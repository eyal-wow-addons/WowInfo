local _, addon = ...
local Quests = addon:NewObject("Quests")

local INFO = {
    QUESTS = {},
    STORY = {},
    CAMPAIGN = {}
}

local CACHE = {
    QUESTS = {},
    STORY = {},
    CAMPAIGN = {}
}

local EMPTY_CHAPTERS = {}

local function IterableQuestInfo()
    local i = 0
    local n = C_QuestLog.GetNumQuestLogEntries()
    return function()
        i = i + 1
        while i <= n do
            local questInfo = C_QuestLog.GetInfo(i)
            if questInfo and not questInfo.isHeader and not questInfo.isHidden and QuestHasPOIInfo(questInfo.questID) then
                return questInfo, questInfo.questID
            end
            i = i + 1
        end
    end
end

local function CacheQuestLogInfo()
    local numQuests, completedQuests = 0, 0

    for _, questID in IterableQuestInfo() do
        numQuests = numQuests + 1
        if C_QuestLog.IsComplete(questID) then
            completedQuests = completedQuests + 1
        end
    end

    CACHE.QUESTS.total = numQuests
    CACHE.QUESTS.totalCompleted = completedQuests
    CACHE.QUESTS.totalIncompleted = numQuests - completedQuests
end

local function CacheCampaignInfo()
    CACHE.CAMPAIGN.ID = nil
    CACHE.CAMPAIGN.title = nil
    CACHE.CAMPAIGN.chapterIDs = nil
    CACHE.CAMPAIGN.numCompleted = nil
    CACHE.CAMPAIGN.isCompleted = nil

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questInfo = C_QuestLog.GetInfo(i)
        local campaignID = questInfo.campaignID

        if campaignID and questInfo.isHeader and not questInfo.useMinimalHeader then
            local chapterIDs = EMPTY_CHAPTERS
            local completedChapters = 0
            local state = C_CampaignInfo.GetState(campaignID)

            if state == Enum.CampaignState.InProgress or state == Enum.CampaignState.Stalled then
                chapterIDs = C_CampaignInfo.GetChapterIDs(campaignID)
                for _, chapterID in ipairs(chapterIDs) do
                    if C_QuestLine.IsComplete(chapterID) then
                        completedChapters = completedChapters + 1
                    end
                end
            elseif state == Enum.CampaignState.Invalid then
                campaignID = nil
            end
            
            CACHE.CAMPAIGN.ID = campaignID
            CACHE.CAMPAIGN.title = questInfo.title
            CACHE.CAMPAIGN.chapterIDs = chapterIDs
            CACHE.CAMPAIGN.numCompleted = completedChapters
            CACHE.CAMPAIGN.isCompleted = state == Enum.CampaignState.Complete 
        end
    end
end

local function CacheZoneStoryInfo()
    CACHE.STORY.ID = nil
    CACHE.STORY.title = nil
    CACHE.STORY.numCriteria = nil
    CACHE.STORY.numCompleted = nil
    CACHE.STORY.isCompleted = nil

    local mapID = C_Map.GetBestMapForUnit("player")

    if mapID then
        local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID)

        if storyAchievementID then
            local mapInfo = C_Map.GetMapInfo(storyMapID)
            local numCriteria = GetAchievementNumCriteria(storyAchievementID)
            local numCompletedCriteria = 0

            for i = 1, numCriteria do
                local _, _, completed = GetAchievementCriteriaInfo(storyAchievementID, i)
                if completed then
                    numCompletedCriteria = numCompletedCriteria + 1
                end
            end

            CACHE.STORY.ID = storyAchievementID
            CACHE.STORY.title = mapInfo.name
            CACHE.STORY.numCriteria = numCriteria
            CACHE.STORY.numCompleted = numCompletedCriteria
            CACHE.STORY.isCompleted = numCriteria == numCompletedCriteria
        end
    end
end

local function CacheQuestsData(_, eventName, ...)
    if eventName == "UNIT_QUEST_LOG_CHANGED" then
        local arg1 = ...
        if arg1 ~= "player" then return end
    elseif eventName == "ZONE_CHANGED" or eventName == "ZONE_CHANGED_NEW_AREA" then
        CacheZoneStoryInfo()
    else
        CacheZoneStoryInfo()
        CacheQuestLogInfo()
        CacheCampaignInfo()
    end
end

Quests:RegisterEvent("PLAYER_LOGIN", function(self, ...)
    CacheQuestsData(self, ...)
    self:RegisterEvents(
        "QUEST_ACCEPTED",
        "QUEST_REMOVED", 
        "QUEST_TURNED_IN",
        "ZONE_CHANGED",
        "ZONE_CHANGED_NEW_AREA",
        "UNIT_QUEST_LOG_CHANGED", CacheQuestsData)
end)

do
    local QuestResetTimeSecondsFormatter = CreateFromMixins(SecondsFormatterMixin)
    QuestResetTimeSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, false)

    function Quests:GetResetTimeString()
        return QuestResetTimeSecondsFormatter:Format(GetQuestResetTime())
    end
end

function Quests:GetQuestLogInfo()
    INFO.QUESTS = CACHE.QUESTS
    return INFO.QUESTS
end

function Quests:GetCampaignInfo()
    INFO.CAMPAIGN = CACHE.CAMPAIGN
    return INFO.CAMPAIGN
end

function Quests:IterableCampaignChaptersInfo()
    local currentChapterID
    local i = 0
    local campaignID = CACHE.CAMPAIGN.ID
    local chapterIDs = CACHE.CAMPAIGN.chapterIDs
    local n = chapterIDs and #chapterIDs or 0
    return function()
        if not campaignID then
            return
        elseif not currentChapterID then
            currentChapterID = C_CampaignInfo.GetCurrentChapterID(campaignID)
        end
        i = i + 1
        if i <= n then
            local chapterID = chapterIDs[i]
            local chapterInfo = C_CampaignInfo.GetCampaignChapterInfo(chapterID)
            local isCompleted = C_QuestLine.IsComplete(chapterID)
            return chapterInfo.name, chapterID == currentChapterID, isCompleted
        end
    end
end

function Quests:GetZoneStoryInfo()
    INFO.STORY = CACHE.STORY
    return INFO.STORY 
end

function Quests:IterableZoneStoryChaptersInfo()
    local storyAchievementID = CACHE.STORY.ID
    local numCriteria = GetAchievementNumCriteria(storyAchievementID)
    local currentCriteria
    local i = 0
    local n = numCriteria or 0
    return function()
        if not storyAchievementID then
            return
        end
        i = i + 1
        if i <= n then
            local title, _, completed = GetAchievementCriteriaInfo(storyAchievementID, i)
            if not currentCriteria and not completed then
                currentCriteria = i
            end
            return title, currentCriteria == i, completed
        end
    end
end
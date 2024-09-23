local _, addon = ...
local L = addon.L
local Quests = addon:NewObject("Quests")

local EMPTY_CHAPTERS = {}

do
    local QuestResetTimeSecondsFormatter = CreateFromMixins(SecondsFormatterMixin)
    QuestResetTimeSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, false)

    function Quests:GetResetTimeString()
        return QuestResetTimeSecondsFormatter:Format(GetQuestResetTime())
    end
end

function Quests:IterableQuestInfo()
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

function Quests:GetTotalQuests()
    local quests, completedQuests = 0, 0
    for _, questID in self:IterableQuestInfo() do
        quests = quests + 1
        if C_QuestLog.IsComplete(questID) then
            completedQuests = completedQuests + 1
        end
    end
    return quests, completedQuests, quests - completedQuests
end

function Quests:GetCampaignInfo()
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questInfo = C_QuestLog.GetInfo(i)
        local campaignID = questInfo.campaignID
        if campaignID and questInfo.isHeader and not questInfo.useMinimalHeader then
            local chapterIDs = EMPTY_CHAPTERS
            local completedChapters = 0
            local state = C_CampaignInfo.GetState(campaignID)
            local progressString
            if state == Enum.CampaignState.InProgress or state == Enum.CampaignState.Stalled then
                chapterIDs = C_CampaignInfo.GetChapterIDs(campaignID)
                for _, chapterID in ipairs(chapterIDs) do
                    if C_QuestLine.IsComplete(chapterID) then
                        completedChapters = completedChapters + 1
                    end
                end
                progressString = L["Campaign Progress: X/Y Chapters"]:format(completedChapters, #chapterIDs)
            elseif state == Enum.CampaignState.Invalid then
                campaignID = nil
            end
            return campaignID, questInfo.title, state == Enum.CampaignState.Complete, progressString, chapterIDs
        end
    end
end

function Quests:IterableCampaignChaptersInfo(campaignID, chapterIDs)
    local currentChapterID
    local i = 0
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
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        local storyAchievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(mapID)
        if storyAchievementID then
            local mapInfo = C_Map.GetMapInfo(storyMapID)
            local numCriteria = GetAchievementNumCriteria(storyAchievementID)
            local completedCriteria = 0
            for i = 1, numCriteria do
                local _, _, completed = GetAchievementCriteriaInfo(storyAchievementID, i)
                if completed then
                    completedCriteria = completedCriteria + 1
                end
            end
            return storyAchievementID, mapInfo.name, numCriteria == completedCriteria, L["Story Progress: X/Y Chapters"]:format(completedCriteria, numCriteria)
        end
    end
end

function Quests:IterableZoneStoryChaptersInfo(storyAchievementID)
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
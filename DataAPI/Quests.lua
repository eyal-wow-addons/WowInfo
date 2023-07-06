local _, addon = ...
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
    local questInfo = C_QuestLog.GetInfo(1)
    local campaignID = questInfo.campaignID
    if questInfo.isHeader and campaignID then
        local chapterIDs = EMPTY_CHAPTERS
        local completedChapters = 0
        local state = C_CampaignInfo.GetState(campaignID)
        local progressString
        if state == Enum.CampaignState.InProgress then
            chapterIDs = C_CampaignInfo.GetChapterIDs(campaignID)
            for _, chapterID in ipairs(chapterIDs) do
                if C_QuestLine.IsComplete(chapterID) then
                    completedChapters = completedChapters + 1
                end
            end
            progressString = CAMPAIGN_PROGRESS_CHAPTERS_TOOLTIP:format(completedChapters, #chapterIDs)
        end
        return questInfo.title, campaignID, chapterIDs, progressString
    end
end

function Quests:IterableCampaignChaptersInfo(campaignID, chapterIDs)
    local state = C_CampaignInfo.GetState(campaignID)
    local currentChapterID = C_CampaignInfo.GetCurrentChapterID(campaignID)
    local i = 0
    local n = chapterIDs and #chapterIDs or 0
    return function()
        if state ~= Enum.CampaignState.InProgress then
            return
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
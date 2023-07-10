local _, addon = ...
local Display = addon:NewDisplay("QuestLog")
local Quests = addon.Quests

local TOTAL_QUESTS_LABEL = "Total Quests"
local COMPLETED_QUESTS_LABEL = "Completed"
local INCOMPLETED_QUESTS_LABEL = "Incompleted"

local function AddCampaign(id, title, isCompleted, progressString, chaptersIterator, ...)
    if id then
        Display:AddEmptyLine()
        if not isCompleted then
            Display:AddHighlightLine(title)
            Display:AddEmptyLine()
            Display:AddLine(progressString)
            for chapterName, isCurrentChapter, isChapterCompleted in chaptersIterator(Quests, id, ...) do
                if isCurrentChapter then
                    Display:AddHighlightLine(chapterName)
                elseif isChapterCompleted then
                    Display:AddLine(chapterName, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                else
                    Display:AddGrayLine(chapterName)
                end
            end
        else
            Display:AddLeftHighlightDoubleLine(title, CRITERIA_COMPLETED, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
    end
end

Display:RegisterHookScript(QuestLogMicroButton, "OnEnter", function()
    local quests, completedQuests, incompletedQuests = Quests:GetTotalQuests()
    local campaignID, campaignTitle, isCampaignCompleted, campaignProgressString, campaignChapterIDs = Quests:GetCampaignInfo()
    local storyAchievementID, storyTitle, isStoryCompleted, storyProgressString = Quests:GetZoneStoryInfo()

    if quests > 0 then
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(TOTAL_QUESTS_LABEL, quests)
        Display:AddRightHighlightDoubleLine(COMPLETED_QUESTS_LABEL, completedQuests)
        Display:AddRightHighlightDoubleLine(INCOMPLETED_QUESTS_LABEL, incompletedQuests)
    end

    AddCampaign(campaignID, campaignTitle, isCampaignCompleted, campaignProgressString, Quests.IterableCampaignChaptersInfo, campaignChapterIDs)

    AddCampaign(storyAchievementID, storyTitle, isStoryCompleted, storyProgressString, Quests.IterableZoneStoryChaptersInfo)

    Display:Show()
end)


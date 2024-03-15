local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Quests")
local Quests = addon.Quests

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
            Display:AddLeftHighlightDoubleLine(title, L["Completed"], GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
    end
end

Display:RegisterHookScript(QuestLogMicroButton, "OnEnter", function()
    local quests, completedQuests, incompletedQuests = Quests:GetTotalQuests()
    local campaignID, campaignTitle, isCampaignCompleted, campaignProgressString, campaignChapterIDs = Quests:GetCampaignInfo()
    local storyAchievementID, storyTitle, isStoryCompleted, storyProgressString = Quests:GetZoneStoryInfo()

    if quests > 0 then
        Display:AddTitleDoubleLine(L["Total Quests"], quests)
        Display:AddRightHighlightDoubleLine(L["Completed"], completedQuests)
        Display:AddRightHighlightDoubleLine(L["Incompleted"], incompletedQuests)
    end

    AddCampaign(campaignID, campaignTitle, isCampaignCompleted, campaignProgressString, Quests.IterableCampaignChaptersInfo, campaignChapterIDs)

    AddCampaign(storyAchievementID, storyTitle, isStoryCompleted, storyProgressString, Quests.IterableZoneStoryChaptersInfo)

    Display:Show()
end)


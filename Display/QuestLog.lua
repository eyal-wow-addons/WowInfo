local _, addon = ...
local Display = addon:NewDisplay("QuestLog")
local Quests = addon.Quests

local TOTAL_QUESTS_LABEL = "Total Quests"
local COMPLETED_QUESTS_LABEL = "Completed"
local INCOMPLETED_QUESTS_LABEL = "Incompleted"

Display:RegisterHookScript(QuestLogMicroButton, "OnEnter", function()
    local quests, completedQuests, incompletedQuests = Quests:GetTotalQuests()
    local title, ID, chapterIDs, progressString = Quests:GetCampaignInfo()

    if quests > 0 then
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(TOTAL_QUESTS_LABEL, quests)
        Display:AddRightHighlightDoubleLine(COMPLETED_QUESTS_LABEL, completedQuests)
        Display:AddRightHighlightDoubleLine(INCOMPLETED_QUESTS_LABEL, incompletedQuests)
    end
    
    if title then
        Display:AddEmptyLine()
        Display:AddHighlightLine(title)
        Display:AddEmptyLine()
        Display:AddLine(progressString)
        for chapterName, isCurrentChapter, isCompleted in Quests:IterableCampaignChaptersInfo(ID, chapterIDs) do
            if isCurrentChapter then
                Display:AddHighlightLine(chapterName)
            elseif isCompleted then
                Display:AddLine(chapterName)
            else
                Display:AddGrayLine(chapterName)
            end
        end
    end

    Display:Show()
end)


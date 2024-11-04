local _, addon = ...
local Quests = addon:GetObject("Quests")
local Tooltip = addon:NewTooltip("Quests")

local L = addon.L

local function AddQuestHeader(headerInfo, progressString, progressIterator)
    if not headerInfo.ID then
        return
    end
    Tooltip:AddEmptyLine()
    if not headerInfo.isCompleted then
        Tooltip
            :SetLine(headerInfo.title)
            :SetHighlight()
            :ToLine()
            :AddEmptyLine()
            :AddLine(progressString)
        for stepName, isCurrentStep, isStepCompleted in progressIterator(Quests) do
            Tooltip:SetLine(stepName)
            if isCurrentStep then
                Tooltip:SetHighlight()
            elseif isStepCompleted then
                Tooltip:SetGreenColor()
            else
                Tooltip:SetGrayColor()
            end
            Tooltip:ToLine()
        end
    else
        Tooltip
            :SetLine(headerInfo.title)
            :SetHighlight()
            :SetLine(L["Completed"])
            :SetGreenColor()
            :ToLine()
    end
end

Tooltip.target = {
    button = QuestLogMicroButton,
    onEnter = function()
        local questLogInfo = Quests:GetQuestLogInfo()
        local campaignInfo = Quests:GetCampaignInfo()
        local storyInfo = Quests:GetZoneStoryInfo()
    
        if questLogInfo.total > 0 then
            Tooltip
                :SetDoubleLine(L["Total Quests"], questLogInfo.total)
                :ToHeader()
    
            Tooltip
                :SetDoubleLine(L["Completed"], questLogInfo.totalCompleted)
                :SetHighlight()
                :ToLine()
    
             Tooltip
                :SetDoubleLine(L["Incompleted"], questLogInfo.totalIncompleted)
                :SetHighlight()
                :ToLine()
        end
    
        AddQuestHeader(
            campaignInfo, 
            L["Campaign Progress: X/Y Chapters"]:format(campaignInfo.numCompleted, campaignInfo.numChapters), 
            Quests.IterableCampaignChaptersInfo)
    
        AddQuestHeader(
            storyInfo,
            L["Story Progress: X/Y Chapters"]:format(storyInfo.numCompleted, storyInfo.numCriteria), 
            Quests.IterableZoneStoryChaptersInfo)
    end
}
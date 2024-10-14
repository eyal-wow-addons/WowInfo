local _, addon = ...
local Quests = addon:GetObject("Quests")
local Display = addon:NewDisplay("Quests")

local L = addon.L

local function AddQuestHeader(headerInfo, progressString, progressIterator)
    if not headerInfo.ID then
        return
    end
    Display:AddEmptyLine()
    if not headerInfo.isCompleted then
        Display
            :SetLine(headerInfo.title)
            :SetHighlight()
            :ToLine()
            :AddEmptyLine()
            :AddLine(progressString)
        for stepName, isCurrentStep, isStepCompleted in progressIterator(Quests) do
            Display:SetLine(stepName)
            if isCurrentStep then
                Display:SetHighlight()
            elseif isStepCompleted then
                Display:SetGreenColor()
            else
                Display:SetGrayColor()
            end
            Display:ToLine()
        end
    else
        Display
            :SetLine(headerInfo.title)
            :SetHighlight()
            :SetLine(L["Completed"])
            :SetGreenColor()
            :ToLine()
    end
end

Display:RegisterHookScript(QuestLogMicroButton, "OnEnter", function()
    local questLogInfo = Quests:GetQuestLogInfo()
    local campaignInfo = Quests:GetCampaignInfo()
    local storyInfo = Quests:GetZoneStoryInfo()

    if questLogInfo.total > 0 then
        Display
            :SetDoubleLine(L["Total Quests"], questLogInfo.total)
            :ToHeader()

        Display
            :SetDoubleLine(L["Completed"], questLogInfo.totalCompleted)
            :SetHighlight()
            :ToLine()

         Display
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

    Display:Show()
end)


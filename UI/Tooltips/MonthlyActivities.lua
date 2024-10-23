local _, addon = ...
local MonthlyActivities = addon:GetObject("MonthlyActivities")
local Tooltip = addon:NewTooltip("MonthlyActivities")

local L = addon.L

local PROGRESS_FORMAT = "%s / %s"

Tooltip:RegisterHookScript(EJMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    local earnedThresholdAmount, thresholdMax, itemReward, pendingReward, monthString, timeString = MonthlyActivities:GetProgressInfo()
  
    if earnedThresholdAmount then
        local thresholdProgressString = PROGRESS_FORMAT:format(earnedThresholdAmount, thresholdMax)

        if itemReward and not Tooltip.itemDataLoadedCancelFunc then
            Tooltip.itemDataLoadedCancelFunc = function()
                local itemName = itemReward:GetItemName()
                if itemName then
                    Tooltip
                        :SetLine(L["Traveler's Log Progress:"])
                        :SetHighlight()
                        :ToLine()
                        :SetLine(itemName)
                        :SetItemQualityColor(itemReward)
                        :SetLine(thresholdProgressString)
                        :SetHighlight()
                        :ToLine()
                        :AddIcon(itemReward:GetItemIcon())
                        :Show()
                end
            end
        end

        Tooltip
            :SetDoubleLine(L["Traveler's Log:"], monthString)
            :ToHeader()
            :AddEmptyLine()
            :SetDoubleLine(" ", timeString)
            :SetHighlight()
            :ToLine()
            :AddEmptyLine()

        if itemReward then
            itemReward:ContinueWithCancelOnItemLoad(Tooltip.itemDataLoadedCancelFunc)
        else
            Tooltip
                :SetDoubleLine(L["Travel Points"], thresholdProgressString)
                :SetHighlight()
                :ToLine()
        end

        if pendingReward then
            Tooltip
                :AddEmptyLine()
                :SetLine(L["Collect your reward in the Collector's Cache at the Trading Post."])
                :SetGreenColor()
                :ToLine()
        end

        Tooltip:Show()
    end
end)

Tooltip:RegisterHookScript(EJMicroButton, "OnLeave", function(self)
    Tooltip:Hide()
	if Tooltip.itemDataLoadedCancelFunc then
		Tooltip.itemDataLoadedCancelFunc()
		Tooltip.itemDataLoadedCancelFunc = nil
	end
end)


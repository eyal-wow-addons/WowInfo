local _, addon = ...
local MonthlyActivities = addon:GetObject("MonthlyActivities")
local Display = addon:NewDisplay("MonthlyActivities")

local L = addon.L

Display:RegisterHookScript(EJMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    local earnedThresholdAmount, thresholdMax, itemReward, pendingReward, monthString, timeString = MonthlyActivities:GetInfo()
  
    if earnedThresholdAmount then
        local thresholdProgressString = addon.PATTERNS.PROGRESS1:format(earnedThresholdAmount, thresholdMax)

        if itemReward and not Display.itemDataLoadedCancelFunc then
            Display.itemDataLoadedCancelFunc = function()
                local itemName = itemReward:GetItemName()
                if itemName then
                    Display
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

        Display
            :SetDoubleLine(L["Traveler's Log:"], monthString)
            :ToHeader()
            :AddEmptyLine()
            :SetDoubleLine(" ", timeString)
            :SetHighlight()
            :ToLine()
            :AddEmptyLine()

        if itemReward then
            itemReward:ContinueWithCancelOnItemLoad(Display.itemDataLoadedCancelFunc)
        else
            Display
                :SetDoubleLine(L["Travel Points"], thresholdProgressString)
                :SetHighlight()
                :ToLine()
        end

        if pendingReward then
            Display
                :AddEmptyLine()
                :SetLine(L["Collect your reward in the Collector's Cache at the Trading Post."])
                :SetGreenColor()
                :ToLine()
        end

        Display:Show()
    end
end)

Display:RegisterHookScript(EJMicroButton, "OnLeave", function(self)
    Display:Hide()
	if Display.itemDataLoadedCancelFunc then
		Display.itemDataLoadedCancelFunc()
		Display.itemDataLoadedCancelFunc = nil
	end
end)


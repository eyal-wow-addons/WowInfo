local _, addon = ...
local MonthlyActivities = addon:GetObject("MonthlyActivities")
local Tooltip = addon:NewTooltip("MonthlyActivities")

local L = addon.L

local PROGRESS_FORMAT = "%s / %s"

MonthlyActivities:RegisterEvent("WOWINFO_MONTHLY_ACTIVITIES_REWARD", function(_, _, itemName, itemColor, progress, itemIcon)
    local progressPct = FormatPercentage(progress)

    Tooltip
        :SetLine(L["Traveler's Log Progress:"])
        :SetHighlight()
        :ToLine()
        :SetLine(itemName)
        :SetColor(itemColor)
        :SetLine(progressPct)
        :SetHighlight()
        :ToLine()

    if itemIcon then
        Tooltip:AddIcon(itemIcon)
    end

    Tooltip:Show()
end)

Tooltip.target = {
    button = EJMicroButton,
    onEnter = function()
        local monthlyActivities = MonthlyActivities:GetProgressInfo()
      
        Tooltip
            :SetDoubleLine(L["Traveler's Log:"], monthlyActivities.monthString)
            :ToHeader()
            :AddEmptyLine()
            :SetDoubleLine(" ", monthlyActivities.timeString)
            :SetHighlight()
            :ToLine()
            :AddEmptyLine()
    
        if monthlyActivities.hasReward then
            MonthlyActivities:TryLoadItemReward()
        else
            local progressString = PROGRESS_FORMAT:format(monthlyActivities.currentValue, monthlyActivities.maxValue)

            Tooltip
                :SetDoubleLine(L["Travel Points"], progressString)
                :SetHighlight()
                :ToLine()
        end

        if monthlyActivities.hasRewardPending then
            Tooltip
                :AddEmptyLine()
                :SetLine(L["Collect your reward in the Collector's Cache at the Trading Post."])
                :SetGreenColor()
                :ToLine()
        end
    end,
    onLeave = function()
        MonthlyActivities:CancelItemReward()
    end
}
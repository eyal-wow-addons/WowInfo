local _, addon = ...
local Display = addon:NewDisplay("MonthlyActivities")
local EncounterJournal = addon.EncounterJournal

local MONTHLY_ACTIVITIES_LABEL = MONTHLY_ACTIVITIES_TAB .. ":"

local itemTextureSettings = {
    width = 14,
    height = 14,
    verticalOffset = 0,
    margin = { right = 2, top = 2, bottom = 2 },
}

Display:RegisterHookScript(EJMicroButton, "OnEnter", function()
    local thresholdProgressString, itemReward, pendingReward, monthString, timeString = EncounterJournal:GetMonthlyActivitiesInfo()

    if thresholdProgressString then
        Display:AddEmptyLine()
        Display:AddHighlightLine(MONTHLY_ACTIVITIES_LABEL)
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(monthString, timeString)
        Display:AddEmptyLine()

        if itemReward then
            local itemName = itemReward:GetItemName()
            local itemColor = itemReward:GetItemQualityColor()
            Display:AddLine(MONTHLY_ACTIVITIES_PROGRESSED)
            Display:AddRightHighlightDoubleLine(itemName, thresholdProgressString, itemColor.r, itemColor.g, itemColor.b)
            Display:AddTexture(itemReward:GetItemIcon(), itemTextureSettings)
        else
            Display:AddRightHighlightDoubleLine(MONTHLY_ACTIVITIES_POINTS, thresholdProgressString)
        end

        if pendingReward then
            Display:AddEmptyLine()
            Display:AddHighlightLine(MONTHLY_ACTIVITIES_THRESHOLD_TOOLTIP_PENDING)
        end

        Display:Show()
    end
end)


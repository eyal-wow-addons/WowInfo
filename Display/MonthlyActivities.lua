local _, addon = ...
local Display = addon:NewDisplay("MonthlyActivities")
local EncounterJournal = addon.EncounterJournal

local MONTHLY_ACTIVITIES_LABEL = MONTHLY_ACTIVITIES_TAB .. ":"
local MONTHLY_ACTIVITIES_PROGRESSED = MONTHLY_ACTIVITIES_PROGRESSED .. ":"

local itemTextureSettings = {
    width = 20,
    height = 20,
    verticalOffset = 3,
    margin = { right = 5, bottom = 5 },
}

Display:RegisterHookScript(EJMicroButton, "OnEnter", function(self)
    local thresholdProgressString, itemReward, pendingReward, monthString, timeString = EncounterJournal:GetMonthlyActivitiesInfo()

    if thresholdProgressString then
        if itemReward and not Display.itemDataLoadedCancelFunc then
            Display.itemDataLoadedCancelFunc = function()
                local itemName = itemReward:GetItemName()
                local itemColor = itemReward:GetItemQualityColor() or HIGHLIGHT_FONT_COLOR
                if itemName then
                    Display:AddHighlightLine(MONTHLY_ACTIVITIES_PROGRESSED)
                    Display:AddRightHighlightDoubleLine(itemName, thresholdProgressString, itemColor.r, itemColor.g, itemColor.b)
                    Display:AddTexture(itemReward:GetItemIcon(), itemTextureSettings)
                    Display:Show()
                end
            end
        end
        
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(MONTHLY_ACTIVITIES_LABEL, monthString)
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(" ", timeString)
        Display:AddEmptyLine()

        if itemReward then
            itemReward:ContinueWithCancelOnItemLoad(Display.itemDataLoadedCancelFunc)
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

Display:RegisterHookScript(EJMicroButton, "OnLeave", function(self)
    Display:Hide()
	if Display.itemDataLoadedCancelFunc then
		Display.itemDataLoadedCancelFunc()
		Display.itemDataLoadedCancelFunc = nil
	end
end)


local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("MonthlyActivities")
local EncounterJournal = addon.EncounterJournal

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
                    Display:AddHighlightLine(L["Traveler's Log Progress:"])
                    Display:AddRightHighlightDoubleLine(itemName, thresholdProgressString, itemColor.r, itemColor.g, itemColor.b)
                    Display:AddTexture(itemReward:GetItemIcon(), itemTextureSettings)
                    Display:Show()
                end
            end
        end
        
        Display:AddTitleDoubleLine(L["Traveler's Log:"], monthString)
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(" ", timeString)
        Display:AddEmptyLine()

        if itemReward then
            itemReward:ContinueWithCancelOnItemLoad(Display.itemDataLoadedCancelFunc)
        else
            Display:AddRightHighlightDoubleLine(L["Travel Points"], thresholdProgressString)
        end

        if pendingReward then
            Display:AddEmptyLine()
            Display:AddHighlightLine(L["Collect your reward in the Collector's Cache at the Trading Post"])
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


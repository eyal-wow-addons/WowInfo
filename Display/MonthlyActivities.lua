local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("MonthlyActivities")
local EncounterJournal = addon.EncounterJournal

Display:RegisterHookScript(EJMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    local thresholdProgressString, itemReward, pendingReward, monthString, timeString = EncounterJournal:GetMonthlyActivitiesInfo()

    if thresholdProgressString then
        if itemReward and not Display.itemDataLoadedCancelFunc then
            Display.itemDataLoadedCancelFunc = function()
                local itemName = itemReward:GetItemName()
                local itemColor = itemReward:GetItemQualityColor() or HIGHLIGHT_FONT_COLOR
                if itemName then
                    Display:AddHighlightLine(L["Traveler's Log Progress:"])
                    Display:AddRightHighlightDoubleLine(itemName, thresholdProgressString, itemColor.r, itemColor.g, itemColor.b)
                    Display:AddIcon(itemReward:GetItemIcon())
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
            Display:AddGreenLine(L["Collect your reward in the Collector's Cache at the Trading Post."])
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


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
        if itemReward and not itemReward:IsItemDataCached() then
            self.itemDataLoadedCancelFunc = itemReward:ContinueOnItemLoad(GenerateClosure(self.OnEnter, self))
        end
    
        self.itemDataLoadedCancelFunc = nil
        
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(MONTHLY_ACTIVITIES_LABEL, monthString)
        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(" ", timeString)
        Display:AddEmptyLine()

        if itemReward then
            local itemName = itemReward:GetItemName()
            local itemColor = itemReward:GetItemQualityColor() or HIGHLIGHT_FONT_COLOR
            Display:AddHighlightLine(MONTHLY_ACTIVITIES_PROGRESSED)
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

Display:RegisterHookScript(EJMicroButton, "OnLeave", function(self)
    Display:Hide()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc()
		self.itemDataLoadedCancelFunc = nil
	end
end)


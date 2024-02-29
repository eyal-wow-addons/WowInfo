local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Experience")
local Experience = addon.Experience

Display:RegisterHookScript(MainStatusTrackingBarContainer.bars[4], "OnEnter", function()
    GameTooltip_SetDefaultAnchor(Display, UIParent)

    local currentProgressString, exhaustionString, nextLevelProgressString = Experience:GetPlayerProgressInfo()

    Display:AddHighlightLine(L["Experience:"])
    Display:AddRightHighlightDoubleLine(L["Current"], currentProgressString)

    Display:AddRightHighlightDoubleLine(L["To Next Level (X)"]:format(UnitLevel("player") + 1), nextLevelProgressString)

    if exhaustionString then
        Display:AddRightHighlightDoubleLine(L["Rested"], exhaustionString)
    end

    Display:Show()
end)

local _, addon = ...
local Display = addon:NewDisplay("Experience")
local Experience = addon.Experience

local EXP_LABEL = "Experience:"
local EXP_TNL_LABEL_FORMAT = "To Next Level (|cffffffff%d|r)"
local EXP_CURRENT_LABEL = "Current"
local EXP_RESTED_LABEL = "Rested"

Display:RegisterHookScript(MainStatusTrackingBarContainer.bars[4], "OnEnter", function()
    GameTooltip_SetDefaultAnchor(Display, UIParent)

    local currentProgressString, exhaustionString, nextLevelProgressString = Experience:GetPlayerProgressInfo()

    Display:AddHighlightLine(EXP_LABEL)
    Display:AddRightHighlightDoubleLine(EXP_CURRENT_LABEL, currentProgressString)

    if exhaustionString then
        Display:AddRightHighlightDoubleLine(EXP_RESTED_LABEL, exhaustionString)
    end

    Display:AddRightHighlightDoubleLine(EXP_TNL_LABEL_FORMAT:format(UnitLevel("player") + 1), nextLevelProgressString)
    Display:Show()
end)

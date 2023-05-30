local _, addon = ...
local plugin = addon:NewPlugin("Experience")

local Experience = addon.Experience
local Tooltip = addon.Tooltip

local EXP_LABEL = "Experience:"
local EXP_TNL_LABEL_FORMAT = "To Next Level (|cffffffff%d|r)"
local EXP_CURRENT_LABEL = "Current"
local EXP_RESTED_LABEL = "Rested"

plugin:RegisterHookScript(MainStatusTrackingBarContainer.bars[4], "OnEnter", function()
    GameTooltip_SetDefaultAnchor(Tooltip, UIParent)

    local xp, xpMax, exhaustionThreshold = Experience:GetInfo()

    Tooltip:AddHighlightLine(EXP_LABEL)
    Tooltip:AddRightHighlightDoubleLine(EXP_CURRENT_LABEL, Experience:GetCurrentProgressText(xp, xpMax))

    if exhaustionThreshold then
        Tooltip:AddRightHighlightDoubleLine(EXP_RESTED_LABEL, Experience:GetExhaustionText(exhaustionThreshold, xpMax))
    end

    Tooltip:AddRightHighlightDoubleLine(EXP_TNL_LABEL_FORMAT:format(UnitLevel("player") + 1), Experience:GetNextLevelProgressText(xp, xpMax))

    Tooltip:Show()
end)

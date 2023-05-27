local _, addon = ...
local module = addon:NewModule("Scripts:Experience", "AceHook-3.0")
local Tooltip = addon.Tooltip

local EXP_LABEL = "Experience:"
local EXP_CURRENT_PROGRESS_LABEL_FORMAT = "%s / %s (%s)"
local EXP_RESTED_STATUS_LABEL_FORMAT = "%s (%s)"
local EXP_TNL_PROGRESS_LABEL_FORMAT = "%s (%s)"
local EXP_TNL_LABEL_FORMAT = "To Next Level (|cffffffff%d|r)"
local EXP_CURRENT_LABEL = "Current"
local EXP_RESTED_LABEL = "Rested"

module:SecureHook(ExhaustionTickMixin, "ExhaustionToolTipText", function()
    GameTooltip_SetDefaultAnchor(Tooltip, UIParent)

    local xp, xpMax = UnitXP("player"), UnitXPMax("player")
    Tooltip:AddHighlightLine(EXP_LABEL)
    Tooltip:AddRightHighlightDoubleLine(EXP_CURRENT_LABEL, EXP_CURRENT_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(xp), AbbreviateNumbers(xpMax), FormatPercentage(xp / xpMax, true)))

    local exhaustionThreshold = GetXPExhaustion()
    if exhaustionThreshold then
        Tooltip:AddRightHighlightDoubleLine(EXP_RESTED_LABEL, EXP_RESTED_STATUS_LABEL_FORMAT:format(AbbreviateNumbers(exhaustionThreshold), FormatPercentage(exhaustionThreshold / xpMax, true)))
    end

    local tnl = xpMax - xp
    Tooltip:AddRightHighlightDoubleLine(EXP_TNL_LABEL_FORMAT:format(UnitLevel("player") + 1), EXP_TNL_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(tnl), FormatPercentage(tnl / xpMax, true)))

    Tooltip:Show()
end)

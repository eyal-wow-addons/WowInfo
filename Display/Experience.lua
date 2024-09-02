local _, addon = ...
local Experience = addon:GetObject("Experience")
local Display = addon:NewDisplay("Experience")

local L = addon.L

local CURRENT_PROGRESS_LABEL_FORMAT = "%s / %s (%s)"

local function GetFormattedXpProgress(xp, xpMax, xpPct)
    return AbbreviateNumbers(xp), AbbreviateNumbers(xpMax), FormatPercentage(xpPct, true)
end

local function GetFormattedProgress(tnl, tnlPct)
    return AbbreviateNumbers(tnl), FormatPercentage(tnlPct, true)
end

Display:RegisterHookScript(MainStatusTrackingBarContainer.bars[4], "OnEnter", function()
    Display:Clear()

    local xp, xpMax, xpPct = Experience:GetInfo()
    local tnl, tnlPct = Experience:GetNextLevelInfo(xp, xpMax)
    local exhaustionThreshold, restedPct = Experience:GetRestedInfo(xpMax)

    Display
        :SetLine(L["Experience:"])
        :SetHighlight()
        :ToLine()

    Display
        :SetLine(L["Current"])
        :SetFormattedLine(CURRENT_PROGRESS_LABEL_FORMAT, GetFormattedXpProgress(xp, xpMax, xpPct))
        :SetHighlight()
        :ToLine()

    Display
        :SetFormattedLine(L["To Next Level (X)"], UnitLevel("player") + 1)
        :SetFormattedLine(addon.PATTERNS.PROGRESS2, GetFormattedProgress(tnl, tnlPct))
        :SetHighlight()
        :ToLine()

    if exhaustionThreshold then
        Display
            :SetLine(L["Rested"])
            :SetFormattedLine(addon.PATTERNS.PROGRESS2, GetFormattedProgress(exhaustionThreshold, restedPct))
            :SetHighlight()
            :ToLine()
    end

    Display:Show()
end)

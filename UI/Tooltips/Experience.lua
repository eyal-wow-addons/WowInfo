local _, addon = ...
local Experience = addon:GetObject("Experience")
local Tooltip = addon:NewTooltip("Experience")

local L = addon.L

local PROGRESS_FORMAT = "%s (%s)"
local CURRENT_PROGRESS_LINE_FORMAT = "%s / %s (%s)"

local function GetFormattedXpProgress(xp, xpMax, xpPct)
    return AbbreviateNumbers(xp), AbbreviateNumbers(xpMax), FormatPercentage(xpPct, true)
end

local function GetFormattedProgress(tnl, tnlPct)
    return AbbreviateNumbers(tnl), FormatPercentage(tnlPct, true)
end

Tooltip.target = {
    frame = MainStatusTrackingBarContainer.bars[4],
    onEnter = function()
        Tooltip:Clear()
    
        local xp, xpMax, xpPct = Experience:GetXpInfo()
        local tnl, tnlPct = Experience:GetNextLevelInfo(xp, xpMax)
        local exhaustionThreshold, restedPct = Experience:GetRestedInfo(xpMax)
    
        Tooltip
            :SetLine(L["Experience:"])
            :SetHighlight()
            :ToLine()
    
        Tooltip
            :SetLine(L["Current"])
            :SetFormattedLine(CURRENT_PROGRESS_LINE_FORMAT, GetFormattedXpProgress(xp, xpMax, xpPct))
            :SetHighlight()
            :ToLine()
    
        Tooltip
            :SetFormattedLine(L["To Next Level (X)"], UnitLevel("player") + 1)
            :SetFormattedLine(PROGRESS_FORMAT, GetFormattedProgress(tnl, tnlPct))
            :SetHighlight()
            :ToLine()
    
        if exhaustionThreshold then
            Tooltip
                :SetLine(L["Rested"])
                :SetFormattedLine(PROGRESS_FORMAT, GetFormattedProgress(exhaustionThreshold, restedPct))
                :SetHighlight()
                :ToLine()
        end
    end
}
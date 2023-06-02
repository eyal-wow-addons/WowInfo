local _, addon = ...
local Experience = addon:NewObject("Experience")

local CURRENT_PROGRESS_LABEL_FORMAT = "%s / %s (%s)"
local RESTED_STATUS_LABEL_FORMAT = "%s (%s)"
local TNL_PROGRESS_LABEL_FORMAT = "%s (%s)"

function Experience:GetInfo()
    local xp, xpMax = UnitXP("player"), UnitXPMax("player")
    local exhaustionThreshold = GetXPExhaustion()
    return xp, xpMax, exhaustionThreshold
end

function Experience:GetCurrentProgressString(xp, xpMax)
    return CURRENT_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(xp), AbbreviateNumbers(xpMax), FormatPercentage(xp / xpMax, true))
end

function Experience:GetExhaustionString(exhaustionThreshold, xpMax)
    return RESTED_STATUS_LABEL_FORMAT:format(AbbreviateNumbers(exhaustionThreshold), FormatPercentage(exhaustionThreshold / xpMax, true))
end

function Experience:GetNextLevelProgressString(xp, xpMax)
    local tnl = xpMax - xp
    return TNL_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(tnl), FormatPercentage(tnl / xpMax, true))
end
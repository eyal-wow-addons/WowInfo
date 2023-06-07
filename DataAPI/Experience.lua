local _, addon = ...
local Experience = addon:NewObject("Experience")

local CURRENT_PROGRESS_LABEL_FORMAT = "%s / %s (%s)"
local RESTED_STATUS_LABEL_FORMAT = "%s (%s)"
local TNL_PROGRESS_LABEL_FORMAT = "%s (%s)"

function Experience:GetPlayerProgressInfo()
    local xp, xpMax = UnitXP("player"), UnitXPMax("player")
    local exhaustionThreshold = GetXPExhaustion()
    local currentProgressString = CURRENT_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(xp), AbbreviateNumbers(xpMax), FormatPercentage(xp / xpMax, true))
    local exhaustionString

    if exhaustionThreshold then
        exhaustionString = RESTED_STATUS_LABEL_FORMAT:format(AbbreviateNumbers(exhaustionThreshold), FormatPercentage(exhaustionThreshold / xpMax, true))
    end

    local tnl = xpMax - xp
    local nextLevelProgressString = TNL_PROGRESS_LABEL_FORMAT:format(AbbreviateNumbers(tnl), FormatPercentage(tnl / xpMax, true))
    
    return currentProgressString, exhaustionString, nextLevelProgressString
end
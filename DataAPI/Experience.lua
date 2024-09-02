local _, addon = ...
local Experience = addon:NewObject("Experience")

function Experience:GetInfo()
    local xp, xpMax = UnitXP("player"), UnitXPMax("player")
    return xp, xpMax, xp / xpMax
end

function Experience:GetNextLevelInfo(xp, xpMax)
    local tnl = xpMax - xp
    return tnl, tnl / xpMax
end

function Experience:GetRestedInfo(xpMax)
    local exhaustionThreshold = GetXPExhaustion()
    return exhaustionThreshold, exhaustionThreshold and exhaustionThreshold / xpMax
end
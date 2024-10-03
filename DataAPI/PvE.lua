local _, addon = ...
local PvE = addon:NewObject("PvE")

local INFO = {
    INSTANCE = {},
    WORLD_BOSS = {}
}

PvE:RegisterEvent("PLAYER_LOGIN", function()
    RequestRaidInfo()
end)

function PvE:IterableInstanceInfo()
    local i = 0
    local n = GetNumSavedInstances()
    return function()
        i = i + 1
        while i <= n do
            local instanceName, _, reset, instanceDifficulty, locked, extended, _, _, _, _, maxBosses, defeatedBosses = GetSavedInstanceInfo(i)
            local difficultyName = GetDifficultyInfo(instanceDifficulty)
            
            if locked or extended then
                INFO.INSTANCE.name = instanceName
                INFO.INSTANCE.reset = reset
                INFO.INSTANCE.difficulty = difficultyName
                INFO.INSTANCE.isCleared = defeatedBosses >= maxBosses
                INFO.INSTANCE.defeatedBosses = defeatedBosses
                INFO.INSTANCE.maxBosses = maxBosses
                return INFO.INSTANCE
            end

            i = i + 1
        end
    end
end

function PvE:IterableSavedWorldBossInfo()
    local i = 0
    local n = GetNumSavedWorldBosses()
    return function()
        i = i + 1
        if i <= n then
            local name, _, reset = GetSavedWorldBossInfo(i)
            INFO.WORLD_BOSS.name = name
            INFO.WORLD_BOSS.reset = reset
            return INFO.WORLD_BOSS
        end
    end
end
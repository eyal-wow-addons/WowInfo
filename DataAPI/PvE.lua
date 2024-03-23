local _, addon = ...
local L = addon.L
local PvE = addon:NewObject("PvE")

local INSTANCE_NAME_FORMAT = "%s (%s)"
local INSTANCE_PROGRESS_FORMAT = "|cffff0000%d|r / |cff00ff00%d|r"

PvE:RegisterEvent("PLAYER_LOGIN", function()
    RequestRaidInfo()
end)

function PvE:IterableInstanceInfo()
    local i = 0
    local n = GetNumSavedInstances()
    return function()
        i = i + 1
        while i <= n do
            local instanceName, _, _, instanceDifficulty, locked, extended, _, _, _, _, maxBosses, defeatedBosses = GetSavedInstanceInfo(i)
            
            if locked or extended then
                local instanceNameString = INSTANCE_NAME_FORMAT:format(instanceName, GetDifficultyInfo(instanceDifficulty))
                if defeatedBosses < maxBosses then
                    return instanceNameString, false, INSTANCE_PROGRESS_FORMAT:format(defeatedBosses, maxBosses)
                else
                    return instanceNameString, true, L["Cleared"]
                end
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
            return GetSavedWorldBossInfo(i)
        end
    end
end
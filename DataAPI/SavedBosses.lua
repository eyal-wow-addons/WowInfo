local _, addon = ...
local SavedBosses = addon:NewObject("SavedBosses")

local INSTANCE_NAME_FORMAT = "%s (%s)"
local INSTANCE_PROGRESS_FORMAT = "|cffff0000%d|r / |cff00ff00%d|r"
local INSTANCE_PROGRESS_CLEARED_STATUS = "Cleared"

function SavedBosses:IterableInstanceInfo()
    RequestRaidInfo()
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
                    return instanceNameString, true, INSTANCE_PROGRESS_CLEARED_STATUS
                end
            end

            i = i + 1
        end
    end
end

function SavedBosses:IterableWorldBossInfo()
    local i = 0
    local n = GetNumSavedWorldBosses()
    return function()
        i = i + 1
        if i <= n then
            return GetSavedWorldBossInfo(i)
        end
    end
end
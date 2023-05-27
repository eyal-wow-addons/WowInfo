local _, addon = ...
local module = addon:NewModule("Scripts:Instances")
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip

local INSTANCE_LABEL = "Dungeons & Raids:"
local INSTANCE_CLEARED_STATUS = "Cleared"

local INSTANCE_INFO_LABEL_FORMAT = "%s (%s)"
local INSTANCE_INFO_STATS_FORMAT = "|cffff0000%d|r / |cff00ff00%d|r"

ScriptLoader:AddHookScript(LFDMicroButton, "OnEnter", function()
    RequestRaidInfo()

    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(INSTANCE_LABEL)

    local isSaved

    for index = 1, GetNumSavedInstances() do
        local instanceName, instanceID, _, instanceDifficulty, locked, extended, _, _, _, _, maxBosses, defeatedBosses = GetSavedInstanceInfo(index)
        if locked or extended then
            local label = INSTANCE_INFO_LABEL_FORMAT:format(instanceName, GetDifficultyInfo(instanceDifficulty))
            if defeatedBosses < maxBosses then
                Tooltip:AddRightHighlightDoubleLine(label, INSTANCE_INFO_STATS_FORMAT:format(defeatedBosses, maxBosses))
            else
                Tooltip:AddDoubleLine(label, INSTANCE_CLEARED_STATUS, nil, nil, nil, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
            end
            isSaved = true
        end
    end

    for index = 1, GetNumSavedWorldBosses() do
        local bossName, worldBossID = GetSavedWorldBossInfo(index)
        Tooltip:AddDoubleLine(bossName, BOSS_DEAD, nil, nil, nil, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        isSaved = true
    end

    if not isSaved then
        Tooltip:AddLine(NO_RAID_INSTANCES_SAVED)
    end

    Tooltip:Show()
end)

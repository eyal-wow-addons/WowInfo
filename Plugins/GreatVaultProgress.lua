local _, addon = ...
local plugin = addon:NewPlugin("GreatVaultProgress")

local Tooltip = addon.Tooltip

local GREAT_VAULT_REWARDS_LABEL = GREAT_VAULT_REWARDS .. ":"
local GREAT_VAULT_HAS_REWARDS_DESC_COLOR = "ff19ff19"
local GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR = "ff14b200"
local GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR = "ff0091f2"
local GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR = "ffc745f9"

local function AddGreatVaultProgressTooltipInfo(activityInfo)
    local thresholdString, progressString
    
    if activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid then
        thresholdString = WEEKLY_REWARDS_THRESHOLD_RAID
    elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
        thresholdString = WEEKLY_REWARDS_THRESHOLD_MYTHIC
    elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
        thresholdString = WEEKLY_REWARDS_THRESHOLD_PVP
    end

    thresholdString = thresholdString:format(activityInfo.threshold)

    if activityInfo.index == 1 and activityInfo.progress > activityInfo.minThreshold then
        thresholdString = WrapTextInColorCode(thresholdString, GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR)
    elseif activityInfo.index == 2 and activityInfo.progress > activityInfo.minThreshold then
        thresholdString = WrapTextInColorCode(thresholdString, GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR)
    elseif activityInfo.index == 3 and activityInfo.progress > activityInfo.minThreshold then
        thresholdString = WrapTextInColorCode(thresholdString, GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR)
    end

    if activityInfo.progress > 0 then
        progressString = WrapTextInColorCode(activityInfo.progress, "ffffffff")
    else
        progressString = activityInfo.progress
    end

    Tooltip:AddGrayDoubleLine(thresholdString, progressString)
end

local function GetActivityInfo(type)
    local info
    local minThreshold
    for _, activityInfo in ipairs(C_WeeklyRewards.GetActivities(type)) do
        info = activityInfo
        info.minThreshold = minThreshold or activityInfo.threshold
        if activityInfo.progress <= activityInfo.threshold then
            break
        end
        minThreshold = activityInfo.threshold
    end
    return info
end

plugin:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if IsPlayerAtEffectiveMaxLevel() then
        Tooltip:AddEmptyLine()
        Tooltip:AddHighlightLine(GREAT_VAULT_REWARDS_LABEL)

        if C_WeeklyRewards.HasAvailableRewards() then
            Tooltip:AddHighlightLine(WrapTextInColorCode(GREAT_VAULT_REWARDS_WAITING, GREAT_VAULT_HAS_REWARDS_DESC_COLOR))
        end

        AddGreatVaultProgressTooltipInfo(GetActivityInfo(Enum.WeeklyRewardChestThresholdType.Raid))
        AddGreatVaultProgressTooltipInfo(GetActivityInfo(Enum.WeeklyRewardChestThresholdType.MythicPlus))
        AddGreatVaultProgressTooltipInfo(GetActivityInfo(Enum.WeeklyRewardChestThresholdType.RankedPvP))

        Tooltip:Show()
    end
end)

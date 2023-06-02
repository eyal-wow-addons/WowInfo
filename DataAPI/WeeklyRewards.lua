local _, addon = ...
local WeeklyRewards = addon:NewObject("WeeklyRewards")

local GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR = "ff14b200"
local GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR = "ff0091f2"
local GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR = "ffc745f9"

local function GetGreatVaultProgressInfo(activityInfo)
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

    return thresholdString, progressString
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

function WeeklyRewards:GetGreatVaultRaidProgressInfo()
    return GetGreatVaultProgressInfo(GetActivityInfo(Enum.WeeklyRewardChestThresholdType.Raid))
end

function WeeklyRewards:GetGreatVaultMythicPlusProgressInfo()
    return GetGreatVaultProgressInfo(GetActivityInfo(Enum.WeeklyRewardChestThresholdType.MythicPlus))
end

function WeeklyRewards:GetGreatVaultPvPProgressInfo()
    return GetGreatVaultProgressInfo(GetActivityInfo(Enum.WeeklyRewardChestThresholdType.RankedPvP))
end
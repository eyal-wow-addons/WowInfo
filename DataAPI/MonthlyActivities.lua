local _, addon = ...
local MonthlyActivities = addon:NewObject("MonthlyActivities")

local DATA = {}

local MONTHLY_ACTIVITIES_MONTH_NAMES = {
	MONTH_JANUARY,
	MONTH_FEBRUARY,
	MONTH_MARCH,
	MONTH_APRIL,
	MONTH_MAY,
	MONTH_JUNE,
	MONTH_JULY,
	MONTH_AUGUST,
	MONTH_SEPTEMBER,
	MONTH_OCTOBER,
	MONTH_NOVEMBER,
	MONTH_DECEMBER,
}

local function AreMonthlyActivitiesRestricted()
	return IsTrialAccount() or IsVeteranTrialAccount()
end

local function HasPendingReward(activitiesInfo, pendingRewards, thresholdOrderIndex)
    for _, reward in pairs(pendingRewards) do
        if reward.activityMonthID == activitiesInfo.activePerksMonth and reward.thresholdOrderIndex == thresholdOrderIndex then
            return true
        end
    end
    return false
end

local GetMonthlyActivitiesTimeInfo
do
    local MonthlyActivitiesTimeLeftFormatter = CreateFromMixins(SecondsFormatterMixin)
    MonthlyActivitiesTimeLeftFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, true)
    MonthlyActivitiesTimeLeftFormatter:SetStripIntervalWhitespace(true)

    function MonthlyActivitiesTimeLeftFormatter:GetMinInterval(seconds)
        return SecondsFormatter.Interval.Minutes
    end

    function MonthlyActivitiesTimeLeftFormatter:GetDesiredUnitCount(seconds)
        return 2
    end

    function GetMonthlyActivitiesTimeInfo(displayMonthName, secondsRemaining)
        local time = MonthlyActivitiesTimeLeftFormatter:Format(secondsRemaining)
        local timeString = MONTHLY_ACTIVITIES_DAYS:format(time)
        local monthString

        if displayMonthName and #displayMonthName > 0 then
            monthString = displayMonthName
        else
            local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
            monthString = MONTHLY_ACTIVITIES_MONTH_NAMES[currentCalendarTime.month]
        end

        return monthString, timeString
    end
end

local function CacheInfo()
    local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo()
    local pendingRewards = C_PerksProgram.GetPendingChestRewards()

    local itemReward, pendingReward
    local thresholdMax = 0
    for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
        thresholdInfo.pendingReward = HasPendingReward(activitiesInfo, pendingRewards, thresholdInfo.thresholdOrderIndex)
        if thresholdInfo.requiredContributionAmount > thresholdMax then
            thresholdMax = thresholdInfo.requiredContributionAmount
            itemReward = thresholdInfo.itemReward and Item:CreateFromItemID(thresholdInfo.itemReward) or nil
            pendingReward = thresholdInfo.pendingReward
        end
    end

    -- Prevent divide by zero below
    if thresholdMax == 0 then
        thresholdMax = 1000
    end

    local earnedThresholdAmount = 0
    for _, activity in pairs(activitiesInfo.activities) do
        if activity.completed then
            earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount
        end
    end
    earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax)

    DATA.itemReward = itemReward
    DATA.pendingReward = pendingReward
    DATA.thresholdMax = thresholdMax
    DATA.earnedThresholdAmount = earnedThresholdAmount
    DATA.displayMonthName = activitiesInfo.displayMonthName
    DATA.secondsRemaining = activitiesInfo.secondsRemaining
end

MonthlyActivities:RegisterEvents(
    "PLAYER_LOGIN",
    "CHEST_REWARDS_UPDATED_FROM_SERVER",
    "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED",
    "PERKS_ACTIVITIES_UPDATED",
    "PERKS_ACTIVITY_COMPLETED", function(_, eventName, ...)
        CacheInfo()
    end)

function MonthlyActivities:GetInfo()
    if AreMonthlyActivitiesRestricted() then
        return nil
    end
    return DATA.earnedThresholdAmount, DATA.thresholdMax, DATA.itemReward, DATA.pendingReward, GetMonthlyActivitiesTimeInfo(DATA.displayMonthName, DATA.secondsRemaining)
end
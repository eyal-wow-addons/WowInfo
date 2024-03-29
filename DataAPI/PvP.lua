local _, addon = ...
local PvP = addon:NewObject("PvP")

local NO_ARENA_SEASON = 0

local SEASON_STATE_OFFSEASON = 1
local SEASON_STATE_PRESEASON = 2
local SEASON_STATE_ACTIVE = 3
local SEASON_STATE_DISABLED = 4

local STANDING_FORMAT = "%s / %s"
local CONQUEST_PROGRESS_FORMAT = "%s (%s)"
local RATED_PVP_LABEL_FORMAT = "%s: |cff00ff00%d|r"
local RATED_PVP_WEEKLY_STATUS_FORMAT = "%d (|cff00ff00%d|r + |cffff0000%d|r)"

PvP:RegisterEvent("PLAYER_LOGIN", function()
    RequestRatedInfo()
end)

do
    local ratedPvPDisabled

    local function GetRatedPvPSeasonState()
        local season = GetCurrentArenaSeason()
        if season == NO_ARENA_SEASON then
            if ratedPvPDisabled then
                return SEASON_STATE_PRESEASON
            else
                return SEASON_STATE_OFFSEASON
            end
        else
            if ratedPvPDisabled then
                return SEASON_STATE_DISABLED
            else
                return SEASON_STATE_ACTIVE
            end
        end
    end

    PvP:RegisterEvent("PVP_TYPES_ENABLED", function(_, _, _, ratedBattlegrounds, ratedArenas)
        ratedPvPDisabled = not ratedBattlegrounds and not ratedArenas
    end)

    function PvP:GetRatedPvPSeasonStateInfo()
        if IsPlayerAtEffectiveMaxLevel() then
            local seasonState = GetRatedPvPSeasonState()
            return seasonState == SEASON_STATE_ACTIVE, seasonState == SEASON_STATE_OFFSEASON, seasonState == SEASON_STATE_PRESEASON
        end
    end
end

function PvP:GetPlayerProgressInfo(isActiveSeason, isOffSeason)
    local currentHonor = UnitHonor("player")
    local maxHonor = UnitHonorMax("player")
    local honorLevel = UnitHonorLevel("player")

    if isActiveSeason or isOffSeason then
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID)

        local totalEarned = currencyInfo.totalEarned
        local maxProgress = currencyInfo.maxQuantity
		local progress = math.min(totalEarned, maxProgress)
        local conquestStandingString

        local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress()
	    local displayType = weeklyProgress.displayType
        local isAtMax = progress >= maxProgress

        if not isAtMax then
            conquestStandingString = STANDING_FORMAT:format(progress, maxProgress)
            if displayType == Enum.ConquestProgressBarDisplayType.Seasonal then
                conquestStandingString = YELLOW_FONT_COLOR:WrapTextInColorCode(conquestStandingString)
            else
                conquestStandingString = BLUE_FONT_COLOR:WrapTextInColorCode(conquestStandingString)
            end
            conquestStandingString = CONQUEST_PROGRESS_FORMAT:format(totalEarned, conquestStandingString)
        else
            conquestStandingString = GRAY_FONT_COLOR:WrapTextInColorCode(totalEarned)
        end

        return honorLevel, STANDING_FORMAT:format(currentHonor, maxHonor), conquestStandingString
    end

    return honorLevel, STANDING_FORMAT:format(currentHonor, maxHonor)
end

local function GetSeasonTierInfo(bracketTierID)
    local tierInfo = C_PvP.GetPvpTierInfo(bracketTierID)
    if tierInfo then
        local ascendTierInfo = tierInfo.ascendTier and C_PvP.GetPvpTierInfo(tierInfo.ascendTier)
        local ascendTierName
        if ascendTierInfo then
            ascendTierName = PVPUtil.GetTierName(ascendTierInfo.pvpTierEnum)
        end
        return PVPUtil.GetTierName(tierInfo.pvpTierEnum), tierInfo.tierIconID, ascendTierName
    end
end

function PvP:IterableArenaProgressInfo()
    local i = 0
    local n = #CONQUEST_SIZE_STRINGS
    return function()
        i = i + 1
        if i <= n then
            local name = CONQUEST_SIZE_STRINGS[i]
            local bracketIndex = CONQUEST_BRACKET_INDEXES[i]
            local rating, _, _, _, _, weeklyPlayed, weeklyWon,_, _, pvpTier = GetPersonalRatedInfo(bracketIndex)
            local ratingString, weeklyStatusString
            if rating > 0 then
                ratingString = RATED_PVP_LABEL_FORMAT:format(name, rating)
                weeklyStatusString = RATED_PVP_WEEKLY_STATUS_FORMAT:format(weeklyPlayed, weeklyWon, weeklyPlayed - weeklyWon)
            else
                ratingString = GRAY_FONT_COLOR:WrapTextInColorCode(name)
                weeklyStatusString = GRAY_FONT_COLOR:WrapTextInColorCode(0)
            end
            return ratingString, weeklyStatusString, GetSeasonTierInfo(pvpTier)
        end
    end
end

function PvP:GetSeasonItemRewardInfo()
	local achievementID = C_PvP.GetPVPSeasonRewardAchievementID()

	if achievementID then
		while true do
			local completed = select(4, GetAchievementInfo(achievementID))
			if not completed then
				break
			end

			local supercedingAchievements = C_AchievementInfo.GetSupercedingAchievements(achievementID)
			if not supercedingAchievements[1] then
				break
			end

			achievementID = supercedingAchievements[1]
		end
	end

    if not achievementID or GetAchievementNumCriteria(achievementID) == 0 then
		return
	end

    local criteriaString, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(achievementID, 1)

    if criteriaString and not completed then
        local rewardItemID = C_AchievementInfo.GetRewardItemID(achievementID)
        if rewardItemID then
            local itemReward = Item:CreateFromItemID(rewardItemID)
            if itemReward then
                return itemReward, FormatPercentage(quantity / reqQuantity)
            end
        end
    end
end
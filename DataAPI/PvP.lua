local _, addon = ...
local PvP = addon:NewObject("PvP")

local INFO = {
    Honor = {},
    Rated = {
        Bracket = {},
        Conquest = {}
    }
}

local DATA = {
    SeasonState = 0
}

local ArenaSeasonState = {
    NoSeason = 0,           -- NO_ARENA_SEASON
    OffSeason = 1,          -- SEASON_STATE_OFFSEASON
    Preseason = 2,          -- SEASON_STATE_PRESEASON
    Active = 3,             -- SEASON_STATE_ACTIVE
    Disabled = 4            -- SEASON_STATE_DISABLED
}

local BracketNames = {      -- CONQUEST_SIZE_STRINGS
    ARENA .. ": " .. RATED_SOLO_SHUFFLE_SIZE, 
    ARENA .. ": " .. ARENA_2V2, 
    ARENA .. ": " .. ARENA_3V3, 
    BATTLEGROUNDS .. ": " .. RATED_BG_BLITZ_SIZE, 
    BATTLEGROUNDS .. ": " .. BATTLEGROUND_10V10 
}

local BracketIndexes = {    -- CONQUEST_BRACKET_INDEXES
    7,  -- Solo Shuffle
    1,  -- 2v2
    2,  -- 3v3
    9,  -- Blitz 
    4   -- 10v10
}

local function GetRatedPvPSeasonState(isRatedPvPDisabled)
    local season = GetCurrentArenaSeason()
    if season == ArenaSeasonState.NoSeason then
        if isRatedPvPDisabled then
            return ArenaSeasonState.Preseason
        else
            return ArenaSeasonState.OffSeason
        end
    else
        if isRatedPvPDisabled then
            return ArenaSeasonState.Disabled
        else
            return ArenaSeasonState.Active
        end
    end
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

PvP:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PVP_TYPES_ENABLED",
    --"PVP_RATED_STATS_UPDATE",
    function(_, eventName, ...) 
        if eventName == "PLAYER_LOGIN" then
            RequestRatedInfo()
            RequestPVPOptionsEnabled()
        elseif eventName == "PLAYER_SPECIALIZATION_CHANGED" then
            RequestRatedInfo()
        elseif eventName == "PVP_TYPES_ENABLED" then
            local _, ratedBgs, ratedArenas, ratedSoloShuffle, ratedBGBlitz = ...;
            local isRatedPvPDisabled = not ratedBgs and not ratedArenas and not ratedSoloShuffle and not ratedBGBlitz 
            DATA.SeasonState = GetRatedPvPSeasonState(isRatedPvPDisabled)
        end        
    end)

function PvP:GetHonorProgressInfo()
    INFO.Honor.currentValue = UnitHonor("player")
    INFO.Honor.maxValue = UnitHonorMax("player")
    INFO.Honor.level = UnitHonorLevel("player")
    return INFO.Honor
end

function PvP:GetConquestProgressInfo()
    INFO.Rated.Conquest.currentValue = nil
    INFO.Rated.Conquest.maxValue = nil
    INFO.Rated.Conquest.isCapped = false
    INFO.Rated.Conquest.displayType = nil

    if DATA.SeasonState == ArenaSeasonState.Active or DATA.SeasonState == ArenaSeasonState.OffSeason then
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID)

        local currentValue = currencyInfo.totalEarned
        local maxValue = currencyInfo.maxQuantity
        local isCapped = currentValue >= maxValue

        local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress()
	    local displayType = weeklyProgress.displayType
        
        INFO.Rated.Conquest.currentValue = currentValue
        INFO.Rated.Conquest.maxValue = maxValue
        INFO.Rated.Conquest.isCapped = isCapped
        INFO.Rated.Conquest.displayType = Enum.ConquestProgressBarDisplayType

        return INFO.Rated.Conquest
    end
end

function PvP:IsPreseason()
    return DATA.SeasonState == ArenaSeasonState.Preseason
end

function PvP:IterableBracketInfo()
    local i = 0
    local n = #BracketNames
    return function()
        i = i + 1
        if i <= n then
            local name = BracketNames[i]
            local bracketIndex = BracketIndexes[i]
            local rating, _, _, _, _, weeklyPlayed, weeklyWon,_, _, pvpTier = GetPersonalRatedInfo(bracketIndex)
            local tierName, tierIconID, nextTierName = GetSeasonTierInfo(pvpTier)
            local info = INFO.Rated[i]

            if not info then
                INFO.Rated[i] = {}
                info = INFO.Rated[i]
            end

            info.name = name
            info.rating = rating
            info.weeklyPlayed = weeklyPlayed
            info.weeklyWon = weeklyWon
            info.weeklyLost = weeklyPlayed - weeklyWon
            info.tierName = tierName
            info.tierIcon = tierIconID
            info.nextTierName = nextTierName

            return info
        end
    end
end

function PvP:TryLoadSeasonItemReward()
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
                if not self.__itemDataLoadedCancelFunc then
                    self.__itemDataLoadedCancelFunc = function()
                        local itemQuality = itemReward:GetItemQuality()
                        local itemName = itemReward:GetItemName()
                        local itemIcon = itemReward:GetItemIcon()
                        if itemName and itemIcon then
                            local progress =  quantity / reqQuantity
                            PvP:TriggerEvent("WOWINFO_PVP_SEASON_REWARD", itemName, itemQuality, itemIcon, progress)
                        end
                    end
                end

                itemReward:ContinueWithCancelOnItemLoad(self.__itemDataLoadedCancelFunc)
            end
        end
    end
end

function PvP:CancelSeasonItemReward()
    if self.__itemDataLoadedCancelFunc then
		self.__itemDataLoadedCancelFunc()
		self.__itemDataLoadedCancelFunc = nil
	end
end
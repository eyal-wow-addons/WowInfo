local _, addon = ...
local PvP = addon:NewObject("PvP")

local NO_ARENA_SEASON = 0

local SEASON_STATE_OFFSEASON = 1
local SEASON_STATE_PRESEASON = 2
local SEASON_STATE_ACTIVE = 3
local SEASON_STATE_DISABLED = 4

local HONOR_LEVEL_LABEL = HONOR_LEVEL_LABEL:gsub("%%d", "|cff00ff00%%d|r")
local STANDING_FORMAT = "%s / %s"
local RATED_PVP_LABEL_FORMAT = "%s: |cff00ff00%d|r"
local RATED_PVP_WEEKLY_STATUS_FORMAT = "%d (|cff00ff00%d|r + |cffff0000%d|r)"

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

    PvP:RegisterEvent("PVP_TYPES_ENABLED", function(_, _, ratedBattlegrounds, ratedArenas)
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
        return HONOR_LEVEL_LABEL:format(honorLevel), STANDING_FORMAT:format(currentHonor, maxHonor), STANDING_FORMAT:format(currencyInfo.totalEarned, currencyInfo.maxQuantity)
    end

    return HONOR_LEVEL_LABEL:format(honorLevel), STANDING_FORMAT:format(currentHonor, maxHonor)
end

function PvP:IterableArenaProgressInfo()
    local i = 0
    local n = #CONQUEST_SIZE_STRINGS
    return function()
        i = i + 1
        while i <= n do
            local name = CONQUEST_SIZE_STRINGS[i]
            local bracketIndex = CONQUEST_BRACKET_INDEXES[i]
            local rating, _, _, _, _, weeklyPlayed, weeklyWon = GetPersonalRatedInfo(bracketIndex)
            if rating > 0 then
                return RATED_PVP_LABEL_FORMAT:format(name, rating), RATED_PVP_WEEKLY_STATUS_FORMAT:format(weeklyPlayed, weeklyWon, weeklyPlayed - weeklyWon)
            end
            i = i + 1
        end
    end
end


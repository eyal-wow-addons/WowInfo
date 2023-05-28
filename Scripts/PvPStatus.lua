local _, addon = ...
local module = addon:NewModule("Scripts:PvPStatus", "AceEvent-3.0")
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip

local NO_ARENA_SEASON = 0

local SEASON_STATE_OFFSEASON = 1
local SEASON_STATE_PRESEASON = 2
local SEASON_STATE_ACTIVE = 3
local SEASON_STATE_DISABLED = 4

local RATED_PVP_LABEL = "Rated PvP"
local PVP_PROGRESS_LABEL = "PvP Progress:"
local HONOR_LEVEL_LABEL = HONOR_LEVEL_LABEL:gsub("%%d", "|cff00ff00%%d|r")
local STANDING_FORMAT = "%s / %s"
local RATED_PVP_LABEL_FORMAT = "%s: |cff00ff00%d|r"
local RATED_PVP_STATUS_FORMAT = "%d (|cff00ff00%d|r + |cffff0000%d|r)"

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

module:RegisterEvent("PVP_TYPES_ENABLED", function(event, wargameBattlegrounds, ratedBattlegrounds, ratedArenas)
    ratedPvPDisabled = not ratedBattlegrounds and not ratedArenas
end)

ScriptLoader:AddHookScript(LFDMicroButton, "OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(PVP_PROGRESS_LABEL)

    local currentHonor = UnitHonor("player")
    local maxHonor = UnitHonorMax("player")
    local honorLevel = UnitHonorLevel("player")
    Tooltip:AddRightHighlightDoubleLine(HONOR_LEVEL_LABEL:format(honorLevel), STANDING_FORMAT:format(currentHonor, maxHonor))

    if IsPlayerAtEffectiveMaxLevel() then
        local seasonState = GetRatedPvPSeasonState()
        if seasonState == SEASON_STATE_ACTIVE or seasonState == SEASON_STATE_OFFSEASON then
            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID)

            Tooltip:AddRightHighlightDoubleLine(PVP_CONQUEST, STANDING_FORMAT:format(currencyInfo.totalEarned, currencyInfo.maxQuantity))

            Tooltip:AddEmptyLine()
            Tooltip:AddHighlightDoubleLine(RATED_PVP_LABEL, ARENA_WEEKLY_STATS)

            for index = 1, 3 do
                local name = CONQUEST_SIZE_STRINGS[index]
                local bracketIndex = CONQUEST_BRACKET_INDEXES[index]
                local rating, _, _, _, _, weeklyPlayed, weeklyWon = GetPersonalRatedInfo(bracketIndex)
                if rating > 0 then
                    Tooltip:AddRightHighlightDoubleLine(RATED_PVP_LABEL_FORMAT:format(name, rating), RATED_PVP_STATUS_FORMAT:format(weeklyPlayed, weeklyWon, weeklyPlayed - weeklyWon))
                end
            end
        elseif seasonState == SEASON_STATE_PRESEASON then
            Tooltip:AddLine(PLAYER_V_PLAYER_PRE_SEASON)
        end
    end

    Tooltip:Show()
end)

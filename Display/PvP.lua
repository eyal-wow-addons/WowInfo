local _, addon = ...
local Display = addon:NewDisplay("PvPStatus")
local PvP = addon.PvP

local RATED_PVP_LABEL = "Rated PvP"
local PVP_PROGRESS_LABEL = "PvP Progress:"

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function()
    Display:AddEmptyLine()
    Display:AddHighlightLine(PVP_PROGRESS_LABEL)

    local isActiveSeason, isOffSeason, isPreseason = PvP:GetRatedPvPSeasonStateInfo()
    local honorLevelString, honorProgressString, conquestProgressString = PvP:GetPlayerProgressInfo(isActiveSeason, isOffSeason)

    Display:AddRightHighlightDoubleLine(honorLevelString, honorProgressString)

    if isActiveSeason or isOffSeason then
        Display:AddRightHighlightDoubleLine(PVP_CONQUEST, conquestProgressString)

        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(RATED_PVP_LABEL, ARENA_WEEKLY_STATS)

        for ratingString, weeklyStatusString in PvP:IterableArenaProgressInfo() do
            Display:AddRightHighlightDoubleLine(ratingString, weeklyStatusString)
        end
    elseif isPreseason then
        Display:AddLine(PLAYER_V_PLAYER_PRE_SEASON)
    end

    Display:Show()
end)

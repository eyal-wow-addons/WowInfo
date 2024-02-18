local _, addon = ...
local Display = addon:NewDisplay("PvPSummary")
local PvP = addon.PvP

local PVP_SUMMARY_LABEL = "PvP Progress:"
local RATED_PVP_LABEL = "Rated PvP"

local itemTextureSettings = {
    width = 20,
    height = 20,
    verticalOffset = 3,
    margin = { right = 5, bottom = 5 },
}

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function()
    Display:AddEmptyLine()
    Display:AddHighlightLine(PVP_SUMMARY_LABEL)

    local isActiveSeason, isOffSeason, isPreseason = PvP:GetRatedPvPSeasonStateInfo()
    local honorLevelString, honorProgressString, conquestProgressString = PvP:GetPlayerProgressInfo(isActiveSeason, isOffSeason)

    Display:AddRightHighlightDoubleLine(honorLevelString, honorProgressString)

    if isActiveSeason or isOffSeason then
        Display:AddRightHighlightDoubleLine(PVP_CONQUEST, conquestProgressString)

        Display:AddEmptyLine()
        Display:AddHighlightDoubleLine(RATED_PVP_LABEL, ARENA_WEEKLY_STATS)

        for ratingString, weeklyStatusString, tierName, tierIcon, nextTierName in PvP:IterableArenaProgressInfo() do
            Display:AddRightHighlightDoubleLine(ratingString, weeklyStatusString)
            if tierName and IsShiftKeyDown() then
                Display:AddDoubleLine(tierName, nextTierName)
                Display:AddTexture(tierIcon, itemTextureSettings)
            end
        end

        local itemName, itemTexture, progress = PvP:GetSeasonRewardInfo()

        if itemName then
            Display:AddEmptyLine()
            Display:AddRightHighlightDoubleLine(itemName, progress)
            Display:AddTexture(itemTexture, itemTextureSettings)
        end
    elseif isPreseason then
        Display:AddLine(PLAYER_V_PLAYER_PRE_SEASON)
    end

    Display:Show()
end)

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

        local itemReward, progress = PvP:GetSeasonItemRewardInfo()

        if itemReward then
            if not Display.itemDataLoadedCancelFunc then
                Display.itemDataLoadedCancelFunc = function()
                    local itemQuality = itemReward:GetItemQuality()
                    local itemQualityColor = itemQuality and BAG_ITEM_QUALITY_COLORS[itemQuality] or HIGHLIGHT_FONT_COLOR
                    local itemName, itemIcon = itemQualityColor:WrapTextInColorCode(itemReward:GetItemName()), itemReward:GetItemIcon()
                    Display:AddEmptyLine()
                    Display:AddRightHighlightDoubleLine(itemName, progress)
                    Display:AddTexture(itemIcon, itemTextureSettings)
                    Display:Show()
                end
            end
            itemReward:ContinueWithCancelOnItemLoad(Display.itemDataLoadedCancelFunc)
        end
    elseif isPreseason then
        Display:AddLine(PLAYER_V_PLAYER_PRE_SEASON)
    end

    Display:Show()
end)

Display:RegisterHookScript(LFDMicroButton, "OnLeave", function(self)
    Display:Hide()
	if Display.itemDataLoadedCancelFunc then
		Display.itemDataLoadedCancelFunc()
		Display.itemDataLoadedCancelFunc = nil
	end
end)

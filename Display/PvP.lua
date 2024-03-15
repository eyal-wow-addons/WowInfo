local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("PvP")
local PvP = addon.PvP

local PVP_RATED_NEXT_RANK = "%s > %s"

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function()
    Display:AddTitleLine(L["PvP Progress:"])

    local isActiveSeason, isOffSeason, isPreseason = PvP:GetRatedPvPSeasonStateInfo()
    local honorLevel, honorProgressString, conquestProgressString = PvP:GetPlayerProgressInfo(isActiveSeason, isOffSeason)

    Display:AddRightHighlightDoubleLine(L["Honor Level X"]:format(honorLevel), honorProgressString)

    if isActiveSeason or isOffSeason then
        Display:AddRightHighlightDoubleLine(L["Conquest"], conquestProgressString)

        Display:AddTitleDoubleLine(L["Rated PvP"], L["Weekly Stats"])

        for ratingString, weeklyStatusString, tierName, tierIcon, nextTierName in PvP:IterableArenaProgressInfo() do
            Display:AddRightHighlightDoubleLine(ratingString, weeklyStatusString)
            if tierName and IsShiftKeyDown() then
                Display:AddLine(PVP_RATED_NEXT_RANK:format(tierName, nextTierName))
                Display:AddIcon(tierIcon)
            end
        end

        local itemReward, progress = PvP:GetSeasonItemRewardInfo()

        if itemReward then
            if not Display.itemDataLoadedCancelFunc then
                Display.itemDataLoadedCancelFunc = function()
                    local itemQuality = itemReward:GetItemQuality()
                    local itemQualityColor = itemQuality and BAG_ITEM_QUALITY_COLORS[itemQuality] or HIGHLIGHT_FONT_COLOR
                    local itemName = itemReward:GetItemName()
                    local itemIcon = itemReward:GetItemIcon()
                    if itemName and itemIcon then
                        itemName = itemQualityColor:WrapTextInColorCode(itemName)
                        Display:AddEmptyLine()
                        Display:AddRightHighlightDoubleLine(itemName, progress)
                        Display:AddIcon(itemIcon)
                        Display:Show()
                    end
                end
            end
            itemReward:ContinueWithCancelOnItemLoad(Display.itemDataLoadedCancelFunc)
        end
    elseif isPreseason then
        Display:AddLine(L["Player vs. Player (Preseason)"])
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

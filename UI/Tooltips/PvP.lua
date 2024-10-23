local _, addon = ...
local PvP = addon:GetObject("PvP")
local Tooltip = addon:NewTooltip("PvP")

local L = addon.L

local STANDING_FORMAT = "%s / %s"
local RATED_PVP_LABEL_FORMAT = "%s: |cff00ff00%d|r"
local RATED_PVP_WEEKLY_STATUS_FORMAT = "%d (|cff00ff00%d|r + |cffff0000%d|r)"
local RATED_PVP_NEXT_RANK = "%s > %s"

Tooltip:RegisterHookScript(LFDMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    Tooltip:AddHeader(L["PvP Progress:"])

    local honor = PvP:GetHonorProgressInfo()

    Tooltip
        :SetFormattedLine(L["Honor Level X"], honor.level)
        :SetFormattedLine(STANDING_FORMAT, honor.currentValue, honor.maxValue)
        :SetHighlight()
        :ToLine()

    if IsPlayerAtEffectiveMaxLevel() then
        local conquest = PvP:GetConquestProgressInfo()

        if conquest then
            Tooltip:SetLine(L["Conquest"])
            if not conquest.isCapped then
                Tooltip:SetFormattedLine(STANDING_FORMAT, conquest.currentValue, conquest.maxValue)
                if conquest.displayType == Enum.ConquestProgressBarDisplayType.Seasonal then
                    Tooltip:SetYellowColor()
                else
                    Tooltip:SetBlueColor()
                end
            else
                Tooltip
                    :SetLine(conquest.currentValue)
                    :SetGrayColor()
            end
            Tooltip:ToLine()

            Tooltip
                :SetDoubleLine(L["Rated PvP"], L["Weekly Stats"])
                :ToHeader()

            for bracket in PvP:IterableBracketInfo() do
                if bracket.rating > 0 then
                    Tooltip
                        :SetFormattedLine(RATED_PVP_LABEL_FORMAT, bracket.name, bracket.rating)
                        :SetFormattedLine(RATED_PVP_WEEKLY_STATUS_FORMAT, bracket.weeklyPlayed, bracket.weeklyWon, bracket.weeklyLost)
                        :SetHighlight()
                else
                    Tooltip
                        :SetLine(bracket.name)
                        :SetGrayColor()
                        :SetLine(0)
                        :SetGrayColor()
                end
                Tooltip:ToLine()

                if bracket.tierName and IsShiftKeyDown() then
                    Tooltip
                        :SetFormattedLine(RATED_PVP_NEXT_RANK, bracket.tierName, bracket.nextTierName)
                        :ToLine()

                    Tooltip:AddIcon(bracket.tierIcon)
                end
            end

            PvP:TryLoadSeasonItemReward()
        elseif PvP:IsPreseason() then
            Tooltip:AddLine(L["Player vs. Player (Preseason)"])
        end
    end

    Tooltip:Show()
end)

PvP:RegisterEvent("WOWINFO_PVP_SEASON_REWARD", function(_, _, itemName, itemQuality, itemIcon, progress)
    local itemQualityColor = itemQuality and BAG_ITEM_QUALITY_COLORS[itemQuality] or HIGHLIGHT_FONT_COLOR
    local progressPct = FormatPercentage(progress)

    Tooltip
        :AddEmptyLine()
        :SetLine(itemName)
        :SetColor(itemQualityColor)
        :SetLine(progressPct)
        :SetHighlight()
        :ToLine()
        :AddIcon(itemIcon)
        :Show()
end)

Tooltip:RegisterHookScript(LFDMicroButton, "OnLeave", function(self)
    Tooltip:Hide()
	PvP:CancelSeasonItemReward()
end)

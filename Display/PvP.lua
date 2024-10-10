local _, addon = ...
local PvP = addon:GetObject("PvP")
local Display = addon:NewDisplay("PvP")

local L = addon.L

local STANDING_FORMAT = "%s / %s"
local RATED_PVP_LABEL_FORMAT = "%s: |cff00ff00%d|r"
local RATED_PVP_WEEKLY_STATUS_FORMAT = "%d (|cff00ff00%d|r + |cffff0000%d|r)"
local RATED_PVP_NEXT_RANK = "%s > %s"

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    Display:AddHeader(L["PvP Progress:"])

    local honorInfo = PvP:GetHonorProgressInfo()

    Display
        :SetFormattedLine(L["Honor Level X"], honorInfo.level)
        :SetFormattedLine(STANDING_FORMAT, honorInfo.currentValue, honorInfo.maxValue)
        :SetHighlight()
        :ToLine()

    if IsPlayerAtEffectiveMaxLevel() then
        local conquest = PvP:GetConquestProgressInfo()

        if conquest then
            Display:SetLine(L["Conquest"])
            if not conquest.isCapped then
                Display:SetFormattedLine(STANDING_FORMAT, conquest.currentValue, conquest.maxValue)
                if conquest.displayType == Enum.ConquestProgressBarDisplayType.Seasonal then
                    Display:SetYellowColor()
                else
                    Display:SetBlueColor()
                end
            else
                Display
                    :SetFormattedLine(conquest.currentValue)
                    :SetGrayColor()
            end
            Display:ToLine()

            Display
                :SetDoubleLine(L["Rated PvP"], L["Weekly Stats"])
                :ToHeader()

            for bracket in PvP:IterableBracketInfo() do
                if bracket.rating > 0 then
                    Display
                        :SetFormattedLine(RATED_PVP_LABEL_FORMAT, bracket.name, bracket.rating)
                        :SetFormattedLine(RATED_PVP_WEEKLY_STATUS_FORMAT, bracket.weeklyPlayed, bracket.weeklyWon, bracket.weeklyLost)
                        :SetHighlight()
                else
                    Display
                        :SetLine(bracket.name)
                        :SetGrayColor()
                        :SetLine(0)
                        :SetGrayColor()
                end
                Display:ToLine()

                if bracket.tierName and IsShiftKeyDown() then
                    Display
                        :SetFormattedLine(RATED_PVP_NEXT_RANK, bracket.tierName, bracket.nextTierName)
                        :ToLine()

                    Display:AddIcon(bracket.tierIcon)
                end
            end

            PvP:TryLoadSeasonItemReward()
        elseif PvP:IsPreseason() then
            Display:AddLine(L["Player vs. Player (Preseason)"])
        end
    end

    Display:Show()
end)

PvP:RegisterEvent("WOWINFO_PVP_SEASON_REWARD", function(_, _, itemName, itemQuality, itemIcon, progress)
    local itemQualityColor = itemQuality and BAG_ITEM_QUALITY_COLORS[itemQuality] or HIGHLIGHT_FONT_COLOR
    local progressPct = FormatPercentage(progress)

    Display
        :AddEmptyLine()
        :SetLine(itemName)
        :SetColor(itemQualityColor)
        :SetLine(progressPct)
        :SetHighlight()
        :ToLine()
        :AddIcon(itemIcon)
        :Show()
end)

Display:RegisterHookScript(LFDMicroButton, "OnLeave", function(self)
    Display:Hide()
	PvP:CancelSeasonItemReward()
end)

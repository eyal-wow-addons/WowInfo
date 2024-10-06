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
        local conquestInfo = PvP:GetConquestProgressInfo()

        if conquestInfo then
            Display:SetLine(L["Conquest"])
            if not conquestInfo.isCapped then
                Display:SetFormattedLine(STANDING_FORMAT, conquestInfo.currentValue, conquestInfo.maxValue)
                if conquestInfo.displayType == Enum.ConquestProgressBarDisplayType.Seasonal then
                    Display:SetYellowColor()
                else
                    Display:SetBlueColor()
                end
            else
                Display
                    :SetFormattedLine(conquestInfo.currentValue)
                    :SetGrayColor()
            end
            Display:ToLine()

            Display
                :SetDoubleLine(L["Rated PvP"], L["Weekly Stats"])
                :ToHeader()

            for info in PvP:IterableBracketInfo() do
                if info.rating > 0 then
                    Display
                        :SetFormattedLine(RATED_PVP_LABEL_FORMAT, info.name, info.rating)
                        :SetFormattedLine(RATED_PVP_WEEKLY_STATUS_FORMAT, info.weeklyPlayed, info.weeklyWon, info.weeklyLost)
                        :SetHighlight()
                else
                    Display
                        :SetLine(info.name)
                        :SetGrayColor()
                        :SetLine(0)
                        :SetGrayColor()
                end
                Display:ToLine()

                if info.tierName and IsShiftKeyDown() then
                    Display
                        :SetFormattedLine(RATED_PVP_NEXT_RANK, info.tierName, info.nextTierName)
                        :ToLine()

                    Display:AddIcon(info.tierIcon)
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

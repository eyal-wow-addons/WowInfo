local _, addon = ...
local Currency = addon:GetObject("Currency")
local Tooltip = addon:NewTooltip("Currency")

local L = addon.L

local ITEM_LINE_FORMAT = "|T%s:0|t %s"
local MAX_QUANTITY_LINE_FORMAT = "%s |cffffffff/ %s|r"

local function AddCurrencyInfo(iterator)
    local refreshTooltip
    for currency in iterator() do
        refreshTooltip = true
        if currency.isHeader then
            Tooltip:AddFormattedHeader(L["S Currency:"], currency.name)
        else
            local currentQuantity = BreakUpLargeNumbers(currency.quantity)

            Tooltip
                :SetFormattedLine(ITEM_LINE_FORMAT, currency.iconFileID, currency.name)
                :SetLine(currentQuantity)
                :SetHighlight()

            if currency.quantity > 0 then
                local percent

                if currency.maxQuantity > 0 then
                    percent = Round(currency.quantity / currency.maxQuantity * 100)

                    if IsShiftKeyDown() then
                        Tooltip:SetFormattedLine(MAX_QUANTITY_LINE_FORMAT, currentQuantity, BreakUpLargeNumbers(currency.maxQuantity))
                    end

                    if percent == 100 then
                        Tooltip:SetRedColor()
                    elseif percent > 90 then
                        Tooltip:SetOrangeColor()
                    elseif percent >= 80 then
                        Tooltip:SetYellowColor()
                    end
                end
            else
                Tooltip:SetGrayColor()
            end

            Tooltip:ToLine()
        end
    end
    return refreshTooltip
end

Tooltip.target = {
    button = CharacterMicroButton,
    onEnter = function()
        local refreshTooltip1 = AddCurrencyInfo(Currency.IterableLatestExpansionInfo)
        local refreshTooltip2 = AddCurrencyInfo(Currency.IterablePvPInfo)
        if refreshTooltip1 or refreshTooltip2 then
            Tooltip:Show()
        end
    end
}
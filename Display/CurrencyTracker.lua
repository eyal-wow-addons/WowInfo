local _, addon = ...
local Currency = addon:GetObject("Currency")
local Display = addon:NewDisplay("CurrencyTracker")

local L = addon.L

local QUANTITY_LINE_FORMAT = "%s: %s"

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(_, index)
    local currencyID = Currency:GetIDByIndex(index)
    local totalQuantity = Currency:GetTotalQuantity(currencyID)
    if totalQuantity > 0 then
        Display:AddFormattedHeader(L["All Characters (X):"], totalQuantity)

        do
            local charName, quantity = Currency:GetPlayerCurrencyInfo(currencyID)

            charName = Display:ToPlayerClassColor(charName)

            if quantity > 0 then
                quantity = Display:ToWhite(quantity)
            else
                quantity = Display:ToGray(quantity)
            end

            Display:AddFormattedLine(QUANTITY_LINE_FORMAT, charName, quantity)
        end

        for charName, quantity in Currency:IterableCharactersCurrencyInfo(currencyID) do
            Display:AddFormattedLine(QUANTITY_LINE_FORMAT, charName, Display:ToWhite(quantity))
        end

        Display:Show()
    end
end)
local _, addon = ...
local Currency = addon:GetObject("Currency")
local Display = addon:NewDisplay("CurrencyTracker")

local L = addon.L

local CURRENCY_QUANTITY_PER_CHARACTER_FORMAT = "%s: %s"

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(_, index)
    local link = C_CurrencyInfo.GetCurrencyListLink(index)
    local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    local totalQuantity = Currency:GetTotalQuantity(currencyID)
    if totalQuantity > 0 then
        Display:AddFormattedHeader(L["All Characters (X):"], totalQuantity)

        do
            local charName, quantity = Currency:GetPlayerCurrencyInfo(currencyID)

            charName = Display:ToClassColor(charName)

            if quantity > 0 then
                quantity = Display:ToWhite(quantity)
            else
                quantity = Display:ToGray(quantity)
            end

            Display:AddFormattedLine(CURRENCY_QUANTITY_PER_CHARACTER_FORMAT, charName, quantity)
        end

        if currencyID then
            for charName, quantity in Currency:IterableCharactersCurrencyInfo(currencyID) do
                Display:AddFormattedLine(CURRENCY_QUANTITY_PER_CHARACTER_FORMAT, charName, Display:ToWhite(quantity))
            end
        end

        Display:Show()
    end
end)
local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("CurrencyTracker")
local Currency = addon.Currency

local CURRENCY_QUANTITY_PER_CHARACTER_FORMAT = "%s: %s"

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(_, index)
    local link = C_CurrencyInfo.GetCurrencyListLink(index)
    local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    local totalQuantity = Currency:GetTotalQuantity(currencyID)
    if totalQuantity > 0 then
        Display:AddTitleLine(L["All Characters (X):"]:format(totalQuantity))

        do
            local charName, quantity = Currency:GetPlayerCurrencyInfo(currencyID)
            if quantity > 0 then
                quantity = WHITE_FONT_COLOR:WrapTextInColorCode(quantity)
            else
                quantity = GRAY_FONT_COLOR:WrapTextInColorCode(quantity)
            end
            Display:AddLine(CURRENCY_QUANTITY_PER_CHARACTER_FORMAT:format(charName, quantity))
        end

        if currencyID then
            for charName, quantity in Currency:IterableCharactersCurrencyInfo(currencyID) do
                Display:AddLine(CURRENCY_QUANTITY_PER_CHARACTER_FORMAT:format(charName, WHITE_FONT_COLOR:WrapTextInColorCode(quantity)))
            end
        end

        Display:Show()
    end
end)
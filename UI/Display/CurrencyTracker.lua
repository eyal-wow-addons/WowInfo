local _, addon = ...
local Currency = addon:GetObject("Currency")
local Display = addon:NewDisplay("CurrencyTracker")

local L = addon.L

local QUANTITY_LINE_FORMAT = "%s: %s"

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(_, index)
    local totalQuantity = Currency:GetTotalQuantity(index)
    if totalQuantity > 0 then
        Display:AddFormattedHeader(L["All Characters (X):"], totalQuantity)

        for charName, quantity, isCurrentChar in Currency:IterableCharactersCurrencyInfo(index) do
            if isCurrentChar then
                charName = Display:ToPlayerClassColor(charName)
            end
            if quantity > 0 then
                quantity = Display:ToWhite(quantity)
            else
                quantity = Display:ToGray(quantity)
            end
            Display:AddFormattedLine(QUANTITY_LINE_FORMAT, charName, Display:ToWhite(quantity))
        end

        Display
            :AddEmptyLine()
            :Show()
    end
end)
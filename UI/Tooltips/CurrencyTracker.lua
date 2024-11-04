local _, addon = ...
local Currency = addon:GetObject("Currency")
local Tooltip = addon:NewTooltip("CurrencyTracker")

local L = addon.L

local QUANTITY_LINE_FORMAT = "%s: %s"

Tooltip.target = {
    table = GameTooltip,
    funcName = "SetCurrencyToken",
    func = function(_, index)
        local totalQuantity = Currency:GetTotalQuantity(index)
        if totalQuantity > 0 then
            Tooltip:AddFormattedHeader(L["All Characters (X):"], totalQuantity)
    
            for charName, quantity, isCurrentChar in Currency:IterableCharactersCurrencyInfo(index) do
                if isCurrentChar then
                    charName = Tooltip:ToPlayerClassColor(charName)
                end
                if quantity > 0 then
                    quantity = Tooltip:ToWhite(quantity)
                else
                    quantity = Tooltip:ToGray(quantity)
                end
                Tooltip:AddFormattedLine(QUANTITY_LINE_FORMAT, charName, Tooltip:ToWhite(quantity))
            end
    
            Tooltip:AddEmptyLine()
        end
    end
}
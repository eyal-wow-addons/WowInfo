local _, addon = ...
local Currency = addon:GetObject("Currency")
local Display = addon:NewDisplay("Currency")

local L = addon.L

local ITEM_LINE_FORMAT = "|T%s:0|t %s"
local MAX_QUANTITY_LINE_FORMAT = "%s |cffffffff/ %s|r"

local function AddCurrencyInfo(iterator)
    local refreshTooltip
    for name, isHeader, icon, quantity, maxQuantity in iterator() do
        refreshTooltip = true
        if isHeader then
            Display:AddFormattedHeader(L["S Currency:"], name)
        else
            local currentQuantity = BreakUpLargeNumbers(quantity)

            Display
                :SetFormattedLine(ITEM_LINE_FORMAT, icon, name)
                :SetLine(currentQuantity)

            if quantity > 0 then
                local percent

                if maxQuantity > 0 then
                    percent = Round(quantity / maxQuantity * 100)

                    if IsShiftKeyDown() then
                        Display:SetFormattedLine(MAX_QUANTITY_LINE_FORMAT, currentQuantity, BreakUpLargeNumbers(maxQuantity))
                    end

                    if percent == 100 then
                        Display:SetRedColor()
                    elseif percent > 90 then
                        Display:SetOrangeColor()
                    elseif percent >= 80 then
                        Display:SetYellowColor()
                    else
                        Display:SetHighlight()
                    end
                end
            else
                Display:SetGrayColor()
            end

            Display:ToLine()
        end
    end
    return refreshTooltip
end

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    local refreshTooltip1 = AddCurrencyInfo(Currency.IterableLatestExpansionInfo)
    local refreshTooltip2 = AddCurrencyInfo(Currency.IterablePvPInfo)
    if refreshTooltip1 or refreshTooltip2 then
        Display:Show()
    end
end)
local _, addon = ...
local Currency = addon:GetObject("Currency")
local Display = addon:NewDisplay("Currency")

local L = addon.L

local CURRENCY_ITEM_FORMAT = "|T%s:0|t %s"
local CURRENCY_MAX_FORMAT = "%s |cffffffff/ %s|r"

local function AddCurrencyInfo(iterator)
    local refreshTooltip
    for name, isHeader, icon, quantity, maxQuantity in iterator() do
        refreshTooltip = true
        if isHeader then
            Display:SetFormat(L["S Currency:"], name):ToHeader()
        else
            local leftText = CURRENCY_ITEM_FORMAT:format(icon, name)
            local rightText = BreakUpLargeNumbers(quantity)

            Display:SetText(leftText):SetText(rightText)

            if quantity > 0 then
                local percent

                if maxQuantity > 0 then
                    percent = Round(quantity / maxQuantity * 100)

                    if IsShiftKeyDown() then
                        rightText = CURRENCY_MAX_FORMAT:format(rightText, BreakUpLargeNumbers(maxQuantity))
                    end

                    if percent == 100 then
                        Display:SetRedColor()
                    elseif percent > 90 then
                        Display:SetOrangeColor()
                    elseif percent >= 80 then
                        Display:SetYellowColor()
                    else
                        percent = nil
                    end
                end

                if not percent then
                    Display:SetHighlight()
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
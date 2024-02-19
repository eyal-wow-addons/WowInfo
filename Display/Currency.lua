local _, addon = ...
local Display = addon:NewDisplay("Currency")
local Currency = addon.Currency

local CURRENCY_ITEM_FORMAT = "|T%s:0|t %s"
local CURRENCY_SEASON_FORMAT = "%s |cffffffff(%s)"
local CURRENCY_MAX_FORMAT = "%s |cffffffff/ %s|r"

local CHARACTERS_CURRENCY_LABEL = "Additional Characters:"
local CHARACTERS_CURRENCY_FORMAT = "%s: |cffffffff%d|r"

local function AddCurrencyInfo(iterator)
    local refreshTooltip
    for name, isHeader, icon, quantity, maxQuantity in iterator() do
        refreshTooltip = true
        if isHeader then
            Display:AddEmptyLine()
            Display:AddHighlightLine(("%s Currency:"):format(name))
        else
            local leftText = CURRENCY_ITEM_FORMAT:format(icon, name)
            local rightText = BreakUpLargeNumbers(quantity)
            if quantity > 0 then
                local percent

                if maxQuantity > 0 then
                    percent = Round(quantity / maxQuantity * 100)

                    if IsShiftKeyDown() then
                        rightText = CURRENCY_MAX_FORMAT:format(rightText, BreakUpLargeNumbers(maxQuantity))
                    end

                    if percent == 100 then
                        Display:AddRightRedDoubleLine(leftText, rightText)
                    elseif percent > 90 then
                        Display:AddRightOrangeDoubleLine(leftText, rightText)
                    elseif percent >= 80 then
                        Display:AddRightYellowDoubleLine(leftText, rightText)
                    else
                        percent = nil
                    end
                end

                if not percent then
                    Display:AddRightHighlightDoubleLine(leftText, rightText)
                end
            else
                Display:AddGrayDoubleLine(leftText, rightText)
            end
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

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(_, index)
    local link = C_CurrencyInfo.GetCurrencyListLink(index)
    local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    if currencyID then
        local isLabelAdded
        for charDisplayName, quantity in Currency:IterableCharactersCurrencyInfoByCurrencyID(currencyID) do
            if not isLabelAdded then
                Display:AddEmptyLine()
                Display:AddHighlightLine(CHARACTERS_CURRENCY_LABEL)
                isLabelAdded = true
            end
            Display:AddLine(CHARACTERS_CURRENCY_FORMAT:format(charDisplayName, quantity))
        end
        Display:Show()
    end
end)
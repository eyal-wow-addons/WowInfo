local _, addon = ...
local Display = addon:NewDisplay("Currency")
local Currency = addon.Currency

local CURRENCY_ITEM_FORMAT = "|T%s:0|t %s"
local CHARACTERS_CURRENCY_LABEL = "Additional Characters:"
local CHARACTERS_CURRENCY_FORMAT = "%s: |cffffffff%d|r"

local function AddHeader(name)
    Display:AddEmptyLine()
    Display:AddHighlightLine(("%s Currency:"):format(name))
end

local function AddItem(name, icon, quantity)
    local leftText = CURRENCY_ITEM_FORMAT:format(icon, name)
    local rightText = BreakUpLargeNumbers(quantity)
    if quantity > 0 then
        Display:AddRightHighlightDoubleLine(leftText, rightText)
    else
        Display:AddGrayDoubleLine(leftText, rightText)
    end
end

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    local refreshTooltip = false

    for name, isHeader, icon, quantity in Currency:IterableLatestExpansionInfo() do
        refreshTooltip = true
        if isHeader then
            AddHeader(name)
        else
            AddItem(name, icon, quantity)
        end
    end

    for name, isHeader, icon, quantity in Currency:IterablePvPInfo() do
        refreshTooltip = true
        if isHeader then
            AddHeader(name)
        else
            AddItem(name, icon, quantity)
        end
    end

    if refreshTooltip then
        Display:Show()
    end
end)

hooksecurefunc(GameTooltip, "SetCurrencyToken", function(_, index)
    local link = C_CurrencyInfo.GetCurrencyListLink(index)
    local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    if currencyID then
        local counter = 1
        for charDisplayName, quantity in Currency:IterableCharactersCurrencyInfoByCurrencyID(currencyID) do
            if counter == 1 then
                Display:AddEmptyLine()
                Display:AddHighlightLine(CHARACTERS_CURRENCY_LABEL)
            end
            Display:AddLine(CHARACTERS_CURRENCY_FORMAT:format(charDisplayName, quantity))
            counter = counter + 1
        end
        Display:Show()
    end
end)
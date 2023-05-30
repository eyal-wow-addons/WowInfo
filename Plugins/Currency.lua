local _, addon = ...
local plugin = addon:NewPlugin("Currency")

local Currency = addon.Currency
local Tooltip = addon.Tooltip

local CURRENCY_ITEM_FORMAT = "|T%s:0|t %s"

local function AddHeader(name)
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(("%s Currency:"):format(name))
end

local function AddItem(name, icon, quantity)
    local leftText = CURRENCY_ITEM_FORMAT:format(icon, name)
    local rightText = BreakUpLargeNumbers(quantity)
    if quantity > 0 then
        Tooltip:AddRightHighlightDoubleLine(leftText, rightText)
    else
        Tooltip:AddGrayDoubleLine(leftText, rightText)
    end
end

plugin:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    local refreshTooltip = false

    for name, isHeader, icon, quantity in Currency:IterableLatestExpansionCurrencyInfo() do
        refreshTooltip = true
        if isHeader then
            AddHeader(name)
        else
            AddItem(name, icon, quantity)
        end
    end

    for name, isHeader, icon, quantity in Currency:IterablePvPCurrencyInfo() do
        refreshTooltip = true
        if isHeader then
            AddHeader(name)
        else
            AddItem(name, icon, quantity)
        end
    end

    if refreshTooltip then
        Tooltip:Show()
    end
end)

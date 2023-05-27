local _, addon = ...
local module = addon:NewModule("Scripts:Currency")
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip

local CURRENCY_ITEM_FORMAT = "|T%s:0|t %s"

local expansions = {}
local currentExpansionLevel = GetClampedCurrentExpansionLevel()

for i = 0, currentExpansionLevel do
    table.insert(expansions, _G["EXPANSION_NAME" .. i])
end

local function addHeader(name)
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(("%s Currency:"):format(name))
end

local function addItem(name, icon, count)
    local leftText = CURRENCY_ITEM_FORMAT:format(icon, name)
    local rightText = BreakUpLargeNumbers(count)
    if count > 0 then
        Tooltip:AddRightHighlightDoubleLine(leftText, rightText)
    else
        Tooltip:AddGrayDoubleLine(leftText, rightText)
    end
end

ScriptLoader:AddHookScript(CharacterMicroButton, "OnEnter", function()
    local pvpFound = false
    local latestExpansionLevelAvailableForCurrencyFound = false
    local expansionLevel = currentExpansionLevel + 1

    for i = 1, #expansions do
        for j = 1, C_CurrencyInfo.GetCurrencyListSize() do
            local info = C_CurrencyInfo.GetCurrencyListInfo(j)
            local name, isHeader, count, icon = info.name, info.isHeader, info.quantity, info.iconFileID
            if not isHeader and latestExpansionLevelAvailableForCurrencyFound then
                addItem(name, icon, count)
            elseif name == expansions[expansionLevel] then
                local nextName, nextIsHeader = C_CurrencyInfo.GetCurrencyListInfo(j + 1)
                if nextName and not nextIsHeader then
                    latestExpansionLevelAvailableForCurrencyFound = true
                    addHeader(name)
                end
            else
                -- If we didn't find a header for the latest expansion available
                -- then break and try to get one for the expansion before that
                break
            end
        end
        if not latestExpansionLevelAvailableForCurrencyFound then
            expansionLevel = expansionLevel - 1
        else
            -- If we got this far it means currency was found and we can bail out
            break
        end
    end

    for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        local name, isHeader, count, icon = info.name, info.isHeader, info.quantity, info.iconFileID
        if not isHeader and pvpFound then
            addItem(name, icon, count)
        elseif name == PLAYER_V_PLAYER then
            local nextName, nextIsHeader = C_CurrencyInfo.GetCurrencyListInfo(i + 1)
            if nextName and not nextIsHeader then
                pvpFound = true
                addHeader(name)
            end
        elseif pvpFound then
            break
        end
    end

    if latestExpansionLevelAvailableForCurrencyFound or pvpFound then
        Tooltip:Show()
    end
end)

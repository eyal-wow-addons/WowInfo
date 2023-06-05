local _, addon = ...
local Currency = addon:NewObject("Currency")

local expansions = {}
local currentExpansionLevel = GetClampedCurrentExpansionLevel()

for i = 0, currentExpansionLevel do
    table.insert(expansions, _G["EXPANSION_NAME" .. i])
end

function Currency:IterableLatestExpansionCurrencyInfo()
    local latestExpansionLevelAvailableForCurrencyFound = false
    local expansionLevel = currentExpansionLevel + 1
    local i = 0
    local n = C_CurrencyInfo.GetCurrencyListSize()
    return function()
        i = i + 1
        if i <= n then
            while true do
                local info = C_CurrencyInfo.GetCurrencyListInfo(i)
                if not info.isHeader and latestExpansionLevelAvailableForCurrencyFound then
                    return info.name, info.isHeader, info.iconFileID, info.quantity
                elseif info.name == expansions[expansionLevel] then
                    local nextInfo = C_CurrencyInfo.GetCurrencyListInfo(i + 1)
                    if nextInfo and nextInfo.name and not nextInfo.isHeader then
                        latestExpansionLevelAvailableForCurrencyFound = true
                        return info.name, info.isHeader
                    end
                -- If we didn't find a header for the latest expansion available
                -- then try the expansion before that
                elseif not latestExpansionLevelAvailableForCurrencyFound then
                    expansionLevel = expansionLevel - 1
                else
                    -- If we got this far it means currency was found and we can bail out
                    return
                end
            end
        end
    end
end

function Currency:IterablePvPCurrencyInfo()
    local pvpFound = false
    local i = 0
    local n = C_CurrencyInfo.GetCurrencyListSize()
    return function()
        i = i + 1
        if i <= n then
            while true do
                local info = C_CurrencyInfo.GetCurrencyListInfo(i)
                if not info.isHeader and pvpFound then
                    return info.name, info.isHeader, info.iconFileID, info.quantity
                elseif info.name == PLAYER_V_PLAYER then
                    local nextInfo = C_CurrencyInfo.GetCurrencyListInfo(i + 1)
                    if nextInfo and nextInfo.name and not nextInfo.isHeader then
                        pvpFound = true
                        return info.name, info.isHeader
                    end
                elseif pvpFound then
                    return
                end
            end
        end
    end
end
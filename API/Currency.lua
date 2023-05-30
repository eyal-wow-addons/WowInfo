local _, addon = ...
local Currency = {}
addon.Currency = Currency

local expansions = {}
local currentExpansionLevel = GetClampedCurrentExpansionLevel()

for i = 0, currentExpansionLevel do
    table.insert(expansions, _G["EXPANSION_NAME" .. i])
end

function Currency:IterableLatestExpansionCurrencyInfo()
    local latestExpansionLevelAvailableForCurrencyFound = false
    local expansionLevel = currentExpansionLevel + 1
    return function()
        for i = 1, #expansions do
            for j = 1, C_CurrencyInfo.GetCurrencyListSize() do
                local info = C_CurrencyInfo.GetCurrencyListInfo(j)
                if not info.isHeader and latestExpansionLevelAvailableForCurrencyFound then
                    return info.name, info.isHeader, info.iconFileID, info.quantity
                elseif info.name == expansions[expansionLevel] then
                    local nextInfo = C_CurrencyInfo.GetCurrencyListInfo(j + 1)
                    if nextInfo and nextInfo.name and not nextInfo.isHeader then
                        latestExpansionLevelAvailableForCurrencyFound = true
                        return info.name, info.isHeader
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
    end
end

function Currency:IterablePvPCurrencyInfo()
    local pvpFound = false
    return function()
        for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
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
                break
            end
        end
    end
end
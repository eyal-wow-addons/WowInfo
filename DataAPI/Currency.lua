local _, addon = ...
local Currency = addon:NewObject("Currency")
local Character = addon.Character

Currency.GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
Currency.GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
Currency.GetClampedCurrentExpansionLevel = GetClampedCurrentExpansionLevel

local expansions, currentExpansionLevel

function Currency:OnInitialize()
    expansions = {}
    currentExpansionLevel = Currency.GetClampedCurrentExpansionLevel()
    for i = 0, currentExpansionLevel do
        table.insert(expansions, _G["EXPANSION_NAME" .. i])
    end
end

local function IterableCurrencyByCategory(categoryName)
    local isHeaderCategoryFound = false
    local i = 0
    local n = Currency.GetCurrencyListSize()
    return function()
        i = i + 1
        while i <= n do
            local info = Currency.GetCurrencyListInfo(i)
            if not info.isHeader and isHeaderCategoryFound then
                return info.name, info.isHeader, info.iconFileID, info.quantity
            elseif info.name == categoryName then
                local nextInfo = Currency.GetCurrencyListInfo(i + 1)
                -- Check whether the header has children
                if nextInfo and nextInfo.name and not nextInfo.isHeader then
                    isHeaderCategoryFound = true
                    return info.name, info.isHeader
                end
            elseif not isHeaderCategoryFound then
                -- We didn't find a matching header for the category so try the next index
            else
                -- If we got this far it means currency was found and we can bail out
                return
            end
            i = i + 1
        end
    end
end

function Currency:IterableLatestExpansionInfo()
    local expansionLevel = currentExpansionLevel + 1
    local categoryName
    while expansionLevel > 0 do
        categoryName = IterableCurrencyByCategory(expansions[expansionLevel])()
        if not categoryName then
            -- If we didn't find a header for the latest expansion available
            -- then try the expansion before that
            expansionLevel = expansionLevel - 1
        else
            break
        end
    end
    return IterableCurrencyByCategory(expansions[expansionLevel])
end

function Currency:IterablePvPInfo()
    return IterableCurrencyByCategory(PLAYER_V_PLAYER)
end

function Currency:IterableCharactersCurrencyInfoByCurrencyID(currencyID)
    local charName, data
    return function()
        charName, data = Currency.storage:GetCurrencyInfoByCharacter(charName)
        while charName do
            for id, quantity in pairs(data) do
                if id == currencyID then
                    local charDisplayName = charName
                    if Character:IsOnConnectedRealm(charName, false) then
                        charDisplayName = Character:ShortConnectedRealm(charDisplayName)
                    else
                        charDisplayName = Character:RemoveRealm(charDisplayName)
                    end
                    return charDisplayName, quantity
                end
            end
            charName, data = Currency.storage:GetCurrencyInfoByCharacter(charName)
        end
    end
end
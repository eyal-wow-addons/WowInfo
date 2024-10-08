local _, addon = ...
local Currency = addon:NewObject("Currency")

local CharacterInfo = LibStub("CharacterInfo-1.0")

local DATA = {
    expansions = {},
    expansionCategory = "",
    currentExpansionLevel = 0
}

local CACHE = {
    CurrencyList = {}
}

local ACCOUNT_WIDE_CURRENCY = {
    [2032] = true -- Trader's Tender
}

local _G = _G
local PLAYER_V_PLAYER = PLAYER_V_PLAYER

local function IterableCurrencyInfo()
    local i = 0
    local n = C_CurrencyInfo.GetCurrencyListSize()
    return function()
        i = i + 1
        while i <= n do
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if not info.isHeader and not info.isTradeable then
                local link = C_CurrencyInfo.GetCurrencyListLink(i)
                local currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(link)
                local quantity = info.quantity
                if not ACCOUNT_WIDE_CURRENCY[currencyID] and quantity > 0 then
                    return currencyID, quantity
                end
            end
            i = i + 1
        end
    end
end

local function GetPlayerCurrencyQuantity(currencyID)
    if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
        return 0
    end
    for id, quantity in IterableCurrencyInfo() do
        if id == currencyID then
            return quantity
        end
    end
    return 0
end

local function IterableCurrencyInfoByCategory(categoryName)
    local isHeaderCategoryFound = false
    local i = 0
    local n = C_CurrencyInfo.GetCurrencyListSize()
    return function()
        i = i + 1
        while i <= n do
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if not info.isHeader and isHeaderCategoryFound then
                return info.name, info.isHeader, info.iconFileID, info.quantity, info.maxQuantity
            elseif info.name == categoryName then
                local nextInfo = C_CurrencyInfo.GetCurrencyListInfo(i + 1)
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

local function GetExpansionCategory()
    local expansionLevel = DATA.currentExpansionLevel + 1
    local categoryName
    while expansionLevel > 0 do
        categoryName = IterableCurrencyInfoByCategory(DATA.expansions[expansionLevel])()
        if not categoryName then
            -- If we didn't find a header for the latest expansion available
            -- then try the expansion before that
            expansionLevel = expansionLevel - 1
        else
            break
        end
    end
    return categoryName
end

local function CacheCurrencyInfoByCategory(categoryName)
    local index = 1
    CACHE[categoryName] = CACHE[categoryName] or {}
    for name, isHeader, icon, quantity, maxQuantity in IterableCurrencyInfoByCategory(categoryName) do
        local category = CACHE[categoryName]
        if not category[name] then
            category[name] = {index, isHeader, icon, quantity, maxQuantity}
        else
            category[name][1] = index
            category[name][4] = quantity
            category[name][5] = maxQuantity
        end
        index = index + 1
    end
end

local function CacheCategoriesCurrencyInfo()
    local expansionCategory = GetExpansionCategory()
    if not expansionCategory then
        return
    end
    CacheCurrencyInfoByCategory(expansionCategory)
    CacheCurrencyInfoByCategory(PLAYER_V_PLAYER)
    DATA.expansionCategory = expansionCategory
end

local function CacheCharactersCurrencyInfo()
    local charName, data
    local charDisplayName
    for currencyID in IterableCurrencyInfo() do
        charName, data = Currency.storage:GetCharacterCurrencyInfo(charName)
        while charName do
            local onCurrentRealm = CharacterInfo:IsCharacterOnCurrentRealm(charName)
            local onConnectedRealm = CharacterInfo:IsCharacterOnConnectedRealm(charName)
            if onCurrentRealm or onConnectedRealm then
                for id, quantity in pairs(data) do
                    if id == currencyID then
                        charDisplayName = charName
                        if onConnectedRealm then
                            charDisplayName = CharacterInfo:ShortConnectedRealm(charDisplayName)
                        else
                            charDisplayName = CharacterInfo:RemoveRealm(charDisplayName)
                        end
                        if not CACHE.CurrencyList[currencyID] then
                            CACHE.CurrencyList[currencyID] = {}
                        end
                        CACHE.CurrencyList[currencyID][charDisplayName] = quantity
                    end
                end
            end
            charName, data = Currency.storage:GetCharacterCurrencyInfo(charName)
        end
    end
end

function Currency:OnInitializing()
    DATA.currentExpansionLevel = GetClampedCurrentExpansionLevel()
    for i = 0, DATA.currentExpansionLevel do
        table.insert(DATA.expansions, _G["EXPANSION_NAME" .. i])
    end
end

Currency:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_LOGOUT",
    "CURRENCY_DISPLAY_UPDATE", 
    function(_, eventName)
        if eventName == "PLAYER_LOGIN" then
            Currency.storage:ClearCurrencyData()
            CacheCategoriesCurrencyInfo()
            CacheCharactersCurrencyInfo()
        elseif eventName == "PLAYER_LOGOUT" then
            Currency.storage:StoreCurrencyData(IterableCurrencyInfo)
        elseif eventName == "CURRENCY_DISPLAY_UPDATE" then
            CacheCategoriesCurrencyInfo()
            CacheCharactersCurrencyInfo()
        end
    end)

do
    local function IterableCurrencyInfoByCategory(categoryName)
        local category = CACHE[categoryName]
        local index = 1
        return function()
            for name, currencyData in next, category do
                if currencyData[1] == index then
                    index = index + 1
                    return name, currencyData[2], currencyData[3], currencyData[4], currencyData[5]
                end
            end
        end
    end

    function Currency:IterableLatestExpansionInfo()
        return IterableCurrencyInfoByCategory(DATA.expansionCategory)
    end
    
    function Currency:IterablePvPInfo()
        return IterableCurrencyInfoByCategory(PLAYER_V_PLAYER)
    end
end

function Currency:GetPlayerCurrencyInfo(currencyID)
    return CharacterInfo:GetName(), GetPlayerCurrencyQuantity(currencyID)
end

function Currency:IterableCharactersCurrencyInfo(currencyID)
    local data = CACHE.CurrencyList[currencyID]
    local key, value
    return function()
        if data then
            key, value = next(data, key)
            if key then
                return key, value
            end
        end
        return nil, 0
    end
end

function Currency:GetIDByIndex(index)
    local link = C_CurrencyInfo.GetCurrencyListLink(index)
    return link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
end

function Currency:GetTotalQuantity(currencyID)
    local totalQuantity = GetPlayerCurrencyQuantity(currencyID)
    for _, quantity in self:IterableCharactersCurrencyInfo(currencyID) do
        totalQuantity = totalQuantity + quantity
    end
    return totalQuantity
end

function Currency:Reset()
    self.storage:Reset()
    for currencyID in IterableCurrencyInfo() do
        CACHE.CurrencyList[currencyID] = nil
    end
end
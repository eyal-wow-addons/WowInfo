local _, addon = ...
local PlayerInfo = LibStub("PlayerInfo-1.0")
local Currency = addon:NewObject("Currency")

local DATA = {
    expansions = {},
    expansionCategory = "",
    currentExpansionLevel = 0,
    currency = {}
}

local ACCOUNT_WIDE_CURRENCY = {
    [2032] = true -- Trader's Tender
}

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

local function GetCurrencyQuantity(currencyID)
    if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
        return -1
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

local function CacheCurrency(categoryName)
    local index = 1
    DATA.currency[categoryName] = DATA.currency[categoryName] or {}
    for name, isHeader, icon, quantity, maxQuantity in IterableCurrencyInfoByCategory(categoryName) do
        local category = DATA.currency[categoryName]
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

local function CacheCategories()
    local expansionCategory = GetExpansionCategory()
    if not expansionCategory then
        return
    end
    CacheCurrency(expansionCategory)
    CacheCurrency(PLAYER_V_PLAYER)
    DATA.expansionCategory = expansionCategory
end

local function CachedIterableCurrencyInfoByCategory(categoryName)
    local category = DATA.currency[categoryName]
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

function Currency:OnInitializing()
    DATA.currentExpansionLevel = GetClampedCurrentExpansionLevel()
    for i = 0, DATA.currentExpansionLevel do
        table.insert(DATA.expansions, _G["EXPANSION_NAME" .. i])
    end
end

Currency:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_LOGOUT",
    "CURRENCY_DISPLAY_UPDATE", function(_, eventName)
        if eventName == "PLAYER_LOGIN" then
            Currency.storage:ClearCurrencyData()
            CacheCategories()
        elseif eventName == "PLAYER_LOGOUT" then
            Currency.storage:StoreCurrencyData(IterableCurrencyInfo)
        elseif eventName == "CURRENCY_DISPLAY_UPDATE" then
            CacheCategories()
        end
    end)

function Currency:IterableLatestExpansionInfo()
    return CachedIterableCurrencyInfoByCategory(DATA.expansionCategory)
end

function Currency:IterablePvPInfo()
    return CachedIterableCurrencyInfoByCategory(PLAYER_V_PLAYER)
end

function Currency:GetPlayerCurrencyInfo(currencyID)
    if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
        return
    end
    return PlayerInfo:GetCharacterName(), GetCurrencyQuantity(currencyID)
end

function Currency:IterableCharactersCurrencyInfo(currencyID)
    local charDisplayName
    local charName, data
    return function()
        if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
            return
        end
        charName, data = self.storage:GetCharacterCurrencyInfo(charName)
        while charName do
            local onCurrentRealm = PlayerInfo:IsCharacterOnCurrentRealm(charName)
            local onConnectedRealm = PlayerInfo:IsCharacterOnConnectedRealm(charName)
            if onCurrentRealm or onConnectedRealm then
                for id, quantity in pairs(data) do
                    if id == currencyID then
                        charDisplayName = charName
                        if onConnectedRealm then
                            charDisplayName = PlayerInfo:ShortConnectedRealm(charDisplayName)
                        else
                            charDisplayName = PlayerInfo:RemoveRealm(charDisplayName)
                        end
                        return charDisplayName, quantity
                    end
                end
            end
            charName, data = self.storage:GetCharacterCurrencyInfo(charName)
        end
    end
end

function Currency:GetTotalQuantity(currencyID)
    if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
        return -1
    end
    local totalQuantity = GetCurrencyQuantity(currencyID)
    for _, quantity in self:IterableCharactersCurrencyInfo(currencyID) do
        totalQuantity = totalQuantity + quantity
    end
    return totalQuantity
end
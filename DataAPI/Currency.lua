local _, addon = ...
local Currency = addon:NewObject("Currency")
local Character = addon.Character

Currency.GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
Currency.GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
Currency.GetClampedCurrentExpansionLevel = GetClampedCurrentExpansionLevel

local ACCOUNT_WIDE_CURRENCY = {
    [2032] = true -- Trader's Tender
}

local expansions, currentExpansionLevel

function Currency:OnInitialize()
    expansions = {}
    currentExpansionLevel = Currency.GetClampedCurrentExpansionLevel()
    for i = 0, currentExpansionLevel do
        table.insert(expansions, _G["EXPANSION_NAME" .. i])
    end
end

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

Currency:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_LOGOUT", function(_, eventName)
        if eventName == "PLAYER_LOGIN" then
            Currency.storage:ClearCurrencyData()
        elseif eventName == "PLAYER_LOGOUT" then
            Currency.storage:StoreCurrencyData(IterableCurrencyInfo)
        end
    end)

local function IterableCurrencyInfoByCategory(categoryName)
    local isHeaderCategoryFound = false
    local i = 0
    local n = Currency.GetCurrencyListSize()
    return function()
        i = i + 1
        while i <= n do
            local info = Currency.GetCurrencyListInfo(i)
            if not info.isHeader and isHeaderCategoryFound then
                return info.name, info.isHeader, info.iconFileID, info.quantity, info.maxQuantity
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
        categoryName = IterableCurrencyInfoByCategory(expansions[expansionLevel])()
        if not categoryName then
            -- If we didn't find a header for the latest expansion available
            -- then try the expansion before that
            expansionLevel = expansionLevel - 1
        else
            break
        end
    end
    return IterableCurrencyInfoByCategory(expansions[expansionLevel])
end

function Currency:IterablePvPInfo()
    return IterableCurrencyInfoByCategory(PLAYER_V_PLAYER)
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

function Currency:GetPlayerCurrencyInfo(currencyID)
    if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
        return
    end
    local quantity = GetCurrencyQuantity(currencyID)
    local charName = Character:GetFullName()
    return GetClassColoredTextForUnit("player", Character:RemoveRealm(charName)), quantity
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
            if Character:IsOnCurrentRealm(charName) or Character:IsOnConnectedRealm(charName) then
                for id, quantity in pairs(data) do
                    if id == currencyID then
                        charDisplayName = charName
                        if Character:IsOnConnectedRealm(charName) then
                            charDisplayName = Character:ShortConnectedRealm(charDisplayName)
                        else
                            charDisplayName = Character:RemoveRealm(charDisplayName)
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
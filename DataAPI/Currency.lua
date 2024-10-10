local _, addon = ...
local Currency = addon:NewObject("Currency")

local CharacterInfo = LibStub("CharacterInfo-1.0")

local INFO = {}

local DATA = {
    expansions = {},
    expansionHeader = "",
    currentExpansionLevel = 0,
    CollapsedIndexes = {}
}

local CACHE = {
    CurrencyList = {
        size = 0
    },
    CurrencyTracker = {}
}

local ACCOUNT_WIDE_CURRENCY = {
    [2032] = true -- Trader's Tender
}

local _G = _G
local PLAYER_V_PLAYER = PLAYER_V_PLAYER

local function GetCurrencyListSize()
    return CACHE.CurrencyList.size
end

local function GetCurrencyListEntryInfo(index)
    local entry = CACHE.CurrencyList[index]
    if entry then
        INFO.ID = entry.ID
        INFO.name = entry.name
        INFO.headerName = entry.headerName
        INFO.isHeader = entry.isHeader
        INFO.isTradeable = entry.isTradeable
        INFO.quantity = entry.quantity
        INFO.maxQuantity = entry.maxQuantity
        INFO.iconFileID = entry.iconFileID
        return INFO
    end
end

local function IterableCurrencyListEntryInfo()
    local i = 0
    local n = GetCurrencyListSize()
    return function()
        i = i + 1
        while i <= n do
            local entry = GetCurrencyListEntryInfo(i)
            if entry and not ACCOUNT_WIDE_CURRENCY[entry.ID] then
                return entry
            end
            i = i + 1
        end
    end
end

local function IterableHeaderInfo(headerName)
    local i = 0
    local n = GetCurrencyListSize()
    return function()
        i = i + 1
        while i <= n do
            local entry = GetCurrencyListEntryInfo(i)
            if entry and headerName:find(entry.headerName)  then
                return entry
            end
            i = i + 1
        end
    end
end

local function FindHeaderByName(headerName)
    for entry in IterableCurrencyListEntryInfo() do
        if entry.quantity > 0 and headerName:find(entry.headerName) then
            return true
        end
    end
    return false
end

local function GetPlayerCurrencyQuantity(currencyID)
    if not currencyID or ACCOUNT_WIDE_CURRENCY[currencyID] then
        return 0
    end
    for entry in IterableCurrencyListEntryInfo() do
        if entry.ID and entry.ID == currencyID then
            return entry.quantity
        end
    end
    return 0
end

local function CacheCurrencyInfo()
    local i = 1
    local currency = C_CurrencyInfo.GetCurrencyListInfo(i)
    local headerName, currencyID

    while currency do
        currencyID = nil

        if not currency.isHeaderExpanded then
            C_CurrencyInfo.ExpandCurrencyList(i, true)
            table.insert(DATA.CollapsedIndexes, i)
        end

        local entry = CACHE.CurrencyList[i]

        if not entry then
            CACHE.CurrencyList[i] = {}
            entry = CACHE.CurrencyList[i]
        end

        if not currency.isHeader then
            local link = C_CurrencyInfo.GetCurrencyListLink(i)
            if link then
                currencyID = C_CurrencyInfo.GetCurrencyIDFromLink(link)
            end
        else
            headerName = currency.name
        end

        entry.ID = currencyID
        entry.name = currency.name
        entry.headerName = headerName
        entry.isHeader = currency.isHeader
        entry.isTradeable = currency.isTradeable
        entry.quantity = currency.quantity
        entry.maxQuantity = currency.maxQuantity
        entry.iconFileID = currency.iconFileID
        
        CACHE.CurrencyList.size = i

        i = i + 1
        currency = C_CurrencyInfo.GetCurrencyListInfo(i)
    end

    for i = #DATA.CollapsedIndexes, 1, -1 do
        local collapsedIndex = DATA.CollapsedIndexes[i]
        C_CurrencyInfo.ExpandCurrencyList(collapsedIndex, false)
        DATA.CollapsedIndexes[i] = nil
    end
end

local function CacheCharactersCurrencyQuantity()
    local currentCharName = CharacterInfo:GetFullName()
    local charName, currency
    local charDisplayName
    for entry in IterableCurrencyListEntryInfo() do 
        if entry.ID then
            charName, currency = Currency.storage:GetCharacterCurrencyInfo(charName)
            while charName do
                if charName ~= currentCharName then
                    local onCurrentRealm = CharacterInfo:IsCharacterOnCurrentRealm(charName)
                    local onConnectedRealm = CharacterInfo:IsCharacterOnConnectedRealm(charName)
                    if onCurrentRealm or onConnectedRealm then
                        for id, quantity in pairs(currency) do
                            if id == entry.ID then
                                charDisplayName = charName
                                if onConnectedRealm then
                                    charDisplayName = CharacterInfo:ShortConnectedRealm(charDisplayName)
                                else
                                    charDisplayName = CharacterInfo:RemoveRealm(charDisplayName)
                                end
                                local charEntry = CACHE.CurrencyTracker[id]
                                if not charEntry then
                                    CACHE.CurrencyTracker[id] = {}
                                    charEntry = CACHE.CurrencyTracker[id]
                                end
                                charEntry[charDisplayName] = quantity
                            end
                        end
                    end
                end
                charName, currency = Currency.storage:GetCharacterCurrencyInfo(charName)
            end
        end
    end
end

local function SetLatestExpansionHeader()
    local headerName
    local expansionLevel = DATA.currentExpansionLevel + 1
    while expansionLevel > 0 do
        headerName = DATA.expansions[expansionLevel]
        if not FindHeaderByName(headerName) then
            -- If we didn't find a header for the latest expansion available
            -- then try the expansion before that
            expansionLevel = expansionLevel - 1
        else
            break
        end
    end
    DATA.expansionHeader = headerName
end

function Currency:OnInitializing()
    DATA.currentExpansionLevel = GetClampedCurrentExpansionLevel()
    for i = 0, DATA.currentExpansionLevel do
        table.insert(DATA.expansions, _G["EXPANSION_NAME" .. i])
    end
end

Currency:RegisterEvent("PLAYER_LOGIN", function(self, eventName)
    CacheCurrencyInfo()
    CacheCharactersCurrencyQuantity()
    SetLatestExpansionHeader()

    self:RegisterEvents(
        "PLAYER_LOGOUT",
        "CURRENCY_DISPLAY_UPDATE", 
        function(self, eventName)
            if eventName == "PLAYER_LOGOUT" then
                self.storage:StoreCurrencyData(IterableCurrencyListEntryInfo)
            elseif eventName == "CURRENCY_DISPLAY_UPDATE" then
                CacheCurrencyInfo()
                CacheCharactersCurrencyQuantity()
                SetLatestExpansionHeader()
            end
        end)

    self.storage:RegisterEvent("WOWINFO_CURRENCY_RESET", function()
        for id in pairs(CACHE.CurrencyTracker) do
            CACHE.CurrencyTracker[id] = nil
        end
    end)
end)

Currency.GetCurrencyListSize = GetCurrencyListSize
Currency.GetCurrencyListEntryInfo = GetCurrencyListEntryInfo
Currency.IterableCurrencyListEntryInfo = IterableCurrencyListEntryInfo

function Currency:IterableLatestExpansionInfo()
    return IterableHeaderInfo(DATA.expansionHeader)
end

function Currency:IterablePvPInfo()
    return IterableHeaderInfo(PLAYER_V_PLAYER)
end

function Currency:IterableCharactersCurrencyInfo(index)
    local link = C_CurrencyInfo.GetCurrencyListLink(index)
    local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
    local entry = CACHE.CurrencyTracker[currencyID]
    local charName, quantity, visitedCurrentChar
    return function()
        if currencyID and not visitedCurrentChar then
            visitedCurrentChar = true
            return CharacterInfo:GetName(), GetPlayerCurrencyQuantity(currencyID), true
        end
        if entry then
            charName, quantity = next(entry, charName)
            if charName then
                return charName, quantity, false
            end
        end
        return nil, 0
    end
end

function Currency:GetTotalQuantity(index)
    local totalQuantity = 0
    for _, quantity in self:IterableCharactersCurrencyInfo(index) do
        totalQuantity = totalQuantity + quantity
    end
    return totalQuantity
end
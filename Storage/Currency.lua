local _, addon = ...
local Storage, DB = addon:NewStorage("Currency")

local defaults = {
    profile = {}
}

function Storage:OnConfig()
    DB = self:RegisterDB(defaults)

    if not addon.DB.global.Currency then
        addon.DB.global.Currency = {}
    end

    local englishFaction = UnitFactionGroup("player")
    local charName = addon.Character:GetFullName()

    if not addon.DB.global.Currency[englishFaction] or type(addon.DB.global.Currency[englishFaction]) ~= "table" then
        addon.DB.global.Currency[englishFaction] = {}
    end

    DB.__data = addon.DB.global.Currency[englishFaction]
    DB.__character_data = DB.__data[charName]

    if not DB.__character_data then
        DB.__character_data = {}
        DB.__data[charName] = DB.__character_data
    end
end

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
                local currencyId = C_CurrencyInfo.GetCurrencyIDFromLink(link)
                if not ACCOUNT_WIDE_CURRENCY[currencyId] then
                    return currencyId, info.quantity
                end
            end
            i = i + 1
        end
    end
end

local function ClearCurrencyData()
    local currencyID = next(DB.__character_data)
    while currencyID do
        DB.__character_data[currencyID] = nil
        currencyID = next(DB.__character_data, currencyID)
    end
end

local function StoreCurrencyData()
    for currencyID, quantity in IterableCurrencyInfo() do
        DB.__character_data[currencyID] = quantity
    end
end

Storage:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_LOGOUT", function(_, eventName)
        if eventName == "PLAYER_LOGIN" then
            ClearCurrencyData()
        elseif eventName == "PLAYER_LOGOUT" then
            StoreCurrencyData()
        end
    end)

function Storage:GetCharacterCurrencyInfo(charName)
    return next(DB.__data, charName)
end

function Storage:Reset()
    for key, value in pairs(addon.DB.global.Currency) do
        if type(value) ~= "table" then
            addon.DB.global.Currency[key] = nil
        end
    end

    for charName in pairs(DB.__data) do
        DB.__data[charName] = nil
    end
end



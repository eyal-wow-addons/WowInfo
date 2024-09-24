local _, addon = ...
local Storage, DB = addon:NewStorage("Currency")

local CharacterInfo = LibStub("CharacterInfo-1.0")

local defaults = {
    profile = {}
}

function Storage:OnInitialized()
    DB = self:RegisterDB(defaults)

    if not addon.DB.global.Currency then
        addon.DB.global.Currency = {}
    end

    local englishFaction = UnitFactionGroup("player")
    local charName = CharacterInfo:GetFullName()

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

function Storage:ClearCurrencyData()
    local currencyID = next(DB.__character_data)
    while currencyID do
        DB.__character_data[currencyID] = nil
        currencyID = next(DB.__character_data, currencyID)
    end
end

function Storage:StoreCurrencyData(iterableCurrencyInfo)
    for currencyID, quantity in iterableCurrencyInfo() do
        DB.__character_data[currencyID] = quantity
    end
end

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



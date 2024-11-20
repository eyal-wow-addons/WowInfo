local _, addon = ...
local Storage, DB = addon:NewStorage("CurrencyTracker")

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
        DB.__data[charName] = {}
        DB.__character_data = DB.__data[charName]
    end
end

function Storage:StoreCurrencyData(iterator)
    for entry in iterator() do
        if entry.ID and entry.quantity > 0 and not entry.isTradeable then
            DB.__character_data[entry.ID] = entry.quantity
        end
    end
end

function Storage:GetCharacterCurrencyInfo(charName)
    if not DB or not DB.__data then return end
    return next(DB.__data, charName)
end

function Storage:Reset()
    for charName in pairs(DB.__data) do
        DB.__data[charName] = nil
    end
    local charName = CharacterInfo:GetFullName()
    DB.__data[charName] = {}
    DB.__character_data = DB.__data[charName]
    self:TriggerEvent("WOWINFO_CURRENCY_TRACKER_RESET")
end
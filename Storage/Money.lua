if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local Storage, DB = addon:NewStorage("Money")

local defaults = {
    profile = {
        hideConnectedRealmsNames = true,
        showAllCharacters = false,
        minMoneyAmount = 0
    }
}

function Storage:OnConfig()
    DB = self:RegisterDB(defaults)

    if not addon.DB.global.Money then
        addon.DB.global.Money = {}
    end

    local englishFaction = UnitFactionGroup("player")

    if not addon.DB.global.Money[englishFaction] or type(addon.DB.global.Money[englishFaction]) ~= "table" then
        addon.DB.global.Money[englishFaction] = {}
    end

    DB.__data = addon.DB.global.Money[englishFaction]
end

do
    Storage:RegisterEvents(
        "PLAYER_LOGIN",
        "PLAYER_MONEY",
        "PLAYER_TRADE_MONEY",  
        "SEND_MAIL_MONEY_CHANGED", 
        "SEND_MAIL_COD_CHANGED", 
        "TRADE_MONEY_CHANGED",
        "WOWINFO_MONEY_DB_RESET", function()
            DB.__data[addon.Character:GetFullName()] = GetMoney()
        end)

    function Storage:GetMoneyInfoByCharacter(charName)
        local money
        charName, money = next(DB.__data, charName)
        while charName do
            if money > 0 and (addon.Character:IsOnConnectedRealm(charName, true) or addon.Character:IsOnCurrentRealm(charName)) then
                return charName, money
            end
            charName, money = next(DB.__data, charName)
        end
    end
end

function Storage:Reset()
    for key, value in pairs(addon.DB.global.Money) do
        if type(value) ~= "table" then
            addon.DB.global.Money[key] = nil
        end
    end

    for charName in pairs(DB.__data) do
        DB.__data[charName] = nil
    end

    DB.__data[addon.Character:GetFullName()] = GetMoney()

    Storage:TriggerEvent("WOWINFO_MONEY_DB_RESET")
end

function Storage:SetMinMoneyAmount(value)
    DB.profile.minMoneyAmount = tonumber(value)
end

function Storage:GetMinMoneyAmount()
    return DB.profile.minMoneyAmount or 0
end

function Storage:IsConnectedRealmsNamesHidden()
    return DB.profile.hideConnectedRealmsNames
end

function Storage:ToggleConnectedRealmsNames()
    DB.profile.hideConnectedRealmsNames = not DB.profile.hideConnectedRealmsNames
end

function Storage:CanShowAllCharacters()
    return DB.profile.showAllCharacters
end

function Storage:ToggleShowAllCharacters()
    DB.profile.showAllCharacters = not DB.profile.showAllCharacters
end
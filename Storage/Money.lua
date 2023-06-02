if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local MoneyDB = addon:NewStorage("Money")
local Character = addon.Character

local defaults = {
    profile = {
        hideConnectedRealmsNames = true,
        showAllCharacters = true,
        minMoneyAmount = 0
    }
}

function MoneyDB:OnInitialize()
    self:RegisterDB(defaults)

    if not addon.DB.global.Money then
        addon.DB.global.Money = {}
    end

    local englishFaction = UnitFactionGroup("player")

    if not addon.DB.global.Money[englishFaction] or type(addon.DB.global.Money[englishFaction]) ~= "table" then
        addon.DB.global.Money[englishFaction] = {}
    end

    self.__money = addon.DB.global.Money[englishFaction]
end

function MoneyDB:UpdateForCharacter(character, money)
    self.__money[character] = money
end

function MoneyDB:IterableMoneyInfo()
    return pairs(self.__money)
end

function MoneyDB:Reset()
    for key, value in pairs(addon.DB.global.Money) do
        if type(value) ~= "table" then
            addon.DB.global.Money[key] = nil
        end
    end

    for character in self:IterableMoneyInfo() do
        self:UpdateForCharacter(character, nil)
    end

    self:UpdateForCharacter(Character:GetFullName(), GetMoney())

    MoneyDB:TriggerEvent("WOWINFO_MONEY_DB_RESET")
end

function MoneyDB:SetMinMoneyAmount(value)
    self.options.profile.minMoneyAmount = tonumber(value)
end

function MoneyDB:GetMinMoneyAmount()
    return self.options.profile.minMoneyAmount or 0
end

function MoneyDB:IsConnectedRealmsNamesHidden()
    return self.options.profile.hideConnectedRealmsNames
end

function MoneyDB:ToggleConnectedRealmsNames()
    self.options.profile.hideConnectedRealmsNames = not self.options.profile.hideConnectedRealmsNames
end

function MoneyDB:CanShowAllCharacters()
    return self.options.profile.showAllCharacters
end

function MoneyDB:ToggleShowAllCharacters()
    self.options.profile.showAllCharacters = not self.options.profile.showAllCharacters
end
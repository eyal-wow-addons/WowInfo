if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local storage, db = addon:NewStorage("Gold")
local options, Gold

local Events = addon.Events

local defaults = {
    profile = {
        hideConnectedRealmsNames = true,
        minGoldAmount = 0
    }
}

function storage:OnInitialize()
    Events:New(db)

    options = self:RegisterDB(defaults)

    if not addon.DB.global.Gold then
        addon.DB.global.Gold = {}
    end

    local englishFaction = UnitFactionGroup("player")

    if not addon.DB.global.Gold[englishFaction] or type(addon.DB.global.Gold[englishFaction]) ~= "table" then
        addon.DB.global.Gold[englishFaction] = {}
    end

    Gold = addon.DB.global.Gold[englishFaction]
end

function db:UpdateGold(player, money)
    Gold[player] = money
end

function db:GetGoldInfo()
    return pairs(Gold)
end

function db:ResetGold()
    for key, value in pairs(addon.DB.global.Gold) do
        if type(value) ~= "table" then
            addon.DB.global.Gold[key] = nil
        end
    end

    for player in self:GetGoldInfo() do
        Gold[player] = nil
    end

    Gold[addon.Character:GetFullName()] = GetMoney()

    self:TriggerEvent("GoldDB_Reset")
end

function db:SetMinGoldAmount(value)
    options.profile.minGoldAmount = tonumber(value)
end

function db:GetMinGoldAmount()
    return options.profile.minGoldAmount or 0
end

function db:ToggleConnectedRealmsNames()
    options.profile.hideConnectedRealmsNames = not options.profile.hideConnectedRealmsNames
end

function db:IsConnectedRealmsNamesHidden()
    return options.profile.hideConnectedRealmsNames
end

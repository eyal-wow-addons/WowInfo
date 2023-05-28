if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local module = addon:NewModule("Storage:Gold")
local Events = addon.Events

local GoldDB, Gold, options = {}
addon.GoldDB = GoldDB

local defaults = {
    profile = {
        hideConnectedRealmsNames = true,
        minGoldAmount = 0
    }
}

function module:OnInitialize()
    Events:New(GoldDB)

    options = addon.DB:RegisterNamespace("Gold", defaults)

    if not addon.DB.global.Gold then
        addon.DB.global.Gold = {}
    end

    local englishFaction = UnitFactionGroup("player")

    if not addon.DB.global.Gold[englishFaction] or type(addon.DB.global.Gold[englishFaction]) ~= "table" then
        addon.DB.global.Gold[englishFaction] = {}
    end

    Gold = addon.DB.global.Gold[englishFaction]
end

function GoldDB:UpdateGold(player, money)
    Gold[player] = money
end

function GoldDB:GetGoldInfo()
    return pairs(Gold)
end

function GoldDB:ResetGold()
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

function GoldDB:SetMinGoldAmount(value)
    options.profile.minGoldAmount = tonumber(value)
end

function GoldDB:GetMinGoldAmount()
    return options.profile.minGoldAmount or 0
end

function GoldDB:ToggleConnectedRealmsNames()
    options.profile.hideConnectedRealmsNames = not options.profile.hideConnectedRealmsNames
end

function GoldDB:IsConnectedRealmsNamesHidden()
    return options.profile.hideConnectedRealmsNames
end

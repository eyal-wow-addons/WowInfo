if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local storage, db = addon:NewStorage("Social")
local options

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function storage:OnInitialize()
    options = self:RegisterDB(defaults)
end

function db:GetMaxOnlineFriends()
    return options.profile.maxOnlineFriends
end

function db:SetMaxOnlineFriends(value)
    options.profile.maxOnlineFriends = tonumber(value)
end

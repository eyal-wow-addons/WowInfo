if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local module = addon:NewModule("Storage:Social")

local SocialDB, options = {}
addon.SocialDB = SocialDB

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function module:OnInitialize()
    options = addon.DB:RegisterNamespace("Social", defaults)
end

function SocialDB:GetMaxOnlineFriends()
    return options.profile.maxOnlineFriends
end

function SocialDB:SetMaxOnlineFriends(value)
    options.profile.maxOnlineFriends = tonumber(value)
end

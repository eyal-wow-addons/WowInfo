local _, addon = ...
local module = addon:NewModule("Storage:GuildFriends")

local GuildFriendsDB, options = {}
addon.GuildFriendsDB = GuildFriendsDB

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function module:OnInitialize()
    options = addon.DB:RegisterNamespace("GuildFriends", defaults)
end

function GuildFriendsDB:GetMaxOnlineGuildFriends()
    return options.profile.maxOnlineFriends
end

function GuildFriendsDB:SetMaxOnlineGuildFriends(value)
    options.profile.maxOnlineFriends = tonumber(value)
end

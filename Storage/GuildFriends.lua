local _, addon = ...
local storage, db = addon:NewStorage("GuildFriends")
local options

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function storage:OnInitialize()
    options = self:RegisterDB(defaults)
end

function db:GetMaxOnlineGuildFriends()
    return options.profile.maxOnlineFriends
end

function db:SetMaxOnlineGuildFriends(value)
    options.profile.maxOnlineFriends = tonumber(value)
end

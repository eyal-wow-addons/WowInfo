local _, addon = ...
local GuildDB = addon:NewStorage("Guild")

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function GuildDB:OnInitialize()
    self:RegisterDB(defaults)
end

function GuildDB:GetMaxOnlineFriends()
    return self.options.profile.maxOnlineFriends
end

function GuildDB:SetMaxOnlineFriends(value)
    self.options.profile.maxOnlineFriends = tonumber(value)
end

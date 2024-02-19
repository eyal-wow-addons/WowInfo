local _, addon = ...
local Storage, DB = addon:NewStorage("Guild")

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function Storage:OnInitialize()
    DB = self:RegisterDB(defaults)
end

function Storage:GetMaxOnlineFriends()
    return DB.profile.maxOnlineFriends
end

function Storage:SetMaxOnlineFriends(value)
    DB.profile.maxOnlineFriends = tonumber(value)
end

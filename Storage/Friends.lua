if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local FriendsDB = addon:NewStorage("Friends")

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function FriendsDB:OnInitialize()
    self:RegisterDB(defaults)
end

function FriendsDB:GetMaxOnlineFriends()
    return self.options.profile.maxOnlineFriends
end

function FriendsDB:SetMaxOnlineFriends(value)
    self.options.profile.maxOnlineFriends = tonumber(value)
end

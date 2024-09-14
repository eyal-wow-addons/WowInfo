local _, addon = ...
local Storage, DB = addon:NewStorage("Friends")

local defaults = {
    profile = {
        maxWowOnlineFriends = 10,
        maxBattleNetOnlineFriends = 10
    }
}

function Storage:OnInitialized()
    DB = self:RegisterDB(defaults)
end

function Storage:GetMaxOnlineFriends(friendsType)
    return friendsType == "WOW" and DB.profile.maxWowOnlineFriends
            or friendsType == "BN" and DB.profile.maxBattleNetOnlineFriends
end

function Storage:SetMaxOnlineFriends(friendsType, value)
    if friendsType == "WOW" then
        DB.profile.maxWowOnlineFriends = tonumber(value)
    elseif friendsType == "BN" then
        DB.profile.maxBattleNetOnlineFriends = tonumber(value)
    end
end

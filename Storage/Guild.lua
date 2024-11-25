local _, addon = ...
local Storage, DB = addon:NewStorage("Guild")

local defaults = {
    profile = {
        maxOnlineFriends = 20
    }
}

function Storage:OnInitialized()
    DB = self:RegisterDB(defaults)
end

local function GetDefault(key, tbl)
    for k, v in pairs() do
		if type(v) == "table" then
			return GetDefault(key, v)
        elseif k == key then
            return v
		end
	end
    -- TODO: throw if not found ynice?
end

function Storage:GetDefault(key)
    return GetDefault(key, defaults)
end

function Storage:GetMaxOnlineFriends()
    return DB.profile.maxOnlineFriends
end

function Storage:SetMaxOnlineFriends(value)
    DB.profile.maxOnlineFriends = tonumber(value)
end

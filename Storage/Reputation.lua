local _, addon = ...
local Storage, DB = addon:NewStorage("Reputation")

local defaults = {
    profile = {
        alwaysShowParagon = true
    }
}

local function GetFactionID(factionID)
    return select(14, GetFactionInfoByID(factionID))
end

function Storage:OnConfig()
    DB = self:RegisterDB(defaults)

    if not addon.DB.global.Reputation then
        addon.DB.global.Reputation = {}
    end

    local rep = addon.DB.global.Reputation
    local charFullName = addon.Character:GetFullName()

    rep[charFullName] = rep[charFullName] or {}
    DB.__data = rep[charFullName]
end

function Storage:GetAlwaysShowParagon()
    return DB.profile.alwaysShowParagon
end

function Storage:ToggleAlwaysShowParagon()
    DB.profile.alwaysShowParagon = not DB.profile.alwaysShowParagon
end

function Storage:IsSelectedFaction(factionID)
    return factionID and GetFactionID(factionID) and DB.__data[factionID] ~= nil
end

function Storage:ToggleFaction(factionID)
    if factionID and GetFactionID(factionID) then
        if DB.__data[factionID] then
            DB.__data[factionID] = nil
        else
            DB.__data[factionID] = true
        end
    end
end

function Storage:HasFactionsTracked()
	return DB.__data and next(DB.__data) and true or false
end


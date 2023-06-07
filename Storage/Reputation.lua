local _, addon = ...
local RepDB = addon:NewStorage("Reputation")
local Character = addon.Character

local defaults = {
    profile = {
        alwaysShowParagon = true
    }
}

local factionStore

local function GetFactionID(factionID)
    return select(14, GetFactionInfoByID(factionID))
end

function RepDB:OnConfig()
    self:RegisterDB(defaults)

    if not addon.DB.global.Reputation then
        addon.DB.global.Reputation = {}
    end

    local rep = addon.DB.global.Reputation
    local charFullName = Character:GetFullName()

    rep[charFullName] = rep[charFullName] or {}
    factionStore = rep[charFullName]
end

function RepDB:GetAlwaysShowParagon()
    return self.options.profile.alwaysShowParagon
end

function RepDB:ToggleAlwaysShowParagon()
    self.options.profile.alwaysShowParagon = not self.options.profile.alwaysShowParagon
end

function RepDB:IsSelectedFaction(factionID)
    return factionID and GetFactionID(factionID) and factionStore ~= nil
end

function RepDB:ToggleFaction(factionID)
    if factionID and GetFactionID(factionID) then
        if factionStore[factionID] then
            factionStore[factionID] = nil
        else
            factionStore[factionID] = true
        end
    end
end

function RepDB:HasFactionsTracked()
	return factionStore and next(factionStore) and true or false
end


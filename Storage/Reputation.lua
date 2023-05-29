local _, addon = ...
local storage, db = addon:NewStorage("Reputation")
local options, Factions

local Character = addon.Character

local defaults = {
    profile = {
        alwaysShowParagon = true
    }
}

storage:RegisterFunction(function()
    options = storage:RegisterDB(defaults)
    if not addon.DB.global.Reputation then
        addon.DB.global.Reputation = {}
    end
    local rep = addon.DB.global.Reputation
    local charFullName = Character:GetFullName()
    rep[charFullName] = rep[charFullName] or {}
    Factions = rep[charFullName]
end)

function db:GetAlwaysShowParagon()
    return options.profile.alwaysShowParagon
end

function db:ToggleAlwaysShowParagon()
    options.profile.alwaysShowParagon = not options.profile.alwaysShowParagon
end

function db:IsSelectedFaction(factionID)
    return factionID and select(14, GetFactionInfoByID(factionID)) and Factions[factionID] ~= nil
end

function db:ToggleFaction(factionID)
    if factionID and select(14, GetFactionInfoByID(factionID)) then
        if Factions[factionID] then
            Factions[factionID] = nil
        else
            Factions[factionID] = true
        end
    end
end

function db:HasFactionsTracked()
	return Factions and next(Factions) and true or false
end


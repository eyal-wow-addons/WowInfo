local _, addon = ...
local module = addon:NewModule("Storage:Reputation")
local ScriptLoader = addon.ScriptLoader
local Character = addon.Character

local ReputationDB, Factions, options = {}
addon.ReputationDB = ReputationDB

local defaults = {
    profile = {
        alwaysShowParagon = true
    }
}

ScriptLoader:RegisterScript(function()
    options = addon.DB:RegisterNamespace("Reputation", defaults)
    if not addon.DB.global.Reputation then
        addon.DB.global.Reputation = {}
    end
    local rep = addon.DB.global.Reputation
    local charFullName = Character:GetFullName()
    rep[charFullName] = rep[charFullName] or {}
    Factions = rep[charFullName]
end)

function ReputationDB:GetAlwaysShowParagon()
    return options.profile.alwaysShowParagon
end

function ReputationDB:ToggleAlwaysShowParagon()
    options.profile.alwaysShowParagon = not options.profile.alwaysShowParagon
end

function ReputationDB:IsSelectedFaction(factionID)
    return factionID and select(14, GetFactionInfoByID(factionID)) and Factions[factionID] ~= nil
end

function ReputationDB:ToggleFaction(factionID)
    if factionID and select(14, GetFactionInfoByID(factionID)) then
        if Factions[factionID] then
            Factions[factionID] = nil
        else
            Factions[factionID] = true
        end
    end
end

function ReputationDB:HasFactionsTracked()
	return Factions and next(Factions) and true or false
end


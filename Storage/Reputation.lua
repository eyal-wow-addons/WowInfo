local _, addon = ...
local CharacterInfo = LibStub("CharacterInfo-1.0")
local Storage, DB = addon:NewStorage("Reputation")

local defaults = {
    profile = {
        alwaysShowParagon = true
    }
}

function Storage:OnInitialized()
    DB = self:RegisterDB(defaults)

    if not addon.DB.global.Reputation then
        addon.DB.global.Reputation = {}
    end

    local rep = addon.DB.global.Reputation
    local charName = CharacterInfo:GetFullName()

    rep[charName] = rep[charName] or {}
    
    DB.__data = rep[charName]
end

function Storage:GetAlwaysShowParagon()
    return DB.profile.alwaysShowParagon
end

function Storage:ToggleAlwaysShowParagon()
    DB.profile.alwaysShowParagon = not DB.profile.alwaysShowParagon
end

function Storage:IsSelectedFaction(factionID)
    return factionID and DB.__data[factionID] ~= nil
end

function Storage:ToggleFaction(factionID)
    if factionID then
        if DB.__data[factionID] then
            DB.__data[factionID] = nil
        else
            DB.__data[factionID] = true
        end
    end
end
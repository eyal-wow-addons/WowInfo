local _, addon = ...
local CharacterInfo = LibStub("CharacterInfo-1.0")
local Storage, DB = addon:NewStorage("Reputation")

local GetNumFactions = C_Reputation.GetNumFactions
local GetFactionDataByIndex = C_Reputation.GetFactionDataByIndex
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local IsFactionParagon = C_Reputation.IsFactionParagon

local defaults = {
    profile = {
        alwaysShowParagon = true
    }
}

local function GetFactionID(index)
    local factionData = GetFactionDataByIndex(index)
    return factionData and factionData.factionID
end

local function HasParagonRewardPending(factionID)
    local hasParagonRewardPending = false
    if factionID then
        if IsFactionParagon(factionID) then
            local _, _, _, hasRewardPending, tooLowLevelForParagon = GetFactionParagonInfo(factionID)
            if not tooLowLevelForParagon and hasRewardPending then
                hasParagonRewardPending = true
            end
        end
    end
    return hasParagonRewardPending
end

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

function Storage:GetTrackedFaction(index)
    local factionID = GetFactionID(index)
    local shouldAlwaysShowParagon = self:GetAlwaysShowParagon() and HasParagonRewardPending(factionID)
    if factionID and DB.__data[factionID] or shouldAlwaysShowParagon then
        return factionID
    end
    return nil
end

function Storage:IterableTrackedFactions()
    local i = 0
    local n = GetNumFactions()
    return function()
        i = i + 1
        while i <= n do
            local factionID = self:GetTrackedFaction(i)
            if factionID then
                return factionID
            end
            i = i + 1
        end
    end
end


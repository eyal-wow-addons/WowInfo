local _, addon = ...
local Frame = addon.Frame
local Realm = {}
addon.Realm = Realm

local connectedRealms, myRealm = {}

local frame = CreateFrame("Frame", "WowInfo_RealmFrame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    local _, realm = UnitFullName("player")
    myRealm = realm
    for i, v in ipairs(GetAutoCompleteRealms() or {}) do
        connectedRealms[v] = true
    end
    frame:UnregisterEvent(event)
end)

function Realm:IsRealmConnectedRealm(realm, includeOwn)
    if not realm then return end
    realm = realm:gsub("[ -]", "")
    return (realm ~= myRealm or includeOwn) and connectedRealms[realm]
end

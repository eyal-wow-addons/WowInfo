local _, addon = ...
local Realm = addon:NewObject("Realm")

local myRealm
local realms, realmsMap = GetAutoCompleteRealms() or {}, {}

for i, v in ipairs(realms) do
    realmsMap[v] = true
end

function Realm:OnBeforeConfig()
    local _, realm = UnitFullName("player")
    myRealm = realm
end

function Realm:IsRealmConnectedRealm(realm, includeOwn)
    realm = realm:gsub("[ -]", "")
    return (realm ~= myRealm or includeOwn) and realmsMap[realm]
end

function Realm:IterableConnectedRealms()
    local i = 0
    local n = #realms
    return function ()
        i = i + 1
        if i <= n then
            local realm = realms[i]
            return myRealm == realm, realm
        end
    end
end



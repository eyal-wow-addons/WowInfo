local _, addon = ...
local Character = addon:NewObject("Character")

local REALM_PATTERN = "% - (.+)"

local charName, charRealm1, charRealm2, charFullName

function Character:OnBeforeConfig()
    charName, charRealm1 = UnitName("player"), GetRealmName()
    charRealm2 = select(2, UnitFullName("player"))
    charFullName = string.join(" - ", charName, charRealm1)
end

function Character:GetName()
    return charName
end

function Character:GetRealm(trimmed)
    return trimmed and charRealm2 or charRealm1
end

function Character:GetFullName()
    return charFullName
end

function Character:IsSameCharacter(name)
    return name == self:GetFullName()
end

function Character:IsOnCurrentRealm(name)
    return name:find(self:GetRealm())
end

function Character:IsOnConnectedRealm(name)
    return addon.Realm:IsRealmConnectedRealm(name:match(REALM_PATTERN))
end

function Character:RemoveRealm(name)
    return name:gsub(REALM_PATTERN, "")
end

function Character:ShortConnectedRealm(name)
    return name:gsub(REALM_PATTERN, "*")
end
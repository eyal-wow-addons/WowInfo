local _, addon = ...
local Character = {}
addon.Character = Character

local charName, charRealm1, charRealm2, charFullName

local frame = CreateFrame("Frame", "WowInfo_CharacterFrame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    charName, charRealm1 = UnitName("player"), GetRealmName()
    charRealm2 = select(2, UnitFullName("player"))
    charFullName = string.join(" - ", charName, charRealm1)
    frame:UnregisterEvent(event)
end)

function Character:GetName()
    return charName
end

function Character:GetRealm(trimmed)
    return trimmed and charRealm2 or charRealm1
end

function Character:GetFullName()
    return charFullName
end

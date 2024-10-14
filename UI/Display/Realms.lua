local _, addon = ...
local CharacterInfo = LibStub("CharacterInfo-1.0")
local Display = addon:NewDisplay("Realms")

local L = addon.L

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    if CharacterInfo:IsOnConnectedRealm() then
        if CharacterInfo:HasConnectedRealms() then
            Display:AddHeader(L["Connected Realms:"])
        end
        for isPlayerRealm, realm in CharacterInfo:IterableConnectedRealms() do
            Display:SetLine(realm)
            if isPlayerRealm then
                Display:SetPlayerClassColor()
            end
            Display:ToLine()
        end
    else
        Display:AddFormattedHeader(L["Realm: X"], Display:ToPlayerClassColor(CharacterInfo:GetRealm()))
    end
    Display:Show()
end)

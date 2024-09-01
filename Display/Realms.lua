local _, addon = ...
local PlayerInfo = LibStub("PlayerInfo-1.0")
local Display = addon:NewDisplay("Realms")

local L = addon.L

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    if PlayerInfo:IsCurrentCharacterOnConnectedRealm() then
        if PlayerInfo:HasConnectedRealms() then
            Display:AddHeader(L["Connected Realms:"])
        end
        for isPlayerRealm, realm in PlayerInfo:IterableConnectedRealms() do
            Display:SetLine(realm)
            if isPlayerRealm then
                Display:SetClassColor()
            end
            Display:ToLine()
        end
    else
        Display:AddFormattedHeader(L["Realm: X"], Display:ToClassColor(PlayerInfo:GetCharacterRealm()))
    end
    Display:Show()
end)

local _, addon = ...
local L = addon.L
local PlayerInfo = LibStub("PlayerInfo-1.0")
local Display = addon:NewDisplay("Realms")

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    if PlayerInfo:IsCurrentCharacterOnConnectedRealm() then
        if PlayerInfo:HasConnectedRealms() then
            Display:AddHeader(L["Connected Realms:"])
        end
        for isPlayerRealm, realm in PlayerInfo:IterableConnectedRealms() do
            if isPlayerRealm then
                Display:AddClassColorLine(realm)
            else
                Display:AddLine(realm)
            end
        end
    else
        Display:AddFormattedClassColoredHeader(L["Realm: X"], PlayerInfo:GetCharacterRealm())
    end
    Display:Show()
end)

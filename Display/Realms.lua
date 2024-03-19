local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("ConnectedRealms")
local Realm = addon.Realm
local Character = addon.Character

Realm:RegisterEvent("REALM_SHOW_CONNECTED_REALMS", function()
    Display:AddTitleLine(L["Connected Realms:"], true)
end)

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    if Character:IsOnConnectedRealm(Character:GetFullName(), true) then
        for isPlayerRealm, realm in Realm:IterableConnectedRealms() do
            if isPlayerRealm then
                realm = GetClassColoredTextForUnit("player", realm)
            end
            Display:AddLine(realm)
        end
    else
        local realm = GetClassColoredTextForUnit("player", Character:GetRealm())
        Display:AddTitleLine(L["Realm: X"]:format(realm), true)
    end
    Display:Show()
end)

local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("ConnectedRealms")
local Realm = addon.Realm

Realm:RegisterEvent("REALM_SHOW_CONNECTED_REALMS", function()
    Display:AddTitleLine(L["Connected Realms:"], true)
end)

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    for isPlayerRealm, realm in Realm:IterableConnectedRealms() do
        if isPlayerRealm then
            realm = GetClassColoredTextForUnit("player", realm)
        end
        Display:AddLine(realm)
    end

    Display:Show()
end)

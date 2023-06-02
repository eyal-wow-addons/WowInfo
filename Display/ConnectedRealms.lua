local _, addon = ...
local Display = addon:NewDisplay("ConnectedRealms")

local Realm = addon.Realm

local CONNECTED_REALMS_LABEL = "Connected Realms:"

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    Display:AddEmptyLine()
    Display:AddHighlightLine(CONNECTED_REALMS_LABEL)

    for isPlayerRealm, realm in Realm:IterableConnectedRealmsInfo() do
        if isPlayerRealm then
            realm = GetClassColoredTextForUnit("player", realm)
        end
        Display:AddLine(realm)
    end

    Display:Show()
end)

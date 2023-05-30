local _, addon = ...
local plugin = addon:NewPlugin("ConnectedRealms", "AceHook-3.0")

local Realm = addon.Realm
local Tooltip = addon.Tooltip

local CONNECTED_REALMS_LABEL = "Connected Realms:"

plugin:SecureHook("MainMenuBarPerformanceBarFrame_OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(CONNECTED_REALMS_LABEL)

    for isPlayerRealm, realm in Realm:IterableConnectedRealmsInfo() do
        if isPlayerRealm then
            realm = GetClassColoredTextForUnit("player", realm)
        end
        Tooltip:AddLine(realm)
    end

    Tooltip:Show()
end)

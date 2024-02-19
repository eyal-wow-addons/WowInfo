local _, addon = ...
local Display = addon:NewDisplay("ConnectedRealms")

local Realm = addon.Realm

local CONNECTED_REALMS_LABEL = "Connected Realms:"

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    local isLabelAdded
    
    for isPlayerRealm, realm in Realm:IterableConnectedRealms() do
        if not isLabelAdded then
            Display:AddEmptyLine()
            Display:AddHighlightLine(CONNECTED_REALMS_LABEL)
            isLabelAdded = true
        end
        if isPlayerRealm then
            realm = GetClassColoredTextForUnit("player", realm)
        end
        Display:AddLine(realm)
    end

    Display:Show()
end)

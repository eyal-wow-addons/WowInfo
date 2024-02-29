local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("ConnectedRealms")
local Realm = addon.Realm

hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", function()
    local isLabelAdded
    
    for isPlayerRealm, realm in Realm:IterableConnectedRealms() do
        if not isLabelAdded then
            Display:AddTitleLine(L["Connected Realms:"])
            isLabelAdded = true
        end
        if isPlayerRealm then
            realm = GetClassColoredTextForUnit("player", realm)
        end
        Display:AddLine(realm)
    end

    Display:Show()
end)

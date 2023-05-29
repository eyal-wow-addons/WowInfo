local _, addon = ...
local plugin = addon:NewPlugin("ConnectedRealms", "AceHook-3.0")

local Tooltip = addon.Tooltip

local realms = GetAutoCompleteRealms() or {}
if #realms == 0 then return end

local CONNECTED_REALMS_LABEL = "Connected Realms:"

plugin:SecureHook("MainMenuBarPerformanceBarFrame_OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(CONNECTED_REALMS_LABEL)

    local _, playerRealm = UnitFullName("player")

    for _, realm in ipairs(realms) do
        if realm == playerRealm then
            realm = GetClassColoredTextForUnit("player", realm)
        end
        Tooltip:AddLine(realm)
    end

    Tooltip:Show()
end)

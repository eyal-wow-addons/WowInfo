local _, addon = ...
local module = addon:NewModule("Scripts:ConnectedRealms", "AceHook-3.0")
local Tooltip = addon.Tooltip

local realms = GetAutoCompleteRealms() or {}
if #realms == 0 then return end

local CONNECTED_REALMS_LABEL = "Connected Realms:"

local REALM_CLASS_COLOR_FORMAT = "|cff%.2x%.2x%.2x%s|r"

module:SecureHook("MainMenuBarPerformanceBarFrame_OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(CONNECTED_REALMS_LABEL)

    local _, playerRealm = UnitFullName("player")

    for _, realm in ipairs(realms) do
        if realm == playerRealm then
            local _, englishClass = UnitClass("player")
            local classColor = englishClass and RAID_CLASS_COLORS[englishClass] or NORMAL_FONT_COLOR
            realm = REALM_CLASS_COLOR_FORMAT:format(classColor.r * 255, classColor.g * 255, classColor.b * 255, realm)
        end
        Tooltip:AddLine(realm)
    end

    Tooltip:Show()
end)

local _, addon = ...
local CharacterInfo = LibStub("CharacterInfo-1.0")
local Tooltip = addon:NewTooltip("Realms")

local L = addon.L

Tooltip.target = {
    funcName = "MainMenuBarPerformanceBarFrame_OnEnter",
    func = function()
        if CharacterInfo:IsOnConnectedRealm() then
            if CharacterInfo:HasConnectedRealms() then
                Tooltip:AddHeader(L["Connected Realms:"])
            end
            for isPlayerRealm, realm in CharacterInfo:IterableConnectedRealms() do
                Tooltip:SetLine(realm)
                if isPlayerRealm then
                    Tooltip:SetPlayerClassColor()
                end
                Tooltip:ToLine()
            end
        else
            Tooltip:AddFormattedHeader(L["Realm: X"], Tooltip:ToPlayerClassColor(CharacterInfo:GetRealm()))
        end
    end
}
local _, addon = ...
local Speedometer = addon:GetObject("Speedometer")

local LDB = LibStub("LibDataBroker-1.1")

local L = addon.L

local dataobj

local function UpdateTextWhenStartedMoving(_, _, status, currentSpeed)
    status = L["S : S"]:format(currentSpeed, L[status])
    if MinimapCluster.ZoneTextButton:IsVisible() then
        if MinimapCluster:IsEventRegistered("ZONE_CHANGED") then
            MinimapCluster:UnregisterEvent("ZONE_CHANGED")
            MinimapCluster:UnregisterEvent("ZONE_CHANGED_INDOORS")
            MinimapCluster:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        end
        MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        MinimapZoneText:SetText(status)
    end
    dataobj.text = status
end

local function UpdateTextWhenStoppedMoving()
    if MinimapCluster.ZoneTextButton:IsVisible() then
        if not MinimapCluster:IsEventRegistered("ZONE_CHANGED") then
            MinimapCluster:RegisterEvent("ZONE_CHANGED")
            MinimapCluster:RegisterEvent("ZONE_CHANGED_INDOORS")
            MinimapCluster:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        end
        Minimap_Update()
    end
    dataobj.text = ""
end

Speedometer:RegisterEvent("WOWINFO_PLAYER_STARTED_MOVING", UpdateTextWhenStartedMoving)
Speedometer:RegisterEvent("WOWINFO_PLAYER_STOPPED_MOVING", UpdateTextWhenStoppedMoving)

dataobj = LDB:NewDataObject("Speedometer", {
    type = "data source"
})

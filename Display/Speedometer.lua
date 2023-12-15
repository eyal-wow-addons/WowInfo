local _, addon = ...
local LDB = LibStub("LibDataBroker-1.1")
local Speedometer = addon.Speedometer

local dataobj

local function UpdateText()
    if MinimapCluster.ZoneTextButton:IsVisible() then
        MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        MinimapZoneText:SetText(Speedometer:GetFormattedCurrentSpeed())
    end
end

local function UpdateTextWhenStartMoving(_, status)
    if MinimapCluster.ZoneTextButton:IsVisible() then
        MinimapCluster.ZoneTextButton:SetScript("OnUpdate", UpdateText)
    end
    dataobj.text = status
end

local function UpdateTextWhenStopMoving(_, status)
    if MinimapCluster.ZoneTextButton:IsVisible() then
        MinimapCluster.ZoneTextButton:SetScript("OnUpdate", nil)
        Minimap_Update()
    end
    if UnitOnTaxi("player") then
        status = "Taxi"
    end
    dataobj.text = status
end

Speedometer:RegisterEvent("SPEEDOMETER_PLAYER_STARTED_MOVING", UpdateTextWhenStartMoving)
Speedometer:RegisterEvent("SPEEDOMETER_PLAYER_STOPPED_MOVING", UpdateTextWhenStopMoving)

dataobj = LDB:NewDataObject("Speedometer", {
    type = "data source"
})

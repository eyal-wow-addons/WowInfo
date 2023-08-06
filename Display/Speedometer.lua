local _, addon = ...
local Display = addon:NewDisplay("Speedometer")
local LDB = LibStub("LibDataBroker-1.1")
local Timer = addon.Timer
local Speedometer = addon.Speedometer

local SPEED_HEADER = STAT_SPEED .. ":"
local SPEED_GROUND_LABEL = STAT_MOVEMENT_GROUND_TOOLTIP:gsub("%s.+", "")
local SPEED_FLIGHT_LABEL = STAT_MOVEMENT_FLIGHT_TOOLTIP:gsub("%s.+", "")
local SPEED_SWIM_LABEL = STAT_MOVEMENT_SWIM_TOOLTIP:gsub("%s.+", "")

local dataobj, timer

local function UpdateText()
    if MinimapCluster.ZoneTextButton:IsVisible() then
        MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        MinimapZoneText:SetText(Speedometer:GetFormattedCurrentSpeed())
    end
end

local function UpdateTextWhenStartMoving()
    if MinimapCluster.ZoneTextButton:IsVisible() then
        MinimapCluster.ZoneTextButton:SetScript("OnUpdate", UpdateText)
    end
    timer:Start(0)
end

local function UpdateTextWhenStopMoving()
    if MinimapCluster.ZoneTextButton:IsVisible() then
        MinimapCluster.ZoneTextButton:SetScript("OnUpdate", nil)
        Minimap_Update()
    end
    timer:Cancel()
    dataobj.text = "Standing"
end

Display:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if IsPlayerMoving() or Speedometer:GetCurrentSpeed() > 0 then
        UpdateTextWhenStartMoving()
    else
        UpdateTextWhenStopMoving()
    end
end)

function Display:OnInitialize()
    timer = Timer:Create(function()
        dataobj.text = Speedometer:GetFormattedCurrentSpeed()
    end)
end

Display:RegisterEvent("PLAYER_STARTED_MOVING", UpdateTextWhenStartMoving)
Display:RegisterEvent("PLAYER_STOPPED_MOVING", UpdateTextWhenStopMoving)

dataobj = LDB:NewDataObject("Speedometer", {
    type = "data source"
})

MinimapCluster.ZoneTextButton:HookScript("OnEnter", function()
    Display:AddEmptyLine()

    local runSpeedString, flightSpeedString, swimSpeedString = Speedometer:GetFormattedPlayerSpeedInfo()
    
    Display:AddHighlightLine(SPEED_HEADER)
    Display:AddRightHighlightDoubleLine(SPEED_GROUND_LABEL, runSpeedString)
    Display:AddRightHighlightDoubleLine(SPEED_FLIGHT_LABEL, flightSpeedString)
    Display:AddRightHighlightDoubleLine(SPEED_SWIM_LABEL, swimSpeedString)

    Display:Show()
end)

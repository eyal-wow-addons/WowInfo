if not MinimapCluster.ZoneTextButton:IsVisible() then return end

local _, addon = ...
local Display = addon:NewDisplay("Speedometer")
local Speedometer = addon.Speedometer

local SPEED_HEADER = STAT_SPEED .. ":"
local SPEED_GROUND_LABEL = STAT_MOVEMENT_GROUND_TOOLTIP:gsub("%s.+", "")
local SPEED_FLIGHT_LABEL = STAT_MOVEMENT_FLIGHT_TOOLTIP:gsub("%s.+", "")
local SPEED_SWIM_LABEL = STAT_MOVEMENT_SWIM_TOOLTIP:gsub("%s.+", "")

local function UpdateText()
    MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    MinimapZoneText:SetText(Speedometer:GetFormattedCurrentSpeed())
end

local function UpdateTextWhenStartMoving()
    MinimapCluster.ZoneTextButton:SetScript("OnUpdate", UpdateText)
end

local function UpdateTextWhenStopMoving()
    MinimapCluster.ZoneTextButton:SetScript("OnUpdate", nil)
    Minimap_Update()
end

Display:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if IsPlayerMoving() or Speedometer:GetCurrentSpeed() > 0 then
        UpdateTextWhenStartMoving()
    else
        UpdateTextWhenStopMoving()
    end
end)

Display:RegisterEvent("PLAYER_STARTED_MOVING", UpdateTextWhenStartMoving)
Display:RegisterEvent("PLAYER_STOPPED_MOVING", UpdateTextWhenStopMoving)

MinimapCluster.ZoneTextButton:HookScript("OnEnter", function(self)
    Display:AddEmptyLine()

    local runSpeedString, flightSpeedString, swimSpeedString = Speedometer:GetFormattedPlayerSpeedInfo()
    
    Display:AddHighlightLine(SPEED_HEADER)
    Display:AddRightHighlightDoubleLine(SPEED_GROUND_LABEL, runSpeedString)
    Display:AddRightHighlightDoubleLine(SPEED_FLIGHT_LABEL, flightSpeedString)
    Display:AddRightHighlightDoubleLine(SPEED_SWIM_LABEL, swimSpeedString)

    Display:Show()
end)

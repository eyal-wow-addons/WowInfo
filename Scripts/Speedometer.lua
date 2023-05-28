if not MinimapCluster.ZoneTextButton:IsVisible() then return end

local _, addon = ...
local module = addon:NewModule("Scripts:Speedometer", "AceEvent-3.0")
local Tooltip = addon.Tooltip

local SPEED_HEADER = STAT_SPEED .. ":"
local SPEED_GROUND_LABEL = STAT_MOVEMENT_GROUND_TOOLTIP:gsub("%s.+", "")
local SPEED_FLIGHT_LABEL = STAT_MOVEMENT_FLIGHT_TOOLTIP:gsub("%s.+", "")
local SPEED_SWIM_LABEL = STAT_MOVEMENT_SWIM_TOOLTIP:gsub("%s.+", "")

local format = string.format
local GetUnitSpeed = GetUnitSpeed

local currentUnit = "player"

local function FormatSpeed(speed)
    return format("%d%%", speed / BASE_MOVEMENT_SPEED * 100 + 0.5)
end

local function UpdateText()
    MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    MinimapZoneText:SetText(FormatSpeed(GetUnitSpeed(currentUnit)))
end

local function UpdateTextWhenStartMoving()
    MinimapCluster.ZoneTextButton:SetScript("OnUpdate", UpdateText)
end

local function UpdateTextWhenStopMoving()
    MinimapCluster.ZoneTextButton:SetScript("OnUpdate", nil)
    Minimap_Update()
end

module:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if UnitInVehicle("player") then
        currentUnit = "vehicle"
    end
    if IsPlayerMoving() or GetUnitSpeed(currentUnit) > 0 then
        UpdateTextWhenStartMoving()
    else
        UpdateTextWhenStopMoving()
    end
end)

module:RegisterEvent("PLAYER_STARTED_MOVING", UpdateTextWhenStartMoving)
module:RegisterEvent("PLAYER_STOPPED_MOVING", UpdateTextWhenStopMoving)

module:RegisterEvent("UNIT_ENTERED_VEHICLE", function(event, unit)
    if unit == "player" then
        currentUnit = "vehicle"
    end
end)

module:RegisterEvent("UNIT_EXITED_VEHICLE", function(event, unit)
    if unit == "player" then
        currentUnit = "player"
    end
end)

MinimapCluster.ZoneTextButton:HookScript("OnEnter", function(self)
    Tooltip:AddEmptyLine()

    local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    Tooltip:AddHighlightLine(SPEED_HEADER)
    Tooltip:AddRightHighlightDoubleLine(SPEED_GROUND_LABEL, FormatSpeed(runSpeed))
    Tooltip:AddRightHighlightDoubleLine(SPEED_FLIGHT_LABEL, FormatSpeed(flightSpeed))
    Tooltip:AddRightHighlightDoubleLine(SPEED_SWIM_LABEL, FormatSpeed(swimSpeed))

    Tooltip:Show()
end)

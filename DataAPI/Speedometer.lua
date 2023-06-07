local _, addon = ...
local Speedometer = addon:NewObject("Speedometer")

local currentUnit = "player"

Speedometer:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if UnitInVehicle("player") then
        currentUnit = "vehicle"
    end
end)

Speedometer:RegisterEvent("UNIT_ENTERED_VEHICLE", function(event, unit)
    if unit == "player" then
        currentUnit = "vehicle"
    end
end)

Speedometer:RegisterEvent("UNIT_EXITED_VEHICLE", function(event, unit)
    if unit == "player" then
        currentUnit = "player"
    end
end)

local function FormatSpeed(speed)
    return format("%d%%", speed / BASE_MOVEMENT_SPEED * 100 + 0.5)
end

function Speedometer:GetFormattedPlayerSpeedInfo()
    local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    return FormatSpeed(runSpeed), FormatSpeed(flightSpeed), FormatSpeed(swimSpeed)
end

function Speedometer:GetCurrentSpeed()
    return GetUnitSpeed(currentUnit)
end

function Speedometer:GetFormattedCurrentSpeed()
    return FormatSpeed(self:GetCurrentSpeed())
end

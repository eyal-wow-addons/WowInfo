local _, addon = ...
local Speedometer = addon:NewObject("Speedometer")

local currentUnit = "player"

Speedometer:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if UnitInVehicle("player") then
        currentUnit = "vehicle"
    end
end)

Speedometer:RegisterEvent("UNIT_ENTERED_VEHICLE", function(_, unit)
    if unit == "player" then
        currentUnit = "vehicle"
    end
end)

Speedometer:RegisterEvent("UNIT_EXITED_VEHICLE", function(_, unit)
    if unit == "player" then
        currentUnit = "player"
    end
end)

local function FormatSpeed(speed, status)
    speed = Round(speed / BASE_MOVEMENT_SPEED * 100)
    if status then
        return format("%s at %d%%", status, speed)
    else
        return format("%d%%", speed)
    end
end

function Speedometer:GetFormattedPlayerSpeedInfo()
    local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    return FormatSpeed(runSpeed), FormatSpeed(flightSpeed), FormatSpeed(swimSpeed)
end

function Speedometer:GetCurrentSpeed()
    local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    return isGliding and forwardSpeed or GetUnitSpeed(currentUnit), isGliding
end

function Speedometer:GetFormattedCurrentSpeed()
    local status
    local currentSpeed, isGliding = self:GetCurrentSpeed()

    if isGliding then
        status = "Gliding"
    elseif IsFlying() then
        status = "Flying"
    elseif IsSwimming() then
        status = "Swimming"
    elseif currentSpeed > 0 then
        status = "Moving"
    end

    return FormatSpeed(currentSpeed, status)
end

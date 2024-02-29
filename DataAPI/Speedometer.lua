local _, addon = ...
local L = addon.L
local Timer = addon.Timer
local Speedometer = addon:NewObject("Speedometer")

local IsPlayerMoving = IsPlayerMoving
local GetUnitSpeed = GetUnitSpeed
local GetGlidingInfo = C_PlayerInfo.GetGlidingInfo

local currentUnit = "player"
local timer

local function FormatSpeed(currentSpeed, status)
    local speedPercentage = Round(currentSpeed / BASE_MOVEMENT_SPEED * 100)
    if status and currentSpeed == 0 then
        return status
    elseif status then
        return format(L["S at X%"], status, speedPercentage)
    else
        return format("%d%%", speedPercentage)
    end
end

local function StartedMoving()
    Speedometer:TriggerEvent("SPEEDOMETER_PLAYER_STARTED_MOVING", Speedometer:GetFormattedCurrentSpeed())
end

local function StoppedMoving()
    Speedometer:TriggerEvent("SPEEDOMETER_PLAYER_STOPPED_MOVING", L["Standing"])
end

function Speedometer:OnBeforeConfig()
    timer = Timer:Create(function()
        if IsPlayerMoving() then
            StartedMoving()
        else
            StoppedMoving()
        end
    end)
    timer:Start(0.5)
end

Speedometer:RegisterEvent("PLAYER_STARTED_MOVING", StartedMoving)
Speedometer:RegisterEvent("PLAYER_STOPPED_MOVING", StoppedMoving)

Speedometer:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if UnitInVehicle("player") then
        currentUnit = "vehicle"
    end
end)

Speedometer:RegisterEvent("UNIT_ENTERED_VEHICLE", function(_, _, unit)
    if unit == "player" then
        currentUnit = "vehicle"
    end
end)

Speedometer:RegisterEvent("UNIT_EXITED_VEHICLE", function(_, _, unit)
    if unit == "player" then
        currentUnit = "player"
    end
end)

function Speedometer:GetFormattedPlayerSpeedInfo()
    local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
    return FormatSpeed(runSpeed), FormatSpeed(flightSpeed), FormatSpeed(swimSpeed)
end

function Speedometer:GetCurrentSpeed()
    local isGliding, _, forwardSpeed = GetGlidingInfo()
    return isGliding and forwardSpeed or GetUnitSpeed(currentUnit), isGliding
end

function Speedometer:GetFormattedCurrentSpeed()
    local status
    local currentSpeed, isGliding = self:GetCurrentSpeed()

    if isGliding then
        status = L["Glide"] 
    elseif IsFlying() then
        status = L["Fly"]
    elseif IsSwimming() then
        status = L["Swim"]
    elseif IsPlayerMoving() and currentSpeed == 0 then
        status = L["Moving"]
    elseif IsPlayerMoving() then
        status = L["Move"]
    end

    return FormatSpeed(currentSpeed, status)
end

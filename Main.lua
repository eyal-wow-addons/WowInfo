local addon = LibStub("Addon-1.0"):New(...)
local Tooltip = LibStub("Tooltip-1.0")

function addon:NewDisplay(name)
    local display = addon:NewObject(name .. "Display")
    return display, Tooltip
end
local addon = LibStub("Addon-1.0"):New(...)
local Tooltip = LibStub("Tooltip-1.0")

function addon:NewDisplay(name)
    local obj = addon:NewObject(name .. "Display")
    return Tooltip:CreateProxy(Tooltip, obj)
end
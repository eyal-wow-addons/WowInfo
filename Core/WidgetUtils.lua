local _, addon = ...
local WidgetUtils = {}
addon.WidgetUtils = WidgetUtils

function WidgetUtils:CreateWidgetProxy(frame, tbl)
    local mt  = {
        __index = frame
    }

    local wrapper = setmetatable(tbl, mt)

    -- Sets the userdata so the widget API would work with the wrapper
    wrapper[0] = frame[0]

    return wrapper
end
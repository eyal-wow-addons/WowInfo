local addon = LibStub("Addon-1.0"):New(...)

function addon:OnInitialized()
    self.DB = LibStub("AceDB-3.0"):New("WowInfoDB", {}, true)
end

do
    local Tooltip = LibStub("Tooltip-1.0")
    local Colorizer = addon.Colorizer

    local MT = {
        __index = function(_, key)
            return Tooltip[key] or Colorizer[key]
        end
    }

    function addon:NewDisplay(name)
        local display = addon:NewObject(name .. "Display")
        return setmetatable(display, MT)
    end
end


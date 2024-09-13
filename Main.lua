local addon = LibStub("Addon-1.0"):New(...)

local Tooltip = LibStub("Tooltip-1.0")
local Colorizer = addon.Colorizer

function addon:OnInitialized()
    self.DB = LibStub("AceDB-3.0"):New("WowInfoDB", {}, true)
end

do
    local MT = {
        __index = function(t, key)
            return Tooltip[key]
                    or Colorizer[key]
                    or rawget(t, "__friend") and t.__friend[key] 
                    or rawget(t, "__extension") and t.__extension[key]
        end
    }

    function addon:NewDisplay(name, extensionName)
        local display = addon:NewObject(name .. "Display")
        local friend = addon:GetObject(name .. "Extension", true)
        -- When the Display and the Extension have the same name they are considered friends,
        -- meaning, the Display can access the Extension as if it was part of the same object.
        display.__friend = friend
        -- REVIEW: For now each Display can have a single extension.
        if extensionName then
            display.__extension = addon:GetObject(extensionName .. "Extension")
        end
        return setmetatable(display, MT)
    end
end

do
    local MT = {
        __index = function(t, key)
            return Tooltip[key]
                    or Colorizer[key]
                    or rawget(t, "__root") and t.__root[key]
        end
    }

    function addon:NewExtension(name)
        local root = addon:GetObject(name)
        local extension = addon:NewObject(name .. "Extension")
        extension.__root = root
        return setmetatable(extension, MT)
    end
end
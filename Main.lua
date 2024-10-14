local addon = LibStub("Addon-1.0"):New(...)

local Tooltip = LibStub("Tooltip-1.0")

local Colorizer = addon.Colorizer

local ADDON_LOAD_FAILED = "<< %s >> " .. ADDON_LOAD_FAILED

local function TryLoadAddOn(name)
	local loaded, reason = C_AddOns.LoadAddOn(name)
	if not loaded and not reason then
        C_AddOns.LoadAddOn(name)
    elseif reason then
        local _, title = GetAddOnInfo(addon:GetName())
        title = NORMAL_FONT_COLOR:WrapTextInColorCode(title)
        local state = RED_FONT_COLOR:WrapTextInColorCode(_G["ADDON_" .. reason])
        print(YELLOW_FONT_COLOR:WrapTextInColorCode(ADDON_LOAD_FAILED:format(title, name, state)))
        return false
	end
    return true
end

function addon:OnInitialized()
    self.DB = LibStub("AceDB-3.0"):New("WowInfoDB", {}, true)
    SLASH_WOWINFO1 = "/wowinfo"
    SLASH_WOWINFO2 = "/wowi"
    SLASH_WOWINFO3 = "/wi"
    SlashCmdList["WOWINFO"] = function(input)
        if TryLoadAddOn("WowInfo_Options") then
            if not addon.__options then
                addon.__options = LibStub("AceOptions-1.0")
            end
            addon.__options:Open()
        end
    end
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

    function addon:NewTooltip(name, extensionName)
        local tooltip = addon:NewObject(name .. "Tooltip")
        local friend = addon:GetObject(name .. "Extension", true)
        -- When the Tooltip and the Extension have the same name they are considered friends,
        -- meaning, the Tooltip can access the Extension as if it was part of the same object.
        tooltip.__friend = friend
        -- REVIEW: For now each Tooltip can have a single extension.
        if extensionName then
            tooltip.__extension = addon:GetObject(extensionName .. "Extension")
        end
        return setmetatable(tooltip, MT)
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
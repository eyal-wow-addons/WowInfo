local addon = LibStub("Addon-1.0"):New(...)

local ADDON_LOAD_FAILED = "<< %s >> " .. ADDON_LOAD_FAILED

local function TryLoadAddOn(name)
	local loaded, reason = LoadAddOn(name)
	if not loaded and not reason then
        LoadAddOn(name)
    elseif reason then
        local _, title = GetAddOnInfo(addonName)
        title = NORMAL_FONT_COLOR:WrapTextInColorCode(title)
        local state = RED_FONT_COLOR:WrapTextInColorCode(_G["ADDON_" .. reason])
        print(YELLOW_FONT_COLOR:WrapTextInColorCode(ADDON_LOAD_FAILED:format(title, name, state)))
        return false
	end
    return true
end

function addon:OnInitialize()
    addon.DB = LibStub("AceDB-3.0"):New("WowInfoDB", {}, true)
    SLASH_WOWINFO1 = "/wowinfo"
    SLASH_WOWINFO2 = "/wowi"
    SLASH_WOWINFO2 = "/wi"
    SlashCmdList["WOWINFO"] = function(input)
        if TryLoadAddOn("WowInfo_Options") then
            HideUIPanel(GameMenuFrame)
            Settings.OpenToCategory("WowInfo")
            Settings.OpenToCategory("WowInfo")
        end
    end
end

function addon:NewDisplay(name)
    local obj = addon:NewObject(name .. "Display")
    return addon.WidgetUtils:CreateWidgetProxy(addon.Tooltip, obj)
end
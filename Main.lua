local addonName, addon = ...

local ADDON_LOAD_FAILED = YELLOW_FONT_COLOR:WrapTextInColorCode("<%s> " .. ADDON_LOAD_FAILED .. ".")

local function TryLoadAddOn(name)
	local loaded, reason = LoadAddOn(name)
	if not loaded and not reason then
        LoadAddOn(name)
    elseif reason then
        local _, title = GetAddOnInfo(addonName)
        print(ADDON_LOAD_FAILED:format(title, name, _G["ADDON_" .. reason]))
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
            InterfaceOptionsFrame_OpenToCategory("WowInfo")
            InterfaceOptionsFrame_OpenToCategory("WowInfo")
        end
    end
end

function addon:NewDisplay(name)
    local obj = addon:NewObject(name .. "Display")
    return addon.WidgetUtils:CreateWidgetProxy(addon.Tooltip, obj)
end
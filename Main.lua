local _, addon = ...

function addon:OnInitialize()
    addon.DB = LibStub("AceDB-3.0"):New("WowInfoDB", {}, true)
end

function addon:NewDisplay(name)
    local obj = addon:NewObject(name .. "Display")
    return addon.WidgetUtils:CreateWidgetProxy(addon.Tooltip, obj)
end
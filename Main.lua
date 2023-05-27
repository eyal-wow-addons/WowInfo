local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, "WowInfo")

function addon:OnInitialize()
    addon.DB = LibStub("AceDB-3.0"):New("WowInfoDB", {}, true)
end

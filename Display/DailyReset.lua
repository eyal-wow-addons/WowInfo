local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("DailyReset")
local Quests = addon.Quests

hooksecurefunc("GameTime_UpdateTooltip", function()
    Display:AddTitleDoubleLine(L["Daily Reset:"], Quests:GetResetTimeString())
    Display:Show()
end)
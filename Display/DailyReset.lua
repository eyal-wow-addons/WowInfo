local _, addon = ...
local Display = addon:NewDisplay("DailyReset")
local Quests = addon.Quests

local DAILY_RESET_LABEL = "Daily Reset:"

hooksecurefunc("GameTime_UpdateTooltip", function()
    Display:AddEmptyLine()
    Display:AddHighlightDoubleLine(DAILY_RESET_LABEL, Quests:GetResetTimeString())
    Display:Show()
end)
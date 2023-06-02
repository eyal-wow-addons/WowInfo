local _, addon = ...
local Display = addon:NewDisplay("DailyReset")
local Quest = addon.Quest

local DAILY_RESET_LABEL = "Daily Reset:"

hooksecurefunc("GameTime_UpdateTooltip", function()
    Display:AddEmptyLine()
    Display:AddHighlightDoubleLine(DAILY_RESET_LABEL, Quest:GetResetTime())
    Display:Show()
end)
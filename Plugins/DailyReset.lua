local _, addon = ...
local plugin = addon:NewPlugin("DailyReset", "AceHook-3.0")

local Quest = addon.Quest
local Tooltip = addon.Tooltip

local DAILY_RESET_LABEL = "Daily Reset:"

plugin:SecureHook("GameTime_UpdateTooltip", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightDoubleLine(DAILY_RESET_LABEL, Quest:GetResetTime())
    Tooltip:Show()
end)

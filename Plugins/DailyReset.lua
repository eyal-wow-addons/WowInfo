local _, addon = ...
local plugin = addon:NewPlugin("DailyReset", "AceHook-3.0")

local Tooltip = addon.Tooltip

local DAILY_RESET_LABEL = "Daily Reset:"

local interval = 1
local lastUpdate = 0

plugin:SecureHook("GameTime_UpdateTooltip", function()
    Tooltip:AddEmptyLine()

    local resetTime, maxCount = GetQuestResetTime(), 1
    if resetTime < 60 then
        -- interval = 1
    elseif resetTime < 3600 then
        -- interval = 60
    elseif resetTime % 3600 < 60 then
    else
        maxCount = 2
    end

    Tooltip:AddHighlightDoubleLine(DAILY_RESET_LABEL, SecondsToTime(resetTime, nil, nil, maxCount))
    Tooltip:Show()
end)

local _, addon = ...
local Quests = addon:GetObject("Quests")
local Tooltip = addon:NewTooltip("DailyReset")

local L = addon.L

hooksecurefunc("GameTime_UpdateTooltip", function()
    Tooltip
        :SetDoubleLine(L["Daily Reset:"], Quests:GetResetTimeString())
        :ToHeader()
        :Show()
end)
local _, addon = ...
local Quests = addon:GetObject("Quests")
local Display = addon:NewDisplay("DailyReset")

local L = addon.L

hooksecurefunc("GameTime_UpdateTooltip", function()
    Display
        :SetDoubleLine(L["Daily Reset:"], Quests:GetResetTimeString())
        :ToHeader()
        :Show()
end)
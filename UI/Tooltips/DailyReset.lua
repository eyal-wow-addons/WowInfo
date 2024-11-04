local _, addon = ...
local Quests = addon:GetObject("Quests")
local Tooltip = addon:NewTooltip("DailyReset")

local L = addon.L

Tooltip.target = {
    funcName = "GameTime_UpdateTooltip",
    func = function()
        Tooltip
            :SetDoubleLine(L["Daily Reset:"], Quests:GetResetTimeString())
            :ToHeader()
    end
}
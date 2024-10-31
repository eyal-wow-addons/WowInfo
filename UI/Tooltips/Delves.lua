local _, addon = ...
local Delves = addon:GetObject("Delves")
local Tooltip = addon:NewTooltip("Delves")

local L = addon.L

local PROGRESS_FORMAT = "%s / %s"

Tooltip.target = {
    button = LFDMicroButton,
    onEnter = function()
        --[[if not button:IsEnabled() then
            return
        end]]
    
        local delves = Delves:GetProgressInfo()
    
        if delves then
            Tooltip:AddFormattedHeader(DELVES_DASHBOARD_SEASON_TITLE, DELVES_LABEL, delves.expansion, delves.seasonNumber)
    
            Tooltip
                :SetLine(L["Delver's Journey"])
                :SetFormattedLine(PROGRESS_FORMAT, delves.currentValue, delves.maxValue)
                :SetHighlight()
                :ToLine()
    
            if delves.companionLevel > 0 then
                Tooltip
                    :SetLine(delves.companionName)
                    :SetFormattedLine(PROGRESS_FORMAT, delves.companionLevel, delves.companionMaxLevel)
                    :SetHighlight()
                    :ToLine()
            end
        end
    end
}
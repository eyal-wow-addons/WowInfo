local _, addon = ...
local Reputation = addon:GetObject("Reputation")
local Tooltip = addon:NewTooltip("Reputation")

local L = addon.L

local PROGRESS_FORMAT = "%s / %s"
local ICON_AVAILABLE_REWARD = " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"

Tooltip.target = {
    button = CharacterMicroButton,
    onEnter = function()
        if Reputation:HasTrackedFactions() then
            Tooltip:AddHeader(L["Reputation:"])
            local factionName, standingColor, prevHeaderName
            for faction, progressInfo in Reputation:IterableTrackedFactionsInfo() do
                if prevHeaderName ~= faction.headerName then
                    Tooltip:AddLine(faction.headerName)
                    prevHeaderName = faction.headerName
                end
    
                factionName = faction.name
                standingColor = FACTION_BAR_COLORS[progressInfo.standingID]
    
                if progressInfo.type == 1 then
                    -- Friendship Faction
                elseif progressInfo.type == 2 then
                    -- Paragon 
                    standingColor = LIGHTBLUE_FONT_COLOR
                elseif progressInfo.type == 3 then
                    -- Major Faction
                    standingColor = BLUE_FONT_COLOR
                end
    
                if progressInfo.hasReward then
                    factionName = factionName .. ICON_AVAILABLE_REWARD
                end
    
                Tooltip
                    :SetLine(factionName)
                    :Indent(4)
                    :SetColor(standingColor)
        
                if progressInfo.isCapped or IsShiftKeyDown() then
                    Tooltip:SetLine(progressInfo.standing)
                else
                    Tooltip:SetFormattedLine(PROGRESS_FORMAT, progressInfo.currentValue, progressInfo.maxValue)
                end
    
                Tooltip
                    :SetHighlight()
                    :ToLine()
            end
            Tooltip:Show()
        end
    end
}
local _, addon = ...
local Reputation = addon:GetObject("Reputation")
local Display = addon:NewDisplay("Reputation")

local L = addon.L

local PROGRESS_FORMAT = "%s / %s"
local ICON_AVAILABLE_REWARD = " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if Reputation:HasTrackedFactions() then
        Display:AddHeader(L["Reputation:"])
        local factionName, standingColor, prevHeaderName
        for info, progressInfo in Reputation:IterableTrackedFactionsInfo() do
            if prevHeaderName ~= info.headerName then
                Display:AddLine(info.headerName)
                prevHeaderName = info.headerName
            end

            factionName = info.factionName
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

            Display
                :SetLine(factionName)
                :Indent(4)
                :SetColor(standingColor)
    
            if progressInfo.isCapped or IsShiftKeyDown() then
                Display:SetLine(progressInfo.standing)
            else
                Display:SetFormattedLine(PROGRESS_FORMAT, progressInfo.currentValue, progressInfo.maxValue)
            end

            Display
                :SetHighlight()
                :ToLine()
        end
        Display:Show()
    end
end)

local _, addon = ...
local Reputation = addon:GetObject("Reputation")
local Display = addon:NewDisplay("Reputation")

local L = addon.L

local PROGRESS_FORMAT = "%s / %s"
local ICON_AVAILABLE_REWARD = " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if Reputation:HasTrackedFactions() then
        Display:AddHeader(L["Reputation:"])
        local factionName, standingColor
        for info in Reputation:IterableTrackedFactions() do
            factionName = info.factionName
            standingColor = FACTION_BAR_COLORS[info.standingID]

            if info.hasReward then
                factionName = factionName .. ICON_AVAILABLE_REWARD
            end

            if info.factionType == 1 then
                standingColor = LIGHTBLUE_FONT_COLOR
            elseif info.factionType == 2 then
                standingColor = BLUE_FONT_COLOR
                factionName = L["S (Renown X)"]:format(factionName, info.renownLevel)
            end

            Display
                :SetLine(factionName)
                :SetColor(standingColor)
    
            if isCapped then
                Display:SetLine(info.standing)
            else
                Display:SetFormattedLine(PROGRESS_FORMAT, info.progressValue, info.progressMax)
            end

            Display
                :SetHighlight()
                :ToLine()
        end
        Display:Show()
    end
end)

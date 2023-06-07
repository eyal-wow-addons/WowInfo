local _, addon = ...
local Display = addon:NewDisplay("Reputation")
local Reputation = addon.Reputation

local REPUTATION_LABEL = "Reputation:"

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    local isTitleAdded

    for factionName, standing, isCapped, progressString in Reputation:IterableTrackedFactions() do
        if not isTitleAdded then
            Display:AddEmptyLine()
            Display:AddHighlightLine(REPUTATION_LABEL)
            isTitleAdded = true
        end
        if isCapped then
            Display:AddRightHighlightDoubleLine(factionName, standing)
        else
            Display:AddRightHighlightDoubleLine(factionName, progressString)
        end
    end

    if isTitleAdded then
        Display:Show()
    end
end)

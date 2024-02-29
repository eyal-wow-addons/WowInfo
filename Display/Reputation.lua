local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Reputation")
local Reputation = addon.Reputation

Reputation:RegisterEvent("REPUTATION_SHOW_TRACKED_FACTIONS_PROGRESS", function()
    Display:AddTitleLine(L["Reputation:"], true)
end)

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    for factionName, standing, isCapped, progressString in Reputation:IterableTrackedFactions() do
        if isCapped then
            Display:AddRightHighlightDoubleLine(factionName, standing)
        else
            Display:AddRightHighlightDoubleLine(factionName, progressString)
        end
    end

    Display:Show()
end)

local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Reputation")
local Reputation = addon.Reputation

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    local isLabelAdded

    for factionName, standing, isCapped, progressString in Reputation:IterableTrackedFactions() do
        if not isLabelAdded then
            Display:AddTitleLine(L["Reputation:"])
            isLabelAdded = true
        end
        if isCapped then
            Display:AddRightHighlightDoubleLine(factionName, standing)
        else
            Display:AddRightHighlightDoubleLine(factionName, progressString)
        end
    end

    Display:Show()
end)

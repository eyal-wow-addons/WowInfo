local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Spellbook")
local Professions = addon.Professions

Professions:RegisterEvent("PROFESSIONS_SHOW_PROGRESS", function()
    Display:AddTitleLine(L["Professions:"], true)
end)

Display:RegisterHookScript(ProfessionMicroButton, "OnEnter", function()
    for nameString, icon, progressString in Professions:IterableProfessionInfo() do
        Display:AddRightHighlightDoubleLine(nameString, progressString)
        Display:AddIcon(icon)
    end

    Display:Show()
end)
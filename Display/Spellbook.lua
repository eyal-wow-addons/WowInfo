local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Spellbook")
local Professions = addon.Professions

local itemTextureSettings = {
    width = 20,
    height = 20,
    verticalOffset = 3,
    margin = { right = 5, bottom = 5 },
}

Professions:RegisterEvent("PROFESSIONS_SHOW_PROGRESS", function()
    Display:AddTitleLine(L["Professions:"], true)
end)

Display:RegisterHookScript(SpellbookMicroButton, "OnEnter", function()
    for nameString, icon, progressString in Professions:IterableProfessionInfo() do
        Display:AddRightHighlightDoubleLine(nameString, progressString)
        Display:AddTexture(icon, itemTextureSettings)
    end

    Display:Show()
end)
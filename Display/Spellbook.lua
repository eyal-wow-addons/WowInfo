local _, addon = ...
local Display = addon:NewDisplay("Spellbook")
local Professions = addon.Professions

local PROFESIONS_LABEL = TRADE_SKILLS .. ":"

local itemTextureSettings = {
    width = 20,
    height = 20,
    verticalOffset = 3,
    margin = { right = 5, bottom = 5 },
}

Display:RegisterHookScript(SpellbookMicroButton, "OnEnter", function()
    local isLabelAdded

    for nameString, icon, progressString in Professions:IterableProfessionInfo() do
        if not isLabelAdded then
            Display:AddEmptyLine()
            Display:AddHighlightLine(PROFESIONS_LABEL)
            isLabelAdded = true
        end
        Display:AddRightHighlightDoubleLine(nameString, progressString)
        Display:AddTexture(icon, itemTextureSettings)
    end

    Display:Show()
end)
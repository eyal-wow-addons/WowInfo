local _, addon = ...
local Display = addon:NewDisplay("Durability")
local Durability = addon.Durability

local DURABILITY_LABEL = "Durability:"
local DURABILITY_EQUIPPED_LABEL = "Equipped"
local DURABILITY_BAGS_LABEL = "Bags"

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    Display:AddEmptyLine()
    Display:AddHighlightLine(DURABILITY_LABEL)
    Display:AddDoubleLine(DURABILITY_EQUIPPED_LABEL, Durability:GetInventoryPercentageString())
    Display:AddDoubleLine(DURABILITY_BAGS_LABEL, Durability:GetBagsPercentageString())
    Display:Show()
end)

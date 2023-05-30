local _, addon = ...
local plugin = addon:NewPlugin("Durability")

local Durability = addon.Durability
local Tooltip = addon.Tooltip

local DURABILITY_LABEL = "Durability:"
local DURABILITY_EQUIPPED_LABEL = "Equipped"
local DURABILITY_BAGS_LABEL = "Bags"

plugin:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(DURABILITY_LABEL)
    Tooltip:AddDoubleLine(DURABILITY_EQUIPPED_LABEL, Durability:GetInventoryPercentageText())
    Tooltip:AddDoubleLine(DURABILITY_BAGS_LABEL, Durability:GetBagsPercentageText())
    Tooltip:Show()
end)

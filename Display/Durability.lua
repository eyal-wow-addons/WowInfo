local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Durability")
local Durability = addon.Durability

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    Display:AddTitleLine(L["Durability:"])
    Display:AddDoubleLine(L["Equipped"], Durability:GetInventoryPercentageString())
    Display:AddDoubleLine(L["Bags"], Durability:GetBagsPercentageString())
    Display:Show()
end)

local _, addon = ...
local Durability = addon:GetObject("Durability")
local Tooltip = addon:NewTooltip("Durability")

local L = addon.L

local function GetColoredString(percent)
    local r, g

    if percent >= 0.5 then
        r = (1 - percent) * 2
        g = 1
    else
        r = 1
        g = percent * 2
    end

    return ("|cff%02x%02x%02x%d%%|r"):format(r * 255, g * 255, 0, (percent * 100))
end

Tooltip:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    local inventoryPct, bagsPct = Durability:GetPercentages()

    inventoryPct = inventoryPct and GetColoredString(inventoryPct) or L["N/A"]
    bagsPct = bagsPct and GetColoredString(bagsPct) or L["None"]

    Tooltip:AddHeader(L["Durability:"])
    Tooltip:AddDoubleLine(L["Equipped"], inventoryPct)
    Tooltip:AddDoubleLine(L["Bags"], bagsPct)
    Tooltip:Show()
end)
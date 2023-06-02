local _, addon = ...
local Durability = addon:NewObject("Durability")

local NA_LABEL = "N/A"
local NONE_LABEL = "|cffa0a0a0None|r"

local NUM_BAG_FRAMES = 4

local SLOTS = {
    "HeadSlot",
    "ShoulderSlot",
    "ChestSlot",
    "WristSlot",
    "HandsSlot",
    "WaistSlot",
    "LegsSlot",
    "FeetSlot",
    "MainHandSlot",
    "SecondaryHandSlot"
}

local inventoryPct, bagsPct

local function GetPercentage(current, total)
    if current and total > 0 then
        local perc = current / total
        local fixed = perc
        -- Makes sure we never round down to 0 so we can distinguish between completely broken and fully functional
        if perc > 0 then
            fixed = max(0.01, perc)
        end
        return fixed, perc
    end
end

Durability:RegisterEvents(
    "UPDATE_INVENTORY_DURABILITY",
    "PLAYER_EQUIPMENT_CHANGED", function(eventName)
        local inventory, inventoryMax = 0, 0
        local bags, bagsMax = 0, 0

        for _, slot in ipairs(SLOTS) do
            local durability, durabilityMax = GetInventoryItemDurability(GetInventorySlotInfo(slot))
            if durability and durabilityMax then
                local _, exactPct = GetPercentage(durability, durabilityMax)
                -- Adds item durability values to total inventory durability value
                inventory = inventory + exactPct
                inventoryMax = inventoryMax + 1
            end
        end

        -- Scans bags items durability status
        for bag = 0, NUM_BAG_FRAMES do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local durability, durabilityMax = C_Container.GetContainerItemDurability(bag, slot)
                if durability then
                    bags = bags + durability
                    bagsMax = bagsMax + durabilityMax
                end
            end
        end

        inventoryPct = GetPercentage(inventory, inventoryMax)
        bagsPct = GetPercentage(bags, bagsMax)
    end)

local function GetColoredText(percent)
    local r, g

    if percent >= 0.5 then
        r = (1 - percent) * 2
        g = 1
    else
        r = 1
        g = percent * 2
    end

    return format("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, 0, (percent * 100))
end

function Durability:GetInventoryPercentageString()
    return inventoryPct and GetColoredText(inventoryPct) or NA_LABEL
end

function Durability:GetBagsPercentageString()
    return bagsPct and GetColoredText(bagsPct) or NONE_LABEL
end



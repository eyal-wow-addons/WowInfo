local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("PvE")
local PvE = addon.PvE

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function()
    Display:AddTitleLine(L["Dungeons & Raids:"])

    local isSaved

    for instanceNameString, isCleared, progressString in PvE:IterableInstanceInfo() do
        if isCleared then
            Display:AddDoubleLine(instanceNameString, progressString, nil, nil, nil, RED_FONT_COLOR:GetRGB())
        else
            Display:AddRightHighlightDoubleLine(instanceNameString, progressString)
        end
        isSaved = true
    end

    for bossName in PvE:IterableSavedWorldBossInfo() do
        Display:AddDoubleLine(bossName, L["Defeated"], nil, nil, nil, RED_FONT_COLOR:GetRGB())
        isSaved = true
    end

    if not isSaved then
        Display:AddLine(L["You are not saved to any instances."])
    end

    Display:Show()
end)

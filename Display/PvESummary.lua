local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("PvESummary")
local SavedBosses = addon.SavedBosses

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function()
    Display:AddTitleLine(L["Dungeons & Raids:"])

    local isSaved

    for instanceNameString, isCleared, progressString in SavedBosses:IterableInstanceInfo() do
        if isCleared then
            Display:AddDoubleLine(instanceNameString, progressString, nil, nil, nil, RED_FONT_COLOR:GetRGB())
        else
            Display:AddRightHighlightDoubleLine(instanceNameString, progressString)
        end
        isSaved = true
    end

    for bossName in SavedBosses:IterableWorldBossInfo() do
        Display:AddDoubleLine(bossName, L["Defeated"], nil, nil, nil, RED_FONT_COLOR:GetRGB())
        isSaved = true
    end

    if not isSaved then
        Display:AddLine(L["You are not saved to any instances."])
    end

    Display:Show()
end)

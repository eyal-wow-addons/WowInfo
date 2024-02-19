local _, addon = ...
local Display = addon:NewDisplay("PvESummary")
local SavedBosses = addon.SavedBosses

local PVE_SUMMARY_LABEL = "Dungeons & Raids:"

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function()
    Display:AddEmptyLine()
    Display:AddHighlightLine(PVE_SUMMARY_LABEL)

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
        Display:AddDoubleLine(bossName, BOSS_DEAD, nil, nil, nil, RED_FONT_COLOR:GetRGB())
        isSaved = true
    end

    if not isSaved then
        Display:AddLine(NO_RAID_INSTANCES_SAVED)
    end

    Display:Show()
end)

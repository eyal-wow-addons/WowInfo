local _, addon = ...
local PvE = addon:GetObject("PvE")
local Display = addon:NewDisplay("PvE")

local L = addon.L

local INSTANCE_NAME_FORMAT = "%s (%s)"
local INSTANCE_PROGRESS_FORMAT = "%d / %d"

Display:RegisterHookScript(LFDMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    Display:AddHeader(L["Dungeons & Raids:"])

    local isSaved

    for info in PvE:IterableInstanceInfo() do
        Display:SetFormattedLine(INSTANCE_NAME_FORMAT, info.name, info.difficulty)
        if info.isCleared then
            Display
                :SetLine(L["Cleared"])
                :SetRedColor()
        else
            Display:SetFormattedLine(INSTANCE_PROGRESS_FORMAT, Display:ToRed(info.defeatedBosses), Display:ToGreen(info.maxBosses))
        end
        Display:ToLine()
        isSaved = true
    end

    for info in PvE:IterableSavedWorldBossInfo() do
        Display
            :SetDoubleLine(info.name, L["Defeated"])
            :SetRedColor()
            :ToLine()
        isSaved = true
    end

    if not isSaved then
        Display:AddLine(L["You are not saved to any instances."])
    end

    Display:Show()
end)

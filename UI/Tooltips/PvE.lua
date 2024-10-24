local _, addon = ...
local PvE = addon:GetObject("PvE")
local Tooltip = addon:NewTooltip("PvE")

local L = addon.L

local INSTANCE_NAME_FORMAT = "%s (%s)"
local INSTANCE_PROGRESS_FORMAT = "%s / %s"

Tooltip:RegisterHookScript(LFDMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    Tooltip:AddHeader(L["Dungeons & Raids:"])

    local isSaved

    for instance in PvE:IterableInstanceInfo() do
        Tooltip:SetFormattedLine(INSTANCE_NAME_FORMAT, instance.name, instance.difficulty)
        if instance.isCleared then
            Tooltip
                :SetLine(L["Cleared"])
                :SetRedColor()
        else
            Tooltip:SetFormattedLine(INSTANCE_PROGRESS_FORMAT, Tooltip:ToRed(instance.defeatedBosses), Tooltip:ToGreen(instance.maxBosses))
        end
        Tooltip:ToLine()
        isSaved = true
    end

    for boss in PvE:IterableSavedWorldBossInfo() do
        Tooltip
            :SetDoubleLine(boss.name, L["Defeated"])
            :SetRedColor()
            :ToLine()
        isSaved = true
    end

    if not isSaved then
        Tooltip:AddLine(L["You are not saved to any instances."])
    end

    Tooltip:Show()
end)

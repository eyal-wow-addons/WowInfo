local _, addon = ...
local PvE = addon:GetObject("PvE")
local Tooltip = addon:NewTooltip("PvE")

local L = addon.L

local INSTANCE_NAME_FORMAT = "%s (%s)"
local INSTANCE_PROGRESS_FORMAT = "%d / %d"

Tooltip:RegisterHookScript(LFDMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    Tooltip:AddHeader(L["Dungeons & Raids:"])

    local isSaved

    for info in PvE:IterableInstanceInfo() do
        Tooltip:SetFormattedLine(INSTANCE_NAME_FORMAT, info.name, info.difficulty)
        if info.isCleared then
            Tooltip
                :SetLine(L["Cleared"])
                :SetRedColor()
        else
            Tooltip:SetFormattedLine(INSTANCE_PROGRESS_FORMAT, Tooltip:ToRed(info.defeatedBosses), Tooltip:ToGreen(info.maxBosses))
        end
        Tooltip:ToLine()
        isSaved = true
    end

    for info in PvE:IterableSavedWorldBossInfo() do
        Tooltip
            :SetDoubleLine(info.name, L["Defeated"])
            :SetRedColor()
            :ToLine()
        isSaved = true
    end

    if not isSaved then
        Tooltip:AddLine(L["You are not saved to any instances."])
    end

    Tooltip:Show()
end)

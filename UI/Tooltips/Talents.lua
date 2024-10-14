local _, addon = ...
local Talents = addon:GetObject("Talents")
local Tooltip = addon:NewTooltip("Talents")

local L = addon.L

local TALENTS_LOADOUT_SHARED_ACTION_BARS = "%s*"

Tooltip:RegisterHookScript(PlayerSpellsMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    local spec = Talents:GetCurrentSpec()

    if spec then
        Tooltip:AddFormattedHeader(L["Specialization: S"], Tooltip:ToPlayerClassColor(spec))
    end

    if Talents:HasLoadouts() then
        Tooltip:AddHeader(L["Loadouts:"])

        Tooltip:SetLine(TALENT_FRAME_DROP_DOWN_STARTER_BUILD)
        if Talents:IsStarterBuildActive() then
            Tooltip:SetGreenColor()
        else
            Tooltip:SetGrayColor()
        end
        Tooltip:ToLine()

        for info in Talents:IterableLoadoutsInfo() do
            if info and info.name then
                local name = info.name
                if info.usesSharedActionBars then
                    name = TALENTS_LOADOUT_SHARED_ACTION_BARS:format(name)
                end
                Tooltip:SetLine(name)
                if info.isActive then
                    Tooltip:SetGreenColor()
                else
                    Tooltip:SetGrayColor()
                end
                Tooltip:ToLine()
            end
        end
    end

    if Talents:HasPvpTalents() then
        Tooltip:AddHeader(L["PvP Talents:"])

        for name, icon in Talents:IteratablePvpTalents() do
            Tooltip:AddLine(name)
            Tooltip:AddIcon(icon)
        end
    end

    Tooltip:Show()
end)
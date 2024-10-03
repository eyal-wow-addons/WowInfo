local _, addon = ...
local Talents = addon:GetObject("Talents")
local Display = addon:NewDisplay("Talents")

local L = addon.L

local TALENTS_LOADOUT_SHARED_ACTION_BARS = "%s*"

Display:RegisterHookScript(PlayerSpellsMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    local spec = Talents:GetCurrentSpec()

    if spec then
        Display:AddFormattedHeader(L["Specialization: S"], Display:ToPlayerClassColor(spec))
    end

    if Talents:HasLoadouts() then
        Display:AddHeader(L["Loadouts:"])

        Display:SetLine(TALENT_FRAME_DROP_DOWN_STARTER_BUILD)
        if Talents:IsStarterBuildActive() then
            Display:SetGreenColor()
        else
            Display:SetGrayColor()
        end
        Display:ToLine()

        for info in Talents:IterableLoadoutsInfo() do
            if info and info.name then
                local name = info.name
                if info.usesSharedActionBars then
                    name = TALENTS_LOADOUT_SHARED_ACTION_BARS:format(name)
                end
                Display:SetLine(name)
                if info.isActive then
                    Display:SetGreenColor()
                else
                    Display:SetGrayColor()
                end
                Display:ToLine()
            end
        end
    end

    if Talents:HasPvpTalents() then
        Display:AddHeader(L["PvP Talents:"])

        for name, icon in Talents:IteratablePvpTalents() do
            Display:AddLine(name)
            Display:AddIcon(icon)
        end
    end

    Display:Show()
end)
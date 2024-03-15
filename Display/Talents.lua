local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Talents")
local Talents = addon.Talents

local TALENTS_LOADOUT_SHARED_ACTION_BARS = "%s*"

Talents:RegisterEvent("TALENTS_SHOW_LOADOUTS", function()
    Display:AddTitleLine(L["Loadouts:"], true)
end)

Talents:RegisterEvent("TALENTS_SHOW_PVP_TALENTS", function()
    Display:AddTitleLine(L["PvP Talents:"], true)
end)

Display:RegisterHookScript(TalentMicroButton, "OnEnter", function()
    if not PlayerUtil.CanUseClassTalents() then
        return
    end

    local spec = Talents:GetSpecString()

    if spec then
        Display:AddTitleLine(L["Specialization: S"]:format(spec))
    end

    local starterBuildName, isStarterBuildActive = Talents:GetStarterBuildInfo()

    if starterBuildName then
        if isStarterBuildActive then
            Display:AddGreenLine(starterBuildName)
        else
            Display:AddGrayLine(starterBuildName)
        end
    end

    for configInfo, isActive in Talents:IterableLoadoutsInfo() do
        local name = configInfo.name
        if configInfo.usesSharedActionBars then
            name = TALENTS_LOADOUT_SHARED_ACTION_BARS:format(name)
        end
        if isActive then
            Display:AddGreenLine(name)
        else
            Display:AddGrayLine(name)
        end
    end

    for name, icon in Talents:IteratablePvPTalents() do
        Display:AddLine(name)
        Display:AddIcon(icon)
    end

    Display:Show()
end)
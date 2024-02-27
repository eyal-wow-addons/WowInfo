local _, addon = ...
local Display = addon:NewDisplay("Talents")
local Talents = addon.Talents

local TALENTS_SPEC_LABEL = "Specialization: %s"
local TALENTS_LOADOUTS_TITLE = "Loadouts:"
local TALENTS_LOADOUT_SHARED_ACTION_BARS_FORMAT = "%s*"
local TALENTS_PVP_TALENTS_TITLE = "PvP Talents:"

local itemTextureSettings = {
    width = 20,
    height = 20,
    verticalOffset = 3,
    margin = { right = 5, bottom = 5 },
}

Talents:RegisterEvent("TALENTS_SHOW_LOADOUTS", function()
    Display:AddTitleLine(TALENTS_LOADOUTS_TITLE, true)
end)

Talents:RegisterEvent("TALENTS_SHOW_PVP_TALENTS", function()
    Display:AddTitleLine(TALENTS_PVP_TALENTS_TITLE, true)
end)

Display:RegisterHookScript(TalentMicroButton, "OnEnter", function()
    if not PlayerUtil.CanUseClassTalents() then
        return
    end

    local spec = Talents:GetSpecString()

    if spec then
        Display:AddEmptyLine()
        Display:AddHighlightLine(TALENTS_SPEC_LABEL:format(spec))
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
            name = TALENTS_LOADOUT_SHARED_ACTION_BARS_FORMAT:format(name)
        end
        if isActive then
            Display:AddGreenLine(name)
        else
            Display:AddGrayLine(name)
        end
    end

    for name, icon in Talents:IteratablePvPTalents() do
        Display:AddLine(name)
        Display:AddTexture(icon, itemTextureSettings)
    end

    Display:Show()
end)
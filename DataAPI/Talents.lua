local _, addon = ...
local Talents = addon:NewObject("Talents")

function Talents:GetSpecString()
    local _, classFilename = UnitClass("player")
    local specString
    local currentSpecID = PlayerUtil.GetCurrentSpecID()

    for i = 1, GetNumSpecializations() do
        local id, name = GetSpecializationInfo(i)
        if id == currentSpecID then
            local classColor = RAID_CLASS_COLORS[classFilename]
            specString = WrapTextInColor(name, classColor)
            break
        end
    end

    return specString
end

function Talents:IterableLoadoutsInfo()
    local i = 0
    local specID = specID or PlayerUtil.GetCurrentSpecID()
    local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
    local n = configIDs and #configIDs or 0
    if n > 0 then
        self:TriggerEvent("TALENTS_SHOW_LOADOUTS")
    end
    return function()
        i = i + 1
        if i <= n then
            local isActive = false
            local configID = configIDs[i]
            local configInfo = C_Traits.GetConfigInfo(configID)
            local lastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
            if configID == lastSelectedSavedConfigID then
                isActive = true
            end
            return configInfo, isActive
        end
    end
end

function Talents:GetStarterBuildInfo()
    local hasStarterBuild = C_ClassTalents.GetHasStarterBuild()
    if hasStarterBuild then
        self:TriggerEvent("TALENTS_SHOW_LOADOUTS")
        return TALENT_FRAME_DROP_DOWN_STARTER_BUILD, C_ClassTalents.GetStarterBuildActive()
    end
end

function Talents:IteratablePvPTalents()
    local i = 0
    local t = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
    local n = #t
    if n > 0 then
        self:TriggerEvent("TALENTS_SHOW_PVP_TALENTS")
    end
    return function()
        i = i + 1
        if i <= n then
            local talentID = t[i]
            local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
            return name, icon, unlocked
        end
    end
end
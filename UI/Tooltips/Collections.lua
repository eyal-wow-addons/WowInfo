local _, addon = ...
local Collections = addon:GetObject("Collections")
local Achievements = addon:GetObject("Achievements")
local Tooltip = addon:NewTooltip("Collections")

local L = addon.L

local ACHIEVEMENT_LINE_FORMAT = "- %s: |cffffffff%d|r / |cff20ff20%d|r"

function Tooltip:AddAchievementLine(callback)
    local name, currAmount, reqAmount = callback()
    if name then
        self:AddFormattedLine(ACHIEVEMENT_LINE_FORMAT, name, currAmount, reqAmount)
    end
    return self
end

Tooltip:RegisterHookScript(CollectionsMicroButton, "OnEnter", function()
    local totalMounts = Collections:GetTotalMounts()
    if totalMounts  then
        Tooltip
            :AddFormattedHeader(L["Mounts: X"], totalMounts)
            :AddAchievementLine(Achievements.GetMountAchievementInfo)
    end

    local totalPets = Collections:GetTotalPets()
    if totalPets then
        Tooltip
            :AddFormattedHeader(L["Pets: X"], totalPets)
            :AddAchievementLine(Achievements.GetPetsAchievementInfo)
    end

    local totalLearnedToys, totalToys = Collections:GetTotalToys()
    if totalLearnedToys then
        Tooltip
            :AddFormattedHeader(L["Toys: X / Y"], totalLearnedToys, totalToys)
            :AddAchievementLine(Achievements.GetToysAchievementInfo)
    end

    Tooltip:Show()
end)


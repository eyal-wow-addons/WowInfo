local _, addon = ...
local L = addon.L
local Collections = addon:GetObject("Collections")
local Achievements = addon:GetObject("Achievements")
local Display = addon:NewDisplay("Collections")

local COLLECTIONS_LABEL_FORMAT = "- %s: |cffffffff%d|r / |cff20ff20%d|r"

function Display:AddAchievementLine(callback)
    local name, currAmount, reqAmount = callback()
    if name then
        self:AddFormattedLine(COLLECTIONS_LABEL_FORMAT, name, currAmount, reqAmount)
    end
    return self
end

Display:RegisterHookScript(CollectionsMicroButton, "OnEnter", function()
    local totalMounts = Collections:GetTotalMounts()
    if totalMounts  then
        Display
            :AddFormattedHeader(L["Mounts: X"], totalMounts)
            :AddAchievementLine(Achievements.GetMountAchievementInfo)
    end

    local totalPets = Collections:GetTotalPets()
    if totalPets then
        Display
            :AddFormattedHeader(L["Pets: X"], totalPets)
            :AddAchievementLine(Achievements.GetPetsAchievementInfo)
    end

    local totalLearnedToys, totalToys = Collections:GetTotalToys()
    if totalLearnedToys then
        Display
            :AddFormattedHeader(L["Toys: X / Y"], totalLearnedToys, totalToys)
            :AddAchievementLine(Achievements.GetToysAchievementInfo)
    end

    Display:Show()
end)


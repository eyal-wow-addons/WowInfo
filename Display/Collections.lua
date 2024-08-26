local _, addon = ...
local L = addon.L
local Collections = addon:GetObject("Collections")
local Achievements = addon:GetObject("Achievements")
local Display = addon:NewDisplay("Collections")

local COLLECTIONS_LABEL_FORMAT = "- %s: |cffffffff%d|r / |cff20ff20%d|r"

function Display:AddAchievementLine(callback)
    local name, currAmount, reqAmount = callback
    if name then
        self:AddLine(COLLECTIONS_LABEL_FORMAT:format(name, currAmount, reqAmount))
    end
end

Display:RegisterHookScript(CollectionsMicroButton, "OnEnter", function()
    local totalMounts = Collections:GetTotalMounts()
    if totalMounts  then
        Display:AddHeader(L["Mounts: X"]:format(totalMounts))
        Display:AddAchievementLine(Achievements.GetMountAchievementInfo)
    end

    local totalPets = Collections:GetTotalPets()
    if totalPets then
        Display:AddHeader(L["Pets: X"]:format(totalPets))
        Display:AddAchievementLine(Achievements.GetPetsAchievementInfo)
    end

    local totalLearnedToys, totalToys = Collections:GetTotalToys()
    if totalLearnedToys then
        Display:AddHeader(L["Toys: X / Y"]:format(totalLearnedToys, totalToys))
        Display:AddAchievementLine(Achievements.GetToysAchievementInfo)
    end

    Display:Show()
end)


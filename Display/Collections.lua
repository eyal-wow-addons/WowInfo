local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Collections")
local Collections = addon.Collections
local Achievements = addon.Achievements

Display:RegisterHookScript(CollectionsMicroButton, "OnEnter", function()
    local totalMounts = Collections:GetTotalMounts()
    if totalMounts  then
        local achievementString = Achievements:GetMountAchievementString()
        Display:AddTitleLine(L["Mounts: X"]:format(totalMounts))
        if achievementString then
            Display:AddLine(achievementString)
        end
    end

    local totalPets = Collections:GetTotalPets()
    if totalPets then
        local achievementString = Achievements:GetPetsAchievementString()
        Display:AddTitleLine(L["Pets: X"]:format(totalPets))
        if achievementString then
            Display:AddLine(achievementString)
        end
    end

    local totalLearnedToys, totalToys = Collections:GetTotalToys()
    if totalLearnedToys then
        local achievementString = Achievements:GetToysAchievementString()
        Display:AddTitleLine(L["Toys: X / Y"]:format(totalLearnedToys, totalToys))
        if achievementString then
            Display:AddLine(achievementString)
        end
    end

    Display:Show()
end)


local _, addon = ...
local Display = addon:NewDisplay("Collections")
local Collections = addon.Collections
local Achievements = addon.Achievements

Display:RegisterHookScript(CollectionsMicroButton, "OnEnter", function()
    Display:AddEmptyLine()

    local totalMountsString = Collections:GetTotalMountsString()
    if totalMountsString  then
        local achievementString = Achievements:GetMountAchievementString()
        Display:AddLine(totalMountsString)
        if achievementString then
            Display:AddLine(achievementString)
        end
    end

    local totalPetsString = Collections:GetTotalPetsString()
    if totalPetsString then
        local achievementString = Achievements:GetPetsAchievementString()
        Display:AddEmptyLine()
        Display:AddLine(totalPetsString)
        if achievementString then
            Display:AddLine(achievementString)
        end
    end

    local totalToysString = Collections:GetTotalToysString()
    if totalToysString then
        local achievementString = Achievements:GetToysAchievementString()
        Display:AddEmptyLine()
        Display:AddLine(totalToysString)
        if achievementString then
            Display:AddLine(achievementString)
        end
    end

    Display:Show()
end)


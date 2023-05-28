local _, addon = ...
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip
local Collections = addon.Collections
local Achievements = addon.Achievements

ScriptLoader:AddHookScript(CollectionsMicroButton, "OnEnter", function()
    Tooltip:AddEmptyLine()

    local totalMountsString = Collections:GetTotalMountsString()
    if totalMountsString  then
        local achievementString = Achievements:GetMountAchievementString()
        Tooltip:AddLine(totalMountsString)
        if achievementString then
            Tooltip:AddLine(achievementString)
        end
    end

    local totalPetsString = Collections:GetTotalPetsString()
    if totalPetsString then
        local achievementString = Achievements:GetPetsAchievementString()
        Tooltip:AddEmptyLine()
        Tooltip:AddLine(totalPetsString)
        if achievementString then
            Tooltip:AddLine(achievementString)
        end
    end

    local totalToysString = Collections:GetTotalToysString()
    if totalToysString then
        local achievementString = Achievements:GetToysAchievementString()
        Tooltip:AddEmptyLine()
        Tooltip:AddLine(totalToysString)
        if achievementString then
            Tooltip:AddLine(achievementString)
        end
    end

    Tooltip:Show()
end)


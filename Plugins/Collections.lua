local _, addon = ...
local plugin = addon:NewPlugin("Collections")

local Tooltip = addon.Tooltip
local Collections = addon.Collections
local Achievements = addon.Achievements

plugin:RegisterHookScript(CollectionsMicroButton, "OnEnter", function()
    Tooltip:AddEmptyLine()

    local totalMountsText = Collections:GetTotalMountsText()
    if totalMountsText  then
        local achievementText = Achievements:GetMountAchievementText()
        Tooltip:AddLine(totalMountsText)
        if achievementText then
            Tooltip:AddLine(achievementText)
        end
    end

    local totalPetsText = Collections:GetTotalPetsText()
    if totalPetsText then
        local achievementText = Achievements:GetPetsAchievementText()
        Tooltip:AddEmptyLine()
        Tooltip:AddLine(totalPetsText)
        if achievementText then
            Tooltip:AddLine(achievementText)
        end
    end

    local totalToysText = Collections:GetTotalToysText()
    if totalToysText then
        local achievementText = Achievements:GetToysAchievementText()
        Tooltip:AddEmptyLine()
        Tooltip:AddLine(totalToysText)
        if achievementText then
            Tooltip:AddLine(achievementText)
        end
    end

    Tooltip:Show()
end)


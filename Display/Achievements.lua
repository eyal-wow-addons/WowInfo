local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Achievements")
local Achievements = addon.Achievements
local MicroMenu = addon.MicroMenu

Display:RegisterHookScript(AchievementMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    if MicroMenu:SetButtonTooltip(self, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT") then
        return
    end

    Display:AddTitleLine(L["Summary:"])
    Display:AddRightHighlightDoubleLine(Achievements:GetSummaryProgressString())
    Display:AddEmptyLine()

    for categoryName, progressString in Achievements:IterableCategoriesSummaryInfo() do
        Display:AddRightHighlightDoubleLine(categoryName, progressString)
    end

    if IsInGuild() then
        Display:AddTitleLine(L["Guild:"])
        Display:AddRightHighlightDoubleLine(Achievements:GetSummaryProgressString(true))
        Display:AddEmptyLine()

        for categoryName, progressString in Achievements:IterableCategoriesSummaryInfo(true) do
            Display:AddRightHighlightDoubleLine(categoryName, progressString)
        end
    end

    Display:Show()
end)
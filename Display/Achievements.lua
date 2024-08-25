local _, addon = ...
local L = addon.L
local MicroMenu = addon:GetObject("MicroMenu")
local Achievements = addon:GetObject("Achievements")
local Display = addon:NewDisplay("Achievements")

function Display:AddAchievementSummaryProgressLine(guildOnly)
    local total, completed = Achievements:GetSummaryProgressInfo(guildOnly)
    if not guildOnly then
        self:AddHeader(L["Summary:"])
    else
        self:AddHeader(L["Guild:"])
    end
    self:AddRightHighlightDoubleLine(ACHIEVEMENTS_COMPLETED, addon.PATTERNS.PROGRESS:format(completed, total))
    self:AddEmptyLine()
end

function Display:AddAchievementCategoriesSummaryInfo(guildOnly)
    local progressString
    for categoryName, total, completed in Achievements:IterableCategoriesSummaryInfo(guildOnly) do
        progressString = addon.PATTERNS.PROGRESS:format(completed, total)
        Display:AddRightHighlightDoubleLine(categoryName, progressString)
    end
end

Display:RegisterHookScript(AchievementMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    if MicroMenu:SetButtonTooltip(self, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT") then
        return
    end

    Display:AddAchievementSummaryProgressLine()
    Display:AddAchievementCategoriesSummaryInfo()

    if IsInGuild() then
        Display:AddAchievementSummaryProgressLine(true)
        Display:AddAchievementCategoriesSummaryInfo(true)
    end

    Display:Show()
end)
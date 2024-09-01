local _, addon = ...
local Achievements = addon:GetObject("Achievements")
local Display = addon:NewDisplay("Achievements")

local L = addon.L
local MicroMenu = addon.MicroMenu

function Display:AddAchievementSummaryProgressLine(guildOnly)
    local total, completed = Achievements:GetSummaryProgressInfo(guildOnly)

    if not guildOnly then
        self:AddHeader(L["Summary:"])
    else
        self:AddHeader(L["Guild:"])
    end

    self:SetLine(ACHIEVEMENTS_COMPLETED)
        :SetFormattedLine(addon.PATTERNS.PROGRESS, completed, total)
        :SetHighlight()
        :ToLine()
        :AddEmptyLine()
end

function Display:AddAchievementCategoriesSummaryInfo(guildOnly)
    for categoryName, total, completed in Achievements:IterableCategoriesSummaryInfo(guildOnly) do
        self:SetLine(categoryName)
            :SetFormattedLine(addon.PATTERNS.PROGRESS, completed, total)
            :SetHighlight()
            :ToLine()
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
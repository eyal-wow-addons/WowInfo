local _, addon = ...
local Achievements = addon:GetObject("Achievements")
local Display = addon:NewDisplay("Achievements")

local L = addon.L
local MicroMenu = addon.MicroMenu

local PROGRESS_FORMAT = "%s / %s"

function Display:AddAchievementSummaryProgressLine(guildOnly)
    local total, completed = Achievements:GetSummaryProgressInfo(guildOnly)

    total = BreakUpLargeNumbers(total)
    completed = BreakUpLargeNumbers(completed)

    if not guildOnly then
        self:AddHeader(L["Summary:"])
    else
        self:AddHeader(L["Guild:"])
    end

    self:SetLine(ACHIEVEMENTS_COMPLETED)
        :SetFormattedLine(PROGRESS_FORMAT, completed, total)
        :SetHighlight()
        :ToLine()
        :AddEmptyLine()
end

function Display:AddAchievementCategoriesSummaryInfo(guildOnly)
    for categoryName, total, completed in Achievements:IterableCategoriesSummaryInfo(guildOnly) do

        total = BreakUpLargeNumbers(total)
        completed = BreakUpLargeNumbers(completed)
        
        self:SetLine(categoryName)
            :SetFormattedLine(PROGRESS_FORMAT, completed, total)
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
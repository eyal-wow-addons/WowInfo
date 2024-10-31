local _, addon = ...
local Achievements = addon:GetObject("Achievements")
local Tooltip = addon:NewTooltip("Achievements")

local L = addon.L
local MicroMenu = addon.MicroMenu

local PROGRESS_FORMAT = "%s / %s"

function Tooltip:AddAchievementSummaryProgressLine(guildOnly)
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

function Tooltip:AddAchievementCategoriesSummaryInfo(guildOnly)
    for categoryName, total, completed in Achievements:IterableCategoriesSummaryInfo(guildOnly) do

        total = BreakUpLargeNumbers(total)
        completed = BreakUpLargeNumbers(completed)
        
        self:SetLine(categoryName)
            :SetFormattedLine(PROGRESS_FORMAT, completed, total)
            :SetHighlight()
            :ToLine()
    end
end

Tooltip.target = {
    button = AchievementMicroButton,
    onEnter = function()
        --[[if not button:IsEnabled() then
            return
        end
    
        if MicroMenu:SetButtonTooltip(button, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT") then
            return
        end]]
    
        Tooltip:AddAchievementSummaryProgressLine()
        Tooltip:AddAchievementCategoriesSummaryInfo()
    
        if IsInGuild() then
            Tooltip:AddAchievementSummaryProgressLine(true)
            Tooltip:AddAchievementCategoriesSummaryInfo(true)
        end
    
        Tooltip:Show()
    end
}
local _, addon = ...
local Display = addon:NewDisplay("Achievements")
local Achievements = addon.Achievements

local ACHIEVEMENT_SUMMARY_CATEGORY = ACHIEVEMENT_SUMMARY_CATEGORY .. ":"
local ACHIEVEMENTS_GUILD_TAB = ACHIEVEMENTS_GUILD_TAB .. ":"

Display:RegisterHookScript(AchievementMicroButton, "OnEnter", function()
    Display:AddEmptyLine()

    Display:AddHighlightLine(ACHIEVEMENT_SUMMARY_CATEGORY)
    Display:AddRightHighlightDoubleLine(Achievements:GetSummaryProgressString())
    Display:AddEmptyLine()

    for categoryName, progressString in Achievements:IterableCategoriesSummaryInfo() do
        Display:AddRightHighlightDoubleLine(categoryName, progressString)
    end

    if IsInGuild() then
        Display:AddEmptyLine()
        Display:AddHighlightLine(ACHIEVEMENTS_GUILD_TAB)
        Display:AddRightHighlightDoubleLine(Achievements:GetSummaryProgressString(true))
        Display:AddEmptyLine()

        for categoryName, progressString in Achievements:IterableCategoriesSummaryInfo(true) do
            Display:AddRightHighlightDoubleLine(categoryName, progressString)
        end
    end

    Display:Show()
end)


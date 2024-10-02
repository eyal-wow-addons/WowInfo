local _, addon = ...
local Professions = addon:GetObject("Professions")
local Display = addon:NewDisplay("Spellbook")

local L = addon.L

local PROFESIONS_RANK_FORMAT = "%d / %d"
local PROFESIONS_RANK_WITH_MODIFIER_FORMAT = "%d |cff20ff20+ %d|r / %d"
local PROFESIONS_LABEL_FORMAT = "%s - %s"

Display:RegisterHookScript(ProfessionMicroButton, "OnEnter", function()
    if Professions:HasProfessions() then
        Display:AddHeader(L["Professions:"])

        for info in Professions:IterableProfessionInfo() do
            Display:SetFormattedLine(PROFESIONS_LABEL_FORMAT, info.name, info.skillTitle)

            if info.skillModifier > 0 then
                Display:SetFormattedLine(PROFESIONS_RANK_WITH_MODIFIER_FORMAT, info.skillLevel, info.skillModifier, info.skillMaxLevel)
            else
                Display:SetFormattedLine(PROFESIONS_RANK_FORMAT, info.skillLevel, info.skillMaxLevel)
            end

            Display
                :SetHighlight()
                :ToLine()

            Display:AddIcon(info.icon)
        end

        Display:Show()
    end
end)
local _, addon = ...
local Professions = addon:GetObject("Professions")
local Tooltip = addon:NewTooltip("Spellbook")

local L = addon.L

local PROFESIONS_RANK_FORMAT = "%d / %d"
local PROFESIONS_RANK_WITH_MODIFIER_FORMAT = "%d |cff20ff20+ %d|r / %d"
local PROFESIONS_LABEL_FORMAT = "%s - %s"

Tooltip:RegisterHookScript(ProfessionMicroButton, "OnEnter", function()
    if Professions:HasProfessions() then
        Tooltip:AddHeader(L["Professions:"])

        for info in Professions:IterableProfessionInfo() do
            Tooltip:SetFormattedLine(PROFESIONS_LABEL_FORMAT, info.name, info.skillTitle)

            if info.skillModifier > 0 then
                Tooltip:SetFormattedLine(PROFESIONS_RANK_WITH_MODIFIER_FORMAT, info.skillLevel, info.skillModifier, info.skillMaxLevel)
            else
                Tooltip:SetFormattedLine(PROFESIONS_RANK_FORMAT, info.skillLevel, info.skillMaxLevel)
            end

            Tooltip
                :SetHighlight()
                :ToLine()

            Tooltip:AddIcon(info.icon)
        end

        Tooltip:Show()
    end
end)
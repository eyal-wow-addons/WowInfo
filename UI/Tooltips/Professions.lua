local _, addon = ...
local Professions = addon:GetObject("Professions")
local Tooltip = addon:NewTooltip("Spellbook")

local L = addon.L

local PROFESIONS_RANK_FORMAT = "%d / %d"
local PROFESIONS_RANK_WITH_MODIFIER_FORMAT = "%d |cff20ff20+ %d|r / %d"
local PROFESIONS_LABEL_FORMAT = "%s - %s"

Tooltip.target = {
    button = ProfessionMicroButton,
    onEnter = function()
        if Professions:HasProfessions() then
            Tooltip:AddHeader(L["Professions:"])
    
            for prof in Professions:IterableProfessionInfo() do
                Tooltip:SetFormattedLine(PROFESIONS_LABEL_FORMAT, prof.name, prof.skillTitle)
    
                if prof.skillModifier > 0 then
                    Tooltip:SetFormattedLine(PROFESIONS_RANK_WITH_MODIFIER_FORMAT, prof.skillLevel, prof.skillModifier, prof.skillMaxLevel)
                else
                    Tooltip:SetFormattedLine(PROFESIONS_RANK_FORMAT, prof.skillLevel, prof.skillMaxLevel)
                end
    
                Tooltip
                    :SetHighlight()
                    :ToLine()
    
                Tooltip:AddIcon(prof.icon)
            end
    
            Tooltip:Show()
        end
    end
}
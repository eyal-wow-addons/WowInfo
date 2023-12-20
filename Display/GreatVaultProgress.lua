local _, addon = ...
local Display = addon:NewDisplay("GreatVaultProgress")
local WeeklyRewards = addon.WeeklyRewards

local GREAT_VAULT_REWARDS_LABEL = GREAT_VAULT_REWARDS .. ":"
local GREAT_VAULT_HAS_REWARDS_DESC_COLOR = "ff19ff19"

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if IsPlayerAtEffectiveMaxLevel() then
        Display:AddEmptyLine()
        Display:AddHighlightLine(GREAT_VAULT_REWARDS_LABEL)

        if C_WeeklyRewards.HasAvailableRewards() then
            Display:AddHighlightLine(WrapTextInColorCode(GREAT_VAULT_REWARDS_WAITING, GREAT_VAULT_HAS_REWARDS_DESC_COLOR))
        end

        Display:AddGrayDoubleLine(WeeklyRewards:GetGreatVaultRaidProgressString())
        Display:AddGrayDoubleLine(WeeklyRewards:GetGreatVaultActivitiesProgressString())
        Display:AddGrayDoubleLine(WeeklyRewards:GetGreatVaultPvPProgressString())

        Display:Show()
    end
end)

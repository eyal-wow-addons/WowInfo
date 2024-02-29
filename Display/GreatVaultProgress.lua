local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("GreatVaultProgress")
local WeeklyRewards = addon.WeeklyRewards

local GREAT_VAULT_HAS_REWARDS_DESC_COLOR = "ff19ff19"

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if IsPlayerAtEffectiveMaxLevel() then
        Display:AddTitleLine(L["Great Vault Rewards:"])

        if C_WeeklyRewards.HasAvailableRewards() then
            Display:AddHighlightLine(WrapTextInColorCode(L["You have rewards waiting for you at the Great Vault."], GREAT_VAULT_HAS_REWARDS_DESC_COLOR))
        end

        Display:AddGrayDoubleLine(WeeklyRewards:GetGreatVaultRaidProgressString())
        Display:AddGrayDoubleLine(WeeklyRewards:GetGreatVaultActivitiesProgressString())
        Display:AddGrayDoubleLine(WeeklyRewards:GetGreatVaultPvPProgressString())

        Display:Show()
    end
end)

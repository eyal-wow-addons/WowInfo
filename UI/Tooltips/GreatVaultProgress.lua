local _, addon = ...
local WeeklyRewards = addon:GetObject("WeeklyRewards")
local Tooltip = addon:NewTooltip("GreatVaultProgress")

local L = addon.L

local GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR = CreateColorFromRGBHexString("14b200")
local GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR = CreateColorFromRGBHexString("0091f2")
local GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR = CreateColorFromRGBHexString("c745f9")

Tooltip:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if IsPlayerAtEffectiveMaxLevel() then
        Tooltip:AddHeader(L["Great Vault Rewards:"])

        if C_WeeklyRewards.HasAvailableRewards() then
            Tooltip
                :SetLine(L["You have rewards waiting for you at the Great Vault."])
                :SetGreenColor()
                :ToLine()
        end

        for info in WeeklyRewards:IterableGreatVaultInfo() do
            Tooltip:SetLine(info.header)
            if info.index == 1 then
                Tooltip:SetColor(GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR)
            elseif info.index == 2 then
                Tooltip:SetColor(GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR)
            elseif info.index == 3 then
                Tooltip:SetColor(GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR)
            else
                Tooltip:SetGrayColor()
            end
            Tooltip:SetLine(info.progress)
            if info.progress > 0 then
                Tooltip:SetWhiteColor()
            else
                Tooltip:SetGrayColor()
            end
            Tooltip:ToLine()
        end

        Tooltip:Show()
    end
end)

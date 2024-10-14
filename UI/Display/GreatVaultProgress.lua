local _, addon = ...
local WeeklyRewards = addon:GetObject("WeeklyRewards")
local Display = addon:NewDisplay("GreatVaultProgress")

local L = addon.L

local GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR = CreateColorFromRGBHexString("14b200")
local GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR = CreateColorFromRGBHexString("0091f2")
local GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR = CreateColorFromRGBHexString("c745f9")

Display:RegisterHookScript(CharacterMicroButton, "OnEnter", function()
    if IsPlayerAtEffectiveMaxLevel() then
        Display:AddHeader(L["Great Vault Rewards:"])

        if C_WeeklyRewards.HasAvailableRewards() then
            Display
                :SetLine(L["You have rewards waiting for you at the Great Vault."])
                :SetGreenColor()
                :ToLine()
        end

        for info in WeeklyRewards:IterableGreatVaultInfo() do
            Display:SetLine(info.header)
            if info.index == 1 then
                Display:SetColor(GREAT_VAULT_UNLOCKED_1ST_REWARD_COLOR)
            elseif info.index == 2 then
                Display:SetColor(GREAT_VAULT_UNLOCKED_2ND_REWARD_COLOR)
            elseif info.index == 3 then
                Display:SetColor(GREAT_VAULT_UNLOCKED_3RD_REWARD_COLOR)
            else
                Display:SetGrayColor()
            end
            Display:SetLine(info.progress)
            if info.progress > 0 then
                Display:SetWhiteColor()
            else
                Display:SetGrayColor()
            end
            Display:ToLine()
        end

        Display:Show()
    end
end)

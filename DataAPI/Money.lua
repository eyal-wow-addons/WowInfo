local _, addon = ...
local Money = addon:NewObject("Money")
local Character = addon.Character

local totalMoney = 0

function Money:IterableMoneyInfo()
    totalMoney = 0
    local charName, money
    return function()
        charName, money = Money.storage:GetMoneyInfoByCharacter(charName)
        totalMoney = totalMoney + (money or 0)
        while charName do
            local charDisplayName = charName

            if Character:IsOnConnectedRealm(charName, false) and Money.storage:IsConnectedRealmsNamesHidden() then
                charDisplayName = Character:ShortConnectedRealm(charDisplayName)
            elseif Character:IsOnCurrentRealm(charName) then
                charDisplayName = Character:RemoveRealm(charDisplayName)
            end

            local fraction = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))

            if Character:IsSame(charName) or fraction > Money.storage:GetMinMoneyAmount() or Money.storage:CanShowAllCharacters() then
                if Character:IsSame(charName) then
                    charDisplayName = GetClassColoredTextForUnit("player", charDisplayName)
                end
                return charDisplayName, GetMoneyString(money, true)
            end

            charName, money = Money.storage:GetMoneyInfoByCharacter(charName)
        end
    end
end

function Money:GetTotalMoneyString()
    return GetMoneyString(totalMoney, true)
end

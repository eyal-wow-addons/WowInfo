local _, addon = ...
local Money = addon:NewObject("Money")
local Character = addon.Character

function Money:GetPlayerMoneyInfo()
    local charName, money = Money.storage:GetPlayerMoneyInfo()
    return GetClassColoredTextForUnit("player", Character:RemoveRealm(charName)), GetMoneyString(money, true)
end

function Money:IterableCharactersMoneyInfo()
    local charDisplayName
    local charName, money
    return function()
        charName, money = Money.storage:GetCharacterMoneyInfo(charName)
        while charName do
            charDisplayName = charName

            if Character:IsOnConnectedRealm(charName) and Money.storage:IsConnectedRealmsNamesHidden() then
                charDisplayName = Character:ShortConnectedRealm(charDisplayName)
            elseif Character:IsOnCurrentRealm(charName) then
                charDisplayName = Character:RemoveRealm(charDisplayName)
            end

            local fraction = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))

            if not Character:IsSameCharacter(charName) and (fraction > Money.storage:GetMinMoneyAmount() or Money.storage:CanShowAllCharacters()) then
                return charDisplayName, GetMoneyString(money, true)
            end

            charName, money = Money.storage:GetCharacterMoneyInfo(charName)
        end
    end
end

function Money:GetTotalMoneyString()
    local totalMoney = 0
    local charName, money = Money.storage:GetCharacterMoneyInfo()
    while charName do
        if Character:IsSameCharacter(charName) or Character:IsOnCurrentRealm(charName) or Character:IsOnConnectedRealm(charName) then
            totalMoney = totalMoney + money
        end
        charName, money = Money.storage:GetCharacterMoneyInfo(charName)
    end
    return GetMoneyString(totalMoney, true)
end

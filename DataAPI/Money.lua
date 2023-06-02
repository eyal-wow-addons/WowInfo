local _, addon = ...
local Money = addon:NewObject("Money")
local Realm = addon.Realm
local Character = addon.Character

local REALM_PATTERN = "% - (.+)"

local totalMoney, data = 0, {}

local function IsCharacterOnConnectedRealm(character, includeOwn)
    return Realm:IsRealmConnectedRealm(character:match(REALM_PATTERN), includeOwn)
end

local function SortCharacterNamesAlphabetically(a, b)
    return a[1]:lower() < b[1]:lower() 
end

Money:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_MONEY", 
    "SEND_MAIL_MONEY_CHANGED", 
    "SEND_MAIL_COD_CHANGED", 
    "PLAYER_TRADE_MONEY", 
    "TRADE_MONEY_CHANGED",
    "WOWINFO_MONEY_DB_RESET", function()
        local money = GetMoney()

        Money.db:UpdateForCharacter(Character:GetFullName(), money)

        totalMoney = 0

        table.wipe(data)

        for character, money in Money.db:IterableMoneyInfo() do
            local isCharacterOnCurrentRealm = character:find(Character:GetRealm())
            if money > 0 and (IsCharacterOnConnectedRealm(character, true) or isCharacterOnCurrentRealm) then
                table.insert(data, {character, money})
                totalMoney = totalMoney + money
            end
        end

        table.sort(data, SortCharacterNamesAlphabetically)
    end)

function Money:IterableMoneyInfo()
    local i = 0
    local n = #data
    return function()
        i = i + 1
        if i <= n then
            local info = data[i]

            local characterString = info[1]
            local isCharacterOnCurrentRealm = characterString:find(Character:GetRealm())

            if IsCharacterOnConnectedRealm(characterString, false) and Money.db:IsConnectedRealmsNamesHidden() then
                characterString = characterString:gsub(REALM_PATTERN, "*")
            elseif isCharacterOnCurrentRealm then
                characterString = characterString:gsub(REALM_PATTERN, "")
            end

            characterString = Ambiguate(characterString, "none")

            local money = info[2]
            local fraction = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
            local isCharacterCurrentPlayer = characterString == Character:GetName()

            if isCharacterCurrentPlayer then
                characterString = GetClassColoredTextForUnit("player", characterString)
            end

            if isCharacterCurrentPlayer or fraction > Money.db:GetMinMoneyAmount() or Money.db:CanShowAllCharacters()  then
                return characterString, GetMoneyString(money, true)
            end

            return characterString
        end
    end
end

function Money:GetTotalMoneyString()
    return GetMoneyString(totalMoney, true)
end

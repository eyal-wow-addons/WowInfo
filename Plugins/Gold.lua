if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local plugin, db = addon:NewPlugin("Gold", "AceEvent-3.0")

local Tooltip = addon.Tooltip
local Character = addon.Character
local Realm = addon.Realm

local TOTAL_GOLD_LABEL = "Total"
local GOLD_LABEL = "Gold:"

local REALM_PATTERN = "% - (.+)"

local sum, goldInfo = 0, {}

local function IsCharacterOnConnectedRealm(character, includeOwn)
    return Realm:IsRealmConnectedRealm(character:match(REALM_PATTERN), includeOwn)
end

local function SortCharacterNamesAlphabetically(a, b)
    return a[1]:lower() < b[1]:lower() 
end

local function UpdateGold()
    local money = GetMoney()

    db:UpdateGold(Character:GetFullName(), money)

    sum = 0
    wipe(goldInfo)

    for character, money in db:GetGoldInfo() do
        local isCharacterOnCurrentRealm = character:find(Character:GetRealm())
        if money > 0 and (IsCharacterOnConnectedRealm(character, true) or isCharacterOnCurrentRealm) then
            table.insert(goldInfo, {character, money})
            sum = sum + money
        end
    end

    table.sort(goldInfo, SortCharacterNamesAlphabetically)
end

function plugin:OnInitialize()
    db:RegisterEvent("GoldDB_Reset", UpdateGold)
end

plugin:RegisterEvent("PLAYER_LOGIN", UpdateGold)
plugin:RegisterEvent("PLAYER_MONEY", UpdateGold)
plugin:RegisterEvent("SEND_MAIL_MONEY_CHANGED", UpdateGold)
plugin:RegisterEvent("SEND_MAIL_COD_CHANGED", UpdateGold)
plugin:RegisterEvent("PLAYER_TRADE_MONEY", UpdateGold)
plugin:RegisterEvent("TRADE_MONEY_CHANGED", UpdateGold)

plugin:RegisterHookScript(MainMenuBarBackpackButton, "OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(GOLD_LABEL)

    if #goldInfo > 0 then
        for _, data in ipairs(goldInfo) do
            local character = data[1]
            local isCharacterOnCurrentRealm = character:find(Character:GetRealm())

            if IsCharacterOnConnectedRealm(character, false) and db:IsConnectedRealmsNamesHidden() then
                character = character:gsub(REALM_PATTERN, "*")
            elseif isCharacterOnCurrentRealm then
                character = character:gsub(REALM_PATTERN, "")
            end

            character = Ambiguate(character, "none")

            local money = data[2]
            local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
            local isCharacterCurrentPlayer = character == Character:GetName()

            if isCharacterCurrentPlayer then
                character = GetClassColoredTextForUnit("player", character)
            end

            if isCharacterCurrentPlayer or gold > db:GetMinGoldAmount() then
                Tooltip:AddRightHighlightDoubleLine(character, GetMoneyString(money, true))
            end
        end
        Tooltip:AddEmptyLine()
    end

    Tooltip:AddRightHighlightDoubleLine(TOTAL_GOLD_LABEL, GetMoneyString(sum, true))
    Tooltip:AddEmptyLine()

    Tooltip:Show()
end)

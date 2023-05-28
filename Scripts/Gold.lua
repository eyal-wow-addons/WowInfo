if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local module = addon:NewModule("Scripts:Gold", "AceEvent-3.0")
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip
local Character = addon.Character
local Realm = addon.Realm
local GoldDB = addon.GoldDB

local TOTAL_GOLD_LABEL = "Total"
local GOLD_LABEL = "Gold:"

local REALM_PATTERN = "% - (.+)"
local CHARACTER_CLASS_COLOR_FORMAT = "|cff%.2x%.2x%.2x%s|r"

local sum, goldInfo = 0, {}

local function IsCharacterOnConnectedRealm(character, includeOwn)
    return Realm:IsRealmConnectedRealm(character:match(REALM_PATTERN), includeOwn)
end

local function SortCharacterNamesAlphabetically(a, b)
    return a[1]:lower() < b[1]:lower() 
end

local function UpdateGold()
    local money = GetMoney()

    GoldDB:UpdateGold(Character:GetFullName(), money)

    sum = 0
    wipe(goldInfo)

    for character, money in GoldDB:GetGoldInfo() do
        local isCharacterOnCurrentRealm = character:find(Character:GetRealm())
        if money > 0 and (IsCharacterOnConnectedRealm(character, true) or isCharacterOnCurrentRealm) then
            table.insert(goldInfo, {character, money})
            sum = sum + money
        end
    end

    table.sort(goldInfo, SortCharacterNamesAlphabetically)
end

function module:OnInitialize()
    GoldDB:RegisterEvent("GoldDB_Reset", UpdateGold)
end

module:RegisterEvent("PLAYER_LOGIN", UpdateGold)
module:RegisterEvent("PLAYER_MONEY", UpdateGold)
module:RegisterEvent("SEND_MAIL_MONEY_CHANGED", UpdateGold)
module:RegisterEvent("SEND_MAIL_COD_CHANGED", UpdateGold)
module:RegisterEvent("PLAYER_TRADE_MONEY", UpdateGold)
module:RegisterEvent("TRADE_MONEY_CHANGED", UpdateGold)

ScriptLoader:AddHookScript(MainMenuBarBackpackButton, "OnEnter", function()
    Tooltip:AddEmptyLine()
    Tooltip:AddHighlightLine(GOLD_LABEL)

    if #goldInfo > 0 then
        for _, data in ipairs(goldInfo) do
            local character = data[1]
            local isCharacterOnCurrentRealm = character:find(Character:GetRealm())

            if IsCharacterOnConnectedRealm(character, false) and GoldDB:IsConnectedRealmsNamesHidden() then
                character = character:gsub(REALM_PATTERN, "*")
            elseif isCharacterOnCurrentRealm then
                character = character:gsub(REALM_PATTERN, "")
            end

            character = Ambiguate(character, "none")

            local money = data[2]
            local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
            local isCharacterCurrentPlayer = character == Character:GetName()

            if isCharacterCurrentPlayer then
                local _, englishClass = UnitClass("player")
                local classColor = englishClass and RAID_CLASS_COLORS[englishClass] or NORMAL_FONT_COLOR
                character = CHARACTER_CLASS_COLOR_FORMAT:format(classColor.r * 255, classColor.g * 255, classColor.b * 255, character)
            end

            if isCharacterCurrentPlayer or gold > GoldDB:GetMinGoldAmount() then
                Tooltip:AddRightHighlightDoubleLine(character, GetMoneyString(money, true))
            end
        end
        Tooltip:AddEmptyLine()
    end

    Tooltip:AddRightHighlightDoubleLine(TOTAL_GOLD_LABEL, GetMoneyString(sum, true))
    Tooltip:AddEmptyLine()

    Tooltip:Show()
end)

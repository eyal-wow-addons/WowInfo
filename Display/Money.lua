if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local Money = addon:GetObject("Money")
local Display = addon:NewDisplay("Money")

local L = addon.L

function Display:AddPlayerMoneyLine()
    local charName, moneyString = Money:GetPlayerMoneyInfo()

    return
        self:SetLine(charName)
            :SetPlayerClassColor()
            :SetLine(moneyString)
            :SetHighlight()
            :ToLine()
end

function Display:AddMoneyLine(text, moneyString)
    return
        self:SetLine(text)
            :SetLine(moneyString)
            :SetHighlight()
            :ToLine()
end

Display:RegisterHookScript(MainMenuBarBackpackButton, "OnEnter", function()
    Display:AddHeader(L["Money:"])

    Display:AddPlayerMoneyLine()

    for charName, moneyString in Money:IterableCharactersMoneyInfo() do
        Display:AddMoneyLine(charName, moneyString)
    end

    Display
        :AddEmptyLine()
        :AddMoneyLine(L["Total"], Money:GetTotalMoneyString())
        :AddEmptyLine()

    Display:Show()
end)

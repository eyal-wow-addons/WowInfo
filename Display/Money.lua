if not MainMenuBarBackpackButton:IsVisible() then return end

local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Money")
local Money = addon.Money

Display:RegisterHookScript(MainMenuBarBackpackButton, "OnEnter", function()
    Display:AddTitleLine(L["Money:"])

    Display:AddRightHighlightDoubleLine(Money:GetPlayerMoneyInfo())

    for charDisplayName, moneyString in Money:IterableCharactersMoneyInfo() do
        Display:AddRightHighlightDoubleLine(charDisplayName, moneyString)
    end

    Display:AddEmptyLine()
    Display:AddHighlightDoubleLine(L["Total"], Money:GetTotalMoneyString())
    Display:AddEmptyLine()

    Display:Show()
end)

if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local Friends = addon:GetObject("Friends")
local Tooltip = addon:NewTooltip("Friends")

local L = addon.L

local BNET_CHAR_LINE_FORMAT = "%s (%s)"

Tooltip:RegisterHookScript(QuickJoinToastButton, "OnEnter", function()
    local _, numWoWOnline, _, numBNetOnline = Friends:GetNumOnlineFriendsInfo()

    if numWoWOnline > 0 then
        Tooltip:AddFormattedHeader(L["World of Warcraft (X):"], numWoWOnline)

        for info in Friends:IterableWoWFriendsInfo() do
            local charName = Tooltip:GetFormattedCharName(info)
            charName = Tooltip:GetFormattedStatus(info, charName)

            Tooltip:SetLine(charName):ToLine()

            if IsShiftKeyDown() and info.zoneName then
                Tooltip:SetLine(info.zoneName):Indent(6)

                if info.sameZone then
                    Tooltip:SetGreenColor()
                else
                    Tooltip:SetGrayColor()
                end

                Tooltip:ToLine()
            end
        end
    end

    if numBNetOnline > 0 then
        Tooltip:AddFormattedHeader(L["Battle.net (X):"], numBNetOnline)

        for info in Friends:IterableBattleNetFriendsInfo() do
            local accountName = info.accountName
            --accountName = info.isFavorite and info.appearOffline and Tooltip:ToGray(accountName) or accountName
            accountName = Tooltip:GetFormattedStatus(info, accountName)

            if info.characterName then
                Tooltip:SetFormattedLine(BNET_CHAR_LINE_FORMAT, accountName, Tooltip:GetFormattedCharName(info))
            else
                Tooltip:SetLine(accountName)
            end

            Tooltip
                :SetColor(BATTLENET_FONT_COLOR)
                :SetLine(info.clientProgram)
                :SetColor(BATTLENET_FONT_COLOR)
                :ToLine()

            if IsShiftKeyDown() and info.characterName then
                if info.zoneName then
                    Tooltip:SetLine(info.zoneName):Indent(6)
                    if info.sameZone then
                        Tooltip:SetGreenColor()
                    else
                        Tooltip:SetGrayColor()
                    end
                end
                if info.realmName then
                    Tooltip:SetLine(info.realmName):Indent()
                    if info.sameRealm then
                        Tooltip:SetGreenColor()
                    else
                        Tooltip:SetGrayColor()
                    end
                end
                Tooltip:ToLine()
            end
        end
    end

    Tooltip:Show()
end)

if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local Friends = addon:GetObject("Friends")
local Display = addon:NewDisplay("Friends")

local L = addon.L

local BNET_CHAR_LINE_FORMAT = "%s (%s)"

Display:RegisterHookScript(QuickJoinToastButton, "OnEnter", function()
    local _, numWoWOnline, _, numBNetOnline = Friends:GetNumOnlineFriendsInfo()

    if (numBNetOnline + numWoWOnline) > 0 then
        Friends:ResetConnectedFriendsCounter()

        if numWoWOnline > 0 then
            Display:AddFormattedHeader(L["World of Warcraft (X):"], numWoWOnline)

            for info in Friends:IterableWoWFriendsInfo() do
                local charName = Friends:GetFormattedCharName(info)
                charName = Friends:GetFormattedStatus(info, charName)

                Display:SetLine(charName):ToLine()

                if IsShiftKeyDown() and info.zoneName then
                    Display:SetLine(info.zoneName):Indent(6)

                    if info.sameZone then
                        Display:SetGreenColor()
                    else
                        Display:SetGrayColor()
                    end

                    Display:ToLine()
                end
            end
        end

        if numBNetOnline > 0 then
            Display:AddFormattedHeader(L["Battle.net (X):"], numBNetOnline)

            for info in Friends:IterableBattleNetFriendsInfo() do
                local accountName = info.accountName
                accountName = info.isFavorite and info.appearOffline and Display:ToGray(accountName) or accountName
                accountName = Display:GetFormattedStatus(info, accountName)

                if info.characterName then
                    Display:SetFormattedLine(BNET_CHAR_LINE_FORMAT, accountName, Display:GetFormattedCharName(info))
                else
                    Display:SetLine(accountName)
                end

                Display
                    :SetColor(BATTLENET_FONT_COLOR)
                    :SetLine(info.clientProgram)
                    :SetColor(BATTLENET_FONT_COLOR)
                    :ToLine()

                if IsShiftKeyDown() and info.characterName then
                    if info.zoneName then
                        Display:SetLine(info.zoneName):Indent(6)
                        if info.sameZone then
                            Display:SetGreenColor()
                        else
                            Display:SetGrayColor()
                        end
                    end
                    if info.realmName then
                        Display:SetLine(info.realmName):Indent()
                        if info.sameRealm then
                            Display:SetGreenColor()
                        else
                            Display:SetGrayColor()
                        end
                    end
                    Display:ToLine()
                end
            end
        end

        Display:Show()
    end
end)

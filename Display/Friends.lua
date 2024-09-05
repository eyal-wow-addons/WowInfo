if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local Friends = addon:GetObject("Friends")
local Display = addon:NewDisplay("Friends")

local L = addon.L

local WOW_CHAR_FORMAT = "%s |cffffffff%d|r"
local WOW_CHAR_GROUPED_FORMAT = "|cffaaaaaa[|r%s|cffaaaaaa]|r"
local BNET_CHAR_LINE_FORMAT = "%s (%s)"
local GAME_STATUS_TABLE = { FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND, FRIENDS_TEXTURE_OFFLINE }
local GAME_STATUS_FORMAT = "|T%s:0|t %s"

local function GetFormattedCharName(info)
    local className = addon.CLASS_NAMES[info.characterClassName]
    local charName = Display:ToClassColor(className, info.characterName)
    charName = info.characterLevel and WOW_CHAR_FORMAT:format(charName, info.characterLevel)
    charName = info.grouped and WOW_CHAR_GROUPED_FORMAT:format(charName) or charName
    return charName
end

Display:RegisterHookScript(QuickJoinToastButton, "OnEnter", function()
    local _, numWoWOnline, _, numBNetOnline = Friends:GetNumOnlineFriendsInfo()

    if (numBNetOnline + numWoWOnline) > 0 then
        Friends:ResetConnectedFriendsCounter()

        if numWoWOnline > 0 then
            Display:AddFormattedHeader(L["World of Warcraft (X):"], numWoWOnline)

            for info in Friends:IterableWoWFriendsInfo() do
                local charName = GetFormattedCharName(info)
                charName = info.status and GAME_STATUS_FORMAT:format(GAME_STATUS_TABLE[info.status], charName)

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

                if info.isFavorite and info.appearOffline then
                    accountName = Display:ToGray(accountName)
                end

                accountName = info.status and GAME_STATUS_FORMAT:format(GAME_STATUS_TABLE[info.status], accountName)

                if info.characterName then
                    Display:SetFormattedLine(BNET_CHAR_LINE_FORMAT, accountName, GetFormattedCharName(info))
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

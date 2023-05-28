if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local module = addon:NewModule("Scripts:Social")
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip
local SocialDB = addon.SocialDB

local FRIENDS_WOW_LABEL_FORMAT = "%s%s %d %s"

local FRIENDS_BNET_ONLINE_LABEL_FORMAT = "Battle.net (%d):"
local FRIENDS_BNET_CLIENT_LABEL_FORMAT = "%s |cffffffff(|r|c%s%s|r%s |c%s%d|r|cffffffff)|r %s"
local FRIENDS_BNET_CLIENT_OTHER_LABEL_FORMAT = "%s |cffffffff(|r%s|cffffffff)|r"
local FRIENDS_BNET_STATUS_TABLE = {"|cffff0000<AFK>|r", "|cffff0000<DND>|r", ""}
local FRIENDS_BNET_NO_CLASS_COLOR = "ffffffff"

local FRIENDS_ACTIVE_ZONE_COLOR = {r=0.3, g=1.0, b=0.3}
local FRIENDS_INACTIVE_ZONE_COLOR = {r=0.65, g=0.65, b=0.65}
local FRIENDS_GROUPED_TABLE = {"|cffaaaaaa*|r", ""}

ScriptLoader:AddHookScript(QuickJoinToastButton, "OnEnter", function()
    local maxOnlineFriends = SocialDB:GetMaxOnlineFriends()
    if maxOnlineFriends == 0 then return end

    local numWoWTotal, numWoWOnline = C_FriendList.GetNumFriends(), C_FriendList.GetNumOnlineFriends()
    local numBNetTotal, numBNetOnline = BNGetNumFriends()
    local zoneColors, realmColors, grouped

    if (numBNetOnline + numWoWOnline) > 0 then
        local counter = 0

        if numWoWOnline > 0 then
            Tooltip:AddEmptyLine()
            Tooltip:AddHighlightLine(("World of Warcraft (%d):"):format(numWoWOnline))

            for i = 1, numWoWTotal do
                local info = C_FriendList.GetFriendInfoByIndex(i)
                if info then 
                    local name = info.name
                    local class = info.className
                    local status = ""

                    if info.dnd then
                        status = CHAT_FLAG_DND;
                    elseif info.afk then
                        status = CHAT_FLAG_AFK;
                    end

                    if counter >= maxOnlineFriends then
                        break
                    elseif info.connected then
                        if GetRealZoneText() == info.area then
                            zoneColors = FRIENDS_ACTIVE_ZONE_COLOR
                        else
                            zoneColors = FRIENDS_INACTIVE_ZONE_COLOR
                        end

                        for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do 
                            if class == v then class = k end 
                        end

                        local grouped
                        if UnitInParty(name) or UnitInRaid(name) then
                            grouped = 1
                        else
                            grouped = 2
                        end

                        local classColors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
                        Tooltip:AddDoubleLine(FRIENDS_WOW_LABEL_FORMAT:format(name, FRIENDS_GROUPED_TABLE[grouped], info.level, status), info.area, classColors.r, classColors.g, classColors.b, zoneColors.r, zoneColors.g, zoneColors.b)
                        counter = counter + 1
                    end
                end
            end
        end

        if numBNetOnline > 0 then
            Tooltip:AddEmptyLine()
            Tooltip:AddHighlightLine(FRIENDS_BNET_ONLINE_LABEL_FORMAT:format(numBNetOnline))
            local status = 0
            for i = 1, numBNetTotal do
                local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(i)
                if counter >= maxOnlineFriends then
                    break
                elseif friendAccountInfo.bnetAccountID and friendAccountInfo.gameAccountInfo.isOnline then
                    local accountInfo = C_BattleNet.GetAccountInfoByID(friendAccountInfo.bnetAccountID)
                    local accountName = accountInfo.accountName
                    local clientProgram = accountInfo.gameAccountInfo.clientProgram
                    local characterName =  accountInfo.gameAccountInfo.characterName
                    if characterName and clientProgram == BNET_CLIENT_WOW then
                        clientProgram = accountInfo.gameAccountInfo.richPresence == BNET_FRIEND_TOOLTIP_WOW_CLASSIC and BNET_FRIEND_TOOLTIP_WOW_CLASSIC or clientProgram

                        local class =  accountInfo.gameAccountInfo.className
                        local level =  accountInfo.gameAccountInfo.characterLevel or 0

                        if accountInfo.gameAccountInfo.isGameAFK then
                            status = 1
                        elseif accountInfo.gameAccountInfo.isGameBusy then
                            status = 2
                        else
                            status = 3
                        end

                        local grouped
                        if UnitInParty(characterName) or UnitInRaid(characterName) then
                            grouped = 1
                        else
                            grouped = 2
                        end

                        if class then
                            for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do 
                                if class == v then class = k end 
                            end
                            local classColors = class and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class].colorStr
                            Tooltip:AddRightHighlightDoubleLine(FRIENDS_BNET_CLIENT_LABEL_FORMAT:format(accountName, classColors or FRIENDS_BNET_NO_CLASS_COLOR, characterName, FRIENDS_GROUPED_TABLE[grouped], classColors or FRIENDS_BNET_NO_CLASS_COLOR, level, FRIENDS_BNET_STATUS_TABLE[status]), clientProgram)
                        else
                            Tooltip:AddRightHighlightDoubleLine(accountName, clientProgram)
                        end

                        if IsShiftKeyDown() then
                            local zoneName =  accountInfo.gameAccountInfo.areaName
                            local realmName =  accountInfo.gameAccountInfo.realmName or ""
                            if GetRealZoneText() == zoneName then
                                zoneColors = FRIENDS_ACTIVE_ZONE_COLOR
                            else
                                zoneColors = FRIENDS_INACTIVE_ZONE_COLOR
                            end
                            if GetRealmName() == realmName then
                                realmColors = FRIENDS_ACTIVE_ZONE_COLOR
                            else
                                realmColors = FRIENDS_INACTIVE_ZONE_COLOR
                            end
                            if zoneName then 
                                Tooltip:AddIndentedDoubleLine(zoneName, realmName, zoneColors.r, zoneColors.g, zoneColors.b, realmColors.r, realmColors.g, realmColors.b)
                            end
                        end
                    else
                        if characterName and clientProgram ~= BNET_CLIENT_APP then
                            characterName = BNet_GetValidatedCharacterName(characterName, friendAccountInfo.battleTag, clientProgram)
                            Tooltip:AddRightHighlightDoubleLine(FRIENDS_BNET_CLIENT_OTHER_LABEL_FORMAT:format(accountName, characterName), clientProgram)
                        else
                            Tooltip:AddRightHighlightDoubleLine(accountName, clientProgram)
                        end
                    end
                    counter = counter + 1
                end
            end
        end

        Tooltip:Show()
    end
end)

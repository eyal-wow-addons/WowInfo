local _, addon = ...
local Friends = addon:NewObject("Friends")

Friends.GetNumFriends = C_FriendList.GetNumFriends
Friends.GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
Friends.BNGetNumFriends = BNGetNumFriends
Friends.GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo

local FRIENDS_WOW_LABEL_FORMAT = "%s%s %d %s"

local FRIENDS_BNET_CLIENT_LABEL_FORMAT = "%s |cffffffff(|r|c%s%s|r%s |c%s%d|r|cffffffff)|r %s"
local FRIENDS_BNET_CLIENT_OTHER_LABEL_FORMAT = "%s |cffffffff(|r%s|cffffffff)|r"
local FRIENDS_BNET_STATUS_TABLE = {"|cffff0000<AFK>|r", "|cffff0000<DND>|r", ""}
local FRIENDS_BNET_NO_CLASS_COLOR = "ffffffff"

local FRIENDS_ACTIVE_ZONE_COLOR = CreateColor(0.3, 1.0, 0.3)
local FRIENDS_INACTIVE_ZONE_COLOR = CreateColor(0.65, 0.65, 0.65)
local FRIENDS_GROUPED_TABLE = {"|cffaaaaaa*|r", ""}

local connectedFriendsCounter = 0

function Friends:GetOnlineFriendsInfo()
    local numWoWTotal = self.GetNumFriends()
    local numBNetTotal = self.BNGetNumFriends()
    local onlineFriendsCounter = 0
    local onlineFriends

    for i = 1, numWoWTotal do
        local info = self.GetFriendInfoByIndex(i)
        if info and info.connected then
            onlineFriends = onlineFriends or {}
            onlineFriends[info.name] = true
            onlineFriendsCounter = onlineFriendsCounter + 1
        end
    end

    for i = 1, numBNetTotal do
        local accountInfo = self.GetFriendAccountInfo(i)
        local characterName = accountInfo.gameAccountInfo.characterName
        local client = accountInfo.gameAccountInfo.clientProgram
        local isOnline = accountInfo.gameAccountInfo.isOnline
        if client == BNET_CLIENT_WOW and isOnline  then
            onlineFriends = onlineFriends or {}
            onlineFriends[characterName] = true
            onlineFriendsCounter = onlineFriendsCounter + 1
        end
    end

    return onlineFriends, onlineFriendsCounter
end

function Friends:GetNumOnlineFriendsInfo()
    local numWoWTotal, numWoWOnline = C_FriendList.GetNumFriends(), C_FriendList.GetNumOnlineFriends()
    local numBNetTotal, numBNetOnline = BNGetNumFriends()
    return numWoWTotal, numWoWOnline, numBNetTotal, numBNetOnline
end

function Friends:ResetConnectedFriendsCounter()
    connectedFriendsCounter = 0
end

function Friends:IterableWoWFriendsInfo()
    local maxOnlineFriends, friendInfo, name, className, status, zoneColors, grouped, classColor, friendString, zoneString
    local i = 0
    local n = C_FriendList.GetNumFriends()
    return function()
        maxOnlineFriends = self.storage:GetMaxOnlineFriends()
        if maxOnlineFriends == 0 then 
            return 
        end
        i = i + 1
        while i <= n do
            if connectedFriendsCounter >= maxOnlineFriends then
                return
            end

            friendInfo = C_FriendList.GetFriendInfoByIndex(i)

            if friendInfo.connected then
                connectedFriendsCounter = connectedFriendsCounter + 1

                name = friendInfo.name
                className = friendInfo.className
                status = ""

                if friendInfo.dnd then
                    status = CHAT_FLAG_DND;
                elseif friendInfo.afk then
                    status = CHAT_FLAG_AFK;
                end

                if GetRealZoneText() == friendInfo.area then
                    zoneColors = FRIENDS_ACTIVE_ZONE_COLOR
                else
                    zoneColors = FRIENDS_INACTIVE_ZONE_COLOR
                end

                if UnitInParty(name) or UnitInRaid(name) then
                    grouped = 1
                else
                    grouped = 2
                end

                if className then
                    className = addon.CLASS_NAMES[className]
                    classColor = RAID_CLASS_COLORS[className]
                else
                    classColor = NORMAL_FONT_COLOR
                end

                friendString = FRIENDS_WOW_LABEL_FORMAT:format(name, FRIENDS_GROUPED_TABLE[grouped], friendInfo.level, status) 
                zoneString = friendInfo.area

                return WrapTextInColor(friendString, classColor), WrapTextInColor(zoneString, zoneColors)
            end
            i = i + 1
        end
    end
end

function Friends:IterableBattleNetFriendsInfo()
    local maxOnlineFriends, status, friendAccountInfo, accountInfo, accountName, clientProgram, characterName, zoneName, realmName, className, characterLevel, grouped, zoneColors, realmColors, zoneString, realmString
    local i = 0
    local n = BNGetNumFriends()
    return function()
        maxOnlineFriends = self.storage:GetMaxOnlineFriends()
        if maxOnlineFriends == 0 then
            return
        end
        i = i + 1
        while i <= n do
            if connectedFriendsCounter >= maxOnlineFriends then
                return
            end

            friendAccountInfo = C_BattleNet.GetFriendAccountInfo(i)

            if friendAccountInfo.bnetAccountID and friendAccountInfo.gameAccountInfo.isOnline then
                connectedFriendsCounter = connectedFriendsCounter + 1

                accountInfo = C_BattleNet.GetAccountInfoByID(friendAccountInfo.bnetAccountID)
                accountName = accountInfo.accountName
                clientProgram = accountInfo.gameAccountInfo.clientProgram
                characterName =  accountInfo.gameAccountInfo.characterName
                zoneName =  accountInfo.gameAccountInfo.areaName
                realmName =  accountInfo.gameAccountInfo.realmName or ""

                if characterName and clientProgram == BNET_CLIENT_WOW then
                    clientProgram = accountInfo.gameAccountInfo.richPresence == BNET_FRIEND_TOOLTIP_WOW_CLASSIC and BNET_FRIEND_TOOLTIP_WOW_CLASSIC or clientProgram

                    className =  accountInfo.gameAccountInfo.className
                    characterLevel =  accountInfo.gameAccountInfo.characterLevel or 0

                    if accountInfo.gameAccountInfo.isGameAFK then
                        status = 1
                    elseif accountInfo.gameAccountInfo.isGameBusy then
                        status = 2
                    else
                        status = 3
                    end

                    if UnitInParty(characterName) or UnitInRaid(characterName) then
                        grouped = 1
                    else
                        grouped = 2
                    end

                    if zoneName then
                        if GetRealZoneText() == zoneName then
                            zoneColors = FRIENDS_ACTIVE_ZONE_COLOR
                        else
                            zoneColors = FRIENDS_INACTIVE_ZONE_COLOR
                        end
                        zoneString = WrapTextInColor(zoneName, zoneColors)
                    end

                    if realmName then
                        if GetRealmName() == realmName then
                            realmColors = FRIENDS_ACTIVE_ZONE_COLOR
                        else
                            realmColors = FRIENDS_INACTIVE_ZONE_COLOR
                        end
                        realmString = WrapTextInColor(realmName, realmColors)
                    end
                    if className then
                        className = addon.CLASS_NAMES[className]
                        local classColors = className and RAID_CLASS_COLORS[className].colorStr
                        return FRIENDS_BNET_CLIENT_LABEL_FORMAT:format(accountName, classColors or FRIENDS_BNET_NO_CLASS_COLOR, characterName, FRIENDS_GROUPED_TABLE[grouped], classColors or FRIENDS_BNET_NO_CLASS_COLOR, characterLevel, FRIENDS_BNET_STATUS_TABLE[status]), zoneString, realmString, clientProgram
                    else
                        return accountName, zoneString, realmString, clientProgram
                    end
                else
                    if characterName and clientProgram ~= BNET_CLIENT_APP then
                        characterName = BNet_GetValidatedCharacterName(characterName, friendAccountInfo.battleTag, clientProgram)
                        return FRIENDS_BNET_CLIENT_OTHER_LABEL_FORMAT:format(accountName, characterName), clientProgram
                    else
                        return accountName, clientProgram
                    end
                end
            end
            i = i + 1
        end
    end
end
local _, addon = ...
local Friends = addon:NewObject("Friends")

Friends.GetNumFriends = C_FriendList.GetNumFriends
Friends.GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
Friends.GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
Friends.BNGetNumFriends = BNGetNumFriends
Friends.GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
Friends.GetAccountInfoByID = C_BattleNet.GetAccountInfoByID

local DATA = {
    WOW = {},
    BATTLENET = {}
}

local connectedFriendsCounter = 0

function Friends:GetOnlineFriendsInfo()
    local numWoWTotal = self:GetNumFriends()
    local numBNetTotal = self:BNGetNumFriends()
    local onlineFriendsCounter = 0
    local onlineFriends

    for i = 1, numWoWTotal do
        local info = self:GetFriendInfoByIndex(i)
        if info and info.connected then
            onlineFriends = onlineFriends or {}
            onlineFriends[info.name] = true
            onlineFriendsCounter = onlineFriendsCounter + 1
        end
    end

    for i = 1, numBNetTotal do
        local accountInfo = self:GetFriendAccountInfo(i)
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
    local numWoWTotal, numWoWOnline = self:GetNumFriends(), self:GetNumOnlineFriends()
    local numBNetTotal, numBNetOnline = self:BNGetNumFriends()
    return numWoWTotal, numWoWOnline, numBNetTotal, numBNetOnline
end

function Friends:ResetConnectedFriendsCounter()
    connectedFriendsCounter = 0
end

function Friends:IterableWoWFriendsInfo()
    local maxOnlineFriends, friendInfo, characterName, grouped, sameZone, status
    local i = 0
    local n = self:GetNumFriends()
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

            friendInfo = self:GetFriendInfoByIndex(i)

            if friendInfo.connected then
                connectedFriendsCounter = connectedFriendsCounter + 1

                characterName = friendInfo.name
                status = ""

                if friendInfo.dnd then
                    status = CHAT_FLAG_DND;
                elseif friendInfo.afk then
                    status = CHAT_FLAG_AFK;
                end

                if friendInfo.area then
                    if GetRealZoneText() == friendInfo.area then
                        sameZone = true
                    else
                        sameZone = false
                    end
                end

                if UnitInParty(characterName) or UnitInRaid(characterName) then
                    grouped = true
                else
                    grouped = false
                end

                DATA.WOW.characterName = characterName
                DATA.WOW.characterClassName = friendInfo.className
                DATA.WOW.characterLevel = friendInfo.level
                DATA.WOW.grouped = grouped
                DATA.WOW.zoneName = friendInfo.area
                DATA.WOW.sameZone = sameZone
                DATA.WOW.status = status

                return DATA.WOW
            end
            i = i + 1
        end
    end
end

function Friends:IterableBattleNetFriendsInfo()
    local maxOnlineFriends, friendAccountInfo, accountInfo
    local characterName, characterClassName, characterLevel, grouped, zoneName, sameZone, status, accountName, realmName, sameRealm, clientProgram
    local i = 0
    local n = self:BNGetNumFriends()
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

            friendAccountInfo = self:GetFriendAccountInfo(i)

            if friendAccountInfo.bnetAccountID and friendAccountInfo.gameAccountInfo.isOnline then
                connectedFriendsCounter = connectedFriendsCounter + 1

                accountInfo = self:GetAccountInfoByID(friendAccountInfo.bnetAccountID)
                accountName = accountInfo.accountName
                clientProgram = accountInfo.gameAccountInfo.clientProgram
                characterName =  accountInfo.gameAccountInfo.characterName
                zoneName =  accountInfo.gameAccountInfo.areaName
                realmName =  accountInfo.gameAccountInfo.realmName or ""

                if characterName and clientProgram == BNET_CLIENT_WOW then
                    clientProgram = accountInfo.gameAccountInfo.richPresence == BNET_FRIEND_TOOLTIP_WOW_CLASSIC and BNET_FRIEND_TOOLTIP_WOW_CLASSIC or clientProgram

                    characterClassName = accountInfo.gameAccountInfo.className
                    characterLevel =  accountInfo.gameAccountInfo.characterLevel

                    if accountInfo.gameAccountInfo.isGameAFK then
                        status = 1
                    elseif accountInfo.gameAccountInfo.isGameBusy then
                        status = 2
                    else
                        status = 3
                    end

                    if UnitInParty(characterName) or UnitInRaid(characterName) then
                        grouped = true
                    else
                        grouped = false
                    end

                    if zoneName then
                        if GetRealZoneText() == zoneName then
                            sameZone = true
                        else
                            sameZone = false
                        end
                    end

                    if realmName then
                        if GetRealmName() == realmName then
                            sameRealm = true
                        else
                            sameRealm = false
                        end
                    end
                else
                    if characterName and clientProgram ~= BNET_CLIENT_APP then
                        characterName = BNet_GetValidatedCharacterName(characterName, friendAccountInfo.battleTag, clientProgram)
                    end
                end

                DATA.BATTLENET.characterName = characterName
                DATA.BATTLENET.characterClassName = characterClassName
                DATA.BATTLENET.characterLevel = characterLevel
                DATA.BATTLENET.grouped = grouped
                DATA.BATTLENET.zoneName = zoneName
                DATA.BATTLENET.sameZone = sameZone
                DATA.BATTLENET.status = status
                DATA.BATTLENET.accountName = accountName
                DATA.BATTLENET.realmName = realmName
                DATA.BATTLENET.sameRealm = sameRealm
                DATA.BATTLENET.clientProgram = clientProgram

                return DATA.BATTLENET
            end
            i = i + 1
        end
    end
end
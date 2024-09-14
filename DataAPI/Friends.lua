local _, addon = ...
local Friends = addon:NewObject("Friends")

local tinsert = table.insert

Friends.GetNumFriends = C_FriendList.GetNumFriends
Friends.GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
Friends.GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
Friends.BNGetNumFriends = BNGetNumFriends
Friends.GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
Friends.GetAccountInfoByID = C_BattleNet.GetAccountInfoByID

local DATA = {
    WOW = {},
    BATTLENET = {},
    ONLINE = {}
}

local CACHE = {
    WOW = {},
    BATTLENET = {}
}

local connectedFriendsCounter = 0

local function CacheFriendsInfoHelper(cache, getNumFriends, getFriendInfo)
    local numTotal = getNumFriends()
    for i = 1, math.max(#cache, numTotal) do
        local info = getFriendInfo(i)
        if info and cache[i] then
            cache[i] = info
        elseif not info then
            cache[i] = nil
        else
            tinsert(cache, info)
        end
    end
end

local function CacheFriendsInfo()
    CacheFriendsInfoHelper(CACHE.WOW, Friends.GetNumFriends, Friends.GetFriendInfoByIndex)
end

local function CacheFriendsAccountInfo()
    CacheFriendsInfoHelper(CACHE.BATTLENET, Friends.BNGetNumFriends, Friends.GetFriendAccountInfo)
end

Friends:RegisterEvents(
    "PLAYER_LOGIN",
    "FRIENDLIST_UPDATE",
    "BN_FRIEND_INVITE_ADDED",
    "BN_FRIEND_INVITE_REMOVED",
    "BN_CONNECTED",
    "BN_DISCONNECTED", function(_, eventName)
        if eventName == "PLAYER_LOGIN" or eventName == "FRIENDLIST_UPDATE" then
            CacheFriendsInfo()
            CacheFriendsAccountInfo()
        else
            CacheFriendsAccountInfo()
        end
    end)

function Friends:GetOnlineFriendsInfo()
    local numWoWTotal = #CACHE.WOW
    local numBNetTotal = #CACHE.BATTLENET
    local onlineFriendsCounter = 0

    for i = 1, numWoWTotal do
        local info = CACHE.WOW[i]
        if info and info.connected then
            DATA.ONLINE[info.name] = true
            onlineFriendsCounter = onlineFriendsCounter + 1
        elseif DATA.ONLINE[info.name] then
            DATA.ONLINE[info.name] = nil
        end
    end

    for i = 1, numBNetTotal do
        local accountInfo = CACHE.BATTLENET[i]
        if accountInfo then
            local characterName = accountInfo.gameAccountInfo.characterName
            local client = accountInfo.gameAccountInfo.clientProgram
            local isOnline = accountInfo.gameAccountInfo.isOnline
            if client == BNET_CLIENT_WOW and isOnline then
                DATA.ONLINE[characterName] = true
                onlineFriendsCounter = onlineFriendsCounter + 1
            elseif DATA.ONLINE[characterName] then
                DATA.ONLINE[characterName] = nil
            end
        end
    end

    return DATA.ONLINE, onlineFriendsCounter
end

function Friends:GetNumOnlineFriendsInfo()
    local numWoWTotal, numWoWOnline = self.GetNumFriends(), self.GetNumOnlineFriends()
    local numBNetTotal, numBNetOnline = self.BNGetNumFriends()
    return numWoWTotal, numWoWOnline, numBNetTotal, numBNetOnline
end

function Friends:ResetConnectedFriendsCounter()
    connectedFriendsCounter = 0
end

function Friends:IterableWoWFriendsInfo()
    local maxOnlineFriends, friendInfo, characterName, grouped, sameZone, status
    local i = 0
    local n = #CACHE.WOW
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

            friendInfo = CACHE.WOW[i]

            if friendInfo and friendInfo.connected then
                connectedFriendsCounter = connectedFriendsCounter + 1

                characterName = friendInfo.name

                if friendInfo.afk then
                    status = 3
                elseif friendInfo.dnd then
                    status = 4
                else
                    status = 2
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
                DATA.WOW.characterLevel = friendInfo.level
                DATA.WOW.className = friendInfo.className
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
    local characterName, characterLevel, className, grouped, zoneName, sameZone, status, accountName, realmName, sameRealm, clientProgram, appearOffline, isFavorite
    local i = 0
    local n = #CACHE.BATTLENET
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

            accountInfo = CACHE.BATTLENET[i]

            if accountInfo and accountInfo.gameAccountInfo.isOnline then
                connectedFriendsCounter = connectedFriendsCounter + 1

                accountName = accountInfo.accountName
                appearOffline = accountInfo.appearOffline
                isFavorite = accountInfo.isFavorite

                characterName =  accountInfo.gameAccountInfo.characterName
                zoneName =  accountInfo.gameAccountInfo.areaName
                realmName =  accountInfo.gameAccountInfo.realmName or ""
                clientProgram = accountInfo.gameAccountInfo.clientProgram

                if accountInfo.isAFK or accountInfo.gameAccountInfo.isGameAFK then
                    status = 3
                elseif accountInfo.isDND or accountInfo.gameAccountInfo.isGameBusy then
                    status = 4
                else
                    status = 2
                end

                if characterName then
                    if clientProgram == BNET_CLIENT_WOW then
                        clientProgram = accountInfo.gameAccountInfo.richPresence == BNET_FRIEND_TOOLTIP_WOW_CLASSIC and BNET_FRIEND_TOOLTIP_WOW_CLASSIC or clientProgram
                        characterLevel =  accountInfo.gameAccountInfo.characterLevel
                        className = accountInfo.gameAccountInfo.className

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
                    elseif clientProgram ~= BNET_CLIENT_APP then
                        characterName = BNet_GetValidatedCharacterName(characterName, friendAccountInfo.battleTag, clientProgram)
                    end
                end

                DATA.BATTLENET.characterName = characterName
                DATA.BATTLENET.characterLevel = characterLevel
                DATA.BATTLENET.className = className
                DATA.BATTLENET.grouped = grouped
                DATA.BATTLENET.zoneName = zoneName
                DATA.BATTLENET.sameZone = sameZone
                DATA.BATTLENET.status = status
                DATA.BATTLENET.accountName = accountName
                DATA.BATTLENET.realmName = realmName
                DATA.BATTLENET.sameRealm = sameRealm
                DATA.BATTLENET.clientProgram = clientProgram
                DATA.BATTLENET.appearOffline = appearOffline
                DATA.BATTLENET.isFavorite = isFavorite

                return DATA.BATTLENET
            end
            i = i + 1
        end
    end
end
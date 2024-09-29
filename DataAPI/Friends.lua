local _, addon = ...
local Friends = addon:NewObject("Friends")

local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local BNET_CLIENT_APP = BNET_CLIENT_APP
local BNET_FRIEND_TOOLTIP_WOW_CLASSIC = BNET_FRIEND_TOOLTIP_WOW_CLASSIC

local INFO = {
    WOW = {},
    BATTLENET = {},
    ONLINE_FRIENDS = {}
}

local CACHE = {
    WOW = {},
    BATTLENET = {}
}

local function CacheFriendsInfoHelper(cache, getNumFriends, getFriendInfo)
    local numTotal = getNumFriends()
    for i = 1, math.max(#cache, numTotal) do
        local info = getFriendInfo(i)
        if info and cache[i] then
            cache[i] = info
        elseif not info then
            cache[i] = nil
        else
            table.insert(cache, info)
        end
    end
end

local function CacheFriendsInfo()
    CacheFriendsInfoHelper(CACHE.WOW, C_FriendList.GetNumFriends, C_FriendList.GetFriendInfoByIndex)
end

local function CacheFriendsAccountInfo()
    CacheFriendsInfoHelper(CACHE.BATTLENET, BNGetNumFriends, C_BattleNet.GetFriendAccountInfo)
end

Friends:RegisterEvents(
    "PLAYER_LOGIN",
    "FRIENDLIST_UPDATE",
    "BN_FRIEND_INFO_CHANGED",
    "BN_INFO_CHANGED", function(self, eventName)
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
            INFO.ONLINE_FRIENDS[info.name] = true
            onlineFriendsCounter = onlineFriendsCounter + 1
        elseif INFO.ONLINE_FRIENDS[info.name] then
            INFO.ONLINE_FRIENDS[info.name] = nil
        end
    end

    for i = 1, numBNetTotal do
        local accountInfo = CACHE.BATTLENET[i]
        if accountInfo then
            local characterName = accountInfo.gameAccountInfo.characterName
            local client = accountInfo.gameAccountInfo.clientProgram
            local isOnline = accountInfo.gameAccountInfo.isOnline
            if client == BNET_CLIENT_WOW and isOnline then
                INFO.ONLINE_FRIENDS[characterName] = true
                onlineFriendsCounter = onlineFriendsCounter + 1
            elseif INFO.ONLINE_FRIENDS[characterName] then
                INFO.ONLINE_FRIENDS[characterName] = nil
            end
        end
    end

    return INFO.ONLINE_FRIENDS, onlineFriendsCounter
end

function Friends:GetNumOnlineFriendsInfo()
    local numWoWTotal, numWoWOnline = C_FriendList.GetNumFriends(), C_FriendList.GetNumOnlineFriends()
    local numBNetTotal, numBNetOnline = BNGetNumFriends()
    return numWoWTotal, numWoWOnline, numBNetTotal, numBNetOnline
end

function Friends:IterableWoWFriendsInfo()
    local connectedFriends, maxOnlineFriends = 0, 0
    local friendInfo, characterName, grouped, sameZone, status
    local i = 0
    local n = #CACHE.WOW
    return function()
        maxOnlineFriends = self.storage:GetMaxOnlineFriends("WOW")
        if maxOnlineFriends == 0 then
            return
        end
        i = i + 1
        while i <= n do
            if connectedFriends >= maxOnlineFriends then
                return
            end

            friendInfo = CACHE.WOW[i]

            if friendInfo and friendInfo.connected then
                connectedFriends = connectedFriends + 1

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

                INFO.WOW.characterName = characterName
                INFO.WOW.characterLevel = friendInfo.level
                INFO.WOW.className = friendInfo.className
                INFO.WOW.grouped = grouped
                INFO.WOW.zoneName = friendInfo.area
                INFO.WOW.sameZone = sameZone
                INFO.WOW.status = status

                return INFO.WOW
            end
            i = i + 1
        end
    end
end

function Friends:IterableBattleNetFriendsInfo()
    local connectedFriends, maxOnlineFriends = 0, 0
    local friendAccountInfo, accountInfo
    local characterName, characterLevel, className, grouped, zoneName, sameZone, status, accountName, realmName, sameRealm, clientProgram, appearOffline, isFavorite
    local i = 0
    local n = #CACHE.BATTLENET
    return function()
        maxOnlineFriends = self.storage:GetMaxOnlineFriends("BN")
        if maxOnlineFriends == 0 then
            return
        end
        i = i + 1
        while i <= n do
            if connectedFriends >= maxOnlineFriends then
                return
            end

            accountInfo = CACHE.BATTLENET[i]

            if accountInfo and accountInfo.gameAccountInfo.isOnline then
                connectedFriends = connectedFriends + 1

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

                INFO.BATTLENET.characterName = characterName
                INFO.BATTLENET.characterLevel = characterLevel
                INFO.BATTLENET.className = className
                INFO.BATTLENET.grouped = grouped
                INFO.BATTLENET.zoneName = zoneName
                INFO.BATTLENET.sameZone = sameZone
                INFO.BATTLENET.status = status
                INFO.BATTLENET.accountName = accountName
                INFO.BATTLENET.realmName = realmName
                INFO.BATTLENET.sameRealm = sameRealm
                INFO.BATTLENET.clientProgram = clientProgram
                INFO.BATTLENET.appearOffline = appearOffline
                INFO.BATTLENET.isFavorite = isFavorite

                return INFO.BATTLENET
            end
            i = i + 1
        end
    end
end
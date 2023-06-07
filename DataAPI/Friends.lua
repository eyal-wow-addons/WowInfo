local _, addon = ...
local Friends = addon:NewObject("Friends")

Friends.GetNumFriends = C_FriendList.GetNumFriends
Friends.GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
Friends.BNGetNumFriends = BNGetNumFriends
Friends.GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo

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
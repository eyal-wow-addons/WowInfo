local _, addon = ...
local Friends = addon:NewObject("Friends")

function Friends:GetOnlineFriendsInfo()
    local numWoWTotal = C_FriendList.GetNumFriends()
    local numBNetTotal = BNGetNumFriends()
    local onlineFriendsCounter = 0
    local onlineFriends

    for i = 1, numWoWTotal do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            onlineFriends = onlineFriends or {}
            onlineFriends[info.name] = true
            onlineFriendsCounter = onlineFriendsCounter + 1
        end
    end

    for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
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
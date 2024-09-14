local _, addon = ...
local Friends = addon:GetObject("Friends")
local Guild = addon:NewObject("Guild")

local tinsert = table.insert

Guild.GuildRoster = C_GuildInfo.GuildRoster
Guild.GetNumGuildMembers = GetNumGuildMembers
Guild.GetGuildRosterInfo = GetGuildRosterInfo

local DATA = {}
local CACHE = {}

local function CacheGuildRosterInfo()
    local numTotal = Guild.GetNumGuildMembers()
    local characterName, characterLevel, zoneName, online, status, classFilename, isMobile
    for i = 1, math.max(#CACHE, numTotal) do
        characterName, _, _, characterLevel, _, zoneName, _, _, online, status, classFilename, _, _, isMobile = Guild.GetGuildRosterInfo(i)

        if characterName then
            characterName = Ambiguate(characterName, "guild")

            if status == 1 then
                status = 3
            elseif status == 2 then
                status = 4
            elseif online then
                status = 2
            else
                status = 1
            end
        end

        if characterName and CACHE[i] then
            CACHE[i].characterName = characterName
            CACHE[i].characterLevel = characterLevel
            CACHE[i].zoneName = zoneName
            CACHE[i].online = online
            CACHE[i].status = status
            CACHE[i].classFilename = classFilename
            CACHE[i].isMobile = isMobile
        elseif not characterName then
            CACHE[i] = nil
        else
            tinsert(CACHE, {
                characterName = characterName,
                characterLevel = characterLevel,
                zoneName = zoneName,
                online = online,
                status = status,
                classFilename = classFilename,
                isMobile = isMobile
            })
        end
    end
end

Friends:RegisterEvents(
    "FRIENDLIST_UPDATE",
    "BN_FRIEND_INVITE_ADDED",
    "BN_FRIEND_INVITE_REMOVED",
    "BN_CONNECTED",
    "BN_DISCONNECTED",
    "GUILD_ROSTER_UPDATE", function(_, eventName)
        if eventName == "GUILD_ROSTER_UPDATE" then
            CacheGuildRosterInfo()
        else
            Guild.GuildRoster()
        end
    end)

function Guild:IterableGuildRosterInfo(index)
    local memberInfo, sameZone, grouped
    local onlineFriendsLookupTable = Friends:GetOnlineFriendsInfo()
    local i = index or 0
    local n = #CACHE
    return function()
        if not onlineFriendsLookupTable then
            return
        end
        i = i + 1
        if i <= n then
            memberInfo = CACHE[i]

            if memberInfo.zone then
                if GetRealZoneText() == memberInfo.zone then
                    sameZone = true
                else
                    sameZone = false
                end
            end

            if UnitInParty(memberInfo.characterName) or UnitInRaid(memberInfo.characterName) then
                grouped = true
            else
                grouped = false
            end

            DATA.characterName = memberInfo.characterName
            DATA.characterLevel = memberInfo.characterLevel
            DATA.classFilename = memberInfo.classFilename
            DATA.grouped = grouped
            DATA.zoneName = memberInfo.zoneName
            DATA.sameZone = sameZone
            DATA.status = memberInfo.status
            DATA.isMobile = memberInfo.isMobile
            DATA.isFriend = onlineFriendsLookupTable[memberInfo.characterName]

            return i, DATA
        end
    end
end

function Guild:GetTotalOnlineFriends()
    local onlineGuildFriendsCounter = 0
    local onlineGuildFriendsMobileCounter = 0
    for _, info in self:IterableGuildRosterInfo() do
        if info.isFriend then
            if info.status > 1 then
                onlineGuildFriendsCounter = onlineGuildFriendsCounter + 1
            elseif info.isMobile then
                onlineGuildFriendsMobileCounter = onlineGuildFriendsMobileCounter + 1
            end
        end
    end
    return onlineGuildFriendsCounter, onlineGuildFriendsMobileCounter
end

function Guild:IterableOnlineFriendsInfo()
    local maxOnlineGuildFriends = Guild.storage:GetMaxOnlineFriends()
    local onlineGuildFriendsCounter = 0
    local i = 0
    return function()
        if maxOnlineGuildFriends <= 0 then
            return
        end
        for index, info in self:IterableGuildRosterInfo(i) do
            if onlineGuildFriendsCounter >= maxOnlineGuildFriends then
                return
            end
            i = index
            if info.isFriend and info.status > 1 then
                onlineGuildFriendsCounter = onlineGuildFriendsCounter + 1
                return info
            end
        end
    end
end

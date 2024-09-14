local _, addon = ...
local Friends = addon:GetObject("Friends")
local Guild = addon:NewObject("Guild")

local tinsert = table.insert

Guild.GuildRoster = C_GuildInfo.GuildRoster
Guild.GetNumGuildMembers = GetNumGuildMembers
Guild.GetGuildRosterInfo = GetGuildRosterInfo

local DATA = {}

local CACHE = {}

local function CacheGuildFriendsInfo()
    local onlineFriendsLookupTable = Friends:GetOnlineFriendsInfo()

    if not onlineFriendsLookupTable then
        return
    end

    local numTotal = Guild.GetNumGuildMembers()
    local i2 = 1
    local characterName, characterLevel, zoneName, online, status, classFilename, isMobile

    for i = 1, numTotal do
        characterName, _, _, characterLevel, _, zoneName, _, _, online, status, classFilename, _, _, isMobile = Guild.GetGuildRosterInfo(i)

        if characterName then
            characterName = Ambiguate(characterName, "guild")

            if onlineFriendsLookupTable[characterName] then
                if status == 1 then
                    status = 3
                elseif status == 2 then
                    status = 4
                elseif online then
                    status = 2
                else
                    status = 1
                end

                if CACHE[i2] then
                    CACHE[i2].characterName = characterName
                    CACHE[i2].characterLevel = characterLevel
                    CACHE[i2].zoneName = zoneName
                    CACHE[i2].online = online
                    CACHE[i2].status = status
                    CACHE[i2].classFilename = classFilename
                    CACHE[i2].isMobile = isMobile
                    -- print("CacheGuildFriendsInfo", i2, "UPDATE")
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
                    -- print("CacheGuildFriendsInfo", #CACHE, numTotal, "INSERT")
                end

                i2 = i2 + 1
            end
        end
    end

    for i = i2, #CACHE do
        CACHE[i] = nil
        -- print("CacheGuildFriendsInfo", i, "REMOVE")
    end

    Guild.__rosterCached = true
end

Guild:RegisterEvents(
    "PLAYER_LOGIN",
    "FRIENDLIST_UPDATE",
    "GUILD_ROSTER_UPDATE",
    "BN_FRIEND_INFO_CHANGED",
    "BN_INFO_CHANGED", function(self, eventName, ...)
        local canRequestRosterUpdate = ...
        if (eventName == "GUILD_ROSTER_UPDATE" and canRequestRosterUpdate) or eventName ~= "GUILD_ROSTER_UPDATE" then
            self.GuildRoster()
            self.__rosterCached = false
        end
    end)

function Guild:IterableGuildFriendsInfo(index)
    if not self.__rosterCached then
        CacheGuildFriendsInfo()
    end
    local memberInfo, sameZone, grouped
    local i = index or 0
    local n = #CACHE
    return function()
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

            return i, DATA
        end
    end
end

function Guild:GetTotalOnlineFriends()
    local onlineGuildFriendsCounter = 0
    local onlineGuildFriendsMobileCounter = 0
    for _, info in self:IterableGuildFriendsInfo() do
        if info.status > 1 then
            onlineGuildFriendsCounter = onlineGuildFriendsCounter + 1
        elseif info.isMobile then
            onlineGuildFriendsMobileCounter = onlineGuildFriendsMobileCounter + 1
        end
    end
    return onlineGuildFriendsCounter, onlineGuildFriendsMobileCounter
end

function Guild:IterableOnlineFriendsInfo()
    local maxOnlineGuildFriends = self.storage:GetMaxOnlineFriends()
    local onlineGuildFriendsCounter = 0
    local i = 0
    return function()
        if maxOnlineGuildFriends <= 0 then
            return
        end
        for index, info in self:IterableGuildFriendsInfo(i) do
            if onlineGuildFriendsCounter >= maxOnlineGuildFriends then
                return
            end
            i = index
            if info.status > 1 then
                onlineGuildFriendsCounter = onlineGuildFriendsCounter + 1
                return info
            end
        end
    end
end

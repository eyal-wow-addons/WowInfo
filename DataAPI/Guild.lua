local _, addon = ...
local Friends = addon:GetObject("Friends")
local Guild = addon:NewObject("Guild")

Guild.GuildRoster = C_GuildInfo.GuildRoster
Guild.GetNumGuildMembers = GetNumGuildMembers
Guild.GetGuildRosterInfo = GetGuildRosterInfo

local DATA = {}

function Guild:IterableGuildRosterInfo(index)
    Guild.GuildRoster()
    local sameZone, grouped
    local characterName, characterLevel, zone, online, status, classFilename, isMobile
    local onlineFriendsLookupTable = Friends:GetOnlineFriendsInfo()
    local i = index or 0
    local n = Guild.GetNumGuildMembers()
    return function()
        if not onlineFriendsLookupTable then
            return
        end
        i = i + 1
        if i <= n then
            characterName, _, _, characterLevel, _, zone, _, _, online, status, classFilename, _, _, isMobile = Guild.GetGuildRosterInfo(i)

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

            if zone then
                if GetRealZoneText() == zone then
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

            DATA.characterName = characterName
            DATA.characterLevel = characterLevel
            DATA.classFilename = classFilename
            DATA.grouped = grouped
            DATA.zoneName = zone
            DATA.sameZone = sameZone
            DATA.status = status
            DATA.isMobile = isMobile
            DATA.isFriend = onlineFriendsLookupTable[characterName]

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

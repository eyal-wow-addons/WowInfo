local _, addon = ...
local L = addon.L
local Guild = addon:NewObject("Guild")
local Friends = addon.Friends

Guild.GuildRoster = C_GuildInfo.GuildRoster
Guild.GetNumGuildMembers = GetNumGuildMembers
Guild.GetGuildRosterInfo = GetGuildRosterInfo

local GUILD_ON_MOBILE_ICON_FORMAT = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:0|t %s"

function Guild:GetTotalOnlineFriends()
    local onlineGuildFriendsCounter = 0
    local onlineGuildFriendsMobileCounter = 0

    for _, isFriend, _, _, online, _, _, isMobile in self:IterableGuildRosterInfo() do
        if isFriend then
            if online then
                onlineGuildFriendsCounter = onlineGuildFriendsCounter + 1
            elseif isMobile then
                onlineGuildFriendsMobileCounter = onlineGuildFriendsMobileCounter + 1
            end
        end
    end

    return onlineGuildFriendsCounter, onlineGuildFriendsMobileCounter
end

function Guild:IterableGuildRosterInfo(index)
    local onlineFriendsLookupTable = Friends:GetOnlineFriendsInfo()

    Guild.GuildRoster()

    local i = index or 0
    local n = Guild.GetNumGuildMembers()
    return function()
        if not onlineFriendsLookupTable then
            return
        end
        i = i + 1
        if i <= n then
            local isFriend = false
            local name, _, _, _, _, zone, _, _, online, status, className, _, _, isMobile = Guild.GetGuildRosterInfo(i)

            name = Ambiguate(name, "guild")

            if status == 1 then
                status = L["AFK"]
            elseif status == 2 then
                status = L["DND"]
            else
                status = ""
            end

            if onlineFriendsLookupTable[name] then
                isFriend = true
            end

            return i, isFriend, name, zone, online, status, className, isMobile
        end
    end
end

function Guild:IterableOnlineFriendsInfo()
    local maxOnlineGuildFriends = Guild.storage:GetMaxOnlineFriends()
    local onlineGuildFriendsCounter = 0
    local i = 0
    return function()
        if maxOnlineGuildFriends <= 0 then
            return
        end
        for index, isFriend, name, zone, online, status, className, isMobile in self:IterableGuildRosterInfo(i) do
            if onlineGuildFriendsCounter >= maxOnlineGuildFriends then
                return
            end
            i = index
            if isFriend then
                local classColor = RAID_CLASS_COLORS[className]
                name = WrapTextInColor(name, classColor)
                if not online then
                    zone = nil
                    if isMobile then
                        name = GUILD_ON_MOBILE_ICON_FORMAT:format(name)
                    end
                else
                    onlineGuildFriendsCounter = onlineGuildFriendsCounter + 1
                end
                if zone then
                    return name .. status, WrapTextInColor(zone, WHITE_FONT_COLOR)
                else
                    return name
                end
            end
        end
    end
end

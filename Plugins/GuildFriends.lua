local _, addon = ...
local plugin = addon:NewPlugin("GuildFriends")

local Tooltip = addon.Tooltip
local GuildFriendsDB = addon.GuildFriendsDB

local GUILD_TOTAL_FRIENDS_LABEL_FORMAT = "Guild Friends (%d):"
local GUILD_ON_MOBILE_ICON_FORMAT = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:0|t %s"

local GUILD_FRIEND_AFK = " |cffff0000<AFK>|r"
local GUILD_FRIEND_DND = " |cffff0000<DND>|r"

plugin:RegisterHookScript(GuildMicroButton, "OnEnter", function()
    local maxOnlineGuildFriends = GuildFriendsDB:GetMaxOnlineGuildFriends()
    if maxOnlineGuildFriends == 0 then return end

    local numWoWTotal = C_FriendList.GetNumFriends()
    local numBNetTotal = BNGetNumFriends()
    local friends, counter = {}, 0

    for i = 1, numWoWTotal do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            friends[info.name] = true
            counter = counter + 1
        end
    end

    for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        local characterName = accountInfo.gameAccountInfo.characterName
        local client = accountInfo.gameAccountInfo.clientProgram
        local isOnline = accountInfo.gameAccountInfo.isOnline
        if client == BNET_CLIENT_WOW and isOnline  then
            friends[characterName] = true
            counter = counter + 1
        end
    end

    local guildFriends = {}
    if counter > 0 then
        counter = 1

        C_GuildInfo.GuildRoster()
        local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers()
        for i = 1, numTotalMembers do
            local name, _, _, _, _, zone, _, _, online, status, class, _, _, isMobile = GetGuildRosterInfo(i)
            name = Ambiguate(name, "guild")
            if counter >= maxOnlineGuildFriends then
                break
            elseif friends[name] then
                if status == 1 then
                    status = GUILD_FRIEND_AFK
                elseif status == 2 then
                    status = GUILD_FRIEND_DND
                else
                    status = ""
                end
                table.insert(guildFriends, {name, zone, online, status, class, isMobile})
                counter = counter + 1
            end
        end
    end

    local totalGuildFriends = #guildFriends
    if totalGuildFriends > 0 then
        Tooltip:AddEmptyLine()
        Tooltip:AddHighlightLine(GUILD_TOTAL_FRIENDS_LABEL_FORMAT:format(totalGuildFriends))
        for _, data in ipairs(guildFriends) do
            local name, zone, online, status, class, isMobile = unpack(data)
            if not online then
                zone = nil
                if isMobile then
                    name = GUILD_ON_MOBILE_ICON_FORMAT:format(name)
                end
            end
            if zone then
                local color = RAID_CLASS_COLORS[class]
                Tooltip:AddRightHighlightDoubleLine(name .. status, zone, color.r, color.g, color.b)
            else
                Tooltip:AddDoubleLine(name, zone, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
            end
        end
    end

    Tooltip:Show()
end)

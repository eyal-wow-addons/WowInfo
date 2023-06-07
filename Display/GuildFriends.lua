local _, addon = ...
local Display = addon:NewDisplay("GuildFriends")
local Guild = addon.Guild

local GUILD_TOTAL_FRIENDS_LABEL_FORMAT = "Guild Friends (%d):"

Display:RegisterHookScript(GuildMicroButton, "OnEnter", function()
    local totalOnlineGuildFriends = Guild:GetTotalOnlineFriends()
    if totalOnlineGuildFriends > 0 then
        Display:AddEmptyLine()
        Display:AddHighlightLine(GUILD_TOTAL_FRIENDS_LABEL_FORMAT:format(totalOnlineGuildFriends))
        for nameString, zoneString in Guild:IterableOnlineFriendsInfo() do
            if zoneString then
                Display:AddDoubleLine(nameString, zoneString)
            else
                Display:AddDoubleLine(nameString, zoneString, GRAY_FONT_COLOR:GetRGB())
            end
        end 
        Display:Show()
    end
end)

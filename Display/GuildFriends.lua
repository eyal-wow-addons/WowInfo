local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("GuildFriends")
local Guild = addon.Guild

Display:RegisterHookScript(GuildMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end
    
    local numTotalGuildMembers, numOnlineGuildMembers = Guild:GetNumGuildMembers()
    if numTotalGuildMembers > 0 then
        Display:AddTitleLine(L["X Members Y Online"]:format(numTotalGuildMembers, numOnlineGuildMembers))
        local totalOnlineGuildFriends = Guild:GetTotalOnlineFriends()
        if totalOnlineGuildFriends > 0 then
            Display:AddTitleLine(L["Guild Friends (X):"]:format(totalOnlineGuildFriends))
            for nameString, zoneString in Guild:IterableOnlineFriendsInfo() do
                if zoneString then
                    Display:AddDoubleLine(nameString, zoneString)
                else
                    Display:AddDoubleLine(nameString, zoneString, GRAY_FONT_COLOR:GetRGB())
                end
            end 
        end
        Display:Show()
    end
end)

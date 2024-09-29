local _, addon = ...
local Guild = addon:GetObject("Guild")
local Display = addon:NewDisplay("GuildFriends", "Friends")

local L = addon.L

Display:RegisterHookScript(GuildMicroButton, "OnEnter", function(self)
    if not self:IsEnabled() then
        return
    end

    local numTotalGuildMembers, numOnlineGuildMembers = GetNumGuildMembers()

    if numTotalGuildMembers > 0 then
        Display:AddFormattedHeader(L["X Members Y Online"], numTotalGuildMembers, numOnlineGuildMembers)

        local totalOnlineGuildFriends = Guild:GetTotalOnlineFriends()

        if totalOnlineGuildFriends > 0 then
            Display:AddFormattedHeader(L["Guild Friends (X):"], totalOnlineGuildFriends)

            for info in Guild:IterableOnlineFriendsInfo() do
                local charName = Display:GetFormattedCharName(info)
                charName = Display:GetFormattedStatus(info, charName)

                Display:SetLine(charName)

                if IsShiftKeyDown() and info.zoneName then
                    Display:SetLine(info.zoneName)

                    if info.sameZone then
                        Display:SetGreenColor()
                    else
                        Display:SetGrayColor()
                    end
                end

                Display:ToLine()
            end
        end

        Display:Show()
    end
end)

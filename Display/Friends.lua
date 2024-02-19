if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local Display = addon:NewDisplay("Friends")
local Friends = addon.Friends

local FRIENDS_WOW_ONLINE_LABEL_FORMAT = "World of Warcraft (%d):"
local FRIENDS_BNET_ONLINE_LABEL_FORMAT = "Battle.net (%d):"

Display:RegisterHookScript(QuickJoinToastButton, "OnEnter", function()
    local _, numWoWOnline, _, numBNetOnline = Friends:GetNumOnlineFriendsInfo()

    if (numBNetOnline + numWoWOnline) > 0 then
        Friends:ResetConnectedFriendsCounter()

        if numWoWOnline > 0 then
            Display:AddEmptyLine()
            Display:AddHighlightLine(FRIENDS_WOW_ONLINE_LABEL_FORMAT:format(numWoWOnline))

            for friendString, zoneString in Friends:IterableWoWFriendsInfo() do
                Display:AddDoubleLine(friendString, zoneString)
            end
        end

        if numBNetOnline > 0 then
            Display:AddEmptyLine()
            Display:AddHighlightLine(FRIENDS_BNET_ONLINE_LABEL_FORMAT:format(numBNetOnline))

            for accountString, zoneString, realmString, clientProgram in Friends:IterableBattleNetFriendsInfo() do
                Display:AddRightHighlightDoubleLine(accountString, clientProgram)

                if IsShiftKeyDown() and zoneString then
                    Display:AddIndentedDoubleLine(zoneString, realmString)
                end
            end
        end

        Display:Show()
    end
end)

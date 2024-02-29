if not QuickJoinToastButton:IsVisible() then return end

local _, addon = ...
local L = addon.L
local Display = addon:NewDisplay("Friends")
local Friends = addon.Friends

Display:RegisterHookScript(QuickJoinToastButton, "OnEnter", function()
    local _, numWoWOnline, _, numBNetOnline = Friends:GetNumOnlineFriendsInfo()

    if (numBNetOnline + numWoWOnline) > 0 then
        Friends:ResetConnectedFriendsCounter()

        if numWoWOnline > 0 then
            Display:AddTitleLine(L["World of Warcraft (X):"]:format(numWoWOnline))

            for friendString, zoneString in Friends:IterableWoWFriendsInfo() do
                Display:AddDoubleLine(friendString, zoneString)
            end
        end

        if numBNetOnline > 0 then
            Display:AddTitleLine(L["Battle.net (X):"]:format(numBNetOnline))

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

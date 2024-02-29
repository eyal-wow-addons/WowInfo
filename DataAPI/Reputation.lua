local _, addon = ...
local L = addon.L
local Reputation = addon:NewObject("Reputation")

local ICON_AVAILABLE_REWARD = " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local STANDING_PROGRESS_FORMAT = "%s / %s"

local function GetFactionDisplayInfoByID(factionID)
    if factionID then
        local factionName = GetFactionInfoByID(factionID)
        if factionName then
            local _, _, standingID, repMin, repMax, repValue = GetFactionInfoByID(factionID)
            local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            local isCapped

            local gender = UnitSex("player")
            local standing = GetText("FACTION_STANDING_LABEL" .. standingID, gender)
            local standingColor = FACTION_BAR_COLORS[standingID]

            local hasParagonRewardPending = false

            if repInfo.friendshipFactionID > 0 then
                if repInfo.nextThreshold then
                    repMin, repMax, repValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
                else
                    repMin, repMax, repValue = 0, 1, 1
                    isCapped = true
                end
                standingID = 5 -- Always color friendship factions with green
                standing = repInfo.reaction
            elseif C_Reputation.IsFactionParagon(factionID) then
                local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
                repMin, repMax, repValue = 0, threshold, currentValue % threshold
                standingColor = LIGHTBLUE_FONT_COLOR
                if not tooLowLevelForParagon and hasRewardPending then
                    hasParagonRewardPending = true
                    factionName = factionName .. ICON_AVAILABLE_REWARD
                end
            elseif C_Reputation.IsMajorFaction(factionID) then
                local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
                local rewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, majorFactionData.renownLevel)
                repMin, repMax = 0, majorFactionData.renownLevelThreshold
                isCapped = C_MajorFactions.HasMaximumRenown(factionID)
                repValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
                standingColor = BLUE_FONT_COLOR
                factionName = L["S (Renown X)"]:format(factionName, majorFactionData.renownLevel)
                if #rewards > 0 then
                    local rewardInfo = rewards[1]
                    if rewardInfo.itemID
                        or rewardInfo.mountID
                        or rewardInfo.spellID
                        or rewardInfo.titleMaskID
                        or rewardInfo.transmogID
                        or rewardInfo.transmogSetID
                        or rewardInfo.garrFollowerID
                        or rewardInfo.transmogIllusionSourceID then
                        factionName = factionName .. ICON_AVAILABLE_REWARD
                    end
                end
            else
                if (standingID == MAX_REPUTATION_REACTION) then
                    isCapped = true;
                end
            end

            repMax = repMax - repMin
            repValue = repValue - repMin

            repMax = AbbreviateNumbers(repMax)
            repValue = AbbreviateNumbers(repValue)
            factionName = standingColor:WrapTextInColorCode(factionName)

            return factionName, standing, isCapped, repValue, repMax, hasParagonRewardPending
        end
    end
end

local function GetFactionID(index)
    return select(14, GetFactionInfo(index))
end

function Reputation:IterableTrackedFactions()
    local i = 0
    local n = GetNumFactions()
    return function()
        i = i + 1
        while i <= n do
            local factionID = GetFactionID(i)
            local factionName, standing, isCapped, repValue, repMax, hasParagonRewardPending = GetFactionDisplayInfoByID(factionID)
            if Reputation.storage:HasFactionsTracked() and Reputation.storage:IsSelectedFaction(factionID) or (Reputation.storage:GetAlwaysShowParagon() and hasParagonRewardPending) then
                return factionName, standing, isCapped, STANDING_PROGRESS_FORMAT:format(repValue, repMax)
            end
            i = i + 1
        end
    end
end
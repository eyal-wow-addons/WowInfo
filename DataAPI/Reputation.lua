local _, addon = ...
local Reputation = addon:NewObject("Reputation")

local GetNumFactions = C_Reputation.GetNumFactions
local GetFactionDataByID = C_Reputation.GetFactionDataByID
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local IsFactionParagon = C_Reputation.IsFactionParagon
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local IsMajorFaction = C_Reputation.IsMajorFaction
local GetMajorFactionData = C_MajorFactions.GetMajorFactionData
local GetRenownRewardsForLevel = C_MajorFactions.GetRenownRewardsForLevel
local HasMaximumRenown = C_MajorFactions.HasMaximumRenown
local UnitSex = UnitSex
local GetText = GetText

local DATA = {}

local function GetFactionDisplayInfoByID(factionID)
    if factionID then
        local factionData = GetFactionDataByID(factionID)
        if factionData and factionData.name then
            local factionName, standingID, repMin, repMax, repValue = factionData.name, factionData.reaction, factionData.currentReactionThreshold, factionData.nextReactionThreshold, factionData.currentStanding
            local repInfo = GetFriendshipReputation(factionID)
            
            local gender = UnitSex("player")
            local standing = GetText("FACTION_STANDING_LABEL" .. standingID, gender)

            local isCapped = false
            local isFactionParagon = false
            local isMajorFaction = false
            local renownLevel = 0
            local hasReward = false

            if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0 then
                if repInfo.nextThreshold then
                    repMin, repMax, repValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
                else
                    repMin, repMax, repValue = 0, 1, 1
                    isCapped = true
                end
                standingID = 5 -- Always color friendship factions with green
                standing = repInfo.reaction
            elseif IsFactionParagon(factionID) then
                local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = GetFactionParagonInfo(factionID)
                repMin, repMax, repValue = 0, threshold, currentValue % threshold
                if not tooLowLevelForParagon and hasRewardPending then
                    hasReward = true
                end
                isFactionParagon = true
            elseif IsMajorFaction(factionID) then
                local majorFactionData = GetMajorFactionData(factionID)
                local rewards = GetRenownRewardsForLevel(factionID, majorFactionData.renownLevel)
                repMin, repMax = 0, majorFactionData.renownLevelThreshold
                isCapped = HasMaximumRenown(factionID)
                repValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
                renownLevel = majorFactionData.renownLevel
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
                            hasReward = true
                    end
                end
                isMajorFaction = true
            else
                if (standingID == MAX_REPUTATION_REACTION) then
                    isCapped = true
                end
            end

            repMax = repMax - repMin
            repValue = repValue - repMin

            DATA.factionName = factionName
            DATA.standing = standing
            DATA.standingID = standingID
            DATA.isCapped = isCapped
            DATA.progressValue = repValue
            DATA.progressMax = repMax
            DATA.factionType = (isFactionParagon and 1) or (isMajorFaction and 2) or 0
            DATA.hasReward = hasReward
            DATA.renownLevel = renownLevel

            return DATA
        end
    end
end

function Reputation:HasTrackedFactions()
    for factionID in self.storage:IterableTrackedFactions() do
        return true
    end
    return false
end

function Reputation:IterableTrackedFactions()
    local i = 0
    local n = GetNumFactions()
    return function()
        i = i + 1
        while i <= n do
            local factionID = self.storage:GetTrackedFaction(i)
            if factionID then
                return GetFactionDisplayInfoByID(factionID)
            end
            i = i + 1
        end
    end
end
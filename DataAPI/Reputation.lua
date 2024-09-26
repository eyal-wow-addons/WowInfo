local _, addon = ...
local Reputation = addon:NewObject("Reputation")

local GetNumFactions = C_Reputation.GetNumFactions
local ExpandFactionHeader = C_Reputation.ExpandFactionHeader
local CollapseFactionHeader = C_Reputation.CollapseFactionHeader
local GetFactionDataByIndex = C_Reputation.GetFactionDataByIndex
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

local CACHE = {
    count = 0
}

local function CreateFactionInfo(factionID)
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
            DATA.isAccountWide = factionData.isAccountWide

            return DATA
        end
    end
end

local function HasParagonRewardPending(factionID)
    local hasParagonRewardPending = false
    if factionID then
        if IsFactionParagon(factionID) then
            local _, _, _, hasRewardPending, tooLowLevelForParagon = GetFactionParagonInfo(factionID)
            if not tooLowLevelForParagon and hasRewardPending then
                hasParagonRewardPending = true
            end
        end
    end
    return hasParagonRewardPending
end

local function IsTrackedFaction(factionID)
    local shouldAlwaysShowParagon = Reputation.storage:GetAlwaysShowParagon() and HasParagonRewardPending(factionID)
    if factionID and Reputation.storage:IsSelectedFaction(factionID) or shouldAlwaysShowParagon then
        return true
    end
    return false
end

local function CacheFactionData(self)
    if self.__cachedNumFactions ~= CACHE.count then
        local i = 1
        local factionData = GetFactionDataByIndex(i)
        local headerCollapsedState = {}
        while factionData do
            if factionData.isHeader and factionData.isCollapsed then
                headerCollapsedState[i] = true
                ExpandFactionHeader(i)
            end
            i = i + 1
            factionData = GetFactionDataByIndex(i)
        end
        local categoryName
        for i = 1, GetNumFactions() do
            local factionData = GetFactionDataByIndex(i)
            if factionData then
                if not CACHE[i] then
                    CACHE[i] = {}
                end
                if factionData.isHeader and not factionData.isChild then
                    categoryName = factionData.name
                end
                CACHE[i].categoryName = categoryName
                CACHE[i].name = factionData.name
                CACHE[i].factionID = factionData.factionID
                CACHE[i].isHeader = factionData.isHeader
                CACHE[i].isHeaderWithRep = factionData.isHeaderWithRep
                CACHE[i].isChild = factionData.isChild
            else
                CACHE[i] = nil
            end
            CACHE.count = i
        end
        for k in pairs(headerCollapsedState) do
            CollapseFactionHeader(k)
            headerCollapsedState[k] = nil
        end
        self.__cachedNumFactions = CACHE.count
    end
end

Reputation:RegisterEvents(
    "PLAYER_LOGIN",
    "MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
	"MAJOR_FACTION_UNLOCKED",
	"UPDATE_FACTION", CacheFactionData)

function Reputation:GetFactionListInfoByIndex(index)
    return CACHE[index]
end

function Reputation:GetNumFactions()
    return CACHE.count
end

function Reputation:HasTrackedFactions()
    for i = 1, self:GetNumFactions() do
        local info = self:GetFactionListInfoByIndex(i)
        if info and IsTrackedFaction(info.factionID) then
            return true
        end
    end
    return false
end

function Reputation:IterableTrackedFactionsInfo()
    local i = 0
    local n = self:GetNumFactions()
    return function()
        i = i + 1
        while i <= n do
            local info = self:GetFactionListInfoByIndex(i)
            if info and IsTrackedFaction(info.factionID) then
                return CreateFactionInfo(info.factionID), info.categoryName
            end
            i = i + 1
        end
    end
end
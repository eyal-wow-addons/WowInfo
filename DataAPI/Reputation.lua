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

local tinsert = table.insert

local INFO = {}

local CACHE = {
    count = 0
}

local function CreateFactionProgressInfo(factionData)
    local factionID = factionData.factionID
    local standingID = factionData.reaction
    local repMin, repMax, repValue = factionData.currentReactionThreshold, factionData.nextReactionThreshold, factionData.currentStanding

    local gender = UnitSex("player")
    local standing = GetText("FACTION_STANDING_LABEL" .. standingID, gender)

    local progressType = 0
    local renownLevel = 0
    local isCapped, hasReward = false, false

    if IsMajorFaction(factionID) then
        local majorFactionData = GetMajorFactionData(factionID)
        repMin, repMax = 0, majorFactionData.renownLevelThreshold
        isCapped = HasMaximumRenown(factionID)
        repValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
        renownLevel = majorFactionData.renownLevel
        if isCapped then
            standing = MAJOR_FACTION_MAX_RENOWN_REACHED
        else
            standing = MAJOR_FACTION_RENOWN_LEVEL_TOAST:format(renownLevel)
        end
        local _, _, rewardQuestID, hasRewardPending, tooLowLevelForParagon = GetFactionParagonInfo(factionID)
        if not tooLowLevelForParagon and (rewardQuestID or hasRewardPending) then
			hasReward = true
		end
        progressType = 3
    elseif IsFactionParagon(factionID) then
        local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = GetFactionParagonInfo(factionID)
        repMin, repMax, repValue = 0, threshold, currentValue % threshold
        if not tooLowLevelForParagon and hasRewardPending then
            hasReward = true
        end
        progressType = 2
    else
        local repInfo = GetFriendshipReputation(factionID)
        if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0 then
            if repInfo.nextThreshold then
                repMin, repMax, repValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
            else
                repMin, repMax, repValue = 0, 1, 1
                isCapped = true
            end
            standingID = 5 -- Always color friendship factions with green
            standing = repInfo.reaction
            progressType = 1
        elseif standingID == MAX_REPUTATION_REACTION then
            isCapped = true
            repMin, repMax, repValue = 0, 1, 1
        end
    end

    repMax = repMax - repMin
    repValue = repValue - repMin

    INFO.type = progressType
    INFO.standing = standing
    INFO.renownLevel = renownLevel
    INFO.standingID = standingID
    INFO.isCapped = isCapped
    INFO.currentValue = repValue
    INFO.maxValue = repMax
    INFO.hasReward = hasReward

    return INFO
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

local function CacheFactionData(self, eventName)
    local progressInfo
    if self.__cachedNumFactions ~= CACHE.count then
        -- NOTE: 'ExpandFactionHeader' and 'CollapseFactionHeader' trigger UPDATE_FACTION and may cause infinite recursion,
        -- so we are unregistering the event before these functions are called and registering it again after they are called.
        self:UnregisterEvent("UPDATE_FACTION")

        local i = 1
        local headerName
        local collapsedIndexes = {}
        local factionData = GetFactionDataByIndex(i)
        while factionData do
            if factionData then
                if factionData.factionID == 0 then
                    -- NOTE: The 'Inactive' header holds hidden factions that aren't displayed in the default UI so break out.
                    break
                end
                
                if factionData.isCollapsed then
                    ExpandFactionHeader(i)
                    tinsert(collapsedIndexes, i)
                end

                local cachedData = CACHE[i]

                if not cachedData then
                    CACHE[i] = {
                        progressInfo = {}
                    }
                    cachedData = CACHE[i]
                end

                -- Top level header
                if factionData.isHeader and not factionData.isChild then
                    headerName = factionData.name
                end

                cachedData.headerName = headerName
                cachedData.factionName = factionData.name
                cachedData.factionID = factionData.factionID
                cachedData.isHeader = factionData.isHeader
                cachedData.isHeaderWithRep = factionData.isHeaderWithRep
                cachedData.isChild = factionData.isChild
                cachedData.isAccountWide = factionData.isAccountWide

                progressInfo = CreateFactionProgressInfo(factionData)

                cachedData.progressInfo.type = progressInfo.type
                cachedData.progressInfo.standing = progressInfo.standing
                cachedData.progressInfo.renownLevel = progressInfo.renownLevel
                cachedData.progressInfo.standingID = progressInfo.standingID
                cachedData.progressInfo.isCapped = progressInfo.isCapped
                cachedData.progressInfo.currentValue = progressInfo.currentValue
                cachedData.progressInfo.maxValue = progressInfo.maxValue
                cachedData.progressInfo.hasReward = progressInfo.hasReward
            end
            CACHE.count = i
            i = i + 1
            factionData = GetFactionDataByIndex(i)
        end

        for i = #collapsedIndexes, 1, -1 do
            local collapsedIndex = collapsedIndexes[i]
            CollapseFactionHeader(collapsedIndex)
            collapsedIndexes[i] = nil
        end

        self.__cachedNumFactions = CACHE.count
        self:RegisterEvent("UPDATE_FACTION", CacheFactionData)
    end
    for i = 1, CACHE.count do
        local cachedData = CACHE[i]
        if cachedData then
            local factionData = GetFactionDataByID(cachedData.factionID)
            if factionData then
                progressInfo = CreateFactionProgressInfo(factionData)
                cachedData.progressInfo.standing = progressInfo.standing
                cachedData.progressInfo.renownLevel = progressInfo.renownLevel
                cachedData.progressInfo.standingID = progressInfo.standingID
                cachedData.progressInfo.isCapped = progressInfo.isCapped
                cachedData.progressInfo.currentValue = progressInfo.currentValue
                cachedData.progressInfo.maxValue = progressInfo.maxValue
                cachedData.progressInfo.hasReward = progressInfo.hasReward
            end
        end
    end
end

Reputation:RegisterEvent("PLAYER_LOGIN", function(self, eventName)
    CacheFactionData(self, eventName)
    self:RegisterEvents(
        "MAJOR_FACTION_RENOWN_LEVEL_CHANGED", 
        "MAJOR_FACTION_UNLOCKED",
        "UPDATE_FACTION", CacheFactionData)
end)

function Reputation:GetFactionDataByIndex(index)
    return CACHE[index]
end

function Reputation:GetNumFactions()
    return CACHE.count
end

function Reputation:HasTrackedFactions()
    for i = 1, self:GetNumFactions() do
        local data = self:GetFactionDataByIndex(i)
        if data and IsTrackedFaction(data.factionID) then
            return true
        end
    end
    return false
end

function Reputation:IterableTrackedFactionsData()
    local i = 0
    local n = self:GetNumFactions()
    return function()
        i = i + 1
        while i <= n do
            local data = self:GetFactionDataByIndex(i)
            if data and IsTrackedFaction(data.factionID) then
                return data, data.progressInfo
            end
            i = i + 1
        end
    end
end
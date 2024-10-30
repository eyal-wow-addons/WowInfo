local _, addon = ...
local Delves = addon:NewObject("Delves")

local INFO = {
    seasonNumber = 0
}

local CACHE = {
    Renown = {},
    Companion = {}
}

local MIN_REP_RANK_FOR_REWARDS = 1
local MIN_REP_THRESHOLD_BAR_VALUE = MIN_REP_RANK_FOR_REWARDS - 1
local MAX_REP_RANK_FOR_REWARDS = 10

local function CacheFactionData()
    local renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(C_DelvesUI.GetDelvesFactionForSeason())
    local renownLevel = renownInfo.renownLevel
    local value = renownInfo.renownReputationEarned / renownInfo.renownLevelThreshold

    local companionFactionID = C_DelvesUI.GetFactionForCompanion(Constants.DelvesConsts.BRANN_COMPANION_INFO_ID)
    local companionFactionInfo = C_Reputation.GetFactionDataByID(companionFactionID)
    local friendshipData = C_GossipInfo.GetFriendshipReputation(companionFactionID)

    CACHE.Renown.currentValue = renownInfo and (RoundToSignificantDigits(renownInfo.renownLevel + value, 1)) or 0
    
    CACHE.Companion.name = companionFactionInfo.name

    if friendshipData and friendshipData.friendshipFactionID > 0 then
        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID)
        if rankInfo.maxLevel > 0 then
            CACHE.Companion.currentLevel = rankInfo.currentLevel
            CACHE.Companion.maxLevel = rankInfo.maxLevel
        end
    else
        CACHE.Companion.currentLevel = 0
        CACHE.Companion.maxLevel = 0
	end
end

Delves:RegisterEvent("PLAYER_LOGIN", function(self, eventName)
    CacheFactionData()
    self:RegisterEvents(
        "MAJOR_FACTION_RENOWN_LEVEL_CHANGED", 
        "MAJOR_FACTION_UNLOCKED",
        "UPDATE_FACTION", CacheFactionData)
end)

function Delves:GetProgressInfo()
    local seasonNumber = C_DelvesUI.GetCurrentDelvesSeasonNumber()
    local isActiveSeason = seasonNumber and seasonNumber > 0

    if isActiveSeason and CACHE.Renown.currentValue > 0 then
        local currExpID = GetExpansionLevel()
        local expName = _G["EXPANSION_NAME"..currExpID]

        INFO.seasonNumber = seasonNumber
        INFO.expansion = expName
        INFO.currentValue = CACHE.Renown.currentValue
        INFO.maxValue = MAX_REP_RANK_FOR_REWARDS
        INFO.companionName = CACHE.Companion.name
        INFO.companionLevel = CACHE.Companion.currentLevel
        INFO.companionMaxLevel = CACHE.Companion.maxLevel

        return INFO
    end
end
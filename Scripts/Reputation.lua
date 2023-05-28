local _, addon = ...
local module = addon:NewModule("Scripts:Reputation")
local ScriptLoader = addon.ScriptLoader
local Tooltip = addon.Tooltip
local ReputationDB = addon.ReputationDB

local REPUTATION_LABEL = "Reputation:"
local STANDING_FORMAT = "%s / %s"
local FACTION_NAME_FORMAT = "|cff%.2x%.2x%.2x%s|r"

local factions = {}

local function GetFactionDisplayInfoByID(factionID)
    if factionID then
        local factionName = GetFactionInfoByID(factionID)
        if factionName then
            local _, _, standingID, repMin, repMax, repValue = GetFactionInfoByID(factionID)
            local friendID = C_GossipInfo.GetFriendshipReputation(factionID)
            local isCapped

            local gender = UnitSex("player")
            local standing = GetText("FACTION_STANDING_LABEL" .. standingID, gender)
            local standingColor = FACTION_BAR_COLORS[standingID]

            local hasParagonRewardPending = false

            if friendID then
                local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = C_GossipInfo.GetFriendshipReputation(factionID)
                if nextFriendThreshold then
                    repMin, repMax, repValue = friendThreshold, nextFriendThreshold, friendRep
                else
                    repMin, repMax, repValue = 0, 1, 1
                    isCapped = true
                end
                standingID = 5 -- Always color friendship factions with green
                standing = friendTextLevel
            elseif C_Reputation.IsFactionParagon(factionID) then
                local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
                repMin, repMax, repValue = 0, threshold, currentValue % threshold
                standingColor = LIGHTBLUE_FONT_COLOR
                if not tooLowLevelForParagon and hasRewardPending then
                    hasParagonRewardPending = true
                    factionName = factionName .. " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
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
            factionName = FACTION_NAME_FORMAT:format(standingColor.r * 255, standingColor.g * 255, standingColor.b * 255, factionName)

            return factionName, standing, isCapped, repValue, repMax, hasParagonRewardPending
        end
    end
end

ScriptLoader:AddHookScript(CharacterMicroButton, "OnEnter", function()
    local factionName, standing, isCapped, repValue, repMax, hasParagonRewardPending

    wipe(factions)

    for index = 1, GetNumFactions() do
        local factionID =  select(14, GetFactionInfo(index))
        factionName, standing, isCapped, repValue, repMax, hasParagonRewardPending = GetFactionDisplayInfoByID(factionID)
        if ReputationDB:HasFactionsTracked() and ReputationDB:IsSelectedFaction(factionID) or (ReputationDB:GetAlwaysShowParagon() and hasParagonRewardPending) then
            table.insert(factions, {factionName, standing, isCapped, repValue, repMax})
        end
    end

    if #factions > 0 then
        Tooltip:AddEmptyLine()
        Tooltip:AddHighlightLine(REPUTATION_LABEL)

        for _, data in ipairs(factions) do
            local factionName, standing, isCapped, repValue, repMax = unpack(data)
            if isCapped then
                Tooltip:AddRightHighlightDoubleLine(factionName, standing)
            else
                Tooltip:AddRightHighlightDoubleLine(factionName, STANDING_FORMAT:format(repValue, repMax))
            end
        end

        Tooltip:Show()
    end
end)

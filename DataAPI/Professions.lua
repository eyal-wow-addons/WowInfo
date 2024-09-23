local _, addon = ...
local Professions = addon:NewObject("Professions")

local PROFESIONS_RANK_FORMAT = "%d / %d"
local PROFESIONS_RANK_WITH_MODIFIER_FORMAT = "%d |cff20ff20+ %d|r / %d"
local PROFESIONS_LABEL_FORMAT = "%s - %s"
local PROFESIONS_INDICES_MAP = {}

Professions:RegisterEvent("PLAYER_LOGIN", function()
    ProfessionsBook_LoadUI()
end)

function Professions:IterableProfessionInfo()
    local prof1, prof2, arch, fish, cook = GetProfessions()
    PROFESIONS_INDICES_MAP[1] = prof1 or -1
    PROFESIONS_INDICES_MAP[2] = prof2 or -1
    PROFESIONS_INDICES_MAP[3] = arch or -1
    PROFESIONS_INDICES_MAP[4] = fish or -1
    PROFESIONS_INDICES_MAP[5] = cook or -1
    local i = 0
    local n = #PROFESIONS_INDICES_MAP
    local hasProfessions = false
    return function()
        i = i + 1
        while i <= n do
            local index = PROFESIONS_INDICES_MAP[i]
            if index > -1 then
                if not hasProfessions then
                    Professions:TriggerEvent("PROFESSIONS_SHOW_PROGRESS")
                    hasProfessions = true
                end

                local skillTitle, skillRankString
                local name, texture, rank, maxRank, _, _, _, rankModifier, _, _, skillLineName = GetProfessionInfo(index)

                if skillLineName then
                    skillTitle = skillLineName
                else
                    for j=1, #PROFESSION_RANKS do
                        local value, title = PROFESSION_RANKS[j][1], PROFESSION_RANKS[j][2]
                        if maxRank < value then break end
                        skillTitle = title
                    end
                end

                if rankModifier > 0 then
                    skillRankString = PROFESIONS_RANK_WITH_MODIFIER_FORMAT:format(rank, rankModifier, maxRank)
                else
                    skillRankString = PROFESIONS_RANK_FORMAT:format(rank, maxRank)
                end

                return PROFESIONS_LABEL_FORMAT:format(name, skillTitle), texture, skillRankString
            end
            i = i + 1
        end
    end
end
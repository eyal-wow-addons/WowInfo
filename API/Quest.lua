local _, addon = ...
local Quest = {}
addon.Quest = Quest

local QuestResetTimeSecondsFormatter = CreateFromMixins(SecondsFormatterMixin)
QuestResetTimeSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, false)

function Quest:GetResetTime()
    return QuestResetTimeSecondsFormatter:Format(GetQuestResetTime())
end


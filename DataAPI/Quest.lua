local _, addon = ...
local Quest = addon:NewObject("Quest")

local QuestResetTimeSecondsFormatter = CreateFromMixins(SecondsFormatterMixin)
QuestResetTimeSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, false)

function Quest:GetResetTimeString()
    return QuestResetTimeSecondsFormatter:Format(GetQuestResetTime())
end


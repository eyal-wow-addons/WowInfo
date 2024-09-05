local _, addon = ...
local Friends = addon:GetObject("Friends")

local Colorizer = addon.Colorizer

local WOW_CHAR_FORMAT = "%s |cffffffff%d|r"
local WOW_CHAR_GROUPED_FORMAT = "|cffaaaaaa[|r%s|cffaaaaaa]|r"
local GAME_STATUS_TABLE = { FRIENDS_TEXTURE_OFFLINE, FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND }
local GAME_STATUS_FORMAT = "|T%s:0|t %s"

function Friends:GetFormattedCharName(info)
    local classFileName = info.className and addon.CLASS_NAMES[info.className] or info.classFileName
    local charName = Colorizer:ToClassColor(classFileName, info.characterName)
    charName = info.characterLevel and WOW_CHAR_FORMAT:format(charName, info.characterLevel)
    charName = info.grouped and WOW_CHAR_GROUPED_FORMAT:format(charName) or charName
    return charName
end

function Friends:GetFormattedStatus(info, name)
    return info.status and GAME_STATUS_FORMAT:format(GAME_STATUS_TABLE[info.status], name) or name
end
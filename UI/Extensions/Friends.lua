local _, addon = ...
local Friends = addon:NewExtension("Friends")

local WOW_CHAR_FORMAT = "%s |cffffffff%d|r"
local WOW_CHAR_GROUPED_FORMAT = "|cffaaaaaa[|r%s|cffaaaaaa]|r"
local GAME_STATUS_TABLE = { FRIENDS_TEXTURE_OFFLINE, FRIENDS_TEXTURE_ONLINE, FRIENDS_TEXTURE_AFK, FRIENDS_TEXTURE_DND }
local GAME_STATUS_FORMAT = "|T%s:0|t %s"

function Friends:GetFormattedCharName(friend)
    local classFilename = friend.className and addon.CLASS_NAMES[friend.className] or friend.classFilename
    local charName = Friends:ToClassColor(classFilename, friend.characterName)
    charName = friend.characterLevel and WOW_CHAR_FORMAT:format(charName, friend.characterLevel)
    charName = friend.grouped and WOW_CHAR_GROUPED_FORMAT:format(charName) or charName
    return charName
end

function Friends:GetFormattedStatus(friend, name)
    return friend.status and GAME_STATUS_FORMAT:format(GAME_STATUS_TABLE[friend.status], name) or name
end
local _, addon = ...
local options = addon:NewOptions("AceEvent-3.0")

local MoneyDB = addon:GetStorage("Money")
local GuildFriendsDB = addon:GetDB("GuildFriends")
local SocialDB = addon:GetDB("Social")
local ReputationDB = addon:GetDB("Reputation")

local function CreateReputationOptions()
    local args = {}
    local prevTable

    table.insert(args, {
        type = "toggle",
        name = "Always Show Paragon Rewards",
        descStyle = "hidden",
        width = "full",
        handler = ReputationDB,
        get = function(self)
            return self.handler:GetAlwaysShowParagon()
        end,
        set = function(self)
            self.handler:ToggleAlwaysShowParagon()
        end
    })


    local parentName
    for index = 1, GetNumFactions() do
        local name, _, _, _, _, _, _, _, isHeader, _, hasRep, _, isChild, factionID = GetFactionInfo(index)
        if isHeader and not hasRep and not isChild then
            parentName = name
        end
        if isHeader then
            if isChild and parentName then
                name = parentName .. " - " .. name
            end
            prevTable = {
                name = name,
                type = "group",
                inline = true,
                args = {}
            }
            table.insert(args, prevTable)
        else
            table.insert(prevTable.args, {
                name = name,
                type = "toggle",
                descStyle = "hidden",
                width = "full",
                handler = ReputationDB,
                get = function(self)
                    return self.handler:IsSelectedFaction(factionID)
                end,
                set = function(self)
                    self.handler:ToggleFaction(factionID)
                end
            })
        end
    end

    for index, parent in ipairs(args) do
        if parent.args and #parent.args == 0 then 
            table.remove(args, index) 
        end
    end

    return args
end

local function BuildOptions()
    addon.AceOptions:RegisterOptions({
        name = "WowInfo",
        type = "group",
        args = {
            {
                type = "description",
                name = function()
                    return GetAddOnMetadata("WowInfo", "Notes")
                end,
                cmdHidden = true,
            },
            {
                type = "separator"
            },
            {
                type = "description",
                name = "",
            },
        },
    })

    if MainMenuBarBackpackButton:IsVisible() then
        addon.AceOptions:RegisterOptions({
            type = "group",
            name = "Money",
            inline = true,
            handler = MoneyDB,
            args = {
                {
                    type = "toggle",
                    name = "Hide Connected Realms Names",
                    descStyle = "hidden",
                    width = "full",
                    get = function(self)
                        return self.handler:IsConnectedRealmsNamesHidden()
                    end,
                    set = function(self)
                        self.handler:ToggleConnectedRealmsNames()
                    end
                },
                {
                    type = "toggle",
                    name = "Show All Characters",
                    descStyle = "hidden",
                    width = "full",
                    get = function(self)
                        return self.handler:CanShowAllCharacters()
                    end,
                    set = function(self)
                        self.handler:ToggleShowAllCharacters()
                    end
                },
                {
                    type = "description",
                    name = "\n" .. "Show only characters that has more than specified amount of |TInterface\\MoneyFrame\\UI-GoldIcon:0:0:0:-1|t money:",
                },
                {
                    type = "input",
                    name = "",
                    get = function(self)
                        return tostring(self.handler:GetMinMoneyAmount())
                    end,
                    set = function(self, value)
                        self.handler:SetMinMoneyAmount(value)
                    end,
                    validate = function(info, value)
                        if value ~= nil and value ~= "" and (not tonumber(value) or tonumber(value) >= 2^31) then
                            return false;
                        end
                        return true
                    end,
                    disabled = function(self)
                        return self.handler:CanShowAllCharacters()
                    end
                },
                {
                    type = "newline"
                },
                {
                    type = "execute",
                    name = "Reset Money Information",
                    descStyle = "hidden",
                    width = "double",
                    func = function(self)
                        self.handler:Reset()
                    end
                }
            }
        })
    end

    addon.AceOptions:RegisterOptions({
        type = "group",
        name = "Guild & Communities",
        inline = true,
        handler = GuildFriendsDB,
        args = {
            {
                type = "range",
                name = "Maximum Friends Online",
                descStyle = "hidden",
                width = "double",
                step = 1,
                min = 0,
                max = 50,
                get = function(self)
                    return self.handler:GetMaxOnlineGuildFriends()
                end,
                set = function(self, value)
                    self.handler:SetMaxOnlineGuildFriends(value)
                end
            },
        }
    })

    if QuickJoinToastButton:IsVisible() then
        addon.AceOptions:RegisterOptions({
            type = "group",
            name = "Social",
            inline = true,
            handler = SocialDB,
            args = {
                {
                    type = "range",
                    name = "Maximum Friends Online",
                    width = "double",
                    descStyle = "hidden",
                    step = 1,
                    min = 0,
                    max = 50,
                    get = function(self)
                        return self.handler:GetMaxOnlineFriends()
                    end,
                    set = function(self, value)
                        self.handler:SetMaxOnlineFriends(value)
                    end
                },
            }
        })
    end

    addon.AceOptions:RegisterOptions({
        name = "Reputation",
        type = "group",
        args = CreateReputationOptions()
    })

    BuildOptions = function() end 
end

function options:OnInitialize()
    SLASH_WOWINFO1 = "/wowinfo"
    SLASH_WOWINFO2 = "/wowi"
    SLASH_WOWINFO2 = "/wi"
    SlashCmdList["WOWINFO"] = function(input)
        HideUIPanel(GameMenuFrame)
        BuildOptions()
        InterfaceOptionsFrame_OpenToCategory("WowInfo")
        InterfaceOptionsFrame_OpenToCategory("WowInfo")
    end
end

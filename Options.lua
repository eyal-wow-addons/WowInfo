local _, addon = ...
local Options = addon:NewObject("Options")
local MoneyDB = addon:GetStorage("Money")
local GuildDB = addon:GetStorage("Guild")
local FriendsDB = addon:GetStorage("Friends")
local ReputationDB = addon:GetStorage("Reputation")
local CurrencyDB = addon:GetStorage("Currency")

local function CreateReputationOptions()
    local args = {}
    local prevTable

    table.insert(args, {
        type = "description",
        name = "Display the reputation status for the tracked factions in the tooltip of the Character Info button.",
    })

    table.insert(args, {
        type = "separator"
    })

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
    for i = 1, GetNumFactions() do
        local name, _, _, _, _, _, _, _, isHeader, _, hasRep, _, isChild, factionID = GetFactionInfo(i)
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

    for i, parent in ipairs(args) do
        if parent.args and #parent.args == 0 then 
            table.remove(args, i) 
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

    addon.AceOptions:RegisterOptions({
        type = "group",
        name = "Money",
        inline = true,
        handler = MoneyDB,
        args = {
            {
                type = "description",
                name = "Display the total money information for all characters in the tooltip of the Backpack.",
            },
            {
                type = "separator"
            },
            {
                type = "toggle",
                name = "Hide Connected Realms Names",
                descStyle = "hidden",
                width = "full",
                get = function(self)
                    return MoneyDB:IsConnectedRealmsNamesHidden()
                end,
                set = function(self)
                    MoneyDB:ToggleConnectedRealmsNames()
                end
            },
            {
                type = "toggle",
                name = "Show All Characters",
                descStyle = "hidden",
                width = "full",
                get = function(self)
                    return MoneyDB:CanShowAllCharacters()
                end,
                set = function(self)
                    MoneyDB:ToggleShowAllCharacters()
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
                    return tostring(MoneyDB:GetMinMoneyAmount())
                end,
                set = function(self, value)
                    MoneyDB:SetMinMoneyAmount(value)
                end,
                validate = function(info, value)
                    if value ~= nil and value ~= "" and (not tonumber(value) or tonumber(value) >= 2^31) then
                        return false;
                    end
                    return true
                end,
                disabled = function(self)
                    return MoneyDB:CanShowAllCharacters()
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
                    MoneyDB:Reset()
                end
            }
        }
    })

    addon.AceOptions:RegisterOptions({
        type = "group",
        name = "Guild & Communities",
        inline = true,
        handler = GuildDB,
        args = {
            {
                type = "description",
                name = "Display the status of your guild friends in the tooltip of the Guild & Communities button."
            },
            {
                type = "separator"
            },
            {
                type = "range",
                name = "Maximum Friends Online",
                descStyle = "hidden",
                width = "double",
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

    addon.AceOptions:RegisterOptions({
        type = "group",
        name = "Social",
        inline = true,
        handler = FriendsDB,
        args = {
            {
                type = "description",
                name = "Display the status of your friends in the tooltip of the Social button."
            },
            {
                type = "separator"
            },
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

    addon.AceOptions:RegisterOptions({
        name = "Reputation",
        type = "group",
        args = CreateReputationOptions()
    })

    addon.AceOptions:RegisterOptions({
        type = "group",
        name = "Currency",
        inline = true,
        handler = CurrencyDB,
        args = {
            {
                type = "description",
                name = "Display the currency amount per character in the tooltip of the Currency Tab."
            },
            {
                type = "separator"
            },
            {
                type = "execute",
                name = "Reset Currency Data",
                descStyle = "hidden",
                width = "double",
                func = function(self)
                    CurrencyDB:Reset()
                end
            }
        }
    })

    BuildOptions = function() end
end

function Options:OnInitialize()
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

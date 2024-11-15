local _, addon = ...
local Storage, DB = addon:NewStorage("TooltipManager")

local defaults = {
    profile = {
        Disabled = {},
        Order = {
            ["CharacterMicroButton"] = {
                "Currency",
                "Durability",
                "GreatVaultProgress",
                "Reputation"
            },
            ["ProfessionMicroButton"] = {
                "Professions"
            },
            ["PlayerSpellsMicroButton"] = {
                "Talents"
            },
            ["AchievementMicroButton"] = {
                "Achievements"
            },
            ["QuestLogMicroButton"] = {
                "Quests"
            },
            ["GuildMicroButton"] = {
                "GuildFriends"
            },
            ["LFDMicroButton"] = {
                "PvE",
                "Delves",
                "PvP"
            },
            ["CollectionsMicroButton"] = {
                "Collections"
            },
            ["EJMicroButton"] = {
                "MonthlyActivities"
            },
            ["MainMenuBarBackpackButton"] = {
                "Money"
            },
            ["QuickJoinToastButton"] = {
                "Friends"
            }
        }
    }
}

local function IsObjectTooltip(object)
    local name = object:GetName()
    return name and name:find(".Tooltip$") and object.target
end

local function RegisterTooltip(tooltip)
    local target = tooltip.target
    local frame = target.button or target.frame
    if frame then
        if target.onEnter then
            frame:HookScript("OnEnter", function(frame)
                if frame.IsEnabled and not frame:IsEnabled() then
                    return
                end
            
                if frame == AchievementMicroButton and addon.MicroMenu:SetButtonTooltip(frame, ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT") then
                    return
                end

                if target.title then
                    tooltip:AddHeader(target.title)
                end

                target.onEnter()
                tooltip:Show()
            end)
        end
        if target.onLeave then
            frame:HookScript("OnLeave", function(frame)
                tooltip:Hide()
                target.onLeave()
            end)
        end
    elseif target.funcName then
        if target.table then
            hooksecurefunc(target.table, target.funcName, function(...)
                target.func(...)
                tooltip:Show()
            end)
        else
            hooksecurefunc(target.funcName, function(...)
                target.func(...)
                tooltip:Show()
            end)
        end
    end
    tooltip.isTooltipRegistered = true
end

local function IterableTooltips()
    local frameName, tooltips 
    return function()
        frameName, tooltips = next(DB.profile.Order, frameName)
        return frameName, tooltips
    end
end

local function RegisterTooltips()
    for frameName, tooltips in IterableTooltips() do
        for index, name in ipairs(tooltips) do
            local tooltip = addon:GetTooltip(name)
            RegisterTooltip(tooltip)
        end
    end
    -- NOTE: Register tooltips that are fixed to a frame and don't appear in the `Order` table.
    for object in addon:IterableObjects() do
        if IsObjectTooltip(object) and not object.isTooltipRegistered then
            RegisterTooltip(object)
        end
    end
end

function Storage:OnInitialized()
    DB = self:RegisterDB(defaults)

    RegisterTooltips()
end

function Storage:Disable(name)
    DB.profile.Disabled[name] = true
end

function Storage:Enable(name)
    DB.profile.Disabled[name] = false
end

function Storage:IsDisabled(name)
    return DB.profile.Disabled[name] == true
end


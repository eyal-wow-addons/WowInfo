local addonName, addon = ...

local Objects = {}
local Callbacks = {}
local Addons = {}
Callbacks["PLAYER_LOGIN"] = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, eventName, ...)
    if eventName == "ADDON_LOADED" then
        local arg1 = ...
        if arg1 == addonName or Addons[arg1] then
            for i, object in ipairs(Objects) do
                local callback = object.OnInitialize
                if callback then
                    callback(object)
                    object.OnInitialize = nil
                end
            end
        end
    elseif eventName == "PLAYER_LOGIN" then
        for _, object in ipairs(Objects) do
            local callback = object.OnBeforeConfig
            if callback then
                callback(object)
            end
        end
        for _, object in ipairs(Objects) do
            local callback = object.OnConfig
            if callback then
                callback(object)
            end
        end
        self:UnregisterEvent(eventName)
    end
    Callbacks:TriggerEvent(eventName, ...)
end)

function Callbacks:RegisterCallback(callback)
    table.insert(Callbacks["PLAYER_LOGIN"], callback)
end

function Callbacks:RegisterHookScript(frame, eventName, callback)
    self:RegisterCallback(function()
        frame:HookScript(eventName, callback)
    end)
end

function Callbacks:RegisterEvent(eventName, callback)
    if eventName == "ADDON_LOADED" then
        return
    end
    local callbacks = Callbacks[eventName]
    if not callbacks then
        callbacks = {}
        Callbacks[eventName] = callbacks
        if C_EventUtils.IsEventValid(eventName) then
            frame:RegisterEvent(eventName)
        end
    end
    table.insert(callbacks, callback)
end

function Callbacks:RegisterEvents(...)
    local eventNames = {}
    local callback
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        if type(arg) == "string" and arg ~= "ADDON_LOADED" then
            table.insert(eventNames, arg)
        elseif type(arg) == "function" then
            callback = arg
            break
        end
    end
    if callback then
        for _, eventName in ipairs(eventNames) do
            self:RegisterEvent(eventName, callback)
        end
    end
end

function Callbacks:UnregisterEvent(eventName, callback)
    if eventName == "ADDON_LOADED" then
        return
    end
    local callbacks = Callbacks[eventName]
    if callbacks then
        for i = #callbacks, 1, -1 do
            local registeredCallback = callbacks[i]
            if not callback or registeredCallback == callback then
                table.remove(Callbacks[eventName], i)
                if callback then
                    break
                end
            end
        end
        if #Callbacks[eventName] == 0 then
            if C_EventUtils.IsEventValid(eventName) then
                frame:UnregisterEvent(eventName)
            end
            Callbacks[eventName] = nil
        elseif not callback then
            Callbacks[eventName] = nil
        end
    end
end

function Callbacks:TriggerEvent(eventName, ...)
    local callbacks = Callbacks[eventName]
    if callbacks then
        for _, callback in ipairs(callbacks) do
            callback(self, eventName, ...)
        end
    end
end

do
    table.insert(Objects, addon)

    local function New(name)
        local object = addon[name]

        if not object then
            object = {}
            addon[name] = object
        end

        table.insert(Objects, object)

        for key, value in pairs(Callbacks) do
            if type(value) == "function" and not object[key] then
                object[key] = value
            end
        end

        return object
    end

    function addon:NewObject(name)
        local object = New(name)

        --Mixin(object, ...)

        local storage = addon[name .. "Storage"]

        if storage then
            object.storage = storage
        end

        return object
    end

    function addon:NewStorage(name)
        local storage = New(name .. "Storage")
        
        function storage:RegisterDB(defaults)
            return addon.DB:RegisterNamespace(name, defaults)
        end

        return storage
    end

    function addon:GetStorage(name)
        return addon[name .. "Storage"]
    end

    WowInfo = {}

    function WowInfo:NewAddon(name, tbl)
        Addons[name] = tbl
        return setmetatable(tbl, { __index = addon })
    end
end



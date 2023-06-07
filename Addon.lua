local addonName, addon = ...

local Objects = {}
local Callbacks = {}
Callbacks["PLAYER_LOGIN"] = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, eventName, ...)
    if eventName == "ADDON_LOADED" then
        local arg1 = ...
        if arg1 == addonName then
            for _, object in ipairs(Objects) do
                local callback = object.OnInitialize
                if callback then
                    callback(object)
                end
            end
            self:UnregisterEvent(eventName)
        end
    elseif eventName == "PLAYER_LOGIN" then
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
        for i, registeredCallbacks in ipairs(callbacks) do
            if registeredCallbacks == callback then
                Callbacks[eventName][i] = nil
            end
        end
        if #Callbacks[eventName] == 0 then
            if C_EventUtils.IsEventValid(eventName) then
                frame:UnregisterEvent(eventName)
            end
            Callbacks[eventName] = nil
        end
    end
end

function Callbacks:TriggerEvent(eventName, ...)
    local callbacks = Callbacks[eventName]
    if callbacks then
        for _, callback in ipairs(callbacks) do
            callback(eventName, ...)
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

        local db = addon[name .. "DB"]

        if db then
            object.db = db
        end

        return object
    end

    function addon:NewStorage(name)
        local db = New(name .. "DB")
        
        function db:RegisterDB(defaults)
            db.options = addon.DB:RegisterNamespace(name, defaults)
        end

        return db
    end

    function addon:GetStorage(name)
        return addon[name .. "DB"]
    end
end



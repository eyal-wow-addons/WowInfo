local _, addon = ...

local API = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    frame[event](self, ...)
    self:UnregisterEvent(event)
end)

do
    local queue = {}

    function frame:PLAYER_LOGIN()
        for index = 1, #queue do
            local func = queue[index]
            func(index)
            queue[index] = nil
        end
        for key, plugins in pairs(queue) do
            for index, plugin in ipairs(plugins) do 
                plugin(key, index)
            end
            queue[key] = nil
        end
    end

    function API:RegisterScript(key, func)
        local plugin = queue[key]
        if not plugin then
            queue[key] = {}
            plugin = queue[key]
        end
        tinsert(plugin, func)
    end

    function API:RegisterFunction(func)
        tinsert(queue, func)
    end
end

function API:RegisterHookScript(frame, event, func)
    self:RegisterScript(frame, function()
        frame:HookScript(event, func)
    end)
end

do
    local function new(name, scope, ...)
        local moduleName

        if scope then
            moduleName = "WowInfo[" .. scope .. "]:" .. name
        else
            moduleName = "WowInfo:" .. name
        end

        local module = addon:NewModule(moduleName, ...)

        for name, func in pairs(API) do
            if not module[name] then
                module[name] = func
            end
        end

        return module
    end

    function addon:NewPlugin(name, ...)
        local db
        
        if addon[name .. "DB"] then
            db = addon[name .. "DB"]
        end

        return new(name, "Plugin", ...), db
    end

    function addon:NewStorage(name, ...)
        local db = addon[name .. "DB"]

        if not db then
            db = {}
            addon[name .. "DB"] = db
        end

        local module =  new(name, "Storage", ...)
        
        function module:RegisterDB(defaults)
            return addon.DB:RegisterNamespace(name, defaults)
        end

        return module, db
    end

    function addon:GetDB(name)
        return addon[name .. "DB"]
    end

    function addon:NewOptions(...)
        return new("Options", nil, ...)
    end
end



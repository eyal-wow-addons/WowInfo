local _, addon = ...

local Lib = {}

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
        for key, funcs in pairs(queue) do
            for index, func in ipairs(funcs) do 
                func(key, index)
            end
            queue[key] = nil
        end
    end

    function Lib:RegisterFunctionByKey(key, func)
        local funcs = queue[key]
        if not funcs then
            queue[key] = {}
            funcs = queue[key]
        end
        tinsert(funcs, func)
    end

    function Lib:RegisterFunction(func)
        tinsert(queue, func)
    end
end

function Lib:RegisterHookScript(frame, event, func)
    self:RegisterFunctionByKey(frame, function()
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

        for name, func in pairs(Lib) do
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



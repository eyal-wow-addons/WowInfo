local _, addon = ...
local Timer = {}
addon.Timer = Timer

function Timer:Create(callback)
    local t = {}
    local __handle = nil
    local __callback = callback

    function t:Start(seconds)
        self:Cancel()
        __handle = C_Timer.NewTicker(seconds, __callback)
    end

    function t:StartOnce(seconds)
        self:Cancel()
        __handle = C_Timer.NewTicker(seconds, __callback, 1)
    end

    function t:Cancel()
        if __handle then
            __handle:Cancel()
            __handle = nil
        end
    end

    return t
end
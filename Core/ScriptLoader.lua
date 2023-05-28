local _, addon = ...
local ScriptLoader = {}
addon.ScriptLoader = ScriptLoader

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
            local script = queue[index]
            script(index)
            queue[index] = nil
        end
        for key, scripts in pairs(queue) do
            for index, script in ipairs(scripts) do 
                script(key, index)
            end
            queue[key] = nil
        end
    end

    function ScriptLoader:AddScript(key, func)
        local scripts = queue[key]
        if not scripts then
            queue[key] = {}
            scripts = queue[key]
        end
        tinsert(scripts, func)
    end

    function ScriptLoader:RegisterScript(func)
        tinsert(queue, func)
    end
end

function ScriptLoader:AddHookScript(frame, event, func)
    self:AddScript(frame, function()
        frame:HookScript(event, func)
    end)
end

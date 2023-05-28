local _, addon = ...
local Events = {}
addon.Events = Events

local CallbackHandler = LibStub("CallbackHandler-1.0")

function Events:New(tbl)
    if not tbl.__events then
        tbl.__events = CallbackHandler:New(tbl, "RegisterEvent", "UnregisterEvent", false)
        tbl.TriggerEvent = tbl.__events.Fire
    end
end

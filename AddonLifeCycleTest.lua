local _, addon = ...
local AddonLifeCycleTest = addon:NewObject("AddonLifeCycleTest")

function addon:OnInitialize()
    print("<AddonLifeCycleTest> addon:OnInitialize")
end

function addon:OnConfig()
    print("<AddonLifeCycleTest> addon:OnConfig")
end

function AddonLifeCycleTest:OnInitialize()
    print("<AddonLifeCycleTest> OnInitialize")
end

function AddonLifeCycleTest:OnConfig()
    print("<AddonLifeCycleTest> OnConfig")
end

AddonLifeCycleTest:RegisterCallback(function()
    print("<AddonLifeCycleTest> RegisterCallback")
end)

AddonLifeCycleTest:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_MONEY", function(eventName)
        print("<AddonLifeCycleTest> RegisterEvents:" .. eventName)
        AddonLifeCycleTest:TriggerEvent("CUSTOM_EVENT")
    end)

AddonLifeCycleTest:RegisterEvent("CUSTOM_EVENT", function()
    print("<AddonLifeCycleTest> RegisterEvent:CUSTOM_EVENT")
end)

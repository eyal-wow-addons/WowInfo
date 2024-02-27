local _, addon = ...
local AddonLifeCycleTest = addon:NewObject("AddonLifeCycleTest")

function addon:OnInitialize()
    print("<AddonLifeCycleTest> addon:OnInitialize")
end

function addon:OnBeforeConfig()
    print("<AddonLifeCycleTest> addon:OnBeforeConfig")
end

function addon:OnConfig()
    print("<AddonLifeCycleTest> addon:OnConfig")
end

function AddonLifeCycleTest:OnInitialize()
    print("<AddonLifeCycleTest> OnInitialize")
end

function AddonLifeCycleTest:OnBeforeConfig()
    print("<AddonLifeCycleTest> OnBeforeConfig")
end

function AddonLifeCycleTest:OnConfig()
    print("<AddonLifeCycleTest> OnConfig")
end

AddonLifeCycleTest:RegisterCallback(function()
    print("<AddonLifeCycleTest> RegisterCallback")
end)

AddonLifeCycleTest:RegisterEvents(
    "PLAYER_LOGIN",
    "PLAYER_MONEY", function(self, eventName)
        print("<AddonLifeCycleTest> RegisterEvents:" .. eventName)
        AddonLifeCycleTest:TriggerEvent("CUSTOM_EVENT", "Hey!")
    end)

AddonLifeCycleTest:RegisterEvent("CUSTOM_EVENT", function(self, eventName, arg1)
    print(("<AddonLifeCycleTest> RegisterEvent:%s %s"):format(eventName, arg1))
end)

local _, addon = ...

WowInfo = addon:NewObject(addon:GetName())

function WowInfo:GetObject(name)
    return addon:GetObject(name)
end

function WowInfo:GetStorage(name)
    return addon:GetStorage(name)
end

function WowInfo:GetTooltip(name)
    return addon:GetTooltip(name)
end

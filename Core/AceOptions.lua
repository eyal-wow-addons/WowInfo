local _, addon = ...
local AceOptions = {}
addon.AceOptions = AceOptions

local Config = LibStub("AceConfig-3.0")
local Dialog = LibStub("AceConfigDialog-3.0")

local counter = 0
local reloadTracker = {}

local function FixTooltipDesc(value)
    local frame = GetMouseFocus()
    if frame and frame.obj and frame.obj.check then
        local check = frame.obj.check
        GameTooltip:SetOwner(check)
        GameTooltip:SetOwner(check, "ANCHOR_RIGHT")
    end
    return value
end

local function FlagOptionForReload(widget)
    if reloadTracker[widget.option] == nil then
        reloadTracker[widget.option] = true
        counter = counter + 1
    else
        reloadTracker[widget.option] = nil
        counter = counter - 1
    end
end

local function ConvertToAceOptionsTable(source, argsfix)
    local dest = {}
    for k, v in pairs(source) do
        if type(v) ~= "table" then
            if tonumber(k) then
                tinsert(dest, k, v)
            -- Fixes the position of the tooltip
            elseif k == "desc" and type(v) == "string" and dest.type == "toggle" and not dest.descStyle then
                dest[k] = function()
                    return FixTooltipDesc(v)
                end
            -- Adds the option to hide the tooltip
            elseif k == "descStyle" and v == "hidden" then
                dest.desc = ""
                dest.descStyle = "inline"
            -- Adds a reload option
            elseif k == "reload" and type(v) == "boolean" and dest.set and type(dest.set) == "function" then
                dest.desc = function()
                    return FixTooltipDesc("|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t This option requires a UI reload.")
                end
                dest.descStyle = nil
                local oldfunc = dest.set
                dest.set = function(self, value)
                    FlagOptionForReload(self)
                    oldfunc(self, value)
                end
            -- Adds horizontal line
            elseif k == "type" and v == "separator" then
                dest.type = "header"
                dest.name = ""
            -- Adds new line
            elseif k == "type" and v == "newline" then
                dest.type = "description"
                dest.name = "\n"
            -- Adds two new lines
            elseif k == "type" and v == "paragraph" then
                dest.type = "description"
                dest.name = "\n\n"
            else
                dest[k] = v
            end
        else
            if tonumber(k) and argsfix then
                local key = tostring(k)
                dest[key] = ConvertToAceOptionsTable(v)
                dest[key].order = k
            elseif k == "args" then
                dest[k] = ConvertToAceOptionsTable(v, true)
            else
                dest[k] = ConvertToAceOptionsTable(v)
            end
        end
    end
    return dest
end

do
    local parent
    function AceOptions:RegisterOptions(table, isAceOptionsTable)
        if not table or not type(table) == "table"  then
            error("Argument 'table' is not a table.")
        end
        if not table.name then
            error("Cannot find a 'name' entry in the provided table.")
        end
        if not isAceOptionsTable then
            table = ConvertToAceOptionsTable(table)
        end
        local parentName = "WowInfo"
        if not parent then
            parent = true
            Config:RegisterOptionsTable(parentName, table)
            Dialog:AddToBlizOptions(parentName, table.name)
        else
            local childName = parentName.."_".. table.name
            Config:RegisterOptionsTable(childName, table)
            Dialog:AddToBlizOptions(childName, table.name, parentName)
        end
    end
end

function AceOptions:IsReloadRequired()
    return counter > 0
end

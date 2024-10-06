local _, addon = ...
local Colorizer = {}
addon.Colorizer = Colorizer

local function WrapText(color, text)
    return color and color:WrapTextInColorCode(text) or text
end

function Colorizer:ToHighlight(text)
    return WrapText(HIGHLIGHT_FONT_COLOR, text)
end

function Colorizer:ToWhite(text)
    return WrapText(WHITE_FONT_COLOR, text)
end

function Colorizer:ToRed(text)
    return WrapText(RED_FONT_COLOR, text)
end

function Colorizer:ToGreen(text)
    return WrapText(GREEN_FONT_COLOR, text)
end

function Colorizer:ToBlue(text)
    return WrapText(BLUE_FONT_COLOR, text)
end

function Colorizer:ToGray(text)
    return WrapText(GRAY_FONT_COLOR, text)
end

function Colorizer:ToYellow(text)
    return WrapText(YELLOW_FONT_COLOR, text)
end

function Colorizer:ToOrange(text)
    return WrapText(ORANGE_FONT_COLOR, text)
end

function Colorizer:ToClassColor(classFilename, text)
    local classColor = RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR
    return WrapText(classColor, text)
end

function Colorizer:ToUnitClassColor(unit, text)
    return self:ToClassColor(select(2, UnitClass(unit)), text)
end

function Colorizer:ToPlayerClassColor(text)
    return self:ToUnitClassColor("player", text)
end

function Colorizer:ToItemQualityColor(item, text)
    local itemColor = item:GetItemQualityColor()
    itemColor = itemColor and itemColor.color or NORMAL_FONT_COLOR
    return WrapText(itemColor, text)
end


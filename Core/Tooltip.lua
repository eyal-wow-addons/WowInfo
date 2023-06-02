local _, addon = ...
local Tooltip = addon.WidgetUtils:CreateWidgetProxy(GameTooltip, {})
addon.Tooltip = Tooltip

local EMPTY = " "

local GameTooltip = GameTooltip
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR

function Tooltip:AddEmptyLine()
    GameTooltip:AddLine(EMPTY)
end

function Tooltip:AddIndentedLine(text, ...)
    GameTooltip:AddLine("  " .. text, ...)
end

function Tooltip:AddHighlightLine(text)
    GameTooltip:AddLine(text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

function Tooltip:AddGrayLine(text)
    GameTooltip:AddLine(text, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end

function Tooltip:AddIndentedDoubleLine(textLeft, ...)
    GameTooltip:AddDoubleLine("  " .. textLeft, ...)
end

function Tooltip:AddLeftHighlightDoubleLine(textLeft, textRight, r, g, b)
    GameTooltip:AddDoubleLine(textLeft, textRight, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, r, g, b)
end

function Tooltip:AddRightHighlightDoubleLine(textLeft, textRight, r, g, b)
    GameTooltip:AddDoubleLine(textLeft, textRight, r, g, b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

function Tooltip:AddHighlightDoubleLine(textLeft, textRight)
    GameTooltip:AddDoubleLine(textLeft, textRight, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

function Tooltip:AddGrayDoubleLine(textLeft, textRight)
    GameTooltip:AddDoubleLine(textLeft, textRight, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end

function Tooltip:AddLeftGrayDoubleLine(textLeft, textRight)
    GameTooltip:AddDoubleLine(textLeft, textRight, nil, nil, nil, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
end

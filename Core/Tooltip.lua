local _, addon = ...
local Tooltip = addon.WidgetUtils:CreateWidgetProxy(GameTooltip, {})
addon.Tooltip = Tooltip

local EMPTY = " "

local GameTooltip = GameTooltip
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR

local Tooltip_Redirect = function(t, k)
    return Tooltip[k]
end

local Tooltip_MT = { __index = Tooltip_Redirect }

function Tooltip:UseTooltip(tooltip)
    if tooltip ~= self.__tooltip then
        if tooltip == GameTooltip or tooltip == Tooltip then
            self.__tooltip = self
        else
            self.__tooltip = setmetatable(tooltip, Tooltip_MT)
        end
    end
    return self.__tooltip
end

function Tooltip:AddEmptyLine()
    self:AddLine(EMPTY)
end

function Tooltip:AddIndentedLine(text, ...)
    self:AddLine("  " .. text, ...)
end

function Tooltip:AddHighlightLine(text)
    self:AddLine(text, HIGHLIGHT_FONT_COLOR:GetRGB())
end

function Tooltip:AddGrayLine(text)
    self:AddLine(text, GRAY_FONT_COLOR:GetRGB())
end

function Tooltip:AddIndentedDoubleLine(textLeft, ...)
    self:AddDoubleLine("  " .. textLeft, ...)
end

function Tooltip:AddLeftHighlightDoubleLine(textLeft, textRight, r, g, b)
    self:AddDoubleLine(textLeft, textRight, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, r, g, b)
end

function Tooltip:AddRightRedDoubleLine(textLeft, textRight, r, g, b)
    self:AddDoubleLine(textLeft, textRight, r, g, b, RED_FONT_COLOR:GetRGB())
end

function Tooltip:AddRightYellowDoubleLine(textLeft, textRight, r, g, b)
    self:AddDoubleLine(textLeft, textRight, r, g, b, YELLOW_FONT_COLOR:GetRGB())
end

function Tooltip:AddRightOrangeDoubleLine(textLeft, textRight, r, g, b)
    self:AddDoubleLine(textLeft, textRight, r, g, b, ORANGE_FONT_COLOR:GetRGB())
end

function Tooltip:AddRightHighlightDoubleLine(textLeft, textRight, r, g, b)
    self:AddDoubleLine(textLeft, textRight, r, g, b, HIGHLIGHT_FONT_COLOR:GetRGB())
end

function Tooltip:AddHighlightDoubleLine(textLeft, textRight)
    self:AddDoubleLine(textLeft, textRight, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR:GetRGB())
end

function Tooltip:AddGrayDoubleLine(textLeft, textRight)
    self:AddDoubleLine(textLeft, textRight, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, GRAY_FONT_COLOR:GetRGB())
end

function Tooltip:AddLeftGrayDoubleLine(textLeft, textRight)
    self:AddDoubleLine(textLeft, textRight, nil, nil, nil, GRAY_FONT_COLOR:GetRGB())
end

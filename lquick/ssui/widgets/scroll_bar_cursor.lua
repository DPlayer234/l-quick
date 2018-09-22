local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local love = require "love"
local math = math

local Widget = require(parentModule .. ".widget")

local ScrollBarCursor = middleclass("ScrollBarCursor", Widget)

function ScrollBarCursor:init(widget, vertical)
	Widget.init(self)
	self._widget = widget
	self._vertical = vertical

	self:setPositionMode("relative", 0, 0)
	self:setSizeMode("relative", 1, 1)
	self:setAlign(0, 0)

	self._value = 0

	self._active = false

	self
	:on("draw", self._onSBCursorDraw)
	:on("click", self._onSBCursorClick)
	:on("unclick", self._onSBCursorUnclick)
	:on("mousemoved", self._onSBCursorMousemoved)
end

function ScrollBarCursor:updateSize()
	local ww, wh = self._widget:getSize()
	local pw, ph = self._widget:getParentSize()

	if self._vertical then
		self:setBaseSize(1, ph / wh)
	else
		self:setBaseSize(pw / ww, 1)
	end
end

function ScrollBarCursor:recalculateValue()
	local x, y = self:getRelativePosition()
	local w, h = self:getSize()
	local pw, ph = self:getParentSize()

	if self._vertical then
		self._value = y / (ph - h)
	else
		self._value = x / (pw - w)
	end

	if self._value < 0 or self._value > 1 then
		self._value = math.max(0, math.min(self._value, 1))
		if self._vertical then
			y = self._value * (ph - h)
		else
			x = self._value * (pw - w)
		end
		self:setRelativePosition(x, y)
		self:moveWidget()
	end
end

function ScrollBarCursor:recalculatePosition()
	self.Widget.recalculatePosition(self)
	self:recalculateValue()
end

function ScrollBarCursor:recalculateSize()
	self.Widget.recalculateSize(self)
	self:recalculateValue()
end

function ScrollBarCursor:getValue()
	return self._value
end

function ScrollBarCursor:moveWidget()
	local wx, wy, ww, wh = self._widget:getRect()
	local px, py, pw, ph = self._widget:getParentRect()
	local value = self:getValue()

	if self._vertical then
		self._widget:setPosition(wx, value * (ph - wh) + py)
	else
		self._widget:setPosition(value * (pw - ww) + px, wy)
	end
end

function ScrollBarCursor:getColorName()
	return self._active and "scrollCursorActive" or self:isHovered() and "scrollCursorHover" or "scrollCursor"
end

function ScrollBarCursor:getColor()
	return self:getTheme()[self:getColorName()]
end

function ScrollBarCursor:_onSBCursorDraw()
	self:renderRect("fill", self:getColorName())
end

function ScrollBarCursor:_onSBCursorClick(x, y, button)
	self._active = true
end

function ScrollBarCursor:_onSBCursorUnclick(x, y, button)
	self._active = false
end

function ScrollBarCursor:_onSBCursorMousemoved(x, y, dx, dy)
	if self._active then
		local mx, my = self:getRelativePosition()
		local w, h = self:getSize()
		local pw, ph = self:getParentSize()

		if self._vertical then
			self:setRelativePosition(mx, math.max(0, math.min(my + dy, ph - h)))
		else
			self:setRelativePosition(math.max(0, math.min(mx + dx, pw - w)), my)
		end

		self:getPosition()
		self:moveWidget()
		self.parent:emit("value", self:getValue())
	end
end

return ScrollBarCursor

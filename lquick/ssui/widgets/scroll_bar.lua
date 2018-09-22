local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"

local Widget = require(parentModule .. ".widget")
local ScrollBarCursor = require(currentModule .. ".scroll_bar_cursor")

local ScrollBar = middleclass("ScrollBar", Widget)

local SCROLL_BAR_WIDTH = 16 --#const

ScrollBar.WIDTH = SCROLL_BAR_WIDTH

function ScrollBar:init(widget, direction)
	Widget.init(self)

	self._widget = widget
	self._vertical = direction == "vertical"

	self._widgetSize = 0

	self:setPositionMode("relative", 1, 1)
	self:setSizeMode("absolute", SCROLL_BAR_WIDTH, SCROLL_BAR_WIDTH)
	self:setAlign(1, 1)

	self.ignorePadding = true

	self._cursor = ScrollBarCursor(self._widget, self._vertical)
	self:add(self._cursor)

	self
	:on("update", self._onScrollBarUpdate)
	:on("draw", self._onScrollBarDraw)
	:on("click", self._onScrollBarClick)
end

function ScrollBar:recalculateSize()
	local parentWidth, parentHeight = self.parent:getSize()

	if self._vertical then
		self._calcWidth = self._width
		self._calcHeight = parentHeight
	else
		self._calcWidth = parentWidth
		self._calcHeight = self._height
	end
end

function ScrollBar:_onScrollBarUpdate()
	local w, h = self._widget:getSize()
	if self._vertical then
		w = h
	end

	if w ~= self._widgetSize then
		self._cursor:updateSize()
		self._widgetSize = w
	end
end

function ScrollBar:_onScrollBarDraw()
	self:renderRect("fill", "scroll")
	self:renderRect("line", "border")
end

function ScrollBar:_onScrollBarClick() end

return ScrollBar

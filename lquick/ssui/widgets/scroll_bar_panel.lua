local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"

local Widget = require(parentModule .. ".widget")
local Scrollbar = require(currentModule .. ".scroll_bar")

local ScrollBarPanel = middleclass("ScrollBarPanel", Widget)

function ScrollBarPanel:initialize(widget, direction)
	Widget.initialize(self)

	self._widget = widget
	self._scrollBar = Scrollbar(widget, direction)
	self.transparent = true

	self:add(self._widget)
	self:add(self._scrollBar)

	self._scrollBar:on("value", function(by, value)
		return self:emit("value", value)
	end)

	local w, h = self._scrollBar:getSize()
	if self._scrollBar._vertical then
		self:setPadding(0, 0, w, 0)
	else
		self:setPadding(0, 0, 0, h)
	end
end

return ScrollBarPanel

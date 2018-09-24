local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local utf8 = require "utf8"
local table = table

local Label = require(currentModule .. ".label")
local Widget = require(parentModule .. ".widget")

local StackPanel = middleclass("StackPanel", Widget)

local StackChild = middleclass("StackChild", Widget)

function StackPanel:initialize(direction, size)
	Widget.initialize(self)

	self._vertical = direction == "vertical"
	self._size = size
	self._nextPos = 0

	self.transparent = true
end

function StackPanel:setPadding(a, b, c, d)
	Widget.setPadding(self, a, b, c, d)
	self._padding = self._padding * 0.5
	return self
end

function StackPanel:add(widget)
	Widget.add(self, StackChild(self, widget))

	self._nextPos = self._size * #self._children

	return self
end

--[[
Define the panel children
]]
function StackChild:initialize(parent, widget)
	Widget.initialize(self)

	self._vertical = parent._vertical

	self:setPositionMode(
		"absolute",
		self._vertical and 0 or parent._nextPos,
		self._vertical and parent._nextPos or 0)

	self:setSizeMode(
		"absolute",
		self._vertical and 1 or parent._size,
		self._vertical and parent._size or 1)

	self._padding = parent:getPadding()

	self.transparent = true

	self:add(widget)
end

function StackChild:recalculatePosition()
	local w, h = self:getParentSize()

	if self._vertical then
		self._width = w
	else
		self._height = h
	end

	return Widget.recalculatePosition(self)
end

return StackPanel

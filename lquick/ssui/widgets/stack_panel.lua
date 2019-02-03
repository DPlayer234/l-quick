local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local Widget = require(parentModule .. ".widget")

local StackPanel = class("StackPanel", Widget)

local StackChild = class("StackChild", Widget)

function StackPanel:new(direction, size)
	self:Widget()

	self._vertical = direction == "vertical"
	self._size = size
	self._nextPos = 0

	self.transparent = true
end

function StackPanel:setPadding(a, b, c, d)
	self.Widget.setPadding(self, a, b, c, d)
	self._padding = self._padding * 0.5
	return self
end

function StackPanel:add(widget)
	self.Widget.add(self, StackChild(self, widget))

	self._nextPos = self._size * #self._children

	return self
end

--[[
Define the panel children
]]
function StackChild:new(parent, widget)
	self:Widget()

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

	return self.Widget.recalculatePosition(self)
end

return StackPanel

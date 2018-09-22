local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local Button = require(currentModule .. ".button")
local Widget = require(parentModule .. ".widget")

local WindowHeader = middleclass("WindowHeader", Widget)

local HEADER_HEIGHT = 16 --#const

WindowHeader.HEIGHT = HEADER_HEIGHT

local onCloseClick = function(self)
	self.parent.parent:destroy()
	self.parent.parent:emit("close")
end

function WindowHeader:init(height, dragable, closable)
	if height == true or height == false or height == nil then height = HEADER_HEIGHT end
	Widget.init(self)
	self:setPositionMode("absolute", 0, 0)
	self:setSizeMode("absolute", height, height)

	self.ignorePadding = true

	self._dragable = dragable
	self._closable = closable
	self._dragging = false

	self
	:on("update", self._onHeaderUpdate)
	:on("draw", self._onHeaderDraw)

	if self._dragable then
		self
		:on("click", self._onHeaderClick)
		:on("unclick", self._onHeaderUnclick)
		:on("unhover", self._onHeaderUnhover)
		:on("mousemoved", self._onHeaderMousemoved)
	end

	if self._closable then
		self:add(
			Button()
			:setPositionMode("relative", 1, 0)
			:setSizeMode("absolute", height, height)
			:setAlign(1, 0)
			:on("click", onCloseClick)
		)
	end
end

function WindowHeader:_onHeaderUpdate()
	local width, height = self:getSize()
	local parentWidth = self.parent:getSize()

	if width ~= parentWidth then
		self:setSize(parentWidth, height)
	end
end

function WindowHeader:_onHeaderDraw()
	self:renderRect("fill", "header")
	self:renderRect("line", "border")
end

function WindowHeader:_onHeaderClick(x, y, button)
	if button == 1 then
		self._dragging = true
	end
end

function WindowHeader:_onHeaderUnclick(x, y, button)
	if button == 1 then
		return self:_onHeaderUnhover()
	end
end

function WindowHeader:_onHeaderUnhover()
	self._dragging = false
end

function WindowHeader:_onHeaderMousemoved(x, y, dx, dy)
	if self._dragging then
		local mx, my = self.parent:getRelativePosition()
		self.parent:setRelativePosition(mx + dx, my + dy)
	end
end

return WindowHeader

local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"
local math = math

local Button = require(currentModule .. ".button")

local WindowScalar = class("WindowScalar", Button)

local SCALAR_SIZE = 16

function WindowScalar:new()
	self:Button()
	self:setPositionMode("relative", 1, 1)
	self:setSizeMode("absolute", SCALAR_SIZE, SCALAR_SIZE)
	self:setAlign(1, 1)

	self.ignorePadding = true

	self._dragging = false

	self:clearListeners("draw")

	self
	:on("draw", self._onScalarDraw)
	:on("click", self._onScalarClick)
	:on("unclick", self._onScalarUnclick)
	:on("unhover", self._onScalarUnhover)
	:on("mousemoved", self._onScalarMousemoved)
end

function WindowScalar:_onScalarDraw()
	local x, y, w, h = self:getRect()

	local polygon = {
		x, y + h,
		x + w, y + h,
		x + w, y
	}

	love.graphics.setColor(self:getColor())
	love.graphics.polygon("fill", polygon)
	love.graphics.setColor(self:getTheme().border)
	love.graphics.polygon("line", polygon)
end

function WindowScalar:_onScalarClick(x, y, button)
	if button == 1 then
		self._dragging = true
	end
end

function WindowScalar:_onScalarUnclick(x, y, button)
	if button == 1 then
		return self:_onScalarUnhover()
	end
end

function WindowScalar:_onScalarUnhover()
	self._dragging = false
end

function WindowScalar:_onScalarMousemoved(x, y, dx, dy)
	if self._dragging then
		local mw, mh = self.parent:getSize()
		local newWidth, newHeight = mw + dx, mh + dy

		self.parent:setSize(
			math.max(self.parent._padding:getWidth() + self.parent._minWidth, newWidth),
			math.max(self.parent._padding:getHeight() + self.parent._minHeight, newHeight))
	end
end

return WindowScalar

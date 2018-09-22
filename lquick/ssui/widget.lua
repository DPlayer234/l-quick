local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"
local type = type
local table, math = table, math

local Thickness = require(currentModule .. ".thickness")
local EventEmitter = require(currentModule .. ".event_emitter")

local Widget = middleclass("Widget", EventEmitter)

function Widget:initialize()
	EventEmitter.initialize(self)

	self._context = false
	self.parent = false

	self.transparent = false
	self.ignorePadding = false

	self.children = {}
	self._children = {}

	self._calcX = 0
	self._calcY = 0

	self._calcWidth = 0
	self._calcHeight = 0

	self._destroyed = false
	self._focusOnAdd = false
	self._padding = Thickness(0)

	self:setPositionMode("relative", 0, 0)
	self:setSizeMode("relative", 1, 1)
	self:setAlign(0, 0)
end

function Widget:getPositionMode()
	return self._positionMode, self._x, self._y
end

function Widget:setPositionMode(mode, x, y)
	self:_setPositionDirty()

	self._positionMode = mode
	self._x = x
	self._y = y

	return self
end

function Widget:getSizeMode()
	return self._sizeMode, self._width, self._height
end

function Widget:setSizeMode(mode, width, height)
	self:_setSizeDirty()

	self._sizeMode = mode
	self._width  = width or 1
	self._height = height or 1

	return self
end

function Widget:getAlign()
	return self._vertAlign, self._horiAlign
end

function Widget:setAlign(vert, hori)
	self:_setPositionDirty()

	self._vertAlign, self._horiAlign = vert, hori
	return self
end

function Widget:spm(m, x, y)
	return self:setPositionMode(m, x, y)
end

function Widget:ssm(m, w, h)
	return self:setSizeMode(m, w, h)
end

function Widget:add(widget)
	widget.parent = self
	self.children[#self.children + 1] = widget
	self._children[#self._children + 1] = widget

	if self:getContext() then
		widget:setContext(self:getContext())
	end

	widget._destroyed = false

	widget:_setPositionDirty()
	widget:_setSizeDirty()

	if widget._focusOnAdd then
		widget:focus()
		widget._focusOnAdd = false
	end

	return self
end

function Widget:get(type)
	for i=1, #self._children do
		if self._children[i]:typeOf(type) then
			return self._children[i]
		end
	end
end

function Widget:getInChildren(type)
	local direct = self:get(type)

	if direct then return direct end

	for i=1, #self._children do
		local indirect = self._children[i]:getInChildren(type)
		if indirect then return indirect end
	end
end

function Widget:getInParents(type)
	if self:typeOf(type) then return self end

	local direct = self:get(type)

	if direct then
		return direct
	elseif self.parent then
		return self.parent:getInParents(type)
	end
end

function Widget:getInHierarchy(type)
	local indirect = self:getInChildren(type)

	if indirect then
		return indirect
	elseif self.parent then
		return self.parent:getInHierarchy(type)
	end
end

function Widget:isChildOf(widget)
	if not self.parent then return false end

	if self.parent == widget then
		return true
	else
		return self.parent:isChildOf(widget)
	end
end

function Widget:setIgnorePadding(value)
	self.ignorePadding = value
	return self
end

function Widget:getPadding()
	return self._padding:clone()
end

function Widget:setPadding(left, top, right, bottom)
	if type(left) == "number" then
		self._padding = Thickness(left, top, right, bottom)
	else
		self._padding = left:clone()
	end
	return self
end

function Widget:update()
	self:emit("update")

	for i=#self._children, 1, -1 do
		self._children[i]:update()
	end
end

function Widget:draw()
	local sx, sy, sw, sh = love.graphics.getScissor()
	local x, y, w, h = self:getRect()
	if w < 0 or h < 0 then return end
	love.graphics.intersectScissor(x, y, w, h)

	self:emit("draw")

	for i=#self._children, 1, -1 do
		self._children[i]:draw()
	end

	love.graphics.setScissor(sx, sy, sw, sh)
end

function Widget:destroy()
	self._destroyed = true

	local index = self:getIndex()
	if index then table.remove(self.parent.children, index) end

	local _index = self:_getIndex()
	if _index then table.remove(self.parent._children, _index) end

	self:_emitDestroy()
end

function Widget:isDestroyed()
	return self._destroyed
end

function Widget:getContext()
	return self._context
end

function Widget:setContext(value)
	self._context = value
	self._theme = value._theme

	for i=1, #self._children do
		self._children[i]:setContext(value)
	end

	self:emit("context")
	self:emit("theme")
end

function Widget:getTheme()
	return self._theme
end

function Widget:setTheme(value)
	self._theme = value

	for i=1, #self._children do
		self._children[i]:setTheme(value)
	end

	self:emit("theme")
	return self
end

function Widget:getPosition()
	self:_calculatePosition()

	return self._calcX, self._calcY
end

function Widget:setPosition(vx, vy)
	local x, y = self:getParentPosition()

	return self:setRelativePosition(vx - x, vy - y)
end

function Widget:getRelativePosition()
	local w, h = self:getSize()

	local x = w * self._vertAlign
	local y = h * self._horiAlign

	if self._positionMode == "absolute" then
		return self._x - x, self._y - y
	end

	local pw, ph = self:getParentSize()

	return self._x * pw - x, self._y * ph - y
end

function Widget:setRelativePosition(vx, vy)
	self:_setPositionDirty()

	local w, h = self:getSize()

	local x = w * self._vertAlign
	local y = h * self._horiAlign

	self._x = vx + x
	self._y = vy + y

	if self._positionMode ~= "absolute" then
		local pw, ph = self:getParentSize()
		self._x = self._x / pw
		self._y = self._y / ph
	end

	return self
end

function Widget:getSize()
	self:_calculateSize()

	return self._calcWidth, self._calcHeight
end

function Widget:setSize(vw, vh)
	self:_setSizeDirty()

	if self._sizeMode == "absolute" then
		self._width, self._height = vw, vh
		return
	end

	local w, h = self:getParentSize()

	self._width = vw / w
	self._height = vh / h
	return self
end

function Widget:getRect()
	self:_calculatePosition()
	self:_calculateSize()

	return self._calcX, self._calcY, self._calcWidth, self._calcHeight
end

function Widget:getInnerPosition()
	local x, y = self:getPosition()

	return x + self._padding.left, y + self._padding.top
end

function Widget:getInnerSize()
	local width, height = self:getSize()

	return width - self._padding:getWidth(), height - self._padding:getHeight()
end

function Widget:getInnerRect()
	local x, y = self:getInnerPosition()
	local w, h = self:getInnerSize()

	return x, y, w, h
end

function Widget:getBasePosition()
	return self._x, self._y
end

function Widget:setBasePosition(vx, vy)
	self:_setPositionDirty()

	self._x, self._y = vx, vy
	return self
end

function Widget:getBaseSize()
	return self._width, self._height
end

function Widget:setBaseSize(w, h)
	self:_setSizeDirty()

	self._width, self._height = w, h
	return self
end

function Widget:setBaseRect(x, y, w, h)
	self:setBasePosition(x, y)
	self:setBaseSize(w, h)
	return self
end

function Widget:getBaseRect()
	return self._x, self._y, self._width, self._height
end

function Widget:focus()
	if self.parent then
		self.parent:_focusChild(self:_getIndex())
	else
		self._focusOnAdd = true
	end
	return self
end

function Widget:isOverlapping(mx, my)
	local x, y, w, h = self:getRect()
	return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function Widget:findOverlappingChild(mx, my, focus, startIndex)
	for index=startIndex, #self._children do
		local child = self._children[index]

		if child:isOverlapping(mx, my) then
			if focus then
				self:_focusChild(index)
			end

			return child, index
		end
	end
end

function Widget:findOverlap(mx, my, focus)
	local child, index = nil, 0
	repeat
		child, index = self:findOverlappingChild(mx, my, focus, index + 1)

		if child then
			local overlap = child:findOverlap(mx, my, focus)
			if overlap then return overlap end
		end
	until not child

	if self:isOverlapping(mx, my) and not self.transparent then
		if focus then
			self:getContext():setActiveWidget(self)
		end

		return self
	end
end

function Widget:getIndex()
	if self.parent then
		for i=1, #self.parent.children do
			if self.parent.children[i] == self then
				return i
			end
		end
	end
end

function Widget:isActive()
	return self:getContext():getActiveWidget() == self
end

function Widget:isHovered()
	return self:getContext():getHoveredWidget() == self
end

function Widget:isRelativeActive()
	if self.parent then
		return self.parent._children[1] == self
	else
		return true
	end
end

function Widget:renderRect(mode, color)
	love.graphics.setColor(self._theme[color])
	love.graphics.rectangle(mode, self:getRect())
end

function Widget:getParentPosition()
	if not self.parent then
		return 0, 0
	elseif self.ignorePadding then
		return self.parent:getPosition()
	else
		return self.parent:getInnerPosition()
	end
end

function Widget:getParentSize()
	if not self.parent then
		return love.graphics.getDimensions()
	elseif self.ignorePadding then
		return self.parent:getSize()
	else
		return self.parent:getInnerSize()
	end
end

function Widget:getParentRect()
	local x, y = self:getParentPosition()
	local w, h = self:getParentSize()

	return x, y, w, h
end

function Widget:recalculatePosition()
	local x, y = self:getParentPosition()
	local rx, ry = self:getRelativePosition()

	self._calcX, self._calcY = x + rx, y + ry
end

function Widget:recalculateSize()
	if self._sizeMode == "absolute" then
		self._calcWidth, self._calcHeight = self._width, self._height
		return
	end

	local w, h = self:getParentSize()

	self._calcWidth, self._calcHeight = w * self._width, h * self._height
end

function Widget:_emitDestroy()
	self:emit("destroy")

	for i=1, #self._children do
		self._children[i]:_emitDestroy()
	end
end

function Widget:_getIndex()
	if self.parent then
		for i=1, #self.parent._children do
			if self.parent._children[i] == self then
				return i
			end
		end
	end
end

function Widget:_focusChild(index)
	if index <= 1 then return end
	table.insert(self._children, 1, table.remove(self._children, index))
end

function Widget:_calculatePosition()
	if not self._positionDirty then return end
	self._positionDirty = false
	self:recalculatePosition()
end

function Widget:_calculateSize()
	if not self._sizeDirty then return end
	self._sizeDirty = false
	self:recalculateSize()
end

function Widget:_setPositionDirty()
	self._positionDirty = true

	for i=1, #self._children do
		self._children[i]:_setPositionDirty()
	end
end

function Widget:_setSizeDirty()
	self._positionDirty = true
	self._sizeDirty = true

	for i=1, #self._children do
		self._children[i]:_setSizeDirty()
	end
end

return Widget

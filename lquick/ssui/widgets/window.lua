local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local Widget = require(parentModule .. ".widget")

local Label = require(currentModule .. ".label")
local WindowHeader = require(currentModule .. ".window_header")
local WindowScalar = require(currentModule .. ".window_scalar")

local Window = class("Window", Widget)

Window.Header = WindowHeader
Window.Scalar = WindowScalar

function Window:new(x, y, width, height, options)
	self:Widget()
	self:setPositionMode("absolute", x, y)
	self:setSizeMode("absolute", width, height)

	if options == nil then options = {} end

	self._closable = not not options.closable
	self._dragable = not not options.dragable
	self._scalable = not not options.scalable

	self._minWidth = 0
	self._minHeight = 0

	if options.header or options.title or self._closable or self._dragable then
		self._header = WindowHeader(options.header, self._dragable, self._closable)
		self:add(self._header)

		if options.title then
			self._header:add(
				Label(options.title, nil, "left")
				:setPositionMode("absolute", 3, 0)
			)
		end
	end

	if self._scalable then
		self._scalar = WindowScalar()
		self:add(self._scalar)
	end

	self:_adjustPadding()

	self
	:on("draw", self._onWindowDraw)
	:on("click", self._onWindowClick)
end

function Window:setPadding(a, b, c, d)
	self.Widget.setPadding(self, a, b, c, d)

	self:_adjustPadding()

	return self
end

function Window:setMinimumSize(w, h)
	self._minWidth = w
	self._minHeight = h

	return self
end

function Window:_onWindowClick() end

function Window:_onWindowDraw()
	self:renderRect("fill", "window")
	self:renderRect("line", "border")
end

function Window:_adjustPadding()
	if self._header then
		local hw, hh = self._header:getSize()
		self._padding.top = self._padding.top + hh
	end
end

return Window

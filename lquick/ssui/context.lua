local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"

local Widget = require(currentModule .. ".widget")

local Context = middleclass("Context", Widget)

function Context:initialize()
	Widget.initialize(self)
	self:setPositionMode("relative", 0, 0)
	self:setSizeMode("relative", 1, 1)

	self._activeWidget = false
	self._hoveredWidget = false

	self._triggerMM = false

	self._nextTooltip = false

	self:setTheme({})
	self:setContext(self)

	self:on("update", function(self)
		if self._triggerMM then
			local x, y = love.mouse.getPosition()
			self:mousemoved(x, y, 0, 0, false)
			self._triggerMM = false
		end
	end)
end

function Context:draw()
	Widget.draw(self)

	if self._nextTooltip then
		self._nextTooltip:drawTooltip()
	end
end

function Context:setNextTooltip(tooltip)
	self._nextTooltip = tooltip
end

function Context:clear()
	self.children = {}
	self._children = {}
end

function Context:getActiveWidget()
	return self:getContext()._activeWidget
end

function Context:setActiveWidget(widget)
	self:getContext()._activeWidget = widget
end

function Context:getHoveredWidget()
	return self:getContext()._hoveredWidget
end

function Context:setHoveredWidget(widget)
	self:getContext()._hoveredWidget = widget
end

function Context:triggerMouseMovement()
	self._triggerMM = true
end

function Context:setContext(context)
	if context == self then
		return Widget.setContext(self, context)
	end

	error("Cannot add contexts to other widgets!", 2)
end

function Context:getPosition()
	return 0, 0
end

function Context:getSize()
	return love.graphics.getDimensions()
end

function Context:getRect()
	return 0, 0, love.graphics.getDimensions()
end

function Context:keypressed(key, scancode, isrepeat)
	local widget = self:getActiveWidget()

	return widget and widget:emit("keydown", key, scancode, isrepeat)
end

function Context:keyreleased(key, scancode)
	local widget = self:getActiveWidget()

	return widget and widget:emit("keyup", key, scancode)
end

function Context:mousepressed(x, y, button, istouch)
	local widget = self:findOverlap(x, y, true)

	return widget and widget:emit("click", x, y, button)
end

function Context:mousereleased(x, y, button, istouch)
	local widget = self:getActiveWidget()

	return widget and widget:emit("unclick", x, y, button)
end

function Context:mousemoved(x, y, dx, dy, istouch)
	local act = self:getActiveWidget()
	if act then
		act:emit("mousemoved", x, y, dx, dy)
	end

	local prev = self:getHoveredWidget()
	if prev and prev ~= act then
		prev:emit("mousemoved", x, y, dx, dy)
	end

	local hov = self:findOverlap(x, y, false)

	if hov ~= prev then
		if prev then
			prev:emit("unhover")
		end

		if hov then
			hov:emit("mousemoved", x, y, dx, dy)
			hov:emit("hover")
			self:setHoveredWidget(hov)
		end
	end
end

function Context:wheelmoved(x, y)
	local widget = self:getHoveredWidget()

	return widget and widget:emit("scroll", x, y)
end

function Context:textinput(text)
	local widget = self:getActiveWidget()

	return widget and widget:emit("text", text)
end

local function merged(base, over)
	local merge = {}
	for k,v in pairs(base) do
		if type(base[k]) == "table" and type(over[k]) == "table" then
			merge[k] = merged(base[k], over[k])
		elseif over[k] ~= nil then
			merge[k] = over[k]
		else
			merge[k] = base[k]
		end
	end
	return merge
end

function Context:setTheme(value)
	Widget.setTheme(self, merged(self.defaultTheme, value))
end

local function c(cstring)
	local n = {}
	cstring:gsub("..", function(sub)
		n[#n + 1] = tonumber(sub, 16) / 255
		return sub
	end)
	return n
end

Context.defaultTheme = {
	text = c"afafaf",
	window = c"2d2d2d",
	header = c"282828",
	border = c"414141",
	tooltip = c"4d4d4d",
	button = c"323232",
	buttonHover = c"282828",
	buttonActive = c"232323",
	imageButton = c"ffffff",
	imageButtonHover = c"bfbfbf",
	imageButtonActive = c"7f7f7f",
	menuItemHighlight = c"ffffff",
	edit = c"262626",
	editCursor = c"afafaf",
	scroll = c"282828",
	scrollCursor = c"646464",
	scrollCursorHover = c"787878",
	scrollCursorActive = c"969696",
	checkBox = c"ff3232",
	checkBoxHover = c"cc2828",
	checkBoxActive = c"aa2323",
	checkBoxChecked = c"32ff32",
	checkBoxCheckedHover = c"28cc28",
	checkBoxCheckedActive = c"23aa23",
}

return Context

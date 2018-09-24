--[[
Wraps touch screen inputs to gamepad inputs
]]
local handlers = love.handlers

local touchWrap = {}

local touches = {}

--[[
Sticks and buttons (elements) are built the following way:
x, y, ax, ay, r, input, inputAlt

x: The relative screen anchor X position
y: The relative screen anchor Y position
ax: The relative object anchor X position
ay: The relative object anchor Y position
r: The radius in relation to the screen width
inputX: The input to trigger (for sticks: X-axis)
inputY: The Y-axis (only sticks)
]]

-- A list of all sticks
local sticks = {
	{ 0.01, 0.99, 0.0, 1.0, 0.13, "leftx", "lefty" }
}

-- A list of all buttons
local buttons = {
	{ 0.98, 0.98, 1.0, 1.2, 0.07, "a" },
	{ 0.98, 0.98, 2.0, 1.0, 0.07, "b" },
	{ 1.00, 0.00, 0.5, 0.5, 0.10, "start" },
	{ 0.00, 0.00, 0.5, 0.5, 0.10, "back" },
}

-- Multiplier for the radius of elements
local radiusMult = 1

-- Used in later code
for i=1, #sticks do
	sticks[i].type  = "stick"
	sticks[i].index = i
end

for i=1, #buttons do
	buttons[i].type  = "button"
	buttons[i].index = i
end

-- Gets the absolute coordinate and size of an element
local function getCoordinates(ele)
	local w, h = love.graphics.getDimensions()

	local r = ele[5] * w * radiusMult
	local x, y = ele[1] * w, ele[2] * h
	return x - (ele[3] - 0.5) * r * 2, y - (ele[4] - 0.5) * r * 2, r
end

-- Gets the inputX of an element
local function getInputX(ele)
	return ele[6]
end

-- Gets the inputY of an element
local function getInputY(ele)
	return ele[7]
end

-- Gets the normalized values of the touch axes in range -1..1
local function getTouchAxes(x, y, stick)
	local tx, ty, tr = getCoordinates(stick)

	local dx = (x - tx) / tr * 1.2
	local dy = (y - ty) / tr * 1.2

	return
		dx > 1 and 1 or dx < -1 and -1 or dx,
		dy > 1 and 1 or dy < -1 and -1 or dy
end

-- Finds an overlap to an element in "tab"
local function findOverlap(x, y, tab)
	for i=1, #tab do
		local ele = tab[i]
		local tx, ty, tr = getCoordinates(ele)

		local dx = x - tx
		local dy = y - ty

		if (dx * dx + dy * dy) < tr * tr then
			return ele
		end
	end
end

-- Fake Joystick class
local Joystick = class("Joystick", class("Object"))

do
	-- Basically implement all joystick methods
	-- Only the general and gamepad ones work, the joystick (ID-based) ones don't
	function Joystick:new()
		self._axes = {}
		self._buttons = {}
	end

	function Joystick:getAxes() return 0 end
	function Joystick:getAxis(axis) return 0 end
	function Joystick:getAxisCount() return 0 end
	function Joystick:getButtonCount() return 0 end
	function Joystick:getGUID() return "00000000000000000000000000000000" end
	function Joystick:getGamepadAxis(axis) return self._axes[axis] or 0 end
	function Joystick:getGamepadMapping() return nil end
	function Joystick:getHat(hat) return "c" end
	function Joystick:getHatCount() return 0 end
	function Joystick:getID() return -1, -1 end
	function Joystick:getName() return "Touch Pad 90X" end
	function Joystick:getVibration() return 0, 0 end
	function Joystick:isConnected() return true end
	function Joystick:isDown() return false end
	function Joystick:isGamepad() return true end

	function Joystick:isGamepadDown(a, ...)
		if self._buttons[a] then return true
		elseif ... then return self:isGamepadDown(...)
		else return false end
	end

	function Joystick:isVibrationSupported() return false end
	function Joystick:setVibration() end
	function Joystick:release() end
end

local joystick = Joystick()
touchWrap.joystick = joystick

-- Called when a button is pressed
local function pressedGamepadButton(name)
	joystick._buttons[name] = true
	handlers.gamepadpressed(joystick, name)
end

-- Called when a button is released
local function releasedGamepadButton(name)
	joystick._buttons[name] = false
	handlers.gamepadreleased(joystick, name)
end

-- Called when an axis is moved
local function changedGamepadAxis(axis, value)
	joystick._axes[axis] = value
	handlers.gamepadaxis(joystick, axis, value)
end

-- Draws the input circles
local function drawCircles(tab)
	local w, h = love.graphics.getDimensions()

	for i=1, #tab do
		local tx, ty, tr = getCoordinates(tab[i])
		love.graphics.circle("fill", tx, ty, tr)
	end
end

-- Called when you press on the screen
function touchWrap.touchpressed(id, x, y, dx, dy, pressure)
	local stick = findOverlap(x, y, sticks)
	if stick then
		local dx, dy = getTouchAxes(x, y, stick)

		changedGamepadAxis(getInputX(stick), dx)
		changedGamepadAxis(getInputY(stick), dy)

		touches[id] = stick
		return
	end

	local button = findOverlap(x, y, buttons)
	if button then
		pressedGamepadButton(getInputX(button))

		touches[id] = button
		return
	end
end

-- Called when you release a press on the screen
function touchWrap.touchreleased(id, x, y, dx, dy, pressure)
	local touch = touches[id]
	if touch then
		if touch.type == "button" then
			releasedGamepadButton(getInputX(touch))
		elseif touch.type == "stick" then
			changedGamepadAxis(getInputX(touch), 0.0)
			changedGamepadAxis(getInputY(touch), 0.0)
		end

		touches[id] = nil
	end
end

-- Called when you move a press
function touchWrap.touchmoved(id, x, y, dx, dy, pressure)
	local touch = touches[id]
	if touch then
	 	if touch.type == "stick" then
			local dx, dy = getTouchAxes(x, y, touch)

			changedGamepadAxis(getInputX(touch), dx)
			changedGamepadAxis(getInputY(touch), dy)
		end
	else
		touchWrap.touchpressed(id, x, y, dx, dy, pressure)
	end
end

-- Draws the touch input stuff
function touchWrap.draw()
	love.graphics.setColor(0, 0, 0, 0.25)
	drawCircles(sticks)
	drawCircles(buttons)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Returns the multiplier for the element radii
function touchWrap.getRadiusMult()
	return radiusMult
end

-- Sets the multiplier for the element radii
function touchWrap.setRadiusMult(value)
	radiusMult = value
end

-- Hooks the entire setup
function touchWrap.hookIn()
	love.touchpressed  = touchWrap.touchpressed
	love.touchreleased = touchWrap.touchreleased
	love.touchmoved    = touchWrap.touchmoved

	handlers.joystickadded(joystick)

	local love_draw = love.draw

	love.draw = function()
		love_draw()
		touchWrap.draw()
	end
end

return touchWrap

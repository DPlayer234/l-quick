local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local Widget = require(parentModule .. ".widget")

local Button = middleclass("Button", Widget)

function Button:init()
	Widget.init(self)

	self._pressed = false

	self
	:on("draw", self._onButtonDraw)
	:on("click", self._onButtonClick)
	:on("unclick", self._onButtonUnclick)
end

function Button:getColorName()
	return self._pressed and "buttonActive" or self:isHovered() and "buttonHover" or "button"
end

function Button:getColor()
	return self:getTheme()[self:getColorName()]
end

function Button:isPressed()
	return self._pressed
end

function Button:_onButtonDraw()
	self:renderRect("fill", self:getColorName())
	self:renderRect("line", "border")
end

function Button:_onButtonClick(x, y, button)
	self._pressed = true
end

function Button:_onButtonUnclick(x, y, button)
	self._pressed = false
end

return Button

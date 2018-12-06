local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local utf8 = require "utf8"
local Widget = require(parentModule .. ".widget")

local Label = class("Label", Widget)

function Label:new(text, font, wrapMode)
	self:Widget()

	self.text = text or ""
	self.font = font or love.graphics.getFont()
	self.wrapMode = wrapMode or "center"

	self.transparent = true

	self:on("draw", self._onLabelDraw)
end

function Label:setText(value)
	self.text = value
	return self
end

function Label:setFont(value)
	self.font = value
	return self
end

function Label:setWrapMode(value)
	self.wrapMode = mode
	return self
end

function Label:getDrawInfo()
	local x, y = self:getPosition()
	local width, height = self:getSize()
	local textWidth, wrappedLines = self.font:getWrap(self.text, width)
	local textHeight = #wrappedLines * self.font:getHeight() * self.font:getLineHeight()

	return x, y + (height - textHeight) * 0.5,
		width, height,
		textWidth, textHeight,
		wrappedLines
end

function Label:getCharRect(index)
	local fontHeight = self.font:getHeight() * self.font:getLineHeight()
	local x, y, width, height, textWidth, textHeight, wrappedLines = self:getDrawInfo()

	local line = table.remove(wrappedLines, 1)
	if not line then return x, y - fontHeight * 0.5, 1, fontHeight end

	while index > utf8.len(line) do
		index = index - utf8.len(line)
		line = table.remove(wrappedLines, 1)
		if not line then return end
		y = y + fontHeight
	end

	return x + (index < 1 and 0 or self.font:getWidth(line:sub(1, utf8.offset(line, index + 1) - 1))), y,
		1, fontHeight
end

function Label:_onLabelDraw()
	local x, y, width, height = self:getDrawInfo()

	love.graphics.setColor(self:getTheme().text)
	love.graphics.printf(self.text, self.font, x, y, width, self.wrapMode)
end

return Label

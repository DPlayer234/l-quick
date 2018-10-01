local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local love = require "love"

local Widget = require(parentModule .. ".widget")

local Tooltip = class("Tooltip", Widget)

local WRAP_LIMIT = 2000 --#const

function Tooltip:new(text, font, wrapMode)
	self:Widget()

	self.text = text or ""
	self.font = font or love.graphics.getFont()
	self.wrapMode = wrapMode or "left"

	self.transparent = true

	self:on("update", self._onTooltipUpdate)
end

function Tooltip:setText(value)
	self.text = value
	return self
end

function Tooltip:setFont(value)
	self.font = value
	return self
end

function Tooltip:setWrapMode(value)
	self.wrapMode = mode
	return self
end

function Tooltip:drawTooltip()
	if self.parent:isHovered() then
		local sx, sy, sw, sh = love.graphics.getScissor()
		love.graphics.setScissor()

		local x, y = love.mouse.getPosition()
		local textWidth, wrappedLines = self.font:getWrap(self.text, WRAP_LIMIT)
		local textHeight = #wrappedLines * self.font:getHeight() * self.font:getLineHeight()

		y = y - textHeight - self._padding:getHeight()

		love.graphics.setColor(self:getTheme().tooltip)
		love.graphics.rectangle("fill", x, y, textWidth + self._padding:getWidth(), textHeight + self._padding:getHeight())

		love.graphics.setColor(self:getTheme().text)
		love.graphics.printf(self.text, self.font, x + self._padding.left, y + self._padding.top, WRAP_LIMIT, self.wrapMode)

		love.graphics.setScissor(sx, sy, sw, sh)
	end
end

function Tooltip:_onTooltipUpdate()
	if self.parent:isHovered() then
		self:getContext():setNextTooltip(self)
	end
end

return Tooltip

local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"

local Button = require(currentModule .. ".button")
local ImageButton = class("ImageButton", Button)

function ImageButton:new(texture, quad)
	self:Button()
	self._texture = texture
	self._quad = quad

	if self._quad then
		self:on("draw", self._onQuadButtonDraw)
	else
		self:on("draw", self._onImageButtonDraw)
	end
end

function ImageButton:getImageColor()
	return self:getTheme()[self._pressed and "imageButtonActive" or self:isHovered() and "imageButtonHover" or "imageButton"]
end

function ImageButton:_onImageButtonDraw()
	local x, y, w, h = self:getRect()
	love.graphics.setColor(self:getImageColor())
	love.graphics.draw(self._texture, x, y, 0, w / self._texture:getWidth(), h / self._texture:getHeight())
end

function ImageButton:_onQuadButtonDraw()
	local x, y, w, h = self:getRect()
	love.graphics.setColor(self:getImageColor())

	local _, _, vw, vh = self._quad:getViewport()
	love.graphics.draw(self._texture, self._quad, x, y, 0, w / vw, h / vh)
end

return ImageButton

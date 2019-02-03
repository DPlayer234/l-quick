local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"
local tostring, pairs = tostring, pairs

local Button = require(currentModule .. ".button")
local Label = require(currentModule .. ".label")
local StackPanel = require(currentModule .. ".stack_panel")
local Tooltip = require(currentModule .. ".tooltip")
local Window = require(currentModule .. ".window")

local ContextMenu = class("ContextMenu", Button)

local ContextWindow = class("ContextWindow", Window)

local INDICATOR_WIDTH = 12 --#const

function ContextMenu:new(default, options)
	self:Button()

	self._selected = default
	self._options = options or {}
	self._tooltips = {}

	self._label = Label(tostring(self._selected))
	self:add(self._label)

	self._window = false

	self:_adjustPadding()

	self
	:on("draw", self._onContextDraw)
	:on("click", self._onContextClick)
	:on("select", self._onContextSelect)
	:on("destroy", self._onContextDestroy)
end

function ContextMenu:setPadding(a, b, c, d)
	self.Widget.setPadding(self, a, b, c, d)

	self:_adjustPadding()

	return self
end

function ContextMenu:setTooltips(tooltips)
	self._tooltips = tooltips
	return self
end

function ContextMenu:getOptions()
	return self._options
end

function ContextMenu:setOptions(options)
	self._options = options
end

function ContextMenu:getOptionCount()
	local count = 0
	for k, v in pairs(self._options) do
		count = count + 1
	end
	return count
end

function ContextMenu:getSelected()
	return self._selected
end

function ContextMenu:setSelected(option)
	self:emit("select", option)
end

function ContextMenu:_adjustPadding()
	self._padding.right = self._padding.right + INDICATOR_WIDTH
end

function ContextMenu:_onContextDraw()
	local x, _, w, _ = self:getInnerRect()
	local _, y, _, h = self:getRect()
	local right = self._padding.right

	love.graphics.setColor(self:getTheme().border)
	love.graphics.line(x + w, y, x + w, y + h)
	love.graphics.line(x + w, y, x + w + right * 0.5, y + h, x + w + right, y)
end

function ContextMenu:_onContextClick()
	if self._window and not self._window:isDestroyed() then
		self._window:destroy()
	else
		self._window = ContextWindow(self)

		self:getContext():add(self._window)
		self:getContext():triggerMouseMovement()
		self._window:focus()
	end
end

function ContextMenu:_onContextSelect(option)
	self._selected = option
	self._label.text = tostring(option)
end

function ContextMenu:_onContextDestroy()
	if self._window then
		self._window:destroy()
	end
end

function ContextWindow:new(contextMenu)
	local x, y, w, h = contextMenu:getInnerRect()

	self._contextMenu = contextMenu
	self._options = contextMenu._options
	self._tooltips = contextMenu._tooltips

	self:Window(x, y, w, h * contextMenu:getOptionCount())

	self._panel = StackPanel("vertical", h)
	self:add(self._panel)

	for key, option in pairs(self._options) do
		local button = Button()
		:add(Label(tostring(option)))
		:on("click", function()
			self:destroy()
			self._contextMenu:emit("select", option)
		end)

		if self._tooltips[key] then
			button:add(Tooltip(tostring(self._tooltips[key])))
		end

		self._panel:add(button)
	end

	self:on("update", self._onContextUpdate)
end

function ContextWindow:_onContextUpdate()
	if not self:isRelativeActive() then
		self:destroy()
	end
end

return ContextMenu

--[[
Renderer class to allow for stacked post-processing effects
]]
local currentModule = (...):gsub("[^%.]*$", "")
local love_graphics = require "love.graphics"

local Renderer = class("Renderer")

local EffectStack = require(currentModule .. ".effect_stack")

local canvasSizeId = 00
local canvasBuffer = {}
local canvasSettings = {}

local function getCanvasSizeId(w, h)
	return w * h * (w > h and 1 or -1)
end

local function fetchCanvas(w, h)
	local id = getCanvasSizeId(w, h)

	if id ~= canvasSizeId then
		canvasBuffer = {}
		canvasSizeId = id
	end

	return table.remove(canvasBuffer) or love_graphics.newCanvas(w, h, canvasSettings)
end

local function bufferCanvas(canvas)
	canvasBuffer[#canvasBuffer + 1] = canvas
end

-- Initializes a new Renderer
function Renderer:new()
	self.effects = EffectStack(self)
end

-- Updates the renderer and its EffectStack
function Renderer:update(dt)
	self.effects:_update(dt)
end

-- Draws a function with the EffectStack applied
function Renderer:draw(func)
	local target = love_graphics.getCanvas()
	local w, h = (target or love_graphics):getDimensions()

	local buffer = fetchCanvas(w, h)
	love_graphics.setCanvas(buffer)
	self.activeCanvas = buffer
	func(self, w, h)
	self.activeCanvas = nil

	love_graphics.origin()
	love_graphics.setBlendMode("replace")
	love_graphics.setColor(1, 1, 1, 1)

	local altBuffer = fetchCanvas(w, h)
	local actives = self.effects._actives

	for i = 1, #actives - 1 do
		self:_applyEffect(buffer, altBuffer, actives[i])
		buffer, altBuffer = altBuffer, buffer
	end

	self:_applyEffect(buffer, target, actives[#actives])

	bufferCanvas(buffer)
	bufferCanvas(altBuffer)

	love_graphics.setShader(nil)
	love_graphics.setBlendMode("alpha", "alphamultiply")
end

-- Internally applies a single effect
function Renderer:_applyEffect(texture, target, effect)
	if effect then
		effect:sendUniforms()
		love_graphics.setShader(effect.shader)
	end

	love_graphics.setCanvas(target)
	love_graphics.draw(texture)
end

-- Globally sets the options for generated canvases. Clears the canvas buffer.
function Renderer.setCanvasOptions(settings)
	canvasBuffer = {}
	canvasSettings = settings
end

return Renderer

--[[
A post-processing effect
]]
local love_graphics = require "love.graphics"

local Effect = middleclass("Effect")

-- Override for varying uniform updates
function Effect:update(dt)
	return
end

-- Override to allow changing active state
function Effect:isActive()
	return true
end

-- Sends all uniforms to the shader
function Effect:sendUniforms()
	for name, value in pairs(self.uniforms) do
		if self.shader:hasUniform(name) then
			self.shader:send(name, value)
		end
	end
end

-- Copies the default uniform table to this instance.
-- You may also define a completely new table in the constructor of every sub-class.
function Effect:copyDefaultUniforms()
	local uniforms = {}
	local defaults = self.uniforms

	for k, v in pairs(defaults) do
		uniforms[k] = v
	end

	self.uniforms = uniforms
end

-- An effect needs a shader.
Effect.shader = nil

-- Table with all uniforms to send to the shader.
Effect.uniforms = {}

-- Override the zIndex to change the order the effects are applied in.
Effect.zIndex = 0

return Effect

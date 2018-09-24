--[[
A stack of post-processing effects
]]
local table = table

local EffectStack = middleclass("EffectStack")

-- Initializes a new EffectStack instance
function EffectStack:initialize(renderer)
	self._stack = {}
	self._actives = {}

	self.renderer = renderer
end

-- Adds a new effect to the stack
function EffectStack:add(effect)
	if self:has(effect) then return false end

	effect.renderer = self.renderer

	for i=1, #self._stack do
		local item = self._stack[i]
		if effect.zIndex < item.zIndex then
			table.insert(self._stack, i, effect)
			return true
		end
	end

	self._stack[#self._stack + 1] = effect
	return true
end

-- Removes an effect from the stack
function EffectStack:remove(effect)
	local index = self:_getIndex(effect)
	if not index then return false end

	table.remove(self._stack, index)
	return true
end

-- Returns whether an effect is already on the stack
function EffectStack:has(effect)
	return self:_getIndex(effect) ~= nil
end

-- Updates all effects on the stack and regenerates self._actives
function EffectStack:_update(dt)
	local actives = {}

	for i=1, #self._stack do
		local item = self._stack[i]
		item:update(dt)

		if item:isActive() then
			actives[#actives + 1] = item
		end
	end

	self._actives = actives
end

-- Gets the index of an effect in the stack
function EffectStack:_getIndex(effect)
	for i=1, #self._stack do
		if self._stack[i] == effect then
			return i
		end
	end

	return nil
end

return EffectStack

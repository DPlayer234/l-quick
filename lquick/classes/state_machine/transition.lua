--[[
This defines the transition and condition for the transition from one state to another.
If you instantiate the same Transition often, consider inheriting this call and overriding check.
]]
local Transition = class("Transition")

-- Initialize a new transition, specifiying the state to transition to by reference or name.
function Transition:new(toState)
	if type(toState) == "string" then
		self._toName = toState
	else
		self._to = toState
	end
end

-- Attaches the state to transition from. This does not need to be called explicitly.
function Transition:attachFromState(fromState)
	assert(self._from == nil, "Cannot attach a Transition to multiple states.")
	self._from = fromState
end

-- Gets the state being transitioned from.
function Transition:getFromState()
	return self._from
end

-- Gets the state being transitioned to.
function Transition:getToState()
	self:_checkToState()
	return self._to
end

-- Checks the conditions and returns its result.
function Transition:check() return false end

-- Gets the condition function.
function Transition:getCondition()
	return self.check
end

-- Sets the condition function and returns the transition.
function Transition:setCondition(func)
	self.check = func
	return self
end

-- Checks the to-state and makes sure the reference is known.
function Transition:_checkToState()
	if self._to == nil and self._toName ~= nil then
		self._to = self._from:getMachine():getState(self._toName)
		if self._to ~= nil then self._toName = nil end
	end
end

return Transition

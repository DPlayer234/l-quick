--[[
This defines a State.
If a specific state is used often, it is smarter to inherit this class and define them directly.
For classes, override update, exit and enter, otherwise call setUpdate, setExit and setEntry.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local State = middleclass("State")

local Transition = require(currentModule .. "transition")

-- Initialize a new named state
function State:initialize(name)
	self._name = name
	self._transitions = {}
end

-- Attached the StateMachine. This does not need to be called explicitly.
function State:attachMachine(machine)
	self._machine = machine
end

-- Returns the state's machine
function State:getMachine()
	return self._machine
end

-- Returns the state name. State names may not be duplicated within a StateMachine.
function State:getName()
	return self._name
end

-- The state update method.
function State:update(...) end

-- The state exit callback.
function State:exit() end

-- The state entry callback.
function State:enter() end

-- Returns a Transition whose condition is fulfilled.
function State:checkTransition()
	for i=1, #self._transitions do
		local transition = self._transitions[i]
		if transition:check() then
			return transition
		end
	end
end

-- Gets an attached transition by index.
function State:getTransition(index)
	return self._transitions[index]
end

-- Gets the amount of transitions from this state.
function State:getTransitionCount()
	return #self._transitions
end

-- Adds a transition from this state.
function State:addTransition(transition)
	self._transitions[#self._transitions + 1] = transition
	transition:attachFromState(self)
	return self
end

-- Gets the update function.
function State:getUpdate()
	return self.update
end

-- Gets the exit function.
function State:getExit()
	return self.exit
end

-- Gets the entry function.
function State:getEntry()
	return self.enter
end

-- Sets the update function and returns the state.
function State:setUpdate(func)
	self.update = func
	return self
end

-- Sets the exit function and returns the state.
function State:setExit(func)
	self.exit = func
	return self
end

-- Sets the entry function and returns the state.
function State:setEntry(func)
	self.enter = func
	return self
end

return State

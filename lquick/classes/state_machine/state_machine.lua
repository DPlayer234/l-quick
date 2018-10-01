--[[
This is Finite State Machine.
You can add any amount of states to it.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local StateMachine = class("StateMachine")

StateMachine.State      = require(currentModule .. "state")
StateMachine.Transition = require(currentModule .. "transition")

-- Initialize a new empty state machine.
function StateMachine:new()
	self._states = {}
	self._state = nil
	self._nextState = nil
end

-- Gets an attached state by name/key.
function StateMachine:getState(key)
	return self._states[key]
end

-- Adds a named state to the machine and returns the machine.
function StateMachine:addState(state)
	assert(state:getName(), "Cannot add States without names.")
	assert(not self:getState(state:getName()), "Cannot add multiple States with the same name.")
	assert(state:getMachine() == nil, "States may not be added to multiple StateMachines.")

	self._states[state:getName()] = state
	state:attachMachine(self)
	return self
end

-- Returns the active state.
function StateMachine:getActiveState()
	return self._state
end

-- Returns the next state.
function StateMachine:getNextState()
	return self._nextState
end

-- Sets the state transitioned to upon the next call of update. Returns the machine.
function StateMachine:setNextState(state)
	state = self:getState(state) or state
	assert(state:getMachine() == self, "Cannot set next state that doesn't belong to this StateMachine.")
	self._nextState = state
	return self
end

-- Updates the state machine.
function StateMachine:update(...)
	self:_checkTransition()
	self:_doTransition()

	if self:getActiveState() == nil then return end

	self:getActiveState():update(...)

	self:_checkTransition()
	self:_doTransition()
end

-- Internal. Perform a transition, call the callbacks and make sure it happens correctly.
function StateMachine:_doTransition()
	if self:getNextState() then
		if self._state then
			self._state:exit()
		end

		self._state = self._nextState
		self._nextState = nil

		self._state:enter()
	end
end

-- Checks for any valid transition and calls setNextState if there is one.
function StateMachine:_checkTransition()
	if self:getActiveState() == nil then return end

	local transition = self:getActiveState():checkTransition()
	if transition then
		self:setNextState(transition:getToState())
	end
end

return StateMachine

--[[
Timer class
]]
local currentModule = (...):gsub("[^%.]*$", "")

local table, math = table, math
local type = type

local Coroutine = require(currentModule .. "coroutine")

local Timer = middleclass("Timer")

-- Initializes a new timer
function Timer:initialize()
	self._time = 0
	self._tasks = {}
end

-- Gets the current run time
function Timer:getTime()
	return self._time
end

-- Starts a coroutine
function Timer:startCoroutine(closure)
	local coroutine = Coroutine(closure)

	self:_addTask(coroutine, self._time)

	return coroutine
end

-- Runs a closure after the given amount of time
function Timer:runAfter(delay, closure)
	self:_addTask(closure, self._time + delay)
end

-- Updates the timer. Should be called once a frame
function Timer:update(dt)
	self._time = self._time + dt

	for i=#self._tasks, 1, -1 do
		if self:_handleTask(self._tasks[i]) then
			table.remove(self._tasks, i)
		end
	end
end

-- Adds a task to be executed
function Timer:_addTask(func, time)
	self._tasks[#self._tasks + 1] = {
		func = func,
		time = time
	}
end

-- Handles a single task
-- Returns whether to remove the task
function Timer:_handleTask(task)
	if task.time < self._time then
		local delay = task.func()

		if type(delay) == "number" then
			task.time = math.max(self._time, task.time + delay)
		elseif delay == nil then
			return true
		else
			error("Task Function returned value of '" .. type(delay) .. "'. Expected number or nil.")
		end
	end
	return false
end

function Timer:__tostring()
	return ("Timer: %.3fs"):format(self:getTime())
end

return Timer

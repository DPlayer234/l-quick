--[[
Easy to use coroutines
]]
local coroutine = coroutine
local assert = assert

local Coroutine = middleclass("Coroutine")

-- Returns all arguments passed except the first
local function _returnFrom2nd(first, ...)
	return ...
end

-- Initialize a new coroutine
function Coroutine:initialize(closure)
	self:setClosure(closure)
end

-- Returns the Lua function used by the thread.
function Coroutine:getClosure()
	return self._closure
end

-- Sets the Lua function used by the thread. This will reset the coroutine! (see Coroutine:reset())
function Coroutine:setClosure(closure)
	self._closure = closure
	self:reset()
end

-- Resets the coroutine by creating a new thread.
-- If done within the coroutine, you should consider that it is now considered to be a different one.
-- Therefore, yielding via instance is no longer allowed but resuming is.
function Coroutine:reset()
	self._thread = coroutine.create(self:getClosure())
end

-- Returns the Lua coroutine object.
function Coroutine:getLuaThread()
	return self._thread
end

-- Resumes the coroutine and returns what it yields.
-- Throws any error that is caused by this action.
function Coroutine:resume(...)
	return _returnFrom2nd(assert(coroutine.resume(self._thread, self, ...)))
end

-- Attempts to resume the coroutine.
-- If it didn't throw any errors, returns true and any yielded values.
-- Otherwise returns false followed by the error message.
function Coroutine:resumeProtected(...)
	return coroutine.resume(self._thread, self, ...)
end

-- Lets the coroutine yield (To be called inside the coroutine)
function Coroutine:yield(...)
	assert(self:isActive(), "The coroutine is not active.")
	return _returnFrom2nd(coroutine.yield(...))
end

-- Returns the current coroutine status
function Coroutine:getStatus()
	return coroutine.status(self._thread)
end

-- Returns whether the coroutine is currently suspended and may be resumed
function Coroutine:isSuspended()
	return self:getStatus() == "suspended"
end

-- Returns whether the coroutine is dead and has finished
function Coroutine:isDead()
	return self:getStatus() == "dead"
end

-- Returns whether the coroutine is the currently active thread.
function Coroutine:isActive()
	return self:getStatus() == "running"
end

-- Returns whether the coroutine is running (or resuming another coroutine)
function Coroutine:isRunning()
	return self:isActive() or self:getStatus() == "normal"
end

Coroutine.__call = Coroutine.resume

return Coroutine

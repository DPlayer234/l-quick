--[[
This simulates a try-catch-finally instruction.
]]
local pcall, tostring = pcall, tostring

local Try = class("Try")

-- Starts a new block.
function Try:new(closure)
	self._success, self._exception = pcall(closure)
	if self._success then self._exception = nil end
	return self
end

-- Catches any exception with a given pattern.
-- If the pattern is nil (or null), catches any exception.
function Try:catch(expattern, closure)
	if self._success then return self end

	if expattern == nil or (tostring(self:getException()):find(expattern)) then
		closure(self:getException())
	end

	return self
end

-- Finally is called regardless of the circumstances after the main block.
function Try:finally(closure)
	closure()
	return self
end

-- Returns whether the initial call was successful
function Try:wasSuccessful()
	return self._success
end

-- Returns the exception, if any has been raised.
function Try:getException()
	return self._exception
end

return Try

--[[
EventHandlers are for grouping methods and calling them all at once.
]]
local remove = table.remove

local EventHandler = class("EventHandler")

-- Initialize a new EventHandler
function EventHandler:new()
	self._list = {}
end

-- Gets the index of a function in the handler list.
-- Returns nil if it's not contained.
function EventHandler:getIndex(func)
	for i=1, #self._list do
		if self._list[i] == func then
			return i
		end
	end
	return nil
end

-- Returns whether the handler has the function.
function EventHandler:has(func)
	return self:getIndex(func) ~= nil
end

-- Adds a function if it not contained already.
function EventHandler:add(func)
	if not self:has(func) then
		self._list[#self._list + 1] = func
	end
end

-- Removes a function if it is contained.
function EventHandler:remove(func)
	local index = self:getIndex(func)
	if index ~= nil then
		remove(self._list, index)
	end
end

-- Calls all handler functions.
function EventHandler:handle(...)
	for i=1, #self._list do
		self._list[i](...)
	end
end

-- Allow calling the handler like a function
EventHandler.__call = EventHandler.handle

return EventHandler

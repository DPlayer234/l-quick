--[[
Stores events to be handled (executed) later.
If any given function yields, it is paused until the EventStore is handling events again.
]]
local assert = assert
local remove = table.remove
local coroutine = coroutine

local EventStore = middleclass("EventStore")

-- Initializes a new Event Store.
function EventStore:initialize()
	self._list = {}
	self._tempList = false
end

-- Add an event to the store (including arguments)
-- Return the event coroutine.
function EventStore:add(event, ...)
	local coEvent = coroutine.create(function(...)--[[EventStore.funcCoroutine]]
		coroutine.yield()
		return event(...)
	end)
	coroutine.resume(coEvent, ...)

	local list = self._tempList or self._list

	list[#list+1] = {
		event = event,
		rout = coEvent
	}
	return coEvent
end

-- Returns whether the event is already added.
-- Unreliable if called during handling.
function EventStore:has(event)
	for i=1, #self._list do
		local this = self._list[i]
		if this.event == event or this.rout == event then
			return true
		end
	end
	return false
end

-- Removes an event by either the original value or by its coroutine.
-- It is illegal to call this during handling.
function EventStore:remove(event)
	assert(not self._tempList, "Cannot remove Events while handling.")

	for i=1, #self._list do
		local this = self._list[i]
		if this.event == event or this.rout == event then
			return remove(self._list, i)
		end
	end
end

-- Like EventStore:add(event, ...), but only adds when EventStore:has(event) returns false.
-- Either returns the event coroutine or nil.
function EventStore:addOnce(event, ...)
	if not self:has(event) then
		return self:add(event, ...)
	end
end

-- Returns the amount of events currently in the store
function EventStore:getCount()
	return #self._list
end

-- Clears all events from the queue
function EventStore:clear()
	self._list = {}
end

-- Handles a single event by resuming the coroutine and raising an error if needed
local function _handleEvent(self, this, ...)
	local ok, errormsg = coroutine.resume(this.rout, ...)
	if ok then
		return coroutine.status(this.rout) == "suspended"
	else
		self.__errorBy = this
		error(debug.traceback(this.rout, errormsg))
	end
end

-- Handles all events
function EventStore:handle(...)
	if not self._list[1] then return end

	self._tempList = {}

	for i=1, self:getCount(), 1 do
		local this = remove(self._list, 1)
		if _handleEvent(self, this, ...) then
			self._list[#self._list+1] = this
		end
	end

	for i=1, #self._tempList do
		self._list[#self._list+1] = self._tempList[i]
	end
	self._tempList = false
end

EventStore.__call = EventStore.handle

return EventStore

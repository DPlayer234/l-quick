local table = table

local EventEmitter = middleclass("EventEmitter")

function EventEmitter:init()
	self._events = {}
end

function EventEmitter:addListener(event, listener)
	if self._events[event] == nil then
		self._events[event] = {}
	end

	table.insert(self._events[event], listener)
end

function EventEmitter:removeListener(event, listener)
	if self._events[event] == nil then
		return
	end

	for i=1, #self._events[event] do
		if self._events[event][i] == listener then
			table.remove(self._events[event], i)
			return true
		end
	end
	return false
end

function EventEmitter:clearListeners(event)
	if event == nil then
		self._events = {}
	elseif self._events[event] ~= nil then
		self._events[event] = nil
	end
end

function EventEmitter:emit(event, ...)
	local listeners = self._events[event]
	if listeners == nil then
		return false
	end

	for i=1, #listeners do
		listeners[i](self, ...)
	end

	return true
end

function EventEmitter:on(event, listener)
	self:addListener(event, listener)

	return self
end

return EventEmitter

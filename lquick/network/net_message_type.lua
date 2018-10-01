--[[
Allows the user to define a type of net-messages.
You never need to create these explicitly.
Set the 'mode' and 'args' fields and override the 'onReceive(self, message)' method.
]]
local bitser = bitser
local table = table
local assert, pairs, type, tostring, tonumber = assert, pairs, type, tostring, tonumber

assert(bitser, "bitser is not loaded into the global variable.")

local NetMessageType = class("NetMessageType")

-- Initializes a NetMessageType instance.
function NetMessageType:new(name)
	self._name = assert(name, "A message type needs a name")
	self._tempHandlers = {}

	self.mode = self.UNRELIABLE
	self.args = {}

	self.netPeer = nil
	self.connection = nil
end

-- Gets the name of the message type.
function NetMessageType:getName()
	return self._name
end

-- To be overriden per instance. Called for every message that was received.
function NetMessageType:onReceive(message) end

-- Adds a closure to be called the next time a message of this type is handled.
-- Receives the NetMessageType instance as the first parameter and the message as its second.
function NetMessageType:addOnceOnReceive(closure)
	self._tempHandlers[#self._tempHandlers + 1] = closure
end

-- Validates that the set values are valid
function NetMessageType:validate()
	--#exclude start
	assert(type(self.args) == "table", "'args' has to be a table")
	assert(self.mode == self.UNRELIABLE or self.mode == self.RELIABLE, "'mode' has to be a NetMessageType.UNRELIABLE or NetMessageType.RELIABLE")
	assert(type(self.onReceive) == "function", "'onReceive' has to be a function")
	--#exclude end
end

-- Casts the value to a string
function NetMessageType:asString(value)
	return tostring(value)
end

-- Casts the value to a number
function NetMessageType:asNumber(value)
	return tonumber(value) or 0
end

-- Casts the value to a boolean
function NetMessageType:asBool(value)
	return not not value
end

-- Casts the value to a table
function NetMessageType:asTable(value)
	return type(value) == "table" and value or {}
end

-- Internal. Strips unneeded data from the message.
function NetMessageType:_strip(message)
	for k, v in pairs(message) do
		if self.args[k] == nil or self.args[k] == v then
			message[k] = nil
		end
	end
end

-- Internal. Expands the message to contain all values.
function NetMessageType:_expand(message)
	for k, v in pairs(message) do
		if v == nil and self.args[k] ~= nil then
			message[k] = self.args[k]
		end
	end
end

-- Internal. Encodes a message to a datagram.
function NetMessageType:_encode(message)
	message._type = self._name
	return bitser.dumps(message)
end

-- Internal. Invokes the callback.
function NetMessageType:_invoke(netPeer, connection, message)
	self.netPeer = netPeer
	self.connection = connection

	self:_expand(message)
	self:onReceive(message)

	if #self._tempHandlers > 0 then
		for i = 1, #self._tempHandlers do
			self._tempHandlers[i](self, message)
			self._tempHandlers[i] = nil
		end
	end
end

function NetMessageType:__tostring()
	return ("%s: %s"):format(self.class.name, self._name)
end

-- Internal. Decodes a datagram into a message.
function NetMessageType:_decode(datagram)
	local message = bitser.loads(datagram)
	if type(message) ~= "table" then return end
	return message
end

NetMessageType.UNRELIABLE = "unsequenced"
NetMessageType.RELIABLE   = "reliable"

return NetMessageType

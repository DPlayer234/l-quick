--[[
Allows the user to define a type of net-messages.
You never need to create these explicitly.
Set the 'mode' and 'args' fields and override the 'onReceive(self, message)' method.
]]
local bitser = bitser
local table = table
local assert = assert

assert(bitser, "bitser is not loaded into the global variable.")

local NetMessageType = middleclass("NetMessageType")

-- Initializes a NetMessageType instance.
function NetMessageType:initialize(name)
	self._name = assert(name, "A message type needs a name")
	self._tempHandlers = {}

	self.mode = NetMessageType.UNRELIABLE
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
function NetMessageType.static:_decode(datagram)
	local message = bitser.loads(datagram)
	if type(message) ~= "table" then return end
	return message
end

NetMessageType.static.UNRELIABLE = "unsequenced"
NetMessageType.static.RELIABLE   = "reliable"

return NetMessageType

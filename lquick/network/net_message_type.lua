--[[
Allows the user to define a type of net-messages.
]]
local bitser = bitser
local table = table
local assert = assert

assert(bitser, "bitser is not loaded into the global variable.")

local NetMessageType = middleclass("NetMessageType")

function NetMessageType:initialize(name)
	self._name = assert(name, "A message type needs a name")
	self._tempHandlers = {}

	self.connection = nil
	self.mode = NetMessageType.UNRELIABLE
	self.args = {}
end

function NetMessageType:getName()
	return self._name
end

function NetMessageType:onReceive(message)
	-- Override. Called for every message that was received.
end

function NetMessageType:addOnceOnReceive(closure)
	self._tempHandlers[#self._tempHandlers + 1] = closure
end

function NetMessageType:_strip(message)
	for k, v in pairs(message) do
		if self.args[k] == nil or self.args[k] == v then
			message[k] = nil
		end
	end
end

function NetMessageType:_expand(message)
	for k, v in pairs(message) do
		if self.args[k] ~= nil then
			message[k] = self.args[k]
		end
	end
end

function NetMessageType:_encode(message)
	message._type = self._name
	return bitser.dumps(message)
end

function NetMessageType:_invoke(message)
	self:_expand(message)
	self:onReceive(message)

	if #self._tempHandlers > 0 then
		for i = 1, #self._tempHandlers do
			self._tempHandlers[i](self, message)
			self._tempHandlers[i] = nil
		end
	end
end

function NetMessageType.static:_decode(datagram)
	local message = bitser.loads(datagram)
	if type(message) ~= "table" then return end
	return message
end

NetMessageType.static.UNRELIABLE = "unsequenced"
NetMessageType.static.RELIABLE   = "reliable"

return NetMessageType

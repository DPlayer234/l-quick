--[[
A peer in the network (for Peer-To-Peer games).
]]
local currentModule = (...):gsub("[^%.]*$", "")

local enet = require "enet"

local NetPeer = middleclass("NetPeer")

local NetConnection  = require(currentModule .. "net_connection")
local NetMessageType = require(currentModule .. "net_message_type")

function NetPeer:initialize(port)
	self._host = self:createHost(port)

	self._connections = {}
	self._messageTypes = {}

	for k, v in pairs(NetPeer._messageTypes) do
		self._messageTypes[k] = v
	end
end

function NetPeer:createHost(port)
	return enet.host_create(port and ("*:%d"):format(port) or "*:*")
end

function NetPeer:getAddress()
	return self._host:get_socket_address()
end

function NetPeer:update()
	local event = self._host:service(0)
	while event do
		self._eventHandlers[event.type](self, event.peer, event.data)
		event = self._host:service(0)
	end
end

function NetPeer:broadcast(messageType, message)
	messageType:_strip(message)
	return self:broadcastDatagram(messageType:_encode(message), messageType.mode)
end

function NetPeer:broadcastDatagram(datagram, mode)
	return self._host:broadcast(datagram, 0, mode)
end

function NetPeer:sendTo(connection, messageType, message)
	messageType:_strip(message)
	return connection:_sendDatagram(messageType:_encode(message), messageType.mode)
end

function NetPeer:sendDatagramTo(connection, datagram, mode)
	return connection:_sendDatagram(datagram, mode)
end

function NetPeer:getMessageType(name, dontCreate)
	if not self._messageTypes[name] and not dontCreate then
		local messageType = NetMessageType(name)
		self._messageTypes[name] = messageType
	end

	return self._messageTypes[name]
end

function NetPeer:connect(address)
	local connection = NetConnection(self._host, address)
	self:_addConnection(connection)
	return connection
end

function NetPeer:getConnectionCount()
	return #self._connections
end

function NetPeer:getConnection(index)
	return self._connections[index]
end

function NetPeer:destroy()
	self._host:flush()
	self._host:destroy()
end

function NetPeer:_addPeer(peer)
	local connection = NetConnection(peer)
	self:_addConnection(connection)
	return connection
end

function NetPeer:_removePeer(peer)
	local connection, index = self:_getConnection(peer)
	table.remove(self._connections, index)
end

function NetPeer:_addConnection(connection)
	connection._netPeer = self
	self._connections[#self._connections + 1] = connection
end

function NetPeer:_getConnection(peer)
	for index, connection in ipairs(self._connections) do
		if connection._peer == peer then
			return connection, index
		end
	end
end

NetPeer._eventHandlers = setmetatable({
	receive = function(self, peer, datagram)
		local message = NetMessageType:_decode(datagram)
		if not message then
			return print("NetPeer", "MessageType unknown.", messageType._type)
		end

		local messageType = self:getMessageType(message._type, true)
		if messageType then
			return messageType:_invoke(message)
		else
			return print("NetPeer", "MessageType unknown.", messageType._type)
		end
	end,
	connect = function(self, peer, data)
		self:_addPeer(peer)
	end,
	disconnect = function(self, peer, data)
		self:_removePeer(peer)
	end
}, {
	__index = function(self, eventType)
		return function(self, peer, data)
			return print("NetPeer", "Event type unknown.", eventType, data)
		end
	end
})

NetPeer.static.getMessageType = NetPeer.getMessageType
NetPeer.static._messageTypes = {}

function NetPeer.static:subclassed(newclass)
	newclass.static._messageTypes = {}
end

return NetPeer

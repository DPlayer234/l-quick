--[[
A peer in the network (for Peer-To-Peer games).
]]
local currentModule = (...):gsub("[^%.]*$", "")

local pairs, tonumber = pairs, tonumber
local enet = require "enet"

local NetPeer = class("NetPeer")

local NetConnection  = require(currentModule .. "net_connection")
local NetMessageType = require(currentModule .. "net_message_type")

-- Initializes a NetPeer instance
function NetPeer:new()
	self._connections = {}
	self._messageTypes = {}

	for k, v in pairs(NetPeer._messageTypes) do
		self._messageTypes[k] = v
	end
end

-- Starts the peer and creates an ENet host.
-- If no port is supplied, a wildcard is used and a random port is chosen by ENet.
function NetPeer:start(port)
	if self:isRunning() then error("Cannot start an already running NetPeer. Did you mean to restart?") end

	self._host = self:createHost(port)
end

-- Shuts down the peer and destroys the ENet host
function NetPeer:shutdown()
	if not self:isRunning() then return end

	self._host:flush()
	self._host:destroy()

	self._host = nil
	self._connections = {}
end

-- Returns whether the peer is running.
function NetPeer:isRunning()
	return self._host ~= nil
end

-- Creates the host.
function NetPeer:createHost(port)
	return enet.host_create(port and ("*:%d"):format(port) or "*:*")
end

-- Gets the socket's address used.
function NetPeer:getAddress()
	self:_errorIfNotRunning("getAddress") --#exclude line

	return self._host:get_socket_address()
end

-- Returns the port (as a number).
function NetPeer:getPort()
	self:_errorIfNotRunning("getPort") --#exclude line

	return tonumber(self:getAddress():match("^.-:(.-)$"))
end

-- Updates the NetPeer, dequeues any stored events and handles received messages.
-- This should be called at least once every frame.
function NetPeer:service()
	self:_errorIfNotRunning("service") --#exclude line

	local event = self._host:service(0)
	while event do
		self._eventHandlers[event.type](self, event.peer, event.data)
		event = self._host:service(0)
	end
end

-- Broadcasts a message to all active connections.
function NetPeer:broadcast(messageType, message)
	self:_errorIfNotRunning("broadcast") --#exclude line

	messageType:_strip(message)
	return self:_broadcastDatagram(messageType:_encode(message), messageType.mode)
end

-- Sends a message to a specific connection.
function NetPeer:sendTo(connection, messageType, message)
	self:_errorIfNotRunning("sendTo") --#exclude line

	messageType:_strip(message)
	return connection:_sendDatagram(messageType:_encode(message), messageType.mode)
end

-- Gets (or even creates) a message type for this peer and returns it.
function NetPeer:getMessageType(name, dontCreate)
	if not self._messageTypes[name] and not dontCreate then
		local messageType = NetMessageType(name)
		self._messageTypes[name] = messageType
	end

	return self._messageTypes[name]
end

-- Connects the peer to a specified address ("hostname:port") and returns the new connection.
function NetPeer:connect(address)
	self:_errorIfNotRunning("connect") --#exclude line

	local connection = NetConnection(self._host, address)
	self:_addConnection(connection)
	return connection
end

-- Returns a new table with all connections. This is potentially slow if called often.
function NetPeer:getConnections()
	local connections = {}
	local index = 0
	for k, v in pairs(self._connections) do
		index = index + 1
		connections[index] = v
	end
	return connections
end

-- Internal. Broadcasts a datagram to all active connections.
function NetPeer:_broadcastDatagram(datagram, mode)
	return self._host:broadcast(datagram, 0, mode)
end

-- Internal. Sends a datagram to a specific connection.
function NetPeer:_sendDatagramTo(connection, datagram, mode)
	return connection:_sendDatagram(datagram, mode)
end

-- Internal. Adds a peer as a connection and returns it.
function NetPeer:_addPeer(peer)
	local connection = NetConnection(peer)
	self:_addConnection(connection)
	return connection
end

-- Internal. Removes a peer as a connection and returns it.
function NetPeer:_removePeer(peer)
	local connection = self._connections[peer]
	self._connections[peer] = nil
	return connection
end

-- Internal. Adds a connection.
function NetPeer:_addConnection(connection)
	connection._netPeer = self
	self._connections[connection._peer] = connection
end

--#exclude start
-- Throws an error if the function for an invalid call on non-running peers
function NetPeer:_errorIfNotRunning(func)
	if not self:isRunning() then
		return error("Cannot use " .. self.class.name .. ":" .. func .. " on not running peers.")
	end
end
--#exclude end

-- Internal. Event handlers for specific ENet events.
NetPeer._eventHandlers = setmetatable({
	-- Received data.
	receive = function(self, peer, datagram)
		local message = NetMessageType:_decode(datagram)
		if not message then
			return print("NetPeer", "MessageType unknown.", messageType._type)
		end

		local messageType = self:getMessageType(message._type, true)
		if messageType then
			return messageType:_invoke(self, self._connections[peer], message)
		else
			return print("NetPeer", "MessageType unknown.", messageType._type)
		end
	end,

	-- A connection has been established.
	connect = function(self, peer, data)
		local connection = self:_addPeer(peer)
		self:getMessageType("connect"):_invoke(self, connection, {})
	end,

	-- A connection has been removed.
	disconnect = function(self, peer, data)
		local connection = self:_removePeer(peer)
		self:getMessageType("disconnect"):_invoke(self, connection, {})
	end
}, {
	__index = function(self, eventType)
		return function(self, peer, data)
			return print("NetPeer", "Event type unknown.", eventType, data)
		end
	end
})

function NetPeer:__tostring()
	return ("%s: %s"):format(self.class.name, self:isRunning() and self:getAddress() or "inactive")
end

NetPeer._messageTypes = {}

function NetPeer:__inherited(newclass)
	newclass._messageTypes = {}
end

return NetPeer

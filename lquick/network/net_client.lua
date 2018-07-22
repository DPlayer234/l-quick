--[[
A game client to be connected to a server.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local enet = require "enet"

local NetPeer = require(currentModule .. "net_peer")

local NetClient = middleclass("NetClient", NetPeer)

-- Creates a host. Clients cannot be connected to.
function NetClient:createHost(port)
	return enet.host_create(nil)
end

-- Sends a message to the server.
function NetClient:send(messageType, message)
	return self:sendTo(self._serverConnection, messageType, message)
end

-- Connects the client to the server. This throws an error if there is already a connection.
function NetClient:connect(address)
	if self._serverConnection ~= nil then error("Can only connect NetClients to one remote-host.") end

	local connection = NetPeer.connect(self, address)
	self._serverConnection = connection
	return connection
end

-- Returns the server connection, if any.
function NetClient:getServerConnection()
	return self._serverConnection
end

-- Internal. Sends a datagram to the server.
function NetClient:_sendDatagram(datagram, mode)
	return self:_sendDatagramTo(self._serverConnection, datagram, mode)
end

-- Internal. Removes a peer as a connection and returns it.
function NetClient:_removePeer(peer)
	local connection = NetPeer._removePeer(self, peer)

	if connection == self._serverConnection then
		self._serverConnection = nil
	end

	return connection
end

return NetClient

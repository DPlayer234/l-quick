--[[
A game client to be connected to a server.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local enet = require "enet"

local NetPeer = require(currentModule .. "net_peer")

local NetClient = middleclass("NetClient", NetPeer)

function NetClient:createHost(port)
	return enet.host_create(nil)
end

function NetClient:send(messageType, message)
	return self:sendTo(self._serverConnection, messageType, message)
end

function NetClient:sendDatagram(datagram, mode)
	return self:sendDatagramTo(self._serverConnection, datagram, mode)
end

function NetClient:connect(address)
	if self._serverConnection ~= nil then error("Can only connect NetClients to one remote-host.") end
	local connection = NetPeer.connect(self, address)
	self._serverConnection = connection
	return connection
end

function NetClient:getServerConnection()
	return self._serverConnection
end

function NetClient:_removePeer(peer)
	NetPeer._removePeer(self, peer)

	if peer == self._serverConnection._peer then
		self._serverConnection = nil
	end
end

return NetClient

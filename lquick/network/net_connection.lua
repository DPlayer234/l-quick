--[[
Represents a connection in the network
]]
local enet = require "enet"

local NetConnection = middleclass("NetConnection")

function NetConnection:initialize(host, address)
	if host.connect then
		-- Object is a host and can connect somewhere
		self._peer = host:connect(address)
	else
		-- Object is probably a peer already
		self._peer = host
	end

	self._netPeer = nil
end

function NetConnection:getState()
	return self._peer:state()
end

function NetConnection:getID()
	return self._peer:connect_id()
end

function NetConnection:disconnect()
	if self._netPeer ~= nil then
		self._netPeer:_removePeer(self._peer)
	end

	return self._peer:disconnect()
end

function NetConnection:_sendDatagram(datagram, mode)
	return self._peer:send(datagram, 0, mode)
end

NetConnection.static.DISCONNECTED     = "disconnected"
NetConnection.static.CONNECTING       = "connecting"
NetConnection.static.ACK_CONNECT      = "acknowledging_connect"
NetConnection.static.PENDING          = "connection_pending"
NetConnection.static.SUCCESS          = "connection_succeeded"
NetConnection.static.CONNECTED        = "connected"
NetConnection.static.DISCONNECT_LATER = "disconnect_later"
NetConnection.static.DISCONNECTING    = "disconnecting"
NetConnection.static.ACK_DISCONNECT   = "acknowledging_disconnect"
NetConnection.static.ZOMBIE           = "zombie"
NetConnection.static.UNKNOWN          = "unknown"

return NetConnection

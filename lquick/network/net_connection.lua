--[[
Represents a connection in the network
You never need to create these explicitly.
]]
local enet = require "enet"

local NetConnection = middleclass("NetConnection")

-- Initializes a NetConnection instance.
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

-- Gets the state of the underlying ENet peer.
function NetConnection:getState()
	return self._peer:state()
end

-- Gets the ENet-connection ID.
function NetConnection:getID()
	return self._peer:connect_id()
end

-- Disconnects.
function NetConnection:disconnect()
	if self._netPeer ~= nil then
		self._netPeer:_removePeer(self._peer)
	end

	return self._peer:disconnect()
end

-- Internal. Sends a datagram over the connection.
function NetConnection:_sendDatagram(datagram, mode)
	return self._peer:send(datagram, 0, mode)
end

function NetConnection:__tostring()
	return ("%s: %s (%s)"):format(self.class.name, self._peer, self:getID())
end

-- All ENet connection states
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

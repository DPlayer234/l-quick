--[[
Represents a connection in the network
You never need to create these explicitly.
]]
local NetConnection = class("NetConnection")

-- Initializes a NetConnection instance.
function NetConnection:new(host, address)
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
	return ("%s: %s (%s)"):format(self.class.name, self._peer, self:getState())
end

-- All ENet connection states
NetConnection.DISCONNECTED     = "disconnected"
NetConnection.CONNECTING       = "connecting"
NetConnection.ACK_CONNECT      = "acknowledging_connect"
NetConnection.PENDING          = "connection_pending"
NetConnection.SUCCESS          = "connection_succeeded"
NetConnection.CONNECTED        = "connected"
NetConnection.DISCONNECT_LATER = "disconnect_later"
NetConnection.DISCONNECTING    = "disconnecting"
NetConnection.ACK_DISCONNECT   = "acknowledging_disconnect"
NetConnection.ZOMBIE           = "zombie"
NetConnection.UNKNOWN          = "unknown"

return NetConnection

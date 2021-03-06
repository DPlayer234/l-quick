--[[
A game server.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local NetPeer = require(currentModule .. "net_peer")

local NetServer = class("NetServer", NetPeer)

-- I get the feeling this isn't too useful right about now.

function NetServer:start(port)
	assert(port, "You must supply a port to start a server.")

	self.NetPeer.start(self, port)
end

return NetServer

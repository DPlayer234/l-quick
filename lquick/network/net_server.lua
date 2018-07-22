--[[
A game server.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local enet = require "enet"

local NetPeer = require(currentModule .. "net_peer")

local NetServer = middleclass("NetServer", NetPeer)

-- I get the feeling this isn't too useful right about now.

return NetServer

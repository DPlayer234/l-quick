--[[
Networking tests
]]
do
	G_netPeer = lquick.NetPeer:new()

	G_connectMessage = G_netPeer:getMessageType("connect")
	G_disconnectMessage = G_netPeer:getMessageType("disconnect")
	G_playerInfoMessage = G_netPeer:getMessageType("player_info")

	function G_connectMessage:onReceive()
		print("connect", self.netPeer, self.connection)
	end

	function G_disconnectMessage:onReceive()
		print("disconnect", self.netPeer, self.connection)
	end

	function G_playerInfoMessage:onReceive(message)
		print(self.connection)
		print(("Player %q connected! Job: %d"):format(message.name, message.job))
	end

	G_playerInfoMessage.mode = lquick.NetMessageType.RELIABLE
	G_playerInfoMessage.args = {
		name = "PLAYER",
		job = 0
	}

	function G_sendTestMessage(name, job)
		return G_netPeer:broadcast(G_playerInfoMessage, {
			name = name,
			job = job
		})
	end

	G_netPeer:start()
end

function love.update()
	if G_netPeer:isRunning() then
		G_netPeer:service()
	end
end

function love.draw()

end

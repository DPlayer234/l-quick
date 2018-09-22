local love = love

local ssui = { callback = {} }

function ssui.callback.init(input, context)
	-- Override the previous callbacks to include nuklear
	function love.keypressed(key, scancode, isrepeat)
		if not context:keypressed(key, scancode, isrepeat) then
			input.keypressed(key, scancode, isrepeat)
		end
	end

	function love.keyreleased(key, scancode)
		if not context:keyreleased(key, scancode) then
			input.keyreleased(key, scancode)
		end
	end

	function love.mousepressed(x, y, button, istouch)
		if not context:mousepressed(x, y, button, istouch) then
			input.mousepressed(x, y, button, istouch)
		end
	end

	function love.mousereleased(x, y, button, istouch)
		if not context:mousereleased(x, y, button, istouch) then
			input.mousereleased(x, y, button, istouch)
		end
	end

	function love.mousemoved(x, y, dx, dy, istouch)
		if not context:mousemoved(x, y, dx, dy, istouch) then
			input.mousemoved(x, y, dx, dy, istouch)
		end
	end

	function love.wheelmoved(x, y)
		if not context:wheelmoved(x, y) then
			input.wheelmoved(x, y)
		end
	end

	function love.textinput(text)
		context:textinput(text)
	end
end

function ssui.callback.deinit(input)
	-- Back to the original callbacks
	love.keypressed    = input.keypressed
	love.keyreleased   = input.keyreleased
	love.mousepressed  = input.mousepressed
	love.mousereleased = input.mousereleased
	love.mousemoved    = input.mousemoved
	love.wheelmoved    = input.wheelmoved
	love.textinput     = nil
end

return ssui.callback

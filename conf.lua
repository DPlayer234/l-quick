--[[
Löve Startup Configuration File
]]
function love.conf(t)
	-- General data
	_game = {
		title     = "Game Title",
		subtitle  = "Subtitle",
		copyright = "Copyright © YYYY Darius \"DPlay\" K.",
		developer = "Darius \"DPlay\" K.",
		publisher = "Publisher",
		version   = "0.0.0",
		identity  = "l-quick"
	}

	_game.fullTitle = _game.subtitle and _game.title .. ": " .. _game.subtitle or _game.title

	-- Main settings
	t.version = "11.1"
	t.accelerometerjoystick = false

	t.identity = _game.identity
	t.appendidentity = true
	t.externalstorage = false

	-- I'll create the window within love.load
	t.window = false
	t.gammacorrect = true

	-- Explicitly enabling/disabling modules
	t.modules.audio    = true
	t.modules.data     = true
	t.modules.event    = true
	t.modules.graphics = true
	t.modules.image    = true
	t.modules.joystick = true
	t.modules.keyboard = true
	t.modules.math     = true
	t.modules.mouse    = true
	t.modules.physics  = false
	t.modules.sound    = true
	t.modules.system   = true
	t.modules.timer    = true
	t.modules.touch    = false
	t.modules.video    = false
	t.modules.window   = true
	t.modules.thread   = true

	-- Argument processing
	_args = require "args"

	if type(_args.srgb) == "boolean" then t.gammacorrect = _args.srgb end
end

-- Load once and be done with it
middleclass = require "libs.middleclass"
bitser = require "libs.bitser"

lquick = require "lquick"

function love.load()
	local args = require "args"

	do
		-- Open the window
		local width, height = love.window.getDesktopDimensions()

		love.window.setMode(width*(2/3), height*(2/3), {
			fullscreen     = false,
			fullscreentype = "desktop",
			vsync          = true,
			resizable      = true,
			borderless     = false,
			minwidth       = 640,
			minheight      = 360,
			msaa           = 0
		})

		love.window.setIcon(love.image.newImageData("assets/textures/icon.png"))
	end

	lquick.loadAll()

	--require "tests.network"

	DBG = require "debugger" ()
	DBG.allowFunctionIndex(true)
	DBG.printWidth = 0.5
	love.errorhandler = DBG.errorhandler
end

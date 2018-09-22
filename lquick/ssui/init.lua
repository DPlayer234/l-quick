--[[
Simple Stateful User Interface
]]
local currentModule = (...):gsub("%.init$", "")

local ssui = {}

ssui.callbacks = require(currentModule .. ".callbacks")

ssui.Context        = require(currentModule .. ".context")
ssui.EventEmitter   = require(currentModule .. ".event_emitter")
ssui.Thickness      = require(currentModule .. ".thickness")
ssui.Widget         = require(currentModule .. ".widget")

ssui.Menu           = require(currentModule .. ".widgets.menu")

ssui.Button         = require(currentModule .. ".widgets.button")
ssui.CheckBox       = require(currentModule .. ".widgets.check_box")
ssui.ContextMenu    = require(currentModule .. ".widgets.context_menu")
ssui.EditBox        = require(currentModule .. ".widgets.edit_box")
ssui.Empty          = require(currentModule .. ".widgets.empty")
ssui.GridPanel      = require(currentModule .. ".widgets.grid_panel")
ssui.ImageButton    = require(currentModule .. ".widgets.image_button")
ssui.Label          = require(currentModule .. ".widgets.label")
ssui.ScrollBarPanel = require(currentModule .. ".widgets.scroll_bar_panel")
ssui.ScrollBar      = require(currentModule .. ".widgets.scroll_bar")
ssui.StackPanel     = require(currentModule .. ".widgets.stack_panel")
ssui.Tooltip        = require(currentModule .. ".widgets.tooltip")
ssui.Window         = require(currentModule .. ".widgets.window")

local context

function ssui.init(input)
	if context == nil then
		context = ssui.Context()
	end

	ssui.callbacks.init(input, context)
end

function ssui.deinit(input)
	ssui.callbacks.deinit(input)
end

function ssui.reset()
	context:reset()
end

function ssui.getContext()
	return context
end

function ssui.update()
	context:update()
end

function ssui.draw()
	context:draw()
end

return ssui

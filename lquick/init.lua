--[[
For quickstarting making a game.
]]
local lquick = {}

assert(middleclass, "middleclass is not loaded into the global variable. Please just do that. Please.")

-- Represents the folder structure.
-- Tables are folders and anything else is a file with the
-- value representing what key to store the data in.
local loadables = {
	-- All classes to load
	classes = {
		behavior_tree = "BehaviorTree",
		state_machine = "StateMachine",
		coroutine = "Coroutine",
		event_handler = "EventHandler",
		event_store = "EventStore",
		timer = "Timer",
		try = "try"
	},

	-- All structs to load
	structs = {
		vec2 = "Vec2",
		vec3 = "Vec3"
	}
}

local currentModule = (...):gsub("%.init$", "")

local function loadItem(folder, structure)
	for item, value in pairs(structure) do
		local fullname = folder .. "." .. item
		if type(value) == "table" then
			loadItem(fullname, value)
		else
			lquick[value] = require(fullname)
		end
	end
end

loadItem(currentModule, loadables)

return lquick

--[[
For quickstarting making a game.
]]
local lquick = {}

assert(middleclass, "middleclass is not loaded into the global variable.")

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
	},

	-- Networking classes
	network = {
		net_client = "NetClient",
		net_connection = "NetConnection",
		net_message_type = "NetMessageType",
		net_peer = "NetPeer",
		net_server = "NetServer"
	}
}

local currentModule = (...):gsub("%.init$", "")

local modules = {}

-- __index method for lquick
local onIndex = function(self, key)
	if modules[key] then
		local value = require(modules[key])
		rawset(self, key, value)
		return value
	end
end

-- Registers items as a module
local function registerItem(folder, structure)
	for item, value in pairs(structure) do
		local fullname = folder .. "." .. item
		if type(value) == "table" then
			registerItem(fullname, value)
		else
			modules[value] = fullname
		end
	end
end

registerItem(currentModule, loadables)

-- Loads all modules immediately
function lquick.loadAll()
	for key, _ in pairs(modules) do
		onIndex(lquick, key)
	end
end

-- Loads (and returns) a certain module
function lquick.load(key)
	if modules[key] == nil then
		error("Attempting to load unknown or unsupported module.")
	end

	return onIndex(lquick, key)
end

return setmetatable(lquick, {
	__index = onIndex
})

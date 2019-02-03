--[[
Simple library for loading and discarding data via garbage collector, that may not always be in use.
	loadingStorage = assets(name, constructor)
loadingStorage will also be stored as assets[name].
To get a value from the loadingStorage, do:
	myValue = loadingStorage[keyToGet]
	myValue = loadingStorage(keyToGet, ...)
If the resource is not in memory, it will call the constructor and return its output, meanwhile storing it for
latter re-usage.
]]

local rawget, rawset = rawget, rawset
local setmetatable, getmetatable = setmetatable, getmetatable
local type, assert = type, assert

local assets = {}

local constructors = setmetatable({}, { __mode = "k" })

local storeMeta = {
	__mode = "v",
	__call = function(t, k, ...)
		local v = rawget(t, k)
		if v ~= nil then
			return v
		else
			local new = constructors[t](k, ...)
			rawset(t, k, new)
			return new
		end
	end,
	__index = function(t, k)
		local new = constructors[t](k)
		rawset(t, k, new)
		return new
	end,
	__newindex = function(t, k, v)
		rawset(t, k, v)
	end,
	__tostring = function(t)
		return "store-"..tostring(constructors[t])
	end
}

-- Creates a new store-function with name
function assets:__call(name, constructor)
	if constructor == nil then return self(nil, name) end

	assert(type(constructor) == "function", "Argument #2 to 'assets' (constructor) is not a function.")
	local new = setmetatable({}, storeMeta)
	constructors[new] = constructor

	if name ~= nil then rawset(self, name, new) end

	return new
end

-- Clears out a store-function
function assets.clear(name)
	local store = assets[name] or name
	assert(getmetatable(store) == storeMeta, "assets.clear only accepts store-functions")
	for k, v in pairs(store) do
		store[k] = nil
	end
end

-- Deletes a store-function immediately. It may not be used anymore after this call.
function assets.delete(name)
	local store = assets[name] or name
	assert(getmetatable(store) == storeMeta, "assets.delete only accepts store-functions")
	if store ~= name then
		assets[name] = nil
	end
	assets.clear(store)
	constructors[store] = nil
end

-- Sets whether the GC is allowed to collect data loaded via a store-function
-- Defaults to 'true'
function assets.setAllowGC(allow)
	storeMeta.__mode = allow and "v" or ""
end

-- Gets whether the GC is allowed to collect data
function assets.getAllowGC()
	return (storeMeta.__mode:find("v")) and true or false
end

assets.__constructors = constructors
assets.__index = assets

assets = setmetatable({}, assets)

return assets

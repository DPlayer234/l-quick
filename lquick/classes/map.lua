--[[
A Map class whose methods are compatible with regular tables.
Has some of the functions of Array.
]]
local rawget, rawset, rawequal, pairs = rawget, rawset, rawequal, pairs

local Map = class("Map")

-- Initializes a new map.
function Map:new()
	-- Nothing needed
end

-- Gets a value
function Map:get(key)
	return rawget(self, key)
end

-- Sets a value
function Map:set(key, value)
	return rawset(self, key, value)
end

-- Returns whether there is a value for the specified key in the map
function Map:has(key)
	return not rawequal(rawget(self, key), nil)
end

-- Deletes a value from the map
function Map:delete(key)
	return rawset(self, key, nil)
end

-- Gets the size (amount of elements) in the map
function Map:getSize()
	local size = 0

	for k, v in pairs(self) do
		size = size + 1
	end

	return size
end

-- Creates a flat copy of the current map
function Map:copy()
	local map = Map()

	for k, v in pairs(self) do
		map[k] = v
	end

	return map
end

-- Returns the iterator for values in the map
function Map:iter()
	return pairs(self)
end

-- Returns a map with each value being applied the mapper(value, key) method.
function Map:map(mapper)
	local map = Map()

	for k, v in pairs(self) do
		map[k] = mapper(v, k)
	end

	return map
end

-- Returns whether at least one element in the map matches the condition given by cond(value, key).
function Map:some(cond)
	for k, v in pairs(self) do
		if cond(v, k) then
			return true
		end
	end

	return false
end

-- Reduces a map to a single value by accumulating each value via red(acc, value, key).
-- acc is the starting value and defaults to nil.
function Map:reduce(red, acc)
	for k, v in pairs(self) do
		acc = red(acc, v, k)
	end

	return acc
end

-- Executes a func(value, key) for every value in the map.
function Map:forEach(func)
	for k, v in pairs(self) do
		func(v, k)
	end
end

-- Converts a Lua table to one of this class in place.
function Map.to(luaTable)
	return setmetatable(luaTable, Map.BASE)
end

return Map

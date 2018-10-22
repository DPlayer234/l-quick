--[[
This is more less a reimplementation of JavaScript arrays and its methods.
Except their still 1-based and are backwards compatible with regular table "arrays".
Each of these functions may be used with such a normal array as well in the form of: Array.method(luaArray, ...)
]]
local table, ipairs, select, unpack = table, ipairs, select, unpack

local Array = class("Array")

local function toPosIndex(self, index)
	if index <= 0 then
		return #self + index
	end

	return index
end

-- Initializes a new array. Does not support setting length.
function Array:new()
	-- Nothing needed
end

-- Returns the length of the array/#self.
function Array:getLength()
	return #self
end

-- Creates a flat copy of this array.
function Array:copy()
	return Array.from(unpack(self))
end

-- Reverses the array content in place.
function Array:reverse()
	local temp = { unpack(self) }

	for i = 1, #self do
		self[i] = temp[#self - i + 1]
	end
end

-- Returns a new array with the values being the reverse of the source.
function Array:reversed()
	local arr = Array.copy(self)
	arr:reverse()
	return arr
end

-- Sorts the array in place by some condition.
function Array:sort(sorter)
	table.sort(self, sorter)
end

-- Creates a new array with all elements sorted by some condition.
function Array:sorted(sorter)
	local arr = Array.copy(self)
	arr:sort(sorter)
	return arr
end

-- Joins all values in the array to a string. May throw an error with invalid values.
function Array:join(sep)
	return table.concat(self, sep or ", ")
end

-- Returns an array with each value being applied the mapper(value, index) method.
function Array:map(mapper)
	local arr = Array()

	for i = 1, #self do
		arr[i] = mapper(self[i], i)
	end

	return arr
end

-- Returns whether at least one element in the array matches the condition given by cond(value, index).
function Array:some(cond)
	for i = 1, #self do
		if cond(self[i], i) then
			return true
		end
	end

	return false
end

-- Reduces an array to a single value by accumulating each value via red(acc, value, index).
-- acc is the starting value and defaults to nil.
function Array:reduce(red, acc)
	for i = 1, #self do
		acc = red(acc, self[i], i)
	end

	return acc
end

-- Removes and returns the first element of the array.
function Array:shift()
	return table.remove(self, 1)
end

-- Adds a new element to the beginning of the array.
function Array:unshift(value)
	return table.insert(self, 1, value)
end

-- Adds multiple elements to the beginning of the array.
function Array:unshiftMany(...)
	for i = 1, select("#", ...) do
		table.insert(self, i, (select(i, ...)))
	end
end

-- Removes and returns the last element of the array.
function Array:pop()
	return table.remove(self)
end

-- Adds a new element to the end of the array.
function Array:push(value)
	return table.insert(self, value)
end

-- Adds multiple elements to the end of the array.
function Array:pushMany(...)
	for i = 1, select("#", ...) do
		table.insert(self, (select(i, ...)))
	end
end

-- Executes a func(value, index) for every value in the array.
function Array:forEach(func)
	for i, v in ipairs(self) do
		func(v, i)
	end
end

-- Returns the first index of the given value in the array.
-- Returns nil if not found.
function Array:indexOf(value, fromIndex)
	for i = toPosIndex(self, fromIndex or 1), #self do
		if self[i] == value then
			return i
		end
	end
end

-- Returns the last index of the given value in the array.
-- Returns nil if not found.
function Array:lastIndexOf(value, fromIndex)
	for i = toPosIndex(self, fromIndex or #self), 1, -1 do
		if self[i] == value then
			return i
		end
	end
end

-- Returns whether the value is contained in the array
function Array:contains(value)
	for i = 1, #self do
		if self[i] == value then
			return true
		end
	end

	return false
end

-- Returns a slice of the array.
function Array:slice(begin, stop)
	begin = toPosIndex(self, begin or 1)
	stop = toPosIndex(self, stop or #self)

	local arr = Array()

	for i = begin, stop do
		arr:push(self[i])
	end

	return arr
end

-- Removes a specified set of elements of the array, returns them as a new array and may add new elements to it.
function Array:splice(start, deleteCount, ...)
	start = toPosIndex(self, start)
	deleteCount = deleteCount or #self - start + 1

	local arr = Array()

	for i = 1, deleteCount do
		arr[i] = self[start]
		table.remove(self, start)
	end

	for i = 1, select("#", ...) do
		table.insert(self, start + i - 1, (select(i, ...)))
	end

	return arr
end

-- Removes a value from an array
function Array:remove(value)
	local index = Array.indexOf(self, value)
	if index then
		Array.removeAt(self, index)
	end
	return false
end

-- Removes an element at a specified index and returns it
function Array:removeAt(index)
	return table.remove(self, index)
end

-- Returns an iterator for the array. (ipairs(self))
function Array:iter()
	return ipairs(self)
end

-- Unpacks the array. (unpack(self))
function Array:unpack()
	return unpack(self)
end

-- Creates an array from a set of values.
function Array.from(...)
	return setmetatable({ ... }, Array.BASE)
end

-- Converts a Lua array to one of this class in place.
function Array.to(luaArray)
	return setmetatable(luaArray, Array.BASE)
end

return Array

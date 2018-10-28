--[[
2D-Vector (using C-FFI Struct)
]]
local math = math
local type = type
local ffi = require "ffi"

local TYPE_NAME = "Vec2" --#const

-- Define the C structs
ffi.cdef [[
struct lquick_Vec2 {
	double x, y;
};
]]

-- Get the type in Lua (also used for construction)
local Vec2 = ffi.typeof("struct lquick_Vec2")

-- Constants
local const = {
	zero  = function() return Vec2( 0, 0) end,
	one   = function() return Vec2( 1, 1) end,
	left  = function() return Vec2(-1, 0) end,
	right = function() return Vec2( 1, 0) end,
	up    = function() return Vec2( 0,-1) end,
	down  = function() return Vec2( 0, 1) end,
}

-- Explicit methods
local methods = {
	-- Copy the current vector
	copy = function(self)
		return Vec2(self.x, self.y)
	end,
	-- Get the squared magnitude/length
	getMagnitudeSqr = function(self)
		return self.x * self.x + self.y * self.y
	end,
	-- Get the magnitude
	getMagnitude = function(self)
		return self:getMagnitudeSqr() ^ 0.5
	end,
	-- Gets the squared distance between two vectors
	getDistanceSqr = function(a, b)
		return (a - b):getMagnitudeSqr()
	end,
	-- Gets the distance between two vectors
	getDistance = function(a, b)
		return (a - b):getMagnitude()
	end,
	-- Returns a new vector with the same direction as the original, but a magnitude of 1
	getNormalized = function(self)
		local magnitude = self:getMagnitude()
		return magnitude == 0 and self:copy() or self / magnitude
	end,
	-- Gets the angle of a vector in relation to the coordinate grid
	getAngle = function(self)
		return math.atan2(self.y, self.x)
	end,
	-- Gets the angle between two vectors
	getAngleTo = function(a, b)
		return (a * b) / (a:getMagnitude() * b:getMagnitude())
	end,
	-- Returns a new vector, which is the original vector rotated by rad radians around origin or (0, 0)
	rotate = function(self, rad, origin)
		if not origin then origin = Vec2.zero end
		self = self - origin

		local sin = math.sin(rad)
		local cos = math.cos(rad)

		return Vec2(
			self.x * cos - self.y * sin,
			self.y * cos + self.x * sin
		) + origin
	end,
	-- Returns the "cross" product of two vectors. Equals the area of the parallelo gram the two vectors define.
	cross = function(a, b)
		return math.abs(a.x * b.y - a.y * b.x)
	end,
	-- Returns the result of a point multiplication.
	point = function(a, b)
		return a.x * b.x + a.y * b.y
	end,
	-- Memberwise addition (+)
	add = function(a, b)
		return a + b
	end,
	-- Memberwise subtraction (-)
	subtract = function(a, b)
		return a - b
	end,
	-- Memberwise multiplication (*)
	multiply = function(a, b)
		return Vec2(a.x * b.x, a.y * b.y)
	end,
	-- Memberwise division (/)
	divide = function(a, b)
		return Vec2(a.x / b.x, a.y / b.y)
	end,
	-- Memberwise modulo division (%)
	modulo = function(a, b)
		return Vec2(a.x % b.x, a.y % b.y)
	end,
	-- Memberwise exponent (^)
	power = function(a, b)
		return Vec2(a.x ^ b.x, a.y ^ b.y)
	end,
	-- Returns both components in order
	unpack = function(self)
		return self.x, self.y
	end,
	-- Returns the largest/smallest component
	max = function(self)
		return math.max(self.x, self.y)
	end,
	min = function(self)
		return math.min(self.x, self.y)
	end,
	-- Type
	type = function() return TYPE_NAME end,
	typeOf = function(self, name) return name == TYPE_NAME end,
	is = function(value) return ffi.istype(Vec2, value) end
}

-- Metatable, including operators
local meta = {
	-- Addition
	__add = function(a, b)
		return Vec2(a.x + b.x, a.y + b.y)
	end,
	-- Subtraction
	__sub = function(a, b)
		return Vec2(a.x - b.x, a.y - b.y)
	end,
	-- Vector * scalar or Scalar-Multiplication
	__mul = function(a, b)
		if type(a) == "number" then
			return Vec2(a * b.x, a * b.y)
		elseif type(b) == "number" then
			return Vec2(a.x * b, a.y * b)
		end
		error("Invalid operation.")
	end,
	-- Vector / scalar
	__div = function(a, b)
		if type(b) == "number" then
			return Vec2(a.x / b, a.y / b)
		end
		error("Invalid operation.")
	end,
	-- Unary minus
	__unm = function(a)
		return Vec2(-a.x, -a.y)
	end,
	-- Equality
	__eq = function(a, b)
		if Vec2.is(a) ~= Vec2.is(b) then return false end
		return a.x == b.x and a.y == b.y
	end,
	-- Nicer string format
	__tostring = function(self)
		return ("Vec2: %.3f, %.3f"):format(self.x, self.y)
	end,
	-- Indexer
	__index = function(self, key)
		if const[key] then
			return const[key]()
		end
		return methods[key]
	end
}

-- Assign metatable
ffi.metatype(Vec2, meta)

return Vec2

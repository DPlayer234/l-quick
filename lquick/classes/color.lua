-- Color class to be used with Löve's functionality
local math = math
local bit = require "bit"

local Color = middleclass("Color")

function Color:initialize(r, g, b, a)
	self[1] = r or 0.0
	self[2] = g or 0.0
	self[3] = b or 0.0
	self[4] = a or 0.0
end

function Color:getRGB()
	return self[1], self[2], self[3]
end

function Color:getHSV()
	local v = math.max(self[1], self[2], self[3])
	local delta = v - math.min(self[1], self[2], self[3])

	local h = delta == 0 and 0
		or v == self[1] and 60 * (((self[2] - self[3]) / delta) % 6)
		or v == self[2] and 60 * (((self[3] - self[1]) / delta) + 2)
		or                  60 * (((self[1] - self[2]) / delta) + 4)

	local s = v == 0 and 0 or delta / v
	return h, s, v
end

function Color:getAlpha()
	return self[4]
end

function Color.__add(a, b)
	return Color(a[1] + b[1], a[2] + b[2], a[3] + b[3], a[4] + b[4])
end

function Color.__sub(a, b)
	return Color(a[1] - b[1], a[2] - b[2], a[3] - b[3], a[4] - b[4])
end

function Color.__mul(a, b)
	if getmetatable(a) == getmetatable(b) then
		return Color(a[1] * b[1], a[2] * b[2], a[3] * b[3], a[4] * b[4])
	elseif type(a) == "number" then
		return Color(a * b[1], a * b[2], a * b[3], a * b[4])
	elseif type(b) == "number" then
		return Color(a[1] * b, a[2] * b, a[3] * b, a[4] * b)
	else
		error("Invalid operands.")
	end
end

function Color.__div(a, b)
	if getmetatable(a) == getmetatable(b) then
		return Color(a[1] / b[1], a[2] / b[2], a[3] / b[3], a[4] / b[4])
	elseif type(b) == "number" then
		return Color(a[1] / b, a[2] / b, a[3] / b, a[4] / b)
	else
		error("Invalid operands.")
	end
end

function Color.__pow(a, b)
	if getmetatable(a) == getmetatable(b) then
		return Color(a[1] ^ b[1], a[2] ^ b[2], a[3] ^ b[3], a[4] ^ b[4])
	elseif type(b) == "number" then
		return Color(a[1] ^ b, a[2] ^ b, a[3] ^ b, a[4] ^ b)
	else
		error("Invalid operands.")
	end
end

function Color.__unm(a)
	return Color(-a[1], -a[2], -a[3], -a[4])
end

function Color:__tostring()
	return ("#%02x%02x%02x%02x"):format(self[1] * 255, self[2] * 255, self[3] * 255, self[4] * 255)
end

function Color.__eq(a, b)
	return (a[4] == 0 and b[4] == 0) or
		(a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4])
end

function Color.static:RGB(r, g, b)
	return self:RGBA(r, g, b, 1.0)
end

function Color.static:RGBA(r, g, b, a)
	return Color(r, g, b, a)
end

function Color.static:HSV(h, s, v, a)
	h = h % 360
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	c = c + m
	x = x + m
	return h <  60 and Color(c, x, 0, a)
		or h < 120 and Color(x, c, 0, a)
		or h < 180 and Color(0, c, x, a)
		or h < 240 and Color(0, x, c, a)
		or h < 300 and Color(x, 0, c, a)
		or             Color(c, 0, x, a)
end

function Color.static:hex(value)
	local b = bit.band(value, 0xff) / 0xff
	local g = bit.band(bit.rshift(value,  8), 0xff) / 0xff
	local r = bit.band(bit.rshift(value, 16), 0xff) / 0xff

	return Color(r, g, b, 1.0)
end

function Color.static:hexa(value)
	local a = bit.band(value, 0xff) / 0xff
	local b = bit.band(bit.rshift(value,  8), 0xff) / 0xff
	local g = bit.band(bit.rshift(value, 16), 0xff) / 0xff
	local r = bit.band(bit.rshift(value, 24), 0xff) / 0xff

	return Color(r, g, b, a)
end

Color.static.red         = Color:hex(0xff0000)
Color.static.orange      = Color:hex(0xff7700)
Color.static.yellow      = Color:hex(0xffe100)
Color.static.green       = Color:hex(0x00be0e)
Color.static.aqua        = Color:hex(0x00ffff)
Color.static.blue        = Color:hex(0x0000ff)
Color.static.purple      = Color:hex(0xa500ff)
Color.static.magenta     = Color:hex(0xff00ff)
Color.static.white       = Color:hex(0xffffff)
Color.static.black       = Color:hex(0x000000)
Color.static.transparent = Color:hexa(0x00000)

return Color

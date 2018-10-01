local math = math
local type = type

local Thickness = class("Thickness")

function Thickness:new(left, top, right, bottom)
	self.left   = left
	self.top    = top or left
	self.right  = right or left
	self.bottom = bottom or top or left
end

function Thickness:clone()
	return Thickness(self.left, self.top, self.right, self.bottom)
end

function Thickness:getWidth()
	return self.left + self.right
end

function Thickness:getHeight()
	return self.top + self.bottom
end

function Thickness:getAverage()
	return (self.left + self.top + self.right + self.bottom) * 0.25
end

function Thickness:getMax()
	return math.max(self.left, self.top, self.right, self.bottom)
end

function Thickness:getMin()
	return math.min(self.left, self.top, self.right, self.bottom)
end

function Thickness.__add(a, b)
	return Thickness(a.left + b.left, a.top + b.top, a.right + b.right, a.bottom + b.bottom)
end

function Thickness.__sub(a, b)
	return Thickness(a.left - b.left, a.top - b.top, a.right - b.right, a.bottom - b.bottom)
end

function Thickness.__mul(a, b)
	if type(a) == "number" then
		return Thickness(a * b.left, a * b.top, a * b.right, a * b.bottom)
	elseif type(b) == "number" then
		return Thickness(a.left * b, a.top * b, a.right * b, a.bottom * b)
	end

	return Thickness(a.left * b.left, a.top * b.top, a.right * b.right, a.bottom * b.bottom)
end

function Thickness.__div(a, b)
	if type(b) == "number" then
		return Thickness(a.left / b, a.top / b, a.right / b, a.bottom / b)
	end

	return Thickness(a.left / b.left, a.top / b.top, a.right / b.right, a.bottom / b.bottom)
end

return Thickness

local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local Widget = require(parentModule .. ".widget")

local Empty = middleclass("Empty", Widget)

function Empty:initialize()
	Widget.initialize(self)
	self.transparent = true
end

return Empty

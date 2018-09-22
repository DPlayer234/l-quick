local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local Widget = require(parentModule .. ".widget")

local Empty = middleclass("Empty", Widget)

function Empty:init()
	Widget.init(self)
	self.transparent = true
end

return Empty

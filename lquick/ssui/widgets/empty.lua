local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local Widget = require(parentModule .. ".widget")

local Empty = class("Empty", Widget)

function Empty:new()
	self:Widget()
	self.transparent = true
end

return Empty

local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")

local math = math

local Widget = require(parentModule .. ".widget")

local GridPanel = middleclass("GridPanel", Widget)

local GridChild = middleclass("GridChild", Widget)

--[[
Define the panel
]]
function GridPanel:init(childMode, columnWidth, rowHeight, options)
	Widget.init(self)

	if options == nil then options = {} end

	self._childMode = childMode
	self._columnWidth = columnWidth or 1
	self._rowHeight = rowHeight or 1

	self._count = 0

	self.verticalFirst = not not options.verticalFirst

	self.transparent = true
end

function GridPanel:setPadding(a, b, c, d)
	self.Widget.setPadding(self, a, b, c, d)
	self._padding = self._padding * 0.5
	return self
end

function GridPanel:alignChildren()
	if self.verticalFirst then
		self:_alignVertical()
	else
		self:_alignHorizontal()
	end
end

function GridPanel:add(widget)
	return self.Widget.add(self, GridChild(self, widget))
end

function GridPanel:recalculateSize()
	self.Widget.recalculateSize(self)
	self:alignChildren()
end

function GridPanel:_alignHorizontal()
	local maxWidth, maxHeight
	if self._childMode == "absolute" then
		maxWidth, maxHeight = self:getInnerSize()
	else
		maxWidth, maxHeight = 1, 1
	end
	local columns = math.max(1, math.floor(maxWidth / self._columnWidth))

	if columns ~= self._count then
		self._count = columns

		for i=1, #self.children do
			local column = (i - 1) % columns
			local row = ((i - 1) - column) / columns

			self.children[i]:setBasePosition(column * self._columnWidth, row * self._rowHeight)
		end
	end

	if self._childMode == "absolute" and #self.children > 0 then
		local child = self.children[#self.children]
		local w, h = self:getSize()
		local cx, cy = child:getRelativePosition()
		local cw, ch = child:getSize()
		local th = cy + ch + self._padding:getHeight() + 1
		if th ~= h then
			self:setSize(w, th)
		end
	end
end

function GridPanel:_alignVertical()
	local maxWidth, maxHeight
	if self._childMode == "absolute" then
		maxWidth, maxHeight = self:getInnerSize()
	else
		maxWidth, maxHeight = 1, 1
	end
	local rows = math.max(1, math.floor(maxHeight / self._rowHeight))

	if rows ~= self._count then
		self._count = rows

		for i=1, #self.children do
			local row = (i - 1) % rows
			local column = ((i - 1) - row) / rows

			self.children[i]:setBasePosition(column * self._columnWidth, row * self._rowHeight)
		end
	end

	if self._childMode == "absolute" and #self.children > 0 then
		local child = self.children[#self.children]
		local w, h = self:getSize()
		local cx, cy = child:getRelativePosition()
		local cw, ch = child:getSize()
		local tw = cx + cw + self._padding:getWidth() + 1
		if tw ~= w then
			self:setSize(tw, h)
		end
	end
end

--[[
Define the panel children
]]
function GridChild:init(parent, widget)
	Widget.init(self)
	self:setPositionMode(parent._childMode, 0, 0)
	self:setSizeMode(parent._childMode, parent._columnWidth, parent._rowHeight)

	self._padding = parent:getPadding()

	self.transparent = true

	self:add(widget)
end

function GridChild:recalculatePosition()
	self:getParentSize()
	return self.Widget.recalculatePosition(self)
end

return GridPanel

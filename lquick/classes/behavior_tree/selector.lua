--[[
A selector is a node which will iterate over all its children in order until
one finishes successfully, then resets itself.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local Node = require(currentModule .. "node")

local Selector = class("Selector", Node)

function Selector:new()
	self:Node()
end

function Selector:reset()
	self.Node.reset(self)
	self._index = 1
end

function Selector:continue(...)
	self:resetFinish()

	-- Iterate over all children, starting at the one
	-- that was not finished last time
	for i=self._index, self:getChildCount() do
		local child = self:getChild(i)

		child:continue(...)

		-- If it is finished
		if child:isFinished() then
			-- and successfully returned
			if child:getResult() then
				self._result = child:getResult()
				self._finished = true
				self._index = 1
				return
			end
			-- otherwise continue the loop
		else
			-- Did not finish, cancel loop
			-- and continue next time.
			self._index = i
			return
		end
	end

	-- Nothing successful
	self._index = 1
	self._result = false
	self._finished = true
end

return Selector

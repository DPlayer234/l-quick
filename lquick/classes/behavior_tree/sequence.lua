--[[
A sequence runs all of its children in order until of them fails or
they're all done. Resets itself after that.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local Node = require(currentModule .. "node")

local Sequence = class("Sequence", Node)

function Sequence:new()
	self:Node()
end

function Sequence:reset()
	self.Node.reset(self)
	self._index = 1
end

function Sequence:continue(...)
	self:resetFinish()

	-- Iterate over all children, starting at the one
	-- that was not finished last time
	for i=self._index, self:getChildCount() do
		local child = self:getChild(i)

		child:continue(...)

		-- If it is finished
		if child:isFinished() then
			-- but failed to return, cancel
			if not child:getResult() then
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

	-- All successful
	self._index = 1
	self._result = true
	self._finished = true
end

return Sequence

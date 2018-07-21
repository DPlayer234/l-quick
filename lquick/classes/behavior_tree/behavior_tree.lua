--[[
This is a BehaviorTree.
You create it by supplying a predefined data structure representing the nodes.
If you want to do this manually, use the node classes directly and use the root node
instead of the BehaviorTree.
]]
local currentModule = (...):gsub("[^%.]*$", "")

local BehaviorTree = middleclass("BehaviorTree")

BehaviorTree.Node     = require(currentModule .. "node")
BehaviorTree.Task     = require(currentModule .. "task")
BehaviorTree.Selector = require(currentModule .. "selector")
BehaviorTree.Sequence = require(currentModule .. "sequence")
BehaviorTree.Parallel = require(currentModule .. "parallel")

-- Initialize a new BehaviorTree based on the given data structure
function BehaviorTree:initialize(data)
	self._root = BehaviorTree.Node.createFromData(data)
end

-- Gets the root node
function BehaviorTree:getRoot()
	return self._root
end

-- Continues the execution
function BehaviorTree:continue(...)
	if self:getRoot() then
		return self:getRoot():continue(...)
	end
end

return BehaviorTree

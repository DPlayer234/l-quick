--[[
This is any node element in the BehaviorTree.
]]
local assert, type = assert, type

local Node = middleclass("Node")

-- Initialize a new node (do not instantiate explicitly)
function Node:initialize()
	self._parent = nil

	self._children = {}
	self:reset()
end

-- Resets the node
function Node:reset()
	self._finished = false
	self._result = false
end

-- Resets the node if it is finished
function Node:resetFinish()
	if self:isFinished() then
		return self:reset()
	end
end

-- Resets the node and all its children
function Node:hardReset()
	self:reset()

	for i=1, #self._children do
		self._children[i]:hardReset()
	end
end

-- Adds a child node. The effects of this depend on the type of node.
-- Returns the node it was added to. (chaining calls)
function Node:addChild(node)
	assert(node:typeOf("Node"), "Can only add nodes to nodes.")
	assert(node:getParent() == nil, "Node cannot be added multiple times.")

	node._parent = self
	self._children[#self._children + 1] = node

	return self
end

-- Gets the amount of children.
function Node:getChildCount()
	return #self._children
end

-- Gets the child at the given index.
function Node:getChild(index)
	return self._children[index]
end

-- Gets the parent node.
function Node:getParent()
	return self._parent
end

-- Returns the result of the last continue
function Node:getResult()
	return self._result
end

-- Returns whether the last continue finished the operation.
function Node:isFinished()
	return self._finished
end

-- Override this to add behaviour (allows for custom node types)
function Node:continue(...) end

-- Additional constructor called when a node is created from data (for custom node types)
function Node:newData(data) end

local nodeTypes = {}

-- Creates an entirely new node from data
function Node.createFromData(data)
	assert(type(data) == "table", "Node data has to be a table.")
	assert(type(data.type) == "string", "'type' has to be a string.")
	local nodeType = nodeTypes[data.type]
	if nodeType == nil then error("No known node type '" .. data.type .. "'.") end

	local node = nodeType(data.param)
	node:newData(data)

	if data.children == nil then
		-- No children
	elseif type(data.children) == "table" then
		-- Add children
		for i=1, #data.children do
			node:addChild(Node.createFromData(data.children[i]))
		end
	else
		-- Something went terribly wrong, didn't it?
		error("'children' has to be a list of node data.")
	end

	return node
end

-- Called when the a custom type is inherited. Used to allow loading data.
function Node:__inherited(cls)
	assert(nodeTypes[cls.NAME] == nil, "Multiple node types with the same name are not allowed.")

	nodeTypes[cls.NAME] = cls
end

return Node

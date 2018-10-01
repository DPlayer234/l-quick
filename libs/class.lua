--[[
The class implementation used by Heartbeat.
(And then adjusted to work with this game.)
]]
local type, tostring = type, tostring
local setmetatable, getmetatable = setmetatable, getmetatable
local rawget, rawset, rawequal = rawget, rawset, rawequal
local pairs, next = pairs, next

-- This value can be replaced with another constant if need be
-- false may work as well.
local null = "null"

local class = setmetatable({}, {
	__call = function(self, ...)
		return self.new(...)
	end
})

local weakTable = { __mode = "kv" }
local defaultFalse = { __index = function() return false end }

-- Class System Main
-- For creation of classes

local function noNew(self)
	error("Cannot instantiate object of type " .. self.CLASS.NAME .. ": It has no 'new' field.", 3)
end

local function noPrecon()
	return {}
end

-- Instantiates a new instance of the given class.
-- Identical to cls(...)
function class.instantiate(cls, ...)
	local obj = setmetatable(cls.PRECON(), cls.BASE)
	return cls.NEW(obj, ...) or obj
end

-- These fields cannot be set
local reservedClassFields = {
	CLASS = true
}

-- These functions are called on the class upon extension
local extendByField = {
	-- Add a constructor
	new = function(cls, new)
		rawset(cls, "NEW", new == nil and (cls.PARENT and cls.PARENT.NEW or noNew) or new)
	end,
	-- Add the preconstruction function
	precon = function(cls, precon)
		rawset(cls, "PRECON", precon == nil and (cls.PARENT and cls.PARENT.PRECON or noPrecon) or precon)
	end,
	-- Add a custom indexer
	__index = function(cls, indexer)
		if indexer == nil then
			-- Reset the value
			cls.OVERRIDE.__index = false
			rawset(cls.BASE, "__index", cls.BASE)
		elseif type(indexer) == "function" then
			-- Add a new function indexer
			rawset(cls.BASE, "__index", function(self, k)
				local v = cls.BASE[k]
				if v == nil then
					return indexer(self, k)
				end
				return v
			end)
		else
			-- Set the indexer directly...?
			rawset(cls.BASE, "__index", indexer)
		end
	end
}

-- Extend a class by a method or value.
-- Identical to cls[k] = v
function class.extend(cls, k, v)
	cls.OVERRIDE[k] = true
	class._extendExact(cls, k, v)

	for _, cls in pairs(cls.CHILDREN) do
		class._extendByParent(cls, k, v, cls)
	end
end

-- Internally used to extend classes.
function class._extendByParent(cls, k, v, parent)
	if not cls.OVERRIDE[k] then
		class._extendExact(cls, k, v)

		for _, cls in pairs(cls.CHILDREN) do
			class._extendByParent(cls, k, v, parent)
		end
	end
end

-- Internally used to extend classes.
function class._extendExact(cls, k, v)
	if reservedClassFields[k] then
		error("Field '" .. tostring(k) .. "' is reserved in classes.", 3)
	else
		rawset(cls.BASE, k, v)

		if extendByField[k] then
			return extendByField[k](cls, v)
		end
	end
end

-- This is the metatable for classes.
local classMeta = {
	__index = function(self, k)
		return rawget(self.BASE, k)
	end,
	__tostring = function(self)
		if self.PARENT == nil then
			return "class " .. tostring(self.NAME)
		end
		return "class " .. tostring(self.NAME) .. " : " .. tostring(self.PARENT.NAME)
	end,
	__call = class.instantiate,
	__newindex = class.extend
}

-- This is the metatable for class bases.
local baseMeta = {
	__newindex = function()
		error("Should not directly add new fields to class bases. Use rawset if this is intentional.", 2)
	end,
	__call = function(base, self, ...)
		if base.new == nil then error("Cannot call '" .. base.CLASS.NAME .. "': The super-class has no such method.", 2) end
		return base.new(self, ...)
	end,
	__tostring = function(base)
		return ("base of class %s"):format(base.CLASS.NAME)
	end
}

-- Creates a new class.
function class.new(name, rawbase, parent)
	if (class.is(rawbase) or rawequal(rawbase, null)) then
		rawbase, parent = parent, rawbase
	end

	if rawequal(parent, nil) then
		parent = class.Default
	elseif rawequal(parent, null) then
		parent = nil
	elseif not class.is(parent) then
		error("Cannot extend a something that is not a class!", 2)
	end

	if type(name) ~= "string" then error("Class name has to be of type string!", 2) end

	local base = {}
	base.__index = base

	local override = {}

	local typeOf = setmetatable({ [name] = true }, defaultFalse)

	-- Copying parent fields
	if parent then
		for k,v in pairs(parent.BASE) do
			base[k] = v
		end

		for k,v in pairs(parent.TYPEOF) do
			typeOf[k] = v
		end

		base.__index = parent.OVERRIDE.__index and parent.BASE.__index or base
	end

	-- Copy itself
	base[name] = base

	setmetatable(base, baseMeta)

	-- Creating the class
	local cls = setmetatable({
		BASE = base,
		NEW = base.new or noNew,
		PRECON = base.precon or noPrecon,
		NAME = name,
		CHILDREN = setmetatable({}, weakTable),
		PARENT = parent,
		OVERRIDE = override,
		TYPEOF = typeOf
	}, classMeta)

	rawset(cls, "CLASS", cls)
	rawset(base, "CLASS", cls)

	-- Add new fields
	if rawbase then
		for k,v in pairs(rawbase) do
			cls[k] = v
		end
	end

	-- Parenting
	if parent then
		parent.CHILDREN[#parent.CHILDREN+1] = cls

		if parent.__inherited then
			parent:__inherited(cls)
		end
	end

	return cls
end

-- Returns whether the object in question is a class
function class.is(cls)
	return getmetatable(cls) == classMeta
end

-- Define the default class. Everything inherits from this.
local Default = class("Default")

function Default:type()
	return self.CLASS.NAME
end

function Default:typeOf(comp)
	return self.CLASS.TYPEOF[comp]
end

function Default:instantiate()
	local obj = {}
	for k,v in pairs(self) do
		obj[k] = v
	end
	return setmetatable(obj, getmetatable(self))
end

function Default:__call(arg)
	for k,v in pairs(arg) do
		self[k] = v
	end
	return self
end

function Default:__tostring()
	return ("%s: %p"):format(self:type(), self)
end

class.Default = Default

return class

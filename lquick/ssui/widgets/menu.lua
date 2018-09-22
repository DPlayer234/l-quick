local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local EventEmitter = require(parentModule .. ".event_emitter")

local Menu = middleclass("Menu", EventEmitter)

local Button = require(currentModule .. ".button")
local ImageButton = require(currentModule .. ".image_button")
Menu.Item = middleclass("Menu.Item", Button)
Menu.ImageItem = middleclass("Menu.ImageItem", ImageButton)

local weakTable = { __mode = "v" }

function Menu:initialize()
	EventEmitter.initialize(self)

	self._items = setmetatable({}, weakTable)

	self._selectedItem = false
end

function Menu:setSelectedItem(new)
	if self._selectedItem == new then return end

	local old = self._selectedItem
	self._selectedItem = new

	if old then old:emit("unselect") end
	if new then new:emit("select") end

	self:emit("change", new, old)
end

function Menu:getSelectedItem()
	return self._selectedItem
end

function Menu.Item:initialize(menu)
	Button.initialize(self)

	self._menu = menu

	self
	:on("draw", self._onMenuItemDraw)
	:on("click", self._onMenuItemClick)
end

function Menu.Item:getMenu()
	return self._menu
end

function Menu.Item:isSelected()
	return self._menu:getSelectedItem() == self
end

function Menu.Item:select()
	self._menu:setSelectedItem(self)
end

function Menu.Item:_onMenuItemDraw()
	if self:isSelected() then
		self:renderRect("line", "menuItemHighlight")
	end
end

function Menu.Item:_onMenuItemClick()
	self:select()
end

function Menu.ImageItem:initialize(menu, texture, quad)
	ImageButton.initialize(self, texture, quad)

	self._menu = menu

	self
	:on("draw", self._onMenuItemDraw)
	:on("click", self._onMenuItemClick)
end

Menu.ImageItem.getMenu = Menu.Item.getMenu
Menu.ImageItem.isSelected = Menu.Item.isSelected
Menu.ImageItem.select = Menu.Item.select
Menu.ImageItem._onMenuItemDraw = Menu.Item._onMenuItemDraw
Menu.ImageItem._onMenuItemDraw = Menu.Item._onMenuItemDraw
Menu.ImageItem._onMenuItemClick = Menu.Item._onMenuItemClick

return Menu

local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local utf8 = require "utf8"
local table = table

local Label = require(currentModule .. ".label")
local Widget = require(parentModule .. ".widget")

local EditBox = middleclass("EditBox", Widget)

function EditBox:initialize(startText)
	Widget.initialize(self)

	self:setPadding(4, 0)

	self._label = Label("", nil, "left")
	self:add(self._label)

	self._wasActive = false

	self
	:on("update", self._onEditBoxUpdate)
	:on("draw", self._onEditBoxDraw)
	:on("text", self._addText)
	:on("keydown", self._onKeyDown)
	:on("click", self._onEditBoxClick)

	self:setText(startText or "")
end

function EditBox:getText()
	return table.concat(self._chars)
end

function EditBox:setText(value)
	self:setTextNoValidate(value)
	self:_onValidate()
end

function EditBox:setTextNoValidate(value)
	self._chars = {}
	self._cursorPos = 1

	self:_addText(value)
end

function EditBox:_onValidate()
	self:emit("edit", self:getText())
end

function EditBox:_onEditBoxUpdate()
	local active = self:isActive()

	if not active and self._wasActive then
		self:_onValidate()
	end

	self._wasActive = active
end

function EditBox:_onEditBoxDraw()
	self:renderRect("fill", "edit")
	self:renderRect("line", "border")

	if self:isActive() then
		local x, y, w, h = self._label:getCharRect(self._cursorPos - 1)
		if x then
			love.graphics.setColor(self:getTheme().editCursor)
			love.graphics.rectangle("fill", x, y, w, h)
		end
	end
end

function EditBox:_onTextChange()
	self._label.text = self:getText()
end

function EditBox:_addText(text)
	for p, c in utf8.codes(text) do
		self:_addChar(utf8.char(c))
	end

	self:_onTextChange()
end

function EditBox:_addChar(char)
	table.insert(self._chars, self._cursorPos, char)
	self._cursorPos = self._cursorPos + 1
end

function EditBox:_removeChar()
	if self._chars[self._cursorPos - 1] then
		self._cursorPos = self._cursorPos - 1
		table.remove(self._chars, self._cursorPos)

		self:_onTextChange()
	end
end

function EditBox:_onKeyDown(key, scancode, isrepeat)
	if key == "backspace" then
		self:_removeChar()
	elseif key == "right" and self._cursorPos <= #self._chars then
		self._cursorPos = self._cursorPos + 1
	elseif key == "left" and self._cursorPos > 1 then
		self._cursorPos = self._cursorPos - 1
	elseif key == "return" then
		self:_onValidate()
	elseif (key == "v" and love.keyboard.isDown("lctrl")) or (key == "lctrl" and love.keyboard.isDown("v")) then
		local clipboardText = love.system.getClipboardText()
		if type(clipboardText) == "string" then
			self:_addText(clipboardText)
		end
	end
end

function EditBox:_onEditBoxClick() end

return EditBox

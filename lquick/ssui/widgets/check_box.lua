local parentModule = (...):gsub("%.[^%.]+%.[^%.]+$", "")
local currentModule = (...):gsub("%.[^%.]+$", "")

local love = require "love"

local Widget = require(parentModule .. ".widget")

local Button = require(currentModule .. ".button")
local CheckBox = class("CheckBox", Button)

function CheckBox:new(initState)
	self:Button()

	self.checked = initState or false

	self:on("click", self._onCheckBoxClick)
end

function CheckBox:getColorName()
	return
		self.checked and (self._pressed and "checkBoxCheckedActive" or self:isHovered() and "checkBoxCheckedHover" or "checkBoxChecked")
		or (self._pressed and "checkBoxActive" or self:isHovered() and "checkBoxHover" or "checkBox")
end

function CheckBox:_onCheckBoxClick()
	self.checked = not self.checked
end

return CheckBox

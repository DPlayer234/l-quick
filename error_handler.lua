--[[
Error handler mostly by 0x25a0:
https://love2d.org/forums/viewtopic.php?f=5&t=83881
]]

local love = love
local format, gsub = string.format, string.gsub
local traceback = debug.traceback

function love.errorhandler(error_message)
	local app_name = _game.title
	local version = _game.version
	local github_url = "https://www.github.com/<user>/<repo>"
	local email = "user@server.com"
	local edition = love.system.getOS()

	local tableFlip = "(╯°□°）╯︵ ┻━┻"

	local dialog_message = [[
%s crashed with the following error message:

%s

Would you like to report this crash so that it can be fixed?]]
	local title = tableFlip
	local full_error = traceback(error_message or "", 2)
	local message = format(dialog_message, app_name, full_error)
	local buttons = {
		"Yes, on GitHub",
		"Yes, copy error",
		"No",
		_arg.debug and tableFlip or nil --#exclude line
	}

	local pressedbutton = love.window.showMessageBox(title, message, buttons, "error")

	local function url_encode(text)
		-- This is not complete. Depending on your issue text, you might need to expand it!
		text = gsub(text, "\n", "%%0A")
		text = gsub(text, " ", "%%20")
		text = gsub(text, "#", "%%23")
		return text
	end

	local issuebody = [[
%s crashed with the following error message:

%s

[If you can, describe what you've been doing when the error occurred]

---
Version: %s
Edition: %s]]

	full_error = "```\n" .. full_error .. "\n```"
	issuebody = format(issuebody, app_name, full_error, version, edition)

	if pressedbutton == 1 then
		-- Surround traceback in ``` to get a Markdown code block
		issuebody = url_encode(issuebody)

		local subject = format("Crash in %s %s", app_name, version)
		local url = format("%s/issues/new?title=%s&body=%s", github_url, subject, issuebody)
		love.system.openURL(url)
	elseif pressedbutton == 2 then
		love.system.setClipboardText(issuebody)
	--#exclude start
	elseif pressedbutton == 4 then
		local s, r = pcall(function()
			return require("debugger").errorhandler(error_message, 5)
		end)
		if s then return r else return debug.debug() end
	--#exclude end
	end

	pcall(love.quit)
end

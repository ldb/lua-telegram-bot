--[[

bot-example.lua - Example code provided with the lua-telegram-bot library.

Copyright (C) 2016 @cosmonawt

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

]]

-- pass token as command line argument or insert it into code
local token = arg[1] or ""

-- create and configure new bot with set token
local bot, extension = require("lua-bot-api").configure(token)

-- override onMessageReceive function so it does what we want
extension.onMessageReceive = function (msg)
	print("New Message by " .. msg.from.first_name)

	if (msg.text == "/start") then
		bot.sendMessage(msg.from.id, "Hello there 👋\nMy name is " .. bot.first_name)
	elseif (msg.text == "ping") then
		bot.sendMessage(msg.chat.id, "pong!")
	else
		bot.sendMessage(msg.chat.id, "I am just an example, running on the Lua Telegram Framework written with ❤️ by @cosmonawt")
	end
end

-- override onPhotoReceive as well
extension.onPhotoReceive = function (msg)
	print("Photo received!")
	bot.sendMessage(msg.chat.id, "Nice photo! It dimensions are " .. msg.photo[1].width .. "x" .. msg.photo[1].height)
end

-- This runs the internal update and callback handler
-- you can even override run()
extension.run()
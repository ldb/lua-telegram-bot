--[[

lua-bot-api.lua - A Lua library to the Telegram Bot API
(https://core.telegram.org/bots/api)

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


local M = require("main") -- Main Bot Framework
local E = require("extension") -- Extension Framework
local C = {} -- Configure Constructor

-- configure and initialize bot
local function configure(token)

  if (token == "") then
    token = nil
  end

  M.token = assert(token, "No token specified!")
  local bot_info = M.getMe()
  if (bot_info) then
    M.id = bot_info.result.id
    M.username = bot_info.result.username
    M.first_name = bot_info.result.first_name
  end
  return M, E
end

C.configure = configure




return C

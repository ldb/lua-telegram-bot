--[[

lua-bot-api-test.lua - Example code provided with the lua-telegram-bot library.

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
local bot = require("lua-bot-api").configure(token)

-- get table of updates
local updates = bot.getUpdates()

-- for each update, check the message
-- Note: processing a message does not prevent it from appearing again, unless
-- you feed it's update id (incremented by one) back into getUpdates()
for key, query in pairs(updates.result) do
  -- only reply to private chats, not groups
  if(query.message.chat.type == "private") then
    -- if message text was 'ping'
    if query.message.text == "ping" then
      -- reply with 'pong'
      bot.sendMessage(query.message.from.id, "pong")

    -- if message text was 'photo'
    elseif query.message.text == "photo" then
      -- get the users profile pictures
      local profilePicture = getUserProfilePhotos(query.message.from.id)
      -- and send the first one back to him using its file id
      bot.sendPhoto(query.message.from.id, profilePicture.result.photos[1][1].file_id)
    end
  end
end

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

-- Import Libraries
local https = require("ssl.https")
local ltn12 = require("ltn12")
local encode = require("multipart.multipart-post").encode
local JSON = require("JSON")

local M = require("main") -- Main Bot Framework
local E = require("extension") -- Extension Framework
local C = {} -- Configure Constructor

-- JSON Error handlers
function JSON:onDecodeError(message, text, location, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON:\n", message)
end

function JSON:onDecodeOfHTMLError(message, text, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON [HTML]:\n", message)
end

function JSON:onDecodeOfNilError(message, _nil, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON [nil]:\n", message)
end

function JSON:onEncodeError(message, etc)
  print((os.date("%x %X")), "Error while encoding JSON:\n", message)
end

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



-- Extension Framework

local function onUpdateReceive(update) end
E.onUpdateReceive = onUpdateReceive

local function onTextReceive(message) end
E.onMessageReceive = onMessageReceive

local function onPhotoReceive(message) end
E.onPhotoReceive = onPhotoReceive

local function onAudioReceive(message) end
E.onAudioReceive = onAudioReceive

local function onDocumentReceive(message) end
E.onDocumentReceive = onDocumentReceive

local function onStickerReceive(message) end
E.onStickerReceive = onStickerReceive

local function onVideoReceive(message) end
E.onVideoReceive = onVideoReceive

local function onVoiceReceive(message) end
E.onVoiceReceive = onVoiceReceive

local function onContactReceive(message) end
E.onContactReceive = onContactReceive

local function onLocationReceive(message) end
E.onLocationReceive = onLocationReceive

local function onLeftChatParticipant(message) end
E.onLeftChatParticipant = onLeftChatParticipant

local function onNewChatParticipant(message) end
E.onNewChatParticipant = onNewChatParticipant

local function onNewChatTitle(message) end
E.onNewChatTitle = onNewChatTitle

local function onNewChatPhoto(message) end
E.onNewChatPhoto = onNewChatPhoto

local function onDeleteChatPhoto(message) end
E.onDeleteChatPhoto = onDeleteChatPhoto

local function onGroupChatCreated(message) end
E.onGroupChatCreated = onGroupChatCreated

local function onSupergroupChatCreated(message) end
E.onsuperGroupChatCreated = onsuperGroupChatCreated

local function onChannelChatCreated(message) end
E.onChannelChatCreated = onChannelChatCreated

local function onMigrateToChatId(message) end
E.onMigrateToChatId = onMigrateToChatId

local function onMigrateFromChatId(message) end
E.onMigrateFromChatId = onMigrateFromChatId

local function onInlineQueryReceive(inlineQuery) end
E.onInlineQueryReceive = onInlineQueryReceive

local function onChosenInlineQueryReceive(chosenInlineQuery) end
E.onChosenInlineQueryReceive = onChosenInlineQueryReceive

local function onUnknownTypeReceive(unknownType)
  print("new unknownType!")
end
E.onUnknownTypeReceive = onUnknownTypeReceive

local function parseUpdateCallbacks(update)
  if (update) then
    E.onUpdateReceive(update)
  end
  if (update.message) then
    if (update.message.text) then
      E.onTextReceive(update.message)
    elseif (update.message.photo) then
      E.onPhotoReceive(update.message)
    elseif (update.message.audio) then
      E.onAudioReceive(update.message)
    elseif (update.message.document) then
      E.onDocumentReceive(update.message)
    elseif (update.message.sticker) then
      E.onStickerReceive(update.message)
    elseif (update.message.video) then
      E.onVideoReceive(update.message)
    elseif (update.message.voice) then
      E.onVoiceReceive(update.message)
    elseif (update.message.contact) then
      E.onContactReceive(update.message)
    elseif (update.message.location) then
      E.onLocationReceive(update.message)
    elseif (update.message.left_chat_participant) then
      E.onLeftChatParticipant(update.message)
    elseif (update.message.new_chat_participant) then
      E.onNewChatParticipant(update.message)
    elseif (update.message.new_chat_photo) then
      E.onNewChatPhoto(update.message)
    elseif (update.message.delete_chat_photo) then
      E.onDeleteChatPhoto(update.message)
    elseif (update.message.group_chat_created) then
      E.onGroupChatCreated(update.message)
    elseif (update.message.supergroup_chat_created) then
      E.onSupergroupChatCreated(update.message)
    elseif (update.message.channel_chat_created) then
      E.onChannelChatCreated(update.message)
    elseif (update.message.migrate_to_chat_id) then
      E.onMigrateToChatId(update.message)
    elseif (update.message.migrate_from_chat_id) then
      E.onMigrateFromChatId(update.message)
    else
      E.onUnknownTypeReceive(update)
    end
  elseif (update.inline_query) then
    E.onInlineQueryReceive(update.inline_query)
  elseif (update.chosen_inline_result) then
    E.onChosenInlineQueryReceive(update.chosen_inline_result)
  else
    E.onUnknownTypeReceive(update)
  end
end

local function run(limit, timeout,update_func)
  if limit == nil then limit = 1 end
  if timeout == nil then timeout = 0 end
  local offset = 0
  local time = os.time()
  while true do 
    local dt = os.difftime(os.time(),time)
    update_func(dt)  
    time = time + dt
    local updates = M.getUpdates(offset, limit, timeout)
    if(updates) then
      if (updates.result) then
        for key, update in pairs(updates.result) do
          parseUpdateCallbacks(update)
          offset = update.update_id + 1
        end
      end
    end
  end
end

E.run = run

return C

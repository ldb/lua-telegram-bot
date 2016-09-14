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

local M = {} -- Main Bot Framework
local E = {} -- Extension Framework
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
  --print((os.date("%x %X")), "Error while decoding JSON:\n", message)
  local datefile = os.date("%d-%m-%Y.txt")
  print((os.date("%x %X")), "Error: decode JSON, logged in ".. datefile)
  local log = io.open("errors/" .. datefile,"a+") -- open log
  log:write((os.date("%x %X")), "Error while decoding JSON:\n", message .. "\n") -- write in log
  log:close()
          
end

function JSON:onDecodeOfHTMLError(message, text, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  --print((os.date("%x %X")), "Error while decoding JSON [HTML]:\n", message)
  local datefile = os.date("%d-%m-%Y.txt")
  print((os.date("%x %X")), "Error: decode JSON [HTML], logged in ".. datefile)
  local log = io.open("errors/" .. datefile,"a+") -- open log
  log:write((os.date("%x %X")), "Error while decoding JSON [HTML]:\n", message .. "\n") -- write in log
  log:close()
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

local function makeRequest(method, request_body)

  local response = {}
  local body, boundary = encode(request_body)

  local success, code, headers, status = https.request{
    url = "https://api.telegram.org/bot" .. M.token .. "/" .. method,
    method = "POST",
    headers = {
      ["Content-Type"] =  "multipart/form-data; boundary=" .. boundary,
    	["Content-Length"] = string.len(body),
    },
    source = ltn12.source.string(body),
    sink = ltn12.sink.table(response),
  }

  local r = {
    success = success or "false",
    code = code or "0",
    headers = table.concat(headers or {"no headers"}),
    status = status or "0",
    body = table.concat(response or {"no response"}),
  }
  return r
end

-- Helper functions

local function downloadFile(file_id, download_path)

  if not file_id then return nil, "file_id not specified" end
  if not download_path then return nil, "download_path not specified" end

  local response = {}

  local file_info = getFile(file_id)
  local download_file_path = download_path or "downloads/" .. file_info.result.file_path

  local download_file = io.open(download_file_path, "w")

  if not download_file then return nil, "download_file could not be created"
  else
    local success, code, headers, status = https.request{
      url = "https://api.telegram.org/file/bot" .. M.token .. "/" .. file_info.result.file_path,
      --source = ltn12.source.string(body),
      sink = ltn12.sink.file(download_file),
    }

    local r = {
      success = true,
      download_path = download_file_path,
      file = file_info.result
    }
    return r
  end
end

M.downloadFile = downloadFile

local function generateReplyKeyboardMarkup(keyboard, resize_keyboard, one_time_keyboard, selective)

  if not keyboard then return nil, "keyboard not specified" end
  if #keyboard < 1 then return nil, "keyboard is empty" end

  local response = {}

  response.keyboard = keyboard
  response.resize_keyboard = resize_keyboard
  response.one_time_keyboard = one_time_keyboard
  response.selective = selective


  local responseString = JSON:encode(response)
  return responseString
end

M.generateReplyKeyboardMarkup = generateReplyKeyboardMarkup


local function generateReplyKeyboardHide(hide_keyboard, selective)

  local response = {}

  response.hide_keyboard = true
  response.selective = selective

  local responseString = JSON:encode(response)
  return responseString
end

M.generateReplyKeyboardHide = generateReplyKeyboardHide


local function generateForceReply(force_reply, selective)

  local response = {}

  response.force_reply = true
  response.selective = selective

  local responseString = JSON:encode(response)
  return responseString
end

M.generateForceReply = generateForceReply

-- Bot API 1.0

local function getUpdates(offset, limit, timeout)

  local request_body = {}

  request_body.offset = offset
  request_body.limit = limit
  request_body.timeout = timeout or 0

  local response =  makeRequest("getUpdates", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getUpdates = getUpdates


local function getMe()
  local request_body = {""}

  local response = makeRequest("getMe",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getMe = getMe


local function sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not text then return nil, "text not specified" end

  local allowed_parse_mode = {
    ["Markdown"] = true,
    ["HTML"] = true
  }

  if (not allowed_parse_mode[parse_mode]) then parse_mode = "" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.text = tostring(text)
  request_body.parse_mode = parse_mode
  request_body.disable_web_page_preview = tostring(disable_web_page_preview)
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendMessage",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendMessage = sendMessage

local function forwardMessage(chat_id, from_chat_id, disable_notification, message_id)

  if not chat_id then return nil, "chat_id not specified" end
  if not from_chat_id then return nil, "from_chat_id not specified" end
  if not message_id then return nil, "message_id not specified" end

  local request_body = {""}

  request_body.chat_id = chat_id
  request_body.from_chat_id = from_chat_id
  request_body.disable_notification = tostring(disable_notification)
  request_body.message_id = tonumber(message_id)

  local response = makeRequest("forwardMessage",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.forwardMessage = forwardMessage


local function sendPhoto(chat_id, photo, caption, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not photo then return nil, "photo not specified" end

  local request_body = {""}
  local file_id = ""
  local photo_data = {}

  if not(string.find(photo, "%.")) then
    file_id = photo
  else
    file_id = nil
    local photo_file = io.open(photo, "r")

    photo_data.filename = photo
    photo_data.data = photo_file:read("*a")
    photo_data.content_type = "image"

    photo_file:close()
  end

  request_body.chat_id = chat_id
  request_body.photo = file_id or photo_data
  request_body.caption = caption
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendPhoto",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendPhoto = sendPhoto


local function sendAudio(chat_id, audio, duration, performer, title, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not audio then return nil, "audio not specified" end

  local request_body = {}
  local file_id = ""
  local audio_data = {}

  if not(string.find(audio, "%.mp3")) then
    file_id = audio
  else
    file_id = nil
    local audio_file = io.open(audio, "r")

    audio_data.filename = audio
    audio_data.data = audio_file:read("*a")
    audio_data.content_type = "audio/mpeg"

    audio_file:close()
  end

  request_body.chat_id = chat_id
  request_body.audio = file_id or audio_data
  request_body.duration = duration
  request_body.performer = performer
  request_body.title = title
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendAudio",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendAudio = sendAudio


local function sendDocument(chat_id, document, caption, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not document then return nil, "document not specified" end

  local request_body = {}
  local file_id = ""
  local document_data = {}

  if not(string.find(document, "%.")) then
    file_id = document
  else
    file_id = nil
    local document_file = io.open(document, "r")

    document_data.filename = document
    document_data.data = document_file:read("*a")

    document_file:close()
  end

  request_body.chat_id = chat_id
  request_body.document = file_id or document_data
  request_body.caption = caption
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendDocument",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendDocument = sendDocument


local function sendSticker(chat_id, sticker, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not sticker then return nil, "sticker not specified" end

  local request_body = {}
  local file_id = ""
  local sticker_data = {}

  if not(string.find(sticker, "%.webp")) then
    file_id = sticker
  else
    file_id = nil
    local sticker_file = io.open(sticker, "r")

    sticker_data.filename = sticker
    sticker_data.data = sticker_file:read("*a")
    sticker_data.content_type = "image/webp"

    sticker_file:close()
  end

  request_body.chat_id = chat_id
  request_body.sticker = file_id or sticker_data
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendSticker",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendSticker = sendSticker


local function sendVideo(chat_id, video, duration, caption, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not video then return nil, "video not specified" end

  local request_body = {}
  local file_id = ""
  local video_data = {}

  if not(string.find(video, "%.")) then
    file_id = video
  else
    file_id = nil
    local video_file = io.open(video, "r")

    video_data.filename = video
    video_data.data = video_file:read("*a")
    video_data.content_type = "video"

    video_file:close()
  end

  request_body.chat_id = chat_id
  request_body.video = file_id or video_data
  request_body.duration = duration
  request_body.caption = caption
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendVideo",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendVideo = sendVideo


local function sendVoice(chat_id, voice, duration, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not voice then return nil, "voice not specified" end

  local request_body = {}
  local file_id = ""
  local voice_data = {}

  if not(string.find(voice, "%.ogg")) then
    file_id = voice
  else
    file_id = nil
    local voice_file = io.open(voice, "r")

    voice_data.filename = voice
    voice_data.data = voice_file:read("*a")
    voice_data.content_type = "audio/ogg"

    voice_file:close()
  end

  request_body.chat_id = chat_id
  request_body.voice = file_id or voice_data
  request_body.duration = duration
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendVoice",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendVoice = sendVoice

local function sendLocation(chat_id, latitude, longitude, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not latitude then return nil, "latitude not specified" end
  if not longitude then return nil, "longitude not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.latitude = tonumber(latitude)
  request_body.longitude = tonumber(longitude)
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendLocation",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendLocation = sendLocation

local function sendChatAction(chat_id, action)

  if not chat_id then return nil, "chat_id not specified" end
  if not action then return nil, "action not specified" end

  local request_body = {}

  local allowedAction = {
    ["typing"] = true,
    ["upload_photo"] = true,
    ["record_video"] = true,
    ["upload_video"] = true,
    ["record_audio"] = true,
    ["upload_audio"] = true,
    ["upload_document"] = true,
    ["find_location"] = true,
  }

  if (not allowedAction[action]) then action = "typing" end

  request_body.chat_id = chat_id
  request_body.action = action

  local response = makeRequest("sendChatAction",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendChatAction = sendChatAction

local function getUserProfilePhotos(user_id, offset, limit)

  if not user_id then return nil, "user_id not specified" end

  local request_body = {}

  request_body.user_id = tonumber(user_id)
  request_body.offset = offset
  request_body.limit = limit

  local response = makeRequest("getUserProfilePhotos",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getUserProfilePhotos = getUserProfilePhotos

local function getFile(file_id)

  if not file_id then return nil, "file_id not specified" end

  local request_body = {}

  request_body.file_id = file_id

  local response = makeRequest("getFile",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getFile = getFile

local function answerInlineQuery(inline_query_id, results, cache_time, is_personal, next_offset, switch_pm_text, switch_pm_parameter)

  if not inline_query_id then return nil, "inline_query_id not specified" end
  if not results then return nil, "results not specified" end

  local request_body = {}

  request_body.inline_query_id = tostring(inline_query_id)
  request_body.results = JSON:encode(results)
  request_body.cache_time = tonumber(cache_time)
  request_body.is_personal = tostring(is_personal)
  request_body.next_offset = tostring(next_offset)
  request_body.switch_pm_text = tostring(switch_pm_text)
  request_body.switch_pm_parameter = tostring(switch_pm_text)

  local response = makeRequest("answerInlineQuery",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.answerInlineQuery = answerInlineQuery

-- Bot API 2.0

local function sendVenue(chat_id, latitude, longitude, title, adress, foursquare_id, disable_notification, reply_to_message_id, reply_markup)
  
  if not chat_id then return nil, "chat_id not specified" end
  if not latitude then return nil, "latitude not specified" end
  if not longitude then return nil, "longitude not specified" end
  if not title then return nil, "title not specified" end
  if not adress then return nil, "adress not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.latitude = tonumber(latitude)
  request_body.longitude = tonumber(longitude)
  request_body.title = title
  request_body.adress = adress
  request_body.foursquare_id = foursquare_id
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendVenue",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendVenue = sendVenue

local function sendContact(chat_id, phone_number, first_name, last_name, disable_notification, reply_to_message_id, reply_markup)
  
  if not chat_id then return nil, "chat_id not specified" end
  if not phone_number then return nil, "phone_number not specified" end
  if not first_name then return nil, "first_name not specified" end
 
  request_body.chat_id = chat_id
  request_body.phone_number = tostring(phone_number)
  request_body.first_name = tostring(first_name)
  request_body.last_name = tostring(last_name)
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendContact",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.sendContact = sendContact

local function kickChatMember(chat_id, user_id)
	if not chat_id then return nil, "chat_id not specified" end
	if not user_id then return nil, "user_id not specified" end

	local request_body = {}

	request_body.chat_id = chat_id
	request_body.user_id = tonumber(user_id)
	
	local response = makeRequest("kickChatMember",request_body)

	  if (response.success == 1) then
	    return JSON:decode(response.body)
	  else
	    return nil, "Request Error"
  end
end

M.kickChatMember = kickChatMember

local function unbanChatMember(chat_id, user_id)
	if not chat_id then return nil, "chat_id not specified" end
	if not user_id then return nil, "user_id not specified" end

	local request_body = {}

	request_body.chat_id = chat_id
	request_body.user_id = tonumber(user_id) 
	
	local response = makeRequest("unbanChatMember",request_body)

	  if (response.success == 1) then
	    return JSON:decode(response.body)
	  else
	    return nil, "Request Error"
  end
end

M.unbanChatMember = unbanChatMember

local function answerCallbackQuery(callback_query_id, text, show_alert)

	if not callback_query_id then return nil, "callback_query_id not specified" end

	local request_body = {}

	request_body.callback_query_id = tostring(callback_query_id)
	request_body.text = tostring(text)
	request_body.show_alert = tostring(show_alert)
	
	local response = makeRequest("answerCallbackQuery",request_body)

	  if (response.success == 1) then
	    return JSON:decode(response.body)
	  else
	    return nil, "Request Error"
  end
end

M.answerCallbackQuery = answerCallbackQuery

local function editMessageText(chat_id, message_id, inline_message_id, text, parse_mode, disable_web_page_preview, reply_markup)
	
  if not chat_id and not inline_message_id then return nil, "chat_id not specified" end
  if not message_id and not inline_message_id then return nil, "message_id not specified" end
  if not inline_message_id and not (chat_id and message_id) then return nil, "inline_message_id not specified" end
  if not text then return nil, "text not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(message_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.text = tostring(text)
  request_body.parse_mode = tostring(parse_mode)
  request_body.disable_web_page_preview = disable_web_page_preview
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageText",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.editMessageText = editMessageText

local function editMessageCaption(chat_id, message_id, inline_message_id, caption, reply_markup)
  
  if not chat_id and not inline_message_id then return nil, "chat_id not specified" end
  if not message_id and not inline_message_id then return nil, "message_id not specified" end
  if not inline_message_id and not (chat_id and message_id) then return nil, "inline_message_id not specified" end
  if not caption then return nil, "caption not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(message_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.caption = tostring(caption)
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageCaption",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.editMessageCaption = editMessageCaption

local function editMessageReplyMarkup(chat_id, message_id, inline_message_id, reply_markup)
  
  if not chat_id and not inline_message_id then return nil, "chat_id not specified" end
  if not message_id and not inline_message_id then return nil, "message_id not specified" end
  if not inline_message_id and not (chat_id and message_id) then return nil, "inline_message_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(message_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageReplyMarkup",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.editMessageReplyMarkup = editMessageReplyMarkup

-- Bot API 2.1

local function getChat(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("getChat", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getChat = getChat

local function leaveChat(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("leaveChat", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.leaveChat = leaveChat

local function getChatAdministrators(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("getChatAdministrators", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getChatAdministrators = getChatAdministrators

local function getChatMembersCount(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("getChatMembersCount", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getChatMembersCount = getChatMembersCount

local function getChatMember(chat_id, user_id)

  if not chat_id then return nil, "chat_id not specified" end
  if not user_id then return nil, "user_id not specified" end


  local request_body = {}
  request_body.chat_id = chat_id
  request_body.user_id = user_id

  local response = makeRequest("getChatMember", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end

M.getChatMember = getChatMember

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

local function onEditedMessageReceive(message) end
E.onEditedMessageReceive = onEditedMessageReceive

local function onInlineQueryReceive(inlineQuery) end
E.onInlineQueryReceive = onInlineQueryReceive

local function onChosenInlineQueryReceive(chosenInlineQuery) end
E.onChosenInlineQueryReceive = onChosenInlineQueryReceive

local function onCallbackQueryReceive(CallbackQuery) end
E.onCallbackQueryReceive = onCallbackQueryReceive

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
  elseif (update.edited_message) then
    E.onEditedMessageReceive(update.edited_message)
  elseif (update.inline_query) then
    E.onInlineQueryReceive(update.inline_query)
  elseif (update.chosen_inline_result) then
    E.onChosenInlineQueryReceive(update.chosen_inline_result)
  elseif (update.callback_query) then
    E.onCallbackQueryReceive(update.callback_query)
  else
    E.onUnknownTypeReceive(update)
  end
end

local function run(limit, timeout)
  if limit == nil then limit = 1 end
  if timeout == nil then timeout = 0 end
  local offset = 0
  while true do 
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

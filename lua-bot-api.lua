-- Telegram Bot API Framework for LUA
-- Written by cosmonawt 2016
-- More information on the API: https://core.telegram.org/bots/api

-- Import Libraries
local https = require("ssl.https")
local ltn12 = require("ltn12")
local encode = (require "multipart.multipart-post").encode
local JSON = (loadfile "JSON.lua")()
local dump = (require "dump").dump

local M = {} -- Main Bot Framework
local C = {} -- Configure Constructor

function configure(token)
  M.token = token
  local bot_info = getMe()
  if (bot_info) then
    M.id = bot_info.id
    M.username = bot_info.username
    M.first_name = bot_info.first_name
  end
  return M
end

C.configure = configure


function makeRequest(method, request_body)

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
  --print(success, code, table.concat(headers or {"no headers"}), status)
  --print(table.concat(response or {"no body", }))
  local r = {
    success = success or "false",
    code = code or "0",
    headers = table.concat(headers or {"no headers"}),
    status = status or "0",
    body = table.concat(response or {"no response"}),
  }
  return r
end

function downloadFile(file_id, download_path)

  local response = {}

  local file_info = getFile(file_id)
  local download_file_path = download_path or "downloads/" .. file_info.result.file_path

  local download_file = io.open(download_file_path, "w")

  if (not download_file) then
    return {
      success = false,
      error = "File could not be created",
    }

  else
    local success, code, headers, status = https.request{
      url = "https://api.telegram.org/file/bot" .. M.token .. "/" .. file_info.result.file_path,
      --source = ltn12.source.string(body),
      sink = ltn12.sink.file(download_file),
    }

    local r = {
      success = true,
      download_path = download_file_path,
      file = file_info.result.
    }
    return r
  end
end

M.downloadFile = downloadFile


function getUpdates(offset, limit, timeout)
  local request_body = {""}

  request_body.offset = offset --or ""
  request_body.limit = limit --or ""
  request_body.offset = timeout --or ""

  local response =  makeRequest("getUpdates", request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.getUpdates = getUpdates


function getMe()
  local request_body = {""}

  local response = makeRequest("getMe",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.getMe = getMe


function sendMessage(chat_id, text, parse_mode, disable_web_page_preview, reply_to_message_id, reply_markup)
  local request_body = {""}

  request_body.chat_id = chat_id
  request_body.text = tostring(text)
  request_body.parse_mode = parse_mode or ""
  request_body.disable_web_page_preview = disable_web_page_preview or ""
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendMessage",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendMessage = sendMessage


function forwardMessage(chat_id, from_chat_id, message_id)
  local request_body = {""}

  request_body.chat_id = chat_id
  request_body.from_chat_id = from_chat_id
  request_body.message_id = tonumber(message_id)

  local response = makeRequest("forwardMessage",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.forwardMessage = forwardMessage


function sendPhoto (chat_id, photo, caption, reply_to_message_id, reply_markup)
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
  request_body.caption = caption or ""
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendPhoto",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendPhoto = sendPhoto


function sendAudio (chat_id, audio, duration, performer, title, reply_to_message_id, reply_markup)
  local request_body = {""}
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
  request_body.duration = duration or tonumber("")
  request_body.performer = performer or ""
  request_body.title = title or ""
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendAudio",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendAudio = sendAudio


function sendDocument (chat_id, document, reply_to_message_id, reply_markup)
  local request_body = {""}
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
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendDocument",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendDocument = sendDocument


function sendSticker (chat_id, sticker, reply_to_message_id, reply_markup)
  local request_body = {""}
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
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendSticker",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendSticker = sendSticker


function sendVideo (chat_id, video, duration, caption, reply_to_message_id, reply_markup)
  local request_body = {""}
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
  request_body.duration = duration or tonumber("")
  request_body.caption = caption or ""
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendVideo",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendVideo = sendVideo


function sendVoice (chat_id, voice, duration, reply_to_message_id, reply_markup)
  local request_body = {""}
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
  request_body.duration = duration or tonumber("")
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendVoice",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendAudio = sendAudio


function sendLocation(chat_id, latitude, longitude, reply_to_message_id, reply_markup)
  local request_body = {""}

  request_body.chat_id = chat_id
  request_body.latitude = tonumber(latitude)
  request_body.longitude = tonumber(longitude)
  request_body.reply_to_message_id = tonumber(reply_to_message_id) or tonumber("")
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendLocation",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendLocation = sendLocation


function sendChatAction (chat_id, action)
  local request_body = {""}

  local allowedAction = {
    "typing",
    "upload_photo",
    "record_video",
    "upload_video",
    "record_audio",
    "upload_audio",
    "upload_document",
    "find_location",
  }

  if (not allowedAction[action]) then action = "typing" end

  request_body.chat_id = chat_id
  request_body.action = action

  local response = makeRequest("sendChatAction",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.sendChatAction = sendChatAction


function getUserProfilePhotos (user_id, offset, limit)
  local request_body = {""}

  request_body.user_id = tonumber(user_id)
  request_body.offset = offset or tonumber("")
  request_body. limit = limit or tonumber("")

  local response = makeRequest("getUserProfilePhotos",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.getUserProfilePhotos = getUserProfilePhotos

function getFile (file_id)
  local request_body = {""}

  request_body.file_id = file_id

  local response = makeRequest("getFile",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, response.code
  end
end

M.getFile = getFile

function answerInlineQuery (args)
  -- body...
end




return C

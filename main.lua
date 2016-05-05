local M = {}
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

function M.downloadFile(file_id, download_path)
  
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


function M.generateReplyKeyboardMarkup(keyboard, resize_keyboard, one_time_keyboard, selective)

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



function M.generateReplyKeyboardHide(hide_keyboard, selective)

  local response = {}

  response.hide_keyboard = true
  response.selective = selective

  local responseString = JSON:encode(response)
  return responseString
end



function M.generateForceReply(force_reply, selective)

  local response = {}

  response.force_reply = true
  response.selective = selective

  local responseString = JSON:encode(response)
  return responseString
end

function M.getUpdates(offset, limit, timeout)

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



function M.getMe()
  local request_body = {""}

  local response = makeRequest("getMe",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end



function M.sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not text then return nil, "text not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.text = tostring(text)
  request_body.parse_mode = parse_mode or ""
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



function M.forwardMessage(chat_id, from_chat_id, disable_notification, message_id)

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



function M.sendPhoto(chat_id, photo, caption, disable_notification, reply_to_message_id, reply_markup)

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



function M.sendAudio(chat_id, audio, duration, performer, title, disable_notification, reply_to_message_id, reply_markup)

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



function M.sendDocument(chat_id, document, caption, disable_notification, reply_to_message_id, reply_markup)

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



function M.sendSticker(chat_id, sticker, disable_notification, reply_to_message_id, reply_markup)

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



function M.sendVideo(chat_id, video, duration, caption, disable_notification, reply_to_message_id, reply_markup)

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



function M.sendVoice(chat_id, voice, duration, disable_notification, reply_to_message_id, reply_markup)

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


function M.sendLocation(chat_id, latitude, longitude, disable_notification, reply_to_message_id, reply_markup)

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

function M.sendVenue(chat_id, latitude, longitude, title, adress, foursquare_id, disable_notification, reply_to_message_id, reply_markup)
  
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

function M.sendContact(chat_id, phone_number, first_name, last_name, disable_notification, reply_to_message_id, reply_markup)
  
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

function M.sendChatAction(chat_id, action)

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


function M.getUserProfilePhotos(user_id, offset, limit)

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

function M.getFile(file_id)

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

function M.kickChatMember(chat_id, user_id)
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


function M.unbanChatMember(chat_id, user_id)
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


function M.answerCallbackQuery(callback_query_id, text, show_alert)
	if not callback_query_id then return nil, "callback_query_id not specified" end

	local request_body = {}

	request_body.callback_query_id = tostring(callback_query_id)
	request_body.text = tostring(text)
	request_body.show_alert = show_alert
	
	local response = makeRequest("answerCallbackQuery",request_body)

	  if (response.success == 1) then
	    return JSON:decode(response.body)
	  else
	    return nil, "Request Error"
  end
end


function M.editMessageText(chat_id, message_id, inline_message_id, text, parse_mode, disable_web_page_preview, reply_markup)
	
  if not chat_id then return nil, "chat_id not specified" end
  if not message_id then return nil, "message_id not specified" end
  if not inline_message_id then return nil, "inline_message_id not specified" end
  if not text then return nil, "text not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(chat_id)
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


function M.editMessageCaption(chat_id, message_id, inline_message_id, caption, reply_markup)
  
  if not chat_id then return nil, "chat_id not specified" end
  if not message_id then return nil, "message_id not specified" end
  if not inline_message_id then return nil, "inline_message_id not specified" end
  if not caption then return nil, "caption not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(chat_id)
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


function M.editMessageReplyMarkup(chat_id, message_id, inline_message_id, reply_markup)
  
  if not chat_id then return nil, "chat_id not specified" end
  if not message_id then return nil, "message_id not specified" end
  if not inline_message_id then return nil, "inline_message_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(chat_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageReplyMarkup",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end


function M.answerInlineQuery(inline_query_id, results, cache_time, is_personal, next_offset)

  if not inline_query_id then return nil, "inline_query_id not specified" end
  if not results then return nil, "results not specified" end

  local request_body = {}

  request_body.inline_query_id = tostring(inline_query_id)
  request_body.results = JSON:encode(results)
  request_body.cache_time = tonumber(cache_time)
  request_body.is_personal = tostring(is_personal)
  request_body.next_offset = tostring(next_offset)

  local response = makeRequest("answerInlineQuery",request_body)

  if (response.success == 1) then
    return JSON:decode(response.body)
  else
    return nil, "Request Error"
  end
end
return M

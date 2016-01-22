# lua-telegram-bot
A simple LUA Framework for the [Telegram Bot API](https://https://core.telegram.org/bots/api)


## Installing

To install this module, place it inside the same folder your bot is located.

This modules requires [luasec](https://github.com/brunoos/luasec) to work.
You can easily install it with luarocks using `luarocks install luasec`.


You will also need a Module for JSON en- and decoding, which can be found [here](http://regex.info/code/JSON.lua).
Simply place it in the `lua-telegram-bot` Folder.

## Using

To use this module, import it into your bot like this:
```lua
local bot = (require "lua-bot-api").configure(token)
```
Include your bot token as parameter for `configure()`.

The `bot` Table exports variables and functions which return the following return values:

### Return values

All functions return a table as received from the server if called successfully as their first return value.
This does *not* mean the request was successful, for example in case of a bad `offset` in `getUpdates()`.

A function returns `nil` and an `error description` if it was wrongly called (missing parameters).

### Variables

```lua
id
```
```lua
username
```
```lua
first_name
```

### Functions

```lua
getMe()
```
```lua
getUpdates([offset] [,limit] [,timeout])
```
```lua
sendMessage(chat_id, text [,parse_mode] [,disable_web_page_preview] [,reply_to_message_id] [,reply_markup])
```
```lua
forwardMessage(chat_id, from_chat_id, message_id)
```
```lua
sendPhoto(chat_id, photo, caption [,reply_to_message_id] [,reply_markup])
```
```lua
sendAudio(chat_id, audio, duration [,performer] [,title] [,reply_to_message_id] [,reply_markup])
```
```lua
sendDocument(chat_id, document [,reply_to_message_id] [,reply_markup])
```
```lua
sendSticker(chat_id, sticker [,reply_to_message_id] [,reply_markup])
```
```lua
sendVideo(chat_id, video [,duration] [,caption] [,reply_to_message_id] [,reply_markup])
```
```lua
sendVoice(chat_id, voice [,duration] [,reply_to_message_id] [,reply_markup])
```
```lua
sendLocation(chat_id, latitude, longitude [,reply_to_message_id] [,reply_markup])
```
```lua
sendChatAction(chat_id, action)
```
```lua
getUserProfilePhotos(user_id [,offset] [,limit])
```
```lua
getFile(file_id)
```

```lua
answerInlineQuery(inline_query_id, results [,cache_time] [,is_personal] [,next_offset])
```
### Helper functions:

```lua
downloadFile(file_id [,download_path])
```
- Downloads file from Telegram Servers.
- `download_path` is an optional path where the file can be saved. If not specified, it will be saved in `/downloads/<filenameByTelegram>`. In both cases make sure the path already exists, since LUA can not create folders without additional modules.

```lua
generateReplyKeyboardMarkup(keyboard [,resize_keyboard] [,one_time_keyboard] [,selective])
```
- Generates a `ReplyKeyboardMarkup` of type `reply_markup` which can be sent optionally in other functions such as `sendMessage()`.
- Displays the custom `keyboard` on the receivers device.

```lua
generateReplyKeyboardHide([hide_keyboard] [,selective])
```
- Generates a `ReplyKeyboardHide` of type `reply_markup` which can be sent optionally in other functions such as `sendMessage()`.
- Forces to hide the custom `keyboard` on the receivers device.
- `hide_keyboard` can be left out, as it is always `true`.

```lua
generateForceReply([force_reply] [,selective])
```
- Generates a `ForcReply` of type `reply_markup` which can be sent optionally in other functions such as `sendMessage()`.
- Forces to reply to the corresponding message from the receivers device.
- `force_reply` can be left out, as it is always `true`.

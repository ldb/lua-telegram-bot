# lua-telegram-bot
A simple LUA Framework for the [Telegram Bot API](https://https://core.telegram.org/bots/api)


## Installation

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

The `bot` Table exports following variables and functions:

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
getUpdates(offset, limit timeout)
```
```lua
sendMessage(chat_id, text, parse_mode, disable_web_page_preview, reply_to_message_id, reply_markup)
```
```lua
forwardMessage(chat_id, from_chat_id, message_id)
```
```lua
sendPhoto(chat_id, photo, caption, reply_to_message_id, reply_markup)
```
```lua
sendAudio(chat_id, audio, duration, performer, title, reply_to_message_id, reply_markup)
```
```lua
sendDocument(chat_id, document, reply_to_message_id, reply_markup)
```
```lua
sendSticker(chat_id, sticker, reply_to_message_id, reply_markup)
```
```lua
sendVideo(chat_id, video, duration, caption, reply_to_message_id, reply_markup)
```
```lua
sendVoice(chat_id, voice, duration, reply_to_message_id, reply_markup)
```
```lua
sendLocation(chat_id, latitude, longitude, reply_to_message_id, reply_markup)
```
```lua
sendChatAction(chat_id, action)
```
```lua
getUserProfilePhotos(user_id, offset, limit)
```
```lua
getFile(file_id)
```
### Helper functions:

```lua
downloadFile(file_id, download_path)
<<<<<<< HEAD
```
- Downloads file from Telegram Servers.
- `download_path` is an optional path where the file can be saved. If not specified, it will be saved in `/downloads/<filenameByTelegram>`. In both cases make sure the path already exists, since LUA can not create folders without additional modules.
=======
```
>>>>>>> origin/master

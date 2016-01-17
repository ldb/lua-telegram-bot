# luatgbot
A simple LUA Framework for the [Telegram Bot API](https://https://core.telegram.org/bots/api)


## Installation

To install this module, place it inside the same folder your bot is located.

This modules requires [luasec](https://github.com/brunoos/luasec) to work.
You can easily install it with luarocks using `luarocks install luasec`.


You will also need a Module for JSON en- and decoding, which can be found [here](http://regex.info/code/JSON.lua).
Simply place it in the `luatgbot` Folder.

## Using

To use this module, import it into your bot like this:
```lua
local bot = (require "lua-bot-api").configure(token)
```
Include your bot token as parameter for `configure()`.

The `bot` Table exports following variables and functions:

### Variables

- id
- username
- first_name

### Functions

```lua
- getMe()
- getUpdates(offset, limit timeout)
- sendMessage(chat_id, text, parse_mode, disable_web_page_preview, reply_to_message_id, reply_markup)
- forwardMessage(chat_id, from_chat_id, message_id)
- sendPhoto (chat_id, photo, caption, reply_to_message_id, reply_markup)
- sendAudio (chat_id, audio, duration, performer, title, reply_to_message_id, reply_markup)
- sendDocument (chat_id, document, reply_to_message_id, reply_markup)
- sendSticker (chat_id, sticker, reply_to_message_id, reply_markup)
- sendVideo (chat_id, video, duration, caption, reply_to_message_id, reply_markup)
- sendVoice (chat_id, voice, duration, reply_to_message_id, reply_markup)
- sendLocation(chat_id, latitude, longitude, reply_to_message_id, reply_markup)
- sendChatAction (chat_id, action)
- getUserProfilePhotos (user_id, offset, limit)
- getFile (file_id)
```
### Helper functions:

```lua
function downloadFile(file_id, download_path)
```

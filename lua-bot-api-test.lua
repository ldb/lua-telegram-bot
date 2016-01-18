-- set bot token here!
local token = ""

-- create and configure new bot with set token
local bot = require("lua-bot-api").configure(token)

-- get table of updates
local updates = bot.getUpdates()

-- for each update, check wether message is 'ping' and reply accordingly
for key, value in ipairs(updates.result) do
  if value.message.text == "ping" then
    bot.sendMessage(value.message.from.id, "pong")
  end
end

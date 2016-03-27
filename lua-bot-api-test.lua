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

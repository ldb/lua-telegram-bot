local E ={}

local message_types = {
    text  =       "onTextReceive",
    photo  =       "onPhotoReceive",
    audio  =       "onAudioReceive",
    document  =       "onDocumentReceive",
    sticker  =       "onStickerReceive",
    video  =       "onVideoReceive",
    voice  =       "onVoiceReceive",
    contact  =       "onContactReceive",
    location  =       "onLocationReceive",
    left_chat_participant  =       "onLeftChatParticipant",
    new_chat_participant  =       "onNewChatParticipant",
    new_chat_photo  =       "onNewChatPhoto",
    delete_chat_photo  =       "onDeleteChatPhoto",
    group_chat_created  =       "onGroupChatCreated",
    supergroup_chat_created  =       "onSupergroupChatCreated",
    channel_chat_created  =       "onChannelChatCreated",
    migrate_to_chat_id  =       "onMigrateToChatId",
    migrate_from_chat_id  =       "onMigrateFromChatId"
}
local function parseUpdateCallbacks(update)
  local known = false
  if (update) then
    E.onUpdateReceive(update)
  end
  if (update.message) then
    for k,v in pairs(message_types) do
        if update.message[k]then
            if E[v] then
                E[v](update.message)
            end
            known = true
        end
    end
  elseif (update.inline_query) then
    E.onInlineQueryReceive(update.inline_query)
    known = true
  elseif (update.chosen_inline_result) then
    E.onChosenInlineQueryReceive(update.chosen_inline_result)
    known = true
  end
    if not known then
      E.onUnknownTypeReceive(update)
    end
end

function E.run(limit, timeout,update_func)
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

return E

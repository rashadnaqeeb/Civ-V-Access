-- Multiplayer chat ingestion. Subscribes to Events.GameMessageChat from
-- the WorldView Context (Boot's env) so the listener survives load-game-
-- from-game without depending on DiploCorner's child-Context re-init
-- behavior. Three downstream effects per incoming message:
--   1) civvaccess_shared._inGameChatLog (capped) -- backing store for
--      ChatAccess's Messages tab.
--   2) MessageBuffer.append(formatted, "chat") -- the user's [ / ] review
--      surface, where chat shares the cycle with notifications / reveal /
--      combat.
--   3) SpeechPipeline.speakQueued -- in-the-moment announcement, queued
--      (not interrupting) so chat doesn't cut off other speech. Suppressed
--      while ChatAccess's Compose panel is up so the user isn't double-
--      announced what they're already focused on.
--
-- No install-once guard, mirroring the rest of the in-game listener
-- surface: Civ V kills WorldView's env on load-from-game and a flag-
-- gated registration would lock the mod to the dead listener forever.
-- Boot.lua re-includes this module on every onInGameBoot.

ChatBuffer = {}

local CHAT_LOG_CAP = 100

local function appendLog(entry)
    local log = civvaccess_shared._inGameChatLog or {}
    log[#log + 1] = entry
    while #log > CHAT_LOG_CAP do
        table.remove(log, 1)
    end
    civvaccess_shared._inGameChatLog = log
end

local function chatPanelActive()
    return civvaccess_shared.chatPanelActive == true
end

-- Steam nickname when set, else the player's leader / civilization name
-- via Player:GetName (always populated for an active slot). Player slot
-- nil isn't guarded -- the engine doesn't fire GameMessageChat for an
-- invalid sender, so a nil here is a real bug we want to surface via
-- onChat's pcall rather than silently rebrand as "unknown player".
local function resolveNick(playerID)
    local p = Players[playerID]
    local nick = p:GetNickName()
    if nick ~= nil and nick ~= "" then
        return nick
    end
    return p:GetName()
end

local function formatLine(fromPlayer, toPlayer, text, eTargetType)
    local fromName = resolveNick(fromPlayer)
    if eTargetType == ChatTargetTypes.CHATTARGET_TEAM then
        return Text.format("TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM", fromName, text)
    elseif eTargetType == ChatTargetTypes.CHATTARGET_PLAYER then
        local localID = Game.GetActivePlayer()
        local toName
        if toPlayer == localID then
            toName = Text.key("TXT_KEY_YOU")
        else
            toName = resolveNick(toPlayer)
        end
        return Text.format("TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER", fromName, toName, text)
    end
    return Text.format("TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG", fromName, text)
end

local function onChat(fromPlayer, toPlayer, text, eTargetType)
    if text == nil or text == "" then
        return
    end
    local line = formatLine(fromPlayer, toPlayer, text, eTargetType)
    appendLog({
        fromPlayer = fromPlayer,
        toPlayer = toPlayer,
        text = text,
        targetType = eTargetType,
        line = line,
    })
    MessageBuffer.append(line, "chat")
    if not chatPanelActive() then
        SpeechPipeline.speakQueued(line)
    end
end

-- Test seam.
ChatBuffer._onChat = onChat

function ChatBuffer.installListeners()
    civvaccess_shared._inGameChatLog = {}
    if Events ~= nil and Events.GameMessageChat ~= nil then
        Events.GameMessageChat.Add(onChat)
    else
        Log.warn("ChatBuffer: Events.GameMessageChat missing; chat receive will not fire")
    end
end

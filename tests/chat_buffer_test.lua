-- ChatBuffer: multiplayer chat ingestion. Tests the per-message fan-out
-- (history log + message buffer + speech) and the compose-panel speech
-- suppression. Listener-install de-duplication lives upstream in Boot's
-- generation guard, not here, so installListeners stays a plain register.

local T = require("support")
local M = {}

local spoken
local chatListeners

local function setup()
    spoken = {}
    chatListeners = {}
    civvaccess_shared = {}

    -- Capture every GameMessageChat registration so the idempotency tests can
    -- count how many listeners installListeners actually wired up.
    Events = {
        GameMessageChat = {
            Add = function(fn)
                chatListeners[#chatListeners + 1] = fn
            end,
        },
    }

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end

    Players = {
        [1] = {
            GetNickName = function()
                return "Alice"
            end,
            GetName = function()
                return "Alice the Great"
            end,
        },
    }

    Text = Text or {}
    Text.key = function(k)
        if k == "TXT_KEY_YOU" then
            return "You"
        end
        return k
    end
    Text.format = function(k, a, b, c)
        if k == "TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG" then
            return a .. ": " .. b
        elseif k == "TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM" then
            return a .. " (team): " .. b
        elseif k == "TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER" then
            return a .. " to " .. b .. ": " .. c
        end
        return k
    end

    SpeechPipeline = {
        speakQueued = function(t)
            spoken[#spoken + 1] = t
        end,
    }

    -- Real MessageBuffer so the "chat" category routing is exercised, not a
    -- stub that could drift from production.
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ChatBuffer.lua")
end

-- One message lands in all three surfaces: the history log, the bracket
-- buffer (chat category), and speech.
function M.test_fans_out_to_log_buffer_and_speech()
    setup()
    ChatBuffer.installListeners()
    ChatBuffer._onChat(1, -1, "hello", ChatTargetTypes.CHATTARGET_ALL)
    T.eq(#civvaccess_shared._inGameChatLog, 1, "history logged")
    T.eq(civvaccess_shared._inGameChatLog[1].line, "Alice: hello")
    local s = MessageBuffer._snapshot()
    T.eq(#s.entries, 1, "buffered once")
    T.eq(s.entries[1].text, "Alice: hello")
    T.eq(s.entries[1].category, "chat")
    T.eq(#spoken, 1, "spoken once")
    T.eq(spoken[1], "Alice: hello")
end

-- With the compose panel up, speech backs off (the user is focused there)
-- but the history and buffer still record the message.
function M.test_compose_panel_suppresses_speech_only()
    setup()
    civvaccess_shared.chatPanelActive = true
    ChatBuffer.installListeners()
    ChatBuffer._onChat(1, -1, "hi", ChatTargetTypes.CHATTARGET_ALL)
    T.eq(#spoken, 0, "speech suppressed while compose panel is active")
    T.eq(#MessageBuffer._snapshot().entries, 1, "still buffered")
    T.eq(#civvaccess_shared._inGameChatLog, 1, "still logged")
end

return M

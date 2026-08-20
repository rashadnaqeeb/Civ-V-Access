-- LekModChat: classification of the protocols LekMod carries over
-- Network.SendChat. Our chat listeners subscribe to Events.GameMessageChat,
-- which is upstream of LekMod's own filtering, so anything this misses gets
-- read out as if a player had typed it. The draft broadcasts on every ban
-- change, so a miss is not a one-off -- it floods.
--
-- The ChatBuffer cases exercise the real in-game listener rather than
-- re-asserting classify(): what matters there is that a dropped packet
-- reaches neither speech nor the bracket buffer, and that an announcement
-- LekMod makes goes out as itself with nobody attributed to it.

local T = require("support")
local M = {}

local spoken

local function setup()
    spoken = {}
    civvaccess_shared = {}
    LekmodVersion = nil

    Events = {
        GameMessageChat = {
            Add = function() end,
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
        return k
    end
    Text.format = function(k, a, b)
        if k == "TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG" then
            return a .. ": " .. b
        end
        return k
    end

    SpeechPipeline = {
        speakQueued = function(t)
            spoken[#spoken + 1] = t
        end,
    }

    dofile("src/dlc/UI/Shared/CivVAccess_LekModChat.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ChatBuffer.lua")
end

-- Anything a player actually typed classifies as ordinary chat, including
-- text that merely mentions a prefix rather than starting with one.
function M.test_player_chat_is_not_classified()
    setup()
    T.eq(LekModChat.classify("hello"), nil)
    T.eq(LekModChat.classify("what does #LDRAFT# mean"), nil)
    T.eq(LekModChat.classify(""), nil, "empty text is not a protocol message")
end

-- The draft state sync: one of these goes out on every ban any player sets.
function M.test_draft_protocol_is_dropped()
    setup()
    T.eq(LekModChat.classify("#LDRAFT#BAN|3|-1,42").kind, "drop")
    T.eq(LekModChat.classify("#LDRAFT#LOCK|1").kind, "drop")
end

function M.test_version_handshake_is_dropped()
    setup()
    T.eq(LekModChat.classify("#LEKVER#v35.006").kind, "drop")
end

-- LekMod publishes every protocol prefix on its own global; when it is loaded
-- those win, so a change upstream cannot quietly bring the spam back.
function M.test_prefixes_follow_lekmod_when_published()
    setup()
    LekmodVersion = {
        LOBBY_CHAT_REQ = "#LCHREQ2#",
        LOBBY_CHAT_CLEAR = "#LCHCLEAR2#",
        LOBBY_CHAT_PREFIX = "#LCH2#",
        DRAFT_PREFIX = "#LDRAFT2#",
        OLD_HANDSHAKE_PREFIX = "#LEKVER2#",
        GAME_CHAT_PREFIX = "#LGAME2#",
    }
    T.eq(LekModChat.classify("#LCHREQ2#").kind, "drop")
    T.eq(LekModChat.classify("#LCHCLEAR2#").kind, "clear")
    T.eq(LekModChat.classify("#LDRAFT2#BAN|3|-1").kind, "drop")
    T.eq(LekModChat.classify("#LEKVER2#v36").kind, "drop")
    local system = LekModChat.classify("#LGAME2#Draft created.")
    T.eq(system.kind, "system")
    T.eq(system.text, "Draft created.")
    local history = LekModChat.classify("#LCH2#1|Alice|hello")
    T.eq(history.kind, "history")
    T.eq(history.text, "hello")
end

-- LekMod's own announcements (kick notices, the draft's lifecycle lines) are
-- the one protocol with something to say to the player.
function M.test_system_announcement_carries_its_body()
    setup()
    local result = LekModChat.classify("#LGAME#Draft created.")
    T.eq(result.kind, "system")
    T.eq(result.text, "Draft created.")
end

-- Chat-history replay to a joining client: the host sends a clear, then one
-- packet per remembered line. Both are machinery, but the history lines carry
-- real chat that belongs in the log.
function M.test_history_replay_decodes_sender_and_text()
    setup()
    T.eq(LekModChat.classify("#LCHREQ#").kind, "drop")
    T.eq(LekModChat.classify("#LCHCLEAR#").kind, "clear")
    local entry = LekModChat.classify("#LCH#3|Alice|hello there")
    T.eq(entry.kind, "history")
    T.eq(entry.fromPlayer, 3)
    T.eq(entry.name, "Alice")
    T.eq(entry.text, "hello there")
end

-- A history line may itself contain the separator; only the first two split
-- the fields, so the message survives intact.
function M.test_history_text_keeps_later_separators()
    setup()
    T.eq(LekModChat.classify("#LCH#3|Alice|a|b").text, "a|b")
end

function M.test_malformed_history_is_dropped_not_spoken()
    setup()
    T.eq(LekModChat.classify("#LCH#garbage").kind, "drop")
end

-- In game, a dropped packet must reach nothing: not speech, not the bracket
-- buffer the player reviews with [ and ], and not the chat panel's log.
function M.test_ingame_protocol_reaches_no_surface()
    setup()
    ChatBuffer.installListeners()
    -- One real message first, so the assertions below distinguish "not
    -- appended" from "nothing has been appended yet".
    ChatBuffer._onChat(1, -1, "hello", ChatTargetTypes.CHATTARGET_ALL)
    ChatBuffer._onChat(1, -1, "#LDRAFT#BAN|3|42", ChatTargetTypes.CHATTARGET_ALL)
    T.eq(#spoken, 1, "protocol not spoken")
    T.eq(#MessageBuffer._snapshot().entries, 1, "protocol not buffered")
    T.eq(#civvaccess_shared._inGameChatLog, 1, "protocol not logged")
end

-- An announcement is not from the player who happened to broadcast it, so it
-- goes out as itself rather than "Alice: <notice>".
function M.test_ingame_system_line_is_unattributed()
    setup()
    ChatBuffer.installListeners()
    ChatBuffer._onChat(1, -1, "#LGAME#Player was kicked", ChatTargetTypes.CHATTARGET_ALL)
    T.eq(#spoken, 1)
    T.eq(spoken[1], "Player was kicked")
    T.eq(MessageBuffer._snapshot().entries[1].text, "Player was kicked")
end

-- Ordinary chat is untouched by the classification pass.
function M.test_ingame_player_chat_still_announces()
    setup()
    ChatBuffer.installListeners()
    ChatBuffer._onChat(1, -1, "hello", ChatTargetTypes.CHATTARGET_ALL)
    T.eq(spoken[1], "Alice: hello")
end

return M

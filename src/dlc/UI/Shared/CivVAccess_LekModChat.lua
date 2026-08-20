-- LekMod chat-protocol classification.
--
-- LekMod carries several of its own protocols over Network.SendChat, and its
-- own OnChat handlers filter every one of them out before anything reaches the
-- visible chat box: the civ-draft state sync, the multiplayer version
-- handshake, the lobby chat-history replay a joiner receives, and its "Game:"
-- system announcements (kick notices, ui_check warnings, and the draft's own
-- lifecycle lines). Our chat listeners subscribe to Events.GameMessageChat
-- directly, which is upstream of all that filtering, so without this module a
-- blind player hears raw packets read out ("hash L DRAFT hash BAN pipe 3 pipe
-- minus 1") on every ban any player edits.
--
-- classify() is the single place that knows the prefixes. It is inert off
-- LekMod by construction: no other engine ever sends a message carrying one of
-- these prefixes, so vanilla and VP always fall through to the ordinary-chat
-- return.
--
-- Prefixes are LekMod's, from Lekmod_version.lua (handshake / system) and the
-- file-local constants in StagingRoom.lua and Lekmod_staging_draft.lua (the
-- lobby-history and draft protocols). The two exposed as fields on LekMod's
-- LekmodVersion global are read from there when it is loaded, so a change
-- upstream cannot silently reintroduce the spam; the rest are pinned here and
-- re-checked on a re-pin.

LekModChat = {}

local DRAFT_PREFIX = "#LDRAFT#"
local HANDSHAKE_PREFIX = "#LEKVER#"
local SYSTEM_PREFIX = "#LGAME#"
local HISTORY_PREFIX = "#LCH#"
local HISTORY_REQUEST = "#LCHREQ#"
local HISTORY_CLEAR = "#LCHCLEAR#"

-- LekMod's own value wins where it publishes one; the constant is the
-- fallback for Contexts that never loaded Lekmod_version.lua and for the
-- offline suite.
local function prefix(field, fallback)
    if type(LekmodVersion) == "table" and type(LekmodVersion[field]) == "string" then
        return LekmodVersion[field]
    end
    return fallback
end

local function startsWith(text, pre)
    return string.sub(text, 1, #pre) == pre
end

-- Split a lobby chat-history packet: "#LCH#<fromPlayer>|<name>|<text>".
-- LekMod replaces any "|" in the name before encoding, so the first two
-- separators are always the field boundaries.
local function decodeHistory(body)
    local sep1 = string.find(body, "|", 1, true)
    if sep1 == nil then
        return nil
    end
    local sep2 = string.find(body, "|", sep1 + 1, true)
    if sep2 == nil then
        return nil
    end
    local fromPlayer = tonumber(string.sub(body, 1, sep1 - 1))
    if fromPlayer == nil then
        return nil
    end
    return {
        kind = "history",
        fromPlayer = fromPlayer,
        name = string.sub(body, sep1 + 1, sep2 - 1),
        text = string.sub(body, sep2 + 1),
    }
end

-- Classify one incoming chat message. Returns nil for ordinary player chat
-- (the caller announces it as usual), otherwise a table whose `kind` is:
--   "drop"     LekMod machinery with nothing for the player: the draft state
--              sync, the version handshake, a history request. Discard.
--   "clear"    the host telling a joining client to wipe its chat history
--              before the replay arrives. Discard the message and drop any
--              log the caller keeps.
--   "history"  one replayed history line, carrying `fromPlayer`, `name` and
--              `text`. Log it, do not speak it: these arrive as a burst of up
--              to a hundred old lines the moment a player joins.
--   "system"   a LekMod announcement, body in `text`. Speak and log it as an
--              unattributed line -- the sending playerID is whichever client
--              broadcast it (usually the host), not its author.
function LekModChat.classify(text)
    if type(text) ~= "string" or text == "" then
        return nil
    end
    if text == HISTORY_REQUEST then
        return { kind = "drop" }
    end
    if text == HISTORY_CLEAR then
        return { kind = "clear" }
    end
    if startsWith(text, DRAFT_PREFIX) then
        return { kind = "drop" }
    end
    local handshake = prefix("HANDSHAKE_PREFIX", HANDSHAKE_PREFIX)
    if startsWith(text, handshake) then
        return { kind = "drop" }
    end
    local system = prefix("GAME_CHAT_PREFIX", SYSTEM_PREFIX)
    if startsWith(text, system) then
        return { kind = "system", text = string.sub(text, #system + 1) }
    end
    if startsWith(text, HISTORY_PREFIX) then
        local entry = decodeHistory(string.sub(text, #HISTORY_PREFIX + 1))
        if entry ~= nil then
            return entry
        end
        -- A malformed history packet is still machinery, not chat.
        Log.warn("LekModChat: undecodable history packet, dropping")
        return { kind = "drop" }
    end
    return nil
end

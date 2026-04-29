-- Session-scoped scrollable history of speech-worthy events. Producers
-- (NotificationAnnounce, RevealAnnounce, ForeignUnitWatch, UnitControl
-- combat hooks) call MessageBuffer.append at the same callsite they hand
-- text to the speech pipeline; the user navigates the buffer with [ / ]
-- (with shift / ctrl modifiers) to review what's been spoken across the
-- session.
--
-- Append is opt-in per producer: cursor reads, scanner navigation, UI
-- chatter all flow through SpeechPipeline too, but they don't belong in
-- the buffer (the user invoked them directly and won't want to scroll
-- back to them). New producers must explicitly add an append() call to
-- show up in the buffer.
--
-- State lives on civvaccess_shared so cross-Context producers (chat in
-- multiplayer, eventually) can call append without re-including this
-- module's globals. Reset on every onInGameBoot: load-game-from-game
-- would otherwise carry entries from a different game (different units,
-- different turns, no relation to the current map state). Cap evictions
-- shift position by one so the cursor tracks the same logical entry; an
-- evicted-out-of-band cursor clamps to the new oldest rather than
-- becoming "uninitialized" which would feel like losing your place.

MessageBuffer = {}

-- Buffer ceiling. Sized for a long Marathon game (500+ turns, 10-20
-- producer events per late-game turn) without unbounded growth. Each
-- entry is a short text + small category string, so 5000 ~ a few hundred
-- KB of Lua-side memory. Bumpable if real sessions outgrow it. Test
-- seam (_setCap) overrides for cap-eviction tests that don't want to
-- allocate 5000 entries to exercise the eviction branch.
local _cap = 5000

-- Cycle order for Shift+[ / Shift+]. "all" first so the default state
-- after reset matches the cycle's home position. New categories slot in
-- before "all" rolls over (chat will go between combat and all when MP
-- chat is wired up).
local FILTER_CYCLE = { "all", "notification", "reveal", "combat" }

-- Categories must stay in lockstep with FILTER_CYCLE: an entry that
-- passes append's category guard but has no slot in the cycle is
-- silently unreachable except through "all". When MP chat is wired up,
-- add "chat" to both this set and FILTER_CYCLE in the same change.
local CATEGORIES = {
    notification = true,
    reveal = true,
    combat = true,
}

local function state()
    local s = civvaccess_shared.messageBuffer
    if s == nil then
        s = { entries = {}, filter = "all", position = 0 }
        civvaccess_shared.messageBuffer = s
    end
    return s
end

local function matches(entry, filter)
    if filter == "all" then
        return true
    end
    return entry.category == filter
end

-- Walk from fromIdx in the given direction until a matching entry is
-- found. Returns the index, or nil if the walk falls off the end. Caller
-- handles the edge announcement.
local function walk(entries, filter, fromIdx, direction)
    local i = fromIdx + direction
    while i >= 1 and i <= #entries do
        if matches(entries[i], filter) then
            return i
        end
        i = i + direction
    end
    return nil
end

local function newestMatching(entries, filter)
    return walk(entries, filter, #entries + 1, -1)
end

local function oldestMatching(entries, filter)
    return walk(entries, filter, 0, 1)
end

local function speakText(text)
    SpeechPipeline.speakInterrupt(text)
end

local function speakKey(key)
    SpeechPipeline.speakInterrupt(Text.key(key))
end

-- Filter announce form: "<filter name>, <newest entry text>" or
-- "<filter name>, <empty marker>". Single speakInterrupt so a fast
-- Shift-cycle through filters cuts the prior announcement cleanly
-- instead of stacking queued entries.
local function speakFilterChange(filter, entry)
    local filterName = Text.key("TXT_KEY_CIVVACCESS_MSGBUF_FILTER_" .. filter:upper())
    local tail
    if entry == nil then
        tail = Text.key("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
    else
        tail = entry.text
    end
    SpeechPipeline.speakInterrupt(filterName .. ", " .. tail)
end

function MessageBuffer.append(text, category)
    if text == nil or text == "" then
        return
    end
    if not CATEGORIES[category] then
        Log.warn("MessageBuffer.append: unknown category " .. tostring(category))
        return
    end
    local s = state()
    s.entries[#s.entries + 1] = { text = text, category = category }
    if #s.entries > _cap then
        table.remove(s.entries, 1)
        -- Cap evicted the oldest. If the user's cursor was on a still-
        -- valid entry, decrement so it tracks the same logical message.
        -- If they were on the just-evicted entry, clamp to the new
        -- oldest rather than dropping back to position 0 ("uninitialized")
        -- which would feel like losing their place mid-scrollback.
        if s.position > 0 then
            s.position = math.max(1, s.position - 1)
        end
    end
end

function MessageBuffer.next()
    local s = state()
    -- Position 0 is "uninitialized / past newest" so ] from there is
    -- already at the forward edge. The user has to press [ first to
    -- enter the buffer (lands on newest matching) and then can scroll
    -- both ways from there. Empty buffer / empty filter is distinct
    -- from "at the newest edge with content behind you" -- mirror
    -- prev's branch so the user hears the right marker either way.
    if s.position == 0 then
        if newestMatching(s.entries, s.filter) == nil then
            speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
        else
            speakKey("TXT_KEY_CIVVACCESS_MSGBUF_NEWEST")
        end
        return
    end
    local idx = walk(s.entries, s.filter, s.position, 1)
    if idx == nil then
        speakKey("TXT_KEY_CIVVACCESS_MSGBUF_NEWEST")
        return
    end
    s.position = idx
    speakText(s.entries[idx].text)
end

function MessageBuffer.prev()
    local s = state()
    local idx
    if s.position == 0 then
        idx = newestMatching(s.entries, s.filter)
    else
        idx = walk(s.entries, s.filter, s.position, -1)
    end
    if idx == nil then
        if s.position == 0 then
            -- Empty buffer or no entries match the active filter.
            -- Distinct from the oldest-edge case where there were
            -- matches but the user has walked past them all.
            speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
        else
            speakKey("TXT_KEY_CIVVACCESS_MSGBUF_OLDEST")
        end
        return
    end
    s.position = idx
    speakText(s.entries[idx].text)
end

function MessageBuffer.jumpFirst()
    local s = state()
    local idx = oldestMatching(s.entries, s.filter)
    if idx == nil then
        speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
        return
    end
    s.position = idx
    speakText(s.entries[idx].text)
end

function MessageBuffer.jumpLast()
    local s = state()
    local idx = newestMatching(s.entries, s.filter)
    if idx == nil then
        speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
        return
    end
    s.position = idx
    speakText(s.entries[idx].text)
end

local function rotate(filter, direction)
    local n = #FILTER_CYCLE
    for i, f in ipairs(FILTER_CYCLE) do
        if f == filter then
            local nxt = i + direction
            if nxt < 1 then
                nxt = n
            elseif nxt > n then
                nxt = 1
            end
            return FILTER_CYCLE[nxt]
        end
    end
    return FILTER_CYCLE[1]
end

local function applyFilter(s, direction)
    s.filter = rotate(s.filter, direction)
    local idx = newestMatching(s.entries, s.filter)
    s.position = idx or 0
    speakFilterChange(s.filter, idx and s.entries[idx] or nil)
end

function MessageBuffer.cycleFilterForward()
    applyFilter(state(), 1)
end

function MessageBuffer.cycleFilterBackward()
    applyFilter(state(), -1)
end

function MessageBuffer._reset()
    civvaccess_shared.messageBuffer = nil
end

-- Called from onInGameBoot. Wipes the buffer on every game load so
-- entries from a prior game don't bleed into the current session.
function MessageBuffer.installListeners()
    MessageBuffer._reset()
end

-- Test seam. Production callers should not touch these.
function MessageBuffer._setCap(n)
    _cap = n
end

function MessageBuffer._snapshot()
    return civvaccess_shared.messageBuffer
end

local VK_OEM_4 = 219 -- [
local VK_OEM_6 = 221 -- ]

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_CTRL = 2

local bind = HandlerStack.bind

-- Pulled into BaselineHandler.create's binding list, same as UnitControl /
-- Turn / etc. Lives at the bottom of the stack so any popup or overlay
-- above it pre-empts the bracket keys (a popup that wants [ / ] for its
-- own purpose can bind them and our bindings stay dormant).
function MessageBuffer.getBindings()
    local bindings = {
        bind(VK_OEM_4, MOD_NONE, MessageBuffer.prev, "Previous message in buffer"),
        bind(VK_OEM_6, MOD_NONE, MessageBuffer.next, "Next message in buffer"),
        bind(VK_OEM_4, MOD_CTRL, MessageBuffer.jumpFirst, "Oldest message in buffer"),
        bind(VK_OEM_6, MOD_CTRL, MessageBuffer.jumpLast, "Newest message in buffer"),
        bind(VK_OEM_4, MOD_SHIFT, MessageBuffer.cycleFilterBackward, "Cycle buffer filter backward"),
        bind(VK_OEM_6, MOD_SHIFT, MessageBuffer.cycleFilterForward, "Cycle buffer filter forward"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV",
            description = "TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE",
            description = "TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER",
            description = "TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

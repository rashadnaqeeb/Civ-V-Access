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
-- different turns, no relation to the current map state). Each append
-- resets the cursor to "uninitialized" so the next [ / ] lands on the
-- newly-arrived message instead of stranding the user mid-scrollback
-- when there is something new to hear.

MessageBuffer = {}

-- Buffer ceiling. Sized for a long Marathon game (500+ turns, 10-20
-- producer events per late-game turn) without unbounded growth. Each
-- entry is a short text + small category string, so 5000 ~ a few hundred
-- KB of Lua-side memory. Bumpable if real sessions outgrow it. Test
-- seam (_setCap) overrides for cap-eviction tests that don't want to
-- allocate 5000 entries to exercise the eviction branch.
local _cap = 5000

-- Cycle order for Shift+[ / Shift+]. "all" first so the default state
-- after reset matches the cycle's home position. Empty categories are
-- skipped at cycle time so the user never lands on a filter view with
-- nothing in it -- the cycle order is what to consider, not what to
-- visit unconditionally.
local FILTER_CYCLE = { "all", "notification", "reveal", "combat", "chat" }

-- Categories must stay in lockstep with FILTER_CYCLE: an entry that
-- passes append's category guard but has no slot in the cycle is
-- silently unreachable except through "all".
local CATEGORIES = {
    notification = true,
    reveal = true,
    combat = true,
    chat = true,
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
-- found. Returns the index, or nil if the walk falls off the end.
-- Callers re-speak the current entry on nil.
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

-- Filter announce form: "<filter name>, <newest entry text>". Single
-- speakInterrupt so a fast Shift-cycle through filters cuts the prior
-- announcement cleanly instead of stacking queued entries. Filter cycle
-- skips empty categories, so the entry argument is always non-nil here.
local function speakFilterChange(filter, entry)
    local filterName = Text.key("TXT_KEY_CIVVACCESS_MSGBUF_FILTER_" .. filter:upper())
    SpeechPipeline.speakInterrupt(filterName .. ", " .. entry.text)
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
    end
    -- Reset to uninitialized so the next bracket press enters at the
    -- newest matching entry. A new message means there is something new
    -- to hear; the user shouldn't have to scroll forward from a stale
    -- mid-buffer position to reach it.
    s.position = 0
end

-- Walking off either end re-speaks the current entry rather than
-- announcing an "edge" marker. The bracket key still feels responsive
-- (something speaks) and the user gets the actual content again, which
-- doubles as the "you tried to go further but couldn't" feedback.
function MessageBuffer.next()
    local s = state()
    if s.position == 0 then
        -- Uninitialized: pressing either bracket from a fresh state
        -- enters the buffer at the newest matching entry. Empty buffer
        -- (or empty filter) speaks the no-messages marker.
        local idx = newestMatching(s.entries, s.filter)
        if idx == nil then
            speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
            return
        end
        s.position = idx
        speakText(s.entries[idx].text)
        return
    end
    local idx = walk(s.entries, s.filter, s.position, 1)
    if idx == nil then
        speakText(s.entries[s.position].text)
        return
    end
    s.position = idx
    speakText(s.entries[idx].text)
end

function MessageBuffer.prev()
    local s = state()
    if s.position == 0 then
        local idx = newestMatching(s.entries, s.filter)
        if idx == nil then
            speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
            return
        end
        s.position = idx
        speakText(s.entries[idx].text)
        return
    end
    local idx = walk(s.entries, s.filter, s.position, -1)
    if idx == nil then
        speakText(s.entries[s.position].text)
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

-- Walk the filter cycle from the current filter in the given direction
-- until a filter with at least one matching entry is found. Returns the
-- filter name plus the index of its newest matching entry, or nil if no
-- filter has entries (which means the buffer is fully empty -- "all"
-- matches every entry, so any non-empty buffer is reachable through it).
-- Walks a full lap of n steps so the fully-empty case exhausts every
-- slot before returning nil to applyFilter as the empty-buffer signal.
local function rotateNonEmpty(entries, currentFilter, direction)
    local n = #FILTER_CYCLE
    local startIdx = 1
    for i, f in ipairs(FILTER_CYCLE) do
        if f == currentFilter then
            startIdx = i
            break
        end
    end
    for step = 1, n do
        local idx = startIdx + step * direction
        while idx < 1 do
            idx = idx + n
        end
        while idx > n do
            idx = idx - n
        end
        local f = FILTER_CYCLE[idx]
        local newest = newestMatching(entries, f)
        if newest ~= nil then
            return f, newest
        end
    end
    return nil
end

local function applyFilter(s, direction)
    local nextFilter, idx = rotateNonEmpty(s.entries, s.filter, direction)
    if nextFilter == nil then
        -- Buffer fully empty. Don't change the filter -- there is nothing
        -- to view in any cycle slot, so cycling has no meaning. Speak the
        -- bare empty marker rather than "<filter>, no messages" so the
        -- announcement matches what the bracket keys say in the same
        -- state.
        speakKey("TXT_KEY_CIVVACCESS_MSGBUF_EMPTY")
        return
    end
    s.filter = nextFilter
    s.position = idx
    speakFilterChange(s.filter, s.entries[idx])
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

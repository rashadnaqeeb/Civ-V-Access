-- Digit-keyed cursor bookmarks plus the Ctrl+S permanent jump-to-
-- capital. Ctrl + 1-0 saves the cursor's current (x, y) into the slot,
-- Shift + 1-0 jumps the cursor there (with backspace return via the
-- scanner's pre-jump cell), Alt + 1-0 speaks a direction (and optional
-- capital-relative coord, gated on the scanner's coord setting) from
-- the live cursor to the saved cell. Ctrl+S is the equivalent of a
-- permanent slot for the player's current capital. All three jumps go
-- through ScannerNav.jumpCursorTo, the shared mark-then-jump primitive
-- that also handles the cursor-already-at-target case (speaks
-- SCANNER_HERE rather than re-running the full glance).
--
-- Lives here rather than inline in BaselineHandler because the jump
-- pattern is identical to the slot jumps and this file already has
-- the Cursor / ScannerNav dependencies wired up at boot. The Ctrl+S
-- help entry is author'd in BaselineHandler so it sits next to the
-- Shift+S coordinate readout in the map-mode help list.
--
-- Persistence. Slots survive save/load via Modding.OpenUserData -- a
-- per-machine SQLite store under Documents/My Games/.../ModUserData/
-- (one .db file per (mod GUID, version)), keyed here by the map's
-- random seed and the active player's slot. The store is outside the
-- .Civ5Save and outside the engine's m_syncArchive, so MP clients
-- don't see each other's bookmarks and asymmetric mod loading can't
-- desync. Hotseat re-hydrates on every active-player change so each
-- player at the keyboard sees only their own slots. The Ctrl+S
-- capital jump is computed live from player:GetCapitalCity() and
-- isn't persisted.
--
-- Storage shape: civvaccess_shared.bookmarks[slot] = {x, y}. Slot
-- key is the literal digit string ("1".."9","0") -- same form as
-- Keys["1"] dispatch. The serialized blob is "slot,x,y;..." per
-- (map seed, player slot) key.

Bookmarks = {}

local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_ALT = 4

local SLOT_KEYS = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

-- Our DLC's GUID (matches src/dlc/CivVAccess_2.Civ5Pkg). The engine
-- creates ModUserData/<guid>-<version>.db on first SetValue. Version
-- is independent of mod version: bumping it would orphan the prior
-- bookmarks file, so it stays at 1 unless we deliberately migrate.
local STORE_ID = "40a9df7b-ae9f-48db-abb5-44afe0420524"
local STORE_VERSION = 1

-- Game-and-player scope. GetMapRandSeed is fixed at map gen and
-- persists in the save, so it round-trips a load and uniquely
-- identifies "this game" versus a separately rolled new game.
-- GetActivePlayer is the local seat in SP / MP and rotates with
-- turn order in hotseat -- exactly the per-player-at-keyboard
-- scoping we want. Two saves of the same game share a key.
local function storageKey()
    return tostring(Network.GetMapRandSeed()) .. ":" .. tostring(Game.GetActivePlayer())
end

local function serialize(bookmarks)
    local parts = {}
    for _, slot in ipairs(SLOT_KEYS) do
        local b = bookmarks[slot]
        if b ~= nil then
            parts[#parts + 1] = slot .. "," .. tostring(b.x) .. "," .. tostring(b.y)
        end
    end
    return table.concat(parts, ";")
end

local function deserialize(s)
    local result = {}
    if s == nil or s == "" then
        return result
    end
    for entry in string.gmatch(s, "[^;]+") do
        local slot, x, y = string.match(entry, "([^,]+),([^,]+),([^,]+)")
        if slot ~= nil then
            -- tonumber on a malformed coord returns nil. A {x=nil, y=nil}
            -- entry would look populated to jumpTo / directionTo and
            -- crash downstream in HexGeom; skip and warn instead so a
            -- corrupt store row doesn't masquerade as a valid bookmark.
            local nx, ny = tonumber(x), tonumber(y)
            if nx ~= nil and ny ~= nil then
                result[slot] = { x = nx, y = ny }
            else
                Log.warn("Bookmarks: deserialize skipped malformed entry: " .. tostring(entry))
            end
        end
    end
    return result
end

-- Wraps OpenUserData in the same pcall + nil-handle pattern Prefs uses
-- (CivVAccess_UserPrefs.lua handle()). Returns nil on any failure; the
-- error is logged so the user-facing failure (slots not persisting,
-- empty hydrate) traces back to a Bookmarks-scoped Lua.log line rather
-- than getting swallowed by InputRouter's outer pcall.
local function openStore()
    if Modding == nil or Modding.OpenUserData == nil then
        Log.warn("Bookmarks: Modding.OpenUserData unavailable; persistence disabled this session")
        return nil
    end
    local ok, h = pcall(Modding.OpenUserData, STORE_ID, STORE_VERSION)
    if not ok then
        Log.error("Bookmarks: OpenUserData threw: " .. tostring(h))
        return nil
    end
    if h == nil then
        Log.warn("Bookmarks: OpenUserData returned nil")
        return nil
    end
    return h
end

local function persist()
    local store = openStore()
    if store == nil then
        return
    end
    local key = storageKey()
    local ok, err = pcall(function()
        store.SetValue(key, serialize(civvaccess_shared.bookmarks))
    end)
    if not ok then
        Log.error("Bookmarks: SetValue threw: " .. tostring(err))
    end
end

function Bookmarks.hydrateForCurrentGame()
    -- Always assign a fresh empty table first so a failed store open or
    -- a thrown GetValue still leaves civvaccess_shared.bookmarks as a
    -- valid (empty) table. The binding handlers index it without nil
    -- guarding, and a hydrate failure must not strand them with a nil.
    civvaccess_shared.bookmarks = {}
    local store = openStore()
    if store == nil then
        return
    end
    local key = storageKey()
    local ok, raw = pcall(function()
        return store.GetValue(key)
    end)
    if not ok then
        Log.error("Bookmarks: GetValue threw: " .. tostring(raw))
        return
    end
    civvaccess_shared.bookmarks = deserialize(raw)
end

function Bookmarks.save(slot)
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("Bookmarks.save: cursor not initialised; ignoring slot " .. tostring(slot))
        return ""
    end
    civvaccess_shared.bookmarks[slot] = { x = cx, y = cy }
    persist()
    return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_ADDED")
end

-- Empty slots speak "no bookmark" rather than going silent: a blind
-- user can't tell whether the keystroke registered or which slots
-- they've populated, so feedback closes that loop. Same string for
-- jump and direction. Pre-jump capture, the at-target SCANNER_HERE
-- short-circuit, and the actual Cursor.jumpTo call all live in
-- ScannerNav.jumpCursorTo so this file just resolves the slot.
function Bookmarks.jumpTo(slot)
    local b = civvaccess_shared.bookmarks[slot]
    if b == nil then
        return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY")
    end
    return ScannerNav.jumpCursorTo(b.x, b.y)
end

-- Active player's current capital city plot, or nil before the first
-- city is founded. Targets the current capital (player:GetCapitalCity)
-- rather than the original capital that Shift+S coordinates anchor to
-- via HexGeom.activeOriginalCapital -- if the original was captured
-- and the seat of government moved, "go home" should mean "where I
-- currently rule from", which also matches Cursor.init's initial-
-- placement choice.
local function capitalPlot()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return nil
    end
    local capital = player:GetCapitalCity()
    if capital == nil then
        return nil
    end
    return capital:Plot()
end

-- Ctrl+S: send the cursor to the active player's current capital.
-- Routes through ScannerNav.jumpCursorTo so the at-target SCANNER_HERE
-- short-circuit and the scanner-Backspace pre-jump anchor are shared
-- with the slot jumps. Speaks NO_CAPITAL rather than going silent
-- before the first city is founded.
function Bookmarks.jumpToCapital()
    local plot = capitalPlot()
    if plot == nil then
        return Text.key("TXT_KEY_CIVVACCESS_NO_CAPITAL")
    end
    return ScannerNav.jumpCursorTo(plot:GetX(), plot:GetY())
end

-- A populated slot implies the cursor was set at save time (Bookmarks.save
-- guards against nil cursor), and Cursor never reverts to nil after init,
-- so Cursor.position() is non-nil whenever b is non-nil. No defensive nil
-- guard here -- if the invariant ever broke, HexGeom would throw and the
-- pcall in InputRouter would log it.
function Bookmarks.directionTo(slot)
    local b = civvaccess_shared.bookmarks[slot]
    if b == nil then
        return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY")
    end
    local cx, cy = Cursor.position()
    local dir
    if cx == b.x and cy == b.y then
        dir = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    else
        dir = HexGeom.directionString(cx, cy, b.x, b.y)
    end
    if civvaccess_shared.scannerCoords then
        local coord = HexGeom.coordinateString(b.x, b.y)
        if coord ~= "" then
            return dir .. ". " .. coord
        end
    end
    return dir
end

local bind = HandlerStack.bind

local speak = SpeechPipeline.speakInterrupt

local function saveBinding(slot)
    return bind(Keys[slot], MOD_CTRL, function()
        speak(Bookmarks.save(slot))
    end, "Save bookmark slot " .. slot)
end

local function jumpBinding(slot)
    return bind(Keys[slot], MOD_SHIFT, function()
        speak(Bookmarks.jumpTo(slot))
    end, "Jump to bookmark slot " .. slot)
end

local function directionBinding(slot)
    return bind(Keys[slot], MOD_ALT, function()
        speak(Bookmarks.directionTo(slot))
    end, "Direction to bookmark slot " .. slot)
end

function Bookmarks.getBindings()
    local bindings = {}
    for _, slot in ipairs(SLOT_KEYS) do
        bindings[#bindings + 1] = saveBinding(slot)
        bindings[#bindings + 1] = jumpBinding(slot)
        bindings[#bindings + 1] = directionBinding(slot)
    end
    -- Engine's Ctrl+S is Save game, already swallowed by Baseline's
    -- capturesAllInput barrier (passthroughKeys covers only F1-F11 +
    -- Escape). Filling a dead key, not displacing engine behaviour;
    -- Save remains reachable via Esc menu.
    bindings[#bindings + 1] = bind(Keys.S, MOD_CTRL, function()
        speak(Bookmarks.jumpToCapital())
    end, "Jump cursor to capital")
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE",
            description = "TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP",
            description = "TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION",
            description = "TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Hotseat: GameplaySetActivePlayer fires when the seat passes between
-- human players (same lua_State, same game, different active player).
-- storageKey scopes by Game.GetActivePlayer, so re-hydrating here
-- swaps in the new player's slots; the prior player's slots are
-- already on disk because save() writes through. Hotseat-only because
-- the event doesn't fire on every-turn rotation in SP / MP, and the
-- in-memory state is already correct in those modes.
function Bookmarks._onActivePlayerChanged(iActive, _iPrev)
    -- Mirror HotseatCursor's guard (CivVAccess_HotseatCursorRestore.lua):
    -- the engine fires this with iActive < 0 during teardown / non-player
    -- transitions. Without the guard, hydrate would key off a stale
    -- Game.GetActivePlayer() and silently overwrite the current player's
    -- in-memory slots with whatever happens to be at "<seed>:-1".
    if iActive == nil or iActive < 0 then
        return
    end
    if not Game.IsHotSeat() then
        return
    end
    Bookmarks.hydrateForCurrentGame()
end

function Bookmarks.installListeners()
    if not Game.IsHotSeat() then
        return
    end
    if
        Log.installEvent(
            Events,
            "GameplaySetActivePlayer",
            Bookmarks._onActivePlayerChanged,
            "Bookmarks",
            "hotseat per-player bookmark restore disabled"
        )
    then
        Log.info("Bookmarks: installed hotseat listener")
    end
end

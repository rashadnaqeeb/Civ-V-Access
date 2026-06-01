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
--
-- Unit bookmarks. The same digit chords address a parallel store of
-- the player's own units when unit mode is active (Ctrl+B toggles).
-- A unit can't be stored as a coordinate -- it moves -- so the slot
-- holds {owner, id} and resolves to a live unit via
-- Players[owner]:GetUnitByID at jump time. Ctrl+digit bookmarks the
-- selected unit, Shift+digit selects it and brings it into view
-- (UnitControl.selectAndReveal, the same path the Military Advisor
-- uses, so the cursor-follows-selection setting governs the jump
-- identically), Alt+digit speaks direction to its live plot. A slot
-- whose unit has died, disbanded, or been given away speaks "unit no
-- longer exists". Mode resets to map on every boot (resetMode); it is
-- session state on civvaccess_shared, not persisted. The unit store
-- persists like the tile store, under the "<key>:units" sub-key, shape
-- civvaccess_shared.unitBookmarks[slot] = {owner, id}, serialized
-- "slot,owner,id;...".

Bookmarks = {}

local MODE_MAP = "map"
local MODE_UNIT = "unit"

local function isUnitMode()
    return civvaccess_shared.bookmarkMode == MODE_UNIT
end

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

-- Both stores share one wire format: "slot,a,b;..." where (a, b) are the
-- two numeric payload fields named by f1 / f2. Tile slots carry {x, y};
-- unit slots carry {owner, id}. One serialize / deserialize pair keeps the
-- format and the malformed-row guard a single source of truth so a fix to
-- one can't silently skip the other.
local function serializeSlots(store, f1, f2)
    local parts = {}
    for _, slot in ipairs(SLOT_KEYS) do
        local b = store[slot]
        if b ~= nil then
            parts[#parts + 1] = slot .. "," .. tostring(b[f1]) .. "," .. tostring(b[f2])
        end
    end
    return table.concat(parts, ";")
end

-- tonumber on a malformed field returns nil. An entry with a nil field
-- would look populated to the jump / direction paths and crash downstream
-- (HexGeom for tiles, Players[nil] for units); skip and warn instead so a
-- corrupt store row can't masquerade as a valid bookmark. `tag` names the
-- store so the warning points at the right blob.
local function deserializeSlots(s, f1, f2, tag)
    local result = {}
    if s == nil or s == "" then
        return result
    end
    for entry in string.gmatch(s, "[^;]+") do
        local slot, a, b = string.match(entry, "([^,]+),([^,]+),([^,]+)")
        if slot ~= nil then
            local na, nb = tonumber(a), tonumber(b)
            if na ~= nil and nb ~= nil then
                result[slot] = { [f1] = na, [f2] = nb }
            else
                Log.warn("Bookmarks: " .. tag .. " skipped malformed entry: " .. tostring(entry))
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

-- Write one store under `subkey` (appended to the (seed, player) scope
-- key: "" for tile slots, ":units" for unit slots, so they share the scope
-- without colliding in the same SQLite store). Logs a thrown write through
-- the Bookmarks wrapper rather than letting InputRouter's outer pcall
-- swallow it.
local function persistStore(subkey, serialized)
    local store = openStore()
    if store == nil then
        return
    end
    local ok, err = pcall(function()
        store.SetValue(storageKey() .. subkey, serialized)
    end)
    if not ok then
        Log.error("Bookmarks: SetValue" .. subkey .. " threw: " .. tostring(err))
    end
end

local function persist()
    persistStore("", serializeSlots(civvaccess_shared.bookmarks, "x", "y"))
end

local function persistUnits()
    persistStore(":units", serializeSlots(civvaccess_shared.unitBookmarks, "owner", "id"))
end

-- Drop any prior game's mode so every boot (and hotseat handover) starts
-- in map mode, the original digit-chord behavior. civvaccess_shared
-- survives load-from-game, so without this the player could load straight
-- into unit mode with no visible cue.
function Bookmarks.resetMode()
    civvaccess_shared.bookmarkMode = MODE_MAP
end

function Bookmarks.hydrateForCurrentGame()
    -- Always assign fresh empty tables first so a failed store open or a
    -- thrown GetValue still leaves both stores as valid (empty) tables.
    -- The binding handlers index them without nil guarding, and a hydrate
    -- failure must not strand them with a nil.
    civvaccess_shared.bookmarks = {}
    civvaccess_shared.unitBookmarks = {}
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
    else
        civvaccess_shared.bookmarks = deserializeSlots(raw, "x", "y", "deserialize")
    end
    local okU, rawU = pcall(function()
        return store.GetValue(key .. ":units")
    end)
    if not okU then
        Log.error("Bookmarks: GetValue (units) threw: " .. tostring(rawU))
    else
        civvaccess_shared.unitBookmarks = deserializeSlots(rawU, "owner", "id", "deserializeUnits")
    end
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

-- HERE / direction / optional-coord composition shared by the tile and
-- unit direction readouts. HERE at zero delta (the token the scanner
-- speaks), otherwise the bearing string; the capital-relative coord segment
-- rides on the scannerCoords toggle so both modes share one vocabulary.
local function composeDirection(cx, cy, tx, ty)
    local dir
    if cx == tx and cy == ty then
        dir = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    else
        dir = HexGeom.directionString(cx, cy, tx, ty)
    end
    if civvaccess_shared.scannerCoords then
        local coord = HexGeom.coordinateString(tx, ty)
        if coord ~= "" then
            return dir .. ". " .. coord
        end
    end
    return dir
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
    return composeDirection(cx, cy, b.x, b.y)
end

-- ===== Unit bookmarks =================================================

local speak = SpeechPipeline.speakInterrupt

-- Ctrl+digit in unit mode: bookmark the head-selected unit. Stores owner
-- and id (not a coordinate -- the unit moves) so the slot resolves to a
-- live unit at jump time. Speaks "no unit selected" rather than saving an
-- empty slot when nothing is selected. The confirmation names the unit so
-- the mode is audible without a separate query; UnitSpeech.unitName can
-- return "" on a degenerate GameInfo miss, in which case fall back to the
-- bare confirmation rather than speak a dangling "bookmarked ".
function Bookmarks.saveUnit(slot)
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then
        return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_NO_UNIT")
    end
    civvaccess_shared.unitBookmarks[slot] = { owner = unit:GetOwner(), id = unit:GetID() }
    persistUnits()
    local name = UnitSpeech.unitName(unit)
    if name == "" then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_BOOKMARK_ADDED")
    end
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_BOOKMARK_ADDED_NAMED", name)
end

-- Resolve a unit slot to a live unit. Returns (unit, nil) when alive, or
-- (nil, message) for the two miss cases the user must hear apart: an empty
-- slot ("no unit bookmark") versus a saved slot whose unit has died,
-- disbanded, or been given away ("unit no longer exists"). GetUnitByID
-- returns nil for all of those, which is exactly the own-units-only
-- contract: a nil here means gone, not merely out of sight.
local function resolveBookmarkedUnit(slot)
    local b = civvaccess_shared.unitBookmarks[slot]
    if b == nil then
        return nil, Text.key("TXT_KEY_CIVVACCESS_UNIT_BOOKMARK_EMPTY")
    end
    -- owner is the active player (saveUnit captures the head selection,
    -- always own), who is always alive, so Players[b.owner] is never a
    -- legitimate nil; let it crash to Lua.log if that invariant ever breaks.
    local unit = Players[b.owner]:GetUnitByID(b.id)
    if unit == nil then
        return nil, Text.key("TXT_KEY_CIVVACCESS_UNIT_BOOKMARK_GONE")
    end
    return unit, nil
end

-- Shift+digit in unit mode: select the bookmarked unit and bring it into
-- view through the shared select-and-reveal path (cursor-follows-selection
-- governs the jump, same as the Military Advisor). selectAndReveal returns
-- false when the unit was already the head selection -- it only re-centers
-- then, firing no selection announcement, so speak the unit info to confirm
-- the keystroke registered. The alive path speaks via the selection
-- listener, so this returns nothing; the binding doesn't wrap it in speak().
function Bookmarks.jumpToUnit(slot)
    local unit, msg = resolveBookmarkedUnit(slot)
    if unit == nil then
        speak(msg)
        return
    end
    -- A bookmark jump is a deliberate navigation action, like the unit-cycle
    -- keys, so its selection announcement should interrupt rather than queue
    -- behind whatever is speaking. selectAndReveal's UI.SelectUnit fires the
    -- selection listener synchronously, which consumes this flag.
    UnitControl.markUserInitiatedSelection()
    if not UnitControl.selectAndReveal(unit) then
        speak(UnitSpeech.info(unit))
    end
end

-- Alt+digit in unit mode: direction from the cursor to the unit's live
-- plot, read off GetX/GetY at speech time (never a stored coordinate).
function Bookmarks.directionToUnit(slot)
    local unit, msg = resolveBookmarkedUnit(slot)
    if unit == nil then
        return msg
    end
    local cx, cy = Cursor.position()
    return composeDirection(cx, cy, unit:GetX(), unit:GetY())
end

-- Ctrl+B: flip between map and unit bookmarks. Announces the new mode on
-- every press -- mode is invisible state, so the announcement is the only
-- orientation a blind player gets, and the save / jump announcements in
-- each mode differ in content (tile glance versus unit) as the backstop.
function Bookmarks.toggleMode()
    if isUnitMode() then
        civvaccess_shared.bookmarkMode = MODE_MAP
        return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_MODE_MAP")
    end
    civvaccess_shared.bookmarkMode = MODE_UNIT
    return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_MODE_UNIT")
end

local bind = HandlerStack.bind

-- One binding per (digit, modifier); the mode flag selects which store the
-- chord addresses. The unit jump speaks internally (it defers to the
-- selection listener on the alive path), so it isn't wrapped in speak().
local function saveBinding(slot)
    return bind(Keys[slot], MOD_CTRL, function()
        if isUnitMode() then
            speak(Bookmarks.saveUnit(slot))
        else
            speak(Bookmarks.save(slot))
        end
    end, "Save bookmark slot " .. slot)
end

local function jumpBinding(slot)
    return bind(Keys[slot], MOD_SHIFT, function()
        if isUnitMode() then
            Bookmarks.jumpToUnit(slot)
        else
            speak(Bookmarks.jumpTo(slot))
        end
    end, "Jump to bookmark slot " .. slot)
end

local function directionBinding(slot)
    return bind(Keys[slot], MOD_ALT, function()
        if isUnitMode() then
            speak(Bookmarks.directionToUnit(slot))
        else
            speak(Bookmarks.directionTo(slot))
        end
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
    -- Ctrl+B: switch the digit chords between map and unit bookmarks.
    -- Engine's Ctrl+B is unbound (bare B is ranged-attack / found-city,
    -- all AltDown=0 ShiftDown=0 CtrlDown=0) and Baseline's barrier swallows
    -- the chord regardless. Help entry author'd in BaselineHandler next to
    -- the other bookmark rows, same as Ctrl+S.
    bindings[#bindings + 1] = bind(Keys.B, MOD_CTRL, function()
        speak(Bookmarks.toggleMode())
    end, "Toggle map/unit bookmarks")
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

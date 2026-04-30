-- Per-session digit-keyed cursor bookmarks plus the Ctrl+S permanent
-- jump-to-capital. Ctrl + 1-0 saves the cursor's current (x, y) into
-- the slot, Shift + 1-0 jumps the cursor there (with backspace return
-- via the scanner's pre-jump cell), Alt + 1-0 speaks a direction (and
-- optional capital-relative coord, gated on the scanner's coord
-- setting) from the live cursor to the saved cell. Ctrl+S is the
-- equivalent of a permanent slot for the player's current capital.
-- All three jumps go through ScannerNav.jumpCursorTo, the shared
-- mark-then-jump primitive that also handles the cursor-already-at-
-- target case (speaks SCANNER_HERE rather than re-running the full
-- glance).
--
-- Lives here rather than inline in BaselineHandler because the jump
-- pattern is identical to the slot jumps and this file already has
-- the Cursor / ScannerNav dependencies wired up at boot. The Ctrl+S
-- help entry is author'd in BaselineHandler so it sits next to the
-- Shift+S coordinate readout in the map-mode help list.
--
-- Storage shape: civvaccess_shared.bookmarks[slot] = {x, y}. Slot
-- key is the literal digit string ("1".."9","0") -- same form as
-- Keys["1"] dispatch. onInGameBoot calls resetForNewGame before any
-- binding can fire, so the table is always non-nil at access time.
-- Not persisted to the save file: Civ V's save format has no mod-
-- controlled extension point, and any custom payload on a save would
-- risk multiplayer-hash drift.

Bookmarks = {}

local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_ALT = 4

local SLOT_KEYS = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

function Bookmarks.resetForNewGame()
    civvaccess_shared.bookmarks = {}
end

function Bookmarks.save(slot)
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("Bookmarks.save: cursor not initialised; ignoring slot " .. tostring(slot))
        return ""
    end
    civvaccess_shared.bookmarks[slot] = { x = cx, y = cy }
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

local function speak(s)
    if s == nil or s == "" then
        return
    end
    SpeechPipeline.speakInterrupt(s)
end

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

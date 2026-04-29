-- Per-session digit-keyed cursor bookmarks. Ctrl + 1-0 saves the
-- cursor's current (x, y) into the slot, Shift + 1-0 jumps the
-- cursor there (with backspace return via the scanner's pre-jump
-- cell), Alt + 1-0 speaks a direction (and optional capital-relative
-- coord, gated on the scanner's coord setting) from the live cursor
-- to the saved cell.
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
-- jump and direction.
function Bookmarks.jumpTo(slot)
    local b = civvaccess_shared.bookmarks[slot]
    if b == nil then
        return Text.key("TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY")
    end
    -- Mirror ScannerNav.jumpToEntry's pre-jump capture so backspace
    -- on the scanner returns the cursor to where it was before the
    -- bookmark jump. Skip when already at the target -- a no-op jump
    -- shouldn't shadow the prior backspace anchor.
    local cx, cy = Cursor.position()
    if cx ~= nil and (cx ~= b.x or cy ~= b.y) then
        ScannerNav.markPreJump(cx, cy)
    end
    return Cursor.jumpTo(b.x, b.y)
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

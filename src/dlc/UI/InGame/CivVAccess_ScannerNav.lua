-- Scanner navigation state machine. Owns the four cursor indices
-- (category, subcategory, item, instance), the current snapshot, the
-- pre-jump cell for Backspace, and the turn-start invalidation
-- subscription. Every scanner binding maps to one of the entry points
-- below; the handler file is purely the (key, mods) -> entry-point
-- table (CivVAccess_ScannerHandler.lua).
--
-- Rebuild triggers (design section 5):
--   * Ctrl+PageUp/Down            explicit, eager
--   * Events.ActivePlayerTurnStart  marks stale; next op that needs the
--                                 snapshot rebuilds
-- Subcategory / item / instance cycles never rebuild -- closest-first
-- sort reshuffling after every cursor step would lose the user's
-- place constantly.

ScannerNav = {}

local _catIdx       = 1
local _subIdx       = 1
local _itemIdx      = 0
local _instIdx      = 0
local _snapshot     = nil
local _snapshotStale = true
local _preJumpX     = nil
local _preJumpY     = nil

-- Running the turn-start listener through civvaccess_shared so multiple
-- in-game Contexts booting into the same lua_State don't each register
-- their own subscription (same pattern CivVAccess_Boot uses for
-- LoadScreenClose).
local function installTurnStartListener()
    if civvaccess_shared.scannerNavListenerInstalled then return end
    if Events == nil or Events.ActivePlayerTurnStart == nil then
        Log.warn("ScannerNav: Events.ActivePlayerTurnStart missing; "
            .. "turn-start invalidation disabled")
        return
    end
    civvaccess_shared.scannerNavListenerInstalled = true
    Events.ActivePlayerTurnStart.Add(function()
        _snapshotStale = true
    end)
    Log.info("ScannerNav: registered ActivePlayerTurnStart listener")
end

installTurnStartListener()

-- Initialise the auto-move toggle on the shared table the first time we
-- boot into a session. Default is on per design section 9; users who
-- want it off flip it with Shift+End.
if civvaccess_shared.scannerAutoMove == nil then
    civvaccess_shared.scannerAutoMove = true
end

-- ===== Snapshot plumbing =====

local function currentCategory()
    if _snapshot == nil then return nil end
    return _snapshot.categories[_catIdx]
end

local function currentSub()
    local cat = currentCategory()
    if cat == nil then return nil end
    return cat.subcategories[_subIdx]
end

local function currentItem()
    local sub = currentSub()
    if sub == nil or _itemIdx == 0 then return nil end
    return sub.items[_itemIdx]
end

local function currentInstance()
    local item = currentItem()
    if item == nil or _instIdx == 0 then return nil end
    return item.instances[_instIdx]
end

-- Reset sub/item/inst indices to the "front" of the current category.
-- Item and instance land at 1 when the sub has entries, otherwise 0.
local function snapToCategoryFront()
    _subIdx = 1
    local sub = currentSub()
    if sub ~= nil and #sub.items > 0 then
        _itemIdx = 1
        _instIdx = (#sub.items[1].instances > 0) and 1 or 0
    else
        _itemIdx, _instIdx = 0, 0
    end
end

-- Gather entries from every backend and build a fresh snapshot using
-- the cursor's current (x, y) as the distance origin.
local function rebuildSnapshot()
    local entries = {}
    local activePlayer = Game.GetActivePlayer()
    local activeTeam   = Game.GetActiveTeam()
    for _, backend in ipairs(ScannerCore.BACKENDS) do
        local ok, list = pcall(backend.Scan, activePlayer, activeTeam)
        if not ok then
            Log.error("ScannerNav: backend '" .. tostring(backend.name)
                .. "' Scan failed: " .. tostring(list))
        elseif type(list) == "table" then
            for _, entry in ipairs(list) do
                entries[#entries + 1] = entry
            end
        end
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("ScannerNav.rebuild: cursor not initialised; using (0, 0) as distance origin")
        cx, cy = 0, 0
    end
    _snapshot = ScannerSnap.build(entries, cx, cy)
    _snapshotStale = false
end

-- Ensure a current, non-stale snapshot exists before any op that reads it.
local function ensureSnapshot()
    if _snapshot == nil or _snapshotStale then
        rebuildSnapshot()
    end
end

-- ===== Speech assembly =====
-- `<item name>. <distance/direction from cursor>. <N> of <M>.`
-- The concise-announcement rule forbids "N of M" for menus ("Play, 1 of 8"
-- adds no information because the name already disambiguates). It is
-- actionable here: "Swordsman, 1 of 8" tells the player there are eight
-- swordsmen and this is the closest. The scanner carves out an exception
-- to the rule for that reason.
local function formatInstance(item, instance, instIdx, instCount)
    local cx, cy = Cursor.position()
    local dir = ""
    if cx ~= nil then
        if cx == instance.plotX and cy == instance.plotY then
            dir = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
        else
            dir = HexGeom.directionString(cx, cy, instance.plotX, instance.plotY)
        end
    end
    local count = Text.format("TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT",
        instIdx, instCount)
    return item.name .. ". " .. dir .. ". " .. count
end

local function announceCurrent()
    local item = currentItem()
    if item == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local inst = currentInstance()
    if inst == nil then
        -- Item existed but all instances pruned out; caller already tried
        -- to advance. Fall back to empty.
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    return formatInstance(item, inst, _instIdx, #item.instances)
end

-- Compose a "<label>. <current item announcement>" string for the
-- subcategory / category cycle entries, per design section 7.
local function announceWithLabel(labelKey)
    return Text.key(labelKey) .. ". " .. announceCurrent()
end

-- Auto-move side-effect shared by every cycle. Jumps the cursor to the
-- current instance's plot when the toggle is on. The jump is silent --
-- the cycle's own announcement already speaks the entry and distance,
-- and saying the plot glance on top would double the audio. Explicit
-- Home speaks the glance because it has no cycle announcement covering
-- for it.
local function autoMoveIfEnabled()
    if not civvaccess_shared.scannerAutoMove then return end
    local inst = currentInstance()
    if inst == nil then return end
    local cx, cy = Cursor.position()
    if cx == nil then return end
    if cx == inst.plotX and cy == inst.plotY then return end
    _preJumpX, _preJumpY = cx, cy
    Cursor.jumpTo(inst.plotX, inst.plotY)
end

-- ===== Wrap helpers =====

local function wrapIndex(i, n, dir)
    if n <= 0 then return 0 end
    i = i + dir
    if i < 1 then i = n end
    if i > n then i = 1 end
    return i
end

-- ===== Entry points =====

function ScannerNav.cycleCategory(dir)
    ensureSnapshot()
    local n = #_snapshot.categories
    if n == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    _catIdx = wrapIndex(_catIdx, n, dir)
    -- Category change is the rebuild signal per section 5: force one
    -- before resetting indices into the new category's subs.
    rebuildSnapshot()
    snapToCategoryFront()
    autoMoveIfEnabled()
    return announceWithLabel(currentCategory().label)
end

function ScannerNav.cycleSubcategory(dir)
    ensureSnapshot()
    local cat = currentCategory()
    if cat == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local n = #cat.subcategories
    _subIdx = wrapIndex(_subIdx, n, dir)
    local sub = currentSub()
    if sub ~= nil and #sub.items > 0 then
        _itemIdx = 1
        _instIdx = (#sub.items[1].instances > 0) and 1 or 0
    else
        _itemIdx, _instIdx = 0, 0
    end
    autoMoveIfEnabled()
    return announceWithLabel(sub.label)
end

function ScannerNav.cycleItem(dir)
    ensureSnapshot()
    local sub = currentSub()
    if sub == nil or #sub.items == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    _itemIdx = wrapIndex(_itemIdx == 0 and 1 or _itemIdx, #sub.items, dir)
    local item = currentItem()
    _instIdx = (item ~= nil and #item.instances > 0) and 1 or 0
    autoMoveIfEnabled()
    return announceCurrent()
end

function ScannerNav.cycleInstance(dir)
    ensureSnapshot()
    local item = currentItem()
    if item == nil or #item.instances == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    _instIdx = wrapIndex(_instIdx == 0 and 1 or _instIdx, #item.instances, dir)
    autoMoveIfEnabled()
    return announceCurrent()
end

-- Home: jump the cursor to the current entry's plot and speak the
-- glance (same text Cursor.move produces after a directional step).
-- The glance covers the "where am I now" need; no re-announcement of
-- the entry label is required because the user just pressed Home on
-- it and already knows.
function ScannerNav.jumpToEntry()
    ensureSnapshot()
    local inst = currentInstance()
    if inst == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local cx, cy = Cursor.position()
    if cx ~= nil and (cx ~= inst.plotX or cy ~= inst.plotY) then
        _preJumpX, _preJumpY = cx, cy
    end
    return Cursor.jumpTo(inst.plotX, inst.plotY)
end

-- End: speak the distance/direction from the hex cursor to the
-- current entry. Byte-identical format to the S key (capital -> cursor)
-- via HexGeom.directionString; the only divergence is the zero-distance
-- short-circuit key (SCANNER_HERE here, AT_CAPITAL there).
function ScannerNav.distanceFromCursor()
    ensureSnapshot()
    local inst = currentInstance()
    if inst == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local cx, cy = Cursor.position()
    if cx == nil then return "" end
    if cx == inst.plotX and cy == inst.plotY then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    end
    return HexGeom.directionString(cx, cy, inst.plotX, inst.plotY)
end

-- Shift+End: flip the session-scoped auto-move preference on the shared
-- table. The design calls out that this is the first persistent user
-- setting and stays session-only until a settings layer lands; the
-- table already survives Context re-instantiation, which is the scope
-- we need until then.
function ScannerNav.toggleAutoMove()
    local now = not civvaccess_shared.scannerAutoMove
    civvaccess_shared.scannerAutoMove = now
    if now then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_ON")
    else
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_OFF")
    end
end

-- Backspace: restore the cursor to the cell saved at the most recent
-- scanner-driven jump. No-op (speak JUMP_NO_RETURN) when no such jump
-- has happened since the last restore.
function ScannerNav.returnToPreJump()
    if _preJumpX == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN")
    end
    local x, y = _preJumpX, _preJumpY
    _preJumpX, _preJumpY = nil, nil
    return Cursor.jumpTo(x, y)
end

-- Ctrl+F: open the type-ahead search handler on top of the scanner.
-- The handler itself owns the Enter / Escape flow and pops itself.
function ScannerNav.openSearch()
    HandlerStack.push(ScannerInput.create())
    return Text.key("TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT")
end

-- Test seam (module has persistent upvalues; production never calls it).
function ScannerNav._reset()
    _catIdx, _subIdx, _itemIdx, _instIdx = 1, 1, 0, 0
    _snapshot, _snapshotStale = nil, true
    _preJumpX, _preJumpY = nil, nil
end

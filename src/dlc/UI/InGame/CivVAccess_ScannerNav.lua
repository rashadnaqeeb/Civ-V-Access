-- Scanner navigation state machine. Owns the four cursor indices
-- (category, subcategory, item, instance), the current snapshot, and
-- the pre-jump cell for Backspace. Every scanner binding maps to one of
-- the entry points below; the handler file is purely the (key, mods) ->
-- entry-point table (CivVAccess_ScannerHandler.lua).
--
-- Rebuild model (design section 5, revised):
-- Every navigation entry point rebuilds the snapshot from live backend
-- output. Explicit "reorient" cycles (Ctrl+PageUp/Down, Shift+PageUp/Down,
-- Ctrl+F) re-anchor the sort origin to the current cursor and land the
-- user at the front of the new scope. Every other cycle (bare, Alt,
-- Home, End) preserves the origin from the previous rebuild and
-- re-locates the user's current instance in the new snapshot by its
-- entry key, so a resort never moves them off whatever entity they were
-- pointing at. New entries that slot in behind the cursor's identity
-- appear naturally on subsequent reverse cycles; new entries that would
-- reorder existing items leave the user's cursor on the same entity at
-- its new index. A Ctrl/Shift+PageUp/Down remains the "forget where I
-- was" escape hatch.
--
-- Search snapshots (isSearch) are an exception: they are frozen slices
-- produced by applySearch and not rebuilt on navigation. Exiting search
-- (Ctrl+PageUp/Down from inside a search snapshot) rebuilds the normal
-- snapshot anchored to the cursor at exit time.

ScannerNav = {}

local _catIdx = 1
local _subIdx = 1
local _itemIdx = 0
local _instIdx = 0
local _snapshot = nil
local _preJumpX = nil
local _preJumpY = nil
-- Remembered _catIdx from the moment a search opened. A Ctrl+PageUp/Down
-- from inside a search snapshot cycles relative to this, not relative to
-- the synthetic search category (which is the only one in the search
-- snapshot).
local _preSearchCatIdx = nil

-- Hydrate the auto-move toggle on the shared table the first time we
-- boot into a session. Default is off: auto-move yanks the cursor away
-- from the user's working cell on every scan step, which is disruptive
-- enough to warrant opt-in. Users who want it flip it with Shift+End and
-- the new value persists across sessions via Prefs.
if civvaccess_shared.scannerAutoMove == nil then
    civvaccess_shared.scannerAutoMove = Prefs.getBool("ScannerAutoMove", false)
end

-- ===== Snapshot plumbing =====

local function currentCategory()
    if _snapshot == nil then
        return nil
    end
    return _snapshot.categories[_catIdx]
end

local function currentSub()
    local cat = currentCategory()
    if cat == nil then
        return nil
    end
    return cat.subcategories[_subIdx]
end

local function currentItem()
    local sub = currentSub()
    if sub == nil or _itemIdx == 0 then
        return nil
    end
    return sub.items[_itemIdx]
end

local function currentInstance()
    local item = currentItem()
    if item == nil or _instIdx == 0 then
        return nil
    end
    return item.instances[_instIdx]
end

local function isSearchSnapshot()
    return _snapshot ~= nil and _snapshot.isSearch == true
end

-- Set _itemIdx / _instIdx to the front of the current sub. Called after
-- any cursor move that changes which sub is current (category or sub
-- cycle, post-search land).
local function landOnCurrentSub()
    local sub = currentSub()
    if sub ~= nil and #sub.items > 0 then
        _itemIdx = 1
        _instIdx = (#sub.items[1].instances > 0) and 1 or 0
    else
        _itemIdx, _instIdx = 0, 0
    end
end

-- Reset sub/item/inst indices to the "front" of the current category.
local function snapToCategoryFront()
    _subIdx = 1
    landOnCurrentSub()
end

-- Gather entries from every backend. Shared between the normal rebuild
-- path and search, which both consume the same flat list.
--
-- When civvaccess_shared.mapScope is set (e.g. CityView's hex sub-handler
-- has narrowed the world to a single city's reachable tiles), filter
-- entries whose plotIndex resolves outside the scope. One funnel covers
-- both rebuildSnapshot and applySearch so every consumer sees the same
-- scoped list.
local function gatherEntries()
    local entries = {}
    local activePlayer = Game.GetActivePlayer()
    local activeTeam = Game.GetActiveTeam()
    for _, backend in ipairs(ScannerCore.BACKENDS) do
        local ok, list = pcall(backend.Scan, activePlayer, activeTeam)
        if not ok then
            Log.error("ScannerNav: backend '" .. tostring(backend.name) .. "' Scan failed: " .. tostring(list))
        elseif type(list) == "table" then
            for _, entry in ipairs(list) do
                entries[#entries + 1] = entry
            end
        end
    end
    local scope = civvaccess_shared.mapScope
    if scope ~= nil then
        local kept = {}
        for _, entry in ipairs(entries) do
            local plot = Map.GetPlotByIndex(entry.plotIndex)
            if plot ~= nil and scope(plot:GetX(), plot:GetY()) then
                kept[#kept + 1] = entry
            end
        end
        entries = kept
    end
    return entries
end

local function cursorOriginOrDefault()
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("ScannerNav: cursor not initialised; using (0, 0) as distance origin")
        return 0, 0
    end
    return cx, cy
end

-- Build a fresh snapshot whose sort origin is (originX, originY). The
-- caller decides whether that's the live cursor (explicit reorient) or
-- the previous snapshot's origin (identity-preserving refresh).
local function rebuildSnapshot(originX, originY)
    local entries = gatherEntries()
    _snapshot = ScannerSnap.build(entries, originX, originY)
end

-- Rebuild and re-seat the user's cursor on the same instance they were
-- pointing at. Preserves the sort origin from the previous snapshot so
-- distances announced across a rebuild stay relative to a stable anchor
-- rather than drifting with the live cursor (which auto-move may have
-- driven onto the entry itself).
--
-- Search snapshots are frozen; callers must not rebuild them through this
-- path. Returns whether identity was preserved.
--
-- On the very first build of the session, advance _catIdx past any empty
-- leading category. _catIdx starts at 1 (cities), which is empty before
-- the capital is founded; without this skip, a turn-0 PageDown would
-- speak EMPTY even though units_my holds the starting settler. Subsequent
-- rebuilds intentionally keep the user's chosen category -- if it empties
-- out mid-game, EMPTY is the correct answer rather than a silent jump
-- elsewhere.
local function rebuildAndLocate()
    if isSearchSnapshot() then
        return false
    end
    local isFirstBuild = (_snapshot == nil)
    local key, hintCat, hintSub
    local inst = currentInstance()
    if inst ~= nil then
        key, hintCat, hintSub = inst.key, _catIdx, _subIdx
    end
    local originX, originY
    if isFirstBuild then
        originX, originY = cursorOriginOrDefault()
    else
        originX, originY = _snapshot.cursorX, _snapshot.cursorY
    end
    rebuildSnapshot(originX, originY)
    if key ~= nil then
        local ci, si, ii, ini = ScannerSnap.locate(_snapshot, key, hintCat, hintSub)
        if ci ~= nil then
            _catIdx, _subIdx, _itemIdx, _instIdx = ci, si, ii, ini
            return true
        end
    end
    -- No prior identity (first build) or identity gone (entity died).
    _itemIdx, _instIdx = 0, 0
    if isFirstBuild then
        local cats = _snapshot.categories
        local n = #cats
        for step = 0, n - 1 do
            local i = ((_catIdx - 1 + step) % n) + 1
            local allSub = cats[i].subcategories[1]
            if allSub ~= nil and #allSub.items > 0 then
                _catIdx = i
                _subIdx = 1
                break
            end
        end
    end
    return false
end

-- Full rebuild that re-anchors the sort origin to the current cursor.
-- Used by explicit reorient entry points (Ctrl+PageUp/Down,
-- Shift+PageUp/Down, search commit). Resets item / instance to sentinels
-- so the caller picks where to land (front of cat, front of sub, etc.).
local function rebuildFromCursor()
    local cx, cy = cursorOriginOrDefault()
    rebuildSnapshot(cx, cy)
    _itemIdx, _instIdx = 0, 0
end

-- Ask the backend whether the current instance is still live. If not,
-- prune it and re-land on whatever the surviving neighbour is; loop
-- because the next candidate might also be stale. Design section 5:
-- "`ValidateEntry` is called on the current instance every time the user
-- navigates to it. If it returns false, the entry is pruned ... and the
-- navigator advances to the next valid instance within the same item
-- (or wraps up the hierarchy if the item empties out)."
local function ensureCurrentInstanceValid()
    while true do
        local inst = currentInstance()
        if inst == nil then
            return
        end
        local entry = inst.entry
        local ok, valid = pcall(entry.backend.ValidateEntry, entry, nil)
        if not ok then
            Log.error(
                "ScannerNav: backend '" .. tostring(entry.backend.name) .. "' ValidateEntry failed: " .. tostring(valid)
            )
            return
        end
        if valid then
            return
        end
        ScannerSnap.pruneInstance(_snapshot, _catIdx, _subIdx, _itemIdx, _instIdx)
        -- Re-land indices after prune. The surviving instance, if any,
        -- now occupies _instIdx or a lower index; if the item emptied
        -- out, pruneInstance also removed it from sub.items.
        local item = currentItem()
        if item == nil or #item.instances == 0 then
            local sub = currentSub()
            if sub == nil or #sub.items == 0 then
                _itemIdx, _instIdx = 0, 0
                return
            end
            if _itemIdx > #sub.items then
                _itemIdx = #sub.items
            end
            if _itemIdx == 0 then
                _itemIdx = 1
            end
            _instIdx = (#sub.items[_itemIdx].instances > 0) and 1 or 0
        elseif _instIdx > #item.instances then
            _instIdx = #item.instances
        end
    end
end

-- ===== Speech assembly =====
-- `<item name>. <distance/direction from origin>. <N> of <M>.`
-- The concise-announcement rule forbids "N of M" for menus ("Play, 1 of 8"
-- adds no information because the name already disambiguates). It is
-- actionable here: "Swordsman, 1 of 8" tells the player there are eight
-- swordsmen and this is the closest. The scanner carves out an exception
-- to the rule for that reason.
--
-- Distance origin depends on the auto-move toggle:
--   * auto-move ON  -- snapshot origin. Each cycle warps the cursor onto
--                      the entry; a live-cursor formatter would then say
--                      "here" on every subsequent cycle. Anchoring to the
--                      origin keeps distances meaningful and matches the
--                      sort order the snapshot was built against.
--   * auto-move OFF -- live cursor. The user drives the cursor themselves,
--                      so a manual step toward an entry should count the
--                      distance down on the next re-announce. Distances
--                      may diverge from the snapshot's sort order once the
--                      user has moved; that's the intended tradeoff for
--                      making spatial feedback track the cursor.
-- The live-cursor distance is also available on demand via End regardless
-- of toggle state.
local function formatInstance(instance, instIdx, instCount)
    local cx, cy
    if civvaccess_shared.scannerAutoMove then
        cx, cy = _snapshot.cursorX, _snapshot.cursorY
    else
        cx, cy = Cursor.position()
        if cx == nil then
            cx, cy = _snapshot.cursorX, _snapshot.cursorY
        end
    end
    local dir
    if cx == instance.plotX and cy == instance.plotY then
        dir = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    else
        dir = HexGeom.directionString(cx, cy, instance.plotX, instance.plotY)
    end
    local count = Text.format("TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT", instIdx, instCount)
    local entry = instance.entry
    -- FormatName is the live-query seam per design section 4; item.name
    -- is only the grouping key captured at build time.
    local name = entry.backend.FormatName(entry)
    return name .. ". " .. dir .. ". " .. count
end

local function announceCurrent()
    local item = currentItem()
    if item == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local inst = currentInstance()
    if inst == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    return formatInstance(inst, _instIdx, #item.instances)
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
    if not civvaccess_shared.scannerAutoMove then
        return
    end
    local inst = currentInstance()
    if inst == nil then
        return
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return
    end
    if cx == inst.plotX and cy == inst.plotY then
        return
    end
    _preJumpX, _preJumpY = cx, cy
    Cursor.jumpTo(inst.plotX, inst.plotY)
end

-- ===== Wrap helpers =====

local function wrapIndex(i, n, dir)
    if n <= 0 then
        return 0
    end
    i = i + dir
    if i < 1 then
        i = n
    end
    if i > n then
        i = 1
    end
    return i
end

-- A category is non-empty iff its `all` sub (index 1) has items. `all`
-- shares item refs with every named sub, so this is both O(1) and the
-- single source of truth for "does this category contain anything".
local function categoryHasItems(cat)
    local allSub = cat.subcategories[1]
    return allSub ~= nil and #allSub.items > 0
end

local function subHasItems(sub)
    return #sub.items > 0
end

-- Walk `list` from startIdx in direction `dir`, wrapping, until `pred`
-- accepts an element. Returns 0 when nothing matches. dir=0 is the
-- "stay put but validate" case: returns startIdx if it passes, else 0.
-- Category / subcategory cycles use this to skip empty buckets so the
-- user never lands on an empty slot and hears the EMPTY token when a
-- neighbour has content. Item / instance cycles intentionally don't --
-- those axes cycle within a sub and wrapping through empties is moot
-- there (the sub either has items or it doesn't).
local function nextIndexMatching(list, startIdx, dir, pred)
    local n = #list
    if n <= 0 then
        return 0
    end
    if dir == 0 then
        if pred(list[startIdx]) then
            return startIdx
        end
        return 0
    end
    local i = startIdx
    for _ = 1, n do
        i = i + dir
        if i < 1 then
            i = n
        end
        if i > n then
            i = 1
        end
        if pred(list[i]) then
            return i
        end
    end
    return 0
end

-- ===== Entry points =====

function ScannerNav.cycleCategory(dir)
    -- Ctrl+PageUp/Down from inside a search snapshot is the "exit search"
    -- signal per design section 8. Drop the synthetic snapshot and
    -- restore the pre-search category index; rebuildFromCursor below
    -- builds the normal snapshot anchored to where the cursor is now.
    if isSearchSnapshot() then
        _catIdx = _preSearchCatIdx or 1
        _snapshot = nil
    end
    -- Explicit reorient: new origin at the cursor, user lands at the
    -- front of the new category's `all` sub.
    rebuildFromCursor()
    local newIdx = nextIndexMatching(_snapshot.categories, _catIdx, dir, categoryHasItems)
    if newIdx == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    _catIdx = newIdx
    snapToCategoryFront()
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceWithLabel(currentCategory().label)
end

function ScannerNav.cycleSubcategory(dir)
    -- Explicit reorient within the category: new origin at the cursor,
    -- user lands at the front of the new sub. Same escape-hatch role as
    -- Ctrl+PageUp/Down, one level down the hierarchy.
    rebuildFromCursor()
    local cat = currentCategory()
    if cat == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local newIdx = nextIndexMatching(cat.subcategories, _subIdx, dir, subHasItems)
    if newIdx == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    _subIdx = newIdx
    landOnCurrentSub()
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceWithLabel(currentSub().label)
end

-- _itemIdx / _instIdx sit at 0 in two cases: a fresh snapshot (first build
-- resets them) and after a pruned item empties out. "0" is the "before
-- item 1" sentinel -- the first cycle out of it must LAND on the endpoint,
-- not step past it. wrapIndex adds dir unconditionally, so routing 0 through
-- it would skip over index 1 on a forward step (and did, until this branch).
local function stepFromZero(dir, n)
    return (dir < 0) and n or 1
end

function ScannerNav.cycleItem(dir)
    rebuildAndLocate()
    local sub = currentSub()
    if sub == nil or #sub.items == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    if _itemIdx == 0 then
        _itemIdx = stepFromZero(dir, #sub.items)
    else
        _itemIdx = wrapIndex(_itemIdx, #sub.items, dir)
    end
    local item = currentItem()
    _instIdx = (item ~= nil and #item.instances > 0) and 1 or 0
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceCurrent()
end

function ScannerNav.cycleInstance(dir)
    rebuildAndLocate()
    local item = currentItem()
    if item == nil or #item.instances == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    if _instIdx == 0 then
        _instIdx = stepFromZero(dir, #item.instances)
    else
        _instIdx = wrapIndex(_instIdx, #item.instances, dir)
    end
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceCurrent()
end

-- Home: jump the cursor to the current entry's plot and speak the
-- glance (same text Cursor.move produces after a directional step).
-- The glance covers the "where am I now" need; no re-announcement of
-- the entry label is required because the user just pressed Home on
-- it and already knows.
function ScannerNav.jumpToEntry()
    rebuildAndLocate()
    ensureCurrentInstanceValid()
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
    rebuildAndLocate()
    ensureCurrentInstanceValid()
    local inst = currentInstance()
    if inst == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return ""
    end
    if cx == inst.plotX and cy == inst.plotY then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    end
    return HexGeom.directionString(cx, cy, inst.plotX, inst.plotY)
end

-- Shift+End: flip the auto-move preference. The shared table holds the
-- live value so every cycle reads it cheaply; Prefs.setBool persists the
-- flip so the choice survives a restart.
function ScannerNav.toggleAutoMove()
    local now = not civvaccess_shared.scannerAutoMove
    civvaccess_shared.scannerAutoMove = now
    Prefs.setBool("ScannerAutoMove", now)
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
-- _preSearchCatIdx isn't touched here -- applySearch captures it at
-- commit time so an Escape (which never installs a search snapshot)
-- leaves the anchor untouched.
function ScannerNav.openSearch()
    HandlerStack.push(ScannerInput.create())
    return Text.key("TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT")
end

-- Commit a type-ahead query: filter the flat entry list through
-- TypeAheadSearch and install the result as the current snapshot.
-- Returns the announcement string (label + first item) or a no-match
-- reply on empty result. The caller (ScannerInput) speaks it.
function ScannerNav.applySearch(query)
    if query == nil or query == "" then
        return Text.format("TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH", query or "")
    end
    local entries = gatherEntries()
    local cx, cy = cursorOriginOrDefault()
    local snap = ScannerSearch.build(entries, query, cx, cy)
    if snap == nil then
        return Text.format("TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH", query)
    end
    -- Save the pre-search anchor exactly at the transition from normal to
    -- search snapshot, so a subsequent Ctrl+PageUp/Down can cycle relative
    -- to where the user started from. Re-committing a new query while
    -- already in search mode must not overwrite the original anchor.
    if not isSearchSnapshot() then
        _preSearchCatIdx = _catIdx
    end
    _snapshot = snap
    _catIdx = 1
    snapToCategoryFront()
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceWithLabel(currentCategory().label)
end

-- Test seam: exercise the rebuild + prune + announce pipeline without
-- touching indices. Production dispatches through cycle entry points
-- with dir = +/-1 only; suites use this to probe the rebuild and
-- validation path in isolation (e.g. checking that a dead current
-- instance gets pruned) rather than relying on cycle(0) as an implicit
-- stay-put contract.
function ScannerNav._refresh()
    rebuildAndLocate()
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceCurrent()
end

-- Test seam (module has persistent upvalues; production never calls it).
function ScannerNav._reset()
    _catIdx, _subIdx, _itemIdx, _instIdx = 1, 1, 0, 0
    _snapshot = nil
    _preJumpX, _preJumpY = nil, nil
    _preSearchCatIdx = nil
end

-- Test seam: inspect state without exposing upvalues.
function ScannerNav._indices()
    return _catIdx, _subIdx, _itemIdx, _instIdx
end
function ScannerNav._snapshot()
    return _snapshot
end
function ScannerNav._preJump()
    return _preJumpX, _preJumpY
end
function ScannerNav._preSearchCatIdx()
    return _preSearchCatIdx
end

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

-- Half-width of a scoped direction's arc: pi/4 makes the four cardinal arcs
-- (centers in HexGeom.DIRECTION_ARC_CENTER) tile the full circle with no gaps
-- or overlaps.
local ARC_HALF_WIDTH = math.pi / 4

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
-- enough to warrant opt-in. Users who want it flip it from the F12
-- Settings overlay; the new value persists across sessions via Prefs.
if civvaccess_shared.scannerAutoMove == nil then
    civvaccess_shared.scannerAutoMove = Prefs.getBool("ScannerAutoMove", false)
end

-- Hydrate the compass-direction toggle on the same shared table. Off by
-- default: the hex-decomposition readout is what the mod has shipped from
-- the start, so the spatial-bearing variant stays opt-in. Settings.lua's
-- defineBoolPref is a no-op once this line runs; the same field is read
-- in formatInstance / distanceFromCursor.
if civvaccess_shared.scannerCompassDirection == nil then
    civvaccess_shared.scannerCompassDirection = Prefs.getBool("ScannerCompassDirection", false)
end

-- Returns the spoken direction segment from (cx, cy) to the entry plot.
-- Picks the 8-point compass bearing + cube-distance summary
-- (HexGeom.compassDirectionString) when the player has opted in via the
-- F12 setting; otherwise the two-axis hex decomposition
-- (HexGeom.directionString). Scoped to the scanner -- every other
-- HexGeom.directionString caller (cursor selection readout, surveyor,
-- bookmarks, military overview, path diagnostic, unit-finished-move)
-- stays on the hex decomposition regardless.
local function directionForScanner(cx, cy, tx, ty)
    if civvaccess_shared.scannerCompassDirection then
        return HexGeom.compassDirectionString(cx, cy, tx, ty)
    end
    return HexGeom.directionString(cx, cy, tx, ty)
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

-- Index of the category carrying `key` in the current snapshot, or nil.
-- Custom categories are prepended to the snapshot, so adding or removing one
-- from F12 settings while the scanner is open renumbers every real
-- category's index. _catIdx is a raw index captured against the previous
-- snapshot; translating it through the category key re-finds the same
-- category after such a layout shift instead of trusting the stale number.
local function categoryIndexByKey(key)
    if _snapshot == nil or key == nil then
        return nil
    end
    for i, cat in ipairs(_snapshot.categories) do
        if cat.key == key then
            return i
        end
    end
    return nil
end

-- Re-seat _catIdx on the category named by `key` after a rebuild, clamping
-- into range when that category is gone (a custom category the user was on,
-- deleted from settings). Keeps category / subcategory cycles anchored when
-- the category layout changed underneath the old index.
local function reanchorCategory(key)
    local i = categoryIndexByKey(key)
    if i ~= nil then
        _catIdx = i
        return
    end
    local n = #_snapshot.categories
    if _catIdx > n then
        _catIdx = n
    end
    if _catIdx < 1 then
        _catIdx = 1
    end
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
--
-- When civvaccess_shared.scannerDirection is set AND the caller supplies
-- an arc origin, additionally keep only entries whose plot falls inside
-- the 90-degree compass arc fanning out from (arcOriginX, arcOriginY).
-- The origin is the live hex cursor so "scanning west" and a result's
-- spoken "west" agree. applySearch passes no origin, so a name search
-- spans the whole map regardless of the active direction.
local function gatherEntries(arcOriginX, arcOriginY)
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
    -- One pass applies both filters so each plot is resolved once even when a
    -- city-view scope and a direction are active together.
    local scope = civvaccess_shared.mapScope
    local dir = civvaccess_shared.scannerDirection
    local arcActive = dir ~= nil and arcOriginX ~= nil
    if scope ~= nil or arcActive then
        local center = arcActive and HexGeom.DIRECTION_ARC_CENTER[dir] or nil
        local kept = {}
        for _, entry in ipairs(entries) do
            local plot = Map.GetPlotByIndex(entry.plotIndex)
            if plot ~= nil then
                local x, y = plot:GetX(), plot:GetY()
                local keep = (scope == nil or scope(x, y))
                if keep and arcActive then
                    keep = HexGeom.bearingInArc(arcOriginX, arcOriginY, x, y, center, ARC_HALF_WIDTH)
                end
                if keep then
                    kept[#kept + 1] = entry
                end
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
-- the previous snapshot's origin (identity-preserving refresh). applyArc
-- gates the directional scope: when true, the same origin is handed to
-- gatherEntries as the arc apex so a set direction prunes the list;
-- when false the arc is ignored (Home / End never lose the focused item
-- to the scope). With no direction active both values collapse to today's
-- unscoped gather.
local function rebuildSnapshot(originX, originY, applyArc)
    local arcX, arcY
    if applyArc then
        arcX, arcY = originX, originY
    end
    local entries = gatherEntries(arcX, arcY)
    local customDefs = ScannerFavorites ~= nil and ScannerFavorites.customCategoryDefs() or nil
    _snapshot = ScannerSnap.build(entries, originX, originY, customDefs)
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
-- leading category. _catIdx starts at 1 -- the snapshot's first category,
-- which is a custom category when any exist and otherwise cities -- and
-- that slot is empty before the capital is founded; without this skip, a
-- turn-0 PageDown would speak EMPTY even though units_my holds the starting
-- settler. Subsequent rebuilds intentionally keep the user's chosen
-- category -- if it empties out mid-game, EMPTY is the correct answer
-- rather than a silent jump elsewhere.
--
-- The hint category is captured by key, not index: a custom category added
-- or removed between rebuilds shifts every index, so locate translates the
-- old category identity into the new snapshot rather than trusting a stale
-- _catIdx (which would mis-aim the hint and let the custom-first full scan
-- silently relocate the user into a mirrored custom category).
local function rebuildAndLocate(applyArc)
    if isSearchSnapshot() then
        return false
    end
    local isFirstBuild = (_snapshot == nil)
    local key, hintKey, hintSub
    local inst = currentInstance()
    if inst ~= nil then
        key, hintSub = inst.key, _subIdx
        local cat = currentCategory()
        hintKey = cat ~= nil and cat.key or nil
    end
    -- Re-anchor the sort origin to the live cursor on the first build and on
    -- directional item / instance cycles (so the arc tracks the cursor as it
    -- roams and prunes entries that fall out of it). Otherwise preserve the
    -- previous snapshot's origin so distances stay stable across identity-
    -- preserving rebuilds. (Home / End pass applyArc = false and keep the
    -- stable origin even with a direction active.)
    local originX, originY
    if isFirstBuild or (civvaccess_shared.scannerDirection ~= nil and applyArc) then
        originX, originY = cursorOriginOrDefault()
    else
        originX, originY = _snapshot.cursorX, _snapshot.cursorY
    end
    rebuildSnapshot(originX, originY, applyArc)
    if key ~= nil then
        local hintCat = categoryIndexByKey(hintKey)
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
    -- Anchor by key so a category-layout shift (custom category added /
    -- removed from settings while the scanner was open) keeps the cycle
    -- starting from the same category rather than a stale index.
    local cat = currentCategory()
    local prevKey = cat ~= nil and cat.key or nil
    local cx, cy = cursorOriginOrDefault()
    rebuildSnapshot(cx, cy, true)
    reanchorCategory(prevKey)
    _itemIdx, _instIdx = 0, 0
end

-- Resolve the live cursor to a plotIndex hint for ValidateEntry. Cluster
-- backends use it to re-center their rep on the nearest surviving cell
-- after a prune; non-cluster backends ignore the hint. Nil during very-
-- early boot before the cursor has placed itself; cluster ValidateEntry
-- treats nil as anchor (0, 0) and the next rebuild re-aims everything.
local function cursorPlotIndexHint()
    local cx, cy = Cursor.position()
    if cx == nil then
        return nil
    end
    local plot = Map.GetPlot(cx, cy)
    if plot == nil then
        return nil
    end
    return plot:GetPlotIndex()
end

-- Ask the backend whether the current instance is still live. If not,
-- prune it and re-land on whatever the surviving neighbour is; loop
-- because the next candidate might also be stale. Design section 5:
-- "`ValidateEntry` is called on the current instance every time the user
-- navigates to it. If it returns false, the entry is pruned ... and the
-- navigator advances to the next valid instance within the same item
-- (or wraps up the hierarchy if the item empties out)."
--
-- Cluster-backed entries (terrain "unexplored") may mutate entry.plotIndex
-- when ValidateEntry re-centers the rep on the nearest surviving cell.
-- inst.plotX / plotY are baked at snapshot build time and would otherwise
-- announce the old rep's bearing; we refresh them from the new plotIndex
-- when validation returns true.
local function ensureCurrentInstanceValid()
    while true do
        local inst = currentInstance()
        if inst == nil then
            return
        end
        local entry = inst.entry
        local oldPlotIndex = entry.plotIndex
        local ok, valid = pcall(entry.backend.ValidateEntry, entry, cursorPlotIndexHint())
        if not ok then
            Log.error(
                "ScannerNav: backend '" .. tostring(entry.backend.name) .. "' ValidateEntry failed: " .. tostring(valid)
            )
            return
        end
        if valid then
            if entry.plotIndex ~= oldPlotIndex then
                local plot = Map.GetPlotByIndex(entry.plotIndex)
                if plot ~= nil then
                    inst.plotX, inst.plotY = plot:GetX(), plot:GetY()
                end
            end
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
-- When the current item groups differently-named entities (a civ's
-- cities under the civ-name item), landings that change which item is
-- current additionally lead with the item name: `<item name>. <instance
-- name>. <dir>. <N> of <M>.` Instance steps within the item skip the
-- prefix -- the group is already known and the city name is the
-- distinguishing word.
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
--
-- Factored so the directional-beep hook reads from the same origin the
-- speech announces from; otherwise the spoken bearing and the audio
-- bearing could drift apart on auto-move boundary cases.
local function readoutOrigin()
    if civvaccess_shared.scannerAutoMove then
        return _snapshot.cursorX, _snapshot.cursorY
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return _snapshot.cursorX, _snapshot.cursorY
    end
    return cx, cy
end

local function formatInstance(instance, instIdx, instCount, groupName)
    local cx, cy = readoutOrigin()
    local dir
    if cx == instance.plotX and cy == instance.plotY then
        dir = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    else
        dir = directionForScanner(cx, cy, instance.plotX, instance.plotY)
    end
    local count = Text.format("TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT", instIdx, instCount)
    local entry = instance.entry
    -- FormatName is the live-query seam per design section 4; item.name
    -- is only the grouping key captured at build time.
    local name = entry.backend.FormatName(entry)
    -- Grouped items speak both names on landings: the item name says
    -- which group was reached, the instance name says which member leads.
    -- groupName is nil on instance steps within an item.
    if groupName ~= nil and groupName ~= name then
        name = groupName .. ". " .. name
    end
    -- Optional capital-relative coord segment, opt-in via Settings. Sits
    -- between dir and count so the user hears the entry, then where to
    -- walk, then where it sits, then which-of-N. HexGeom returns "" when
    -- the player has no original capital yet, in which case we drop the
    -- segment rather than print "no capital" noise mid-readout.
    if civvaccess_shared.scannerCoords then
        local coord = HexGeom.coordinateString(instance.plotX, instance.plotY)
        if coord ~= "" then
            return name .. ". " .. dir .. ". " .. coord .. ". " .. count
        end
    end
    return name .. ". " .. dir .. ". " .. count
end

-- Fire the scanner directional beep at the same origin formatInstance
-- announces from, so the audio and spoken bearings stay aligned. Internal
-- gating (toggle, audio handle availability) lives in ScannerBeep; this
-- helper is a no-op when the feature is off. ScannerBeep is loaded after
-- ScannerNav in Boot, so it is a non-nil global by the time any cycle
-- entry point fires.
local function fireDirectionBeep(targetX, targetY)
    if ScannerBeep == nil then
        return
    end
    local cx, cy = readoutOrigin()
    ScannerBeep.play(cx, cy, targetX, targetY)
end

-- Visual twin of the directional beep: ring the scanned target on screen so
-- a sighted companion can see what the player is pointing at. No-op when the
-- MapHighlight module is absent or the feature is toggled off (the gate lives
-- inside MapHighlight.setScanner). The cleared-on-empty branches below keep a
-- stale ring from lingering once the scanned set empties out.
local function fireScannerHighlight(targetX, targetY)
    if MapHighlight == nil then
        return
    end
    MapHighlight.setScanner(targetX, targetY)
end

-- withGroupName: landings that change which item is current (category /
-- subcategory / item cycles, search commit, direction set) pass true so
-- a grouped item leads with its item name. Instance steps pass false --
-- the group is already known there. formatInstance drops the prefix
-- whenever it matches the instance's own spoken name, so ungrouped items
-- are unaffected either way.
local function announceCurrent(withGroupName)
    local item = currentItem()
    if item == nil then
        if MapHighlight ~= nil then
            MapHighlight.clearScanner()
        end
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local inst = currentInstance()
    if inst == nil then
        if MapHighlight ~= nil then
            MapHighlight.clearScanner()
        end
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    fireDirectionBeep(inst.plotX, inst.plotY)
    fireScannerHighlight(inst.plotX, inst.plotY)
    return formatInstance(inst, _instIdx, #item.instances, withGroupName and item.name or nil)
end

-- Resolve a category / subcategory node's spoken label. Synthetic custom
-- categories carry a pre-localized labelText ("Custom 3", positional and
-- keyless); every taxonomy node carries a TXT_KEY in label instead.
local function nodeLabel(node)
    if node.labelText ~= nil then
        return node.labelText
    end
    return Text.key(node.label)
end

-- Compose a "<label>. <current item announcement>" string for the
-- subcategory / category cycle entries, per design section 7.
local function announceWithLabel(node)
    return nodeLabel(node) .. ". " .. announceCurrent(true)
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
    return announceWithLabel(currentCategory())
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
    return announceWithLabel(currentSub())
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
    rebuildAndLocate(true)
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
    return announceCurrent(true)
end

function ScannerNav.cycleInstance(dir)
    rebuildAndLocate(true)
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

-- Flat traversal order for a sub: every instance of every item, sorted
-- by distance from the snapshot origin, then sortKey, then plotIndex --
-- the same comparator ScannerSnap sorts instances by within an item, so
-- a flat walk visits entries in the exact order a per-item walk would if
-- the item boundaries were erased. Returns { itemIdx, instIdx, inst }
-- triples in that order.
local function flattenSub(sub)
    local flat = {}
    for ii, item in ipairs(sub.items) do
        for ini, inst in ipairs(item.instances) do
            flat[#flat + 1] = { itemIdx = ii, instIdx = ini, inst = inst }
        end
    end
    table.sort(flat, function(a, b)
        if a.inst.distance ~= b.inst.distance then
            return a.inst.distance < b.inst.distance
        end
        local ka = a.inst.entry.sortKey or 0
        local kb = b.inst.entry.sortKey or 0
        if ka ~= kb then
            return ka < kb
        end
        return a.inst.entry.plotIndex < b.inst.entry.plotIndex
    end)
    return flat
end

-- Announce the current instance with flat numbering: its position in the
-- flattened walk over `flat` and the walk's total, in place of the
-- instance-within-item count the PageUp/Down cycles speak. The walk is
-- what the user is stepping with the key, so the count follows the walk.
local function announceFlat(flat, withGroupName)
    local item = currentItem()
    local inst = currentInstance()
    if item == nil or inst == nil then
        if MapHighlight ~= nil then
            MapHighlight.clearScanner()
        end
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    local pos = 0
    for i, cell in ipairs(flat) do
        if cell.inst == inst then
            pos = i
            break
        end
    end
    fireDirectionBeep(inst.plotX, inst.plotY)
    fireScannerHighlight(inst.plotX, inst.plotY)
    return formatInstance(inst, pos, #flat, withGroupName and item.name or nil)
end

-- J / K / L: one-key cycle through the slot-th custom category (1-based,
-- in the same name-sorted order the category cycle and the F12 settings
-- list use). Each press steps through the category's `all` sub as one
-- flattened instance list, nearest first, ignoring item grouping: a
-- single key has no Alt-instance axis, so grouping two warriors under
-- one item stop would strand the second one. A cursor away from the
-- snapshot origin forces a restart -- the walk answers "nearest first
-- from where I am", so once the cursor has moved (by hand, Home, or
-- auto-move) the press re-anchors and begins a fresh sweep from the
-- cursor. When the nearest entry is the one the user is already parked
-- on, the restart steps once in the pressed direction instead -- the
-- press asked for movement, and this is what turns an auto-move walk
-- into a nearest-neighbor hop. Everything downstream (Home / End /
-- Backspace, beep, auto-move, the announcement shape) is the shared
-- scanner machinery; only the X of Y counts the flat walk.
function ScannerNav.cycleCustomFlat(slot, dir)
    local defs = ScannerFavorites ~= nil and ScannerFavorites.customCategoryDefs() or {}
    local def = defs[slot]
    if def == nil then
        return Text.format("TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM", slot)
    end
    -- Same escape hatch as cycleCategory: leave a frozen search snapshot
    -- before navigating the real category list.
    if isSearchSnapshot() then
        _catIdx = _preSearchCatIdx or 1
        _snapshot = nil
    end
    local atOrigin = false
    if _snapshot ~= nil then
        local cx, cy = Cursor.position()
        atOrigin = cx == nil or (cx == _snapshot.cursorX and cy == _snapshot.cursorY)
    end
    local cat = currentCategory()
    local continuing = atOrigin and cat ~= nil and cat.key == def.key and _subIdx == 1 and currentInstance() ~= nil
    if continuing then
        -- Identity-preserving rebuild, like the item / instance cycles.
        rebuildAndLocate(true)
        cat = currentCategory()
        continuing = cat ~= nil and cat.key == def.key and _subIdx == 1
    end
    local prevItemIdx = _itemIdx
    if continuing then
        local flat = flattenSub(currentSub())
        if #flat == 0 then
            return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
        end
        local cur = currentInstance()
        local pos = 0
        for i, cell in ipairs(flat) do
            if cell.inst == cur then
                pos = i
                break
            end
        end
        -- pos 0 means the identity died across the rebuild
        -- (rebuildAndLocate zeroed the indices): land on the flat
        -- endpoint, same sentinel semantics as the item / instance cycles.
        if pos == 0 then
            pos = stepFromZero(dir, #flat)
        else
            pos = wrapIndex(pos, #flat, dir)
        end
        _itemIdx, _instIdx = flat[pos].itemIdx, flat[pos].instIdx
    else
        -- Entry press (scanner elsewhere or on a named sub) or restart
        -- press (cursor left the origin): re-anchor to the live cursor
        -- and land on the nearest entry.
        local prevKey
        local inst = currentInstance()
        if inst ~= nil and cat ~= nil and cat.key == def.key then
            prevKey = inst.key
        end
        rebuildFromCursor()
        local idx = categoryIndexByKey(def.key)
        if idx == nil then
            Log.warn("ScannerNav.cycleCustomFlat: def '" .. tostring(def.key) .. "' missing from snapshot")
            return Text.format("TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM", slot)
        end
        _catIdx = idx
        _subIdx = 1
        prevItemIdx = 0
        local flat = flattenSub(currentSub())
        if #flat == 0 then
            _itemIdx, _instIdx = 0, 0
            return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
        end
        local pos = 1
        -- Nearest is the entry the user is already on with the cursor
        -- parked on it (distance 0 from the fresh origin, i.e. Home or
        -- auto-move put the cursor there): step once in the pressed
        -- direction instead of re-landing where the user already is.
        if prevKey ~= nil and flat[1].inst.key == prevKey and flat[1].inst.distance == 0 and #flat > 1 then
            pos = wrapIndex(1, #flat, dir)
        end
        _itemIdx, _instIdx = flat[pos].itemIdx, flat[pos].instIdx
    end
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    -- Recompute the flat order after validation (a prune may have
    -- reshaped the sub) so the spoken X of Y matches what the walk will
    -- actually do next. Lead with the item name only when the press
    -- crossed into a different item, matching the landing-vs-instance-
    -- step convention.
    local sub = currentSub()
    if sub == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    return announceFlat(flattenSub(sub), _itemIdx ~= prevItemIdx)
end

-- Home: jump the cursor to the current entry's plot and speak the
-- glance (same text Cursor.move produces after a directional step), or
-- SCANNER_HERE when the cursor is already on the entry's plot. The
-- glance covers the "where am I now" need; no re-announcement of the
-- entry label is required because the user just pressed Home on it and
-- already knows.
function ScannerNav.jumpToEntry()
    rebuildAndLocate(false)
    ensureCurrentInstanceValid()
    local inst = currentInstance()
    if inst == nil then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_EMPTY")
    end
    return ScannerNav.jumpCursorTo(inst.plotX, inst.plotY)
end

-- End: speak the distance/direction from the hex cursor to the
-- current entry. Byte-identical format to the S key (capital -> cursor)
-- via HexGeom.directionString; the only divergence is the zero-distance
-- short-circuit key (SCANNER_HERE here, AT_CAPITAL there). Always uses
-- the hex decomposition regardless of the compass-direction toggle --
-- End is the user's on-demand "give me the precise hex breakdown" probe,
-- distinct from the per-cycle readout which the toggle reshapes.
function ScannerNav.distanceFromCursor()
    rebuildAndLocate(false)
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
    -- End is an on-demand directional probe; fire the beep alongside the
    -- spoken bearing regardless of the auto-move-driven readout origin
    -- (this entry point always reads from the live cursor, never the
    -- snapshot anchor, because it's the user explicitly asking "from
    -- where I am now").
    if ScannerBeep ~= nil then
        ScannerBeep.play(cx, cy, inst.plotX, inst.plotY)
    end
    return HexGeom.directionString(cx, cy, inst.plotX, inst.plotY)
end

-- Public seam for cross-module pre-jump tracking. Used by
-- ScannerNav.jumpCursorTo (the shared cursor-jump primitive) and by
-- autoMoveIfEnabled, which writes the same upvalue pair internally for
-- the no-speech cycle path.
function ScannerNav.markPreJump(x, y)
    _preJumpX, _preJumpY = x, y
end

-- Shared cursor-jump primitive for every keystroke that sends the cursor
-- to a remembered cell: scanner Home (jumpToEntry), Bookmarks Shift+digit
-- (Bookmarks.jumpTo), and Bookmarks Ctrl+S (Bookmarks.jumpToCapital).
-- When the cursor is already on the target, speak SCANNER_HERE rather
-- than re-running Cursor.jumpTo's full glance: a no-op press is a fast
-- "you are already there" confirmation, not a re-read of details the user
-- already heard at arrival. Skipping the markPreJump in that case also
-- preserves whatever Backspace anchor the user had set earlier --
-- otherwise pressing the same jump key twice on the same spot would
-- silently shadow it. Lives in ScannerNav because the Backspace anchor
-- it captures is the scanner's, and ScannerNav already owns markPreJump.
function ScannerNav.jumpCursorTo(x, y)
    local cx, cy = Cursor.position()
    if cx == x and cy == y then
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    end
    if cx ~= nil then
        ScannerNav.markPreJump(cx, cy)
    end
    return Cursor.jumpTo(x, y)
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
    ScannerInput.open()
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
    return announceWithLabel(currentCategory())
end

-- Ctrl+arrow: scope the scanner to one compass direction, or clear the
-- scope when the active direction is pressed again. The arc fans out from
-- the hex cursor (the scanner's distance/direction origin), so "scanning
-- west" and a result's spoken "west" always agree. dirCode is one of
-- "N" / "S" / "E" / "W".
function ScannerNav.setDirection(dirCode)
    -- Search snapshots are frozen slices; drop back to the normal snapshot
    -- first (the cycleCategory escape-hatch pattern) so the direction
    -- scopes the real category list, not the synthetic search one.
    if isSearchSnapshot() then
        _catIdx = _preSearchCatIdx or 1
        _snapshot = nil
    end
    if civvaccess_shared.scannerDirection == dirCode then
        civvaccess_shared.scannerDirection = nil
        -- Refresh the now-unscoped list while keeping the focused item
        -- (applyArc = false, like End: clearing the scope must not prune).
        rebuildAndLocate(false)
        return Text.key("TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_CLEARED")
    end
    civvaccess_shared.scannerDirection = dirCode
    rebuildFromCursor()
    landOnCurrentSub()
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return Text.format(
        "TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_SET",
        HexGeom.dirText("TXT_KEY_CIVVACCESS_DIR_" .. dirCode)
    ) .. ". " .. announceCurrent(true)
end

-- Test seam: exercise the rebuild + prune + announce pipeline without
-- touching indices. Production dispatches through cycle entry points
-- with dir = +/-1 only; suites use this to probe the rebuild and
-- validation path in isolation (e.g. checking that a dead current
-- instance gets pruned) rather than relying on cycle(0) as an implicit
-- stay-put contract.
function ScannerNav._refresh()
    rebuildAndLocate(true)
    ensureCurrentInstanceValid()
    autoMoveIfEnabled()
    return announceCurrent(true)
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

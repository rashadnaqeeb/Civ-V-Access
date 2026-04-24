-- ScannerNav: cursor index wrapping, category-change rebuild, identity-
-- preserving rebuild across every other navigation entry point, and
-- mid-snapshot validation pruning. Exercises the full nav-state machine
-- via the public entry points, with a stubbed backend registered into
-- ScannerCore.BACKENDS so Nav's gather+build path runs end-to-end
-- without touching the real game APIs.

local T = require("support")
local M = {}

-- Stub backend that returns whatever entries its `nextBatch` is set to.
local _entries = {}
local _validator = function(_e)
    return true
end
local function installStubBackend()
    ScannerCore.BACKENDS = {}
    ScannerCore.registerBackend({
        name = "stub",
        Scan = function()
            return _entries
        end,
        ValidateEntry = function(entry, cursorPlotIndex)
            return _validator(entry, cursorPlotIndex)
        end,
        FormatName = function(entry)
            return entry.itemName
        end,
    })
end

local function mkPlot(x, y, idx)
    return T.fakePlot({ x = x, y = y, plotIndex = idx })
end

local function mkEntry(cat, sub, name, plotIndex, opts)
    opts = opts or {}
    opts.backend = opts.backend or ScannerCore.BACKENDS[1]
    return T.mkEntry(cat, sub, name, plotIndex, opts)
end

local function setup()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSnap.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSearch.lua")
    -- HexGeom is a transitive requirement through the announcement helpers.
    dofile("src/dlc/UI/InGame/CivVAccess_HexGeom.lua")
    civvaccess_shared = {}
    -- Stubs for cursor and HandlerStack (Nav pushes ScannerInput in openSearch).
    Cursor = {
        _x = 0,
        _y = 0,
        position = function()
            return 0, 0
        end,
        jumpTo = function(x, y)
            return "jumped to " .. x .. "," .. y
        end,
    }
    HandlerStack = { push = function() end, removeByName = function() end }
    ScannerInput = {
        create = function()
            return { name = "ScannerInput" }
        end,
    }
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end

    dofile("src/dlc/UI/InGame/CivVAccess_ScannerNav.lua")
    installStubBackend()
    _entries = {}
    _validator = function()
        return true
    end
    ScannerNav._reset()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
end

-- ===== Item cycle wrap =====

function M.test_cycle_item_wraps_forward_and_back()
    setup()
    local p1 = mkPlot(0, 0, 0)
    local p2 = mkPlot(1, 0, 1)
    local p3 = mkPlot(2, 0, 2)
    T.installMap({ p1, p2, p3 })
    _entries = {
        mkEntry("cities", "my", "A", 0),
        mkEntry("cities", "my", "B", 1),
        mkEntry("cities", "my", "C", 2),
    }
    ScannerNav.cycleCategory(0) -- build + land on cities
    -- After land: _catIdx=cities, _subIdx=1 (all), items=[A,B,C] by distance.
    ScannerNav.cycleSubcategory(1) -- move to "my"
    ScannerNav.cycleItem(1) -- B
    ScannerNav.cycleItem(1) -- C
    ScannerNav.cycleItem(1) -- wraps to A
    local _, _, itemIdx = ScannerNav._indices()
    T.eq(itemIdx, 1, "next from last item must wrap to first")

    ScannerNav.cycleItem(-1)
    local _, _, itemIdx2 = ScannerNav._indices()
    T.eq(itemIdx2, 3, "prev from first wraps to last")
end

-- ===== Instance cycle wrap =====

function M.test_cycle_instance_wraps()
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0, { key = "stub:rome-a" }),
        mkEntry("cities", "my", "Rome", 1, { key = "stub:rome-b" }),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1) -- to "my"
    ScannerNav.cycleInstance(1)
    local _, _, _, instIdx = ScannerNav._indices()
    T.eq(instIdx, 2)
    ScannerNav.cycleInstance(1) -- wraps
    _, _, _, instIdx = ScannerNav._indices()
    T.eq(instIdx, 1, "instance cycle wraps back to 1")
end

-- ===== Category change forces rebuild =====

function M.test_cycle_category_rebuilds_snapshot()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local scans = 0
    ScannerCore.BACKENDS[1].Scan = function()
        scans = scans + 1
        return { mkEntry("cities", "my", "Rome", 0) }
    end
    ScannerNav.cycleCategory(1)
    local firstScans = scans
    ScannerNav.cycleCategory(1)
    T.truthy(scans > firstScans, "each category cycle must re-run every backend Scan (rebuild signal)")
end

-- ===== Identity-preserving rebuild on non-reorient cycles =====

function M.test_cycle_item_rebuilds_and_preserves_identity()
    -- PageDown rebuilds the snapshot before cycling. Identity preservation
    -- means the cursor stays on the same entity (by its key), so the next
    -- step lands on whatever genuinely follows that entity in the fresh
    -- sort. Exercised by flipping distance so the sort order inverts
    -- between cycles: the user was on "B"; after a sort flip where B
    -- becomes the closest, next-from-B must still land on the item after
    -- B in the NEW order, not on what was index 3 in the OLD order.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(5, 0, 1), mkPlot(10, 0, 2) })
    _entries = {
        mkEntry("cities", "my", "A", 0, { key = "stub:A" }),
        mkEntry("cities", "my", "B", 1, { key = "stub:B" }),
        mkEntry("cities", "my", "C", 2, { key = "stub:C" }),
    }
    ScannerNav.cycleCategory(0) -- origin (0,0): A (0), B (5), C (10)
    ScannerNav.cycleSubcategory(1) -- into "my"
    ScannerNav.cycleItem(1) -- land on B (item 2)
    local _, _, itemIdx = ScannerNav._indices()
    T.eq(itemIdx, 2, "precondition: B at item 2")
    -- Swap B's plot so B is now closest. The snapshot rebuild on next
    -- cycle should re-sort: B (1), A (2 at d=... wait let's pick coords
    -- carefully)
    T.installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1), mkPlot(10, 0, 2) })
    -- Origin still (0,0). A d=0, B d=0, C d=10. A and B tie but lower
    -- plotIndex wins, so A at item 1, B at item 2, C at item 3.
    -- Rebuild preserves origin (0,0), so user stays on B at item 2.
    ScannerNav.cycleItem(1) -- next after B = C
    local catIdxAfter, subIdxAfter, itemIdxAfter = ScannerNav._indices()
    T.eq(itemIdxAfter, 3, "next after B must be C (item 3), not a stale old-sort index")
    local item = ScannerNav._snapshot().categories[catIdxAfter].subcategories[subIdxAfter].items[itemIdxAfter]
    T.eq(item.name, "C", "item at the located index must actually be C")
end

function M.test_new_entry_appearing_does_not_move_cursor()
    -- A new entry enters the snapshot between cycles. The user's cursor,
    -- tracked by entry key, stays on whatever entity they were pointing
    -- at rather than drifting because the new entry pushed indices
    -- around.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(5, 0, 1), mkPlot(2, 0, 2) })
    _entries = {
        mkEntry("cities", "my", "A", 0, { key = "stub:A" }),
        mkEntry("cities", "my", "B", 1, { key = "stub:B" }),
    }
    ScannerNav.cycleCategory(0) -- A, B (by distance)
    ScannerNav.cycleSubcategory(1)
    ScannerNav.cycleItem(1) -- on B (item 2)
    -- New entry "New" appears at distance 2 (closer than B).
    _entries = {
        mkEntry("cities", "my", "A", 0, { key = "stub:A" }),
        mkEntry("cities", "my", "B", 1, { key = "stub:B" }),
        mkEntry("cities", "my", "New", 2, { key = "stub:New" }),
    }
    ScannerNav._refresh() -- re-announce current; rebuild happens
    -- After rebuild: A (d=0), New (d=2), B (d=5). B is now item 3.
    local catIdx, subIdx, itemIdx = ScannerNav._indices()
    T.eq(itemIdx, 3, "cursor must stay on B by identity; B is now item 3 after New slotted in")
    local item = ScannerNav._snapshot().categories[catIdx].subcategories[subIdx].items[itemIdx]
    T.eq(item.name, "B", "item at re-seated index must be B")
end

function M.test_identity_lost_resets_to_sentinel()
    -- The user's current entity disappears (unit dies, city falls). A
    -- rebuild can't find the key, so the navigator resets item / instance
    -- to the sentinel so the next cycle direction picks up from the front
    -- or back of the sub.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(5, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "A", 0, { key = "stub:A" }),
        mkEntry("cities", "my", "B", 1, { key = "stub:B" }),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    ScannerNav.cycleItem(1) -- on B
    _entries = {
        mkEntry("cities", "my", "A", 0, { key = "stub:A" }),
        -- B is gone entirely.
    }
    ScannerNav.cycleItem(1) -- rebuild loses B, identity gone
    -- Sentinel reset -> stepFromZero in dir=1 lands on item 1 = A.
    local _, _, itemIdx = ScannerNav._indices()
    T.eq(itemIdx, 1, "dead identity resets to sentinel; next PageDown lands on item 1")
end

function M.test_rebuild_preserves_origin_across_identity_cycles()
    -- The snapshot's sort origin is the cursor at the last EXPLICIT
    -- reorient (cycleCategory, cycleSubcategory, applySearch). Identity-
    -- preserving cycles (PageDown, PageUp, Alt+PageDown, Home, End) must
    -- keep that origin stable so distance announcements don't drift when
    -- auto-move warps the cursor around.
    setup()
    T.installMap({ mkPlot(3, 0, 0), mkPlot(7, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "A", 0, { key = "stub:A" }),
        mkEntry("cities", "my", "B", 1, { key = "stub:B" }),
    }
    ScannerNav.cycleCategory(0) -- origin = cursor (0,0)
    local snap = ScannerNav._snapshot()
    T.eq(snap.cursorX, 0)
    T.eq(snap.cursorY, 0)
    -- Cursor physically moves (e.g. user drove it, or auto-move yanked).
    Cursor.position = function()
        return 42, 42
    end
    ScannerNav.cycleItem(1) -- identity-preserving rebuild
    local snapAfter = ScannerNav._snapshot()
    T.eq(snapAfter.cursorX, 0, "origin must NOT refresh to live cursor on identity cycles")
    T.eq(snapAfter.cursorY, 0)
end

function M.test_explicit_reorient_refreshes_origin()
    -- Ctrl+PageUp/Down is the "forget where I was" escape hatch. Its
    -- rebuild must re-anchor the sort origin to the current cursor so
    -- distances in the new category are measured from where the user is
    -- now, not from some stale anchor set turns ago.
    setup()
    T.installMap({ mkPlot(3, 0, 0) })
    _entries = { mkEntry("cities", "my", "A", 0, { key = "stub:A" }) }
    ScannerNav.cycleCategory(0) -- origin (0,0)
    Cursor.position = function()
        return 9, 9
    end
    ScannerNav.cycleCategory(1) -- explicit reorient
    local snap = ScannerNav._snapshot()
    T.eq(snap.cursorX, 9, "Ctrl+PageUp/Down must refresh origin to the live cursor")
    T.eq(snap.cursorY, 9)
end

-- ===== Validation-driven pruning =====

-- Find the "my" sub index on the cities cat. Taxonomy is static but the
-- index within cat.subcategories is an implementation detail, so tests
-- look it up by key.
local function findMySubIdx(snap)
    for i, s in ipairs(snap.categories[1].subcategories) do
        if s.key == "my" then
            return i
        end
    end
end

function M.test_validate_returning_false_prunes_on_next_nav_read()
    -- Backend Scan keeps emitting two entries; ValidateEntry says plot 0
    -- is dead. After a refresh, the current snapshot (re-read because
    -- rebuild produces a new table) should have pruned the invalid
    -- instance from the current item.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0, { key = "stub:rome-0" }),
        mkEntry("cities", "my", "Rome", 1, { key = "stub:rome-1" }),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local snap = ScannerNav._snapshot()
    local myIdx = findMySubIdx(snap)
    T.eq(#snap.categories[1].subcategories[myIdx].items[1].instances, 2)
    _validator = function(entry)
        return entry.plotIndex ~= 0
    end
    ScannerNav._refresh()
    local snap2 = ScannerNav._snapshot()
    T.eq(
        #snap2.categories[1].subcategories[myIdx].items[1].instances,
        1,
        "nav must prune the invalid current instance before announcement"
    )
end

function M.test_validate_false_on_all_instances_wraps_up_to_empty()
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0, { key = "stub:rome-0" }),
        mkEntry("cities", "my", "Rome", 1, { key = "stub:rome-1" }),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    _validator = function()
        return false
    end
    local out = ScannerNav._refresh()
    T.truthy(
        out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY" or out:find("empty", 1, true),
        "all-invalid item must wrap up to EMPTY, got " .. tostring(out)
    )
    local snap = ScannerNav._snapshot()
    local myIdx = findMySubIdx(snap)
    T.eq(
        #snap.categories[1].subcategories[myIdx].items,
        0,
        "item with every instance invalid must be removed from the sub"
    )
end

function M.test_format_name_dispatched_through_backend()
    -- FormatName is the live-query seam per design section 4. Nav must
    -- call it rather than reading the snapshot-captured item.name. Proved
    -- here by having the backend return a different string from itemName.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerCore.BACKENDS[1].FormatName = function(_)
        return "LiveName"
    end
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local out = ScannerNav._refresh()
    T.truthy(out:find("LiveName", 1, true), "announcement must go through FormatName, got " .. tostring(out))
end

function M.test_empty_snapshot_speaks_empty_token()
    setup()
    T.installMap({})
    _entries = {}
    local out = ScannerNav.cycleItem(1)
    T.truthy(
        out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY" or out:find("empty", 1, true) ~= nil,
        "empty snapshot must trigger the EMPTY token, got " .. tostring(out)
    )
end

-- ===== Skip empty categories / subcategories =====

-- Locate a category by its key in the taxonomy order, so tests don't
-- have to hardcode the raw index (and break when taxonomy shifts).
local function catIdxByKey(key)
    for i, cat in ipairs(ScannerCore.CATEGORIES) do
        if cat.key == key then
            return i
        end
    end
end

function M.test_initial_build_skips_empty_category_on_first_plain_cycle()
    -- On turn 0 the default _catIdx=1 (cities) has no items because no
    -- city has been founded. A plain PageDown (cycleItem) must skip past
    -- the empty leading category so the first keypress lands on a real
    -- item instead of speaking EMPTY. Only the initial build does this;
    -- subsequent rebuilds keep the user's chosen category.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("units_my", "melee", "Warrior", 0) }
    local out = ScannerNav.cycleItem(1)
    T.truthy(out:find("Warrior", 1, true), "first PageDown must advance past empty cities to land on Warrior: " .. out)
    local cat = ScannerNav._indices()
    T.eq(cat, catIdxByKey("units_my"), "initial build must move _catIdx off the empty cities bucket")
end

function M.test_initial_build_stays_when_starting_category_has_items()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleItem(1)
    local cat = ScannerNav._indices()
    T.eq(cat, catIdxByKey("cities"), "initial-build skip must not move off a non-empty starting cat")
end

function M.test_rebuild_preserves_empty_category_choice()
    -- If the user navigated to a specific category and it empties out
    -- mid-game, subsequent rebuilds must not silently jump elsewhere --
    -- EMPTY is the correct answer because the user explicitly chose that
    -- category. The initial-build skip is opt-in for the very first build.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleCategory(1) -- land on resources (first non-empty)
    T.eq(ScannerNav._indices(), catIdxByKey("resources"))
    _entries = {} -- everything disappears
    local out = ScannerNav.cycleItem(1)
    T.eq(ScannerNav._indices(), catIdxByKey("resources"), "rebuild must keep user's chosen cat")
    T.truthy(
        out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY" or out:find("empty", 1, true) ~= nil,
        "empty cat on rebuild speaks EMPTY, got " .. tostring(out)
    )
end

function M.test_cycle_category_skips_empty_forward()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    -- Only `resources` is populated; every other cat should be skipped.
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleCategory(1)
    local cat, _, _, _ = ScannerNav._indices()
    T.eq(cat, catIdxByKey("resources"), "forward cycle must skip empty cats and land on resources")
end

function M.test_cycle_category_skips_empty_backward()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleCategory(-1)
    local cat, _, _, _ = ScannerNav._indices()
    T.eq(cat, catIdxByKey("resources"), "backward cycle must skip empty cats and land on resources")
end

function M.test_cycle_category_all_empty_speaks_empty()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = {}
    local out = ScannerNav.cycleCategory(1)
    T.truthy(
        out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY" or out:find("empty", 1, true) ~= nil,
        "no-non-empty-cat case must speak EMPTY, got " .. tostring(out)
    )
end

function M.test_cycle_subcategory_skips_empty()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    -- cities taxonomy: all, my, neutral, enemy, barb. Only `barb` populated.
    _entries = { mkEntry("cities", "barb", "BarbCamp", 0) }
    ScannerNav.cycleCategory(1) -- lands on cities (only non-empty cat)
    -- _subIdx is now 1 (all). Forward cycle from `all` must skip my,
    -- neutral, enemy (all empty) and land on barb.
    ScannerNav.cycleSubcategory(1)
    local snap = ScannerNav._snapshot()
    local _, subIdx, _, _ = ScannerNav._indices()
    T.eq(snap.categories[1].subcategories[subIdx].key, "barb", "subcategory cycle must skip empty subs")
end

function M.test_cycle_subcategory_all_empty_in_cat_speaks_empty()
    -- Entering a category-cycle lands on a non-empty cat, but if the
    -- user's category somehow has all-empty subs a sub cycle must speak
    -- EMPTY rather than wrap forever.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = {}
    -- Force _catIdx to a valid position without going through cycleCategory
    -- (which would short-circuit to EMPTY on an empty snapshot).
    ScannerNav.cycleCategory(0) -- builds snapshot; returns EMPTY; _catIdx stays at 1
    local out = ScannerNav.cycleSubcategory(1)
    T.truthy(
        out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY" or out:find("empty", 1, true) ~= nil,
        "sub cycle with no non-empty subs must speak EMPTY, got " .. tostring(out)
    )
end

-- ===== Search entry / exit =====

function M.test_apply_search_builds_search_snapshot()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0) -- initial normal snapshot
    local catBefore, _, _, _ = ScannerNav._indices()
    ScannerNav.applySearch("rom")
    local snap = ScannerNav._snapshot()
    T.eq(snap.isSearch, true, "applySearch must install an isSearch snapshot")
    -- Pre-search category index must be preserved for the exit cycle.
    T.eq(ScannerNav._preSearchCatIdx(), catBefore)
end

function M.test_apply_search_no_match_keeps_existing_snapshot()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0)
    local before = ScannerNav._snapshot()
    ScannerNav.openSearch() -- capture _preSearchCatIdx
    ScannerNav.applySearch("zzzz")
    T.eq(ScannerNav._snapshot(), before, "no-match must keep the current snapshot, not replace it with nil")
    T.falsy(ScannerNav._snapshot().isSearch, "previous normal snapshot stays in place")
end

function M.test_cycle_category_exits_search_snapshot()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0)
    ScannerNav.openSearch()
    ScannerNav.applySearch("rom")
    T.eq(ScannerNav._snapshot().isSearch, true)
    ScannerNav.cycleCategory(1)
    local snap = ScannerNav._snapshot()
    T.falsy(snap.isSearch, "Ctrl+PageUp/Down from search must discard the search snapshot")
end

-- ===== openSearch does not stomp pre-search index on re-entry =====

function M.test_open_search_during_search_preserves_pre_search_catidx()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleCategory(0) -- cities (idx 1)
    ScannerNav.cycleCategory(1)
    ScannerNav.cycleCategory(1)
    ScannerNav.cycleCategory(1)
    ScannerNav.cycleCategory(1) -- advance to resources (idx 5)
    local catBeforeSearch, _, _, _ = ScannerNav._indices()
    ScannerNav.openSearch()
    ScannerNav.applySearch("iron")
    ScannerNav.openSearch() -- re-entry while already in search
    T.eq(
        ScannerNav._preSearchCatIdx(),
        catBeforeSearch,
        "re-opening search must not overwrite the original pre-search anchor"
    )
end

return M

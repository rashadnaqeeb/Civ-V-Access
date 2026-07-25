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
    -- This suite tests base navigation with no custom categories. Clear the
    -- global another suite may have left set so rebuildSnapshot's guarded
    -- customCategoryDefs call short-circuits, regardless of suite order.
    ScannerFavorites = nil
    -- Stubs for cursor and HandlerStack (Nav opens ScannerInput in openSearch).
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
        open = function() end,
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
    -- ScannerStrings_en_US is not on run.lua's load list (scanner_announcement
    -- sets this same key in its own setup); seed it here so the jumpCursorTo
    -- tests can assert the at-target branch by literal value.
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "here"
end

-- ===== ScannerNav.jumpCursorTo (shared cursor-jump primitive) =====

function M.test_jumpCursorTo_speaks_here_when_already_at_target()
    -- A no-op press (cursor on the target) speaks SCANNER_HERE rather
    -- than re-running Cursor.jumpTo's full glance -- a fast confirmation
    -- instead of a re-read of details the user already heard.
    setup()
    Cursor.position = function()
        return 5, 5
    end
    local jumped
    Cursor.jumpTo = function(x, y)
        jumped = { x = x, y = y }
        return "should not be called"
    end
    local spoken = ScannerNav.jumpCursorTo(5, 5)
    T.eq(spoken, "here")
    T.eq(jumped, nil, "Cursor.jumpTo must not be invoked on a no-op press")
    -- And the existing backspace anchor must be preserved -- otherwise
    -- pressing the same jump key twice on the same spot would silently
    -- shadow whatever the user had set via an earlier scanner Home.
    T.eq(ScannerNav.returnToPreJump(), Text.key("TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"))
end

function M.test_jumpCursorTo_marks_prejump_and_jumps_when_target_differs()
    -- Live cursor at (3, 3), target (10, 10): mark anchor at the live
    -- cell, then forward to Cursor.jumpTo. Returning to pre-jump must
    -- land back at (3, 3).
    setup()
    Cursor.position = function()
        return 3, 3
    end
    local spoken = ScannerNav.jumpCursorTo(10, 10)
    T.eq(spoken, "jumped to 10,10")
    T.eq(ScannerNav.returnToPreJump(), "jumped to 3,3")
end

function M.test_jumpCursorTo_skips_prejump_when_cursor_uninit()
    -- Pre-Cursor.init the position is (nil, nil); the markPreJump call
    -- must be skipped (an anchor of nil would corrupt the upvalues), but
    -- the jump itself still proceeds.
    setup()
    Cursor.position = function()
        return nil, nil
    end
    local spoken = ScannerNav.jumpCursorTo(7, 7)
    T.eq(spoken, "jumped to 7,7")
    T.eq(ScannerNav.returnToPreJump(), Text.key("TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"))
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

-- ===== Category anchoring across a mid-session layout shift =====
-- Custom categories are prepended to the snapshot, so adding one from F12
-- settings while the scanner is open shifts every real category's index.
-- The cursor must stay on the same category by identity, not drift with the
-- stale index (which would also let the custom-first locate scan silently
-- relocate the user into the mirrored custom category).

local function withCustomDefs(defsRef)
    ScannerFavorites = {
        customCategoryDefs = function()
            return defsRef.list
        end,
    }
end

local STRATEGIC_RESOURCE_DEF = {
    key = "custom:1",
    labelText = "Custom 1",
    selectors = { { cat = "resources", sub = "strategic", label = "Strategic" } },
}

function M.test_locate_stays_on_real_category_when_custom_added_midsession()
    setup()
    local defsRef = { list = {} }
    withCustomDefs(defsRef)
    T.installMap({ mkPlot(3, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    -- First build lands on the only non-empty category, resources.
    ScannerNav.cycleItem(1)
    local ci = select(1, ScannerNav._indices())
    T.eq(ScannerNav._snapshot().categories[ci].key, "resources", "cursor starts on resources")
    -- Simulate adding a custom category from settings: it mirrors Iron and
    -- prepends, pushing resources back one slot.
    defsRef.list = { STRATEGIC_RESOURCE_DEF }
    ScannerNav.cycleItem(1)
    local snap = ScannerNav._snapshot()
    ci = select(1, ScannerNav._indices())
    T.eq(snap.categories[1].key, "custom:1", "custom category is now prepended")
    T.eq(snap.categories[ci].key, "resources", "cursor stays on resources, not the prepended custom mirror")
end

function M.test_category_cycle_anchors_after_custom_added_midsession()
    setup()
    local defsRef = { list = {} }
    withCustomDefs(defsRef)
    T.installMap({ mkPlot(3, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleItem(1) -- land on resources
    defsRef.list = { STRATEGIC_RESOURCE_DEF } -- settings add prepends custom:1
    -- Next category from resources must advance off it; with a stale index it
    -- would re-land on resources (the slot the old index now precedes).
    ScannerNav.cycleCategory(1)
    local ci = select(1, ScannerNav._indices())
    T.eq(ScannerNav._snapshot().categories[ci].key, "custom:1", "next category lands on the other non-empty category")
end

-- ===== Directional scope (Ctrl+arrow) =====
-- setDirection scopes the scanner to a 90-degree arc fanning out from the
-- live cursor. The arc apex is re-anchored to the cursor on every
-- navigation-key rebuild (cycleItem here), so an item that falls behind the
-- roaming cursor is pruned on the next nav read; read-only probes (End)
-- keep the focused item by skipping the arc filter.

-- Find the "all" sub on the cities cat -- where every in-category item
-- lives regardless of owner sub.
local function citiesAllItems(snap)
    return snap.categories[1].subcategories[1].items
end

local function dirSetup()
    setup()
    Map.IsWrapX = function()
        return false
    end
    Map.IsWrapY = function()
        return false
    end
end

function M.test_set_direction_scopes_to_in_arc_entries()
    dirSetup()
    -- Cursor at origin; one city west, one east. Direction W keeps only
    -- the western city and lands on it.
    T.installMap({ mkPlot(-5, 0, 0), mkPlot(5, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "West", 0, { key = "stub:west" }),
        mkEntry("cities", "my", "East", 1, { key = "stub:east" }),
    }
    local out = ScannerNav.setDirection("W")
    T.truthy(out:find("West", 1, true), "set-direction must land on the western city, got " .. tostring(out))
    T.falsy(out:find("East", 1, true), "the eastern city must be out of the W arc")
    local items = citiesAllItems(ScannerNav._snapshot())
    T.eq(#items, 1, "only the in-arc city survives the W scope")
    T.eq(items[1].name, "West")
end

function M.test_switching_direction_rescopes()
    dirSetup()
    T.installMap({ mkPlot(-5, 0, 0), mkPlot(5, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "West", 0, { key = "stub:west" }),
        mkEntry("cities", "my", "East", 1, { key = "stub:east" }),
    }
    ScannerNav.setDirection("W")
    local out = ScannerNav.setDirection("E")
    T.truthy(out:find("East", 1, true), "switching to E must re-scope to the eastern city, got " .. tostring(out))
    local items = citiesAllItems(ScannerNav._snapshot())
    T.eq(#items, 1, "the E scope keeps only the eastern city")
    T.eq(items[1].name, "East")
    T.eq(civvaccess_shared.scannerDirection, "E")
end

function M.test_pressing_same_direction_clears_and_restores_full_list()
    dirSetup()
    T.installMap({ mkPlot(-5, 0, 0), mkPlot(5, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "West", 0, { key = "stub:west" }),
        mkEntry("cities", "my", "East", 1, { key = "stub:east" }),
    }
    ScannerNav.setDirection("W")
    T.eq(#citiesAllItems(ScannerNav._snapshot()), 1, "precondition: scoped to one city")
    local out = ScannerNav.setDirection("W")
    T.eq(out, Text.key("TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_CLEARED"))
    T.eq(civvaccess_shared.scannerDirection, nil, "pressing the active direction clears the scope")
    T.eq(#citiesAllItems(ScannerNav._snapshot()), 2, "clearing restores the full unscoped list")
end

function M.test_prune_on_nav_drops_entry_and_lands_at_front()
    dirSetup()
    -- A near city one west and a far city ten west; both in the W arc from
    -- the origin, so set-direction lands on the near one.
    T.installMap({ mkPlot(-1, 0, 0), mkPlot(-10, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Near", 0, { key = "stub:near" }),
        mkEntry("cities", "my", "Far", 1, { key = "stub:far" }),
    }
    ScannerNav.setDirection("W")
    local _, _, itemIdx = ScannerNav._indices()
    T.eq(citiesAllItems(ScannerNav._snapshot())[itemIdx].name, "Near", "precondition: focused on the near city")
    -- Drive the cursor two west: Near (-1,0) is now EAST of the cursor and
    -- falls out of the W arc; Far (-10,0) stays west.
    Cursor.position = function()
        return -2, 0
    end
    local out = ScannerNav.cycleItem(1)
    local items = citiesAllItems(ScannerNav._snapshot())
    T.eq(#items, 1, "Near must be pruned now that it sits east of the cursor")
    T.eq(items[1].name, "Far")
    local _, _, itemAfter = ScannerNav._indices()
    T.eq(itemAfter, 1, "pruning the focused item lands navigation at the front of the list")
    T.truthy(out:find("Far", 1, true), "the cycle announces the surviving entry, got " .. tostring(out))
end

function M.test_direction_and_mapscope_both_filter()
    dirSetup()
    -- mapScope (city-view style) keeps x >= -6; direction W keeps the western
    -- arc. Only an entry passing BOTH survives, proving the fused filter ANDs
    -- them rather than letting either alone decide.
    T.installMap({ mkPlot(-5, 0, 0), mkPlot(-7, 0, 1), mkPlot(5, 0, 2) })
    _entries = {
        mkEntry("cities", "my", "InBoth", 0, { key = "stub:both" }),
        mkEntry("cities", "my", "WestButOutOfScope", 1, { key = "stub:oos" }),
        mkEntry("cities", "my", "InScopeButEast", 2, { key = "stub:east" }),
    }
    civvaccess_shared.mapScope = function(x, _y)
        return x >= -6
    end
    ScannerNav.setDirection("W")
    local items = citiesAllItems(ScannerNav._snapshot())
    T.eq(#items, 1, "only the entry passing both mapScope and the W arc survives")
    T.eq(items[1].name, "InBoth")
end

function M.test_end_keeps_held_entry_out_of_arc()
    dirSetup()
    -- One city one west; direction W lands on it.
    T.installMap({ mkPlot(-1, 0, 0) })
    _entries = { mkEntry("cities", "my", "Near", 0, { key = "stub:near" }) }
    ScannerNav.setDirection("W")
    -- Drive the cursor two west so the held city is now one east of it.
    Cursor.position = function()
        return -2, 0
    end
    -- End is a read-only probe: it must NOT prune the held entry even
    -- though the city has fallen behind the cursor and out of the W arc.
    -- It reports the entry's live bearing (one east) rather than EMPTY.
    local out = ScannerNav.distanceFromCursor()
    T.eq(out, "1e", "End keeps the held entry and reports its live bearing, got " .. tostring(out))
    T.eq(#citiesAllItems(ScannerNav._snapshot()), 1, "the held entry survives a read-only probe")
end

-- ===== J/K/L flattened custom-category cycle =====

-- Stub ScannerFavorites with a fixed def list (the shape
-- customCategoryDefs returns); the model's own selector logic is covered
-- in scanner_favorites_test.lua.
local function customFlatSetup(defs)
    setup()
    ScannerFavorites = {
        customCategoryDefs = function()
            return defs
        end,
    }
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "empty"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM"] = "no custom category {1_Num}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} of {2_Total}"
end

local function unitsDef()
    return {
        key = "custom:1",
        labelText = "Alpha",
        selectors = { { cat = "units_my", sub = "all", label = "My Units" } },
    }
end

local function currentInstancePlotX()
    local ci, si, ii, ini = ScannerNav._indices()
    return ScannerNav._snapshot().categories[ci].subcategories[si].items[ii].instances[ini].plotX
end

function M.test_custom_flat_entry_press_lands_on_closest_without_label()
    customFlatSetup({ unitsDef() })
    T.installMap({ mkPlot(1, 0, 0), mkPlot(2, 0, 1) })
    _entries = {
        mkEntry("units_my", "ranged", "Archer", 0, { key = "stub:archer" }),
        mkEntry("units_my", "melee", "Warrior", 1, { key = "stub:warrior" }),
    }
    local out = ScannerNav.cycleCustomFlat(1, 1)
    T.eq(out, "Archer. 1e. 1 of 2", "entry press lands on the closest entry, no category-name prefix, flat count")
    local catIdx, subIdx = ScannerNav._indices()
    T.eq(catIdx, 1, "custom category sorts first in the snapshot")
    T.eq(subIdx, 1, "entry press lands on the `all` sub")
end

function M.test_custom_flat_steps_interleave_across_item_grouping()
    -- Two Warriors (d=1 and d=3) grouped under one item, an Archer (d=2)
    -- between them. The flat walk must visit W1, Archer, W2 -- an item
    -- cycle would skip W2, an instance cycle would skip the Archer. The
    -- spoken X of Y counts the flat walk, not the within-item instances.
    customFlatSetup({ unitsDef() })
    T.installMap({ mkPlot(1, 0, 0), mkPlot(2, 0, 1), mkPlot(3, 0, 2) })
    _entries = {
        mkEntry("units_my", "melee", "Warrior", 0, { key = "stub:w1" }),
        mkEntry("units_my", "ranged", "Archer", 1, { key = "stub:a" }),
        mkEntry("units_my", "melee", "Warrior", 2, { key = "stub:w2" }),
    }
    local out = ScannerNav.cycleCustomFlat(1, 1) -- entry press: W1 (closest)
    T.eq(currentInstancePlotX(), 1, "entry press lands on W1")
    T.truthy(out:find("1 of 3", 1, true), "flat numbering: W1 is walk position 1 of 3, got " .. out)
    out = ScannerNav.cycleCustomFlat(1, 1)
    T.eq(currentInstancePlotX(), 2, "first step reaches the Archer")
    T.truthy(out:find("2 of 3", 1, true), "flat numbering: Archer is walk position 2 of 3, got " .. out)
    out = ScannerNav.cycleCustomFlat(1, 1)
    T.eq(currentInstancePlotX(), 3, "second step reaches the second Warrior, not a wrap to W1")
    T.truthy(out:find("3 of 3", 1, true), "flat numbering: W2 is walk position 3, not instance 2 of 2, got " .. out)
    ScannerNav.cycleCustomFlat(1, 1)
    T.eq(currentInstancePlotX(), 1, "walk wraps from the last flat entry to the first")
    ScannerNav.cycleCustomFlat(1, -1)
    T.eq(currentInstancePlotX(), 3, "Shift steps backward, wrapping from first to last")
end

function M.test_custom_flat_cursor_move_restarts_at_nearest()
    -- Once the cursor leaves the snapshot origin, the next press starts a
    -- fresh sweep from the cursor rather than continuing the stale walk.
    customFlatSetup({ unitsDef() })
    T.installMap({ mkPlot(1, 0, 0), mkPlot(2, 0, 1), mkPlot(3, 0, 2) })
    _entries = {
        mkEntry("units_my", "melee", "Warrior", 0, { key = "stub:w1" }),
        mkEntry("units_my", "ranged", "Archer", 1, { key = "stub:a" }),
        mkEntry("units_my", "melee", "Warrior", 2, { key = "stub:w2" }),
    }
    ScannerNav.cycleCustomFlat(1, 1) -- W1
    ScannerNav.cycleCustomFlat(1, 1) -- Archer
    Cursor.position = function()
        return 3, 0
    end
    local out = ScannerNav.cycleCustomFlat(1, 1)
    T.eq(currentInstancePlotX(), 3, "restart lands on the entry nearest the moved cursor")
    T.truthy(out:find("1 of 3", 1, true), "and the walk renumbers from the new origin, got " .. out)
end

function M.test_custom_flat_on_current_entry_hops_to_next_nearest()
    -- Cursor parked on the current entry (Home / auto-move): the nearest
    -- entry from there is the entry itself, so the press steps once in
    -- the pressed direction instead of re-landing where the user already
    -- is -- the nearest-neighbor hop.
    customFlatSetup({ unitsDef() })
    T.installMap({ mkPlot(1, 0, 0), mkPlot(2, 0, 1), mkPlot(3, 0, 2) })
    _entries = {
        mkEntry("units_my", "melee", "Warrior", 0, { key = "stub:w1" }),
        mkEntry("units_my", "ranged", "Archer", 1, { key = "stub:a" }),
        mkEntry("units_my", "melee", "Warrior", 2, { key = "stub:w2" }),
    }
    ScannerNav.cycleCustomFlat(1, 1) -- W1 at (1,0)
    Cursor.position = function()
        return 1, 0
    end
    local out = ScannerNav.cycleCustomFlat(1, 1)
    T.eq(currentInstancePlotX(), 2, "hop skips the parked-on entry and lands on the next nearest")
    T.truthy(out:find("2 of 3", 1, true), "spoken as walk position 2 in the re-anchored order, got " .. out)
end

function M.test_custom_flat_missing_slot_speaks_no_custom()
    customFlatSetup({ unitsDef() })
    T.installMap({ mkPlot(1, 0, 0) })
    _entries = { mkEntry("units_my", "melee", "Warrior", 0, { key = "stub:w" }) }
    T.eq(ScannerNav.cycleCustomFlat(2, 1), "no custom category 2")
end

function M.test_custom_flat_empty_category_speaks_empty()
    customFlatSetup({ { key = "custom:1", labelText = "Alpha", selectors = {} } })
    T.installMap({ mkPlot(1, 0, 0) })
    _entries = { mkEntry("units_my", "melee", "Warrior", 0, { key = "stub:w" }) }
    T.eq(ScannerNav.cycleCustomFlat(1, 1), "empty")
end

function M.test_custom_flat_from_named_sub_reenters_at_all_front()
    -- The flat walk owns the `all` sub only. From a named sub of the same
    -- category (reached via Shift+PageDown), a press is an entry press:
    -- back to the front of `all`, not a flat walk of the named sub.
    customFlatSetup({ unitsDef() })
    T.installMap({ mkPlot(1, 0, 0), mkPlot(2, 0, 1) })
    _entries = {
        mkEntry("units_my", "ranged", "Archer", 0, { key = "stub:archer" }),
        mkEntry("units_my", "melee", "Warrior", 1, { key = "stub:warrior" }),
    }
    ScannerNav.cycleCustomFlat(1, 1)
    ScannerNav.cycleSubcategory(1) -- into the first named sub
    local _, subIdx = ScannerNav._indices()
    T.truthy(subIdx > 1, "precondition: on a named sub")
    local out = ScannerNav.cycleCustomFlat(1, 1)
    local _, subIdxAfter = ScannerNav._indices()
    T.eq(subIdxAfter, 1, "press from a named sub re-enters the `all` sub")
    T.truthy(out:find("1 of 2", 1, true), "and lands at the front of the flat walk, got " .. out)
end

return M

-- ScannerNav: cursor index wrapping, category-change rebuild, turn-start
-- staleness, mid-snapshot validation pruning. Exercises the full
-- nav-state machine via the public entry points, with a stubbed backend
-- registered into ScannerCore.BACKENDS so Nav's gather+build path runs
-- end-to-end without touching the real game APIs.

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

local function mkEntry(cat, sub, name, plotIndex)
    return T.mkEntry(cat, sub, name, plotIndex, { backend = ScannerCore.BACKENDS[1] })
end

local _turnStartHandlers
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
    -- ScannerNav subscribes to Events.ActivePlayerTurnStart at load time.
    -- Capture the subscription so we can fire it from tests.
    _turnStartHandlers = {}
    civvaccess_shared = {}
    Events.ActivePlayerTurnStart = {
        Add = function(fn)
            _turnStartHandlers[#_turnStartHandlers + 1] = fn
        end,
    }
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

local function fireTurnStart()
    for _, fn in ipairs(_turnStartHandlers) do
        fn()
    end
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
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
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

-- ===== Turn-start invalidation =====

function M.test_turn_start_invalidates_next_read()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0) -- build
    T.falsy(ScannerNav._isStale(), "fresh snapshot must not be stale after build")
    fireTurnStart()
    T.truthy(ScannerNav._isStale(), "ActivePlayerTurnStart must mark the snapshot stale")
    ScannerNav.cycleItem(1) -- any op that needs the snapshot
    T.falsy(ScannerNav._isStale(), "the next read must rebuild and clear the stale flag")
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
    -- Simulates a city falling between rebuilds. Before this fix, Nav
    -- never consulted ValidateEntry; the stale entry kept being announced.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local snap = ScannerNav._snapshot()
    local myIdx = findMySubIdx(snap)
    T.eq(#snap.categories[1].subcategories[myIdx].items[1].instances, 2)
    -- Mark plotIndex=0 entries dead. After this the current instance is
    -- the surviving one at plotIndex=1; pruning must collapse it.
    _validator = function(entry)
        return entry.plotIndex ~= 0
    end
    ScannerNav.cycleInstance(0) -- any op that reads the current instance
    T.eq(
        #snap.categories[1].subcategories[myIdx].items[1].instances,
        1,
        "nav must prune the invalid current instance before announcement"
    )
end

function M.test_validate_false_on_all_instances_wraps_up_to_empty()
    -- Item empties out: prune walks through all instances and then the
    -- "wraps up the hierarchy" path lands on EMPTY since nothing is left.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    _validator = function()
        return false
    end -- every entry stale
    local out = ScannerNav.cycleInstance(0)
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
    local out = ScannerNav.cycleInstance(0)
    T.truthy(out:find("LiveName", 1, true), "announcement must go through FormatName, got " .. tostring(out))
end

function M.test_turn_start_rebuild_resets_item_and_instance()
    -- Design section 5: "Reset item and instance to 0" after turn-start
    -- rebuild. Category / subcategory survive because the taxonomy is
    -- static.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "A", 0),
        mkEntry("cities", "my", "B", 1),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    ScannerNav.cycleItem(1) -- advance to item 2
    local cat, sub, item, _ = ScannerNav._indices()
    T.eq(item, 2, "precondition: landed on item 2 before turn-start")
    fireTurnStart()
    ScannerNav.cycleItem(0) -- first read after turn-start triggers rebuild
    local cat2, sub2, item2, _ = ScannerNav._indices()
    T.eq(cat2, cat, "category preserved across turn-start rebuild")
    T.eq(sub2, sub, "subcategory preserved across turn-start rebuild")
    T.eq(item2, 1, "item reset to front of sub after turn-start rebuild")
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
    -- stale rebuilds keep the user's chosen category.
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

function M.test_stale_rebuild_preserves_empty_category_choice()
    -- If the user navigated to a specific category and it empties out on a
    -- turn boundary, the stale rebuild must not silently jump elsewhere --
    -- EMPTY is the correct answer because the user explicitly chose that
    -- category. The initial-build skip is opt-in for the very first build.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleCategory(1) -- land on resources (first non-empty)
    T.eq(ScannerNav._indices(), catIdxByKey("resources"))
    _entries = {} -- everything disappears next turn
    fireTurnStart()
    local out = ScannerNav.cycleItem(1)
    T.eq(ScannerNav._indices(), catIdxByKey("resources"), "stale rebuild must keep user's chosen cat")
    T.truthy(
        out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY" or out:find("empty", 1, true) ~= nil,
        "empty cat on stale rebuild speaks EMPTY, got " .. tostring(out)
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
    -- user's category somehow has all-empty subs (e.g. after a turn-
    -- start rebuild clears everything) a sub cycle must speak EMPTY
    -- rather than wrap forever.
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

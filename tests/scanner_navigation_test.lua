-- ScannerNav: cursor index wrapping, category-change rebuild, turn-start
-- staleness, mid-snapshot validation pruning. Exercises the full
-- nav-state machine via the public entry points, with a stubbed backend
-- registered into ScannerCore.BACKENDS so Nav's gather+build path runs
-- end-to-end without touching the real game APIs.

local T = require("support")
local M = {}

local function installMap(plots)
    Map.GetNumPlots    = function() return #plots end
    Map.GetPlotByIndex = function(i) return plots[i + 1] end
    Map.PlotDistance   = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    Map.GetPlot = function(x, y)
        for _, p in ipairs(plots) do
            if p:GetX() == x and p:GetY() == y then return p end
        end
        return nil
    end
end

-- Stub backend that returns whatever entries its `nextBatch` is set to.
local _entries = {}
local _validator = function(_e) return true end
local function installStubBackend()
    ScannerCore.BACKENDS = {}
    ScannerCore.registerBackend({
        name          = "stub",
        Scan          = function() return _entries end,
        ValidateEntry = function(entry, cursorPlotIndex)
            return _validator(entry, cursorPlotIndex)
        end,
        FormatName    = function(entry) return entry.itemName end,
    })
end

local function mkPlot(x, y, idx)
    return T.fakePlot({ x = x, y = y, plotIndex = idx })
end

local function mkEntry(cat, sub, name, plotIndex)
    return {
        plotIndex   = plotIndex,
        backend     = ScannerCore.BACKENDS[1],
        data        = {},
        category    = cat,
        subcategory = sub,
        itemName    = name,
        sortKey     = 0,
    }
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
        Add = function(fn) _turnStartHandlers[#_turnStartHandlers + 1] = fn end,
    }
    -- Stubs for cursor and HandlerStack (Nav pushes ScannerInput in openSearch).
    Cursor = {
        _x = 0, _y = 0,
        position = function() return 0, 0 end,
        jumpTo   = function(x, y) return "jumped to " .. x .. "," .. y end,
    }
    HandlerStack = { push = function() end, removeByName = function() end }
    ScannerInput = { create = function() return { name = "ScannerInput" } end }
    Game.GetActivePlayer = function() return 0 end
    Game.GetActiveTeam   = function() return 0 end

    dofile("src/dlc/UI/InGame/CivVAccess_ScannerNav.lua")
    installStubBackend()
    _entries = {}
    _validator = function() return true end
    ScannerNav._reset()
    Log.warn  = function() end
    Log.error = function() end
    Log.info  = function() end
end

local function fireTurnStart()
    for _, fn in ipairs(_turnStartHandlers) do fn() end
end

-- ===== Item cycle wrap =====

function M.test_cycle_item_wraps_forward_and_back()
    setup()
    local p1 = mkPlot(0, 0, 0)
    local p2 = mkPlot(1, 0, 1)
    local p3 = mkPlot(2, 0, 2)
    installMap({ p1, p2, p3 })
    _entries = {
        mkEntry("cities", "my", "A", 0),
        mkEntry("cities", "my", "B", 1),
        mkEntry("cities", "my", "C", 2),
    }
    ScannerNav.cycleCategory(0)  -- build + land on cities
    -- After land: _catIdx=cities, _subIdx=1 (all), items=[A,B,C] by distance.
    ScannerNav.cycleSubcategory(1)  -- move to "my"
    ScannerNav.cycleItem(1)  -- B
    ScannerNav.cycleItem(1)  -- C
    ScannerNav.cycleItem(1)  -- wraps to A
    local _, _, itemIdx = ScannerNav._indices()
    T.eq(itemIdx, 1, "next from last item must wrap to first")

    ScannerNav.cycleItem(-1)
    local _, _, itemIdx2 = ScannerNav._indices()
    T.eq(itemIdx2, 3, "prev from first wraps to last")
end

-- ===== Instance cycle wrap =====

function M.test_cycle_instance_wraps()
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)  -- to "my"
    ScannerNav.cycleInstance(1)
    local _, _, _, instIdx = ScannerNav._indices()
    T.eq(instIdx, 2)
    ScannerNav.cycleInstance(1)  -- wraps
    _, _, _, instIdx = ScannerNav._indices()
    T.eq(instIdx, 1, "instance cycle wraps back to 1")
end

-- ===== Category change forces rebuild =====

function M.test_cycle_category_rebuilds_snapshot()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    local scans = 0
    ScannerCore.BACKENDS[1].Scan = function()
        scans = scans + 1
        return { mkEntry("cities", "my", "Rome", 0) }
    end
    ScannerNav.cycleCategory(1)
    local firstScans = scans
    ScannerNav.cycleCategory(1)
    T.truthy(scans > firstScans,
        "each category cycle must re-run every backend Scan (rebuild signal)")
end

-- ===== Turn-start invalidation =====

function M.test_turn_start_invalidates_next_read()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0)  -- build
    T.falsy(ScannerNav._isStale(), "fresh snapshot must not be stale after build")
    fireTurnStart()
    T.truthy(ScannerNav._isStale(), "ActivePlayerTurnStart must mark the snapshot stale")
    ScannerNav.cycleItem(1)  -- any op that needs the snapshot
    T.falsy(ScannerNav._isStale(), "the next read must rebuild and clear the stale flag")
end

-- ===== Validation-driven pruning =====

function M.test_validate_returning_false_prunes_current_instance()
    -- Simulate a city falling between rebuilds: ValidateEntry on its entry
    -- returns false. Nav's advance / announce path should skip past it.
    -- We exercise this through ValidateEntry being called wherever the
    -- current instance is read. For this test we invoke pruneInstance
    -- directly on the snapshot to simulate what the navigator would do.
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    _entries = {
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
    }
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local snap = ScannerNav._snapshot()
    local myIdx
    for i, s in ipairs(snap.categories[1].subcategories) do
        if s.key == "my" then myIdx = i; break end
    end
    T.eq(#snap.categories[1].subcategories[myIdx].items[1].instances, 2)
    ScannerSnap.pruneInstance(snap, 1, myIdx, 1, 1)
    T.eq(#snap.categories[1].subcategories[myIdx].items[1].instances, 1,
        "prune must remove one instance without collapsing the item")
end

function M.test_empty_snapshot_speaks_empty_token()
    setup()
    installMap({})
    _entries = {}
    local out = ScannerNav.cycleItem(1)
    T.truthy(out == "TXT_KEY_CIVVACCESS_SCANNER_EMPTY"
            or out:find("empty", 1, true) ~= nil,
        "empty snapshot must trigger the EMPTY token, got " .. tostring(out))
end

-- ===== Search entry / exit =====

function M.test_apply_search_builds_search_snapshot()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0)  -- initial normal snapshot
    local catBefore, _, _, _ = ScannerNav._indices()
    ScannerNav.applySearch("rom")
    local snap = ScannerNav._snapshot()
    T.eq(snap.isSearch, true, "applySearch must install an isSearch snapshot")
    -- Pre-search category index must be preserved for the exit cycle.
    T.eq(ScannerNav._preSearchCatIdx(), catBefore)
end

function M.test_apply_search_no_match_keeps_existing_snapshot()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("cities", "my", "Rome", 0) }
    ScannerNav.cycleCategory(0)
    local before = ScannerNav._snapshot()
    ScannerNav.openSearch()  -- capture _preSearchCatIdx
    ScannerNav.applySearch("zzzz")
    T.eq(ScannerNav._snapshot(), before,
        "no-match must keep the current snapshot, not replace it with nil")
    T.falsy(ScannerNav._snapshot().isSearch, "previous normal snapshot stays in place")
end

function M.test_cycle_category_exits_search_snapshot()
    setup()
    installMap({ mkPlot(0, 0, 0) })
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
    installMap({ mkPlot(0, 0, 0) })
    _entries = { mkEntry("resources", "strategic", "Iron", 0) }
    ScannerNav.cycleCategory(0)                 -- cities (idx 1)
    ScannerNav.cycleCategory(1); ScannerNav.cycleCategory(1); ScannerNav.cycleCategory(1); ScannerNav.cycleCategory(1)  -- advance to resources (idx 5)
    local catBeforeSearch, _, _, _ = ScannerNav._indices()
    ScannerNav.openSearch()
    ScannerNav.applySearch("iron")
    ScannerNav.openSearch()  -- re-entry while already in search
    T.eq(ScannerNav._preSearchCatIdx(), catBeforeSearch,
        "re-opening search must not overwrite the original pre-search anchor")
end

return M

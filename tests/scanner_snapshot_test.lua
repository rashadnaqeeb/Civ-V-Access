-- ScannerSnap construction, sort, and prune-by-instance. Covers the
-- `all` sub's shared-reference invariant (the only place in the scanner
-- pipeline where one item object intentionally lives in two containers).

local T = require("support")
local M = {}

local function setup()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSnap.lua")
    Log.warn  = function() end
    Log.error = function() end
end

-- Install a Map that resolves plotIndex 1-based against `plots`.
local function installMap(plots)
    Map.GetNumPlots    = function() return #plots end
    Map.GetPlotByIndex = function(i) return plots[i + 1] end
    Map.PlotDistance   = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
end

local function mkPlot(x, y, idx)
    return T.fakePlot({ x = x, y = y, plotIndex = idx })
end

local function mkEntry(cat, sub, name, plotIndex, sortKey)
    return {
        plotIndex   = plotIndex,
        backend     = { name = "test" },
        data        = {},
        category    = cat,
        subcategory = sub,
        itemName    = name,
        sortKey     = sortKey or 0,
    }
end

-- Look up a snapshot category by key (the snapshot keeps cats in
-- taxonomy order, but tests care about semantics, not index).
local function findCat(snap, key)
    for _, c in ipairs(snap.categories) do
        if c.key == key then return c end
    end
    return nil
end

local function findSub(cat, key)
    for _, s in ipairs(cat.subcategories) do
        if s.key == key then return s end
    end
    return nil
end

function M.test_build_produces_all_taxonomy_categories()
    setup()
    installMap({})
    local snap = ScannerSnap.build({}, 0, 0)
    T.eq(#snap.categories, #ScannerCore.CATEGORIES,
        "every taxonomy category must show up in the snapshot, even when empty")
end

function M.test_all_sub_at_index_1_every_category()
    setup()
    installMap({})
    local snap = ScannerSnap.build({}, 0, 0)
    for _, c in ipairs(snap.categories) do
        T.eq(c.subcategories[1].key, "all",
            "category " .. c.key .. " must have `all` at subcategories[1]")
    end
end

function M.test_items_within_sub_sort_by_nearest_instance_distance()
    setup()
    local p1 = mkPlot(0, 0, 0)  -- close
    local p2 = mkPlot(5, 0, 1)  -- far
    installMap({ p1, p2 })
    local entries = {
        mkEntry("cities", "my", "Far",   1),
        mkEntry("cities", "my", "Close", 0),
    }
    local snap = ScannerSnap.build(entries, 0, 0)
    local sub = findSub(findCat(snap, "cities"), "my")
    T.eq(sub.items[1].name, "Close",
        "closer item must rank first regardless of input order")
    T.eq(sub.items[2].name, "Far")
end

function M.test_instances_within_item_sort_by_distance_then_plotindex()
    setup()
    local a = mkPlot(1, 0, 0)  -- d=1
    local b = mkPlot(2, 0, 1)  -- d=2
    local c = mkPlot(1, 0, 2)  -- d=1, same distance as a, higher plotIndex
    installMap({ a, b, c })
    local entries = {
        mkEntry("cities", "my", "Rome", 1),
        mkEntry("cities", "my", "Rome", 2),
        mkEntry("cities", "my", "Rome", 0),
    }
    local snap = ScannerSnap.build(entries, 0, 0)
    local item = findSub(findCat(snap, "cities"), "my").items[1]
    T.eq(#item.instances, 3)
    T.eq(item.instances[1].entry.plotIndex, 0, "d=1 with lower plotIndex ranks first")
    T.eq(item.instances[2].entry.plotIndex, 2, "d=1 tiebreaker picks lower plotIndex")
    T.eq(item.instances[3].entry.plotIndex, 1, "d=2 ranks last")
end

function M.test_all_sub_shares_item_ref_with_named_sub()
    -- Identity (==), not value equality. Pruning in one must remove from
    -- the other because they're the same table.
    setup()
    local p = mkPlot(0, 0, 0)
    installMap({ p })
    local snap = ScannerSnap.build({ mkEntry("cities", "my", "Rome", 0) }, 0, 0)
    local cat = findCat(snap, "cities")
    local namedItem = findSub(cat, "my").items[1]
    local allItem   = cat.subcategories[1].items[1]
    T.truthy(rawequal(namedItem, allItem),
        "named-sub item and all-sub item must be the same table reference")
end

function M.test_prune_instance_removes_item_from_both_subs_when_empty()
    setup()
    local p = mkPlot(0, 0, 0)
    installMap({ p })
    local snap = ScannerSnap.build({ mkEntry("cities", "my", "Rome", 0) }, 0, 0)
    local cat = findCat(snap, "cities")
    local myIdx, allIdx = 0, 1
    for i, s in ipairs(cat.subcategories) do
        if s.key == "my" then myIdx = i end
    end
    ScannerSnap.pruneInstance(snap, -1, myIdx, 1, 1)  -- wrong cat: no-op
    T.eq(#findSub(cat, "my").items, 1, "pruning a bogus cat must not touch state")
    -- Real prune: remove the only instance so the item empties and gets
    -- dropped from both the named sub and `all`.
    local catIdx = 0
    for i, c in ipairs(snap.categories) do
        if c.key == "cities" then catIdx = i end
    end
    ScannerSnap.pruneInstance(snap, catIdx, myIdx, 1, 1)
    T.eq(#findSub(cat, "my").items, 0, "empty item must drop from named sub")
    T.eq(#cat.subcategories[allIdx].items, 0,
        "empty item must also drop from `all` (shared ref invariant)")
end

function M.test_prune_instance_keeps_item_when_other_instances_remain()
    setup()
    local p1 = mkPlot(0, 0, 0)
    local p2 = mkPlot(1, 0, 1)
    installMap({ p1, p2 })
    local entries = {
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
    }
    local snap = ScannerSnap.build(entries, 0, 0)
    local cat = findCat(snap, "cities")
    local myIdx = 0
    for i, s in ipairs(cat.subcategories) do if s.key == "my" then myIdx = i end end
    local catIdx = 0
    for i, c in ipairs(snap.categories) do if c.key == "cities" then catIdx = i end end
    ScannerSnap.pruneInstance(snap, catIdx, myIdx, 1, 1)
    local item = findSub(cat, "my").items[1]
    T.eq(#item.instances, 1, "item should still carry its surviving instance")
    T.eq(#cat.subcategories[1].items, 1, "item should still be in `all` too")
end

function M.test_unknown_category_logged_and_dropped()
    setup()
    local warned = 0
    Log.warn = function() warned = warned + 1 end
    installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSnap.build({ mkEntry("not_a_real_cat", "my", "X", 0) }, 0, 0)
    T.eq(warned, 1, "bad category must produce a warn")
    -- Snapshot still built with empty items in every legitimate bucket.
    for _, c in ipairs(snap.categories) do
        T.eq(#c.subcategories[1].items, 0)
    end
end

function M.test_unresolved_plotindex_logged_and_dropped()
    setup()
    local warned = 0
    Log.warn = function() warned = warned + 1 end
    installMap({})  -- GetPlotByIndex returns nil for everything
    ScannerSnap.build({ mkEntry("cities", "my", "X", 42) }, 0, 0)
    T.eq(warned, 1, "unresolved plotIndex must produce a warn")
end

return M

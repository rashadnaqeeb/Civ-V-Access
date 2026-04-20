-- ScannerSearch filter. Verifies tier-based inclusion/exclusion plus
-- the synthetic-snapshot shape: one top category with subs keyed by the
-- entries' original category, `all` first.

local T = require("support")
local M = {}

local function setup()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSearch.lua")
    Log.warn  = function() end
    Log.error = function() end
end

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

local function mkEntry(cat, sub, name, plotIndex)
    return {
        plotIndex   = plotIndex,
        backend     = { name = "test" },
        data        = {},
        category    = cat,
        subcategory = sub,
        itemName    = name,
        sortKey     = 0,
    }
end

local function firstSearchCat(snap)
    return snap.categories[1]
end

local function namedSubs(snap)
    local cat = firstSearchCat(snap)
    local out = {}
    for i = 2, #cat.subcategories do out[#out + 1] = cat.subcategories[i] end
    return out
end

function M.test_empty_query_returns_nil()
    setup()
    installMap({})
    T.eq(ScannerSearch.build({}, "",    0, 0), nil)
    T.eq(ScannerSearch.build({}, "   ", 0, 0), nil, "whitespace-only query must return nil")
    T.eq(ScannerSearch.build({}, nil,   0, 0), nil)
end

function M.test_no_match_returns_nil()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    local entries = { mkEntry("cities", "my", "Rome", 0) }
    T.eq(ScannerSearch.build(entries, "zzzz", 0, 0), nil,
        "no matching entry should produce no snapshot, not an empty one")
end

function M.test_single_match_produces_search_category()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSearch.build(
        { mkEntry("cities", "my", "Rome", 0) }, "rome", 0, 0)
    T.truthy(snap ~= nil)
    T.eq(snap.isSearch, true, "search snapshots carry the isSearch flag")
    T.eq(#snap.categories, 1, "search always produces one synthetic category")
    T.eq(snap.categories[1].key, "search")
end

function M.test_match_tier_orders_items_within_sub()
    -- Two entries in the same original category (cities) but different
    -- name-match tiers: "Iron Fist" starts with "iron" (tier 0), "Stone
    -- and Iron" contains "iron" mid-word (tier 2). The scanner must show
    -- the tier-0 item first.
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        mkEntry("cities", "my", "Stone and Iron", 1),  -- tier 2 (mid-word)
        mkEntry("cities", "my", "Iron Fist",      0),  -- tier 0 (start whole word)
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs, 1, "only cities sub should appear")
    T.eq(subs[1].items[1].name, "Iron Fist",
        "tier 0 (start whole word) must rank ahead of tier 2 (mid-word)")
    T.eq(subs[1].items[2].name, "Stone and Iron")
end

function M.test_subs_ordered_by_taxonomy_not_match_order()
    -- Matches in cities + resources; subs should appear in taxonomy
    -- order (cities before resources) regardless of input order.
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        mkEntry("resources", "strategic", "Iron", 1),  -- input first
        mkEntry("cities",    "my",        "Iron", 0),  -- input second
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(subs[1].key, "cities", "cities category must come before resources (taxonomy order)")
    T.eq(subs[2].key, "resources")
end

function M.test_all_sub_first_and_aggregates_everything()
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        mkEntry("cities", "my", "Iron Fist", 0),
        mkEntry("resources", "strategic", "Iron", 1),
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local cat = firstSearchCat(snap)
    T.eq(cat.subcategories[1].key, "all", "`all` must sit at index 1")
    local countInAll = #cat.subcategories[1].items
    local sumInNamed = 0
    for i = 2, #cat.subcategories do
        sumInNamed = sumInNamed + #cat.subcategories[i].items
    end
    T.eq(countInAll, sumInNamed,
        "`all` must aggregate every item from every named sub")
end

function M.test_all_sub_shares_item_refs_with_named_subs()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSearch.build(
        { mkEntry("cities", "my", "Rome", 0) }, "rome", 0, 0)
    local cat = firstSearchCat(snap)
    local allItem   = cat.subcategories[1].items[1]
    local namedItem = cat.subcategories[2].items[1]
    T.truthy(rawequal(allItem, namedItem),
        "search snapshot `all` must share item refs the same way normal snapshots do")
end

function M.test_entries_with_unknown_category_dropped()
    setup()
    installMap({ mkPlot(0, 0, 0) })
    local entries = { mkEntry("not_a_real_cat", "my", "Iron", 0) }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    T.eq(snap, nil, "an entry with a bad category must be dropped; empty result collapses to nil")
end

function M.test_same_name_shared_across_subs_produces_separate_items()
    -- "Iron" as a resource and "Iron" as a city share a name but live
    -- in different original categories. They must stay in their own subs;
    -- the scanner shouldn't merge them because they represent different
    -- things.
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        mkEntry("cities",    "my",        "Iron", 0),
        mkEntry("resources", "strategic", "Iron", 1),
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs[1].items, 1, "one item in cities sub")
    T.eq(#subs[2].items, 1, "one item in resources sub")
end

function M.test_multiple_instances_of_same_name_collapse_into_one_item()
    setup()
    installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1), mkPlot(2, 0, 2) })
    local entries = {
        mkEntry("cities", "my", "Iron", 0),
        mkEntry("cities", "my", "Iron", 1),
        mkEntry("cities", "my", "Iron", 2),
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs[1].items, 1, "three instances same name: one item")
    T.eq(#subs[1].items[1].instances, 3)
end

return M

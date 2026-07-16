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
    Log.warn = function() end
    Log.error = function() end
end

local function mkPlot(x, y, idx)
    return T.fakePlot({ x = x, y = y, plotIndex = idx })
end

local function firstSearchCat(snap)
    return snap.categories[1]
end

local function namedSubs(snap)
    local cat = firstSearchCat(snap)
    local out = {}
    for i = 2, #cat.subcategories do
        out[#out + 1] = cat.subcategories[i]
    end
    return out
end

function M.test_empty_query_returns_nil()
    setup()
    T.installMap({})
    T.eq(ScannerSearch.build({}, "", 0, 0), nil)
    T.eq(ScannerSearch.build({}, "   ", 0, 0), nil, "whitespace-only query must return nil")
    T.eq(ScannerSearch.build({}, nil, 0, 0), nil)
end

function M.test_no_match_returns_nil()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local entries = { T.mkEntry("cities", "my", "Rome", 0) }
    T.eq(
        ScannerSearch.build(entries, "zzzz", 0, 0),
        nil,
        "no matching entry should produce no snapshot, not an empty one"
    )
end

function M.test_single_match_produces_search_category()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSearch.build({ T.mkEntry("cities", "my", "Rome", 0) }, "rome", 0, 0)
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
    T.installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        T.mkEntry("cities", "my", "Stone and Iron", 1), -- tier 2 (mid-word)
        T.mkEntry("cities", "my", "Iron Fist", 0), -- tier 0 (start whole word)
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs, 1, "only cities sub should appear")
    T.eq(subs[1].items[1].name, "Iron Fist", "tier 0 (start whole word) must rank ahead of tier 2 (mid-word)")
    T.eq(subs[1].items[2].name, "Stone and Iron")
end

function M.test_subs_ordered_by_taxonomy_not_match_order()
    -- Matches in cities + resources; subs should appear in taxonomy
    -- order (cities before resources) regardless of input order.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        T.mkEntry("resources", "strategic", "Iron", 1), -- input first
        T.mkEntry("cities", "my", "Iron", 0), -- input second
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(subs[1].key, "cities", "cities category must come before resources (taxonomy order)")
    T.eq(subs[2].key, "resources")
end

function M.test_all_sub_first_and_aggregates_everything()
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        T.mkEntry("cities", "my", "Iron Fist", 0),
        T.mkEntry("resources", "strategic", "Iron", 1),
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local cat = firstSearchCat(snap)
    T.eq(cat.subcategories[1].key, "all", "`all` must sit at index 1")
    local countInAll = #cat.subcategories[1].items
    local sumInNamed = 0
    for i = 2, #cat.subcategories do
        sumInNamed = sumInNamed + #cat.subcategories[i].items
    end
    T.eq(countInAll, sumInNamed, "`all` must aggregate every item from every named sub")
end

function M.test_all_sub_shares_item_refs_with_named_subs()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSearch.build({ T.mkEntry("cities", "my", "Rome", 0) }, "rome", 0, 0)
    local cat = firstSearchCat(snap)
    local allItem = cat.subcategories[1].items[1]
    local namedItem = cat.subcategories[2].items[1]
    T.truthy(
        rawequal(allItem, namedItem),
        "search snapshot `all` must share item refs the same way normal snapshots do"
    )
end

function M.test_entries_with_unknown_category_dropped()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local entries = { T.mkEntry("not_a_real_cat", "my", "Iron", 0) }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    T.eq(snap, nil, "an entry with a bad category must be dropped; empty result collapses to nil")
end

function M.test_same_name_shared_across_subs_produces_separate_items()
    -- "Iron" as a resource and "Iron" as a city share a name but live
    -- in different original categories. They must stay in their own subs;
    -- the scanner shouldn't merge them because they represent different
    -- things.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(0, 0, 1) })
    local entries = {
        T.mkEntry("cities", "my", "Iron", 0),
        T.mkEntry("resources", "strategic", "Iron", 1),
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs[1].items, 1, "one item in cities sub")
    T.eq(#subs[2].items, 1, "one item in resources sub")
end

function M.test_instance_name_alias_matches_query()
    -- A civ-grouped city entry carries the city name as instanceName;
    -- searching the city name must still find it even though itemName is
    -- now the civ.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local entries = {
        T.mkEntry("cities", "my", "Rome", 0, { itemKey = "civ:1", instanceName = "Antium" }),
    }
    local snap = ScannerSearch.build(entries, "antium", 0, 0)
    T.truthy(snap ~= nil, "query matching only the instanceName alias must produce a snapshot")
    local subs = namedSubs(snap)
    T.eq(subs[1].items[1].name, "Rome", "the result item keeps the grouping itemName")
end

function M.test_item_key_groups_matches_into_one_item()
    -- Two grouped cities of the same civ matched by the civ name must
    -- collapse into one item with two instances, mirroring ScannerSnap's
    -- identity-keyed grouping.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    local entries = {
        T.mkEntry("cities", "my", "Rome", 0, { itemKey = "civ:1", instanceName = "Antium" }),
        T.mkEntry("cities", "my", "Rome", 1, { itemKey = "civ:1", instanceName = "Cumae" }),
    }
    local snap = ScannerSearch.build(entries, "rome", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs[1].items, 1, "same itemKey must collapse into one item")
    T.eq(#subs[1].items[1].instances, 2)
end

function M.test_multiple_instances_of_same_name_collapse_into_one_item()
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1), mkPlot(2, 0, 2) })
    local entries = {
        T.mkEntry("cities", "my", "Iron", 0),
        T.mkEntry("cities", "my", "Iron", 1),
        T.mkEntry("cities", "my", "Iron", 2),
    }
    local snap = ScannerSearch.build(entries, "iron", 0, 0)
    local subs = namedSubs(snap)
    T.eq(#subs[1].items, 1, "three instances same name: one item")
    T.eq(#subs[1].items[1].instances, 3)
end

return M

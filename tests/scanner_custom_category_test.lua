-- Custom-category synthesis in ScannerSnap.build. Drives build() with
-- customDefs directly (the flattened shape ScannerFavorites.customCategoryDefs
-- produces) so these cover the snapshot half of the feature without the
-- Prefs-backed model. The model's own selector logic is covered in
-- scanner_favorites_test.lua.

local T = require("support")
local M = {}

local function setup()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
    -- ScannerSnap matches keyword subs through TypeAheadSearch.matchTier, the
    -- same engine Ctrl+F search uses.
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSnap.lua")
    Log.warn = function() end
    Log.error = function() end
end

local function mkPlot(x, y, idx)
    return T.fakePlot({ x = x, y = y, plotIndex = idx })
end

local function findCat(snap, key)
    for _, c in ipairs(snap.categories) do
        if c.key == key then
            return c
        end
    end
    return nil
end

local function findSub(cat, key)
    for _, s in ipairs(cat.subcategories) do
        if s.key == key then
            return s
        end
    end
    return nil
end

-- A def with one all-selector over units_my.
local function unitsAllDef()
    return {
        key = "custom:1",
        labelText = "Custom 1",
        selectors = { { cat = "units_my", sub = "all", label = "My Units" } },
    }
end

function M.test_custom_category_sorts_to_front()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local entries = { T.mkEntry("units_my", "melee", "Warrior", 0) }
    local snap = ScannerSnap.build(entries, 0, 0, { unitsAllDef() })
    T.eq(snap.categories[1].key, "custom:1", "custom categories must sort ahead of taxonomy categories")
    T.eq(snap.categories[1].labelText, "Custom 1", "custom category carries the pre-resolved positional label")
end

function M.test_all_selector_gathers_across_named_subs()
    -- An `all` selector over units_my must collect entries from every named
    -- sub of that category, not just one.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    local entries = {
        T.mkEntry("units_my", "melee", "Warrior", 0),
        T.mkEntry("units_my", "ranged", "Archer", 1),
    }
    local snap = ScannerSnap.build(entries, 0, 0, { unitsAllDef() })
    local custom = findCat(snap, "custom:1")
    local sub = findSub(custom, "units_my:all")
    T.eq(#sub.items, 2, "all-selector sub must hold both the melee and ranged units")
end

function M.test_named_selector_filters_to_its_sub()
    -- A named selector (cities/my) must catch only that sub's entries, with
    -- an enemy city left out.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(2, 0, 1) })
    local def = {
        key = "custom:1",
        labelText = "Custom 1",
        selectors = { { cat = "cities", sub = "my", label = "My Cities" } },
    }
    local entries = {
        T.mkEntry("cities", "my", "Rome", 0),
        T.mkEntry("cities", "enemy", "Babylon", 1),
    }
    local snap = ScannerSnap.build(entries, 0, 0, { def })
    local custom = findCat(snap, "custom:1")
    local sub = findSub(custom, "cities:my")
    T.eq(#sub.items, 1, "named selector must include only its own sub")
    T.eq(sub.items[1].name, "Rome", "the matching city, not the enemy one")
    T.eq(#custom.subcategories[1].items, 1, "custom `all` mirrors the single selector item")
end

function M.test_custom_items_independent_from_real_category()
    -- The same entry placed in its real category and a custom category must
    -- get DISTINCT item objects, so pruning one view never disturbs the
    -- other (real and custom prune independently across rebuilds).
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local entries = { T.mkEntry("units_my", "melee", "Warrior", 0) }
    local snap = ScannerSnap.build(entries, 0, 0, { unitsAllDef() })
    local realItem = findSub(findCat(snap, "units_my"), "melee").items[1]
    local customItem = findSub(findCat(snap, "custom:1"), "units_my:all").items[1]
    T.truthy(realItem ~= nil and customItem ~= nil, "both views must hold the item")
    T.truthy(not rawequal(realItem, customItem), "real and custom item objects must be distinct tables")
end

function M.test_custom_all_shares_instance_within_custom_category()
    -- A named selector sub and the implicit `all` keep their own item objects
    -- per name but share the underlying instance object, so both point at the
    -- same plot and a live re-query reads the same entity.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSnap.build({ T.mkEntry("units_my", "melee", "Warrior", 0) }, 0, 0, { unitsAllDef() })
    local custom = findCat(snap, "custom:1")
    local selItem = findSub(custom, "units_my:all").items[1]
    local allItem = custom.subcategories[1].items[1]
    T.truthy(not rawequal(selItem, allItem), "named sub and `all` keep distinct item objects")
    T.truthy(rawequal(selItem.instances[1], allItem.instances[1]), "but share the same instance object")
end

function M.test_empty_custom_category_has_no_items()
    -- A custom category with no selectors still appears (numbering parity
    -- with the settings list) but holds nothing, so Nav's categoryHasItems
    -- filter skips it.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local def = { key = "custom:1", labelText = "Custom 1", selectors = {} }
    local snap = ScannerSnap.build({ T.mkEntry("units_my", "melee", "Warrior", 0) }, 0, 0, { def })
    local custom = findCat(snap, "custom:1")
    T.truthy(custom ~= nil, "empty custom category is still present in the snapshot")
    T.eq(#custom.subcategories[1].items, 0, "empty custom category exposes no items")
end

-- ===== Keyword subcategories =====

local function subIndex(cat, key)
    for i, s in ipairs(cat.subcategories) do
        if s.key == key then
            return i
        end
    end
    return nil
end

local function keywordDef(keywords, selectors)
    return {
        key = "custom:1",
        labelText = "Custom 1",
        selectors = selectors or {},
        keywords = keywords,
    }
end

function M.test_keyword_matches_item_name_and_excludes_others()
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    local entries = {
        T.mkEntry("units_my", "melee", "Warrior", 0),
        T.mkEntry("units_my", "melee", "Archer", 1),
    }
    local snap = ScannerSnap.build(entries, 0, 0, { keywordDef({ "warrior" }) })
    local sub = findSub(findCat(snap, "custom:1"), "kw:warrior")
    T.truthy(sub ~= nil, "keyword sub must exist under its custom category")
    T.eq(#sub.items, 1, "keyword sub holds only the name-matching entry")
    T.eq(sub.items[1].name, "Warrior", "the matching unit, not the Archer")
end

function M.test_keyword_matches_instance_name_alias()
    -- A civ-grouped city carries the city name as instanceName; a keyword
    -- sub built from the city name must still catch it after the
    -- group-by-civ toggle renames itemName to the civ.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    local entries = {
        T.mkEntry("cities", "my", "Rome", 0, { itemKey = "civ:1", instanceName = "Antium" }),
        T.mkEntry("cities", "my", "Rome", 1, { itemKey = "civ:1", instanceName = "Cumae" }),
    }
    local snap = ScannerSnap.build(entries, 0, 0, { keywordDef({ "antium" }) })
    local sub = findSub(findCat(snap, "custom:1"), "kw:antium")
    T.eq(#sub.items, 1, "keyword sub must hold the alias-matching entry only")
    T.eq(#sub.items[1].instances, 1, "only the matching city, not its grouped sibling")
end

function M.test_keyword_sub_label_is_the_keyword_text()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSnap.build(
        { T.mkEntry("units_my", "melee", "Warrior", 0) },
        0,
        0,
        { keywordDef({ "warrior" }) }
    )
    local sub = findSub(findCat(snap, "custom:1"), "kw:warrior")
    T.eq(sub.labelText, "warrior", "keyword sub speaks the keyword via labelText, not a TXT_KEY")
end

function M.test_keyword_match_is_case_insensitive()
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    -- The keyword keeps its typed case for display but matches case-blind.
    local snap = ScannerSnap.build(
        { T.mkEntry("units_my", "melee", "Warrior", 0) },
        0,
        0,
        { keywordDef({ "WARRIOR" }) }
    )
    local sub = findSub(findCat(snap, "custom:1"), "kw:WARRIOR")
    T.eq(#sub.items, 1, "an upper-case keyword still matches a mixed-case name")
end

function M.test_keyword_and_selector_overlap_dedups_in_all()
    -- A Warrior matched by both a units_my:all selector and a "warrior"
    -- keyword lands in each sub's own item, sharing the instance, and appears
    -- in the custom `all` exactly once.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local def = keywordDef({ "warrior" }, { { cat = "units_my", sub = "all", label = "My Units" } })
    local snap = ScannerSnap.build({ T.mkEntry("units_my", "melee", "Warrior", 0) }, 0, 0, { def })
    local custom = findCat(snap, "custom:1")
    local selItem = findSub(custom, "units_my:all").items[1]
    local kwItem = findSub(custom, "kw:warrior").items[1]
    T.truthy(not rawequal(selItem, kwItem), "each sub keeps its own item object")
    T.truthy(rawequal(selItem.instances[1], kwItem.instances[1]), "but the two subs share the instance")
    T.eq(#custom.subcategories[1].items, 1, "custom `all` lists the overlapping name once")
    T.eq(#custom.subcategories[1].items[1].instances, 1, "and holds the single shared instance, not a duplicate")
end

function M.test_same_name_in_two_subs_does_not_contaminate()
    -- A custom category selecting melee units from two ownership categories
    -- must keep each ownership's Warrior in its own sub: navigating `my melee`
    -- never surfaces the neutral Warrior, and the per-sub count is not
    -- inflated. `all` still unions the two distinct warriors under one name.
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(3, 0, 1) })
    local def = {
        key = "custom:1",
        labelText = "Custom 1",
        selectors = {
            { cat = "units_my", sub = "melee", label = "My Melee" },
            { cat = "units_neutral", sub = "melee", label = "Neutral Melee" },
        },
    }
    local entries = {
        T.mkEntry("units_my", "melee", "Warrior", 0),
        T.mkEntry("units_neutral", "melee", "Warrior", 1),
    }
    local snap = ScannerSnap.build(entries, 0, 0, { def })
    local custom = findCat(snap, "custom:1")
    local mySub = findSub(custom, "units_my:melee")
    T.eq(#mySub.items, 1, "my-melee sub holds the one Warrior name")
    T.eq(#mySub.items[1].instances, 1, "and only my Warrior's instance, not the neutral one")
    T.eq(mySub.items[1].instances[1].plotX, 0, "the instance is my Warrior at plot 0")
    T.eq(#custom.subcategories[1].items, 1, "all lists the Warrior name once")
    T.eq(#custom.subcategories[1].items[1].instances, 2, "with both warriors' instances")
end

function M.test_keyword_prune_is_per_sub()
    -- Pruning an instance from one sub empties that sub's item without
    -- disturbing the other subs that share the instance; cross-sub staleness
    -- self-heals through ValidateEntry on the next landing, the same way a
    -- real category's subs do not prune each other.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local def = keywordDef({ "warrior" }, { { cat = "units_my", sub = "all", label = "My Units" } })
    local snap = ScannerSnap.build({ T.mkEntry("units_my", "melee", "Warrior", 0) }, 0, 0, { def })
    local custom = snap.categories[1]
    local kwIdx = subIndex(custom, "kw:warrior")
    ScannerSnap.pruneInstance(snap, 1, kwIdx, 1, 1)
    T.eq(#findSub(custom, "kw:warrior").items, 0, "pruned keyword sub is empty")
    T.eq(#findSub(custom, "units_my:all").items, 1, "the other sub is untouched until its own validate")
    T.eq(#custom.subcategories[1].items, 1, "and `all` is untouched until its own validate")
end

function M.test_each_keyword_gets_its_own_sub()
    setup()
    T.installMap({ mkPlot(0, 0, 0), mkPlot(1, 0, 1) })
    local entries = {
        T.mkEntry("units_my", "melee", "Warrior", 0),
        T.mkEntry("resources", "strategic", "Iron", 1),
    }
    local snap = ScannerSnap.build(entries, 0, 0, { keywordDef({ "warrior", "iron" }) })
    local custom = findCat(snap, "custom:1")
    T.eq(#findSub(custom, "kw:warrior").items, 1, "first keyword sub holds its match")
    T.eq(#findSub(custom, "kw:iron").items, 1, "second keyword sub holds its match")
    T.eq(#custom.subcategories[1].items, 2, "custom `all` unions both keyword matches")
end

return M

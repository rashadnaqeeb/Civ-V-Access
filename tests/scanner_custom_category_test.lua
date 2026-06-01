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

function M.test_custom_all_shares_ref_within_custom_category()
    -- Within the custom category the named selector sub and the implicit
    -- `all` must share one item object, so prune-by-identity works inside
    -- the custom category exactly as it does in a real one.
    setup()
    T.installMap({ mkPlot(0, 0, 0) })
    local snap = ScannerSnap.build({ T.mkEntry("units_my", "melee", "Warrior", 0) }, 0, 0, { unitsAllDef() })
    local custom = findCat(snap, "custom:1")
    local selItem = findSub(custom, "units_my:all").items[1]
    local allItem = custom.subcategories[1].items[1]
    T.truthy(rawequal(selItem, allItem), "selector-sub item and custom `all` item must be the same table")
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

return M

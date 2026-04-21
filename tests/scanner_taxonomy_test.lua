-- ScannerCore taxonomy invariants. The four cycle axes read positions in
-- these ordered tables, and every backend writes its entries against the
-- keys declared here; a silent reorder (or a key rename) would desync
-- backends from Nav without any one test elsewhere catching it.

local T = require("support")
local M = {}

local function setup()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
end

local function catKeys()
    local keys = {}
    for _, c in ipairs(ScannerCore.CATEGORIES) do
        keys[#keys + 1] = c.key
    end
    return keys
end

local function subKeys(catKey)
    local cat = ScannerCore.CATEGORIES_BY_KEY[catKey]
    local keys = {}
    for _, s in ipairs(cat.subcategories) do
        keys[#keys + 1] = s.key
    end
    return keys
end

function M.test_category_order_fixed()
    setup()
    local expected = {
        "cities",
        "units_my",
        "units_neutral",
        "units_enemy",
        "resources",
        "improvements",
        "special",
        "terrain",
    }
    local actual = catKeys()
    T.eq(#actual, #expected)
    for i, k in ipairs(expected) do
        T.eq(actual[i], k, "position " .. i)
    end
end

function M.test_categories_by_key_matches_list()
    setup()
    for _, c in ipairs(ScannerCore.CATEGORIES) do
        T.eq(
            ScannerCore.CATEGORIES_BY_KEY[c.key],
            c,
            "CATEGORIES_BY_KEY[" .. c.key .. "] must be identical to list entry"
        )
    end
end

function M.test_all_sub_not_listed_in_taxonomy()
    -- `all` is assembled by ScannerSnap at build time from sibling refs;
    -- listing it in the taxonomy would cause Snap to emit an extra empty
    -- sub ahead of the real `all`.
    setup()
    for _, cat in ipairs(ScannerCore.CATEGORIES) do
        for _, sub in ipairs(cat.subcategories) do
            T.truthy(sub.key ~= "all", "subcategory `all` must not appear in the taxonomy for " .. cat.key)
        end
    end
end

function M.test_unit_categories_share_role_subs()
    setup()
    local my = subKeys("units_my")
    local neutral = subKeys("units_neutral")
    local enemy = subKeys("units_enemy")
    -- my + neutral must be identical; enemy adds `barbarians`.
    T.eq(#my, #neutral, "my vs neutral count")
    for i, k in ipairs(my) do
        T.eq(neutral[i], k, "my/neutral position " .. i)
    end
    T.eq(#enemy, #my + 1, "enemy adds one sub")
    T.eq(enemy[#enemy], "barbarians", "barbarians must be the last enemy-units sub so it doesn't reorder shared subs")
end

function M.test_cities_subs()
    setup()
    local subs = subKeys("cities")
    local expected = { "my", "neutral", "enemy", "barb" }
    for i, k in ipairs(expected) do
        T.eq(subs[i], k, "cities position " .. i)
    end
end

function M.test_resources_subs_in_usage_order()
    -- Ordered Strategic, Luxury, Bonus: player-facing heading order matches
    -- how the game's own resource advisor groups them.
    setup()
    local subs = subKeys("resources")
    T.eq(subs[1], "strategic")
    T.eq(subs[2], "luxury")
    T.eq(subs[3], "bonus")
end

function M.test_improvements_subs_owner_order()
    setup()
    local subs = subKeys("improvements")
    T.eq(subs[1], "my")
    T.eq(subs[2], "neutral")
    T.eq(subs[3], "enemy")
end

function M.test_special_subs()
    setup()
    local subs = subKeys("special")
    T.eq(subs[1], "natural_wonders")
    T.eq(subs[2], "ancient_ruins")
end

function M.test_terrain_subs()
    setup()
    local subs = subKeys("terrain")
    T.eq(subs[1], "base")
    T.eq(subs[2], "features")
    T.eq(subs[3], "elevation")
end

function M.test_all_category_labels_resolve_to_text_keys()
    setup()
    for _, cat in ipairs(ScannerCore.CATEGORIES) do
        T.truthy(
            type(cat.label) == "string" and cat.label:match("^TXT_KEY_"),
            cat.key .. " category must carry a TXT_KEY_ label, got " .. tostring(cat.label)
        )
        for _, sub in ipairs(cat.subcategories) do
            T.truthy(
                type(sub.label) == "string" and sub.label:match("^TXT_KEY_"),
                cat.key .. "." .. sub.key .. " sub must carry a TXT_KEY_ label"
            )
        end
    end
end

function M.test_register_backend_rejects_bad_shape()
    setup()
    local errs = 0
    Log.error = function()
        errs = errs + 1
    end
    ScannerCore.registerBackend(nil)
    ScannerCore.registerBackend({})
    ScannerCore.registerBackend({ name = "bad", Scan = function() end })
    T.eq(errs, 3, "each malformed backend must hit Log.error")
    T.eq(#ScannerCore.BACKENDS, 0, "none should land in the registry")
end

function M.test_register_backend_accepts_complete_shape()
    setup()
    ScannerCore.registerBackend({
        name = "ok",
        Scan = function()
            return {}
        end,
        ValidateEntry = function()
            return true
        end,
        FormatName = function()
            return "x"
        end,
    })
    T.eq(#ScannerCore.BACKENDS, 1)
end

return M

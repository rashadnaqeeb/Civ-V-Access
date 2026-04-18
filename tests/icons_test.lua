-- Icon registration. Loads CivVAccess_Icons against a live TextFilter and
-- the in-game strings module, then asserts that the filter swaps each
-- bracket token for the expected localized spoken form. Includes base-game
-- typo variants (ICON_HAPPINES_4, ICON_STRENGHT, ICON_CULTUR) to guard
-- against accidental drift: if one of these stops mapping to its correct
-- counterpart the screen reader will emit garbage on the next game patch.

local T = require("support")
local M = {}

local function setup()
    Log.warn  = function() end
    Log.error = function() end
    Log.info  = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    -- Fresh strings + Text so Icons.lua resolves keys through the same
    -- CivVAccess_Strings table the production include chain uses.
    CivVAccess_Strings = {}
    dofile("src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Icons.lua")
end

local function filtered(name)
    return TextFilter.filter("[" .. name .. "]")
end

-- Yields ------------------------------------------------------------------

function M.test_yield_icons_resolve()
    setup()
    T.eq(filtered("ICON_GOLD"),       "gold")
    T.eq(filtered("ICON_FOOD"),       "food")
    T.eq(filtered("ICON_PRODUCTION"), "production")
    T.eq(filtered("ICON_CULTURE"),    "culture")
    T.eq(filtered("ICON_SCIENCE"),    "science")
    T.eq(filtered("ICON_RESEARCH"),   "research")
    T.eq(filtered("ICON_FAITH"),      "faith")
    T.eq(filtered("ICON_TOURISM"),    "tourism")
end

-- ICON_PEACE is the pre-BNW faith glyph; pedia still uses it for the
-- unit faith-purchase cost ("240 [ICON_PEACE]") so it must speak "faith".
function M.test_icon_peace_speaks_faith()
    setup()
    T.eq(filtered("ICON_PEACE"), "faith")
end

-- Combat ------------------------------------------------------------------

function M.test_combat_icons_resolve()
    setup()
    T.eq(filtered("ICON_STRENGTH"),       "combat strength")
    T.eq(filtered("ICON_RANGE_STRENGTH"), "ranged strength")
    T.eq(filtered("ICON_MOVES"),          "movement")
end

-- Happiness (positive / negative split) -----------------------------------

function M.test_happiness_icons_split_positive_and_negative()
    setup()
    T.eq(filtered("ICON_HAPPINESS_1"), "happy")
    T.eq(filtered("ICON_HAPPINESS_3"), "unhappy")
    T.eq(filtered("ICON_HAPPINESS_4"), "unhappy")
end

-- Resources ---------------------------------------------------------------

function M.test_resource_icons_resolve()
    setup()
    T.eq(filtered("ICON_RES_IRON"),  "iron")
    T.eq(filtered("ICON_RES_HORSE"), "horses")
    T.eq(filtered("ICON_RES_WHALE"), "whales")
    -- Game text uses ICON_RES_COW; "cattle" is the screen-reader-friendly
    -- spoken form (the engine label for the resource).
    T.eq(filtered("ICON_RES_COW"),   "cattle")
end

function M.test_res_gold_disambiguated_from_currency()
    setup()
    -- ICON_GOLD is the currency; ICON_RES_GOLD is the tile resource. They
    -- must speak differently so a sentence like "Gold mines produce [ICON_GOLD]"
    -- isn't ambiguous.
    T.eq(filtered("ICON_GOLD"),      "gold")
    T.eq(filtered("ICON_RES_GOLD"),  "gold ore")
end

-- Religions ---------------------------------------------------------------

function M.test_religion_icons_resolve()
    setup()
    T.eq(filtered("ICON_RELIGION"),                  "religion")
    T.eq(filtered("ICON_RELIGION_PANTHEON"),         "pantheon")
    T.eq(filtered("ICON_RELIGION_CHRISTIANITY"),     "Christianity")
    T.eq(filtered("ICON_RELIGION_ISLAM"),            "Islam")
    T.eq(filtered("ICON_RELIGION_ZOROASTRIANISM"),   "Zoroastrianism")
end

-- Base-game typos map to the same spoken form as the correct spelling.
-- Ensures the user never hears a typo'd icon stripped to silence and
-- never hears the typo token itself spelled out.

function M.test_typo_happines_4_maps_to_unhappy()
    setup()
    T.eq(filtered("ICON_HAPPINES_4"),  "unhappy")
    T.eq(filtered("ICON_HAPPINESS_4"), "unhappy")
end

function M.test_typo_strenght_maps_to_combat_strength()
    setup()
    T.eq(filtered("ICON_STRENGHT"), "combat strength")
    T.eq(filtered("ICON_STRENGTH"), "combat strength")
end

function M.test_typo_aluminnum_maps_to_aluminum()
    setup()
    T.eq(filtered("ICON_RES_ALUMINNUM"), "aluminum")
    T.eq(filtered("ICON_RES_ALUMINUM"),  "aluminum")
end

function M.test_typo_cultur_maps_to_culture()
    setup()
    T.eq(filtered("ICON_CULTUR"),  "culture")
    T.eq(filtered("ICON_CULTURE"), "culture")
end

function M.test_typo_greatpeople_maps_to_great_people()
    setup()
    T.eq(filtered("ICON_GREATPEOPLE"),  "great people")
    T.eq(filtered("ICON_GREAT_PEOPLE"), "great people")
end

function M.test_connection_alias_matches_connected()
    setup()
    T.eq(filtered("ICON_CONNECTION"), "connected")
    T.eq(filtered("ICON_CONNECTED"),  "connected")
end

-- Glyphs ------------------------------------------------------------------

function M.test_arrow_glyphs_resolve()
    setup()
    T.eq(filtered("ICON_ARROW_LEFT"),  "left")
    T.eq(filtered("ICON_ARROW_RIGHT"), "right")
    T.eq(filtered("ICON_PLUS"),        "plus")
    T.eq(filtered("ICON_MINUS"),       "minus")
end

function M.test_bullet_resolves_to_empty_silence()
    setup()
    -- Bullets are visual-only separators; the spoken form is "" so the
    -- token vanishes without a miss-warn firing for every pedia article.
    T.eq(TextFilter.filter("[ICON_BULLET]item one"), "item one")
end

-- Composed: unit cost with icon substitution --------------------------------

function M.test_unit_production_cost_speaks_cleanly()
    setup()
    -- Matches the pedia's "tostring(cost) .. ' [ICON_PRODUCTION]'" pattern.
    T.eq(TextFilter.filter("40 [ICON_PRODUCTION]"), "40 production")
end

function M.test_tech_cost_speaks_cleanly()
    setup()
    T.eq(TextFilter.filter("120 [ICON_RESEARCH]"), "120 research")
end

function M.test_unit_faith_cost_speaks_cleanly()
    setup()
    -- [ICON_PEACE] is the faith-purchase glyph on units (see
    -- CivilopediaScreen.lua's Unit handler: costString for faithCost > 0).
    T.eq(TextFilter.filter("240 [ICON_PEACE]"), "240 faith")
end

return M

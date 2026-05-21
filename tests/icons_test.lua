-- Icon registration. Loads CivVAccess_Icons against a live TextFilter and
-- the in-game strings module, then asserts that the filter swaps each
-- bracket token for the expected localized spoken form. Includes base-game
-- typo variants (ICON_HAPPINES_4, ICON_STRENGHT, ICON_CULTUR) to guard
-- against accidental drift: if one of these stops mapping to its correct
-- counterpart the screen reader will emit garbage on the next game patch.

local T = require("support")
local M = {}

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
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
    T.eq(filtered("ICON_GOLD"), "gold")
    T.eq(filtered("ICON_FOOD"), "food")
    T.eq(filtered("ICON_PRODUCTION"), "production")
    T.eq(filtered("ICON_CULTURE"), "culture")
    T.eq(filtered("ICON_SCIENCE"), "science")
    T.eq(filtered("ICON_RESEARCH"), "science")
    T.eq(filtered("ICON_FAITH"), "faith")
    T.eq(filtered("ICON_TOURISM"), "tourism")
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
    T.eq(filtered("ICON_STRENGTH"), "combat strength")
    T.eq(filtered("ICON_RANGE_STRENGTH"), "ranged combat strength")
    T.eq(filtered("ICON_MOVES"), "moves")
end

-- Happiness (positive / negative split) -----------------------------------

function M.test_happiness_icons_split_positive_and_negative()
    setup()
    T.eq(filtered("ICON_HAPPINESS_1"), "happiness")
    T.eq(filtered("ICON_HAPPINESS_3"), "unhappiness")
    T.eq(filtered("ICON_HAPPINESS_4"), "unhappiness")
end

-- Arrows. Trade columns and a few tutorial glyphs use these standalone,
-- so the direction has to speak.
function M.test_arrow_glyphs_resolve()
    setup()
    T.eq(filtered("ICON_ARROW_LEFT"), "left")
    T.eq(filtered("ICON_ARROW_RIGHT"), "right")
end

-- Base-game typos map to the same spoken form as the correct spelling.
-- Ensures the user never hears a typo'd icon stripped to silence and
-- never hears the typo token itself spelled out.

function M.test_typo_happines_4_maps_to_unhappiness()
    setup()
    T.eq(filtered("ICON_HAPPINES_4"), "unhappiness")
    T.eq(filtered("ICON_HAPPINESS_4"), "unhappiness")
end

function M.test_typo_strenght_maps_to_combat_strength()
    setup()
    T.eq(filtered("ICON_STRENGHT"), "combat strength")
    T.eq(filtered("ICON_STRENGTH"), "combat strength")
end

function M.test_typo_cultur_maps_to_culture()
    setup()
    T.eq(filtered("ICON_CULTUR"), "culture")
    T.eq(filtered("ICON_CULTURE"), "culture")
end

-- Dropped categories fall through to the catch-all stripper and vanish.
-- Asserts the policy: resources, religions, victories, city-status
-- glyphs, etc. are always paired with their label word in game text,
-- so substituting them would just double the noun. The text that
-- survives must be exactly what the source said, minus the icon.

function M.test_dropped_resource_icon_is_stripped()
    setup()
    T.eq(TextFilter.filter("on [ICON_RES_COW] Cows"), "on Cows")
    T.eq(TextFilter.filter("and [ICON_RES_SHEEP] Sheep"), "and Sheep")
end

function M.test_dropped_religion_icon_is_stripped()
    setup()
    T.eq(TextFilter.filter("spread [ICON_RELIGION_ISLAM] Islam"), "spread Islam")
end

function M.test_dropped_city_status_icon_is_stripped()
    setup()
    T.eq(TextFilter.filter("[ICON_RAZING] Razed"), "Razed")
    T.eq(TextFilter.filter("[ICON_CONNECTED] Connected"), "Connected")
end

-- Alias dedup. Primary spoken form stays the substitution, but adjacent
-- grammatical variants that the `s?` suffix rule can't bridge collapse too.

function M.test_happiness_1_collapses_against_happy()
    setup()
    T.eq(TextFilter.filter("+1 [ICON_HAPPINESS_1] Happy City"), "+1 Happy City")
    -- And the primary still collapses against "Happiness".
    T.eq(TextFilter.filter("+1 [ICON_HAPPINESS_1] Happiness"), "+1 Happiness")
    -- A bare token with no neighboring word still speaks the primary form.
    T.eq(TextFilter.filter("+1 [ICON_HAPPINESS_1]"), "+1 happiness")
end

function M.test_happiness_4_collapses_against_unhappy()
    setup()
    T.eq(TextFilter.filter("source of [ICON_HAPPINESS_4] unhappy mood"), "source of unhappy mood")
    T.eq(TextFilter.filter("[ICON_HAPPINESS_4] Unhappiness doubled"), "Unhappiness doubled")
end

-- Engine text routinely inserts a qualifier ("Local", "Global", "Very",
-- "Public Opinion", ...) between the icon and the labelled noun -- e.g.
-- Expansion2 ideology tenets that emit "+1 [ICON_HAPPINESS_1] Local
-- Happiness from every Water Mill". The dedup matcher peeks past one or
-- two short alphabetic words so the user hears "Local Happiness" once,
-- not "happiness Local Happiness".
function M.test_happiness_collapses_past_local_qualifier()
    setup()
    T.eq(
        TextFilter.filter("+1 [ICON_HAPPINESS_1] Local Happiness from every Water Mill"),
        "+1 Local Happiness from every Water Mill"
    )
end

function M.test_unhappy_collapses_past_very_qualifier()
    setup()
    T.eq(TextFilter.filter("[ICON_HAPPINESS_4] Very Unhappy"), "Very Unhappy")
end

function M.test_happiness_collapses_past_two_qualifier_words()
    setup()
    T.eq(TextFilter.filter("[ICON_HAPPINESS_1] Public Opinion Happiness shifts"), "Public Opinion Happiness shifts")
end

-- Three intervening words is past a clause boundary -- the icon stays
-- spoken so its meaning isn't lost when the matching word is far away.
function M.test_happiness_does_not_collapse_past_three_words()
    setup()
    T.eq(
        TextFilter.filter("[ICON_HAPPINESS_1] for the empire happiness boost"),
        "happiness for the empire happiness boost"
    )
end

-- Digits / punctuation between the icon and a later label abort the
-- look-ahead -- "10 turns" in the way means the trailing "happiness" is
-- in a different clause, not the icon's label.
function M.test_qualifier_skip_aborts_on_digit()
    setup()
    T.eq(TextFilter.filter("[ICON_HAPPINESS_1] 10 happiness boost"), "happiness 10 happiness boost")
end

-- [ICON_MOVES] sits next to the noun "Movement" in ability prose on
-- either side -- Denmark's Viking Fury "+1 Movement [ICON_MOVES]" and the
-- BNW scenarios' "+1 [ICON_MOVES] Movement". The "moves" primary can't
-- bridge to "Movement", so the alias collapses it; a bare token with no
-- adjacent noun still speaks "moves" (pedia's "N [ICON_MOVES]").
function M.test_moves_collapses_against_movement_noun()
    setup()
    T.eq(
        TextFilter.filter("Embarked units have +1 Movement [ICON_MOVES] and pay"),
        "Embarked units have +1 Movement and pay"
    )
    T.eq(TextFilter.filter("+1 [ICON_MOVES] Movement"), "+1 Movement")
    T.eq(TextFilter.filter("2 [ICON_MOVES]"), "2 moves")
end

-- [ICON_CULTURE] sits next to the adjective "Cultural" in pedia prose
-- ("[ICON_CULTURE] Cultural output of a city"). The "culture" primary
-- can't bridge to "Cultural", so the alias collapses it; the primary
-- still collapses against the bare noun, and a bare token still speaks.
function M.test_culture_collapses_against_cultural_adjective()
    setup()
    T.eq(
        TextFilter.filter("increases the [ICON_CULTURE] Cultural output of a city"),
        "increases the Cultural output of a city"
    )
    T.eq(TextFilter.filter("+3 [ICON_CULTURE] Culture"), "+3 Culture")
    T.eq(TextFilter.filter("+3 [ICON_CULTURE]"), "+3 culture")
end

-- Typo-variant icons inherit aliases from their canonical TXT_KEY. A base
-- text with the misspelled ICON_HAPPINES_4 next to "unhappy" should collapse
-- just like ICON_HAPPINESS_4 does.
function M.test_typo_happines_4_collapses_against_unhappy()
    setup()
    T.eq(TextFilter.filter("[ICON_HAPPINES_4] unhappy"), "unhappy")
end

-- Composed: unit cost with icon substitution --------------------------------

function M.test_unit_production_cost_speaks_cleanly()
    setup()
    -- Matches the pedia's "tostring(cost) .. ' [ICON_PRODUCTION]'" pattern.
    T.eq(TextFilter.filter("40 [ICON_PRODUCTION]"), "40 production")
end

function M.test_tech_cost_speaks_cleanly()
    setup()
    T.eq(TextFilter.filter("120 [ICON_RESEARCH]"), "120 science")
end

function M.test_unit_faith_cost_speaks_cleanly()
    setup()
    -- [ICON_PEACE] is the faith-purchase glyph on units (see
    -- CivilopediaScreen.lua's Unit handler: costString for faithCost > 0).
    T.eq(TextFilter.filter("240 [ICON_PEACE]"), "240 faith")
end

-- The dedup check must see past a [COLOR_*]...[ENDCOLOR] wrapper that
-- sits between the icon and its label. Civ's pedia wraps many labels
-- this way ("[ICON_GOLD] [COLOR_POSITIVE_TEXT]Gold[ENDCOLOR]"); without
-- stripping the color tags first, the dedup used to miss and the user
-- heard "gold Gold".
function M.test_icon_dedup_sees_past_color_wrapper()
    setup()
    T.eq(TextFilter.filter("spend [ICON_GOLD] [COLOR_POSITIVE_TEXT]Gold[ENDCOLOR] to buy"), "spend Gold to buy")
end

return M

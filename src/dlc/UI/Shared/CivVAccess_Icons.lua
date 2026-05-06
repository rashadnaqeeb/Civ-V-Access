-- Icon spoken-text registry. Maps [ICON_*] tokens to TXT_KEY_CIVVACCESS_ICON_*
-- strings, then hands the resolved text to TextFilter.registerIcon. After this
-- include runs the filter's substituteIcons pass replaces bracket tokens in
-- speech with the localizable spoken form (e.g. "[ICON_PRODUCTION]" ->
-- "production"). Unregistered icons fall through to the catch-all bracket
-- stripper and vanish silently.
--
-- Policy: we only register icons that carry information the surrounding text
-- does not repeat. The diagnostic: an icon is worth speaking when it appears
-- alone or after a bare number ("120 [ICON_RESEARCH]" or "+3 [ICON_HAPPINESS_1]"),
-- because there the icon IS the label. Icons that sit next to the word they
-- represent ("[ICON_RES_COW] Cows", "[ICON_RELIGION_ISLAM] Islam",
-- "[ICON_GOLDEN_AGE] Golden Age") are purely decorative for sighted players;
-- speaking them doubles the noun ("cattle Cows", "Islam Islam") without
-- adding information. Those categories are left out of the registry on
-- purpose: the filter's catch-all strips them to nothing.
--
-- Include order requirement: must load AFTER CivVAccess_TextFilter,
-- CivVAccess_<Context>Strings_<locale>, and CivVAccess_Text so Text.key can
-- resolve the TXT_KEYs into mapped strings at registration time. Loading it
-- earlier registers "TXT_KEY_CIVVACCESS_ICON_X" as the literal spoken form,
-- which is worse than the default strip behavior.
--
-- Base-game text ships with occasional typo variants of icon names
-- (HAPPINES_4, STRENGHT, CULTUR). We map those to the same TXT_KEY as their
-- correctly-spelled counterpart so the screen-reader user never hears a typo
-- or a dropped token.

local ICON_KEYS = {
    -- Yields -------------------------------------------------------------
    ICON_GOLD = "TXT_KEY_CIVVACCESS_ICON_GOLD",
    ICON_FOOD = "TXT_KEY_CIVVACCESS_ICON_FOOD",
    ICON_PRODUCTION = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION",
    ICON_CULTURE = "TXT_KEY_CIVVACCESS_ICON_CULTURE",
    ICON_CULTUR = "TXT_KEY_CIVVACCESS_ICON_CULTURE",
    ICON_SCIENCE = "TXT_KEY_CIVVACCESS_ICON_SCIENCE",
    ICON_RESEARCH = "TXT_KEY_CIVVACCESS_ICON_RESEARCH",
    ICON_FAITH = "TXT_KEY_CIVVACCESS_ICON_FAITH",
    -- ICON_PEACE is the pre-BNW faith glyph; pedia still uses it for the
    -- faith-purchase cost on units (costString = cost .. " [ICON_PEACE]").
    ICON_PEACE = "TXT_KEY_CIVVACCESS_ICON_FAITH",
    ICON_TOURISM = "TXT_KEY_CIVVACCESS_ICON_TOURISM",
    -- Specialist slots / GP-progress rows show "+N[ICON_GREAT_PEOPLE]"
    -- standalone (no adjacent label), so the icon carries the word.
    -- Pedia and tooltip prose pair it with "Great People" / "Great Person",
    -- handled by the dedup adjacency check + the alias below.
    ICON_GREAT_PEOPLE = "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE",

    -- Combat / movement --------------------------------------------------
    ICON_STRENGTH = "TXT_KEY_CIVVACCESS_ICON_STRENGTH",
    ICON_STRENGHT = "TXT_KEY_CIVVACCESS_ICON_STRENGTH",
    ICON_RANGE_STRENGTH = "TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH",
    ICON_MOVES = "TXT_KEY_CIVVACCESS_ICON_MOVEMENT",
    ICON_MOVEMENT = "TXT_KEY_CIVVACCESS_ICON_MOVEMENT",

    -- Happiness (HAPPINESS_1 is the positive face; 3 / 4 are negatives,
    -- and the engine labels them all "unhappy" in context) --------------
    ICON_HAPPINESS_1 = "TXT_KEY_CIVVACCESS_ICON_HAPPY",
    ICON_HAPPINESS = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",
    ICON_HAPPINESS_3 = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",
    ICON_HAPPINESS_4 = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",
    ICON_HAPPINES_4 = "TXT_KEY_CIVVACCESS_ICON_UNHAPPY",

    -- Arrows. Appear as standalone glyphs in trade-column headers and a
    -- handful of tutorial arrows; no adjacent label, so they carry the
    -- directional meaning themselves. --------------------------------
    ICON_ARROW_LEFT = "TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT",
    ICON_ARROW_RIGHT = "TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT",
}

-- Dedup-only aliases keyed by the primary TXT_KEY. An icon's spoken form is
-- still the primary; aliases are additional adjacent forms the word-boundary
-- check should treat as the same concept so the substitution collapses.
-- Keyed by primary TXT_KEY rather than ICON_ name so the typo-variant icons
-- (ICON_HAPPINES_4) inherit the aliases of their canonical counterpart
-- without repeating the list. Per-locale: each strings file defines its own
-- _ALT keys, so a translator only needs to list equivalents in their
-- language here (English-specific helpers like `s?` in TextFilter will not
-- help German / Japanese / etc.).
local ALIAS_KEYS = {
    ["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = { "TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT" },
    ["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = { "TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT" },
    -- ALT covers the singular pairing in base text ("a Great Person of
    -- your choice"). The four ALT_<SPECIALIST> entries collapse the icon
    -- against the "Great X Points:" / "Points d'X illustres :" line the
    -- engine emits at GetHelpTextForBuilding.lua:265 -- one alias per
    -- specialist title because the English and French phrasings differ
    -- per specialist (English uses "Great X Points:"; French uses
    -- "Points d'artistes/d'ingénieurs/de savants illustres :" or
    -- "Points marchands illustres :", with no shared prefix). A broader
    -- alias like "great" / "grand" would over-collapse on unrelated
    -- adjacent text ("Great Wall", "Grande Muraille", etc.).
    ["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = {
        "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT",
        "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST",
        "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER",
        "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT",
        "TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST",
    },
    -- The engine's TXT_KEY_PRODUCTION_STRENGTH formats unit strength as
    -- "[ICON_STRENGTH] Strength: N" — adjacent to the icon's spoken form
    -- "combat strength", that reads "combat strength Strength: 50". The
    -- _ALT alias collapses on the bare "Strength" word so the doubled
    -- "strength" goes away.
    ["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = { "TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT" },
    -- Same pattern for ranged units: TXT_KEY_PRODUCTION_RANGED_STRENGTH
    -- emits "[ICON_RANGE_STRENGTH] Ranged Strength: N", adjacent to the
    -- icon's "ranged combat strength". Alias collapses on "Ranged Strength".
    ["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = { "TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT" },
}

for name, key in pairs(ICON_KEYS) do
    local aliases = {}
    local aliasKeys = ALIAS_KEYS[key]
    if aliasKeys then
        for _, aliasKey in ipairs(aliasKeys) do
            aliases[#aliases + 1] = Text.key(aliasKey)
        end
    end
    TextFilter.registerIcon(name, Text.key(key), aliases)
end

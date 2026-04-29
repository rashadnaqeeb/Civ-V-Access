-- Mod-authored strings for the surveyor, in-game Context. Extends the
-- CivVAccess_Strings table that CivVAccess_InGameStrings_en_US.lua sets
-- up; include order in Boot places the base InGame strings first so this
-- file can append.
--
-- The surveyor answers "what is in a radius around the cursor" questions:
-- yields, resources, terrain, friendly units, enemy units, and cities. Each
-- of the six scope queries (yields / resources / terrain / own units /
-- enemy units / cities) has its own Shift+letter binding documented in the
-- help-overlay block below. See the translator orientation block at the
-- top of CivVAccess_InGameStrings_en_US.lua for the conventions that
-- apply across all in-game string files.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Radius announcements =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS"] = "radius {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MIN"] = "radius {1_N} min"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MAX"] = "radius {1_N} max"

-- ===== Per-scope empty-range fallbacks =====
-- Kept literal per scope so the user hears which axis came up dry rather
-- than a generic "nothing in range" that forces them to remember which
-- key they just pressed.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_YIELDS"] = "no yields in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_RESOURCES"] = "no resources in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_TERRAIN"] = "no terrain in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_OWN_UNITS"] = "no own units in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_ENEMY_UNITS"] = "no enemy units in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_CITIES"] = "no cities in range"

-- ===== Unexplored suffix =====
-- Plural-form bundle: forms keyed by CLDR keyword (one / few / many /
-- other), selected at format time by PluralRules for the active locale.
-- Looked up via Text.formatPlural; the count is passed once for plural
-- selection and again as the {1_N} substitution arg.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_UNEXPLORED_SUFFIX"] = {
    one = "{1_N} tile unexplored",
    other = "{1_N} tiles unexplored",
}

-- ===== Help overlay entries =====
-- One entry per scope key; radius grow / shrink share a label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RADIUS"] = "Shift plus W or X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RADIUS"] = "Grow or shrink surveyor radius"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_YIELDS"] = "Shift plus Q"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_YIELDS"] = "Sum yields in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RESOURCES"] = "Shift plus A"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RESOURCES"] = "Count resources in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_TERRAIN"] = "Shift plus Z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_TERRAIN"] = "Count terrain and features in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_OWN_UNITS"] = "Shift plus E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_OWN_UNITS"] = "List own units in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_ENEMY_UNITS"] = "Shift plus D"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_ENEMY_UNITS"] = "List enemy units in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_CITIES"] = "Shift plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_CITIES"] = "List cities in range, closest first"

-- Apply the active locale's overlay so every Context that includes this
-- baseline gets the localized overrides. WorldView's Boot includes this
-- file; the explicit StringsLoader call here keeps any future Context that
-- chooses to include surveyor strings standalone from speaking English.
include("CivVAccess_StringsLoader")
StringsLoader.loadOverlay("CivVAccess_SurveyorStrings")

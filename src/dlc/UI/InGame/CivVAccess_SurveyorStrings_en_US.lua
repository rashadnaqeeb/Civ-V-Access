-- Mod-authored strings for the surveyor, in-game Context. Extends the
-- CivVAccess_Strings table that CivVAccess_InGameStrings_en_US.lua sets
-- up; include order in Boot places the base InGame strings first so this
-- file can append.
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_HILLS"] = "no hills in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_CITIES"] = "no cities in range"

-- ===== Cities group labels =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_CITIES_FRIENDLY"] = "friendly"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_CITIES_HOSTILE"] = "hostile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_CITIES_NEUTRAL"] = "neutral"

-- ===== Repeated per-instance labels =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HILL"] = "hill"

-- ===== Unexplored suffix =====
-- Singular/plural relaxed to "tiles" across the board; mirrors the icon
-- strings convention that screen-reader users tolerate minor grammar over
-- awkward branching.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_UNEXPLORED_SUFFIX"] = "{1_N} tiles unexplored"

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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_HILLS"] = "Shift plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_HILLS"] = "List hills in range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_CITIES"] = "Shift plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_CITIES"] = "List cities in range grouped by diplomacy"

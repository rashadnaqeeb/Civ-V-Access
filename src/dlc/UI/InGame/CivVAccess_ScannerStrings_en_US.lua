-- Mod-authored strings for the scanner, in-game Context.
-- Every key is prefixed TXT_KEY_CIVVACCESS_SCANNER_ per design section 11.
-- Extends the shared CivVAccess_Strings table already populated by
-- CivVAccess_InGameStrings_en_US.lua; include order in Boot places the
-- base InGame strings first so this file can freely assume the table
-- exists.
--
-- The scanner is the keyboard-driven map enumerator: a hierarchy of
-- categories (cities, units, improvements, etc.) and subcategories that
-- the user pages through with PageUp / PageDown chords. Every string in
-- this file is spoken by Tolk through the screen reader; see the
-- translator orientation block at the top of CivVAccess_InGameStrings_en_US.lua
-- for the conventions that apply (lead with the distinguishing word, no
-- decorative punctuation, plural-form bundles use CLDR keywords).
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
-- Cities category uses the game's TXT_KEY_CITIES_HEADING1_TITLE ("Cities")
-- at the category level; these are its four subcategory labels.
-- Category and subcategory labels are title-cased to match the engine's
-- own headings (TXT_KEY_CITIES_HEADING1_TITLE et al). Inline status tokens
-- like "here" / "empty" further down stay lowercase because they tail
-- another phrase rather than head a section.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "My Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Neutral Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Enemy Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Barbarian Camps"
-- The three unit categories are top-level category labels (not subs).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "My Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Neutral Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Enemy Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Improvements"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Special"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Recommendations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Waypoints"
-- The city-site rec name lives in InGameStrings_en_US because both the
-- scanner and the cursor glance reference it; keeping it here would hide
-- it from the offline test harness, which only loads InGameStrings.

-- ===== Subcategory labels without a clean game key =====
-- Ranged / Siege / Naval / Air / Great People / Strategic / Luxury /
-- Bonus / Natural Wonders / Ancient Ruins reuse game keys directly;
-- only these subs are mod-authored.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "All"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Melee Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Mounted Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Civilian Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Barbarians"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "My"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Enemy"
-- Terrain subs. Features reuses the game's TXT_KEY_TERRAIN_FEATURES_HEADING2_TITLE;
-- these two have no clean game equivalent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Base Terrain"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Elevation"

-- ===== Announcement fragments =====
-- Positional count tail. Carves out an exception to the concise-
-- announcement rule that forbids "N of M" for menus: here it carries
-- real information (how many swordsmen you have, which one you're on).
-- Placeholders so localisation can reorder.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} of {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "empty"

-- ===== Auto-move toggle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_ON"] = "auto move on"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_OFF"] = "auto move off"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "no jump to return from"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "search"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "search results"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"

-- ===== Help overlay entries =====
-- Merged chord labels following the existing cursor help convention so
-- HandlerStack.collectHelpEntries can dedupe by keyLabel string across
-- stacked handlers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "Cycle item within subcategory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Shift plus page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "Cycle subcategory within category"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control plus page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "Cycle category, rebuilds snapshot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt plus page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "Cycle instance within item"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Home"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "Jump cursor to current entry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "Distance and direction from cursor to entry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_AUTO_MOVE"] = "Shift plus end"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_AUTO_MOVE"] = "Toggle auto move cursor on cycle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Search scanner entries"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Return cursor to pre-jump cell"

-- Apply the active locale's overlay so every Context that includes this
-- baseline gets the localized overrides. WorldView's Boot includes this
-- file; the explicit StringsLoader call here keeps any future Context that
-- chooses to include scanner strings standalone from speaking English.
include("CivVAccess_StringsLoader")
StringsLoader.loadOverlay("CivVAccess_ScannerStrings")

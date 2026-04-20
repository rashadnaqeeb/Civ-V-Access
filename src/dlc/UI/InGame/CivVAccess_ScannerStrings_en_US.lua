-- Mod-authored strings for the scanner, in-game Context.
-- Every key is prefixed TXT_KEY_CIVVACCESS_SCANNER_ per design section 11.
-- Extends the shared CivVAccess_Strings table already populated by
-- CivVAccess_InGameStrings_en_US.lua; include order in Boot places the
-- base InGame strings first so this file can freely assume the table
-- exists.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
-- Cities category uses the game's TXT_KEY_CITIES_HEADING1_TITLE ("Cities")
-- at the category level; these are its four subcategory labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"]         = "My Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"]    = "Neutral Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"]      = "Enemy Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Barbarian Camps"
-- The three unit categories are top-level category labels (not subs).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"]          = "My Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"]     = "Neutral Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"]       = "Enemy Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"]      = "Improvements"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"]           = "Special"

-- ===== Subcategory labels without a clean game key =====
-- Ranged / Siege / Naval / Air / Great People / Strategic / Luxury /
-- Bonus / Natural Wonders / Ancient Ruins reuse game keys directly;
-- only these subs are mod-authored.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"]                    = "All"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"]                  = "Melee Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"]                = "Mounted Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"]               = "Civilian Units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"]             = "Barbarians"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"]                     = "My"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"]                = "Neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"]                  = "Enemy"

-- ===== Announcement fragments =====
-- Positional count tail. Carves out an exception to the concise-
-- announcement rule that forbids "N of M" for menus: here it carries
-- real information (how many swordsmen you have, which one you're on).
-- Placeholders so localisation can reorder.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"]             = "{1_Index} of {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"]                       = "here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"]                      = "empty"

-- ===== Auto-move toggle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_ON"]               = "auto move on"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_OFF"]              = "auto move off"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"]             = "no jump to return from"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"]              = "search"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"]             = "search results"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"]            = "no match for {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_CLEARED"]             = "search cleared"

-- ===== Help overlay entries =====
-- Merged chord labels following the existing cursor help convention so
-- HandlerStack.collectHelpEntries can dedupe by keyLabel string across
-- stacked handlers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"]              = "Page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"]             = "Cycle item within subcategory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"]               = "Shift plus page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"]              = "Cycle subcategory within category"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"]          = "Control plus page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"]         = "Cycle category, rebuilds snapshot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"]          = "Alt plus page up or page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"]         = "Cycle instance within item"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"]              = "Home"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"]             = "Jump cursor to current entry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"]          = "End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"]         = "Distance and direction from cursor to entry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_AUTO_MOVE"]         = "Shift plus end"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_AUTO_MOVE"]        = "Toggle auto move cursor on cycle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"]            = "Control plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"]           = "Search scanner entries"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"]            = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"]           = "Return cursor to pre-jump cell"

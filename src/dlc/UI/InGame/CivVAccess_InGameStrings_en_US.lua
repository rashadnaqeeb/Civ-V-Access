-- Mod-authored localized strings, in-game Context.
-- Looked up by Text.key / Text.format in CivVAccess_Text.lua. Sets a global
-- (rather than returning) so the offline test harness can dofile() it without
-- relying on Civ V's include() semantics.
CivVAccess_Strings = CivVAccess_Strings or {}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "Civilization V accessibility loaded in-game."
-- Unit speech. Selection, info dump, action result, and target preview
-- strings. Moves and HP follow an "<current>/<max>" fraction form; the
-- embarked prefix is a lowercase glue token (base TXT_KEY_UNIT_STATUS_EMBARKED
-- is capitalised, so we supply our own to keep it inside a compound phrase
-- like "embarked warrior"). Upgrade / level / promotion-available are mod-
-- authored because base strings bundle them into tooltip markup we'd have
-- to strip anyway.
-- Tile recommendation announcement prefix. Paired with the rec's name
-- (settler "City site" / worker build description) in the glance, then
-- the composer follows with the rec's reason tooltip as a separate
-- comma-joined token.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "recommendation: {1_Name}"
-- Settler recs have no per-build name (unlike worker recs, which reuse
-- the build's Description); every settler-rec plot groups under this
-- label as one item with many instances. Used by the scanner category
-- and by the cursor glance section, so it lives in the shared InGame
-- strings file rather than the scanner-only strings file.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "City site"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_PREFIX"] = "embarked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "promotion available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = "{1_What} {2_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} melee"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} ranged, range {2_Range}"
-- Enemy form of ranged strength: range distance is hidden to match base
-- EnemyUnitPanel.lua, which shows strength but omits the range tile count.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} ranged"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MAX_MOVES"] = "{1_Num} moves"
-- Enemy HP speaks as a color band instead of an exact fraction. The band
-- thresholds mirror UnitFlagManager.lua:412 so blind players hear what
-- sighted players see on the unit flag: over 66% green, over 33% yellow,
-- else red. At 100% the game hides the bar; we speak "full" so the HP
-- slot is always present in the info line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "hp {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "green"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "yellow"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "red"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "full"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "level {1_Lvl}, {2_Cur}/{3_Next} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "upgrade to {1_Name}, {2_Gold} gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "promotions: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = "moved, {1_Num} moves left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "stopped short, 0 moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "action failed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "no units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "no actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "will declare war"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Unit actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Promotions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Worker builds"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "target mode"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "canceled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "out of range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_MyDmg} to me, {5_TheirDmg} to them"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] = "{1_Name}, {2_Dmg} damage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "move to {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} unspent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] =
    "{1_MP} MP, {2_Turns} turns, {3_Left} unspent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "no path"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "too far to compute"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "no target here"
-- Unit control help overlay entries. Chord labels merge each binding
-- cluster into one line so the ? screen doesn't list six Alt+letter rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Period, comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "Cycle to next or previous unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_HEX"] = "Control plus period or comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_HEX"] = "Cycle units on the cursor hex"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] = "Read the selected unit's combat and promotion info"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Open the unit action menu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt plus Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Move the selected unit one hex (double-press to confirm attack)"
-- Combat-result payload from Events.EndCombatSim. Damage values speak
-- absolute-delta ("attacker -8 hp") rather than before/after because the
-- before is already known from the last selection announce.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "attacker {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "defender {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} killed"
-- Self-plot action confirms. Keyed by action hash token so the menu can
-- dispatch without a per-action if-ladder. FORTIFY / SLEEP / ALERT / WAKE /
-- AUTOMATE / DISBAND / BUILD / PROMOTION map 1:1 to the commit path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "fortified"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "sleeping"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "on alert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "awake"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "automated"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "disbanded"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "started {1_Build}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "promoted to {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
-- Cursor / hex-grid handler. Direction tokens are short forms (e, ne, ...)
-- because experienced screen-reader users prefer shorter speech and these
-- appear in tight contexts (per-move river edges, capital orientation).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "e"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "ne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "se"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "sw"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "w"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "nw"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "edge of map"
-- Spoken by Cursor.move when civvaccess_shared.mapScope rejects the target.
-- Generic wording rather than CityView-specific so Phase 8's ranged-strike
-- target picker (scope = valid strike targets) reuses it verbatim.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "edge of range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "unclaimed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "unexplored"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "fog"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = "{1_Moves} moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_PREFIX"] = "river"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "river all sides"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "fresh water"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE"] = "trade route"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_SUFFIX"] = "pillaged"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "hills"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "mountain"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "lake"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = "{1_Build} {2_Turns} turns"
-- "Controlled" = plot:GetWorkingCity(): the tile is part of this city's
-- workable area (the engine's term is "working city," but no citizen need
-- be assigned). "Worked" elsewhere means IsWorkingPlot = a citizen is
-- actually there. Kept the wording distinct so the two never collide.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "controlled by {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "controlled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} percent defense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "in enemy zone of control"
-- Cursor help-overlay key labels: chord forms shared with the main letter
-- cluster. One TXT_KEY per chord because Help dedupes by keyLabel string and
-- the chords don't merge cleanly into a single label (Q is its own meaning).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Q, W, E, A, S, D, Z, X, C cluster"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] = "Move cursor by hex (Q nw, E ne, A w, D e, Z sw, C se)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "Read unit on current tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ORIENT"] = "Shift plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ORIENT"] = "Distance and direction from capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "Economy details for current tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "Combat details for current tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "City identity and combat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "City production and growth"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_POL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_POL"] = "City diplomacy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "Open city screen, annex puppet, or begin diplomacy with a met major civ"
-- City-info speech tokens. Three keys (1 identity + combat, 2 development,
-- 3 politics); shape mirrors the BNW CityBannerManager per-ownership tier.
-- Unmet cities stop at one word. Identity leads with actionable signals
-- (can-attack, capital or city-state trait+friendship), then status flags,
-- then pop/defense/HP, then garrison on team banners. Enemy HP reuses the
-- unit color-band keys so "hp full / green / yellow / red" stays one
-- vocabulary across unit and city queries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "unmet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "can attack"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "no city here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "cultured"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "militaristic"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "maritime"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "mercantile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "religious"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "friend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "ally"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "war"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "permanent war"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = "razing {1_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = "resistance {1_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "occupied"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "puppet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "blockaded"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} population"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} defense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} of {2_Max} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "garrisoned {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = "producing {1_Name} {2_Turns} turns"
-- Process production (Wealth / Research / etc.) has no completion turn or
-- progress fraction -- absence of the turn count is the audible signal that
-- this is a perpetual process rather than a buildable item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "producing {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "not producing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} of {2_Needed} production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = "grows in {1_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "starving"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "stopped growing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} of {2_Threshold} food"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "losing {1_Num} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_NOT_VISIBLE"] = "not visible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "warmonger preview: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "liberation preview: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "spy {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "diplomat {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_POLITICS"] = "no political information"
-- Spoken when Scanner becomes the top handler: on boot, after a popup
-- closes, after a sub-handler (ScannerInput, UnitActionMenu) pops. Gives
-- the user a consistent audible landmark that the hex-viewer cursor is
-- live again -- functioning as the "closed" confirmation that popup
-- dismissal would otherwise need case-by-case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "map mode"
-- Type-ahead search feedback (see FrontEnd strings for the authoring
-- rationale). Mirrored here because TypeAheadSearch runs from in-game
-- BaseMenu contexts whose string table is sandboxed from the FrontEnd copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
-- Help overlay strings (see FrontEnd strings for the authoring rationale).
-- Duplicated here because Contexts are sandboxed: in-game Contexts that
-- eventually wire SetInputHandler through InputRouter need their own copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Help"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Letters"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Up or down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home or end"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter or space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift plus left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Control plus up or down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt plus left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift plus tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Question mark"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Type to search"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Navigate items"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "Jump to first or last"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Activate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "Adjust value or drill in"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "Adjust value in larger steps"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "Jump to previous or next group"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Next tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Previous tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Read screen header"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Cancel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Close"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Cancel edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Commit edit"
-- Widget-generic strings spoken by BaseMenuItems Choice / Checkbox /
-- Textfield and BaseMenuEditMode. Mirrored from the FrontEnd copy because
-- Contexts are sandboxed: an in-game screen that uses these item kinds
-- needs them present in the InGame Context's string table.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "selected"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "on"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "blank"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "editing {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"
-- GameMenu (Esc pause menu) strings. Details tab reuses the base game's
-- TXT_KEY_POPUP_GAME_DETAILS, so no mod-authored tab label here.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "Pause Menu"
-- GenericPopup (the shared Context behind AnnexCity / PuppetCity /
-- ConfirmCommand / DeclareWar / BarbarianRansom / etc.). One display name
-- for all of them; the per-popup text comes from the base via preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "Popup"
-- Informational popups that have no engine-side title to reuse: TextPopup
-- is a generic notification, WonderPopup only carries the wonder name
-- (dynamic), LeagueSplash's title is dynamic per-session.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "Notification"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "Wonder Completed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "World Congress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "End of Game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "Declare War"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "City-State Greeting"
-- Great-work splash (archaeology / wonder / cultural-victory completion).
-- Title is either the great work's artist or the "written artifact" label;
-- description and quote come from GameInfo.GreatWorks.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "Great Work"
-- Choose-family popup screen names. Each popup's body text (what you're
-- picking among) is spoken as preamble from live engine controls; the
-- display name here is just the screen header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "Choose Goody Hut Reward"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "Choose Free Great Person"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "Choose Faith Great Person"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "Choose Maya Bonus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "Choose Pantheon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "Choose Ideology"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "Choose Archaeology Result"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "Choose Admiral New Port"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "Choose Trade Unit New Home"
-- Confirm-overlay sub-handler pushed on top of a Choose* picker when the
-- player activates an item. Display name only; the actual prompt text
-- (e.g. "Are you sure you wish to found X?") comes from Controls.ConfirmText
-- as a function preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Confirm"
-- NotificationLogPopup (BUTTONPOPUP_NOTIFICATION_LOG). Split into Active /
-- Dismissed tabs by the engine's per-notification dismissed flag. Item
-- label inlines the turn so the user can place each entry in history
-- without a separate key.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Notification Log"
-- Advisors tutorial banner (Events.AdvisorDisplayShow). Static screen
-- name; the per-tutorial title, body, and advisor type are spoken through
-- the preamble from live Controls. "Tutorial Advisor" distinguishes this
-- surface from the combat-interrupt AdvisorModal and the concept-browser
-- AdvisorInfoPopup that question buttons drill into.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "Tutorial Advisor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "Active"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "Dismissed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "No notifications."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, turn {2_Turn}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_HELP_KEY_OPEN"] = "Control plus N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_HELP_DESC_OPEN"] = "Open the notification log"
-- AdvisorCounselPopup (BUTTONPOPUP_ADVISOR_COUNSEL). Four tabs, one per
-- advisor. Page item label is composed at Lua level from the engine's
-- TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY fraction + the counsel body so the
-- user hears "i/N, <paragraph>" only when the advisor has more than one
-- page. Empty-advisor fallback when Game.GetAdvisorCounsel() returns
-- nothing for that slot (early-game Science is the usual case). F10 help
-- entry covers the BaselineHandler binding that opens the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "No counsel."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "Open the advisor counsel"
-- CityView hub. Preamble is spoken on open (and via F1). Yield names lead
-- each token so distinguishing information is at the front -- "food 3"
-- not "3 food" -- per the concise-announcement rule.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "City"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "connected"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} unemployed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "food {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "production {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "gold {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "science {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "faith {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "tourism {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "culture {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Period"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "Next city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "Previous city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "no next city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "no previous city"
-- Hub items that push a sub-handler on Enter. The unemployed action is
-- an item on the hub itself, not a sub; its label carries the live count
-- so the user hears it when arrowing past and doesn't have to drill in
-- just to check.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "Wonders"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "Great people progress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "Worker focus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "Unemployed: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "No wonders built."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "No great person generation."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} of {3_Max}"
-- Focus item label when the current focus matches. Read by labelFn on
-- every navigate so flipping focus is reflected immediately.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, selected"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "Avoid growth, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "Reset tile assignments"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} selected"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "tile assignments reset"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "no unemployed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "assigned"
-- Buildings sub-handler (§3.7). Drill-in opens on Enter over any building
-- entry; Sell is conditional on pCity:IsBuildingSellable and not-puppet, so
-- a non-sellable entry lands the user on a drill-in with just Back. The
-- sell-confirm modal speaks the engine's own TXT_KEY_SELL_BUILDING_INFO
-- so blind and sighted players see / hear the same confirmation text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "Buildings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "No buildings."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDING_ACTIONS"] = "{1_Name} actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDING_SELL"] = "Sell for {1_Gold} gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDING_BACK"] = "Back"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SELL_CONFIRM"] = "Sell confirmation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SELL_YES"] = "Y to confirm, N to cancel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SELL_DONE"] = "sold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SELL_CANCELLED"] = "cancelled"
-- Specialists sub-handler (§3.6). One item per slot across specialist-
-- capable buildings. Labels use labelFn so Enter-driven add/remove flips
-- the "empty" / "filled" suffix on the next navigate without rebuilding.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "Specialists"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "No specialist slots."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] = "{1_Building} {2_Specialist} slot {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "empty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "filled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "filled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "unfilled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] = "filled, worker unassigned from tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] = "unfilled, worker assigned to tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "cannot add specialist"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "Manual specialist control, {1_State}"
-- Great works sub-handler (§3.12). One item per great-work slot, grouped by
-- building in label. Slot-type label is the work category ("art", "writing",
-- "music"), not the great-person class, because that's what occupies the
-- slot and what the player reasons about. Synthetic theming-bonus entry
-- per building when the bonus is non-zero -- label carries the bonus magnitude
-- and engine's theming tooltip text so the rule is audible inline.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "Great works"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "art"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "writing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "music"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} slot {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} slot {3_N}, empty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] = "{1_Building} theming bonus plus {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "No great work slots."
-- Production queue sub-handler (§3.1). Slot 1 is the currently-producing
-- item, so its announcement carries the production meter percent; slots 2+
-- only have name + turns. Processes (ORDER_MAINTAIN) have no turns line.
-- Drill-in moves and removes via GAMEMESSAGE_SWAP_ORDER / _POP_ORDER.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "Production queue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "Queue empty."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] =
    "Slot 1, {1_Name}, {2_Turns} turns, {3_Percent} percent. {4_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "Slot 1, {1_Name}, {2_Percent} percent. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "Slot 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = "Slot {1_N}, {2_Name}, {3_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "Slot {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "Slot {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "{1_Name} actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "Move up"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "Move down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "Remove from queue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "Back"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "moved up"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "moved down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "removed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "Queue mode, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "Choose production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "Purchase with gold or faith"
-- Hex map sub-handler (§3.2). Arrow keys walk the cursor across the city's
-- own tile, its workable ring, and purchasable tiles. Tile announcement
-- composes yield line, worked-state word, buy cost, and PlotComposers.glance.
-- Enter over a workable ring plot issues TASK_CHANGE_WORKING_PLOT; over an
-- affordable purchasable plot issues SendCityBuyPlot; over an unaffordable
-- purchasable plot speaks "cannot afford" without sending.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Hex map"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "hex map"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "worked"
-- "Pinned" = IsForcedWorkingPlot: a worker is here AND the citizen manager
-- won't pull them off. Vanilla's visual is a star/pin icon, so the metaphor
-- matches. Pressing Enter on a "not worked" tile lands here in one step --
-- the engine's TASK_CHANGE_WORKING_PLOT both assigns and forces in a single
-- task, same as a mouse left-click.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "pinned"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "blocked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "not worked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "purchasable, {1_Gold} gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] =
    "purchasable, {1_Gold} gold, cannot afford"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "cannot afford"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "Move cursor across city tiles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "Work or buy tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Back to city hub"
-- Rename / Raze hub items (§3.13, §3.14). Rename fires BUTTONPOPUP_RENAME_CITY,
-- whose accessibility is handled by SetCityNameAccess. Raze fires the Yes/No
-- confirmation popup (BUTTONPOPUP_CONFIRM_CITY_TASK with TASK_RAZE), handled
-- by GenericPopupAccess. Unraze is a direct Network.SendDoTask -- no popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "Rename city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "Raze city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "Stop razing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "razing stopped"
-- Collapse announcement emitted when three or more notifications arrive
-- inside a six-frame window. The actual summaries are still available via
-- Ctrl+N so no content is lost.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_BURST"] = "{1_Count} new notifications"
-- Turn lifecycle speech. Turn-start is the game-side "Turn: N" label plus
-- the game's AD/BC year, joined by a comma so the moving parts (number
-- first, year second) read as a single line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "Turn ended"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control plus space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] = "End turn, or announce and open the first blocker"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Control plus shift plus space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "End turn past the units-need-orders prompt; other blockers still announce and open"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "Actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "No mods activated."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, version {2_Version}"
-- Civilopedia (picker/reader two-tab) strings.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "Categories"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "Content"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "No article text available."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "No content for this entry."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "No entry selected. Switch to the categories tab to pick one."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "Start of history."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "End of history."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "Previous or next article in history"
-- AdvisorInfoPopup (BUTTONPOPUP_ADVISOR_INFO). Concept drill-down reachable
-- from the tutorial advisor question buttons and from any related concept
-- link within the popup itself. The boundary announcements reuse
-- TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY / _NO_NEXT_HISTORY -- same
-- "Start of history." / "End of history." text, no reason to duplicate.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] = "Previous or next concept in history"
-- SaveMenu. Two-tab picker/reader over the in-game Save screen. Picker lists
-- existing saves (or cloud slots); reader shows header fields and exposes
-- the Overwrite / Save-to-slot / Delete actions behind pushed Yes/No subs.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "Saves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "Save details"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "No saves in this list."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "Save name"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] = "Save name is empty or contains invalid characters."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "Overwrite this save"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "Save to this slot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "Overwrite {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] = "Overwrite Steam Cloud slot {1_Num}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "Delete {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "Save deleted."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Steam Cloud slot {1_Num}: empty"
-- Spoken replacements for [ICON_*] markup. Registered into TextFilter by
-- CivVAccess_Icons.lua; the filter substitutes the bracket token inline
-- with the spoken text. Singular / plural wording is deliberately relaxed
-- ("turns", "whales") because screen-reader users tolerate minor grammar
-- over awkward branching, and Civ's text uses these icons in both counts.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "food"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "faith"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "tourism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_INFLUENCE"] = "influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "ranged combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SWAP"] = "swap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "unhappiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CAPITAL"] = "capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CITIZEN"] = "citizen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CONNECTED"] = "connected"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_OCCUPIED"] = "occupied"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PUPPET"] = "puppet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RAZING"] = "razing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESISTANCE"] = "resistance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_BLOCKADED"] = "blockaded"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "great people"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "great work"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLDEN_AGE"] = "golden age"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TRADE_ROUTE"] = "trade route"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SPY"] = "spy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_DIPLOMAT"] = "diplomat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TURNS"] = "turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PLUS"] = "plus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MINUS"] = "minus"
-- Empty value: bullet glyphs are purely visual separators; speaking anything
-- at all would add noise. Registered so the token doesn't log the miss-warn
-- on every pedia article that happens to use one.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_BULLET"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TROPHY_BRONZE"] = "bronze trophy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TROPHY_SILVER"] = "silver trophy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TROPHY_GOLD"] = "gold trophy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_VICTORY_CULTURE"] = "cultural victory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_VICTORY_DIPLOMACY"] = "diplomatic victory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_VICTORY_DOMINATION"] = "domination victory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_VICTORY_SCIENCE"] = "science victory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION"] = "religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_PANTHEON"] = "pantheon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_BUDDHISM"] = "Buddhism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_CHRISTIANITY"] = "Christianity"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_CONFUCIANISM"] = "Confucianism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_HINDUISM"] = "Hinduism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_ISLAM"] = "Islam"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_JUDAISM"] = "Judaism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_ORTHODOX"] = "Orthodox Christianity"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_PROTESTANT"] = "Protestantism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_SHINTO"] = "Shinto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_SIKHISM"] = "Sikhism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_TAOISM"] = "Taoism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_TENGRI"] = "Tengri"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RELIGION_ZOROASTRIANISM"] = "Zoroastrianism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_ALUMINUM"] = "aluminum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_ARTIFACT"] = "artifact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_HIDDEN_ARTIFACT"] = "hidden artifact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_BANANA"] = "bananas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_BISON"] = "bison"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_CITRUS"] = "citrus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_CLOVES"] = "cloves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_COAL"] = "coal"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_COCOA"] = "cocoa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_COPPER"] = "copper"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_COTTON"] = "cotton"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_CATTLE"] = "cattle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_CRAB"] = "crab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_DEER"] = "deer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_DYE"] = "dye"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_FISH"] = "fish"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_FUR"] = "fur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_GEMS"] = "gems"
-- Disambiguate from the gold currency to avoid identical speech for two
-- distinct concepts; the game's resource name is also "Gold" but speaking
-- it as-is would collide with [ICON_GOLD] every time a tech description
-- mentions both.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_GOLD_ORE"] = "gold ore"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_HORSES"] = "horses"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_INCENSE"] = "incense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_IRON"] = "iron"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_IVORY"] = "ivory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_JEWELRY"] = "jewelry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_MANPOWER"] = "manpower"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_MARBLE"] = "marble"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_NUTMEG"] = "nutmeg"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_OIL"] = "oil"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_PEARLS"] = "pearls"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_PEPPER"] = "pepper"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_PORCELAIN"] = "porcelain"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_SALT"] = "salt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_SHEEP"] = "sheep"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_SILK"] = "silk"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_SILVER"] = "silver"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_SPICES"] = "spices"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_STONE"] = "stone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_SUGAR"] = "sugar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_TRUFFLES"] = "truffles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_URANIUM"] = "uranium"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_WHALES"] = "whales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_WHEAT"] = "wheat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RES_WINE"] = "wine"

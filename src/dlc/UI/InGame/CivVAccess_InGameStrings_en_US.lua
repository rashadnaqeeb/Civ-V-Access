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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = "{1_MP} MP, {2_Turns} turns, {3_Left} unspent"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WORKED_BY"] = "worked by {1_City}"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "research"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "faith"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "tourism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_INFLUENCE"] = "influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "ranged strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "movement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SWAP"] = "swap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "happy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "unhappy"
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

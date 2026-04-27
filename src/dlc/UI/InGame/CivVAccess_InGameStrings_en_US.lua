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
-- Spoken when a unit is mid-execution on ACTIVITY_MISSION. For a selectable
-- player-controlled unit the cascade falls through to this rung only for
-- multi-turn movement missions (MISSION_MOVE_TO / MISSION_ROUTE_TO) -- build
-- missions get caught by the build rung above, automated units by the
-- automate rung, and one-shot missions (attack, embark, found, airstrike,
-- etc.) resolve within the turn and never reach selection. The Lua API does
-- not expose mission type or destination plot, so we cannot say where.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "queued move"
-- Engine-fork form of the queued rung: when WaypointsCore can compute a
-- destination and turn count for the head-selected unit's queued path,
-- the rung becomes "queued move {dir}, N turns" so the user hears where
-- the unit is going and how long it takes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO"] = "queued move {1_Dir}, {2_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} melee"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} ranged, range {2_Range}"
-- Enemy form of ranged strength: range distance is hidden to match base
-- EnemyUnitPanel.lua, which shows strength but omits the range tile count.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} ranged"
-- Spoken on a friendly combat unit that has used its per-turn attack budget
-- (1 attack, or 2 with Blitz) but still has movement points. The actionable
-- distinction is "you have moves but can't strike with them, only reposition";
-- a 0-moves unit can't attack regardless, so the moves fraction already
-- conveys the answer and this token suppresses to avoid repeating it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "out of attacks"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "stopped short"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = "stopped short, {1_Num} turns till arrival"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "action failed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "no units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "no actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "will declare war"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Unit actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "Activate tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Promotions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Worker builds"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "target mode"
-- Confirms when shift+enter appends a leg to the unit's mission queue.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "queued"
-- Spoken when shift+enter is pressed in a non-queueable mode (melee
-- attack). The engine has no queued-attack semantics that resolve into
-- meaningful gameplay -- a queued attack pushes the mission and resolves
-- on the same turn the queue head reaches it, but we have no
-- pre-snapshot for the eventual combat -- so we reject.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "cannot queue attack"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "canceled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "out of range"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, {5_DmgToMe} damage to me, {6_DmgToThem} to them"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "support fire {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "capture chance {1_Pct} percent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "my bonuses {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "theirs: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "plus {1_N} percent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "minus {1_N} percent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, {5_DmgToThem} damage to them"
-- City-defender preview variants. Cities don't surface a combat
-- prediction (the engine's CombatPrediction is unit-vs-unit only) and
-- the modifier breakdowns are different enough that we drop them rather
-- than mislead. Damage numbers are still computed via the engine's own
-- GetCombatDamage with the city flags set, so they match what the
-- sighted EnemyUnitPanel reports.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "city {1_Name}, {2_MyStr} vs {3_TheirStr}, {4_DmgToMe} damage to me, {5_DmgToThem} to them"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "city {1_Name}, {2_MyStr} vs {3_TheirStr}, {4_DmgToThem} damage to them"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} to me"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPT_POSSIBLE"] = "intercept possible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = "{1_N} interceptors"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "move to {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} unspent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] =
    "{1_MP} MP, {2_Turns} turns, {3_Left} unspent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "this turn, unexplored area"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = "{1_Turns} turns, unexplored area"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] = "this turn, {1_Steps} then unexplored"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] =
    "{1_Turns} turns, {2_Steps} then unexplored"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "no path"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "too far to compute"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "no target here"
-- Route-to (auto-route) preview. Tile count is the path length excluding
-- the worker's start tile -- "the road will reach N tiles further from
-- where you are now." Build turns is the sum of GetBuildTurnsLeft over
-- plots that need a route built; tiles already routed at the target tier
-- (and city tiles) contribute zero. ALREADY_DONE fires when the path
-- exists but every tile already has the target route, so the mission
-- completes the moment the worker walks the chain.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_Tiles} tiles, {2_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = "{1_Tiles} tiles, no work needed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD"] = "no route available"
-- Per-mode "cannot X here" strings for the special interface modes whose
-- legality is the only sighted feedback (highlight tint). Spoken when the
-- engine's per-target Can*At check returns false; legal targets fall
-- through to the destination plot's glance summary instead.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "cannot paradrop here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "cannot airlift here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "cannot rebase here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "cannot embark here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "cannot disembark here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "cannot nuke here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "cannot gift unit here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "cannot improve here"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "no visible interceptors"
-- Unit control help overlay entries. Chord labels merge each binding
-- cluster into one line so the ? screen doesn't list six Alt+letter rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Period, comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "Cycle to next or previous unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Control plus period or comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "Cycle to next or previous unit, including those that have already acted"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] = "Read the selected unit's combat and promotion info"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Control plus slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] = "Recenter the hex cursor on the selected unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Open the unit action menu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt plus Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Move the selected unit one hex (double-press to confirm attack)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] = "Fortify a military unit, or sleep a civilian"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] = "Sentry, sleeping until an enemy comes into sight"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt plus W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "Wake a sleeping or fortified unit, or cancel a queued move or automation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt plus space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "Skip the unit's turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "Heal until full"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "Open the ranged attack target picker; aim with the cursor keys, space to preview, enter to commit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "Pillage the unit's tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt plus U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "Upgrade the unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} not available"
-- Combat-result payload from Events.EndCombatSim. Damage values speak
-- absolute-delta ("attacker -8 hp") rather than before/after because the
-- before is already known from the last selection announce.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "attacker {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "defender {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} killed"
-- City-capture announcements. SerialEventCityCaptured fires for empty
-- city captures (no EndCombatSim) and for capture-after-defender-killed
-- transitions; the active player's perspective decides which line wins.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "captured {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "lost {1_Name}"
-- Self-plot action confirms. Keyed by action hash token so the menu can
-- dispatch without a per-action if-ladder. FORTIFY / SLEEP / ALERT / WAKE /
-- AUTOMATE / DISBAND / BUILD / PROMOTION map 1:1 to the commit path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "fortified"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "sleeping"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "on alert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "awake"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "automated"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "disbanded"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "healing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "pillaged"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "skipped"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "upgraded"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "canceled"
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
-- Cursor prefix that fires while the engine is in a ranged-attack interface
-- mode (unit ranged, airstrike, city ranged) when the attacker has no
-- geometric line of sight to the target plot (mountain, hill chain, or
-- forest in the way). The companion "out of range" prefix reuses
-- TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE so target-mode preview text
-- and cursor-prefix text stay in sync across locales.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "unseen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "capital"
-- Modified-offset coordinate, capital-relative. {1_X} can be a half-integer
-- (NE / NW / SE / SW steps land on .5); {2_Y} is always an integer.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = "{1_Moves} moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_PREFIX"] = "river"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "river all sides"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "fresh water"
-- Numbered step on the head-selected unit's queued path. Speaks on cursor
-- glance and as the scanner item name for the "waypoints" category.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "waypoint {1_Index} of {2_Total}"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Shift plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "Coordinates of cursor relative to original capital, in modified offset notation (each step east is plus one in x, each NE step is plus 0.5 in x and plus one in y, each SE is plus 0.5 in x and minus one in y)"
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
    "Select a unit, or open the city screen (annex popup for puppets, diplomacy with a met major civ), on the tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Ctrl plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "Open Civilopedia for everything at the cursor's tile (units, world wonders, improvement, resource, feature, river, lake, terrain, hills, mountain, route)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "Articles at tile"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control plus I"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "Open Civilopedia entry for the current item"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Cancel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Close"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Cancel edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Commit edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Open settings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Close settings"
-- BaseTable: 2D table viewer (used by F2 cities, future demographics, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, descending"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, ascending"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, sort cleared"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "Move between rows"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "Move between columns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "First or last row"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "Activate cell or sort by column"
-- Settings overlay strings. Reachable from every Context that routes
-- through InputRouter, so duplicated in the FrontEnd copy as well.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Settings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Audio cue mode"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Speech only"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Speech and audio cues"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Audio cues only"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "Master volume"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "Master volume, {1_Num} percent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "Scanner auto-move cursor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "Cursor follows selected unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "Cursor coordinates while moving"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "Speak before move announcement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "Speak after move announcement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "Scanner shows coordinates"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Read subtitles"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "City-State"
-- Fallback for LeaderHeadRoot / DiscussionDialog before TitleText is
-- populated. In practice the onShow hook overwrites handler.displayName
-- with the live leader title (e.g. "Suleiman the Magnificent") that
-- LeaderMessageHandler just set.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "Diplomacy"
-- DiscussionDialog sub-menu display names. Denounce confirm is a yes/no
-- overlay; coop-war leader picker is a scroll list of civs the AI could
-- ally with against us.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "Denounce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "Coop war target"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "Establish Trade Route"
-- Confirm-overlay sub-handler pushed on top of a Choose* picker when the
-- player activates an item. Display name only; the actual prompt text
-- (e.g. "Are you sure you wish to found X?") comes from Controls.ConfirmText
-- as a function preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Confirm"
-- ChooseReligionPopup (BUTTONPOPUP_FOUND_RELIGION). Same Context wraps both
-- founding (Option1=true) and enhancing (Option1=false); the display name
-- resolves per phase. Change Religion Name is a sub-handler covering the
-- engine's ChangeNamePopup overlay (Textfield + OK / Default / Cancel).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "Choose Religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "Enhance Religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "Change Religion Name"
-- Belief-slot label formats. {1_Slot} is the slot's short name (Pantheon
-- belief, Founder belief, Follower belief, Follower belief 2, Enhancer
-- belief, Bonus belief); {2_Belief} is the short description of whichever
-- belief currently fills the slot. States: UNCHOSEN (editable with nothing
-- picked), CHOSEN (either editable with a selection or already committed;
-- both spoken identically - commit state is reflected by whether drill-in
-- opens a belief list), LATER (locked; slot unlocks next phase), and
-- BYZANTINES_ONLY (locked; only reachable with the Byzantine civ trait).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, not chosen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, available later"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, Byzantines only"
-- Religion-picker row. Unselected in founding mode before the user picks
-- from the religion list; selected after SelectReligion fires. Enhance mode
-- replaces the row with a read-only Text showing the player's own religion.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "religion, not chosen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "religion, {1_Name}"
-- Name row. Founding lets the user open ChangeNamePopup to rename; enhance
-- shows read-only. The row is gated on ReligionPanel visibility so only
-- runs once a religion is selected.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "name, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "religion name"
-- NotificationLogPopup (BUTTONPOPUP_NOTIFICATION_LOG). Split into Active /
-- Dismissed tabs by the engine's per-notification dismissed flag. Item
-- label inlines the turn so the user can place each entry in history
-- without a separate key.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Notification Log"
-- LeagueProjectPopup (BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED). Each contributor
-- entry is one navigable Text item: rank, civ name, contribution score, tier
-- earned. Tier maps from base's iTier int (0..3) to the bronze/silver/gold
-- vocabulary the project rewards-table uses; "no reward" covers iTier == 0
-- (contributed too little to qualify for any tier).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "League Project Completed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} production, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "gold tier reward"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "silver tier reward"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "bronze tier reward"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "no reward"
-- VoteResultsPopup (BUTTONPOPUP_VOTE_RESULTS). Each entry is rank, voter,
-- who they voted for, and the votes they themselves received.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "Vote Results"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] =
    "{1_Rank}, {2_Name} voted for {3_Cast}, received {4_Votes} votes"
-- WhosWinningPopup (BUTTONPOPUP_WHOS_WINNING). Engine-fired ranking pop with
-- a randomly-chosen metric. Player rows mirror the engine's "rank, name,
-- score" order so the user hears the rank first; the active player's tag
-- and the unmet placeholder come from the engine's own keys. Tourism-mode
-- rows include the owner because the sighted column shows the leader
-- portrait + civ icon next to the city name (info absent from the city's
-- own label). Unmet city rows degrade to "Unmet Player" with no city or
-- owner, matching what base displays.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "Who's Winning"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"
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
-- MilitaryOverview (BUTTONPOPUP_MILITARY_OVERVIEW, F3). Level 0 reads GP
-- progress + supply line as Text widgets; drill-ins hold the unit rows. The
-- GP line combines the engine's own label (TXT_KEY_CITYVIEW_GG_PROGRGRESS /
-- TXT_KEY_MO_GA_PROGRESS) with the numerator/denominator the sighted tooltip
-- shows first. Supply collapses the sighted screen's six-to-seven-row stack
-- (base, cities, population, cap, use, remaining OR deficit+penalty) into a
-- single line; current state leads ("in use", "remaining" or "over"), then
-- the three-component breakdown the sighted player gets above the divider.
-- Sort selector verbalizes current mode; menu label is independent so the
-- user hears "sort by: name" at the selector and just "sort by" as the
-- title of the picker that opens. Row strength/ranged use bare nouns (not
-- "melee" / range-distance forms that UnitSpeech uses) because the F3 row
-- echoes the sighted column whose header is just an icon.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur} of {3_Max} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_NORMAL"] =
    "Supply: {1_Use} of {2_Cap} in use, {3_Remaining} remaining. Base {4_Base}, cities {5_Cities}, population {6_Pop}."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_DEFICIT"] =
    "Supply: {1_Use} of {2_Cap} in use, {3_Deficit} over, {4_Penalty} production penalty. Base {5_Base}, cities {6_Cities}, population {7_Pop}."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_LABEL"] = "Sort by: {1_Mode}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MENU"] = "Sort by"
-- Sort-mode nouns. Engine's TXT_KEY_MO_SORT_* strings are the column-header
-- tooltips ("Sort By Strength") and would produce "Sort by: Sort By Strength"
-- if reused. Name / Status modes reuse the plain-noun TXT_KEY_NAME /
-- TXT_KEY_STATUS; the numeric columns are icon-only in the sighted UI, so
-- these four are mod-authored.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "Moves left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "Max moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "Strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "Ranged"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GROUP_MILITARY"] = "Military units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GROUP_CIVILIAN"] = "Civilian units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_ROW_STRENGTH"] = "strength {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_ROW_RANGED"] = "ranged {1_Num}"
-- Great People drillable group at the bottom of the panel. Mirrors GPList:
-- one subgroup per specialist type populated with per-city progress rows
-- sorted by turns ascending, plus flat GG / GA rows reusing
-- TXT_KEY_CIVVACCESS_MO_GP_PROGRESS. City row leads with the city name (the
-- distinguishing word as the user navigates a turns-sorted list), then turns,
-- then progress / threshold, then the per-turn rate. NO_PROGRESS variant
-- handles the rate-zero case (city has stranded GPP but no specialists or
-- buildings producing more); skip the turns and rate fields since both are
-- zero. TURNS_NEXT covers the imminent case where threshold-progress <= rate.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_GROUP"] = "Great People progress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress} of {4_Threshold}, plus {5_Rate} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] = "{1_City}: {2_Progress} of {3_Threshold}, no progress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "next turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = "{1_N} turns"
-- AdvisorCounselPopup (BUTTONPOPUP_ADVISOR_COUNSEL). Four tabs, one per
-- advisor. Page item label is composed at Lua level from the engine's
-- TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY fraction + the counsel body so the
-- user hears "i/N, <paragraph>" only when the advisor has more than one
-- page. Empty-advisor fallback when Game.GetAdvisorCounsel() returns
-- nothing for that slot (early-game Science is the usual case). F10 help
-- entry covers the BaselineHandler binding that opens the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "No counsel."
-- Function-row help entries. F1-F9 describe engine passthroughs (no mod
-- binding; BaselineHandler's passthroughKeys lets the keycode reach the
-- engine's own action). F10 is our advisor-counsel rebind; the strategic
-- view toggle the engine binds here is suppressed. Authored as help text
-- only so the map-mode help list documents the full function-row vocab
-- the user can reach from the map.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "Open the Civilopedia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "Open the Economic Advisor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "Open the Military Advisor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "Open the Diplomacy Advisor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "Open the Social Policies screen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "Open the Tech Tree"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "Open the turn and event log"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "Open the Victory Progress screen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "Open the Demographics screen"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "Stats"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} theming bonus plus {2_Amount}. {3_Tip}"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Manage territory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "manage territory"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "purchasable, {1_Gold} gold, cannot afford"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "cannot afford"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "Move cursor across city tiles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "Work or buy tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_LIST"] = "L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_LIST"] = "List worked tiles from cursor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_LIST_NONE"] = "no worked tiles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Back to city hub"
-- Ranged strike sub-handler (§3.5). Hub item closes the city screen, enters
-- INTERFACEMODE_CITY_RANGE_ATTACK, and pushes a target picker. Cursor moves
-- freely via Baseline's QAZEDC; Space speaks a strike-specific preview
-- (target identity if in range, "cannot strike" otherwise); Enter commits
-- with a "fired" confirmation. Exit (commit, cancel, or external pop)
-- returns to the world map -- the city screen does not re-open.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "Ranged strike"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "ranged strike"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "cannot strike"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "fired"
-- City-attacker damage preview suffix. Caller speaks the target's
-- identity (CitySpeech.identity / UnitSpeech.info) before this; we add
-- the engine-computed strengths and damage. No verdict (cities don't
-- get GetCombatPrediction) and no retaliation (city ranged is one-way).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] = "{1_MyStr} vs {2_TheirStr}, {3_Dmg} damage to them"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_PREVIEW"] = "Speak target info"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_COMMIT"] = "Fire on current target"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_CANCEL"] = "Cancel without firing"
-- Gift-unit / gift-improvement target picker (audit §7.7). Pushed from
-- the city-state diplo popup when the user chooses Gift > Unit or Gift >
-- Improvement; the engine's INTERFACEMODE_GIFT_UNIT and INTERFACEMODE_
-- GIFT_TILE_IMPROVEMENT are hex-click-only modes with no engine keyboard
-- path. Cursor moves freely via Baseline; Space speaks legality + plot
-- glance; Enter commits (gift-unit chains into BUTTONPOPUP_GIFT_CONFIRM,
-- gift-improvement calls Game.DoMinorGiftTileImprovement directly).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "gift unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "gift improvement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "improvement given"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_PREVIEW"] = "Speak target info"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_COMMIT"] = "Commit gift on current target"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_CANCEL"] = "Cancel without gifting"
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
-- the engine's F7 notification log so no content is lost.
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
-- Empire status readouts (T/R/G/H/F/P/I bare-letter keys in baseline). Each
-- key speaks one composed line; conditional clauses join with comma. Help
-- entries describe the underlying readout, not the panel item, since the
-- speech composes data from multiple panel surfaces.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "{1_Num} over unit cap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = "{1_Turns} turns to {2_Tech}, science +{3_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} done, science +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "No research, science +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "Science off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] =
    "+{1_Rate} gold, {2_Total} total, {3_Used} of {4_Avail} trade routes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] =
    "minus {1_Rate} gold, {2_Total} total, {3_Used} of {4_Avail} trade routes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "no {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"
-- Section labels for Shift+letter detail readouts. Inserted as
-- "{Label}: " between sections by newDetail.compose() at transitions
-- the engine's first item doesn't already anchor (Help and Income
-- reuse engine TXT_KEY_HELP / TXT_KEY_EO_INCOME).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "Golden age"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "Religions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "Great people"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "Influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "Unhappy minus {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "Very unhappy minus {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = "golden age for {1_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "{1_Cur} of {2_Threshold} to golden age"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "Happiness off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} faith, {2_Total} total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "Religion off"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PANTHEON, which inlines a long rules
-- explainer after the data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "{1_Num} faith for next pantheon"
-- Replaces TXT_KEY_TP_FAITH_PANTHEONS_LOCKED, a four-sentence rules
-- paragraph with no live data.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "no pantheons available"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PROPHET, a one-sentence verbose phrasing
-- that wraps a single data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "{1_Num} faith for next great prophet"
-- Replaces TXT_KEY_TP_TECH_CITY_COST and TXT_KEY_TP_CULTURE_CITY_COST,
-- both one-sentence explainers wrapping a single percent. The engine's
-- policy version also tacks on a "don't expand too much!" rules nudge.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "+{1_Pct}% tech cost per city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "+{1_Pct}% policy cost per city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = "+{1_Rate} culture, {2_Turns} turns to policy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "+{1_Rate} culture, no policies left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] = "no culture, {1_Cur} of {2_Cost} to next policy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "Policies off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} tourism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = "+{1_Rate} tourism, influential on {2_Count} civs"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] =
    "+{1_Rate} tourism, influential on {2_Count} of {3_Total} civs"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "Turn and date, with unit supply when over cap and any strategic resource shortages"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "Current research and science per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "Gold per turn, total, and trade routes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "Empire happiness, count of luxuries providing happiness, and golden age"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "Faith per turn and total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] = "Culture per turn and time to next policy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] = "Tourism per turn and influential civ count"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Shift plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "Per-source science breakdown"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Shift plus G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "Per-source gold income and expenses"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Shift plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "Happiness sources, unhappiness sources, and golden age effect"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Shift plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "Per-source faith breakdown and prophet or pantheon timing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Shift plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "Per-source culture breakdown"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Shift plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "Great works, empty slots, and influential civ count"
-- Task list readout. Scenario-driven objective tracker; silent when no
-- active tasks exist (the common case outside scenarios and tutorials).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Shift plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "Read active scenario tasks"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "ranged combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "happiness"
-- Dedup-only alias. Base text pairs the positive-happy glyph with "Happy"
-- as well as "Happiness"; speaking "happiness Happy" doubles the concept.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "happy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "unhappiness"
-- Dedup-only alias. Base text pairs the unhappy glyph with "unhappy" too.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "unhappy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "right"
-- ChooseProduction popup. Wrapped BaseMenu with two tabs (Produce, Purchase)
-- and five groups per tab (Units, Buildings, Wonders, Other, Current queue).
-- Append-mode commit speaks post-commit queue length so the player hears the
-- fill state as they chain picks; queue-full closes the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "Choose Production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "Produce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "Purchase"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "Current queue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "puppet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "added, slot {1_Slot} in queue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "queue full"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "queue is empty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "queue has {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = "{1_Num} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} faith"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "building {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "purchased {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = "{1_Name}, {2_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"
-- ChooseTech popup. Flat BaseMenu list of researchable techs with the current
-- research pinned on top in free / stealing modes. Activate commits via
-- Network.SendResearch; F6 and the bottom-of-list item both escalate to the
-- full tree through OpenTechTree (defined in TechPopup.lua, same Context).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "Choose Research"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "free tech, {1_N} remaining"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "stealing from {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} science per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = "currently researching {1_Name}, {2_Turns} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "free"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "currently researching"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "queued slot {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = "{1_Num} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "Open Tech Tree"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "researching {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "gained {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "stole {1_Name}"
-- Tech Tree screen. TabbedShell with a hand-rolled DAG cursor tab and a
-- BaseMenu read-only queue tab. Landing speech on every arrow move
-- composes name, status, queue slot (if queued), turns, and unlocks
-- prose. Mode preamble reuses CHOOSETECH_PREAMBLE_* keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "Tech Tree"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "Tree"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "Queue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "researched"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "prerequisites not met"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "locked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "no current research, queue empty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "current"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "queued {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "already researched"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "not available for free tech"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "cannot steal this"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Up/Down/Left/Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV"] = "Up/Down for parent/child, Left/Right for siblings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "Research focused tech"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Shift+Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "Queue focused tech"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Ctrl+I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "Open Civilopedia entry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "Letter / digit / space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "Type to search by name or unlocks"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "Close Tech Tree"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "Close Tech Tree"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "Social Policies"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "Policies"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "Ideology"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "opened"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "finished"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "adoptable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "locked, requires {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] = "locked, requires a founded religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "locked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "blocked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} of {2_Total} adopted"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] = "opener, granted free when branch opens"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] = "finisher, awarded when branch is complete"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "adopted"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "adoptable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "blocked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "locked"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "locked, requires {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "open {1_Branch}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] = "{1_Cur} of {2_Cost} culture, {3_Per} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = "{1_Turns} turns to next policy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = "{1_Num} free policies available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = "{1_Num} free tenets available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "ideology not yet embraced"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "ideology disabled in this game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "Level 1 tenets"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "Level 2 tenets"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "Level 3 tenets"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "slot {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "slot {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "slot {1_Num}, empty, available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] = "slot {1_Num}, empty, requires slot {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "slot {1_Num}, empty, requires level {2_Level} slot {3_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] = "slot {1_Num}, empty, insufficient culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "switch ideology"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "switch ideology, unavailable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "unhappiness {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "Pick Tenet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "no tenets available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "Adopt {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "Open branch {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "Adopt {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "Switch ideology?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "adopted {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "opened {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "adopted tenet {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "ideology switch requested"
-- Number-entry primitive (BaseMenuNumberEntry). Digits / Backspace / Enter /
-- Esc bindings with their own help strings because the digit surface isn't
-- covered by the menu's standard A-Z search entry.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Digits"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "Append digit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "Remove last digit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "Commit amount"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "enter {1_Label}, max {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "empty"
-- Diplomacy trade screen. Labels for the flat top-level menu (Your / Their
-- Offer), drawer tab names, quantity-bearing Offering lines, and the Other
-- Players group for third-party peace / war actions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "Trade"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "Trade with {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "Your offer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "Their offer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "Offering"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "Available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, population {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "vote commitment"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "make peace with {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "declare war on {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "Make peace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "Declare war"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "Other players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "none available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "nothing on the table"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "you have {1_Num}"
-- DiploCurrentDeals review labels. Each deal renders as one Text leaf
-- whose label inlines the full contents; these are the side prefixes the
-- builder concatenates around the per-item descriptions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "we give: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "they give: {1_List}"
-- Diplomatic Overview (Relations / Global tabs). Per-civ composed lines,
-- trade / third-party fragment prefixes, section group headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader} of {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "score {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "gold {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "gold per turn {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "strategic: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "luxury: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "nearby: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "policies: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "wonders: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "Major civilizations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "City-states"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "No civilizations met."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "No deals."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "incoming proposal"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "awaiting response"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "team {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "researching {1_Tech}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "anchored to {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} faith"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} food in capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} food in other cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = "next gift unit in {1_N} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "exporting {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "open borders"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "bullyable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "ally of {1_Civ}"
-- City Stats drillable. The Stats hub item pushes a sub-handler whose
-- top-level items are these category groups. Per-yield drill-ins reuse
-- the existing CITYVIEW_YIELD_* one-line headers (food / production /
-- gold / etc.) so the per-turn label is identical whether the user reads
-- it from the Yields-group root or the individual yield's drill-in
-- header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "Yields"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_GROWTH"] = "Growth"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_CULTURE"] = "Culture progress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_HAPPINESS"] = "Happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "Religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "Trade routes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "Resources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_DEFENSE"] = "Defense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_DEMAND"] = "Resource demand"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "no breakdown available"
-- Per-yield drill-in header keys re-use the same 7 CITYVIEW_YIELD strings
-- the preamble used to read; the table below is symmetrical so a future
-- locale only writes the spoken label once.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_FOOD"] = "food {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_PRODUCTION"] = "production {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_GOLD"] = "gold {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_SCIENCE"] = "science {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_FAITH"] = "faith {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_TOURISM"] = "tourism {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_CULTURE"] = "culture {1_Num}"
-- Culture progress group: stored / threshold pair, per-turn rate, and the
-- next-tile countdown that the engine hides when culture per turn is zero.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_PROGRESS"] = "{1_Stored} of {2_Needed} culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_PER_TURN"] = "{1_Num} per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = "next tile in {1_Num} turns"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "tile expansion stalled"
-- Happiness group: local-only contribution from buildings here, plus the
-- per-city slice of the empire's unhappiness pool (population / occupied /
-- specialists already folded in by the engine).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LOCAL"] = "local happiness {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_UNHAPPINESS"] = "unhappiness {1_Num}"
-- Religion group: one row per religion present, holy-city flag inlined
-- when applicable so the user hears it together with that religion's
-- numbers rather than as a separate line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] =
    "{1_Religion}, {2_Followers} followers, {3_Pressure} pressure"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] =
    "{1_Religion}, holy city, {2_Followers} followers, {3_Pressure} pressure"
-- Trade group: direction first so the partner city name lands second
-- (matches the way GetTradeRoutes presents from / to).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_OUTGOING"] = "to"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_INCOMING"] = "from"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_DOMAIN_LAND"] = "land"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_DOMAIN_SEA"] = "sea"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_ROUTE"] = "{1_Direction} {2_City}, {3_Domain}"
-- ChooseInternationalTradeRoutePopup row format: destination identifier
-- (city, plus civ for major-civ rows), hex distance, then yields split
-- into "you get" / "they get" sides matching the engine's myBonuses /
-- theirBonuses bucketing. Religion-pressure direction verified against
-- Community-Patch-DLL CvLuaPlayer.cpp lGetPotentialInternationalTrade
-- RouteDestinations.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = "{1_Num} hexes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "You get {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "They get {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} pressure"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "No valid destinations."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "No valid home cities."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Ctrl+T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "Open Trade Route Overview"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "Your trade routes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "Available trade routes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "Trade routes with you"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "caravan"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "cargo ship"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] =
    "{1_Domain}, {2_FromCity} ({3_FromCiv}) to {4_ToCity} ({5_ToCiv})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = "{1_Num} turns left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "No routes."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "No source breakdown available."
-- Defense group: each defensive building announces with the same {Building}
-- format string so adding a new defensive building only adds a row, not a
-- new label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_DEFENSE_BUILDING_LINE"] = "{1_Building}"
-- Leader descriptions. Spoken on F2 over LeaderHeadRoot /
-- DiscussionDialog / DiploTrade, keyed by Leaders.Type (Players[i]:GetLeaderType()
-- -> GameInfo.Leaders[lt].Type). Sourced from docs/leader-descriptions.md.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "Describe leader"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "No description available for this leader."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "George Washington, first President of the United States, stands in a paneled interior between heavy red curtains drawn back to either side, his hands loose at his hips. He wears the black civilian dress of a late eighteenth-century American gentleman: a dark double-breasted coat cut long over the thighs, with two rows of brass buttons down the front, a matching waistcoat beneath, a ruffled white jabot at the neck, and white cuffs at the wrists. His hair is dressed white with powder, brushed back from a high forehead, curled at the sides above the ears, and gathered behind in a queue tied with a black silk ribbon. To his left a large terrestrial globe sits on a turned wooden stand; on a small table beside the stand, a bound volume lies open with a blue ribbon marker trailing from its pages. To his right a pale stone mantel carries a tall brass candelabrum of unlit tapers, and above it hangs a framed landscape in a gilt frame. Between the parted curtains behind him, a fluted column rises against a daylit sky and a glimpse of rolling green country. The composition restages Gilbert Stuart's Lansdowne portrait of 1796, the ceremonial sword and state papers replaced here by the globe and the book."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "Harun al-Rashid, Commander of the Faithful and fifth caliph of the Abbasids, sits in a palace garden in the late morning, a paved courtyard opening behind him onto a pale stone colonnade of pointed arches, a distant dome rising through the haze beyond. He is bearded and dark-haired, seated on a low carved wooden chair whose armrests end in rounded finials, his head wrapped in a tall saffron turban with a soft cap rising at its top. A wide sash of the same saffron cloth, its ends brocaded and fringed in gold, is wound across his chest from the right shoulder and gathered at the left hip over a loose white robe that falls to his ankles, the robe's hem banded in the same gold brocade. His right hand is raised near his shoulder and holds a qalam, the Arabic reed pen, between thumb and forefinger; his left hand rests flat on his lap. His feet are set on a round carpet woven in blue, cream, and rust medallions, and on the flagstones beside it lie two bound codices, the topmost a deep red board tooled in gold. Potted cycads and ferns in glazed blue bowls stand to either side of the chair, a tall terracotta urn rises to the right, and dark hedges close the middle distance beneath the arcade."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "Ashurbanipal, King of the World, King of Assyria, stands in a columned hall of his palace, a tablet of pale stone held upright against his chest in his right hand, his fingers curled over its top edge. He is broad-shouldered and bare-armed, his skin warm in the light. His beard is long and square-cut, dressed in tight parallel curls to the chest, his black hair falling in matching ringlets to the shoulder. A low gold diadem circles his brow, its band worked with rosettes. He wears the ankle-length royal shawl of the Assyrian court: a deep blue under-robe strewn with gold rosettes, wrapped over by a heavy magenta mantle whose fringed edge runs diagonally across his torso, over his left shoulder, and down his back, its hems banded in gold and red embroidery. Wide gold cuffs clasp both wrists, and a matching band circles his right upper arm. Behind him rises an arched niche framed by slender columns with pale voluted capitals; to either side, set on plinths, stand the dark bearded figures of lamassu, the human-headed winged bulls that guarded the gates of Assyrian palaces. On the back wall, shallow stone reliefs show horses in profile in a horizontal register, after the hunt-and-chariot panels of his palace at Nineveh. The floor is laid in pale tile, the hall falling away to shadow at either side."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "Maria Theresa, by the Grace of God Dowager Empress of the Romans, Queen of Hungary, of Bohemia, of Dalmatia, of Croatia, of Slavonia, of Galicia, of Lodomeria, Archduchess of Austria (and so on and so forth), stands on an arcaded stone loggia, a covered gallery whose tall round arches open on one side to an alpine landscape of snowcapped peaks, and on the other to a polished floor with a red carpet runner laid along the colonnade. Red damask panels hang between the arches on the interior wall, and sunlight from the left throws long shadows across the stone. She stands in three-quarter view, arms folded lightly at her waist, head turned slightly away. Her hair is pale blonde, drawn back and pinned high in the court style. Her gown is pale blue-grey silk; the bodice is tight-laced to a point at the waist and fronted by a stomacher, the stiff decorated panel worked in silver embroidery and small jewels. A wide hooped skirt spreads over panniers, the same silver embroidery running in a trailing band down the open front of the overskirt. The sleeves end at the elbow in short puffs trimmed with white lace. A sheer lace kerchief is folded across the shoulders and tucked into the neckline. She wears no crown and no visible jewels. Behind her the arches recede in pale stone, the balustrade of turned pillars running off into the distance, the Alps bright and the sky clear."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "Montezuma Xocoyotzin, Huey Tlatoani of the Mexica, stands before a great brazier whose flames rise between him and the viewer, the hall around him lit only by that fire. He is bare-chested and heavily built, his skin dark in the firelight, his face half in shadow. His crown is the quetzalapanecayotl, a crest of long iridescent quetzal tail feathers in green and blue bound with a gold frontlet. Gold spools pierce his ears, a jade-and-gold collar circles his neck, wide jade-and-gold cuffs clasp his wrists, and gold bands circle each bicep. Behind him, set into a wall of red masonry, a great carved disk shows concentric bands of glyphs around a central face, after the Aztec Sun Stone. The walls to either side are carved in rows of stylized skulls, the tzompantli, the rack of skulls displayed at Aztec temples; above each rack rises a large carved Aztec deity mask, and a stone urn at the top of each wall burns with a tall flame. The whole hall glows in the red and gold of the firelight."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "Nebuchadnezzar II, King of Babylon, sits on a massive stone throne in a hall of green-lit masonry, the walls behind him receding into shadow. He wears the agu, the tall rounded cap of the Neo-Babylonian kings, banded at the brow. His beard is long, dark, and dressed in tiered rows of tight tubular curls. His robe is deep red, short-sleeved, and patterned all over with evenly spaced gold rosettes, belted at the waist with a wide embroidered sash; the skirt falls straight to his bare feet, hemmed in a band of pale fringe. Heavy gold cuffs clasp each wrist. His hands rest palm-down on the throne's broad arms, which terminate at the front in carved lion-head corbels, the snarling mouths facing outward at the level of his knees; a smaller pair of matching lion-heads project from the base of the throne at his feet. Flanking the throne stand two tall stone plinths carved with coiled serpentine bodies, each topped by a wide shallow bowl from which rises a pale green flame, the only light in the chamber, casting their sickly green across the stone walls, his face, and his robe."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "Dom Pedro II, Emperor of Brazil, sits at a broad wooden writing desk in a dark paneled study, the scene framed as though the viewer stands across the desk from him. He is an older man, broad-shouldered and heavy-set, with a full white beard that falls well below his collar and thinning white hair swept back from a high forehead. He wears a dark frock coat over a dark waistcoat and a high-collared white shirt with a dark cravat at the throat. At his left breast is pinned the jeweled star of the Imperial Order of the Southern Cross, of which he was Grand Master. Both hands rest flat on the desk; loose papers and a small inkwell lie before him, and a quill pen stands upright in a round penholder near his right hand. On the desk to his left stands a lit oil lamp with a tall clear glass chimney and a polished brass base, its flame the brightest point in the picture and the source of most of the light that falls on his face and hands. Behind him and to the sides, the walls are lined floor to ceiling with bookshelves in deep shadow. A tall window at his left shoulder shows a slice of night sky in deep blue through angled wooden blinds, palm fronds silhouetted beyond. At the far left of the frame, a smaller leaded-glass window of diamond panes catches the warmer colors of a dusk sky, and a small mantel clock sits on a shelf beneath it. The floor is covered by a patterned rug in muted reds and golds."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "Theodora, Augusta of the Romans, reclines on a low couch of gold brocade on an open colonnaded terrace, one arm draped along a bolster, the other resting in her lap. Her crown is a jeweled stemma, the domed cap of the Byzantine imperial headdress, its band set with a row of cabochon stones. A green jewel sits prominently at the brow, the crest above rising to a second green stone clasped in goldwork. Her hair is drawn back beneath it and falls long over her right shoulder. Pendilia, the pearled pendants of the stemma, hang beside her face; a maniakis circles her throat, the jeweled imperial collar of the East. Her gown is layered: a close-cut deep red bodice clasped at the center with a gold medallion, a skirt of gold-green silk patterned in scrollwork lying across her lap, and beneath it a long underskirt of dark teal banded at the hem with narrow gold. Gold cuffs circle her wrists. A heavy red curtain falls behind her on the right, pulled aside to reveal the scene beyond. The terrace is floored in warm stone and edged by a carved balustrade set with urns of red flowers, two pale marble columns framing the view. Across a broad valley stands the Hagia Sophia, the broad central dome flanked by a lower half-dome, its walls tawny in the sunlight, low hills fading blue behind it under a clear sky."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "Dido, founder-queen of Carthage, stands on a palace terrace at night. Behind her, the sky is deep blue and pricked with stars, a distant headland faintly visible on the horizon above a low parapet. A curved stone bench stands at her back, its end-piece carved with a scrolling frieze, and pale columns rise behind it. Flanking the terrace, two large shrubs in pale stone planters bear dark leaves and small red blossoms: pomegranates, whose Latin name punicum marks them as Carthage's tree. She is fair-skinned, her dark hair parted at the center and falling past her shoulders, a slim gold diadem at her brow. Her gown is a pale, near-white chiton, the Greek tunic pinned at the shoulders and belted at the waist, its floor-length skirt scattered with a faint woven pattern. Short slit sleeves are pinned at intervals down the upper arm with small brooches, and a broad sash of deep blue wraps her waist and hangs in a long panel down the front of the skirt. At her throat lies a wide pectoral of dark stones set in gold, and a thin gold bracelet circles one wrist. Her hands rest at her sides, the stone around her cool in the night light."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "Boudicca, Queen of the Iceni, stands on the grassy shoulder of a hilltop stronghold. To the left is a stone wall topped by a timber palisade of sharpened stakes, the conical thatched roof of a roundhouse showing above it; to the right, a range of green hills falls away beneath a heavy grey sky. Her hair is cropped short and vivid copper-red, a pale length of cloth tied at the back of her head and trailing down behind her shoulder. A small dark blue mark sits on her cheekbone below one eye, woad of the kind ancient Britons used as body paint. A Celtic torc, twisted gold and rigid, circles her neck. Her dress is a sleeveless knee-length tunic in a blue and green checked weave, cinched at the waist by a leather belt with a round buckle. Leather vambraces are laced over her wrists, a matching guard strapped around her upper arm, her calves bare above low leather boots. In her left hand she holds a straight double-edged La Tène short sword, the blade tapered to a point and the hilt small and plain; her right hand grips the upright shaft of a spear planted butt-down in the turf. To her left stands a light two-wheeled chariot, its single spoked wheel iron-rimmed, a bundle of long spears angled up out of its bed."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "Wu Zetian, Huangdi of the Tang, stands at the center of a dim hall between heavy red curtains pulled back to each side. Behind her a row of warm golden lanterns hangs in the darkness, the dark wall behind them set with panels of carved latticework. Her black hair is gathered and piled high on her head, fixed at the front with a buyao, a gold and pearl ornament. She wears a ruqun, worn layered. An inner robe of pale gold silk crosses at the breast above a stiff gold panel embroidered with a medallion; a vivid red sash, tied high under the bust, falls as a long skirt to the floor. Over this she wears an outer robe of deep red silk figured with gold roundels, its wide sleeves hanging past her hands and its trailing hem spread on the floor around her feet. She holds a small gold vessel in both hands at her waist, lifted slightly as if presented. Her complexion is pale, her expression composed, her gaze calm. Red curtains, red robe, and gold lanterns warm the frame against the dark of the hall."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "Harald 'Bluetooth' Gormsson, King of the Danes and of Norway, stands amidships on the open deck of a longship. He is broad and heavily built, his beard a reddish blond forked into two plaited tails that fall past his collar, his mustache long and drooping. His head is bare, the hair drawn up into a topknot. A mantle of long russet fur rests across his shoulders. Beneath it he wears a green-grey tunic with a darker yoke, its hem and cuffs picked out in tooled bands of Norse interlace. A wide belt of worked leather crosses his waist, fastened with a heavy square buckle, and a second strap runs diagonally across his chest; both his hands rest on the belt at his front. His helmet lies on the deck beside his feet, a dome of dark iron with a reinforcing brow and nose band and sides flared into rounded flaps of thick russet fur. To his left the ship's stem post curves up and inward in a tall wooden spiral, carved to resemble a dragonhead. Behind his right shoulder rigging lines run down from a mast, and above them a sail hangs in broad vertical stripes of red and white. Along the gunwale a round wooden shield is mounted face-out, its iron boss at the center. The sky above is open and blue, banded with high cloud."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "Ramesses II, Pharaoh of the Two Lands, sits on a throne at the top of a short flight of steps, a hall of tall blue-painted columns opening to either side of him. He is young-faced and clean-shaven, his skin deep bronze, his eyes rimmed in dark kohl. His headdress is a nemes, a striped gold-and-blue headcloth gathered close at the temples and falling in pleated lappets to his chest. At his brow rises the uraeus, a rearing cobra that marks kingship. Across his shoulders and chest lies a wesekh, a broad collar of stacked beaded rows in gold and lapis blue. He wears a shendyt, a pharaonic pleated kilt of long white linen, belted at the waist by a wide sash of gold and blue that falls down the front in a stiff patterned panel. His feet are sandalled and rest on the top step. In his left hand he holds a tall staff against his shoulder; his right rests on the arm of the throne. The columns flanking him are painted in registers of blue, gold, and red, their capitals shaped as papyrus bundles and carved in rows of hieroglyphs and standing figures. Set before the throne to either side stand two large golden statues of Isis and Nephthys, the protective goddesses, their wings outstretched and sweeping forward, feathers rendered in long gilt blades. Palm fronds lean in from either side, and the yellow stone steps at his feet are incised with rows of small triangular motifs. The whole hall is lit in warm gold, the blues of the columns and collar the only cool notes against it."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "Elizabeth I, by the Grace of God Queen of England, France, and Ireland, Defender of the Faith, sits on a tall carved throne flanked by two candelabras on stone plinths, their tapers unlit. A canopy of state rises behind her, heavy red velvet pulled back in folds by tasseled cords of gold, the darkness of the chamber beyond barely visible. Her hair is piled high in tight curls of reddish blond, bound with a small jeweled coronet; her collar is the stiff open ruff of the late Tudor court. Her gown is gold brocade embroidered in black, the bodice close-cut and jeweled, the sleeves puffed at the shoulder and tapering to lace cuffs, the skirt spread wide over a farthingale. Long ropes of pearls cross her breast and hang from her waist, worn in her time as a device of virginity. Her pale hands rest on the arms of the throne."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "Haile Selassie I, Emperor of Ethiopia, Elect of God, Conquering Lion of the Tribe of Judah, stands in a long reception hall of his palace, a pale coffered ceiling overhead, tall windows to his right, a crystal chandelier suspended between them. He is slight and upright, dark-bearded, his hair cropped close. He wears a dark military tunic buttoned to the throat, plain dark trousers, and a wide black leather waist belt. Across his right shoulder and down to his left hip runs a broad emerald green moire sash, the riband of the Order of Solomon's Seal. Four rows of miniature ribbons cluster high on his left breast, campaign and honour decorations accumulated across his reign. Below them hang two large breast stars of senior imperial orders, eight-pointed and worked in gold and enamel. His left hand rests at his side, his right holds a pair of gloves. To his left stands the imperial throne: a high-backed chair upholstered in pale cream and blue, its crest carved into an arched crown and draped with an embroidered cloth, set on a red patterned carpet that runs the length of the hall. Pale upholstered chairs line the walls behind him, receding into the room."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "Napoleon Bonaparte, Emperor of the French, sits astride a pale grey horse in a twilit field of dry grass, a reddish-brown sky and bare trees behind him. He wears a dark blue coat with heavy gold epaulettes, a white waistcoat, white breeches, and tall black riding boots. His bicorne is worn athwart, the two points turned to his shoulders in the orientation he favored to set himself apart from his officers. The horse's bridle is red leather studded with gilt; the saddlecloth beneath is trimmed red and gold. The composition recalls Jacques-Louis David's Napoleon Crossing the Alps, though stilled: no rearing charger, no pointing hand, only a figure alone in the landscape at dusk."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "Otto von Bismarck, Minister President of Prussia and First Chancellor of the German Empire, stands in a tall state room lit by daylight pouring through leaded windows behind him, each pane divided into small squares by slender muntins. Heavy crimson drapery is swagged and tied back at each window in deep folds, its inner lining a darker red. The floor is polished to a mirror and catches the window light in long pale bands. To his left, a small side table holds a white globe lamp. He is tall and broad-shouldered, bald on top with a close fringe of silver-grey hair at the sides and back, and wears a heavy white moustache, long and swept outward at the tips. His coat is a dark double-breasted military frock in deep slate, fastened down the chest by two parallel rows of gold buttons, the standing collar trimmed in gold, the shoulders weighted with heavy gold bullion epaulettes whose fringe hangs to the upper arm. Just below the collar hangs a small pale cross on a dark ribbon, the Pour le Mérite, Prussia's highest military order of merit. He stands three-quarters to the viewer, upright and still, his gaze fixed past the viewer's shoulder."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "Alexander the Great, King of Macedon and Hegemon of the Hellenes, sits astride his solid black stallion, Bucephalus, reining him in on a green upland meadow with ranges of grey mountains to either side and a single snow-capped peak rising at the right. He is young and clean-shaven, his brown hair parted at the center and swept up from the brow in an anastole, a lifted forelock that became a signature of his portraits. He wears a linothorax, Hellenistic body armor of layered linen and leather, faced with gilt plate, its shoulder yokes tied down at the chest by short cords. At the center of the breast, a square gilt plaque carries a gorgoneion, the head of Medusa in relief. From the shoulders and from the belted waist hang pteruges, rows of stiffened leather strips that protect the upper arms and thighs, each strip edged in red and tipped with a gold stud. His arms are bare, a broad gold band on the right wrist; he wears no helmet and carries no visible weapon. The horse's tack is dark leather worked with red, the browband and cheekpieces studded, a single rein drawn across the neck in his left hand. Beneath the saddle, a dappled leopard-skin drapes the horse's flank, paws still attached."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "Attila, King of the Huns, sits on a high-backed wooden throne atop a raised dais, the hall around him lit in deep reds and gold. He leans back at his ease, one leg crossed over the other, a bared sword laid across his lap; one hand rests on the blade, the other holds a goblet. His tunic is red and long-sleeved, bordered in gold, worn over dark blue trousers tucked into tall soft-leather boots trimmed with fur at the cuff. A conical cap of dark fur set with a gold band sits on his head. He is bearded and long-moustached, his face half-lit from the right. The throne's armrests end in carved lion heads, and a heavy fur is thrown over the back. Behind him, a wall of red drapery is flanked by panels hung with round bronze discs of graduated size, the firelight catching in them. To the right of the dais, a tall iron candle stand burns with a single taper. Beyond it on the floor, a large brass bowl bristles with the hilts of sheathed swords stood upright. Past that, an open wooden chest spills coins across a patterned carpet."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "Pachacuti Inca Yupanqui, Sapa Inca of Tahuantinsuyu, sits on a high stone throne on a terrace above Machu Picchu, the throne carved with rows of interlocking geometric motifs picked out in gold and red. Above him to his right, fixed to a stone pillar, a great gold sun disk shows a stylized human face at its center within a ring of rays radiating outwards. Bare peaks rise steeply to his left, and low thatched buildings are laid out on stepped agricultural platforms below. He wears a mascapaycha, a red woolen fringe that falls across the forehead as the emblem of Inca sovereignty, bound by a llauto, a multicolored headband, and crowned with a spray of upright red and dark feathers. His hair is black and shoulder length. Around his neck hangs a heavy gold disk pectoral. His tunic is a sleeveless knee-length garment patterned in a bold black and white checkerboard with a red and gold yoke at the chest. Below the knee his legs are bound with red fringed cords. In his right hand he holds a tall staff topped by a gold bird figure, its shaft hung with tiered red tassels."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "Mohandas Karamchand Gandhi, Mahatma, leader of India's independence, stands on an Indian coast of dry yellow grass, rocky headland, and pale sea. He is thin, bald, bespectacled, with a close-cropped grey mustache. He wears the dress of his later life: a plain white dhoti wrapped at the waist, a shawl draped across one shoulder and under the opposite arm, his chest bare. The cloth is undyed and hand-spun, a deliberate rejection of British cloth that became the emblem of his movement. The setting recalls the long walks he made toward the sea during the struggle for independence, a solitary figure at the edge of the subcontinent."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "Gajah Mada, Mahapatih of the Majapahit Empire of Java, stands at the edge of a flooded rice paddy, the water mirror-bright between low ridges of green. Behind him, dense tropical forest climbs a hillside wrapped in pale mist, and from that mist rises the slender stepped silhouette of a candi, a red-bricked temple tower, its tiered roof dissolving into cloud. He is broad-shouldered and bare-chested, his dark hair drawn up into a topknot, a small tuft of beard at the chin. Gold bands clasp each bicep and each wrist. A wide belt sits high on his waist, fastened with a large scalloped gold plaque worked in the floral Majapahit style. Below the belt a red sarong is wrapped and knotted at the front, the folds falling in heavy panels over a yellow under-cloth that shows at the hem. At his right hip, slung from a cord through the belt, hangs a sheathed kris whose dark wooden scabbard tapers to a narrow point, hilt jutting forward at a canted angle."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "Hiawatha, founder of the Haudenosaunee Confederacy, stands in a sunlit clearing, a large grey boulder rising at his shoulder and slender trunks of beech and birch receding into green undergrowth behind him. He is bare-chested and lean, his skin warm brown in the dappled light. His hair is styled in a scalplock, the sides of the head shaved close and a narrow ridge of dark hair running front to back along the top, with two upright feathers fixed at the rear. Bands of dark paint ring each upper arm. A close-fitting choker of white shell beads, a wampum, sits at his throat, and a single strap crosses his chest from the right shoulder to the left hip, supporting a quiver of arrows whose fletched ends rise past his shoulder. At his waist a breechcloth of pale tan deerskin hangs in a long front flap to mid-thigh. Fringed deerskin leggings sheathe his calves from ankle to knee, tied below the knee and left open at the thigh where the breechcloth covers him. He stands barefoot on the packed earth of the clearing, arms at his sides, the forest light falling across his right side."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "Oda Nobunaga, daimyo of the Oda clan and first of the great unifiers, stands in a rolling green country of tall grass and scattered white stones, a range of blue mountains receding to the horizon under a bright sky of piled cloud. His head is shaven across the pate in the sakayaki manner, brow and top shaved so a helmet would sit cool and steady, the remaining hair gathered behind. He wears a close mustache and a short chin beard. His armor is tosei gusoku, a modern Sengoku-era harness: lacquered iron plates laced in horizontal rows by silk cords, the cuirass and skirt plates bound in alternating bands of dark blue and vermilion. The shoulder guards hang in the same laced plates over each arm. Over it he wears a sleeveless tan battle coat, its front panels open to show the laced cuirass beneath. A broad red sash is knotted at his waist, a sword thrust edge-up through it; at his right side hangs a second sword, his right hand on its hilt. Together they are the daisho, the paired long and short swords carried by every samurai. Rising from behind his right shoulder, carried across his back, is the long dark stock and slender barrel of a tanegashima, the matchlock firearm whose mass adoption Nobunaga is remembered for. He stands alone in open country, only the grass, the stones, and the far mountains around him."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "Sejong the Great, fourth king of the Joseon dynasty, sits centered on a raised wooden dais in the throne hall, an open book held in both hands at his lap. He wears a gonryongpo, a red silk dragon robe worn by Joseon kings, the chest and shoulders worked in gold roundels of four-clawed dragons and bordered in gold scrollwork. A broad jade-set belt crosses his waist. On his head is an ikseongwan, a stiff black gauze cap with two small upturned wings rising from the back like folded leaves. He is clean-shaven but for a trim dark mustache and a short beard at the chin. Behind him rises the Irworobongdo, the sun-moon-and-five-peaks folding screen set behind every Joseon throne, where the king was the sun to the queen's moon: a white moon disk at upper left, a red sun disk at upper right, jagged peaks in deep green, and dark red pines spreading along the lower register. The throne itself is lacquered red, its side panels carved with medallions of tigers. Red lacquered balustrades and posts frame the dais to either side; paper lanterns hang at the edges of the hall, glowing yellow; a short flight of stone steps descends toward the viewer."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "K'inich Janaab' Pacal, K'uhul Ajaw of Bʼaakal, the Holy Lord of Palenque, stands on the terrace of a limestone palace above his capital at midday, stepped pyramid temples rising from the jungle beyond, their roofcombs carved and weathered to a pale rose. Behind his shoulders spreads a great backrack, a wooden frame fanned with long quetzal tail feathers in bands of green, blue, and deep red, mounted over a rectangular plaque of carved and painted glyphs. His headdress is tall and tiered, crowned with more quetzal plumes. His hair falls long and dark to the shoulder. A wide collar of carved jade plaques lies across his chest, a square jade pectoral hangs at its center, and jade ear flares pierce his lobes. A beaded belt gathers a kilt of knotted cloth and feathers at the waist, knee-length fringes of long feathers hang to either side, and his sandals are strapped high up the calf. In his left hand he grips the manikin scepter of K'awiil, a tall staff topped with a small carved head of the lightning deity whose effigy Maya rulers held as the emblem of kingship. To his left, at the edge of the terrace, stands a wide stone brazier, its rim ringed with stubs of burned offerings. The city beyond recedes into haze, pyramid after pyramid stepping down toward a river plain."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "Genghis Khan, Great Khan of the Mongols, sits mounted on a black horse on the open steppe, shown from the waist up and turned three-quarters to the viewer. His helmet is tall and conical, rising to a sharp finial, its dark browband and cheek flaps framing a thin mustache and a small tuft of beard at the chin. His armor is riveted Mongol cavalry harness, the chest dominated by a large round bronze boss stamped with a coiling design; broad pauldrons sit over the shoulders, and studded bands wrap the upper arms. A dark cloak falls from his shoulders, its lining a muted purple where it drapes behind the saddle. The horse's tack is plain leather, a simple bridle with nothing but a browband and forward-gathered reins. Behind him, low green hills roll under a pale overcast sky; on the middle slope stands an encampment of gers, the round white felt tents of the Mongols, pale specks of livestock scattered on the grass around them."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "Ahmad al-Mansur, Saadian Sultan of Morocco, stands at the edge of a Saharan encampment under a deep blue sky. A thin crescent moon and scattered stars hang above low dark ranges on the horizon. He is bearded, his skin warm in the lamplight, his gaze level and turned toward the viewer. He wears the layered dress of the Maghreb: a long white djellaba, an ankle-length hooded robe of North Africa. Over it drapes a selham, a fine wool cloak of princes and rulers, its hood lying back between his shoulder blades. A white turban is wound around his head. At his chest hangs a rectangular embroidered panel in cream and gold, patterned in the interlaced geometry of Islamic ornament. A broad sash of vertical red and cream stripes is wrapped twice around his waist and knotted at the front, the ends tucked under. Behind him and to the left, a great rounded caravan tent of dark striped cloth glows from within, its open flap spilling warm orange light onto the sand; two camels rest on the sand beside it. A smaller light burns further off, and a cluster of date palms rises against the hills."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "William I, Prince of Orange, father of Dutch independence, stands in a tiled chamber lit by a tall leaded-glass window on the left, its small diamond panes framed by heavy red drapery drawn back at the side. The floor is laid in black and white marble squares. Behind him on the far wall hangs a gilt-framed landscape painting of the low country under a heavy sky, a river winding through flat green fields toward a distant town. To his right, a wooden stool carries a terrestrial globe, its meridian ring of brass catching the window light. To his left, a writing table dressed in a red cloth bears an open leather-bound book and loose sheets of paper, and behind it stands a high-backed chair upholstered in blue. The whole interior recalls the scholars' rooms of Vermeer's Geographer and Astronomer, though William belongs to the generation before that style. He is a bearded man in middle age, dark hair cropped short under a small flat cap, mustache and forked beard trimmed close, a broad white pleated ruff standing out at his throat. Over his shoulders hangs a long black cloak, pushed back on the right to free his arms. His doublet is a dull gold figured silk, close-cut to the torso, the front buttoned in a single line. His breeches are paned trunk hose, built from long vertical strips of red and white cloth arranged in alternating stripes over a fuller lining and ending mid-thigh. Plain dark hose cover the lower legs and meet low leather shoes on the checkered floor. In his right hand he holds a baton of office, raised at chest height; his left hand rests near his hip, where a sword hilt is just visible under the fall of the cloak."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "Suleiman the Magnificent, Kanuni the Lawgiver, Sultan of the Ottomans, stands in Topkapi Palace beneath a ribbed dome, a hall of pointed arches faced in blue-and-white Iznik tile. Shafts of daylight fall from unseen windows across the pale stone columns behind him. He is bearded, dark-eyed, his mustache and beard close-trimmed around a thin mouth. His turban is the tall, round kavuk for which he was known, a great wrapping of white cloth bound around a conical frame and rising well above his brow. At its top rises a sorguç, a green plume that marks the sultan's rank. Over an inner robe he wears a long kaftan of yellow silk woven with a pale tracery of vines and rosettes, the front opened to the waist. A wide band of soft grey fur trims its full length, marking it as a kapanice, the highest robe of honor. A dark sash crosses the kaftan at the waist. In his right hand, held upright against his chest, is a bound volume in dark leather. His other hand rests at his side. The hall behind him recedes into shadow between the tiled arches."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "Darius I, the Great, King of Kings of the Achaemenid Empire, stands atop a low flight of steps at the head of a great hall, a shaft of light falling on him from above. He is broad-shouldered and full-bearded, the beard long, square-cut, and tightly curled. On his head is the kidaris, the tall crenellated crown of the Persian kings, a gold cylinder ringed with square merlons. His robe is a long saffron-yellow gown that falls to his feet, banded at the chest, cuffs, and hem with red and gold embroidery. A red sash gathers it at the waist. Heavy gold armlets clasp each bicep. Flanking him on pedestals to either side rise two colossal lamassu, winged bulls, their bodies and folded wings covered in gold, the guardian figures of the Gate of All Nations at Persepolis, here the human-headed version pared back to the bull alone. The back wall is carved in low relief with a procession of figures in long robes and soft caps, after the tribute-bearer reliefs of the Apadana staircase. The stone of the platform and steps is a pale blue-green, picked out with gold bosses at the corners."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "Casimir III the Great, King of Poland and last of the Piast kings, stands in the mouth of a stone gatehouse lit by iron wall sconces whose flames throw a warm red-gold light across the masonry. He is broad-shouldered and full-bearded, the beard dark and trimmed close, his gaze level. His crown is a gold arched circlet set with red stones, its arches closing above in a jeweled finial. Around his shoulders lies a broad tippet of white ermine, the fur worked with small black tail-tufts. Beneath it his mantle is a long crimson robe buttoned down the chest in a line of small gold studs and belted at the waist with a wide gilt belt. In one hand he holds a golden scepter upright at his chest; at his hip hangs Szczerbiec, the Piast sword of state. To either side of him, heavy iron chains descend from the upper darkness along the inner faces of the gatehouse. Behind him, set in the archway at the back of the chamber, a red panel bears the crowned White Eagle of Poland, its wings spread. The eagle is rendered in dark silhouette on the red field rather than the usual silver. The stone is massive and close-fitted, the light pooled on the king and falling off sharply into the shadowed vaults on either side."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "Kamehameha the Great, unifier of the Hawaiian Islands and first Mo'i of the kingdom, stands barefoot on a white-sand beach, the turquoise shallows of a sheltered bay behind him and a dark forested ridge rising beyond. He is tall and heavily built, bare-chested, his skin deep brown in the tropical sun. Over one shoulder hangs an ahu'ula, a feather cloak of Hawaiian ali'i, deep red and falling nearly to his ankles. A broad sash of the same red crosses his chest from the left shoulder, its yellow borders set with small geometric blocks of red. A matching panel of red and yellow hangs at the front of his malo, a loincloth wrapped at the hips. On his head sits a mahiole, a low crested helmet with a narrow fore-and-aft ridge rising from brow to nape, worked in red with yellow striping and a yellow band at its base. In his right hand he holds a tall wooden spear, its head barbed; his left arm hangs at his side. To his right, drawn up on the sand, lie two wa'a kaulua, Polynesian double-hulled voyaging canoes, their twin hulls joined by lashed crossbeams. The sails are triangular, the point at the mast foot and the upper edge curving outward in a long U; the canvas is pale and patched. A third canoe rides at anchor further out in the bay. On the shore behind his left shoulder stands a thatched hale, a Hawaiian house of pole frame and dried-grass roof, half shaded by the fronds of coconut palms. The sky above the ridge is blue with high white cloud."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "Maria I, Queen of Portugal, the Algarves, and of Portuguese dominions beyond the sea, stands on the terrace of the Palácio da Pena at Sintra, a pale stone gallery under a row of heavy Romanesque arches. The Atlantic opens beyond their columns. Her gown is deep blue silk. The bodice is close-fitted with a pointed waist, the elbow-length sleeves finished in white cuffs, the skirt full over panniers and falling in broad folds to the stone. A short red cape is fastened at her shoulders and trails behind her. Across her chest runs a wide white sash edged in red, the sash of the Portuguese Order of Christ, worn by Portuguese sovereigns as Grand Master. A band of jeweled ornament is set down its front. Her dark hair is dressed high, piled above the brow and fixed with an aigrette, a small black ornament pinned with an upright feather. Her right hand rests at her side on the hilt of a slender scepter whose dark shaft falls against the blue of her skirt. To her right, past the balustrade, a narrow sea inlet runs between red cliffs. Two square-rigged Naus with furled canvas are anchored in the channel. To her left rises a yellow-walled keep crowned by a bulbous dome of gilded and tiled bands. Crenellated yellow ramparts step down toward the terrace where she stands. The sky is clear, the light is a bright Atlantic afternoon, and the arches frame her against water on one side and royal architecture on the other."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "Augustus Caesar, first emperor of Rome, sits on a curule-style seat between two bronze sphinx heads, their smooth faces turned outward. He is clean-shaven with short dark hair combed forward over the brow, the fringe of the Prima Porta tradition. A toga picta, a ceremonial purple toga worn at a Roman triumph, is wrapped over his white tunic and drawn across the lap and up over the left shoulder. The neckline of the tunic is bordered in gold. His right hand rests open on one of the sphinx heads; the left lies loose across his knee. Behind him, a dim hall of dark red walls is set with fluted columns and hung with vertical banners of red and gold. On the rear wall, a round bronze medallion bears a lion's head in relief. Shafts of pale daylight fall from the left across his face and chest, leaving the far side of the hall in shadow; two small braziers on iron stands at either side of the throne burn low."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "Catherine II, Empress and Autocrat of All the Russias, stands in the Hall of Light, the Great Hall of the Catherine Palace at Tsarskoye Selo. Her body is turned three-quarters to the viewer, her gaze level. Her dark hair is drawn up and dressed high in the late-eighteenth-century European court fashion. A small jeweled diadem binds it at the top, its points suggesting the tall fleur-shaped arches of the Great Imperial Crown of Russia in miniature. Her gown is court dress of ivory silk: a close-cut bodice with a gold-embroidered central panel down the front, puffed half-sleeves of deep blue trimmed at the shoulder with bands of white ermine. A full skirt spreads below, embroidered in gold with the double-headed eagle of the Russian imperial arms scattered as a repeating motif. Across her body from right shoulder to left hip runs a wide pale blue moire sash, the riband of the Order of Saint Andrew the First-Called. Tall arched windows down the right wall are hung with pale blue curtains drawn back in swags, shafts of daylight falling in visible bars across a black-and-white marble floor polished to a mirror. On the left wall a run of gilded rococo carving, scrolled and foliate, frames mirrored panels."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "Pocatello, chief of the Northwestern Shoshone, sits on a cairn of weathered red boulders at the edge of an intermountain basin, a flat sagebrush plain stretching behind him to low mesas silhouetted on the horizon beneath a dusk sky of rose and pale violet. He is broad-shouldered, his long black hair parted at the center and falling to the chest, with one upright eagle feather fixed at the back of the head. A second dark feather rises behind his shoulder from the quiver strapped to his back. A short wooden bow is slung across alongside the quiver, its upper limb jutting above his right shoulder. In his right hand he holds a long spear planted butt-down against the rock, the shaft wrapped with hide and trailing a dark tuft near the head. Over his torso he wears a fur vest, crossed by a wide strap of tanned hide worked in rows of beadwork running from the right shoulder to the left hip, a short knife sheath hanging at its lower end. His upper arms are wrapped with stacked silver bands. From the waist down he wears dark fringed hide leggings falling to the ankle, and a breechcloth between them. His left hand rests open on his thigh; his posture is still, weight settled on the stone. The light is low and warm, catching the red of the rocks and the edge of the spear, and the distance beyond him is the sagebrush country of the Great Basin, the homeland of the Shoshone between the Rockies and the Sierra."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "Ramkhamhaeng the Great, King of Sukhothai, stands in a sunlit palace garden. The green haze of a tropical forest and the pale silhouettes of distant chedis, bell-shaped Buddhist stupas of Thailand, rise through a low mist behind him. He is slender and bare-chested, his skin warm brown, his face turned slightly to his left with a faint smile. His crown is tall, tiered, and pointed, rising to a slender spire: a chada, the conical crown of Thai kings. A wide gold pectoral collar lies across his shoulders and chest, worked in scrolling repousse and set at the center with a single red stone; narrower gold bands clasp each upper arm. A white silken sash is wound and knotted at his waist, the twisted ends falling to his thighs. Beneath it he wears a wrap-cloth of deep red patterned in gold, with a darker under-layer visible at the hem. To his right, at the edge of a still pond scattered with pink lotus blossoms and their broad flat pads, stands a small stone sculpture: a serene Buddha head, eyes lowered, set upon a lotus-bud pedestal. A pale sand path curves away to his left between banks of red-flowering shrubs, leading back toward the misted towers of the capital."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "Mohammad I, Askia the Great of Songhai, stands on a rocky bluff at sunset with a long blade shouldered and a burning city at his back. He is dark-skinned, close-bearded, his eyes fixed on the viewer. His head is wrapped in a tagelmust, a pale cream Sahelian turban wound high and gathered at one side. Over his shoulders falls a long crimson boubou, a wide-sleeved robe of the West African nobility, its front panel and chest embroidered in dense patterned bands of gold and dark thread. Beneath it a pale sash is wrapped around his waist and knotted so the ends hang loose at the hip, over trousers in the same crimson as the robe. He holds the sword by its hilt in his right hand and lets the blade rest back along his shoulder; it is long and straight-backed with a faint curve toward the tip,. To his right the land falls away to a plain under a red-orange sky, a dark mountain silhouetted against a low sun. To his left a city burns: mudbrick walls and a tall square minaret studded with rows of protruding wooden toron; palm beams left jutting from the plaster. Flames climb the tower and roll through the streets below it; smaller fires scatter across the plain between the city and the cliff where he stands."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "Isabella I, Queen of Castile and León, Queen consort of Aragon, stands in one of the pillared galleries of the Alhambra at Granada, its arcade opening onto a garden of clipped hedges and potted topiaries, hills fading into haze beyond. Slender paired columns with carved capitals rise behind her into lobed and scalloped arches filled with fretwork, the spandrels above them carved in dense geometric and vegetal stucco in pale gold and sand tones. She is slight, pale, her hands folded one over the other at her waist. Her head is covered in the Castilian fashion of her court: a white wimple draped close under the chin and across the throat, a white veil fitted over the top of the head, and above that a small closed crown of gold set with red and green stones. Over her shoulders hangs a long red mantle lined and edged in gold, falling open at the front. Her gown beneath is cream brocade worked in a dark repeating pattern, close-bodiced, with a gold-bordered panel down the center of the skirt. At her breast a red jewel is pinned where the mantle parts. The light is the warm low light of a late afternoon, catching the stucco of the arcade and the pale stone of the gallery floor."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "Gustavus Adolphus, King of the Swedes, Goths, and Wends, the Lion of the North, stands in a gilded palace chamber. Beside him a deep hearth burns with split logs, low and bright. He is tall and heavily built, with a full reddish beard worn to the chest and a thick upturned mustache, his hair swept back from a high forehead. He wears a blackened steel cuirass, chased with gilt bands at the edges and along the central ridge, fitted over a buff coat of thick, pale, oiled ox hide. The armor continues downward into articulated steel tassets that flare to mid thigh over a yellow underskirt. A broad sash of turquoise silk crosses from his right shoulder to his left hip, knotted and falling in a loose fold against the breastplate. Small lace cuffs show at his wrists, and a frill of pale lace edges the breeches above his boots. He stands with his weight set back, each gloved hand resting on a field baton planted point-down on the floor in front of him. Behind him the fireplace surround is carved and gilt, the mantel banded with Baroque acanthus scrollwork. To the left, two gilt-framed paintings hang against a wall of green and gold damask. The nearer shows a bearded man in dark armor, Eric XIV, an earlier king of Sweden. The farther shows a pale woman in a light court gown, Maria Eleonora of Brandenburg, Gustavus's wife. Beneath the paintings a polished dark wood table carries a shallow pewter bowl heaped with fruit, and a tall brass candelabrum rises at the table's near end, its tapers unlit. The room is lit almost entirely by the fire. The warm orange cast falls across the cuirass, the gilt plasterwork, and the right side of his face, leaving the far wall in shadow."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "Enrico Dandolo, Doge of the Most Serene Republic of Venice, stands on a stone bridge over a canal at night, one gloved hand drawn up to his chest. He is old: a long grey beard falls to his chest, grey hair shows at his temples, and his face is deeply lined. On his head sits the corno ducale, a stiff horn-shaped ducal bonnet of rust-red brocade rising to a blunt point at the back like a Phrygian cap, worn here over a close-fitting white linen camauro whose edge shows beneath it at the brow. Across his shoulders lies a heavy grey mantle trimmed in pale fur, falling open at the front and lined in the same rust-red as the cap. Beneath it he wears a long robe of deep red brocade girded at the waist with a knotted gold cord. The bridge's balustrade is wrought iron, its panels filled with slender pointed arches in the Venetian Gothic manner. Behind him the canal recedes into darkness, flanked by palazzi whose windows glow warm orange against the blue night. A narrow gondola is moored at the quay on the left, the starlit sky breaking through cloud above the rooftops."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "Shaka kaSenzangakhona, King of the Zulu, stands in the open ground of a royal homestead, feet planted, shield held out at his left side and short spear at his right. He is bare-chested, dark-skinned, and heavily muscled, his torso crossed by slender cords strung with small beads. Around his head is an umqhele, a thick circular headband of spotted leopard fur marking royal and senior rank. Fixed to it at the brow stands an upright plume of white feathers tipped in red. At his waist hangs an apron of leopard skin falling over the hips, and beneath it a skirting of long pale fur tassels sways against his thighs. Bands of the same spotted fur wrap his ankles. In his left hand he carries an isihlangu, a tall pointed oval war shield of oxhide; Its surface is mottled brown and white, a straight wooden stave running down its center and secured by leather loops. In his right hand, held low and ready, is an iklwa, a short-shafted stabbing spear with a long broad leaf-shaped blade. Behind him curves a row of iqukwane, domed grass-and-thatch beehive huts of a Zulu umuzi, their woven surfaces catching the sun. Flanking the clearing on either side rise wooden posts crowned with the skulls of long-horned cattle, the great sweeping horns still attached, wealth and sacrifice displayed at the gate. The ground is dry pale earth, a flat-topped mesa shows in the far distance, and the sky above is a clear pale blue streaked with thin cloud."
-- Economic Overview (F2 / Domestic Advisor): tab names, column labels,
-- group / row text consumed by CivVAccess_EconomicOverviewAccess.lua.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "Cities"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "Happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "Resources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "Population"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "Strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "Food"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "Science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "Culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "Faith"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "Production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "puppet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "occupied"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "occupied"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "no entries"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "no production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = "{1_Turns} turns: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "{1_PerTurn} per turn, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_NONE"] = "none"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "Treasury, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "Net per turn, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_PENALTY"] = "Science penalty, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_GROSS"] = "Gross gold per turn, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_EXPENSES"] = "Total expenses per turn, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_INCOME"] = "Income"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "Cities, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "Diplomacy, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "Religion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "Trade routes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EXPENSES"] = "Expenses"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "Units, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "Buildings, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "Improvements, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "Diplomacy, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "Total happiness, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "Happiness sources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "Luxuries, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS"] = "Buildings, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "Trade routes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LOCAL_CITIES"] = "Local cities, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "City-states, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "Policies, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "Religion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "Natural wonders, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_FREE_PER_CITY"] = "Free per city, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LEAGUES"] = "Leagues, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "Total unhappiness, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "Unhappiness sources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = "Number of cities, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = "Occupied cities, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = "Population, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = "Occupied population, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "Public opinion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "Per city"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "Available"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "Imported"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "Exported"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "Local"
-- Victory Progress (F8 / Who is winning): button labels for the five drill-
-- in sections, score-row format, and per-section row formats consumed by
-- CivVAccess_VictoryProgressAccess.lua. Disabled-victory and tooltip
-- sentence strings reuse engine TXT_KEY_VP_* keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_MY_SCORE"] = "My score"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "Domination"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "Science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "Diplomatic"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "Cultural"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCORE_ROW"] = "{1_Name}, score {2_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCORE_ROW_LOST"] = "{1_Name}, score {2_Score}, capital lost"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "team {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = "{1_Num} boosters"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "cockpit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "stasis chamber"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "engine"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, Apollo not built"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, Apollo built"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "Apollo built, no parts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, Apollo built, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "Apollo built, {1_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = "{1_Have} of {2_Total} prerequisites researched"
-- Demographics (F9): one row per metric, speaking name, rank, the active
-- player's value, then rival best (with civ name), average, and worst
-- (with civ name) -- vanilla column order. Metric name and unmet-civ /
-- "you of <Civ>" fillers reuse engine TXT_KEYs so the format key stays
-- pure positional substitution.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, rank {2_Rank}, {3_Value}, best {4_BestCiv} {5_BestVal}, average {6_AvgVal}, worst {7_WorstCiv} {8_WorstVal}"
-- Vanilla's TXT_KEY_DEMOGRAPHICS_GOLD label is "GNP", which spells out
-- letter-by-letter in TTS and tells a non-economist nothing. Mod-authored
-- override only -- the engine label stays "GNP" for sighted players.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "Gross National Product"
-- Culture Overview (Ctrl+C). Four-tab popup: Your Culture (per-city GW
-- management with click-to-move/view toggle), Swap Great Works (designate
-- swappable + foreign-offerings list + send), Culture Victory (per-civ
-- influence/tourism/ideology/public-opinion), Player Influence
-- (perspective picker + per-target modifier breakdown / level / trend).
-- Most enum-derived strings (influence levels, trend, public opinion)
-- reuse engine TXT_KEY_CO_* keys directly so phrasing matches what
-- sighted players see; mod-authored keys here only cover row formats,
-- action labels, and our drill-in framing.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "Your Culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "Swap Great Works"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "Culture Victory"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "Player Influence"
-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] = "Antiquity sites: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HIDDEN_SITES"] = "Hidden antiquity sites: {1_Num}"
-- Per-city label. {1_Name} already includes the capital/puppet/occupied
-- prefix when applicable (mirrors engine's CityDisplayName composition).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] =
    "{1_Name}, culture {2_Cul}, tourism {3_Tou}, great works {4_Filled} of {5_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] =
    "{1_Name}, culture {2_Cul}, tourism {3_Tou}, great works {4_Filled} of {5_Total}, damaged {6_Pct} percent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "puppet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "occupied"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "No great work buildings yet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "No cities"
-- Slot type words. Used as a fixed phrase ("art or artifact slot") on the
-- building label so the user knows what kind of work fits before drilling.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "writing slot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "art or artifact slot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "music slot"
-- Multi-slot building entry inside a city. Theming bonus shown when active.
-- Single-slot buildings collapse to one row (see CO_BUILDING_SINGLE_*).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled} of {4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled} of {4_Total}, theming bonus plus {5_Bonus}"
-- Single-slot building rows. The building row is the slot; activation
-- runs the move state machine directly. No drill-in.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, empty"
-- Per-slot leaf inside a multi-slot building. Slot index is 1-based.
-- The slot-type word lives on the parent label, not repeated per leaf.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, empty"
-- Work-class words used inside the slot tooltip ("art by ...").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "writing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "art"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "artifact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "music"
-- Slot tooltip built from primitives. Replaces engine's GetGreatWorkTooltip
-- which packed fields together with no labels and stripped icons.
--
-- Three forms by work class:
--   AUTHORED — art works (Museum/Cathedral/Palace etc. slot type is
--     ART_ARTIFACT and accepts either kind, so the class word disambiguates).
--   NOCLASS  — writing and music. Their slot types (LITERATURE, MUSIC) only
--     accept that one class, so the parent row's slot-type word already
--     conveys it; repeating the class would just double up.
--   ARTIFACT — archaeology works. No human author; class word kept because
--     ART_ARTIFACT slots are ambiguous and need to distinguish from art.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class} by {2_Artist}, {3_OriginCiv}, {4_Era}, plus {5_Cul} culture, plus {6_Tou} tourism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "by {1_Artist}, {2_OriginCiv}, {3_Era}, plus {4_Cul} culture, plus {5_Tou} tourism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, plus {4_Cul} culture, plus {5_Tou} tourism"
-- GW move flow feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "marked as move source"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "moved"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "move source cleared"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] = "wrong slot type for current source"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "cannot move from an empty slot"
-- Tab 2 (Swap Great Works). Three top-level rows: your offerings (drills
-- into per-type pulldowns), available from other civs (drills into civ
-- groups, then into each civ's non-empty slots), trade item with state-
-- aware label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "Your offerings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "Writing"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "Art"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "Artifact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "none designated"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "Clear designation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "Available from other civilizations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "No civilizations offering swappable works"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "No swappable works"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] = "Pick a work from another civilization to swap for"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "No {1_Type} designated to offer for {2_TheirName} from {3_TheirCiv}; designate one in your offerings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "Trade your {1_YourName} for {2_TheirName} from {3_TheirCiv}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "swap sent"
-- Tab 3 (Culture Victory). Per-civ row + drill-in detail.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_ROW"] =
    "{1_Civ}, {2_Influenced} influenced, tourism {3_Tou}, {4_Ideology}, {5_Opinion}, {6_Unhappy} unhappiness, {7_Happy} excess happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N} of {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "no ideology"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "no public opinion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_DETAIL"] = "Public opinion breakdown"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_UNHAPPY_DETAIL"] = "Public opinion unhappiness breakdown"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY_DETAIL"] = "No ideology yet, no public opinion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_CIVS"] = "No met major civs"
-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE"] = "Perspective: {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TOURISM"] = "Tourism per turn: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_ROW"] =
    "{1_Civ}, influence: {2_Level}, {3_Pct} percent, {4_PerTurn} tourism per turn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = "estimated {1_N} turns to influential"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_BAR_YOURS"] = "your tourism on them: {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_BAR_THEIRS"] = "their lifetime culture: {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NO_TARGETS"] = "No civs with influence levels"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIERS_LABEL"] = "Tourism modifier {1_N} percent"
-- Hotkey help (BaselineHandler / map-mode help list).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "Open Culture Overview"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] = "Culture Overview is disabled in this game"
-- League Overview (World Congress / United Nations). TabbedShell over the
-- engine's BUTTONPOPUP_LEAGUE_OVERVIEW: tab 1 status / members, tab 2 current
-- proposals (View / Propose / Vote modes), tab 3 ongoing effects.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "World Congress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control plus L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "Open World Congress overview"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "Status"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "Proposals"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "Effects"
-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "Rename"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(you)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "host"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATE_ONE"] = "1 delegate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = "{1_N} delegates"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "can propose"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "Diplomat in their capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "No World Congress"
-- Status pill clauses are pulled from engine keys verbatim
-- (TXT_KEY_LEAGUE_OVERVIEW_TURNS_UNTIL_SESSION / IN_SESSION / IN_SPECIAL_SESSION,
-- and the WORLD_LEADER_INFO_SESSION / _VOTES UN-only suffix), composed by
-- LeagueOverviewRow.formatStatusPill.
-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "No actions available this session."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE_ONE"] = "1 proposal available."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = "{1_N} proposals available."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING_ONE"] = "1 delegate remaining."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = "{1_N} delegates remaining."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "No proposals this session."
-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "Enact: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "Repeal: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "Proposed by {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "Proposed by you"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "On hold"
-- Vote-state suffix appended to proposal row in Vote mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "your vote: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "abstain"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA_ONE"] = "1 Yea"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = "{1_N} Yea"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY_ONE"] = "1 Nay"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = "{1_N} Nay"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV_ONE"] = "1 for {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} for {2_Civ}"
-- Footer button labels reuse engine keys verbatim
-- (TXT_KEY_LEAGUE_OVERVIEW_RESET_PROPOSALS / _COMMIT_PROPOSALS /
-- _RESET_VOTES / _COMMIT_VOTES / _VIEW_ALL_RESOLUTIONS).
-- Slot picker (Propose mode).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "Empty proposal slot {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "Slot {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "Proposal slot {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "Active resolutions to repeal"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "Resolutions to propose"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "Other resolutions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_THIS"] = "Propose this resolution"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_THIS"] = "Repeal this resolution"
-- View All sections reuse the engine's TXT_KEY_LEAGUE_OVERVIEW_*_RESOLUTIONS
-- keys directly (Enacted Resolutions / Possible Resolutions / Other Resolutions).
-- Religion Overview. TabbedShell over the engine's BUTTONPOPUP_RELIGION_OVERVIEW:
-- tab 1 Your Religion (status / beliefs / faith / great people / auto-purchase),
-- tab 2 World Religions (one row per founded religion plus OVERALL STATUS footer),
-- tab 3 Beliefs (one Group per religion / pantheon, drilling into beliefs).
-- Screen title and tab names reuse engine TXT_KEY_RELIGION_OVERVIEW and
-- TXT_KEY_RO_TAB_*; only the hotkey-help pair and the world-row composition
-- have no engine equivalent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "Open Religion Overview"
-- World Religions row composition. Distinguishing word (religion name) leads;
-- holy city / founder / city count follow with brief framing words so values
-- that could otherwise read as a list of names stay disambiguated.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] =
    "{1_Religion}, holy city {2_HolyCity}, founded by {3_Founder}, {4_NumCities} cities"

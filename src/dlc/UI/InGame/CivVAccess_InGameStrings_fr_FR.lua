-- Mod-authored strings, fr_FR overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- Spoken once, after the in-game Boot Lua finishes installing handlers, so
-- the user knows the mod attached.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "Accessibilité Civilization V chargée en jeu."
-- Hotseat-mute toggle (Ctrl+Shift+F12). The pause announcement speaks
-- before the flag flips so the screen reader hears it; the resume speaks
-- after the flag clears so SpeechPipeline's gate doesn't swallow it.
-- Mirrored in the FrontEnd strings file because InputRouter routes both
-- front-end and in-game dispatch.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "mod en pause"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "mod repris"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "recommandation : {1_Name}"
-- Settler recs have no per-build name (unlike worker recs, which reuse
-- the build's Description); every settler-rec plot groups under this
-- label as one item with many instances. Used by the scanner category
-- and by the cursor glance section, so it lives in the shared InGame
-- strings file rather than the scanner-only strings file.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "Site de ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "embarqué {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} mouvements"
-- Cargo / stationed aircraft count. Speaks the same X/Y the carrier and
-- city-flag dropdowns show in UnitFlagManager. "Aircraft" matches the
-- game's TXT_KEY_STATIONED_AIRCRAFT noun, which covers fighters, bombers,
-- and missiles (all DOMAIN_AIR). Carrier sites speak the token whenever
-- the unit has cargo capacity (so empty carriers still announce 0/3);
-- city sites suppress when X is 0 to avoid spamming every city.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} aéronefs"
-- Trailing token on the unit info line when the unit has earned enough
-- experience to take a new promotion (CanPromote is true).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "promotion disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    one = "{1_What} {2_Turns} tour",
    other = "{1_What} {2_Turns} tours",
}
-- Spoken when a unit is mid-execution on ACTIVITY_MISSION. For a selectable
-- player-controlled unit the cascade falls through to this rung only for
-- multi-turn movement missions (MISSION_MOVE_TO / MISSION_ROUTE_TO) -- build
-- missions get caught by the build rung above, automated units by the
-- automate rung, and one-shot missions (attack, embark, found, airstrike,
-- etc.) resolve within the turn and never reach selection. The Lua API does
-- not expose mission type or destination plot, so we cannot say where.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "mouvement en file d'attente"
-- Engine-fork form of the queued rung: when WaypointsCore can compute a
-- destination and turn count for the head-selected unit's queued path,
-- the rung becomes "queued move {dir}, N turns" so the user hears where
-- the unit is going and how long it takes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO"] = {
    one = "mouvement en file d'attente {1_Dir}, {2_Turns} tour",
    other = "mouvement en file d'attente {1_Dir}, {2_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} mêlée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} à distance, portée {2_Range}"
-- Enemy form of ranged strength: range distance is hidden to match base
-- EnemyUnitPanel.lua, which shows strength but omits the range tile count.
-- Also reused for friendly aircraft so the range tile count isn't said
-- twice -- aircraft surface range alongside rebase range in their own
-- token, see TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} à distance"
-- Aircraft replacement for the moves fraction. Strike range is GetRange();
-- rebase range is strike range * AIR_UNIT_REBASE_RANGE_MULTIPLIER / 100
-- (engine default 200, so rebase = strike * 2). Mirrors base UnitPanel.lua's
-- DOMAIN_AIR branch which swaps the movement stat for the strike range and
-- surfaces the strike/rebase pair in the tooltip via TXT_KEY_UPANEL_UNIT_MAY_STRIKE_REBASE.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "portée {1_Strike}, portée de transfert {2_Rebase}"
-- Spoken on a friendly combat unit that has used its per-turn attack budget
-- (1 attack, or 2 with Blitz) but still has movement points. The actionable
-- distinction is "you have moves but can't strike with them, only reposition";
-- a 0-moves unit can't attack regardless, so the moves fraction already
-- conveys the answer and this token suppresses to avoid repeating it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "plus d'attaques"
-- Aircraft "done for the turn" signal. Every aircraft action (strike,
-- rebase, sweep) ends in CvUnit::finishMoves so MovesLeft == 0 is the
-- reliable "no active actions left this turn" state -- interception is
-- still possible, but the player can't initiate anything else. Friendly
-- aircraft only; non-aircraft already convey this via the moves fraction
-- and the engine doesn't expose foreign aircraft moves on the unit flag.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "plus de mouvements"
-- Enemy HP speaks as a color band instead of an exact fraction. The band
-- thresholds mirror UnitFlagManager.lua:412 so blind players hear what
-- sighted players see on the unit flag: over 66% green, over 33% yellow,
-- else red. At 100% the game hides the bar; we speak "full" so the HP
-- slot is always present in the info line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "hp {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "vert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "jaune"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "rouge"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "plein"
-- Unit info-line tokens. Spoken in the cursor's tile glance and on the
-- "/" info-dump key. Level / XP and upgrade-cost are surfaced because the
-- sighted UI pairs them with icons that get stripped; promotions list
-- joins all earned promotion names. The MOVED_TO and STOPPED_SHORT pairs
-- are post-move feedback after a single Alt+key step: MOVED_TO speaks the
-- remaining moves left after a successful step, STOPPED_SHORT fires when
-- the path was longer than the budget allowed.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "niveau {1_Lvl}, {2_Cur}/{3_Next} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "amélioration vers {1_Name}, {2_Gold} or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "promotions : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    one = "déplacé, {1_Num} mouvement restant",
    other = "déplacé, {1_Num} mouvements restants",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "déplacement en attente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    one = "déplacement en attente, {1_Num} tour avant l'arrivée",
    other = "déplacement en attente, {1_Num} tours avant l'arrivée",
}
-- Generic "the action you tried did not happen" tail spoken when an Alt+key
-- attempt completes without effect (engine refused but did not fire a
-- specific reason). QUEUED_NEXT_TURN fires when shift+enter on a path
-- successfully appends the leg but the unit is already out of moves so the
-- mission won't actually start until the next turn.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "action échouée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "en file d'attente pour le tour suivant"
-- Alt+QAZEDC prechecks. Spoken before the combat preview / move commit
-- when the engine would refuse the action so the user hears a specific
-- reason instead of waiting for the generic timeout.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "unité à distance, utiliser l'attaque à distance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "unité aérienne, utiliser l'attaque à distance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "ne peut pas attaquer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "à court d'attaques"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "à court de mouvements"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "l'aéronef ne peut pas se déplacer ainsi, utiliser le transfert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "non adjacent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "n'attaque que les villes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "ne peut pas attaquer sur terre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "ne peut pas attaquer cette cible"
-- Empty-state tokens spoken when a unit-related key fires with nothing to
-- act on: NO_UNITS when the active player owns zero selectable units,
-- NO_ACTIONS when the unit-action menu has no entries to show.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "pas d'unités"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "pas d'actions"
-- Suffix appended to action / move announcements when committing the action
-- would trigger a war declaration with the target's owner. Spoken before
-- the final confirm so the user can cancel.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "déclarera la guerre"
-- Display names for the in-place menus pushed by Tab and Enter on the hex
-- cursor. UNIT_MENU_NAME is the unit-action menu pushed by Tab on a
-- selected unit; CURSOR_ACTIVATE_MENU_NAME is the multi-target menu pushed
-- by Enter on a tile holding more than one activatable thing. The two
-- _MENU_PROMOTIONS / _BUILDS labels are sub-menu group names within those
-- menus.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Actions de l'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "Activer la case"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Promotions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Construire des améliorations"
-- Spoken on entering a target-picker mode (ranged attack, paradrop, etc.)
-- as the audible confirmation that the cursor's keys are now picking a
-- target rather than navigating freely.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "mode ciblage"
-- Confirms when shift+enter appends a leg to the unit's mission queue.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "en file d'attente"
-- Spoken when shift+enter is pressed in a non-queueable mode (melee
-- attack). The engine has no queued-attack semantics that resolve into
-- meaningful gameplay -- a queued attack pushes the mission and resolves
-- on the same turn the queue head reaches it, but we have no
-- pre-snapshot for the eventual combat -- so we reject.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "impossible de mettre l'attaque en file d'attente"
-- Generic "the action was abandoned" feedback. Spoken when a target-picker
-- or popup is dismissed with Escape; consumed by code paths that need to
-- speak any single word but for which "canceled" is the audible default.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "annulé"
-- Combat preview vocabulary. Spoken on Space inside a target-picker mode
-- (Alt+QAZEDC for melee, Alt+R for ranged, Alt+air-strike, etc.) before
-- the user commits with a second press / Enter. The PREVIEW_ATTACK and
-- PREVIEW_RANGED templates are the one-line full preview; SUPPORT_FIRE
-- and CAPTURE_CHANCE are appended clauses; MODS_MY / MODS_THEIR are
-- pre-amble lists composed from MOD_POS / MOD_NEG entries that name each
-- combat modifier as "plus N percent <reason>" or "minus N percent <reason>".
-- {4_Result} in the preview templates is the engine's verdict word
-- ("decisive victory", "stalemate", etc.) computed from CombatPrediction.
-- OUT_OF_RANGE fires when the cursor sits on a plot the active mode
-- cannot strike; preview is suppressed.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "hors de portée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} contre {3_TheirStr}, {4_Result}, {5_DmgToMe} dégâts pour moi, {6_DmgToThem} pour eux"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "tir de soutien {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "chance de capture {1_Pct} pour cent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "mes bonus {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "leurs bonus {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "plus {1_N} pour cent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "moins {1_N} pour cent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} contre {3_TheirStr}, {4_Result}, {5_DmgToThem} dégâts pour eux"
-- City-defender preview variants. Cities don't surface a combat
-- prediction (the engine's CombatPrediction is unit-vs-unit only) and
-- the modifier breakdowns are different enough that we drop them rather
-- than mislead. Damage numbers are still computed via the engine's own
-- GetCombatDamage with the city flags set, so they match what the
-- sighted EnemyUnitPanel reports.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "ville {1_Name}, {2_MyStr} contre {3_TheirStr}, {4_DmgToMe} dégâts pour moi, {5_DmgToThem} pour eux"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "ville {1_Name}, {2_MyStr} contre {3_TheirStr}, {4_DmgToThem} dégâts pour eux"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} pour moi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    one = "{1_N} intercepteur",
    other = "{1_N} intercepteurs",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "se déplacer vers {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} PM, {2_Left} non dépensés"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    one = "{1_MP} PM, {2_Turns} tour, {3_Left} non dépensés",
    other = "{1_MP} PM, {2_Turns} tours, {3_Left} non dépensés",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "ce tour, zone inexplorée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    one = "{1_Turns} tour, zone inexplorée",
    other = "{1_Turns} tours, zone inexplorée",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "ce tour, {1_Steps} puis inexploré"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    one = "{1_Turns} tour, {2_Steps} puis inexploré",
    other = "{1_Turns} tours, {2_Steps} puis inexploré",
}
-- Combat-with-pathfinding suffix appended to the combat preview when an
-- attack target is reachable but not adjacent. The truncated step list
-- (start through the attack-from tile) names the route; "then attack"
-- marks the terminal step. Mirrors the FOG_PREFIX shape so localizers
-- already have the pattern. MP cost is omitted: the engine consumes all
-- remaining MP on attack and promotion bonuses can grant extra attacks,
-- so any predicted MP-after-attack number would be wrong.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] = "ce tour, {1_Steps} puis attaque"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    one = "{1_Turns} tour, {2_Steps} puis attaque",
    other = "{1_Turns} tours, {2_Steps} puis attaque",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "aucun chemin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "trop loin pour calculer"
-- Discriminative path-failure diagnostics. PathDiagnostic.discriminativePath
-- runs the strict pathfinder, then re-runs with progressively relaxed flag
-- combos; whichever relaxation recovers the path names the cause. Closest-
-- reachable is rendered as the cursor-relative direction string used by the
-- scanner / bookmarks / surveyor, so the spatial vocabulary stays uniform
-- across the mod. _NO_DIR variants fire when the closest-reachable tile is
-- the cursor itself (unit can't get any closer than where you're pointing,
-- e.g. unit already at start with no exit).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "bloqué par frontières {1_Civ}, plus proche atteignable {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "bloqué par frontières {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] =
    "bloqué par frontières fermées, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "bloqué par frontières fermées"
-- Stacking / enemy collapse to one shape: "blocked by [civ-adjective]
-- [unit name]" -- the adjective distinguishes your-own ("Roman Warrior")
-- from foreign ("Mongol Warrior") naturally. UNIT_DESCRIPTOR is the
-- adj+name combiner so the locale can reorder ({2_Name} {1_Adj}) without
-- touching the parent strings.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{2_Name} {1_Adj}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] = "bloqué par {1_Unit}, plus proche atteignable {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "bloqué par {1_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] =
    "bloqué par une unité, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "bloqué par une unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] = "aucun chemin, plus proche atteignable {1_Dir}"
-- Unreachable-branch sub-causes. PathDiagnostic identifies these by
-- inspecting the unit's tech state (no embark / no astronomy), the
-- closest-reachable's neighbors toward target (mountain / natural
-- wonder), the destination's units (foreign-unit blocker for non-combat
-- units, sharing the existing BLOCKED_UNIT format), and the unit's
-- domain + target's water-area mismatch (naval no water connection).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] =
    "technologie d'embarquement manquante, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "technologie d'embarquement manquante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] = "astronomie requise, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "astronomie requise"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] =
    "bloqué par montagnes, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "bloqué par montagnes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] = "bloqué par {1_Wonder}, plus proche atteignable {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "bloqué par {1_Wonder}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] =
    "aucune connexion maritime, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "aucune connexion maritime"
-- Domain-incompatible combat. Land warrior can't melee a trireme on
-- water (engine's ATTACK gate at CvUnit.cpp:2583 hard-rejects
-- domain==LAND + water plot regardless of embark state). Naval unit
-- can't enter non-city land tiles to attack land units. Surfacing
-- these as "cannot attack from [unit's domain]" tells the user the
-- block is fundamental, not a tech gap.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "impossible d'attaquer depuis la terre, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "impossible d'attaquer depuis la terre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "impossible d'attaquer depuis l'eau, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] = "impossible d'attaquer depuis l'eau"
-- Naval unit targeting empty / peaceful-occupied non-city land. Same
-- engine block as cantAttackFromWater but no combat intent on the user
-- side, so the framing is "travel" not "attack".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] =
    "impossible d'aller à terre, plus proche atteignable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "impossible d'aller à terre"
-- Embark / disembark hint appended to a successful move-path preview
-- when the start and destination share a domain but the route crosses
-- the opposite one (land -> water -> land, or water -> land -> water).
-- Cross-domain endpoints (land -> water, water -> land) need no hint
-- because the destination's domain already implies the transition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "embarquement requis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "débarquement requis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "pas de cible ici"
-- Route-to (auto-route) preview. Tile count is the path length excluding
-- the worker's start tile -- "the road will reach N tiles further from
-- where you are now." Build turns is the sum of GetBuildTurnsLeft over
-- plots that need a route built; tiles already routed at the target tier
-- (and city tiles) contribute zero. ALREADY_DONE fires when the path
-- exists but every tile already has the target route, so the mission
-- completes the moment the worker walks the chain.
-- Route preview is two independently-pluralized counts (tiles + turns).
-- A single bundle can't carry combinations like "1 tile, 5 turns" vs
-- "5 tiles, 1 turn", so each clause has its own bundle and the parent
-- key is a scalar combiner with positional placeholders. Translators
-- can reorder ({2_TurnsClause}, {1_TilesClause}) or change punctuation
-- in the combiner without touching plural rules.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TILES_CLAUSE"] = {
    one = "{1_N} case",
    other = "{1_N} cases",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    one = "{1_N} tour",
    other = "{1_N} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    one = "{1_Tiles} case, aucun travail nécessaire",
    other = "{1_Tiles} cases, aucun travail nécessaire",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD"] = "aucune route disponible"
-- Per-mode "cannot X here" strings for the special interface modes whose
-- legality is the only sighted feedback (highlight tint). Spoken when the
-- engine's per-target Can*At check returns false; legal targets fall
-- through to the destination plot's glance summary instead.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "parachutage impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "pont aérien impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "transfert impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "embarquement impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "débarquement impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "frappe nucléaire impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "don d'unité impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "amélioration impossible ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "aucun intercepteur visible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "aérotransporter ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "parachuter ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] = "frappe nucléaire ici, rayon d'explosion {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "offrir {1_Unit} à {2_Recipient}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] =
    "améliorer {1_Resource} pour {2_Recipient}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    one = "{1_Name}, {2_N} case",
    other = "{1_Name}, {2_N} cases",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] = "aucune destination de transfert à portée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "transfert vers {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "Choisissez une ville où aérotransporter cette unité. Une fois sélectionnée, choisissez la case exacte où l'unité atterrira, qui ne peut pas être à plus d'une case de la ville."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    one = "{1_Name}, {2_N} case",
    other = "{1_Name}, {2_N} cases",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] = "aucune destination de pont aérien disponible"
-- Unit control help overlay entries. Chord labels merge each binding
-- cluster into one line so the ? screen doesn't list six Alt+letter rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Point, virgule"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "Passer à l'unité suivante ou précédente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Contrôle plus point ou virgule"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "Passer à l'unité suivante ou précédente, y compris celles qui ont déjà agi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Barre oblique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] =
    "Lire les informations de combat et de promotion de l'unité sélectionnée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Contrôle plus barre oblique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] =
    "Recentrer le curseur hexagonal sur l'unité sélectionnée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tabulation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Ouvrir le menu d'actions de l'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt plus Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Déplacer l'unité sélectionnée d'une case (appuyer deux fois pour confirmer une attaque)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt plus M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "Ouvrir le sélecteur de destination ; viser avec les touches directionnelles, espace pour prévisualiser, Entrée pour confirmer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] =
    "Fortifier une unité militaire, ou mettre en veille un civil"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] =
    "Sentinelle, en veille jusqu'à ce qu'un ennemi soit en vue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt plus W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "Réveiller une unité endormie ou fortifiée, ou annuler un déplacement en file d'attente ou une automatisation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt plus X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "Passer le tour de l'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "Soigner jusqu'à être plein"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "Ouvrir le sélecteur de cible d'attaque à distance; viser avec les touches directionnelles, espace pour prévisualiser, Entrée pour confirmer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "Piller la case de l'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt plus U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "Améliorer l'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt plus N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "Renommer l'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} non disponible"
-- Combat-result payload from the engine fork's CombatResolved hook.
-- Damage values speak absolute-delta ("attacker -8 hp") rather than
-- before/after because the before is already known from the last
-- selection announce.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "attaquant {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "défenseur {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "attaquant {1_Name} indemne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "défenseur {1_Name} indemne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} tué"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} capturé"
-- Substituted for the attacker / defender name in AI-vs-AI combat on a
-- visible plot when one side is invisible to the active team (e.g., AI
-- submarine ambushing AI ship). Matches what sighted players perceive:
-- an unseen hit on a visible target. Active-player-involved combats
-- always use full names regardless of invisibility because attacks
-- reveal identity in base game's defender-side messages.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "inconnu"
-- Air-strike intercept clause. Omitted unless the engine fork's hook
-- reports a landed intercept (interceptorDamage > 0); failed / evaded
-- intercepts surface no clause to match base game's UI.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "intercepté par {1_Name}"
-- Air-sweep prefix. The engine reports combatKind = 1 for sweep into
-- ground AA (one-sided), combatKind = 2 for sweep into another fighter
-- (two-sided dogfight). The prefix lets the user know the combat result
-- they're about to hear came from a sweep they triggered.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "interception"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "combat aérien"
-- Air-sweep no-target. Engine fork's CivVAccessAirSweepNoTarget hook
-- fires when the user issues a sweep but no interceptor is in range to
-- engage. Mirrors base game's TXT_KEY_AIR_PATROL_FOUND_NOTHING which
-- lands in the sighted notification log we don't subscribe to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "aucun intercepteur"
-- Nuclear strike speech. Composed from the engine fork's NukeStart /
-- NukeUnitAffected / NukeCityAffected / NukeEnd hook stream. Sections
-- are elided when empty -- a nuke that finds nothing emits the header
-- + NO_TARGETS line; one with city damage but no unit damage drops
-- the units clause. Each entity entry is built from CIV_NAME +
-- HP_DELTA + optional pop / kill / destroy suffixes joined Lua-side.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "frappe nucléaire de {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "cible {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "victimes {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "unités {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "aucune cible touchée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} pop"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "tué"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "détruit"
-- City-capture announcements. SerialEventCityCaptured fires for empty
-- city captures (no combat resolution) and for capture-after-defender-
-- killed transitions; the active player's perspective decides which line
-- wins.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "capturé {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "perdu {1_Name}"
-- Self-plot action confirms. Keyed by action hash token so the menu can
-- dispatch without a per-action if-ladder. FORTIFY / SLEEP / ALERT / WAKE /
-- AUTOMATE / DISBAND / BUILD / PROMOTION map 1:1 to the commit path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "fortifié"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "endormi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "en alerte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "réveillé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "automatisé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "dissous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "en cours de soin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "pillé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "passé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "amélioré"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "annulé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "démarré {1_Build}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "promu à {1_Name}"
-- Generic "this control is currently un-clickable" suffix appended to
-- button labels whose engine control reports IsDisabled. Mirrored from
-- the FrontEnd copy (the front-end Context has its own sandboxed table).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "désactivé"
-- Compositional form: "<label>, disabled" for buttons that surface a
-- pre-composed label (an engine control's GetText / a built-up offer
-- string) plus the disabled marker. Positional template lets locales
-- swap the marker to lead the phrase or change the separator.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, désactivé"
-- Cursor / hex-grid handler. Direction tokens are short forms (e, ne, ...)
-- because experienced screen-reader users prefer shorter speech and these
-- appear in tight contexts (per-move river edges, capital orientation).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "e"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "ne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "se"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "sw"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "w"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "nw"
-- Compact "<count><dir>" glue used by HexGeom.directionString /
-- stepListString to assemble run-length step lists ("2e, 1se, 3nw").
-- Tight glue (no separator) is the EN form; positional template lets
-- locales insert a space or reorder count and direction.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "bord de la carte"
-- Spoken by Cursor.move when civvaccess_shared.mapScope rejects the target.
-- Generic wording rather than CityView-specific so Phase 8's ranged-strike
-- target picker (scope = valid strike targets) reuses it verbatim.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "bord de la portée"
-- Tile-state words appended to the cursor glance when the plot is unowned
-- (UNCLAIMED), never seen by the active player (UNEXPLORED), or seen once
-- but currently outside view (FOG). UNEXPLORED hides every other plot detail
-- because the user does not yet have rights to know what is there.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "non revendiqué"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "inexploré"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "brouillard"
-- Cursor prefix that fires while the engine is in a ranged-attack interface
-- mode (unit ranged, airstrike, city ranged) when the attacker has no
-- geometric line of sight to the target plot (mountain, hill chain, or
-- forest in the way). The companion "out of range" prefix reuses
-- TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE so target-mode preview text
-- and cursor-prefix text stay in sync across locales.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "non vu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "capitale"
-- Spoken when the user presses Ctrl+S to jump to their capital before
-- founding a city. Mirrors the bookmark "no bookmark" pattern -- silence
-- is indistinguishable from a broken keystroke for a blind player, so we
-- close the loop with a short status word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "pas de capitale"
-- Modified-offset coordinate, capital-relative. {1_X} can be a half-integer
-- (NE / NW / SE / SW steps land on .5); {2_Y} is always an integer.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    one = "{1_Moves} mouvement",
    other = "{1_Moves} mouvements",
}
-- River and fresh-water tokens spoken in the cursor's tile glance.
-- {1_Directions} is a comma-joined run of short edge tokens (e.g. "ne, se, s")
-- naming the hex sides the river touches; ALL_SIDES is the degenerate
-- six-edge case. FRESH_WATER fires for tiles adjacent to a river or lake.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "fleuve {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "fleuve tous côtés"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "eau douce"
-- Numbered step on the head-selected unit's queued path. Speaks on cursor
-- glance and as the scanner item name for the "waypoints" category.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "point de passage {1_Index} sur {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} pillé"
-- Macro-terrain tokens. Spoken inside the cursor glance for plots the engine
-- does not give a per-terrain TXT key for (hills are a flag on top of base
-- terrain, lakes are technically a feature, mountains are a base-terrain
-- type but the engine's TXT key includes punctuation we strip).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "collines"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "montagne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "lac"
-- Generic HP format used wherever a single HP number is spoken without a
-- max (cursor glance for friendly units below full HP, etc.). The
-- max-bearing form is UNIT_HP_FRACTION above.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    one = "{1_Build} {2_Turns} tour",
    other = "{1_Build} {2_Turns} tours",
}
-- Yield + count glue used by per-plot yields and the surveyor radius
-- sum. {2_Yield} is a pre-resolved noun ("food", "production"...);
-- positional template lets number-after-noun locales reorder.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"
-- "Controlled" = plot:GetWorkingCity(): the tile is part of this city's
-- workable area (the engine's term is "working city," but no citizen need
-- be assigned). "Worked" elsewhere means IsWorkingPlot = a citizen is
-- actually there. Kept the wording distinct so the two never collide.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "contrôlé par {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "contrôlé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} pour cent de défense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "en zone de contrôle ennemie"
-- Cursor help-overlay key labels: chord forms shared with the main letter
-- cluster. One TXT_KEY per chord because Help dedupes by keyLabel string and
-- the chords don't merge cleanly into a single label (Q is its own meaning).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Cluster Q, W, E, A, S, D, Z, X, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] =
    "Déplacer le curseur par case (Q no, E ne, A o, D e, Z so, C se)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "Lire l'unité sur la case actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Maj plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "Coordonnées du curseur par rapport à la capitale d'origine, en notation décalée modifiée (chaque pas vers l'est ajoute un en x, chaque pas nord-est ajoute 0.5 en x et un en y, chaque pas sud-est ajoute 0.5 en x et enlève un en y)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Contrôle plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "Déplacer le curseur vers votre capitale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "Détails économiques de la case actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "Détails de combat de la case actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "Identité et combat de la ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "Production et croissance de la ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_POL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_POL"] = "Diplomatie de la ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "Sélectionner une unité, ou ouvrir l'écran de ville (annexion pour les vassales, diplomatie avec une civilisation majeure rencontrée), sur la case"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Contrôle plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "Ouvrir la Civilopédia pour tout ce qui se trouve sur la case du curseur (unités, merveilles du monde, amélioration, ressource, caractéristique, fleuve, lac, terrain, collines, montagne, route)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "Articles sur la case"
-- City-info speech tokens. Three keys (1 identity + combat, 2 development,
-- 3 politics); shape mirrors the BNW CityBannerManager per-ownership tier.
-- Unmet cities stop at one word. Identity leads with actionable signals
-- (can-attack, capital or city-state trait+friendship), then status flags,
-- then pop/defense/HP, then garrison on team banners. Enemy HP reuses the
-- unit color-band keys so "hp full / green / yellow / red" stays one
-- vocabulary across unit and city queries.
-- Spoken alone (no further fields) for cities whose owner the active
-- player has not yet met; everything else in the city info line is
-- suppressed because the engine does not reveal those fields.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "non rencontré"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "peut attaquer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "aucune ville ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "culturelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "militariste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "maritime"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "marchande"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "religieuse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "neutre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "ami"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "allié"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "guerre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "guerre permanente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    one = "incendiée {1_Turns} tour",
    other = "incendiée {1_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    one = "résistance {1_Turns} tour",
    other = "résistance {1_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "occupée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "vassale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "sous blocus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} habitants"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} défense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} sur {2_Max} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "en garnison {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    one = "production de {1_Name} {2_Turns} tour",
    other = "production de {1_Name} {2_Turns} tours",
}
-- Process production (Wealth / Research / etc.) has no completion turn or
-- progress fraction -- absence of the turn count is the audible signal that
-- this is a perpetual process rather than a buildable item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "production de {1_Name}"
-- City development tokens (the "2" key, second tier of the city-info
-- triplet). Production block: NOT_PRODUCING when the queue is empty,
-- PRODUCTION_PROGRESS / PRODUCTION_PER_TURN to read the current item's
-- meter and rate. Growth block: GROWS_IN for next-pop ETA, STARVING when
-- food is negative and population will shrink, STOPPED_GROWING when food
-- is exactly zero and population holds, plus the FOOD_PROGRESS /
-- FOOD_PER_TURN / FOOD_LOSING readouts.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "aucune production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} sur {2_Needed} production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    one = "croissance dans {1_Turns} tour",
    other = "croissance dans {1_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "en famine"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "croissance arrêtée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} sur {2_Threshold} nourriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "perte de {1_Num} par tour"
-- Spoken when development info is being read on a foreign city the active
-- player has not met or cannot see; the engine hides production / growth
-- numbers in this state and we mirror that.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_NOT_VISIBLE"] = "non visible"
-- City politics tokens (the "3" key, third tier). Warmonger / liberation
-- previews are spoken when hovering a city you could capture: the engine
-- computes the diplomatic consequence and we read it as a sentence rather
-- than the colored numeric badge sighted players see. SPY / DIPLOMAT
-- announce the active foreign agent in the city; rank is the engine's tier
-- name (Recruit, Agent, Special Agent, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "prévisualisation belliciste : {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "prévisualisation de libération : {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "espion {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "diplomate {1_Name}, {2_Rank}"
-- Spoken when the politics readout has nothing to surface (no agents, no
-- preview applicable) so the user knows the key fired but had no payload.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_POLITICS"] = "aucune information politique"
-- Spoken when Scanner becomes the top handler: on boot, after a popup
-- closes, after a sub-handler (ScannerInput, UnitActionMenu) pops. Gives
-- the user a consistent audible landmark that the hex-viewer cursor is
-- live again -- functioning as the "closed" confirmation that popup
-- dismissal would otherwise need case-by-case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "mode carte"
-- Type-ahead search feedback (see FrontEnd strings for the authoring
-- rationale). Mirrored here because TypeAheadSearch runs from in-game
-- BaseMenu contexts whose string table is sandboxed from the FrontEnd copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "aucune correspondance pour {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "recherche effacée"
-- Help overlay strings (see FrontEnd strings for the authoring rationale).
-- Duplicated here because Contexts are sandboxed: in-game Contexts that
-- eventually wire SetInputHandler through InputRouter need their own copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Aide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Lettres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Haut ou bas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Début ou fin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Entrée ou espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Gauche ou droite"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Maj plus gauche ou droite"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Contrôle plus haut ou bas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt plus gauche ou droite"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Maj plus tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Contrôle plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Échap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Point d'interrogation"
-- Description tokens of the help overlay (paired with the KEY_* labels
-- above; the two halves combine via HELP_ENTRY = "{1_Key}, {2_Description}").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Saisir pour rechercher"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Naviguer entre les éléments"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "Aller au premier ou au dernier"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Activer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "Ajuster la valeur ou entrer dans une sous-section"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "Ajuster la valeur par grands pas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "Aller au groupe précédent ou suivant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Onglet suivant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Onglet précédent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Lire l'en-tête de l'écran"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "Ouvrir l'entrée Civilopédia pour l'élément actuel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Annuler"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Fermer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Annuler la modification"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Valider la modification"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Contrôle plus Maj plus F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Ouvrir les paramètres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Fermer les paramètres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "Mettre le mod en pause ou le reprendre"
-- BaseTable: 2D table viewer (used by F2 cities, future demographics, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, décroissant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, croissant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, tri effacé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "Se déplacer entre les lignes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "Se déplacer entre les colonnes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "Première ou dernière ligne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "Activer la cellule ou trier par colonne"
-- Settings overlay strings. Reachable from every Context that routes
-- through InputRouter, so duplicated in the FrontEnd copy as well.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Paramètres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Mode des indices sonores"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Voix uniquement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Voix et indices sonores"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Indices sonores uniquement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "Volume principal"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "Volume principal, {1_Num} pourcent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "Déplacement automatique du curseur du scanner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "Curseur suit l'unité sélectionnée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "Coordonnées du curseur pendant le déplacement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Désactivé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "Annoncer avant le déplacement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "Annoncer après le déplacement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] = "Toujours annoncer le territoire de la case"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "Le scanner affiche les coordonnées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Lire les sous-titres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] =
    "Annoncer les changements de visibilité pendant le déplacement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "Annoncer la résolution des combats de l'IA"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] =
    "Annoncer les changements de visibilité en début de tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "Annoncer les campements et ruines réclamés par d'autres en vue"
-- Widget-generic strings spoken by BaseMenuItems Choice / Checkbox /
-- Textfield and BaseMenuEditMode. Mirrored from the FrontEnd copy because
-- Contexts are sandboxed: an in-game screen that uses these item kinds
-- needs them present in the InGame Context's string table.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "sélectionné"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "sélectionné, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "activé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "désactivé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_STATE"] = "{1_Label}, {2_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_VALUE"] = "{1_Label} {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABELED_LIST"] = "{1_Label} {2_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT"] = "{1_Label}, {2_Amount}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE"] = "{1_Label}, {2_Amount}, {3_TurnsLine}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_VALUE_UNIT"] = "{1_Value} {2_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "modifier"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "vide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "modification de {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restauré"
-- GameMenu (Esc pause menu) strings. Details tab reuses the base game's
-- TXT_KEY_POPUP_GAME_DETAILS, so no mod-authored tab label here.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "Menu pause"
-- GenericPopup (the shared Context behind AnnexCity / PuppetCity /
-- ConfirmCommand / DeclareWar / BarbarianRansom / etc.). One display name
-- for all of them; the per-popup text comes from the base via preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "Fenêtre contextuelle"
-- Informational popups that have no engine-side title to reuse: TextPopup
-- is a generic notification, WonderPopup only carries the wonder name
-- (dynamic), LeagueSplash's title is dynamic per-session.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "Notification"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "Merveille achevée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "Congrès mondial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "Fin de partie"
-- Ranking tab row labels. The HistoricRankings table is fixed leader tiers
-- with thresholds; the matched row replaces "score <threshold>" with the
-- player's actual score and tacks on the leader's quote.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, score {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] = "{1_Rank} {2_Leader}, votre score {3_Score}, {4_Quote}"
-- Replay Messages-panel row format. Source is Game.GetReplayMessages() at
-- end-game and g_ReplayInfo.Messages at front-end; same {Turn, Text} shape.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_MESSAGE_ROW"] = "Tour {1_Turn}, {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "Déclarer la guerre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "Accueil de la cité-État"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "Cité-État"
-- Fallback for LeaderHeadRoot / DiscussionDialog before TitleText is
-- populated. In practice the onShow hook overwrites handler.displayName
-- with the live leader title (e.g. "Suleiman the Magnificent") that
-- LeaderMessageHandler just set.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "Diplomatie"
-- DiscussionDialog sub-menu display names. Denounce confirm is a yes/no
-- overlay; coop-war leader picker is a scroll list of civs the AI could
-- ally with against us.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "Dénonciation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "Cible de guerre commune"
-- Great-work splash (archaeology / wonder / cultural-victory completion).
-- Title is either the great work's artist or the "written artifact" label;
-- description and quote come from GameInfo.GreatWorks.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "Chef-d'oeuvre"
-- Choose-family popup screen names. Each popup's body text (what you're
-- picking among) is spoken as preamble from live engine controls; the
-- display name here is just the screen header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "Choisir une récompense de campement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "Choisir un grand personnage gratuit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "Choisir un grand personnage de foi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "Choisir un bonus maya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "Choisir un panthéon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "Choisir une idéologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "Choisir un résultat archéologique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "Choisir un nouveau port pour l'amiral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] =
    "Choisir une nouvelle base pour l'unité commerciale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "Établir une route commerciale"
-- Confirm-overlay sub-handler pushed on top of a Choose* picker when the
-- player activates an item. Display name only; the actual prompt text
-- (e.g. "Are you sure you wish to found X?") comes from Controls.ConfirmText
-- as a function preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Confirmer"
-- ChooseReligionPopup (BUTTONPOPUP_FOUND_RELIGION). Same Context wraps both
-- founding (Option1=true) and enhancing (Option1=false); the display name
-- resolves per phase. Change Religion Name is a sub-handler covering the
-- engine's ChangeNamePopup overlay (Textfield + OK / Default / Cancel).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "Choisir une religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "Améliorer une religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "Changer le nom de la religion"
-- Belief-slot label formats. {1_Slot} is the slot's short name (Pantheon
-- belief, Founder belief, Follower belief, Follower belief 2, Enhancer
-- belief, Bonus belief); {2_Belief} is the short description of whichever
-- belief currently fills the slot. States: UNCHOSEN (editable with nothing
-- picked), CHOSEN (either editable with a selection or already committed;
-- both spoken identically - commit state is reflected by whether drill-in
-- opens a belief list), LATER (locked; slot unlocks next phase), and
-- BYZANTINES_ONLY (locked; only reachable with the Byzantine civ trait).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, non choisi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, disponible plus tard"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, Byzantins uniquement"
-- Religion-picker row. Unselected in founding mode before the user picks
-- from the religion list; selected after SelectReligion fires. Enhance mode
-- replaces the row with a read-only Text showing the player's own religion.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "religion, non choisie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "religion, {1_Name}"
-- Name row. Founding lets the user open ChangeNamePopup to rename; enhance
-- shows read-only. The row is gated on ReligionPanel visibility so only
-- runs once a religion is selected.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "nom, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "nom de la religion"
-- NotificationLogPopup (BUTTONPOPUP_NOTIFICATION_LOG). Split into Active /
-- Dismissed tabs by the engine's per-notification dismissed flag. Item
-- label inlines the turn so the user can place each entry in history
-- without a separate key.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Journal des notifications"
-- LeagueProjectPopup (BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED). Each contributor
-- entry is one navigable Text item: rank, civ name, contribution score, tier
-- earned. Tier maps from base's iTier int (0..3) to the bronze/silver/gold
-- vocabulary the project rewards-table uses; "no reward" covers iTier == 0
-- (contributed too little to qualify for any tier).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "Projet de la ligue achevé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} de production, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "récompense niveau or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "récompense niveau argent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "récompense niveau bronze"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "aucune récompense"
-- VoteResultsPopup (BUTTONPOPUP_VOTE_RESULTS). Each entry is rank, voter,
-- who they voted for, and the votes they themselves received.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "Résultats du vote"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    one = "{1_Rank}, {2_Name} a voté pour {3_Cast}, a reçu {4_Votes} vote",
    other = "{1_Rank}, {2_Name} a voté pour {3_Cast}, a reçu {4_Votes} votes",
}
-- WhosWinningPopup (BUTTONPOPUP_WHOS_WINNING). Engine-fired ranking pop with
-- a randomly-chosen metric. Player rows mirror the engine's "rank, name,
-- score" order so the user hears the rank first; the active player's tag
-- and the unmet placeholder come from the engine's own keys. Tourism-mode
-- rows include the owner because the sighted column shows the leader
-- portrait + civ icon next to the city name (info absent from the city's
-- own label). Unmet city rows degrade to "Unmet Player" with no city or
-- owner, matching what base displays.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "Qui est en tête"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"
-- Advisors tutorial banner (Events.AdvisorDisplayShow). Static screen
-- name; the per-tutorial title, body, and advisor type are spoken through
-- the preamble from live Controls. "Tutorial Advisor" distinguishes this
-- surface from the combat-interrupt AdvisorModal and the concept-browser
-- AdvisorInfoPopup that question buttons drill into.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "Conseiller tutoriel"
-- NotificationLogPopup tab labels and item format. The popup itself has
-- its title at SCREEN_NOTIFICATION_LOG; these are its three tabs (Active
-- holds undismissed alerts the user can act on, Turn Log is the read-only
-- per-turn event stream, Dismissed is the archive), the placeholder
-- spoken when a tab has no rows, and the item-row format combining the
-- engine-supplied notification text with the turn it fired on.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "Actives"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "Journal du tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "Ignorées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "Aucune notification."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, tour {2_Turn}"
-- Combat Log group inside the Turn Log tab. Contains one entry per combat
-- announced to the player while the AI was taking its turn (between End
-- Turn and the next turn start). Drilled into from the level-0 group label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "Journal de combat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "Aucun combat ce tour."
-- MilitaryOverview (BUTTONPOPUP_MILITARY_OVERVIEW, F3). Key prefix MO_*
-- throughout. Glossary for the abbreviations used here and below: GP =
-- Great People (the umbrella term), GG = Great General (military land
-- specialist), GA = Great Admiral (military naval specialist).
--
-- Two-tab TabbedShell. The supply line lives on the shell preamble so
-- it's spoken between the screen title and the active tab name on every
-- open and on F1; values track per-turn state via a function preamble.
-- Tab 1 (Units) is a BaseTable; the column-header strings are the
-- SORT_MODE_* values plus a mod-authored DISTANCE column. Tab 2 (Great
-- People) is a BaseMenu mirroring GPList's per-city / per-specialist
-- breakdown, with flat GG and GA rows underneath. Supply is a bare
-- use/cap fraction: the same fraction conveys both healthy and over-cap
-- states (25/20 reads as obviously over). The sighted screen's
-- production-penalty percent and per-source breakdown (base / cities /
-- population) are dropped here in favour of brevity.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label} : {2_Cur} sur {3_Max} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "Approvisionnement : {1_Use} sur {2_Cap}"
-- Idle status fallback. The engine hides the status column when a unit
-- has no fortify / sleep / sentry / heal / build / automation state.
-- In speech an empty cell would leave the user wondering whether the
-- screen reader cut off, so we name the idle case explicitly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "inactive"
-- Tab labels. Two tabs: Units (BaseTable) and Great People (BaseMenu).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "Unités"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "Grands personnages"
-- Units tab column headers. Name / Status reuse engine plain-noun keys.
-- Movement / Max moves / Strength / Ranged are mod-authored because the
-- engine's TXT_KEY_MO_SORT_* strings ("Sort By Strength") read awkwardly
-- as a column name and the engine's visible columns are icon-only.
-- Distance is mod-authored: leftmost column, sortKey is cube-distance
-- (nearest first on ascending), cell uses HexGeom.directionString --
-- the same compact "<count><dir>" format the scanner speaks ("3e",
-- "2nw, 1ne"). On the cursor's own hex the cell speaks SCANNER_HERE.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "Distance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "Déplacements restants"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "Déplacements maximum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "Force"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "À distance"
-- Great People tab. Mirrors GPList: one subgroup per specialist type
-- populated with per-city progress rows sorted by turns ascending, plus
-- flat GG / GA rows reusing TXT_KEY_CIVVACCESS_MO_GP_PROGRESS. City row
-- leads with the city name (the distinguishing word as the user
-- navigates a turns-sorted list), then turns, then progress / threshold,
-- then the per-turn rate. NO_PROGRESS variant handles the rate-zero
-- case (city has stranded GPP but no specialists or buildings producing
-- more); skip the turns and rate fields since both are zero. TURNS_NEXT
-- covers the imminent case where threshold-progress <= rate.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City} : {2_Turns}, {3_Progress} sur {4_Threshold}, plus {5_Rate} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] =
    "{1_City} : {2_Progress} sur {3_Threshold}, aucune progression"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "tour suivant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    one = "{1_N} tour",
    other = "{1_N} tours",
}
-- AdvisorCounselPopup (BUTTONPOPUP_ADVISOR_COUNSEL). Four tabs, one per
-- advisor. Page item label is composed at Lua level from the engine's
-- TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY fraction + the counsel body so the
-- user hears "i/N, <paragraph>" only when the advisor has more than one
-- page. Empty-advisor fallback when Game.GetAdvisorCounsel() returns
-- nothing for that slot (early-game Science is the usual case). F10 help
-- entry covers the BaselineHandler binding that opens the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "Aucun conseil."
-- Function-row help entries. F1-F9 describe engine passthroughs (no mod
-- binding; BaselineHandler's passthroughKeys lets the keycode reach the
-- engine's own action). F10 is our advisor-counsel rebind; the strategic
-- view toggle the engine binds here is suppressed. Authored as help text
-- only so the map-mode help list documents the full function-row vocab
-- the user can reach from the map.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "Ouvrir la Civilopedia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "Ouvrir le Conseiller économique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "Ouvrir le Conseiller militaire"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "Ouvrir le Conseiller diplomatique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "Ouvrir l'écran des politiques sociales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "Ouvrir l'arbre technologique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "Ouvrir le journal des tours et événements"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "Ouvrir l'écran de progression vers la victoire"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "Ouvrir l'écran démographique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "Ouvrir les conseils des conseillers"
-- CityView hub. Preamble is spoken on open (and via F1). Yield names lead
-- each token so distinguishing information is at the front -- "food 3"
-- not "3 food" -- per the concise-announcement rule.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "Ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "connectée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} sans emploi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "nourriture {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "production {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "or {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "science {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "foi {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "tourisme {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "culture {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Point"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "Ville suivante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Virgule"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "Ville précédente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "pas de ville suivante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "pas de ville précédente"
-- Hub items that push a sub-handler on Enter. The unemployed action is
-- an item on the hub itself, not a sub; its label carries the live count
-- so the user hears it when arrowing past and doesn't have to drill in
-- just to check.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "Statistiques"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "Merveilles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "Progression des grands personnages"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "Priorité d'exploitation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "Sans emploi : {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "Aucune merveille construite."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "Aucune génération de grand personnage."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} sur {3_Max}"
-- Focus item label when the current focus matches. Read by labelFn on
-- every navigate so flipping focus is reflected immediately.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, sélectionné"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "Éviter la croissance, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "Réinitialiser les affectations de cases"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} sélectionné"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "affectations de cases réinitialisées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "aucun sans emploi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "affecté"
-- Buildings sub-handler (§3.7). Drill-in opens on Enter over any building
-- entry; Sell is conditional on pCity:IsBuildingSellable and not-puppet, so
-- a non-sellable entry lands the user on a drill-in with just Back. The
-- sell-confirm modal speaks the engine's own TXT_KEY_SELL_BUILDING_INFO
-- so blind and sighted players see / hear the same confirmation text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "Bâtiments"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "Aucun bâtiment."
-- Specialists sub-handler (§3.6). One item per slot across specialist-
-- capable buildings. Labels use labelFn so Enter-driven add/remove flips
-- the "empty" / "filled" suffix on the next navigate without rebuilding.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "Spécialistes"
-- Specialist slot's per-yield breakdown shows the GP-rate as standalone
-- "+N[ICON_GREAT_PEOPLE]". The icon's spoken form is "great people" for
-- paired-text contexts (where it dedups against the adjacent label), but
-- here the number is a per-turn point count and "great people" alone reads
-- as a count of GP units, not a rate. Render this line as literal text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_GP_POINTS"] = {
    one = "+{1_N} point de grand personnage",
    other = "+{1_N} points de grand personnage",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "Aucun emplacement de spécialiste."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] =
    "{1_Building} {2_Specialist} emplacement {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "vide"
-- _FILLED_STATE substitutes into SPECIALIST_SLOT's {4_State} as the
-- in-list state token. _FILLED is the standalone confirmation spoken on
-- Enter when an unfilled slot just became filled. Two keys with identical
-- value so each can move independently if a future tense / particle
-- requires divergent forms in the target language.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "rempli"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "rempli"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "non rempli"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] = "rempli, travailleur retiré de la case"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] =
    "non rempli, travailleur affecté à la case"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "impossible d'ajouter un spécialiste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "Contrôle manuel des spécialistes, {1_State}"
-- Great works sub-handler (§3.12). One item per great-work slot, grouped by
-- building in label. Slot-type label is the work category ("art", "writing",
-- "music"), not the great-person class, because that's what occupies the
-- slot and what the player reasons about. Synthetic theming-bonus entry
-- per building when the bonus is non-zero -- label carries the bonus magnitude
-- and engine's theming tooltip text so the rule is audible inline.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "Chefs-d'oeuvre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "art"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "écriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "musique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} emplacement {2_Slot} {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} emplacement {2_Slot} {3_N}, vide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} bonus de thème plus {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "Aucun emplacement de chef-d'oeuvre."
-- Production queue sub-handler (§3.1). Slot 1 is the currently-producing
-- item, so its announcement carries the production meter percent; slots 2+
-- only have name + turns. Processes (ORDER_MAINTAIN) have no turns line.
-- Drill-in moves and removes via GAMEMESSAGE_SWAP_ORDER / _POP_ORDER.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "File de production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "File vide."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    one = "Emplacement 1, {1_Name}, {2_Turns} tour, {3_Percent} pourcent. {4_Help}",
    other = "Emplacement 1, {1_Name}, {2_Turns} tours, {3_Percent} pourcent. {4_Help}",
}
-- _TRAIN_INFINITE fires for buildable items (units / buildings / wonders)
-- whose remaining turns cannot be estimated from the current production
-- rate (typical for queued slots 2+ where the city has not yet started
-- accumulating progress towards the item). _PROCESS fires for
-- ORDER_MAINTAIN entries (Wealth, Research, Faith, Defense) that have no
-- completion turn or progress meter at any slot because they are
-- perpetual conversions, not buildable items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "Emplacement 1, {1_Name}, {2_Percent} pourcent. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "Emplacement 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    one = "Emplacement {1_N}, {2_Name}, {3_Turns} tour",
    other = "Emplacement {1_N}, {2_Name}, {3_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "Emplacement {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "Emplacement {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "Actions pour {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "Monter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "Descendre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "Retirer de la file"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "Retour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "monté"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "descendu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "retiré"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "Mode file d'attente, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "Choisir la production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "Acheter avec de l'or ou de la foi"
-- Hex map sub-handler (§3.2). Arrow keys walk the cursor across the city's
-- own tile, its workable ring, and purchasable tiles. Tile announcement
-- composes yield line, worked-state word, buy cost, and PlotComposers.glance.
-- Enter over a workable ring plot issues TASK_CHANGE_WORKING_PLOT; over an
-- affordable purchasable plot issues SendCityBuyPlot; over an unaffordable
-- purchasable plot speaks "cannot afford" without sending.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Gérer le territoire"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "gérer le territoire"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "exploitée"
-- "Pinned" = IsForcedWorkingPlot: a worker is here AND the citizen manager
-- won't pull them off. Vanilla's visual is a star/pin icon, so the metaphor
-- matches. Pressing Enter on a "not worked" tile lands here in one step --
-- the engine's TASK_CHANGE_WORKING_PLOT both assigns and forces in a single
-- task, same as a mouse left-click.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "épinglée"
-- BLOCKED: tile cannot be worked at all (enemy unit on it, foreign
-- territory, or otherwise outside the city's reachable working set).
-- NOT_WORKED: workable in principle but no citizen is currently assigned
-- (an Enter press here triggers TASK_CHANGE_WORKING_PLOT to assign one).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "bloquée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "non exploitée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "achetable, {1_Gold} or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "achetable, {1_Gold} or, impossible à acheter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "pas les moyens"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "Déplacer le curseur sur les cases de la ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "Travailler ou acheter la case"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_LIST"] = "L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_LIST"] = "Lister les cases travaillées depuis le curseur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_LIST_NONE"] = "aucune case travaillée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Échap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Retour au centre-ville"
-- Ranged strike sub-handler (§3.5). Hub item closes the city screen, enters
-- INTERFACEMODE_CITY_RANGE_ATTACK, and pushes a target picker. Cursor moves
-- freely via Baseline's QAZEDC; Space speaks a strike-specific preview
-- (target identity if in range, "cannot strike" otherwise); Enter commits
-- with a "fired" confirmation. Exit (commit, cancel, or external pop)
-- returns to the world map -- the city screen does not re-open.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "Attaque à distance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "attaque à distance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "ne peut pas attaquer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "tir effectué"
-- City-attacker damage preview. Mirrors the unit ranged preview shape
-- ("{name}, {my} vs {theirs}, ..."): the cursor already spoke the target
-- tile's full info, so this only names what is being shot at and the
-- engine-computed strengths and damage. No verdict (cities don't get
-- GetCombatPrediction) and no retaliation (city ranged is one-way).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] =
    "{1_Name}, {2_MyStr} contre {3_TheirStr}, {4_Dmg} dégâts sur eux"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_PREVIEW"] = "Espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_PREVIEW"] = "Lire les informations de la cible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_COMMIT"] = "Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_COMMIT"] = "Tirer sur la cible actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_CANCEL"] = "Échap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_CANCEL"] = "Annuler sans tirer"
-- Gift-unit / gift-improvement target picker (audit §7.7). Pushed from
-- the city-state diplo popup when the user chooses Gift > Unit or Gift >
-- Improvement; the engine's INTERFACEMODE_GIFT_UNIT and INTERFACEMODE_
-- GIFT_TILE_IMPROVEMENT are hex-click-only modes with no engine keyboard
-- path. Cursor moves freely via Baseline; Space speaks legality + plot
-- glance; Enter commits (gift-unit chains into BUTTONPOPUP_GIFT_CONFIRM,
-- gift-improvement calls Game.DoMinorGiftTileImprovement directly).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "don d'unité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "don d'amélioration"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "amélioration donnée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_PREVIEW"] = "Espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_PREVIEW"] = "Lire les informations de la cible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_COMMIT"] = "Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_COMMIT"] = "Confirmer le don sur la cible actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_CANCEL"] = "Échap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_CANCEL"] = "Annuler sans faire de don"
-- Rename / Raze hub items (§3.13, §3.14). Rename fires BUTTONPOPUP_RENAME_CITY,
-- whose accessibility is handled by SetCityNameAccess. Raze fires the Yes/No
-- confirmation popup (BUTTONPOPUP_CONFIRM_CITY_TASK with TASK_RAZE), handled
-- by GenericPopupAccess. Unraze is a direct Network.SendDoTask -- no popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "Renommer la ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "Incendier la ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "Arrêter l'incendie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "incendie arrêté"
-- Refus pour l'écran d'espionnage / ville étrangère. Voix calquée sur les
-- autres refus du mod ("impossible de X"), concise pour le lecteur d'écran.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "espionnage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] =
    "défilement entre villes indisponible pendant l'espionnage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "impossible de tirer à distance depuis une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "impossible de modifier la production d'une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "impossible d'exploiter une case d'une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] =
    "impossible d'acheter une case pour une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] =
    "impossible de vendre un bâtiment dans une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] =
    "impossible de modifier l'orientation d'une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "impossible de gérer les spécialistes d'une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "impossible de consulter les chefs-d'œuvre d'une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "impossible d'affecter un citoyen dans une ville qui n'est pas à vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "achetable"
-- Reveal-announce. After a unit moves (or any reveal source -- map share,
-- embassy, scouting agreement), build one line listing what just appeared
-- in the active player's view. Count is plots whose revealed/visibility
-- state just changed; the bucket headers are short labels because a
-- screen-reader user parses positional buckets faster than they parse a
-- single comma-joined run-on. "1 tiles revealed" is a minor grammar
-- oddity but the lower bound is rare in practice (sight radius reveals
-- multiple plots). HIDDEN_HEADER prefixes the inverse direction (foreign
-- units that just left view); cities and resources don't reappear in
-- fog, so the hide line has no count and only the unit sub-payloads.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_COUNT"] = {
    one = "{1_Num} case révélée",
    other = "{1_Num} cases révélées",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "Révélé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "Ennemis : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "Unités : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "Villes : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "Ressources : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "Disparu"
-- Foreign-unit watch. Four lines spoken at the start of each player turn
-- summarising what foreign units entered / left view during the AI turn
-- just past, split by hostile (at-war + barb) and neutral (everyone else
-- not on the active team). The list arg is comma-joined "{count} {civ-
-- adjective} {unit-name}" pieces; count is omitted when 1. Bare unit name
-- without a plural suffix is intentional (Civ V text data has no plural
-- TXT keys; hand-rolling per-locale plural rules is a maintenance trap).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] = "Nouvelles unités hostiles en vue : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] = "Unités hostiles hors de vue : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] = "Nouvelles unités neutres en vue : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] = "Unités neutres hors de vue : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "Quelqu'un d'autre a réclamé "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " et "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    one = "{1_Num} campement barbare visible",
    other = "{1_Num} campements barbares visibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    one = "{1_Num} ruine antique visible",
    other = "{1_Num} ruines antiques visibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "Disparu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    one = "campement barbare",
    other = "{1_Num} campements barbares",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    one = "ruines antiques",
    other = "{1_Num} ruines antiques",
}
-- Turn lifecycle speech. Turn-start is the game-side "Turn: N" label plus
-- the game's AD/BC year, joined by a comma so the moving parts (number
-- first, year second) read as a single line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "Tour terminé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "Fin de tour annulée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Contrôle plus espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] =
    "Terminer le tour, ou annoncer et ouvrir le premier obstacle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Contrôle plus Maj plus espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "Terminer le tour malgré l'invite d'ordres aux unités ; les autres obstacles sont annoncés et ouverts"
-- Empire status readouts (T/R/G/H/F/P/I bare-letter keys in baseline). Each
-- key speaks one composed line; conditional clauses join with comma. Help
-- entries describe the underlying readout, not the panel item, since the
-- speech composes data from multiple panel surfaces.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "{1_Num} au-dessus du plafond d'unités"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    one = "{1_Turns} tour pour {2_Tech}, science +{3_Rate}",
    other = "{1_Turns} tours pour {2_Tech}, science +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} terminé, science +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "Aucune recherche, science +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "Science désactivée"
-- Plural is driven by {4_Avail}: "1 of 1 trade route" vs "1 of 5 trade
-- routes". The Used count can be 1 even when Avail is many.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    one = "+{1_Rate} or, {2_Total} total, {3_Used} sur {4_Avail} route commerciale",
    other = "+{1_Rate} or, {2_Total} total, {3_Used} sur {4_Avail} routes commerciales",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    one = "moins {1_Rate} or, {2_Total} total, {3_Used} sur {4_Avail} route commerciale",
    other = "moins {1_Rate} or, {2_Total} total, {3_Used} sur {4_Avail} routes commerciales",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "pas de {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"
-- Section labels for Shift+letter detail readouts. Inserted as
-- "{Label}: " between sections by newDetail.compose() at transitions
-- the engine's first item doesn't already anchor (Help and Income
-- reuse engine TXT_KEY_HELP / TXT_KEY_EO_INCOME).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "Âge d'or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "Religions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "Grands personnages"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "Influence"
-- Empire status readout payloads. Each STATUS_* below is one composed line
-- spoken by a bare-letter empire-status key (T/R/G/H/F/P/I) or its Shift+
-- detail variant; the active variant is selected by the live engine state
-- (e.g. STATUS_HAPPY when net happiness is non-negative, STATUS_UNHAPPY
-- between -1 and -9, STATUS_VERY_UNHAPPY below). _OFF tokens fire when the
-- corresponding system is disabled in the game options. The HELP_KEY /
-- HELP_DESC pairs further down cover all of these for the help overlay.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} bonheur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "Mécontentement moins {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "Très mécontent moins {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    one = "âge d'or pour {1_Turns} tour",
    other = "âge d'or pour {1_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "{1_Cur} sur {2_Threshold} pour l'âge d'or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "Bonheur désactivé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} foi, {2_Total} total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "Religion désactivée"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PANTHEON, which inlines a long rules
-- explainer after the data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "{1_Num} foi pour le prochain panthéon"
-- Replaces TXT_KEY_TP_FAITH_PANTHEONS_LOCKED, a four-sentence rules
-- paragraph with no live data.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "aucun panthéon disponible"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PROPHET, a one-sentence verbose phrasing
-- that wraps a single data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "{1_Num} foi pour le prochain grand prophète"
-- Replaces TXT_KEY_TP_TECH_CITY_COST and TXT_KEY_TP_CULTURE_CITY_COST,
-- both one-sentence explainers wrapping a single percent. The engine's
-- policy version also tacks on a "don't expand too much!" rules nudge.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "+{1_Pct}% de coût technologique par ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "+{1_Pct}% de coût de politique par ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    one = "+{1_Rate} culture, {2_Turns} tour pour la politique",
    other = "+{1_Rate} culture, {2_Turns} tours pour la politique",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "+{1_Rate} culture, aucune politique restante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] =
    "aucune culture, {1_Cur} sur {2_Cost} pour la prochaine politique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "Politiques désactivées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} tourisme"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    one = "+{1_Rate} tourisme, influent sur {2_Count} civilisation",
    other = "+{1_Rate} tourisme, influent sur {2_Count} civilisations",
}
-- Plural is driven by {3_Total}: "1 of 1 civ" vs "1 of 5 civs". {2_Count}
-- can be 1 even when Total is many.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    one = "+{1_Rate} tourisme, influent sur {2_Count} des {3_Total} civilisation",
    other = "+{1_Rate} tourisme, influent sur {2_Count} des {3_Total} civilisations",
}
-- Help-overlay entries for the empire status readout keys above. Each
-- pair is one row in the help screen: KEY_* names the keystroke, DESC_*
-- summarises what the key reads. The bare-letter variants (T R G H F P I)
-- speak the headline summary; the Shift+letter _DETAIL variants speak the
-- per-source breakdown.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "Tour et date, avec l'effectif d'unités en cas de dépassement et les pénuries de ressources stratégiques"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "Recherche en cours et science par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "Or par tour, total et routes commerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "Bonheur de l'empire, nombre de ressources de luxe apportant du bonheur et âge d'or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "Foi par tour et total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] =
    "Culture par tour et délai pour la prochaine politique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] =
    "Tourisme par tour et nombre de civilisations sous influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Maj plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "Détail de la science par source"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Maj plus G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "Revenus et dépenses en or par source"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Maj plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "Sources de bonheur, sources de mécontentement et effet de l'âge d'or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Maj plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "Détail de la foi par source et calendrier du prophète ou du panthéon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Maj plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "Détail de la culture par source"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Maj plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "Chefs-d'oeuvre, emplacements vides et nombre de civilisations sous influence"
-- Task list readout. Scenario-driven objective tracker; silent when no
-- active tasks exist (the common case outside scenarios and tutorials).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Maj plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "Lire les tâches actives du scénario"
-- GameMenu (Esc pause menu) tab labels and mod-list payloads. Tab labels
-- sit alongside the engine-keyed Details tab (TXT_KEY_POPUP_GAME_DETAILS).
-- The Mods tab lists every mod active in the current save: NO_MODS for the
-- empty-list state, MOD_ENTRY for each row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "Actions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "Aucun mod activé."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, version {2_Version}"
-- Civilopedia (picker/reader two-tab) strings. PICKER_READER_EMPTY and
-- _NO_SELECTION are the two empty-state words used by the shared
-- PickerReader widget; they are mirrored in the FrontEnd strings file
-- because PickerReader serves both Contexts (saves picker, mods picker,
-- replay picker on the front-end side; civilopedia on the in-game side).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "Catégories"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "Contenu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "Aucun texte disponible pour cet article."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "Aucun contenu pour cet élément."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "Aucun élément sélectionné. Allez dans l'onglet des catégories pour en choisir un."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "Introduction"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "Début de l'historique."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "Fin de l'historique."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "Article précédent ou suivant dans l'historique"
-- AdvisorInfoPopup (BUTTONPOPUP_ADVISOR_INFO). Concept drill-down reachable
-- from the tutorial advisor question buttons and from any related concept
-- link within the popup itself. The boundary announcements reuse
-- TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY / _NO_NEXT_HISTORY -- same
-- "Start of history." / "End of history." text, no reason to duplicate.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] =
    "Concept précédent ou suivant dans l'historique"
-- SaveMenu. Two-tab picker/reader over the in-game Save screen. Picker lists
-- existing saves (or cloud slots); reader shows header fields and exposes
-- the Overwrite / Save-to-slot / Delete actions behind pushed Yes/No subs.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "Sauvegardes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "Détails de la sauvegarde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "Aucune sauvegarde dans cette liste."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "Nom de la sauvegarde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] =
    "Le nom de la sauvegarde est vide ou contient des caractères invalides."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "Écraser cette sauvegarde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "Sauvegarder dans cet emplacement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "Écraser {1_Name} ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] = "Écraser l'emplacement Steam Cloud {1_Num} ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "Supprimer {1_Name} ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "Sauvegarde supprimée."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Emplacement Steam Cloud {1_Num} : vide"
-- Spoken replacements for [ICON_*] markup. Registered into TextFilter by
-- CivVAccess_Icons.lua; the filter substitutes the bracket token inline
-- with the spoken text. Singular / plural wording is deliberately relaxed
-- ("turns", "whales") because screen-reader users tolerate minor grammar
-- over awkward branching, and Civ's text uses these icons in both counts.
-- Mirrored in the FrontEnd strings file (each Context has its own
-- sandboxed CivVAccess_Strings table). Keep the two in sync when adding
-- or renaming icon keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "nourriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "foi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "tourisme"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "grands personnages"
-- Dedup-only alias for the singular pairing in base text ("Great Person Focus").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "grand personnage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "puissance de combat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "puissance de combat à distance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "déplacements"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "bonheur"
-- Dedup-only alias. Base text pairs the positive-happy glyph with "Happy"
-- as well as "Happiness"; speaking "happiness Happy" doubles the concept.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "heureux"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "mécontentement"
-- Dedup-only alias. Base text pairs the unhappy glyph with "unhappy" too.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "mécontent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "gauche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "droite"
-- ChooseProduction popup. Wrapped BaseMenu with two tabs (Produce, Purchase)
-- and five groups per tab (Units, Buildings, Wonders, Other, Current queue).
-- Append-mode commit speaks post-commit queue length so the player hears the
-- fill state as they chain picks; queue-full closes the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "Choisir la production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "Produire"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "Acheter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "File d'attente actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "vassale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "ajouté, emplacement {1_Slot} en file d'attente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "file d'attente pleine"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "file d'attente vide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "file d'attente : {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    one = "{1_Num} tour",
    other = "{1_Num} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} foi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "bâtiment {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "acheté {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    one = "{1_Name}, {2_Turns} tour",
    other = "{1_Name}, {2_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"
-- ChooseTech popup. Flat BaseMenu list of researchable techs with the current
-- research pinned on top in free / stealing modes. Activate commits via
-- Network.SendResearch; F6 and the bottom-of-list item both escalate to the
-- full tree through OpenTechTree (defined in TechPopup.lua, same Context).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "Choisir la recherche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "technologie gratuite, {1_N} restante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "vol en cours depuis {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} science par tour"
-- Plural is driven by {2_Turns}.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    one = "en cours de recherche : {1_Name}, {2_Turns} tour",
    other = "en cours de recherche : {1_Name}, {2_Turns} tours",
}
-- Per-tech state words on the picker. FREE fires only in free-tech mode
-- (Liberty finisher, Great Scientist bulb, etc.) for techs that count as
-- gainable for free. CURRENT marks the active research line. QUEUED marks
-- a slot in the planned queue; {1_Slot} is the 1-based queue position
-- counted after the current research (slot 1 = first queued, not the
-- active one).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "gratuit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "en cours de recherche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "emplacement {1_Slot} en file d'attente"
-- Plural driven by {1_Num} (turn count).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    one = "{1_Num} tour",
    other = "{1_Num} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "Ouvrir l'arbre technologique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "recherche de {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "{1_Name} obtenu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "{1_Name} volé"
-- Tech Tree screen. TabbedShell with a hand-rolled DAG cursor tab and a
-- BaseMenu read-only queue tab. Landing speech on every arrow move
-- composes name, status, queue slot (if queued), turns, and unlocks
-- prose. Mode preamble reuses CHOOSETECH_PREAMBLE_* keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "Arbre technologique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "Toutes les technologies"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "File d'attente"
-- Per-tech state words. AVAILABLE: pickable now. UNAVAILABLE: prereqs not
-- met by the player's current research state. LOCKED: in the queue but
-- waiting on an earlier-queued tech to finish (a sequential block, not a
-- prerequisite block). RESEARCHED: already complete.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "recherché"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "prérequis non satisfaits"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "verrouillé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "aucune recherche en cours, file d'attente vide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "en cours"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "{1_Name} mis en file d'attente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "déjà recherché"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "non disponible comme technologie gratuite"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "impossible de voler ceci"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Haut/Bas/Gauche/Droite"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Haut/Bas dans la colonne d'ère, Gauche/Droite à travers la rangée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Droite vers la technologie dépendante, Gauche vers le prérequis, Haut/Bas pour les voisins"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] =
    "Basculer entre navigation par grille et par arbre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "grille"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "arbre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "Rechercher la technologie ciblée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Maj plus Entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] =
    "Mettre en file d'attente la technologie ciblée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Contrôle plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "Ouvrir l'entrée Civilopédia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "Lettre / chiffre / espace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "Saisir pour rechercher par nom ou découvertes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "Fermer l'arbre des technologies"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Échap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "Fermer l'arbre des technologies"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "Politiques sociales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "Politiques"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "Idéologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "ouverte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "terminée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "adoptable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "verrouillée, requiert {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] =
    "verrouillée, requiert une religion fondée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "verrouillée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "bloquée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} sur {2_Total} adoptées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] =
    "ouverture, accordée gratuitement à l'ouverture de la branche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] =
    "finalisation, accordée à la complétion de la branche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "adoptée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "adoptable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "bloquée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "verrouillée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "verrouillée, requiert {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "ouvrir {1_Branch}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] =
    "{1_Cur} sur {2_Cost} culture, {3_Per} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    one = "{1_Turns} tour avant la prochaine politique",
    other = "{1_Turns} tours avant la prochaine politique",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    one = "{1_Num} politique gratuite disponible",
    other = "{1_Num} politiques gratuites disponibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    one = "{1_Num} doctrine gratuite disponible",
    other = "{1_Num} doctrines gratuites disponibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "idéologie non encore embrassée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "idéologie désactivée dans cette partie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "Doctrines de niveau 1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "Doctrines de niveau 2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "Doctrines de niveau 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "emplacement {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "emplacement {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "emplacement {1_Num}, vide, disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
    "emplacement {1_Num}, vide, requiert l'emplacement {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "emplacement {1_Num}, vide, requiert le niveau {2_Level} emplacement {3_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] =
    "emplacement {1_Num}, vide, culture insuffisante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "changer d'idéologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "changer d'idéologie, indisponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "mécontentement {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "Choisir une doctrine"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "aucune doctrine disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "Adopter {1_Name} ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "Ouvrir la branche {1_Name} ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "Adopter {1_Name} ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "Changer d'idéologie ?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "adoptée {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "ouverte {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "doctrine adoptée {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "changement d'idéologie demandé"
-- Number-entry primitive (BaseMenuNumberEntry). Digits / Backspace / Enter /
-- Esc bindings with their own help strings because the digit surface isn't
-- covered by the menu's standard A-Z search entry.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Chiffres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Retour arrière"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "Ajouter un chiffre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "Supprimer le dernier chiffre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "Confirmer le montant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "saisir {1_Label}, max {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "vide"
-- Diplomacy trade screen. Labels for the flat top-level menu (Your / Their
-- Offer), drawer tab names, quantity-bearing Offering lines, and the Other
-- Players group for third-party peace / war actions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "Commerce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "Commerce avec {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "Votre offre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "Leur offre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "Offerte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "Disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, population {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "engagement de vote"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "faire la paix avec {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "déclarer la guerre à {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "Faire la paix"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "Déclarer la guerre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "Autres joueurs"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "aucun disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "rien sur la table"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "vous avez {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "ils ont {1_Num}"
-- DiploCurrentDeals review labels. Each deal renders as one Text leaf
-- whose label inlines the full contents; these are the side prefixes the
-- builder concatenates around the per-item descriptions. Colon-then-list
-- form, distinct from LABEL_VALUE's space form and DIPLO_GOLD_AMOUNT's
-- comma form; the colon reads as a brief pause before the list of items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "nous donnons : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "ils donnent : {1_List}"
-- Variantes au passé composé pour le groupe Accords passés.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "nous avons donné : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "ils ont donné : {1_List}"
-- Titre de l'onglet et libellé du groupe Accords passés.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "Accords"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "Accords passés"
-- Diplomatic Overview (Relations / Global tabs). Per-civ composed lines,
-- trade / third-party fragment prefixes, section group headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader} de {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "score {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "or {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "or par tour {1_N}"
-- Per-resource entry inside strategic / luxury / nearby lists.
-- {1_Name} is the resource's localized name, {2_N} is the count owned.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "stratégique : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "luxe : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "à proximité : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "bonus : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "politiques : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "merveilles : {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "Grandes civilisations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "Cités-États"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "Aucune civilisation rencontrée."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "Aucun accord."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "proposition entrante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "en attente de réponse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "équipe {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "recherche {1_Tech}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "ancré à {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} bonheur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} foi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} nourriture dans la capitale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} nourriture dans les autres villes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} science"
-- Plural driven by {1_N} (turns until next gift unit arrives).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    one = "prochaine unité offerte dans {1_N} tour",
    other = "prochaine unité offerte dans {1_N} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "exporte {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "frontières ouvertes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "intimidable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "allié de {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "votre relation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "relations extérieures"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "ressources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "ère"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "doctrines"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "merveilles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "score"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "relation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "trait et personnalité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "allié avec"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "quêtes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "ressources à proximité"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "aucun"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "personne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, {2_GPT} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "{1_N} pour devenir ami"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "{1_N} pour devenir allié"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, {2_N} pour évincer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] = "civilisation inconnue, {1_N} pour évincer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL"] = "{1_Trait}, {2_Personality}"
-- City Stats drillable. The Stats hub item pushes a sub-handler whose
-- top-level items are these category groups. Per-yield drill-ins reuse
-- the existing CITYVIEW_YIELD_* one-line headers (food / production /
-- gold / etc.) so the per-turn label is identical whether the user reads
-- it from the Yields-group root or the individual yield's drill-in
-- header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "Rendements"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_GROWTH"] = "Croissance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_CULTURE"] = "Progression culturelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_HAPPINESS"] = "Bonheur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "Religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "Routes commerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "Ressources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_DEFENSE"] = "Défense"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_DEMAND"] = "Demande en ressources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "aucune ventilation disponible"
-- Per-yield drill-in header keys re-use the same 7 CITYVIEW_YIELD strings
-- the preamble used to read; the table below is symmetrical so a future
-- locale only writes the spoken label once.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_FOOD"] = "nourriture {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_PRODUCTION"] = "production {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_GOLD"] = "or {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_SCIENCE"] = "science {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_FAITH"] = "foi {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_TOURISM"] = "tourisme {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_CULTURE"] = "culture {1_Num}"
-- Culture progress group: stored / threshold pair, per-turn rate, and the
-- next-tile countdown that the engine hides when culture per turn is zero.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_PROGRESS"] = "{1_Stored} sur {2_Needed} culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_PER_TURN"] = "{1_Num} par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    one = "prochaine case dans {1_Num} tour",
    other = "prochaine case dans {1_Num} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "expansion territoriale bloquée"
-- Happiness group: local-only contribution from buildings here, plus the
-- per-city slice of the empire's unhappiness pool (population / occupied /
-- specialists already folded in by the engine).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LOCAL"] = "bonheur local {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_UNHAPPINESS"] = "mécontentement {1_Num}"
-- Religion group: one row per religion present, holy-city flag inlined
-- when applicable so the user hears it together with that religion's
-- numbers rather than as a separate line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    one = "{1_Religion}, {2_Followers} adepte, {3_Pressure} pression",
    other = "{1_Religion}, {2_Followers} adeptes, {3_Pressure} pression",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    one = "{1_Religion}, ville sainte, {2_Followers} adepte, {3_Pressure} pression",
    other = "{1_Religion}, ville sainte, {2_Followers} adeptes, {3_Pressure} pression",
}
-- Trade group: direction first so the partner city name lands second
-- (matches the way GetTradeRoutes presents from / to).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_OUTGOING"] = "vers"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_INCOMING"] = "depuis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_DOMAIN_LAND"] = "terrestre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_DOMAIN_SEA"] = "maritime"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_ROUTE"] = "{1_Direction} {2_City}, {3_Domain}"
-- ChooseInternationalTradeRoutePopup row format: destination identifier
-- (city, plus civ for major-civ rows), hex distance, then yields split
-- into "you get" / "they get" sides matching the engine's myBonuses /
-- theirBonuses bucketing. Religion-pressure direction verified against
-- Community-Patch-DLL CvLuaPlayer.cpp lGetPotentialInternationalTrade
-- RouteDestinations.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
-- Plural driven by {1_Num} (hex distance to destination).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = {
    one = "{1_Num} case",
    other = "{1_Num} cases",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "Vous recevez {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "Ils reçoivent {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} reçoit {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} pression"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "Aucune destination valide."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "Aucune ville d'attache valide."
-- Trade Route Overview (TRO) screen. Distinct from the per-pick
-- ChooseInternationalTradeRoutePopup above: TRO is the standalone Ctrl+T
-- screen that surveys every trade route currently active in the game.
-- Three tabs: Yours (your active routes), Available (routes you could
-- start but haven't), and With You (routes other civs run to your
-- cities). Domain words distinguish caravan (land) from cargo ship (sea).
-- ROUTE_HEADER carries five placeholders: domain word, source city, source
-- civ, destination city, destination civ.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Contrôle plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "Ouvrir la vue d'ensemble des routes commerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "Vos routes commerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "Routes commerciales disponibles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "Routes commerciales avec vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "caravane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "navire marchand"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} vers {3_To}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "la cité-État de {1_City}"
-- Plural driven by {1_Num} (turns until the route arrives at its
-- destination and resolves).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    one = "{1_Num} tour restant",
    other = "{1_Num} tours restants",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "Aucune route."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "Aucune ventilation de source disponible."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "Trier par : {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "Trier par"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "or reçu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "science reçue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "nourriture reçue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "production reçue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "pression religieuse vers la destination"
-- Defense group of the City Stats drillable. Each defensive building
-- announces with the same {Building} format string so adding a new
-- defensive building only adds a row, not a new label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_DEFENSE_BUILDING_LINE"] = "{1_Building}"
-- Leader descriptions. Spoken on F2 over LeaderHeadRoot /
-- DiscussionDialog / DiploTrade, keyed by Leaders.Type (Players[i]:GetLeaderType()
-- -> GameInfo.Leaders[lt].Type). Sourced from docs/leader-descriptions.md.
--
-- Each entry is a long-form prose description of what sighted players see in
-- the leader's diplomacy splash art: clothing, regalia, posture, setting,
-- background details. The intent is to give blind players the same first-
-- impression context a sighted player would get from looking at the leader's
-- portrait when meeting them in the diplomacy screen.
--
-- Translation guidance: produce equivalent natural prose in the target
-- language; do not translate literally. Historical and cultural terms
-- (regnal titles, dynasty names, garment names, weapon names) should use
-- the target language's conventional rendering when one exists. The leader's
-- name and titles at the start of each description follow whatever form is
-- standard for that historical figure in the target language.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "Décrire le chef"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "Aucune description disponible pour ce chef."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "George Washington, premier président des États-Unis, se tient dans un intérieur lambrissé entre de lourds rideaux rouges tirés de chaque côté, les mains détendues sur les hanches. Il porte la tenue civile noire d'un gentleman américain de la fin du XVIIIe siècle : un manteau sombre à double boutonnage coupé long sur les cuisses, avec deux rangées de boutons en laiton sur le devant, un gilet assorti en dessous, un jabot blanc à volants au cou et des manchettes blanches aux poignets. Ses cheveux sont poudrés de blanc, brossés en arrière depuis un front haut, bouclés sur les côtés au-dessus des oreilles et rassemblés derrière en une queue nouée par un ruban de soie noire. À sa gauche, un grand globe terrestre repose sur un pied en bois tourné ; sur une petite table à côté du pied, un volume relié est ouvert avec un signet de ruban bleu qui dépasse de ses pages. À sa droite, un manteau de cheminée en pierre pâle supporte un grand candélabre en laiton de bougies non allumées, et au-dessus est accroché un paysage encadré dans un cadre doré. Entre les rideaux ouverts derrière lui, une colonne cannelée s'élève contre un ciel de jour et un aperçu d'un pays verdoyant et vallonné. La composition reprend le portrait Lansdowne de Gilbert Stuart de 1796, l'épée de cérémonie et les documents d'État remplacés ici par le globe et le livre."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "Haroun al-Rachid, Commandeur des Croyants et cinquième calife des Abbassides, est assis dans le jardin d'un palais en fin de matinée, une cour pavée s'ouvrant derrière lui sur une colonnade de pierre claire à arcades en ogive, et un dôme lointain se dressant dans la brume au-delà. Il est barbu et brun de cheveux, assis sur une chaise basse en bois sculpté dont les accoudoirs s'achèvent en pommeaux arrondis, la tête enveloppée dans un grand turban couleur safran surmonté d'une calotte souple. Une large ceinture de la même étoffe safran, dont les extrémités sont brocardées et frangées d'or, est enroulée sur sa poitrine depuis l'épaule droite et rassemblée à la hanche gauche par-dessus une ample robe blanche tombant aux chevilles, dont l'ourlet est bordé du même galon d'or. Sa main droite est levée près de l'épaule et tient un qalam, le calame arabe en roseau, entre le pouce et l'index ; sa main gauche repose à plat sur ses genoux. Ses pieds sont posés sur un tapis rond tissé de médaillons bleus, crème et rouille, et sur les dalles à côté gisent deux codices reliés, le plus haut étant un volume à couverture rouge foncé estampée d'or. Des cycas et des fougères en pots dans des coupes de céramique bleue vernissée se tiennent de chaque côté de la chaise, une grande urne en terre cuite s'élève à droite, et de sombres haies ferment le fond de la scène sous les arcades."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "Ashurbanipal, Roi du monde, Roi d'Assyrie, se tient debout dans une salle à colonnes de son palais, une tablette de pierre pâle maintenue droite contre sa poitrine dans sa main droite, ses doigts recourbés sur le bord supérieur. Il est large d'épaules et aux bras nus, sa peau chaude dans la lumière. Sa barbe est longue et taillée en carré, disposée en boucles parallèles serrées jusqu'à la poitrine, ses cheveux noirs tombant en boucles assorties jusqu'à l'épaule. Un diadème d'or bas ceint son front, son bandeau travaillé de rosettes. Il porte le châle royal à la cheville de la cour assyrienne : une robe de dessous bleu profond parsemée de rosettes d'or, recouverte d'un lourd manteau magenta dont le bord frangé court en diagonale sur son torse, sur son épaule gauche et dans son dos, ses ourlets ornés de broderies d'or et de rouge. De larges bracelets d'or enserrent ses deux poignets, et un bandeau assorti ceint son bras droit au-dessus du coude. Derrière lui se dresse une niche en arc de cercle encadrée de minces colonnes aux chapiteaux à volutes pâles ; de chaque côté, posés sur des socles, se tiennent les sombres figures barbues des lamassu, les taureaux ailés à tête humaine qui gardaient les portes des palais assyriens. Sur le mur du fond, de bas-reliefs en pierre peu profonds représentent des chevaux de profil dans un registre horizontal, à la manière des panneaux de chasse et de char de son palais de Ninive. Le sol est recouvert de carreaux pâles, la salle s'enfonçant dans l'ombre de chaque côté."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "Marie-Thérèse, par la grâce de Dieu impératrice douairière des Romains, reine de Hongrie, de Bohême, de Dalmatie, de Croatie, de Slavonie, de Galicie, de Lodomérie, archiduchesse d'Autriche (et ainsi de suite), se tient sur une loggia de pierre à arcades, une galerie couverte dont les hautes arcades en plein cintre s'ouvrent d'un côté sur un paysage alpin de sommets enneigés, et de l'autre sur un sol poli orné d'un tapis rouge courant le long de la colonnade. Des panneaux de damas rouge sont suspendus entre les arcades sur le mur intérieur, et la lumière du soleil venant de la gauche projette de longues ombres sur la pierre. Elle se tient de trois quarts, les bras légèrement croisés à la taille, la tête légèrement détournée. Ses cheveux sont d'un blond très clair, ramenés en arrière et épinglés haut selon la mode de la cour. Sa robe est de soie bleu-gris pâle ; le corsage est lacé serré jusqu'à la pointe de la taille, devant lequel se trouve un buse, ce panneau rigide décoré brodé d'argent et orné de petits joyaux. Une large jupe à cerceau s'étale sur des paniers, la même broderie d'argent courant en bande descendante sur le devant ouvert de la jupe de dessus. Les manches se terminent au coude par de courts bouillons garnis de dentelle blanche. Un fichu de dentelle transparente est plié sur les épaules et glissé dans l'encolure. Elle ne porte ni couronne ni bijoux visibles. Derrière elle, les arcades s'éloignent en pierre pâle, la balustrade de colonnes tournées se prolongeant au loin, les Alpes brillantes sous un ciel dégagé."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "Montezuma Xocoyotzin, Huey Tlatoani des Mexicas, se tient devant un grand brasero dont les flammes s'élèvent entre lui et le spectateur, la salle alentour n'étant éclairée que par ce seul feu. Il est torse nu et de forte carrure, la peau sombre dans la lueur des flammes, le visage à demi dans l'ombre. Sa coiffe est le quetzalapanecayotl, une aigrette de longues plumes de queue d'ara quetzal irisées, vertes et bleues, maintenues par un frontal d'or. Des disques d'or percent ses oreilles, un collier de jade et d'or ceint son cou, de larges bracelets de jade et d'or enserrent ses poignets, et des anneaux d'or entourent chaque biceps. Derrière lui, enchâssé dans un mur de maçonnerie rouge, un grand disque sculpté présente des bandes concentriques de glyphes autour d'un visage central, à la manière de la Pierre du Soleil aztèque. Les murs de chaque côté sont sculptés de rangées de crânes stylisés, le tzompantli, le présentoir de crânes exposé dans les temples aztèques ; au-dessus de chaque présentoir s'élève un grand masque de divinité aztèque sculpté, et une urne de pierre au sommet de chaque mur brûle d'une haute flamme. Toute la salle resplendit des rouges et des ors de la lueur des brasiers."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "Nabuchodonosor II, roi de Babylone, est assis sur un trône de pierre massif dans une salle de maçonnerie éclairée de vert, les murs derrière lui se perdant dans l'ombre. Il porte l'agu, le bonnet haut et arrondi des rois néo-babyloniens, cerclé d'une bande au niveau du front. Sa barbe est longue, sombre et coiffée en rangées étagées de boucles tubulaires serrées. Sa robe est rouge foncé, à manches courtes et ornée partout de rosettes d'or régulièrement espacées, ceinturée à la taille par une large écharpe brodée ; la jupe tombe droit jusqu'à ses pieds nus, ourlée d'une bande de franges pâles. De lourds bracelets en or enserrent chaque poignet. Ses mains reposent à plat sur les larges accoudoirs du trône, qui se terminent à l'avant par des corbeaux sculptés en tête de lion, les gueules grondantes tournées vers l'extérieur à la hauteur de ses genoux ; une paire plus petite de têtes de lion assorties dépasse de la base du trône à ses pieds. De part et d'autre du trône se dressent deux hauts socles de pierre sculptés de corps serpentins enroulés, chacun surmonté d'une large vasque peu profonde d'où s'élève une flamme vert pâle, seule source de lumière dans la salle, projetant un vert blafard sur les murs de pierre, son visage et sa robe."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "Dom Pedro II, Empereur du Brésil, est assis à un large bureau en bois dans un cabinet de travail aux boiseries sombres, la scène encadrée comme si le spectateur se trouvait en face de lui de l'autre côté du bureau. C'est un homme d'âge mûr, large d'épaules et corpulent, avec une barbe blanche fournie qui tombe bien en dessous de son col et des cheveux blancs clairsemés rejetés en arrière depuis un front haut. Il porte une redingote sombre sur un gilet sombre et une chemise blanche à col haut avec une cravate sombre au niveau de la gorge. À sa poitrine gauche est épinglée l'étoile ornée de joyaux de l'Ordre impérial de la Croix du Sud, dont il était Grand Maître. Ses deux mains reposent à plat sur le bureau ; des papiers épars et un petit encrier sont posés devant lui, et une plume d'oie se dresse dans un porte-plume rond près de sa main droite. Sur le bureau à sa gauche est posée une lampe à huile allumée avec une haute cheminée en verre transparent et un socle en laiton poli, sa flamme étant le point le plus lumineux de l'image et la source principale de la lumière qui tombe sur son visage et ses mains. Derrière lui et sur les côtés, les murs sont garnis du sol au plafond de bibliothèques plongées dans l'ombre profonde. Une haute fenêtre à son épaule gauche laisse entrevoir une portion de ciel nocturne en bleu profond à travers des volets en bois inclinés, des frondes de palmiers se découpant en silhouette au-delà. À l'extrême gauche du cadre, une plus petite fenêtre en verre armé à losanges capte les teintes plus chaudes d'un ciel crépusculaire, et une petite pendule de cheminée est posée sur une étagère en dessous. Le sol est recouvert d'un tapis à motifs dans des rouges et des ors atténués."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "Théodora, Augusta des Romains, est allongée sur un canapé bas de brocart doré sur une terrasse à colonnade ouverte, un bras posé le long d'un traversin, l'autre reposant sur ses genoux. Sa couronne est un stemma orné de joyaux, le bonnet en dôme de la coiffe impériale byzantine, dont le bandeau est serti d'une rangée de pierres en cabochon. Un joyau vert est placé bien en évidence au front, la crête au-dessus s'élevant vers une seconde pierre verte retenue dans une monture en or. Ses cheveux sont ramenés en arrière sous la couronne et retombent longuement sur son épaule droite. Les pendilia, pendentifs perlés du stemma, pendent de part et d'autre de son visage ; un maniakis encercle sa gorge, le collier impérial serti de joyaux de l'Orient. Sa robe est composée de plusieurs couches : un corsage rouge foncé ajusté fermé au centre par un médaillon d'or, une jupe de soie vert doré ornée de volutes posée sur ses genoux, et en dessous une longue jupe de dessous bleu sarcelle foncé bordée à l'ourlet d'un étroit galon d'or. Des manchettes d'or entourent ses poignets. Un lourd rideau rouge tombe derrière elle à droite, écarté pour révéler la scène au-delà. La terrasse est dallée de pierre chaude et bordée d'une balustrade sculptée ornée d'urnes de fleurs rouges, deux colonnes de marbre pâle encadrant la vue. De l'autre côté d'une large vallée se dresse Sainte-Sophie, son vaste dôme central flanqué d'un demi-dôme plus bas, ses murs dorés dans la lumière du soleil, de basses collines se fondant en bleu derrière elle sous un ciel dégagé."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "Didon, reine fondatrice de Carthage, se tient debout sur une terrasse de palais, la nuit. Derrière elle, le ciel est d'un bleu profond piqué d'étoiles, un promontoire lointain vaguement visible à l'horizon au-dessus d'un bas parapet. Un banc de pierre incurvé se dresse dans son dos, son extrémité sculptée d'une frise en volutes, et des colonnes claires s'élèvent derrière lui. De chaque côté de la terrasse, deux grands arbustes dans des jardinières de pierre claire portent des feuilles sombres et de petites fleurs rouges : des grenadiers, dont le nom latin punicum les désigne comme l'arbre de Carthage. Elle a la peau claire, les cheveux sombres séparés au centre et tombant jusqu'aux épaules, un mince diadème d'or à son front. Sa robe est un chiton d'un blanc presque pur, la tunique grecque épinglée aux épaules et ceinturée à la taille, sa jupe pleine longueur parsemée d'un discret motif tissé. De courtes manches fendues sont épinglées à intervalles réguliers le long du bras avec de petites broches, et une large ceinture de bleu profond enserre sa taille et descend en un long panneau sur le devant de la jupe. À son cou repose un large pectoral de pierres sombres serties dans l'or, et un fin bracelet d'or ceint un de ses poignets. Ses mains reposent le long de son corps, la pierre autour d'elle fraîche dans la lumière nocturne."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "Boudicca, reine des Icènes, se tient sur le flanc herbu d'une place forte au sommet d'une colline. À gauche se trouve un mur de pierre surmonté d'une palissade de pieux en bois aiguisés, le toit de chaume conique d'une maison ronde apparaissant au-dessus ; à droite, une chaîne de collines verdoyantes descend sous un ciel gris lourd. Ses cheveux sont coupés court et d'un rouge cuivré vif, une longueur de tissu pâle nouée à l'arrière de sa tête et tombant derrière son épaule. Une petite marque bleu foncé se trouve sur sa pommette sous un oeil, du pastel-des-teinturiers du type que les anciens Bretons utilisaient comme peinture corporelle. Un torque celtique, d'or tordu et rigide, encercle son cou. Sa robe est une tunique sans manches jusqu'aux genoux en tissu à carreaux bleus et verts, resserrée à la taille par une ceinture en cuir à boucle ronde. Des brassards en cuir sont lacés sur ses poignets, un protège-bras assorti attaché autour de son bras supérieur, ses mollets nus au-dessus de bottines en cuir basses. Dans sa main gauche, elle tient une courte épée droite à double tranchant de La Tène, la lame effilée en pointe et la garde petite et simple ; sa main droite serre le manche vertical d'une lance plantée dans le gazon, côté crosse en bas. À sa gauche se dresse un léger char à deux roues, son unique roue à rayons cerclée de fer, un faisceau de longues lances inclinées hors de sa caisse."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "Wu Zetian, Huangdi de la dynastie Tang, se tient au centre d'une salle sombre entre de lourds rideaux rouges tirés de chaque côté. Derrière elle, une rangée de lanternes dorées aux teintes chaudes est suspendue dans l'obscurité, le mur sombre derrière elles orné de panneaux de treillis sculpté. Ses cheveux noirs sont rassemblés et coiffés haut sur sa tête, fixés à l'avant par un buyao, un ornement d'or et de perles. Elle porte un ruqun, vêtement porté en plusieurs couches. Une robe intérieure de soie or pâle croise au buste au-dessus d'un panneau d'or rigide brodé d'un médaillon ; une ceinture rouge vif, nouée haut sous la poitrine, tombe en une longue jupe jusqu'au sol. Par-dessus, elle porte une robe extérieure de soie rouge foncé ornée de rondelles d'or, ses larges manches pendant au-delà de ses mains et son ourlet traînant étalé sur le sol autour de ses pieds. Elle tient un petit vase d'or à deux mains à la taille, légèrement levé comme s'il était présenté. Son teint est clair, son expression composée, son regard calme. Les rideaux rouges, la robe rouge et les lanternes dorées réchauffent le cadre face à l'obscurité de la salle."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "Harald 'Bluetooth' Gormsson, Roi des Danois et de Norvège, se tient au milieu du pont ouvert d'un drakkar. Il est large et solidement bâti, sa barbe d'un blond roux fourchue en deux tresses qui tombent sous son col, sa moustache longue et tombante. Sa tête est nue, les cheveux relevés en chignon. Un manteau de longue fourrure rousse repose sur ses épaules. En dessous, il porte une tunique vert-gris avec un empiècement plus sombre, dont l'ourlet et les manchettes sont ornés de bandes gravées d'entrelacs nordiques. Une large ceinture de cuir travaillé traverse sa taille, fermée par une lourde boucle carrée, et une deuxième sangle court en diagonale sur sa poitrine ; ses deux mains reposent sur la ceinture devant lui. Son casque gît sur le pont à ses pieds, une calotte de fer sombre avec une barre de renfort sur le front et le nez, et des côtés évasés en rabats arrondis de fourrure rousse épaisse. À sa gauche, l'étrave du navire se recourbe vers le haut et vers l'intérieur en une haute spirale de bois sculpté pour ressembler à une tête de dragon. Derrière son épaule droite, des cordages descendent d'un mât, et au-dessus d'eux une voile pend en larges rayures verticales de rouge et de blanc. Le long du bastingage, un bouclier de bois rond est monté face vers l'extérieur, son umbo de fer au centre. Le ciel au-dessus est dégagé et bleu, strié de nuages élevés."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "Ramsès II, Pharaon des Deux Terres, est assis sur un trône au sommet d'un court escalier, une salle de hautes colonnes peintes en bleu s'ouvrant de chaque côté de lui. Il a le visage jeune et est glabre, la peau d'un bronze intense, les yeux soulignés de kohol sombre. Sa coiffe est un nemes, une coiffe rayée d'or et de bleu rassemblée près des tempes et tombant en pans plissés sur sa poitrine. À son front se dresse l'uræus, un cobra dressé qui marque la royauté. Sur ses épaules et sa poitrine repose un ouserékh, un large collier fait de rangées de perles superposées en or et en lapis-lazuli bleu. Il porte un chendyt, un pagne plissé pharaonique en long lin blanc, ceinturé à la taille par une large bande d'or et de bleu qui descend sur le devant en un panneau rigide à motifs. Ses pieds, chaussés de sandales, reposent sur la marche supérieure. Dans sa main gauche il tient un grand sceptre contre son épaule ; sa droite repose sur le bras du trône. Les colonnes qui l'encadrent sont peintes de registres bleus, dorés et rouges, leurs chapiteaux en forme de bouquets de papyrus et sculptés de rangées de hiéroglyphes et de figures debout. Placées devant le trône de chaque côté se dressent deux grandes statues dorées d'Isis et de Nephtys, les déesses protectrices, leurs ailes déployées et projetées vers l'avant, les plumes rendues en longues lames dorées. Des palmes se penchent de chaque côté, et les marches de pierre jaune à ses pieds sont incisées de rangées de petits motifs triangulaires. Toute la salle baigne dans un or chaud, les bleus des colonnes et du collier étant les seules notes fraîches qui s'y détachent."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "Élisabeth Ire, par la grâce de Dieu reine d'Angleterre, de France et d'Irlande, Défenseure de la Foi, est assise sur un trône sculpté à haut dossier flanqué de deux candélabres sur des socles en pierre, leurs bougies non allumées. Un dais d'apparat s'élève derrière elle, du lourd velours rouge tiré en plis par des cordons dorés à glands, l'obscurité de la salle au-delà à peine visible. Ses cheveux sont coiffés haut en boucles serrées d'un blond rougeâtre, liés par une petite couronne ornée de pierreries ; son col est la fraise rigide et ouverte de la cour des Tudor tardifs. Sa robe est un brocard d'or brodé de noir, le corsage taillé près du corps et orné de gemmes, les manches bouffantes à l'épaule et se rétrécissant en manchettes de dentelle, la jupe étalée en largeur sur un vertugadin. De longs rangs de perles traversent sa poitrine et pendent à sa taille, portés en son temps comme emblème de virginité. Ses mains pâles reposent sur les accoudoirs du trône."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "Hailé Sélassié Ier, empereur d'Éthiopie, élu de Dieu, lion conquérant de la tribu de Juda, se tient dans une longue salle de réception de son palais, un plafond à caissons pâle au-dessus de lui, de hautes fenêtres à sa droite, un lustre en cristal suspendu entre elles. Il est mince et droit, à la barbe sombre et taillée ras, les cheveux coupés ras. Il porte une tunique militaire sombre boutonnée jusqu'à la gorge, un simple pantalon sombre et une large ceinture de cuir noir à la taille. De son épaule droite jusqu'à sa hanche gauche court une large écharpe de moiré vert émeraude, le ruban de l'ordre du Sceau de Salomon. Quatre rangées de rubans miniatures se groupent en haut sur sa poitrine gauche, décorations de campagne et d'honneur accumulées tout au long de son règne. En dessous pendent deux grandes étoiles de poitrine d'ordres impériaux supérieurs, à huit branches et travaillées en or et émail. Sa main gauche repose à son côté, sa main droite tient une paire de gants. À sa gauche se dresse le trône impérial : un fauteuil à dossier haut tapissé de crème pâle et de bleu, son fronton sculpté en une couronne arquée et drapé d'un tissu brodé, posé sur un tapis à motifs rouges courant toute la longueur de la salle. Des fauteuils rembourrés pâles longent les murs derrière lui, s'éloignant dans la salle."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "Napoléon Bonaparte, Empereur des Français, est assis à cheval sur un cheval gris pâle dans un champ crépusculaire d'herbe sèche, un ciel brun rougeâtre et des arbres dénudés derrière lui. Il porte un manteau bleu foncé avec de lourdes épaulettes d'or, une veste blanche, une culotte blanche et de hautes bottes d'équitation noires. Son bicorne est porté en travers, les deux pointes tournées vers ses épaules selon l'orientation qu'il affectionnait pour se distinguer de ses officiers. La bride du cheval est en cuir rouge clouté de dorures ; le caparaçon en dessous est bordé de rouge et d'or. La composition rappelle le tableau de Jacques-Louis David intitulé Napoléon franchissant les Alpes, mais figée : pas de cheval cabré, pas de main qui désigne, seulement une silhouette seule dans le paysage au crépuscule."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "Otto von Bismarck, ministre-président de Prusse et premier chancelier de l'Empire allemand, se tient dans une haute salle d'apparat éclairée par la lumière du jour qui pénètre à travers des fenêtres à petits carreaux de plomb derrière lui, chaque vitre divisée en petits carrés par de fins montants. De lourdes tentures cramoisi sont drapées et retenues à chaque fenêtre en plis profonds, leur doublure intérieure d'un rouge plus sombre. Le sol est poli comme un miroir et capte la lumière des fenêtres en longues bandes pâles. À sa gauche, une petite table d'appoint supporte une lampe globe blanche. Il est grand et large d'épaules, chauve sur le dessus avec une frange courte de cheveux gris argenté sur les côtés et à l'arrière, et porte une épaisse moustache blanche, longue et retroussée à ses extrémités. Son manteau est un frac militaire sombre à double boutonnage en ardoise profonde, boutonné sur la poitrine par deux rangées parallèles de boutons dorés, le col montant garni d'or, les épaules lestées de lourdes épaulettes à franges d'or dont la frange descend jusqu'au haut du bras. Juste en dessous du col pend une petite croix pâle sur un ruban sombre, le Pour le Mérite, la plus haute distinction militaire prussienne. Il se tient aux trois quarts face au spectateur, droit et immobile, le regard fixé au-delà de l'épaule du spectateur."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "Alexandre le Grand, Roi de Macédoine et Hégémon des Hellènes, est assis à cheval sur son étalon noir de jais, Bucéphale, le tenant en bride dans une prairie verte de haute altitude, avec des chaînes de montagnes grises de chaque côté et un seul sommet enneigé se dressant à droite. Il est jeune et imberbe, ses cheveux châtains séparés au centre et relevés depuis le front en une anastole, une mèche soulevée qui devint la marque distinctive de ses portraits. Il porte un linothorax, une armure hellénistique faite de couches de lin et de cuir, recouverte d'une plaque dorée, ses épaulières attachées sur la poitrine par de courtes cordes. Au centre de la poitrine, une plaque carrée dorée porte un gorgoneion, la tête de Méduse en relief. Des épaules et de la taille ceinturée pendent des ptéruges, des rangées de lanières de cuir rigidifiées qui protègent le haut des bras et les cuisses, chaque lanière bordée de rouge et surmontée d'un clou doré. Ses bras sont nus, un large bracelet d'or au poignet droit ; il ne porte pas de casque et ne tient aucune arme visible. Le harnais du cheval est en cuir sombre travaillé de rouge, le frontal et les montants de joue cloutés, une seule rêne tirée à travers l'encolure dans sa main gauche. Sous la selle, une peau de léopard tachetée drape le flanc du cheval, les pattes toujours attachées."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "Attila, roi des Huns, est assis sur un trône de bois à haut dossier au sommet d'une estrade surélevée, la salle alentour baignant dans des rouges profonds et des ors. Il est affalé à son aise, une jambe croisée sur l'autre, une épée nue posée en travers de ses genoux ; une main repose sur la lame, l'autre tient une coupe. Sa tunique est rouge à longues manches, bordée d'or, portée sur des pantalons bleu sombre rentrés dans de hautes bottes de cuir souple garnies de fourrure au revers. Un bonnet conique de fourrure sombre agrémenté d'un bandeau d'or couvre sa tête. Il est barbu et porte de longues moustaches, son visage à demi éclairé depuis la droite. Les accoudoirs du trône s'achèvent en têtes de lion sculptées, et une épaisse fourrure est jetée sur le dossier. Derrière lui, une tenture rouge est flanquée de panneaux ornés de disques de bronze ronds de tailles graduées, dans lesquels la lueur du feu se reflète. À droite de l'estrade, un grand chandelier de fer porte une unique bougie allumée. Au-delà, sur le sol, un large bol de laiton hérisse ses bords des poignées de sabres dans leurs fourreaux, disposés à la verticale. Plus loin encore, un coffre de bois ouvert répand des pièces de monnaie sur un tapis à motifs."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "Pachacuti Inca Yupanqui, Sapa Inca de Tahuantinsuyu, est assis sur un haut trône de pierre sur une terrasse dominant le Machu Picchu, le trône sculpté de rangées de motifs géométriques entrelacés rehaussés d'or et de rouge. Au-dessus de lui sur sa droite, fixé à un pilier de pierre, un grand disque solaire en or présente un visage humain stylisé en son centre dans un anneau de rayons divergents. Des sommets dénudés s'élèvent abruptement à sa gauche, et de basses constructions au toit de chaume sont disposées sur des terrasses agricoles étagées en contrebas. Il porte une mascapaycha, une frange de laine rouge tombant sur le front en tant qu'emblème de la souveraineté inca, retenue par un llauto, un bandeau multicolore, et surmontée d'un bouquet de plumes droites rouges et sombres. Ses cheveux sont noirs et descendent jusqu'aux épaules. Autour de son cou est suspendu un lourd pectoral en forme de disque d'or. Sa tunique est un vêtement sans manches allant jusqu'aux genoux, à motif de damier noir et blanc, avec un joug rouge et or sur la poitrine. En dessous du genou, ses jambes sont enroulées de cordes à franges rouges. Dans sa main droite il tient un grand bâton surmonté d'une figure d'oiseau en or, son fût orné de glands rouges en étages."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "Mohandas Karamchand Gandhi, Mahatma, leader de l'indépendance de l'Inde, se tient sur une côte indienne d'herbe jaune sèche, un promontoire rocheux et une mer pâle. Il est mince, chauve, portant des lunettes, avec une moustache grise coupée court. Il porte la tenue de la fin de sa vie : un dhoti blanc simple noué à la taille, un châle drapé sur une épaule et passé sous le bras opposé, sa poitrine nue. Le tissu n'est pas teint et filé à la main, un rejet délibéré du tissu britannique qui devint l'emblème de son mouvement. Le décor rappelle les longues marches qu'il effectuait vers la mer lors de la lutte pour l'indépendance, une figure solitaire au bord du sous-continent."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "Gajah Mada, Mahapatih de l'Empire Majapahit de Java, se tient debout au bord d'une rizière inondée, l'eau brillante comme un miroir entre de bas mamelons verdoyants. Derrière lui, une forêt tropicale dense escalade un flanc de colline enveloppé d'une brume pâle, et de cette brume surgit la svelte silhouette étagée d'un candi, une tour de temple en briques rouges dont le toit en gradins se dissout dans les nuages. Il est large d'épaules et torse nu, ses cheveux sombres relevés en chignon, une petite touffe de barbe au menton. Des bracelets d'or enserrent chaque biceps et chaque poignet. Une large ceinture est portée haut sur sa taille, fermée par une grande plaque d'or festonnée travaillée dans le style floral Majapahit. Sous la ceinture, un sarong rouge est enroulé et noué à l'avant, ses plis tombant en lourds panneaux sur un tissu de dessous jaune qui apparaît à l'ourlet. À sa hanche droite, suspendu à une cordelette passant dans la ceinture, pend un kris dans son fourreau dont le renflement en bois sombre s'effile jusqu'à une pointe étroite, la poignée saillant vers l'avant à un angle incliné."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "Hiawatha, fondateur de la Confédération haudenosaunee, se tient debout dans une clairière ensoleillée, un grand rocher gris s'élevant à la hauteur de son épaule et de fins troncs de hêtres et de bouleaux s'effaçant dans les sous-bois verts derrière lui. Il est torse nu et svelte, la peau d'un brun chaud dans la lumière tachetée. Ses cheveux sont coiffés en touffe de scalp : les côtés de la tête rasés de près et une étroite crête de cheveux sombres courant d'avant en arrière sur le sommet, deux plumes dressées fixées à l'arrière. Des bandes de peinture sombre cerclent chaque bras au niveau du biceps. Un ras-de-cou ajusté de perles de coquillage blanc, un wampum, orne son cou, et une unique lanière traverse sa poitrine depuis l'épaule droite jusqu'à la hanche gauche, soutenant un carquois dont les extrémités emplumées dépassent son épaule. À sa taille, un pagne de peau de daim beige clair tombe en un long rabat frontal jusqu'à mi-cuisse. Des jambières frangées de peau de daim couvrent ses mollets de la cheville au genou, nouées sous le genou et laissées ouvertes à la cuisse là où le pagne le couvre. Il se tient pieds nus sur la terre battue de la clairière, les bras le long du corps, la lumière de la forêt tombant sur son côté droit."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "Oda Nobunaga, daimyo du clan Oda et premier des grands unificateurs, se tient dans un pays verdoyant et vallonné de hautes herbes et de pierres blanches éparses, une chaîne de montagnes bleues s'éloignant vers l'horizon sous un ciel lumineux chargé de nuages en masse. Son crâne est rasé à la manière du sakayaki, le front et le sommet rasés pour qu'un casque puisse y reposer avec fraîcheur et stabilité, les cheveux restants rassemblés derrière. Il porte une fine moustache et une courte barbiche. Son armure est le tosei gusoku, un harnais de l'ère Sengoku : des plaques de fer laquées lacées en rangées horizontales par des cordons de soie, le plastron et les plaques de jupe liés par des bandes alternées de bleu foncé et de vermillon. Les épaulières sont suspendues en plaques lacées identiques sur chaque bras. Par-dessus, il porte un manteau de combat sans manches de couleur fauve, ses panneaux avant ouverts pour révéler le plastron lacé en dessous. Une large ceinture rouge est nouée à sa taille, une épée y étant glissée tranchant vers le haut ; à son côté droit pend une seconde épée, sa main droite sur la garde. Ensemble, ils forment le daisho, la paire de longs et courts sabres portés par chaque samouraï. S'élevant derrière son épaule droite, portés en travers de son dos, la longue crosse sombre et le mince canon d'un tanegashima, l'arme à mèche dont l'adoption massive est le fait dont Nobunaga reste célèbre. Il se tient seul dans un pays ouvert, seuls l'herbe, les pierres et les montagnes lointaines autour de lui."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "Sejong le Grand, quatrième roi de la dynastie Joseon, est assis au centre d'une estrade en bois surélevée dans la salle du trône, un livre ouvert tenu à deux mains sur ses genoux. Il porte un gonryongpo, une robe de dragon en soie rouge portée par les rois Joseon, la poitrine et les épaules ornées de médaillons dorés de dragons à quatre griffes et bordées de rinceaux d'or. Une large ceinture sertie de jade traverse sa taille. Sur sa tête se trouve un ikseongwan, une coiffe de gaze noire rigide avec deux petites ailes relevées s'élevant à l'arrière comme des feuilles pliées. Il est imberbe à l'exception d'une moustache sombre bien taillée et d'une courte barbe au menton. Derrière lui s'élève l'Irworobongdo, le paravent représentant le soleil, la lune et les cinq pics placé derrière chaque trône Joseon, où le roi était le soleil de la lune de la reine : un disque de lune blanc en haut à gauche, un disque de soleil rouge en haut à droite, des pics dentelés en vert profond et des pins rouge sombre s'étendant le long du registre inférieur. Le trône lui-même est laqué rouge, ses panneaux latéraux sculptés de médaillons de tigres. Des balustrades et des poteaux laqués rouges encadrent l'estrade de chaque côté ; des lanternes en papier pendent aux bords de la salle, brillant d'un jaune lumineux ; un court escalier de pierre descend vers le spectateur."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "K'inich Janaab' Pacal, K'uhul Ajaw de Bʼaakal, le Saint Seigneur de Palenque, se tient debout sur la terrasse d'un palais de calcaire dominant sa capitale en plein midi, des temples à pyramides étagées s'élevant de la jungle au-delà, leurs crêtes de toit sculptées et érodées jusqu'à un rose pâle. Derrière ses épaules s'étend un grand dorsal, un cadre en bois déployé de longues plumes de queue de quetzal en bandes de vert, de bleu et de rouge profond, monté au-dessus d'une plaque rectangulaire de glyphes sculptés et peints. Sa coiffure est haute et étagée, couronnée de plumes de quetzal supplémentaires. Ses cheveux tombent longs et sombres jusqu'à l'épaule. Un large collier de plaques de jade sculpté repose sur sa poitrine, un pectoral de jade carré pend en son centre, et des écarteurs d'oreilles en jade percent ses lobes. Une ceinture perlée rassemble une jupe de tissu noué et de plumes à la taille, des franges de longues plumes tombent de chaque côté jusqu'aux genoux, et ses sandales sont attachées haut sur le mollet. Dans sa main gauche, il tient le sceptre manikin de K'awiil, un grand bâton surmonté d'une petite tête sculptée de la divinité de la foudre dont l'effigie était tenue par les souverains mayas comme emblème de la royauté. À sa gauche, au bord de la terrasse, se dresse un large brasero de pierre dont le bord est cerclé de restes d'offrandes brûlées. La ville au-delà se perd dans la brume, pyramide après pyramide descendant en gradins vers une plaine fluviale."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "Gengis Khan, Grand Khan des Mongols, chevauche un cheval noir en pleine steppe, montré de la taille vers le haut et de trois quarts face au spectateur. Son casque est haut et conique, se terminant en pointe acérée, son bandeau sombre et ses couvre-joues encadrant une fine moustache et une petite touffe de barbe au menton. Son armure est un harnais de cavalerie mongole à rivets, la poitrine dominée par un grand umbo de bronze rond estampé d'un motif en spirale ; de larges épaulières couvrent les épaules, et des bandes clouées enserrent les bras au niveau des biceps. Une sombre cape tombe de ses épaules, sa doublure d'un violet atténué là où elle se drape derrière la selle. Le harnachement du cheval est en cuir brut, une simple bride sans rien qu'un bandeau frontal et des rênes rassemblées vers l'avant. Derrière lui, de basses collines verdoyantes ondulent sous un ciel gris pâle et couvert ; sur le versant intermédiaire se dresse un campement de gers, les tentes rondes en feutre blanc des Mongols, de pâles points de bétail épars sur l'herbe autour d'elles."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "Ahmad al-Mansur, sultan saadien du Maroc, se tient au bord d'un campement saharien sous un ciel bleu profond. Un mince croissant de lune et des étoiles éparses sont suspendus au-dessus de bas reliefs sombres à l'horizon. Il est barbu, sa peau chaude dans la lumière de la lampe, son regard horizontal tourné vers le spectateur. Il porte le vêtement en couches du Maghreb : une longue djellaba blanche, une robe à capuche descendant jusqu'aux chevilles propre à l'Afrique du Nord. Par-dessus est drapé un selham, un fin manteau de laine des princes et des souverains, son capuchon pendant dans son dos entre les omoplates. Un turban blanc est enroulé autour de sa tête. À sa poitrine pend un panneau brodé rectangulaire crème et or, à motif de géométrie entrelacée de l'ornementation islamique. Une large ceinture de rayures verticales rouges et crème est enroulée deux fois autour de sa taille et nouée à l'avant, les extrémités rentrées. Derrière lui et à gauche, une grande tente de caravane arrondie en toile rayée sombre rayonne de l'intérieur, son rabat ouvert répandant une lumière orange et chaude sur le sable ; deux chameaux se reposent sur le sable à côté. Une lumière plus petite brûle plus loin, et un groupe de palmiers dattiers se dresse contre les collines."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "Guillaume Ier, prince d'Orange, père de l'indépendance néerlandaise, se tient dans une salle carrelée éclairée par une haute fenêtre à petits carreaux de plomb à gauche, ses petites vitres en losange encadrées par de lourdes tentures rouges tirées sur le côté. Le sol est pavé de dalles de marbre noir et blanc. Derrière lui, sur le mur du fond, est accroché un tableau de paysage dans un cadre doré représentant les Pays-Bas sous un ciel lourd, une rivière sinuant à travers de plats champs verdoyants vers une ville distante. À sa droite, un tabouret en bois supporte un globe terrestre, son anneau méridien en laiton captant la lumière de la fenêtre. À sa gauche, une table à écrire recouverte d'un tissu rouge porte un livre relié en cuir ouvert et des feuilles de papier en vrac, et derrière elle se dresse une chaise à haut dossier rembourrée de bleu. Tout l'intérieur rappelle les salles d'érudits du Géographe et de l'Astronome de Vermeer, bien que Guillaume appartienne à la génération précédant ce style. C'est un homme barbu d'âge mûr, aux cheveux sombres coupés court sous un petit bonnet plat, la moustache et la barbe en pointe taillées court, une large fraise blanche plissée se déployant à son cou. Sur ses épaules pend une longue cape noire, repoussée à droite pour libérer ses bras. Son pourpoint est une soie façonnée or terne, coupée près du torse, le devant boutonné en une seule rangée. Ses hauts-de-chausses sont des trousses à panneaux, composées de longues bandes verticales de tissu rouge et blanc disposées en rayures alternées sur une doublure plus ample et s'arrêtant à mi-cuisse. Des bas sombres unis couvrent le bas des jambes et rejoignent des chaussures en cuir basses sur le sol à damier. Dans sa main droite, il tient un bâton de commandement élevé à la hauteur de la poitrine ; sa main gauche repose près de sa hanche, où une garde d'épée est tout juste visible sous le tombé de la cape."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "Soliman le Magnifique, Kanuni le Législateur, sultan des Ottomans, se tient dans le palais de Topkapi sous un dôme à nervures, une salle d'arcades en ogive revêtue de faïences d'Iznik bleues et blanches. Des faisceaux de lumière du jour tombent de fenêtres invisibles sur les colonnes de pierre claire derrière lui. Il est barbu, aux yeux sombres, sa moustache et sa barbe taillées courtes autour d'une bouche fine. Son turban est le haut kavuk rond pour lequel il était connu, un grand enroulement de tissu blanc fixé autour d'une armature conique et s'élevant bien au-dessus de son front. À son sommet se dresse un sorguç, un plumet vert qui marque le rang du sultan. Par-dessus une robe intérieure, il porte un long caftan de soie jaune tissée d'un fin réseau de vignes et de rosettes sur fond clair, le devant ouvert jusqu'à la taille. Une large bande de douce fourrure grise en borde toute la longueur, le distinguant comme une kapanice, la robe d'honneur la plus élevée. Une ceinture sombre traverse le caftan à la taille. Dans sa main droite, tenu droit contre sa poitrine, se trouve un volume relié en cuir sombre. Son autre main repose le long de son flanc. La salle derrière lui se perd dans l'ombre entre les arcades carrelées."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "Darius I le Grand, Roi des Rois de l'Empire achéménide, se tient au sommet d'un petit escalier en tête d'une grande salle, un faisceau de lumière tombant sur lui d'en haut. Il est large d'épaules et fourni d'une longue barbe taillée en carré et serrée en boucles. Sur sa tête se trouve le kidaris, la haute couronne crénelée des rois perses, un cylindre d'or cerclé de merlons carrés. Sa robe est une longue tunique jaune safran tombant jusqu'à ses pieds, ornée à la poitrine, aux poignets et à l'ourlet de broderies rouges et dorées. Une ceinture rouge la resserre à la taille. De lourds bracelets d'or enserrent chaque biceps. De chaque côté, sur des socles, se dressent deux lamassu colossaux, des taureaux ailés, leurs corps et leurs ailes repliées recouverts d'or, les figures gardiennes de la Porte de toutes les Nations à Persépolis, ici dans la version à tête humaine réduite au seul taureau. Le mur du fond est sculpté en bas-relief d'une procession de personnages en longues robes et bonnets mous, à la manière des reliefs des porteurs de tribut de l'escalier de l'Apadana. La pierre de la plateforme et des marches est d'un bleu-vert pâle, rehaussée de bossages dorés aux angles."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "Casimir III le Grand, roi de Pologne et dernier des rois Piast, se tient dans l'entrée d'un corps de garde en pierre éclairé par des appliques murales en fer dont les flammes projettent une lumière rouge-dorée et chaleureuse sur la maçonnerie. Il est large d'épaules et porte une barbe fournie, la barbe sombre et taillée ras, le regard horizontal. Sa couronne est un cercle arqué en or serti de pierres rouges, ses arceaux se fermant au-dessus en un épi serti de joyaux. Autour de ses épaules est posée une large palatine d'hermine blanche, la fourrure travaillée avec de petites touffes noires au bout de la queue. En dessous, son manteau est une longue robe cramoisie boutonnée sur la poitrine en une rangée de petits clous dorés et ceinturée à la taille d'une large ceinture dorée. Dans une main il tient un sceptre d'or dressé devant sa poitrine ; à sa hanche pend Szczerbiec, l'épée d'État des Piast. De chaque côté de lui, de lourdes chaînes en fer descendent de l'obscurité du haut le long des faces intérieures du corps de garde. Derrière lui, encastré dans l'archivolt au fond de la chambre, un panneau rouge porte l'Aigle blanc couronné de Pologne, les ailes déployées. L'aigle est rendu en silhouette sombre sur le champ rouge plutôt qu'en l'argent habituel. La pierre est massive et bien ajustée, la lumière se concentrant sur le roi et s'éteignant brusquement dans les voûtes ombrées de chaque côté."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "Kamehameha le Grand, unificateur des îles hawaïennes et premier Mo'i du royaume, se tient pieds nus sur une plage de sable blanc, les eaux turquoise peu profondes d'une baie abritée derrière lui et une sombre crête boisée s'élevant au-delà. Il est grand et de forte carrure, torse nu, la peau d'un brun profond sous le soleil tropical. Sur une épaule pend un ahu'ula, une cape de plumes des ali'i hawaïens, rouge intense et tombante presque jusqu'aux chevilles. Une large ceinture du même rouge traverse sa poitrine depuis l'épaule gauche, ses bordures jaunes ornées de petits blocs géométriques rouges. Un panneau assorti de rouge et de jaune pend sur le devant de son malo, un pagne enroulé aux hanches. Sur sa tête est posé un mahiole, un casque à crête basse avec une étroite nervure longitudinale allant du front à la nuque, travaillé en rouge avec des rayures jaunes et une bande jaune à sa base. Dans sa main droite il tient une grande lance de bois à pointe barbelée ; son bras gauche pend le long de son corps. À sa droite, tirés sur le sable, gisent deux wa'a kaulua, des pirogues à double coque polynésiennes destinées aux voyages hauturiers, leurs deux coques réunies par des traverses liées. Les voiles sont triangulaires, la pointe au pied du mât et le bord supérieur incurvé vers l'extérieur en un long U ; la toile est claire et rapiécée. Une troisième pirogue mouille à l'ancre plus au large dans la baie. Sur le rivage derrière son épaule gauche se dresse une hale couverte de chaume, une maison hawaïenne à armature de poteaux et toit de graminées séchées, à demi ombragée par les palmes de cocotiers. Le ciel au-dessus de la crête est bleu avec de hauts nuages blancs."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "Maria Iere, reine du Portugal, des Algarves et des possessions portugaises au-delà des mers, se tient sur la terrasse du Palácio da Pena à Sintra, une galerie en pierre pâle sous une rangée de lourdes arcades romanes. L'Atlantique s'ouvre au-delà de leurs colonnes. Sa robe est en soie bleu profond. Le corsage est ajusté avec une taille pointue, les manches aux coudes finies par des manchettes blanches, la jupe ample sur des paniers et tombant en larges plis sur la pierre. Une courte cape rouge est fixée à ses épaules et traîne derrière elle. Sur sa poitrine court une large écharpe blanche bordée de rouge, l'écharpe de l'Ordre portugais du Christ, portée par les souverains portugais en tant que Grand Maître. Une bande d'ornements sertis de pierres précieuses est disposée sur son devant. Ses cheveux sombres sont coiffés haut, empilés au-dessus du front et fixés par une aigrette, un petit ornement noir piqué d'une plume dressée. Sa main droite repose à ses côtés sur le pommeau d'un mince sceptre dont le sombre manche tombe contre le bleu de sa jupe. À sa droite, au-delà de la balustrade, un étroit bras de mer s'étire entre des falaises rouges. Deux naus à gréement carré à voiles ferlées sont ancrés dans le chenal. À sa gauche s'élève un donjon aux murs jaunes couronné d'un dôme bulbeux de bandes dorées et carrelées. Des remparts jaunes crénelés descendent en gradins vers la terrasse où elle se tient. Le ciel est dégagé, la lumière est celle d'un brillant après-midi atlantique, et les arcades l'encadrent entre l'eau d'un côté et l'architecture royale de l'autre."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "Auguste César, premier empereur de Rome, est assis sur un siège de style curule entre deux têtes de sphinx en bronze, leurs visages lisses tournés vers l'extérieur. Il est imberbe avec des cheveux courts et sombres coiffés vers l'avant sur le front, selon la tradition de la Prima Porta. Une toga picta, une toge de cérémonie pourpre portée lors d'un triomphe romain, est drapée sur sa tunique blanche et tirée en travers des genoux puis relevée sur l'épaule gauche. L'encolure de la tunique est bordée d'or. Sa main droite repose ouverte sur l'une des têtes de sphinx ; la gauche est posée librement sur son genou. Derrière lui, une salle obscure aux murs rouge sombre est dotée de colonnes cannelées et ornée de bannières verticales rouges et dorées. Sur le mur du fond, un médaillon de bronze rond porte une tête de lion en relief. Des faisceaux de lumière du jour pâle tombent depuis la gauche sur son visage et sa poitrine, laissant le côté opposé de la salle dans l'ombre ; deux petits braseros sur des trépieds en fer de chaque côté du trône brûlent faiblement."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "Catherine II, impératrice et autocrate de toutes les Russies, se tient dans la Salle de Lumière, la Grande Salle du palais Catherine à Tsarskoïe Selo. Son corps est tourné de trois quarts vers le spectateur, son regard horizontal. Ses cheveux sombres sont relevés et coiffés haut dans la mode de la cour européenne de la fin du XVIIIe siècle. Un petit diadème serti de joyaux les retient en haut, ses pointes évoquant en miniature les hautes arcades en forme de fleur de la Grande Couronne impériale de Russie. Sa robe est une tenue de cour de soie ivoire : un corsage ajusté avec un panneau central brodé d'or courant sur le devant, des demi-manches bouffantes de bleu foncé garnies à l'épaule de bandes d'hermine blanche. Une jupe ample s'étale en dessous, brodée d'or de l'aigle bicéphale des armes impériales russes répété comme motif. De son épaule droite à sa hanche gauche court une large écharpe de moiré bleu pâle, le ruban de l'ordre de Saint-André le Premier Appelé. De hautes fenêtres arquées le long du mur de droite sont ornées de rideaux bleu pâle retenus en drapés, des rais de lumière du jour tombant en barres visibles sur un sol de marbre noir et blanc poli comme un miroir. Sur le mur de gauche, une suite de sculptures rococo dorées, en volutes et feuillages, encadre des panneaux de miroir."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "Pocatello, chef des Shoshone du Nord-Ouest, est assis sur un cairn de rochers rouges érodés au bord d'un bassin intermontagnard, une plaine d'armoise plate s'étendant derrière lui jusqu'à de bas plateaux se découpant à l'horizon sous un ciel crépusculaire de rose et de violet pâle. Il est large d'épaules, ses longs cheveux noirs séparés au centre et tombant jusqu'à la poitrine, avec une plume d'aigle dressée fixée à l'arrière de la tête. Une deuxième plume sombre s'élève derrière son épaule depuis le carquois attaché dans son dos. Un court arc en bois est passé en bandoulière aux côtés du carquois, son extrémité supérieure dépassant au-dessus de son épaule droite. Dans sa main droite, il tient une longue lance plantée côté crosse contre le rocher, le fût enveloppé de cuir et laissant pendre une sombre touffe près de la pointe. Sur son torse, il porte un gilet de fourrure, traversé par une large sangle de cuir tanné travaillée en rangées de perles allant de l'épaule droite à la hanche gauche, avec un court fourreau de couteau pendant à son extrémité inférieure. Le haut de ses bras est cerclé de bracelets d'argent superposés. De la taille aux pieds, il porte de sombres jambières en cuir frangé tombant jusqu'à la cheville, et un pagne entre elles. Sa main gauche repose ouverte sur sa cuisse ; sa posture est immobile, le poids posé sur la pierre. La lumière est basse et chaude, faisant ressortir le rouge des rochers et le tranchant de la lance, et le lointain au-delà de lui est le pays de l'armoise du Grand Bassin, la terre natale des Shoshone entre les Rocheuses et la Sierra."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "Ramkhamhaeng le Grand, roi de Sukhothaï, se tient dans un jardin de palais ensoleillé. La brume verte d'une forêt tropicale et les silhouettes pâles de chedis lointains, stupas bouddhistes en forme de cloche de Thaïlande, s'élèvent à travers une légère brume derrière lui. Il est svelte et torse nu, sa peau brun chaud, son visage légèrement tourné vers sa gauche avec un sourire ténu. Sa couronne est haute, étagée et pointue, s'élevant vers une flèche élancée : un chada, la couronne conique des rois thaïlandais. Un large pectoral doré repose sur ses épaules et sa poitrine, travaillé en repoussé à motifs de rinceaux et serti au centre d'une pierre rouge unique ; des bandes d'or plus étroites enserrent chaque bras supérieur. Une écharpe de soie blanche est enroulée et nouée à sa taille, les extrémités torsadées tombant jusqu'à ses cuisses. En dessous, il porte un pagne d'un rouge profond à motifs dorés, avec une sous-couche plus sombre visible au bord. À sa droite, au bord d'un étang calme parsemé de fleurs de lotus roses et de leurs larges feuilles plates, se dresse une petite sculpture en pierre : une tête de Bouddha sereine, les yeux baissés, posée sur un piédestal en bouton de lotus. Un sentier de sable pâle s'incurve vers sa gauche entre des massifs d'arbustes à fleurs rouges, menant vers les tours embrumées de la capitale."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "Mohammad I, Askia le Grand du Songhaï, se tient debout sur une falaise rocheuse au coucher du soleil, une longue lame posée sur l'épaule et une ville en flammes dans son dos. Il a la peau sombre, la barbe courte, les yeux fixés sur le spectateur. Sa tête est enveloppée dans un tagelmust, un turban sahélien d'un crème pâle enroulé haut et rassemblé d'un côté. Sur ses épaules tombe un long boubou cramoisi, une robe à larges manches de la noblesse ouest-africaine, dont le panneau frontal et la poitrine sont brodés de denses bandes à motifs en fil d'or et de fil sombre. En dessous, une ceinture claire est nouée autour de sa taille de façon à laisser pendre les extrémités sur la hanche, par-dessus un pantalon du même cramoisi que la robe. Il tient l'épée par sa poignée dans sa main droite et laisse la lame reposer en arrière le long de son épaule ; elle est longue, à dos droit et légèrement courbée vers la pointe. À sa droite le terrain descend vers une plaine sous un ciel rouge orangé, une sombre montagne se découpant en silhouette contre un soleil bas. À sa gauche une ville brûle : des murs de briques d'argile et un grand minaret carré hérissé de rangées de torons de bois saillants, des poutres en palmier laissées dépassant du crépi. Les flammes escaladent la tour et se répandent dans les rues en dessous ; de plus petits incendies se dispersent sur la plaine entre la ville et la falaise où il se tient."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "Isabelle Ire, reine de Castille et de León, reine consort d'Aragon, se tient dans l'une des galeries à piliers de l'Alhambra de Grenade, son arcade s'ouvrant sur un jardin de haies taillées et de topiaires en pot, des collines se fondant dans la brume au loin. De fines colonnes jumelées aux chapiteaux sculptés s'élèvent derrière elle en arcs lobés et festonnés remplis de treillis, les écoinçons au-dessus sculptés en stuc géométrique et végétal dense dans des tons d'or pâle et de sable. Elle est mince, au teint clair, les mains croisées l'une sur l'autre à la taille. Sa tête est couverte à la mode castillane de sa cour : une guimpe blanche drapée étroitement sous le menton et à travers la gorge, un voile blanc ajusté sur le haut de la tête, et au-dessus une petite couronne fermée en or sertie de pierres rouges et vertes. Sur ses épaules pend un long manteau rouge doublé et bordé d'or, s'ouvrant à l'avant. Sa robe en dessous est du brocart crème travaillé dans un sombre motif répétitif, à corsage ajusté, avec un panneau bordé d'or au centre de la jupe. Sur sa poitrine un joyau rouge est épinglé là où le manteau s'écarte. La lumière est la lumière basse et chaude d'une fin d'après-midi, accrochant le stuc de l'arcade et la pierre pâle du sol de la galerie."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "Gustavus Adolphus, Roi des Suédois, des Goths et des Wendes, le Lion du Nord, se tient debout dans une salle de palais dorée. À côté de lui, un foyer profond brûle avec des bûches fendues, bas et lumineux. Il est grand et solidement bâti, avec une barbe rousse fournie portée jusqu'à la poitrine et une moustache épaisse retroussée, ses cheveux rejetés en arrière depuis un front haut. Il porte une cuirasse en acier noirci, ciselée de bandes dorées sur les bords et le long de la crête centrale, ajustée sur un justaucorps de buffle en cuir de boeuf épais, pâle et huilé. L'armure se prolonge vers le bas par des tassettes d'acier articulées s'évasant jusqu'à mi-cuisse sur un sous-jupon jaune. Une large écharpe de soie turquoise traverse depuis son épaule droite jusqu'à sa hanche gauche, nouée et tombant en un pli lâche contre le plastron. De petits poignets de dentelle apparaissent à ses poignets, et un volant de dentelle pâle borde les culottes au-dessus de ses bottes. Il se tient le poids en retrait, chaque main gantée reposant sur un bâton de commandement planté pointe vers le bas sur le sol devant lui. Derrière lui, le manteau de la cheminée est sculpté et doré, la corniche ornée de rinceaux d'acanthe baroques. À gauche, deux tableaux à cadre doré sont accrochés contre un mur de damas vert et or. Le plus proche représente un homme barbu en armure sombre, Éric XIV, un roi de Suède antérieur. Le plus lointain représente une femme au teint pâle dans une légère robe de cour, Maria Eleonora de Brandebourg, l'épouse de Gustavus. Sous les tableaux, une table en bois sombre poli porte un plat creux en étain débordant de fruits, et un grand candélabre en laiton s'élève à l'extrémité proche de la table, ses bougies éteintes. La salle est éclairée presque entièrement par le feu. La teinte orange chaude tombe sur la cuirasse, les stucs dorés et le côté droit de son visage, laissant le mur du fond dans l'ombre."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "Enrico Dandolo, doge de la Très Sérénissime République de Venise, se tient sur un pont de pierre au-dessus d'un canal de nuit, une main gantée ramenée contre sa poitrine. Il est vieux : une longue barbe grise tombe jusqu'à sa poitrine, des cheveux gris apparaissent à ses tempes, et son visage est profondément ridé. Sur sa tête repose le corno ducale, un bonnet ducal rigide en forme de corne en brocard rouge rouille s'élevant en pointe émoussée à l'arrière comme un bonnet phrygien, porté ici par-dessus un camauro de lin blanc ajusté dont le bord apparaît en dessous au niveau du front. Sur ses épaules repose un lourd manteau gris bordé de fourrure pâle, tombant ouvert sur le devant et doublé du même rouge rouille que le bonnet. En dessous, il porte une longue robe de brocard rouge profond ceinte à la taille par un cordon d'or noué. La balustrade du pont est en fer forgé, ses panneaux garnis d'arcs ogivaux élancés dans le style gothique vénitien. Derrière lui, le canal s'enfonce dans l'obscurité, flanqué de palazzi dont les fenêtres brillent d'un orange chaud contre la nuit bleue. Une gondole étroite est amarrée au quai à gauche, le ciel étoilé perçant les nuages au-dessus des toits."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "Shaka kaSenzangakhona, roi des Zoulous, se tient debout sur la terre libre d'un kraal royal, les pieds fermement plantés, le bouclier tenu à sa gauche et la courte lance à sa droite. Il est torse nu, la peau sombre et musclé, le torse barré de minces cordons enfilés de petites perles. Autour de sa tête est noué un umqhele, un épais bandeau circulaire en fourrure de léopard tacheté marquant le rang royal et la haute ancienneté. Fixé à hauteur du front se dresse un plumet vertical de plumes blanches dont les pointes sont rouges. À sa taille pend un tablier de peau de léopard retombant sur les hanches, et en dessous une frange de longs pompons de fourrure claire se balance contre ses cuisses. Des bandes de la même fourrure tachetée cerclent ses chevilles. Dans sa main gauche il porte un isihlangu, un grand bouclier de guerre ovale et pointu en cuir de boeuf ; sa surface est mouchetée de brun et de blanc, un bâton de bois droit courant le long de son centre et maintenu par des boucles de cuir. Dans sa main droite, tenue basse et prête, se trouve un iklwa, une lance d'estoc à manche court avec une longue lame large en forme de feuille. Derrière lui s'incurve une rangée d'iqukwane, des huttes en dôme de chaume et d'herbe en forme de ruches d'un umuzi zoulou, leurs surfaces tressées accrochant le soleil. De chaque côté de la clairière s'élèvent des poteaux de bois couronnés des crânes de boeufs à longues cornes, les grandes cornes courbées encore attachées, richesse et sacrifice exposés à l'entrée. Le sol est une terre sèche et pâle, une mesa au sommet plat se distingue dans le lointain, et le ciel au-dessus est d'un bleu pâle et limpide strié de fins nuages."

-- Economic Overview (F2 / Domestic Advisor): tab names, column labels,
-- group / row text consumed by CivVAccess_EconomicOverviewAccess.lua.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "Villes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "Or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "Bonheur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "Ressources"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "Population"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "Force"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "Nourriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "Science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "Or"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "Culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "Foi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "Production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "capitale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "vassale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "occupée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "occupée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "aucune entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "aucune production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    one = "{1_Turns} tour : {2_Name}",
    other = "{1_Turns} tours : {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "{1_PerTurn} par tour, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "Or total, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "Revenus, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "Dépenses, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "Net par tour, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "Science perdue par déficit, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "Villes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "Diplomatie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "Religion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "Connexions urbaines, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "Unités, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "Bâtiments, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "Améliorations, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "Diplomatie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "Bonheur total, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "Sources de bonheur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "Luxes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "Variété de luxes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "Bonus des luxes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "Autres bonus de luxe, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "Bonheur des villes, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "Bâtiments, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "Bonheur des bâtiments, garnisons, religion et synergies politiques dans chaque ville. "
    .. "Plafonné à la population de la ville."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "Bonus de merveille, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "Bonheur des merveilles à effets spéciaux : synergies de classes de bâtiment, "
    .. "bonheur non modifié, ou bonus par politique. La plupart des bâtiments à bonheur "
    .. "alimentent Bâtiments (par ville) ci-dessus, pas cette ligne."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "Bonus à l'échelle de l'empire, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "Routes commerciales, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "Cités-États, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "Politiques, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "Religion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "Merveilles naturelles, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "Bonus par ville, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "Bonheur des bâtiments ou politiques qui accordent un montant fixe par ville possédée. "
    .. "Multiplié par votre nombre de villes."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "Congrès mondial, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "Niveau de difficulté, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "Mécontentement total, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "Sources de mécontentement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    one = "{1_Count} ville, mécontentement {2_Value}",
    other = "{1_Count} villes, mécontentement {2_Value}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    one = "{1_Count} ville occupée, mécontentement {2_Value}",
    other = "{1_Count} villes occupées, mécontentement {2_Value}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    one = "{1_Count} citoyen, mécontentement {2_Value}",
    other = "{1_Count} citoyens, mécontentement {2_Value}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    one = "{1_Count} citoyen occupé, mécontentement {2_Value}",
    other = "{1_Count} citoyens occupés, mécontentement {2_Value}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "Opinion publique, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "Détail par ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "Disponibles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "Utilisées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "Locales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "Importées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "Exportées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "s/o"
-- Victory Progress (F8 / Who is winning): two-tab layout. Tab 1 is the
-- score table (one row per civ, columns from DiploList's score-breakdown
-- tooltip); Tab 2 is the victory-conditions menu (Time, Domination,
-- Science, Diplomatic, Cultural). Score column headers reuse engine
-- TXT_KEY_VP_CITIES / _POPULATION / _LAND / _WONDERS / _TECH /
-- _FUTURE_TECH / _POLICIES / _GREAT_WORKS / _RELIGION / _SCENARIO1-4
-- so only the Total header and row-state suffix are mod-authored.
-- Disabled-victory and tooltip sentence strings reuse engine TXT_KEY_VP_*
-- keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "Score"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "Victoires"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "Total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, capitale perdue"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "Domination"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "Science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "Diplomatique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "Culturelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "équipe {1_Num}"
-- Plural driven by {1_Num} (count of boosters built for the spaceship,
-- vanilla allows up to 3).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    one = "{1_Num} booster",
    other = "{1_Num} boosters",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "cockpit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "chambre de stase"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "moteur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, Apollo non construit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, Apollo construit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "Apollo construit, aucune pièce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, Apollo construit, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "Apollo construit, {1_Parts}"
-- Plural is driven by {2_Total}: "1 of 1 prerequisite researched" vs
-- "1 of 5 prerequisites researched".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    one = "{1_Have} sur {2_Total} prérequis recherché",
    other = "{1_Have} sur {2_Total} prérequis recherchés",
}
-- Demographics (F9): one row per metric, speaking name, rank, the active
-- player's value, then rival best (with civ name), average, and worst
-- (with civ name) -- vanilla column order. Metric name and unmet-civ /
-- "you of <Civ>" fillers reuse engine TXT_KEYs so the format key stays
-- pure positional substitution.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, rang {2_Rank}, {3_Value}, meilleur {4_BestCiv} {5_BestVal}, moyenne {6_AvgVal}, pire {7_WorstCiv} {8_WorstVal}"
-- Vanilla's TXT_KEY_DEMOGRAPHICS_GOLD label is "GNP", which spells out
-- letter-by-letter in TTS and tells a non-economist nothing. Mod-authored
-- override only -- the engine label stays "GNP" for sighted players.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "Produit national brut"
-- Culture Overview (Ctrl+C). Four-tab popup: Your Culture (per-city GW
-- management with click-to-move/view toggle), Swap Great Works (designate
-- swappable + foreign-offerings list + send), Culture Victory (per-civ
-- influence/tourism/ideology/public-opinion), Player Influence
-- (perspective picker + per-target modifier breakdown / level / trend).
-- Most enum-derived strings (influence levels, trend, public opinion)
-- reuse engine TXT_KEY_CO_* keys directly so phrasing matches what
-- sighted players see; mod-authored keys here only cover row formats,
-- action labels, and our drill-in framing.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "Votre culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "Échanger des chefs-d'oeuvre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "Victoire culturelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "Influence du joueur"
-- Tab 1 (Your Culture).
-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] = "Sites d'antiquité : {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HIDDEN_SITES"] = "Sites d'antiquité cachés : {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    one = "{1_Name}, culture {2_Cul}, tourisme {3_Tou}, chef-d'oeuvre {4_Filled} sur {5_Total}",
    other = "{1_Name}, culture {2_Cul}, tourisme {3_Tou}, chefs-d'oeuvre {4_Filled} sur {5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    one = "{1_Name}, culture {2_Cul}, tourisme {3_Tou}, chef-d'oeuvre {4_Filled} sur {5_Total}, endommagé {6_Pct} pour cent",
    other = "{1_Name}, culture {2_Cul}, tourisme {3_Tou}, chefs-d'oeuvre {4_Filled} sur {5_Total}, endommagé {6_Pct} pour cent",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "capitale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "vassale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "occupée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "Aucun bâtiment de chef-d'oeuvre pour l'instant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "Aucune ville"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "emplacement d'écriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "emplacement d'art ou d'artefact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "emplacement de musique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled} sur {4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled} sur {4_Total}, bonus thématique plus {5_Bonus}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, vide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, vide"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "écriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "art"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "artefact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "musique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class} de {2_Artist}, {3_OriginCiv}, {4_Era}, plus {5_Cul} culture, plus {6_Tou} tourisme"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "de {1_Artist}, {2_OriginCiv}, {3_Era}, plus {4_Cul} culture, plus {5_Tou} tourisme"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, plus {4_Cul} culture, plus {5_Tou} tourisme"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "marqué comme source de déplacement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "déplacé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "source de déplacement annulée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] =
    "type d'emplacement incorrect pour la source actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "impossible de déplacer depuis un emplacement vide"
-- Tab 2 (Swap Great Works). Three top-level rows: your offerings (drills
-- into per-type pulldowns), available from other civs (drills into civ
-- groups, then into each civ's non-empty slots), trade item with state-
-- aware label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "Vos offres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type} : {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "Ecriture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "Art"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "Artefact"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "aucun désigné"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "Effacer la désignation"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "Disponible auprès d'autres civilisations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type} : {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "Aucune civilisation ne propose d'oeuvres échangeables"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "Aucune oeuvre échangeable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] =
    "Choisissez une oeuvre d'une autre civilisation a échanger"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "Aucun {1_Type} désigné a offrir pour {2_TheirName} de {3_TheirCiv} ; désignez-en un dans vos offres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "Échanger votre {1_YourName} contre {2_TheirName} de {3_TheirCiv}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "échange envoyé"
-- Tab 3 (Culture Victory). Per-civ row + drill-in detail.
-- VICTORY_ROW placeholders: {1_Civ} civ short name; {2_Influenced} a count
-- like "3 of 7" of cities you've reached the influential level on (uses
-- VICTORY_INFLUENCED_OF below); {3_Tou} tourism per turn integer;
-- {4_Ideology} the ideology name (Freedom / Order / Autocracy) or NO_IDEOLOGY;
-- {5_Opinion} the public-opinion enum word from engine TXT_KEY_CO_OPINION_*
-- (Content / Dissent / Revolt) or OPINION_NA; {6_Unhappy} integer unhappiness
-- their civ's ideology pressure imposes on you; {7_Happy} integer excess
-- happiness your civ holds (the cushion against {6_Unhappy}).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_ROW"] =
    "{1_Civ}, {2_Influenced} influencé, tourisme {3_Tou}, {4_Ideology}, {5_Opinion}, {6_Unhappy} mécontentement, {7_Happy} bonheur excédentaire"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N} sur {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "pas d'idéologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "pas d'opinion publique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_DETAIL"] = "Détail de l'opinion publique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_UNHAPPY_DETAIL"] =
    "Détail du mécontentement lié à l'opinion publique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY_DETAIL"] =
    "Pas encore d'idéologie, pas d'opinion publique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_CIVS"] = "Aucune grande civilisation rencontrée"
-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE"] = "Perspective : {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TOURISM"] = "Tourisme par tour : {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_ROW"] =
    "{1_Civ}, influence : {2_Level}, {3_Pct} pour cent, {4_PerTurn} tourisme par tour"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    one = "environ {1_N} tour avant l'influence dominante",
    other = "environ {1_N} tours avant l'influence dominante",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_BAR_YOURS"] = "votre tourisme sur eux : {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_BAR_THEIRS"] = "leur culture cumulée : {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NO_TARGETS"] = "Aucune civilisation avec des niveaux d'influence"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIERS_LABEL"] = "Modificateur de tourisme {1_N} pour cent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Contrôle plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "Ouvrir l'aperçu culturel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] = "L'aperçu culturel est désactivé dans cette partie"
-- League Overview (World Congress / United Nations). TabbedShell over the
-- engine's BUTTONPOPUP_LEAGUE_OVERVIEW: tab 1 status / members, tab 2 current
-- proposals (View / Propose / Vote modes), tab 3 ongoing effects.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "Congrès mondial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Contrôle plus L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "Ouvrir l'aperçu du Congrès mondial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "Statut"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "Propositions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "Effets"
-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "Renommer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(vous)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "hôte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    one = "{1_N} délégué",
    other = "{1_N} délégués",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "peut proposer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "Diplomate dans leur capitale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "Pas de Congrès mondial"
-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "Aucune action disponible cette session."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    one = "{1_N} proposition disponible.",
    other = "{1_N} propositions disponibles.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    one = "{1_N} délégué restant.",
    other = "{1_N} délégués restants.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "Aucune proposition cette session."
-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "Promulguer : {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "Abroger : {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "Proposé par {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "Proposé par vous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "En attente"
-- Vote-state suffix appended to proposal row in Vote mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "votre vote : {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "abstention"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    one = "{1_N} Pour",
    other = "{1_N} Pour",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    one = "{1_N} Contre",
    other = "{1_N} Contre",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} pour {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "Emplacement de proposition vide {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "Emplacement {1_N} : {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "Emplacement de proposition {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "Résolutions actives a abroger"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "Résolutions a proposer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "Autres résolutions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_THIS"] = "Proposer cette résolution"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_THIS"] = "Abroger cette résolution"
-- Religion Overview. TabbedShell over the engine's BUTTONPOPUP_RELIGION_OVERVIEW:
-- tab 1 Your Religion (status / beliefs / faith / great people / auto-purchase),
-- tab 2 World Religions (one row per founded religion plus OVERALL STATUS footer),
-- tab 3 Beliefs (one Group per religion / pantheon, drilling into beliefs).
-- Screen title and tab names reuse engine TXT_KEY_RELIGION_OVERVIEW and
-- TXT_KEY_RO_TAB_*; only the hotkey-help pair and the world-row composition
-- have no engine equivalent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Contrôle plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "Ouvrir l'aperçu des religions"
-- Forme étiquette « Religion fondée par vous : X » plutôt que phrase verbale
-- pour contourner l'absence de sélecteur de genre/élision dans nos chaînes :
-- « fondateur de Christianisme » est agrammatical (il faudrait « du
-- Christianisme » / « de l'Islam »), mais nos clés contournent Locale et ne
-- déclenchent pas le sélecteur {@1: gender ...} du moteur. La forme
-- deux-points reste correcte quel que soit le nom (par défaut ou personnalisé).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "Religion fondée par vous : {1_Religion}"
-- Mot de type de croyance puis le mot « croyance » pour désambiguïser la
-- ligne. Le mot du moteur ({1_Type}) varie en nombre et en genre
-- (« Fondateur » masc. sing., « Adeptes » masc. plur., « Panthéon »,
-- « Développement », « Réforme »), donc une apposition par virgule -- qui
-- ne demande aucun accord -- vaut mieux qu'une construction génitive
-- (« croyance du fondateur » / « croyance des adeptes ») qui exigerait
-- des cas séparés par type.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "{1_Type}, croyance"
-- Composition de la ligne d'une religion mondiale. Le nom de la religion
-- mène ; ville sainte et fondateur suivent comme étiquettes apposées ;
-- le nombre de villes adeptes en queue est la statistique propre à la
-- religion (« Christianisme, ..., 12 villes ») que les joueurs voyants
-- lisent dans la ligne du moteur. La ligne est aussi un groupe explorable
-- dont les enfants sont les villes adeptes -- le nombre est calculé sur
-- toutes les civilisations (Game.GetNumCitiesFollowing), pas un compteur
-- du contenu de la liste explorable, donc il reste.
-- « fondateur {Civ} » plutôt que « fondée par {Civ} » : le participe passé
-- exigerait l'accord avec la religion (« Christianisme... fondé » masc.,
-- « Religion X... fondée » fém.), mais le genre des noms de religion
-- personnalisés est indéterminé. Le nom-étiquette esquive l'accord.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    one = "{1_Religion}, ville sainte {2_HolyCity}, fondateur {3_Founder}, {4_NumCities} ville",
    other = "{1_Religion}, ville sainte {2_HolyCity}, fondateur {3_Founder}, {4_NumCities} villes",
}
-- Espionage Overview (BNW only). TabbedShell over the engine's
-- BUTTONPOPUP_ESPIONAGE_OVERVIEW: tab 1 agents (flat list, drill in for
-- actions), tab 2 cities (Your / Their groups, drill in for per-column
-- detail with engine tooltips), tab 3 intrigue messages. Screen title and
-- the Your / Their / Agents / View / Coup / Relocate row labels reuse
-- engine TXT_KEY_EO_* keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Contrôle plus E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "Ouvrir l'aperçu de l'espionnage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "Agents"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "Villes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "Intrigues"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "L'espionnage est désactivé dans cette partie"
-- Agent row. {1_Rank} is the engine's tier name (Recruit, Agent, Special
-- Agent, ...); {2_Name} is the spy's proper name; {3_Where} is either a
-- city name (when stationed) or the engine's "in your hideout" / "in
-- transit" phrase; {4_Activity} is the current mission verb from the
-- engine (e.g. "establishing surveillance", "stealing technology",
-- "rigging election"). The _TURNS variant adds the time remaining.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    one = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} tour",
    other = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} tours",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} tué au combat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", diplomate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "Actions de {1_Rank} {2_Name}"
-- City row pieces. Civ + city + potential + population + spy clause.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "civilisation {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "ville {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "population {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "potentiel {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "potentiel de base {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "détail : {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "potentiel inconnu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] = "cité-État, élection manipulable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] =
    "cité-État, manipulation d'élection en cours"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "agent {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "diplomate {1_Name}"
-- Intrigue row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "Tour {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "de votre espion {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "partagé par {1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "inconnu"
-- Move-agent sub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "Déplacer {1_Rank} {2_Name}"

-- Bookmarks: per-session digit-keyed cursor positions. Ctrl + 1-0 saves
-- the cursor cell, Shift + 1-0 jumps there (with scanner backspace return),
-- Alt + 1-0 speaks distance and direction (and capital-relative coord when
-- the scanner coord setting is on -- so empty / saved direction / coord
-- fragments stay byte-identical with the scanner's End readout).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "signet ajouté"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "aucun signet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Contrôle plus une touche numérique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] =
    "Enregistrer un signet au curseur dans l'emplacement correspondant"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Maj plus une touche numérique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "Déplacer le curseur vers le signet de cet emplacement, retour arrière pour revenir"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt plus une touche numérique"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "Distance et direction du curseur vers le signet de cet emplacement"

-- Message buffer: scrollable history of speech-worthy events
-- (notifications, reveals, foreign-unit-watch lines, combat resolutions).
-- [ / ] step within the active filter; Ctrl+ jumps to ends; Shift+ cycles
-- the filter category and re-anchors at the newest matching entry.
-- Filter labels lead the announcement on Shift+, comma-joined to the
-- newest matching entry. Walking off either end of the buffer re-speaks
-- the current entry rather than announcing a separate edge marker, so
-- only the "no messages" key remains for the empty-buffer case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "Tous les messages"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "Notifications"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "Découvertes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "Combat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "Discussion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "aucun message"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "Crochet gauche et crochet droit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "Message précédent et suivant dans le tampon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] = "Contrôle plus crochet gauche et crochet droit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] =
    "Message le plus ancien et le plus récent dans le tampon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] = "Maj plus crochet gauche et crochet droit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "Changer de catégorie de filtre, en ignorant les catégories vides"

-- Multiplayer chat. Backslash toggles a two-tab BaseMenu over DiploCorner's
-- existing chat panel: Messages reads civvaccess_shared._inGameChatLog
-- (newest-first), Compose wraps Controls.ChatEntry as a Textfield committed
-- via base's SendChat. Single-player no-ops with a spoken marker. Chat
-- target types (all / team / whisper) format the inline announce and the
-- MessageBuffer "chat" entries so the user can tell whom a message went to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Antislash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] =
    "Ouvrir le panneau de discussion multijoueur, sans effet en solo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "La discussion est réservée au multijoueur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "Discussion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "Messages"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "Rédiger"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "Message"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "Aucun message de discussion"
-- {1_Name} sender, {2_Text} message body. Same shape used for the inline
-- speech announce, the MessageBuffer "chat" category entry, and the
-- Messages-tab list item, so the user hears one consistent line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name} : {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} à l'équipe : {2_Text}"
-- {2_To} recipient name (or "you" when the local player is the target).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} à {2_To} : {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "Antislash ou Échap"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "Fermer le panneau de discussion"

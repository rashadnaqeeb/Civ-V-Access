-- Mod-authored strings, es_ES overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- Batch 1 (lines 123-421): translates TXT_KEY_CIVVACCESS_BOOT_INGAME through TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER.

-- Spoken once, after the in-game Boot Lua finishes installing handlers, so
-- the user knows the mod attached.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "Accesibilidad de Civilization V cargada en partida."
-- Hotseat-mute toggle (Ctrl+Shift+F12). The pause announcement speaks
-- before the flag flips so the screen reader hears it; the resume speaks
-- after the flag clears so SpeechPipeline's gate doesn't swallow it.
-- Mirrored in the FrontEnd strings file because InputRouter routes both
-- front-end and in-game dispatch.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "mod en pausa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "mod reanudado"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "recomendación: {1_Name}"
-- Settler recs have no per-build name (unlike worker recs, which reuse
-- the build's Description); every settler-rec plot groups under this
-- label as one item with many instances. Used by the scanner category
-- and by the cursor glance section, so it lives in the shared InGame
-- strings file rather than the scanner-only strings file.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "Lugar para ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "embarcado {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} PV"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} movimientos"
-- Cargo / stationed aircraft count. Speaks the same X/Y the carrier and
-- city-flag dropdowns show in UnitFlagManager. "Aircraft" matches the
-- game's TXT_KEY_STATIONED_AIRCRAFT noun, which covers fighters, bombers,
-- and missiles (all DOMAIN_AIR). Carrier sites speak the token whenever
-- the unit has cargo capacity (so empty carriers still announce 0/3);
-- city sites suppress when X is 0 to avoid spamming every city.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} aviones"
-- Trailing token on the unit info line when the unit has earned enough
-- experience to take a new promotion (CanPromote is true).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "ascenso disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    one = "{1_What} {2_Turns} turno",
    other = "{1_What} {2_Turns} turnos",
}
-- Spoken when a unit is mid-execution on ACTIVITY_MISSION. For a selectable
-- player-controlled unit the cascade falls through to this rung only for
-- multi-turn movement missions (MISSION_MOVE_TO / MISSION_ROUTE_TO) -- build
-- missions get caught by the build rung above, automated units by the
-- automate rung, and one-shot missions (attack, embark, found, airstrike,
-- etc.) resolve within the turn and never reach selection. The Lua API does
-- not expose mission type or destination plot, so we cannot say where.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "movimiento en cola"
-- Engine-fork form of the queued rung: when WaypointsCore can compute
-- per-leg chunks for the head-selected unit's queued action, the rung
-- becomes one or more chunks joined by "then", followed by ", arrive"
-- once at the end. A pure-move queue produces a single move chunk
-- ("queued move, 3 turns: 1ne, then 2e, then 1ne, arrive"); a pure
-- route-to queue produces a single route chunk with the localized route
-- name ("queued road, 9 turns: 1e, then 1e, then 1e, arrive"); a
-- mixed queue (rare -- requires deliberate interface-mode switching by
-- the player) joins chunks with the same "then" the segments use.
-- Segments come pre-joined as {1_Segments} so a translation can change
-- the segment separator independent of the joiner.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_MOVE_CHUNK"] = {
    one = "movimiento en cola, {2_Turns} turno: {1_Segments}",
    other = "movimiento en cola, {2_Turns} turnos: {1_Segments}",
}
-- Route-to chunk: {3_RouteName} is the lowercased route the worker will
-- lay ("road", "railroad", or a modded route's localized name), and
-- {2_Turns} is the summed build-turns across tiles that still need
-- work. Walked-through tiles (already at the target route tier) don't
-- appear as their own segments -- their direction folds into the next
-- build stop -- so {1_Segments} always lists real build pauses only.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_ROUTE_CHUNK"] = {
    one = "{3_RouteName} en cola, {2_Turns} turno: {1_Segments}",
    other = "{3_RouteName} en cola, {2_Turns} turnos: {1_Segments}",
}
-- Joiner inserted between successive direction segments inside a chunk
-- and between successive chunks in a mixed queue. Each "then" marks the
-- next thing the unit will do; chunk boundaries differ from segment
-- boundaries only in that they restart the label / turn count.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO_JOINER"] = ", luego "
-- Trailing tag on the queued rung, appended once at the very end of the
-- composed chunk list. Marks the final stop as the arrival point so the
-- player can hear the queue terminate rather than guess from a missing
-- "then".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_ARRIVE"] = ", llegar"
-- Leading "here" segment used when a worker is actively building a
-- route tile that's also the head of its queued route-to. The build
-- and queued rungs fold into one announcement -- "queued road, 9 turns:
-- 3 turns here, then 2e, then 1e, arrive" -- with this template
-- carrying the current build's remaining turn count as the first
-- segment. The rest of the route's segments stay plain direction
-- strings (the user already opted out of per-tile turn counts for
-- queued tiles); the current-tile time is surfaced because it's the
-- one tile being actively worked, so its remaining turns are
-- actionable ("when will the worker move").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_HERE"] = {
    one = "{1_Turns} turno aquí",
    other = "{1_Turns} turnos aquí",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} cuerpo a cuerpo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} a distancia, alcance {2_Range}"
-- Enemy form of ranged strength: range distance is hidden to match base
-- EnemyUnitPanel.lua, which shows strength but omits the range tile count.
-- Also reused for friendly aircraft so the range tile count isn't said
-- twice -- aircraft surface range alongside rebase range in their own
-- token, see TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} a distancia"
-- Aircraft replacement for the moves fraction. Strike range is GetRange();
-- rebase range is strike range * AIR_UNIT_REBASE_RANGE_MULTIPLIER / 100
-- (engine default 200, so rebase = strike * 2). Mirrors base UnitPanel.lua's
-- DOMAIN_AIR branch which swaps the movement stat for the strike range and
-- surfaces the strike/rebase pair in the tooltip via TXT_KEY_UPANEL_UNIT_MAY_STRIKE_REBASE.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "alcance {1_Strike}, alcance de cambio de base {2_Rebase}"
-- Spoken on a friendly combat unit that has used its per-turn attack budget
-- (1 attack, or 2 with Blitz) but still has movement points. The actionable
-- distinction is "you have moves but can't strike with them, only reposition";
-- a 0-moves unit can't attack regardless, so the moves fraction already
-- conveys the answer and this token suppresses to avoid repeating it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "sin ataques"
-- Aircraft "done for the turn" signal. Every aircraft action (strike,
-- rebase, sweep) ends in CvUnit::finishMoves so MovesLeft == 0 is the
-- reliable "no active actions left this turn" state -- interception is
-- still possible, but the player can't initiate anything else. Friendly
-- aircraft only; non-aircraft already convey this via the moves fraction
-- and the engine doesn't expose foreign aircraft moves on the unit flag.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "sin movimientos"
-- Enemy HP speaks as a color band instead of an exact fraction. The band
-- thresholds mirror UnitFlagManager.lua:412 so blind players hear what
-- sighted players see on the unit flag: over 66% green, over 33% yellow,
-- else red. At 100% the game hides the bar; we speak "full" so the HP
-- slot is always present in the info line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "PV {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "verde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "amarillo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "rojo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "lleno"
-- Unit info-line tokens. Spoken in the cursor's tile glance and on the
-- "/" info-dump key. Level / XP and upgrade-cost are surfaced because the
-- sighted UI pairs them with icons that get stripped; promotions list
-- joins all earned promotion names. The MOVED_TO and STOPPED_SHORT pairs
-- are post-move feedback after a single Alt+key step: MOVED_TO speaks the
-- remaining moves left after a successful step, STOPPED_SHORT fires when
-- the path was longer than the budget allowed.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "nivel {1_Lvl}, {2_Cur}/{3_Next} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "mejorar a {1_Name}, {2_Gold} oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "ascensos: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    one = "movido, {1_Num} movimiento restante",
    other = "movido, {1_Num} movimientos restantes",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "detenido antes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    one = "detenido antes, {1_Num} turno hasta llegar",
    other = "detenido antes, {1_Num} turnos hasta llegar",
}
-- Generic "the action you tried did not happen" tail spoken when an Alt+key
-- attempt completes without effect (engine refused but did not fire a
-- specific reason). QUEUED_NEXT_TURN fires when shift+enter on a path
-- successfully appends the leg but the unit is already out of moves so the
-- mission won't actually start until the next turn.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "acción fallida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "en cola para el siguiente turno"
-- Alt+QAZEDC prechecks. Spoken before the combat preview / move commit
-- when the engine would refuse the action so the user hears a specific
-- reason instead of waiting for the generic timeout.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "unidad a distancia, usa ataque a distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "unidad aérea, usa ataque a distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "no puede atacar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "sin ataques"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "sin movimientos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "los aviones no se pueden mover así, usa cambio de base"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "no es adyacente"
-- Target-specific attack refusals. Spoken when the unit could attack in
-- principle (preflightAttack passes) but the engine would refuse this
-- specific target. CITY_ATTACK_ONLY covers Battering Ram and other units
-- with PROMOTION_ONLY_ATTACKS_CITIES; NAVAL_VS_LAND covers naval melee
-- (Trireme, Caravel, Ironclad, etc.) against a land tile -- naval melee
-- can capture coastal cities but cannot strike land units on land tiles.
-- CANT_ATTACK_TARGET is the generic fallback for engine refusals not
-- covered by the specific drills (combat-limit reached, only-defensive
-- advancing into a city, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "solo ataca ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "unidad naval no puede atacar tierra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "no puede atacar este objetivo"
-- Empty-state tokens spoken when a unit-related key fires with nothing to
-- act on: NO_UNITS when the active player owns zero selectable units,
-- NO_ACTIONS when the unit-action menu has no entries to show.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "sin unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "sin acciones"
-- Suffix appended to action / move announcements when committing the action
-- would trigger a war declaration with the target's owner. Spoken before
-- the final confirm so the user can cancel.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "declarará la guerra"
-- Display names for the in-place menus pushed by Tab and Enter on the hex
-- cursor. UNIT_MENU_NAME is the unit-action menu pushed by Tab on a
-- selected unit; CURSOR_ACTIVATE_MENU_NAME is the multi-target menu pushed
-- by Enter on a tile holding more than one activatable thing. The two
-- _MENU_PROMOTIONS / _BUILDS labels are sub-menu group names within those
-- menus.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Acciones de unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "Activar casilla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Ascensos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Construir mejoras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE_WITH_REASON"] = "no disponible, {1_BuildName}, {2_Reason}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE"] = "no disponible, {1_BuildName}"
-- Spoken on entering a target-picker mode (ranged attack, paradrop, etc.)
-- as the audible confirmation that the cursor's keys are now picking a
-- target rather than navigating freely.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "modo objetivo"
-- Confirms when shift+enter appends a leg to the unit's mission queue.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "en cola"
-- Spoken when shift+enter is pressed in a non-queueable mode (melee
-- attack). The engine has no queued-attack semantics that resolve into
-- meaningful gameplay -- a queued attack pushes the mission and resolves
-- on the same turn the queue head reaches it, but we have no
-- pre-snapshot for the eventual combat -- so we reject.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "no se puede poner en cola el ataque"
-- Entradas de ayuda compartidas por todos los selectores de objetivo.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_PREVIEW"] = "Espacio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_PREVIEW"] =
    "Vista previa de la acción contra la casilla objetivo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_COMMIT"] = "Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_COMMIT"] = "Confirmar la acción contra la casilla objetivo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_QUEUE"] = "Mayúsculas mas intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_QUEUE"] =
    "Poner la acción en la lista de misiones de la unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_CANCEL"] = "Cancelar modo objetivo"
-- Generic "the action was abandoned" feedback. Spoken when a target-picker
-- or popup is dismissed with Escape; consumed by code paths that need to
-- speak any single word but for which "canceled" is the audible default.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "cancelado"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "fuera de alcance"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} contra {3_TheirStr}, {4_Result}, {5_DmgToMe} de daño a mí, {6_DmgToThem} a ellos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "fuego de apoyo {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "probabilidad de captura {1_Pct} por ciento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "mis bonificaciones {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "sus bonificaciones {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "más {1_N} por ciento {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "menos {1_N} por ciento {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} contra {3_TheirStr}, {4_Result}, {5_DmgToThem} de daño a ellos"
-- City-defender preview variants. Cities don't surface a combat
-- prediction (the engine's CombatPrediction is unit-vs-unit only) and
-- the modifier breakdowns are different enough that we drop them rather
-- than mislead. Damage numbers are still computed via the engine's own
-- GetCombatDamage with the city flags set, so they match what the
-- sighted EnemyUnitPanel reports.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "ciudad {1_Name}, {2_MyStr} contra {3_TheirStr}, {4_DmgToMe} de daño a mí, {5_DmgToThem} a ellos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "ciudad {1_Name}, {2_MyStr} contra {3_TheirStr}, {4_DmgToThem} de daño a ellos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} a mí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    one = "{1_N} interceptor",
    other = "{1_N} interceptores",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "mover hacia {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} PM, {2_Left} sin gastar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    one = "{1_MP} PM, {2_Turns} turno, {3_Left} sin gastar",
    other = "{1_MP} PM, {2_Turns} turnos, {3_Left} sin gastar",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "este turno, zona sin explorar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    one = "{1_Turns} turno, zona sin explorar",
    other = "{1_Turns} turnos, zona sin explorar",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "este turno, {1_Steps} y luego sin explorar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    one = "{1_Turns} turno, {2_Steps} y luego sin explorar",
    other = "{1_Turns} turnos, {2_Steps} y luego sin explorar",
}
-- Combat-with-pathfinding suffix appended to the combat preview when an
-- attack target is reachable but not adjacent. The truncated step list
-- (start through the attack-from tile) names the route; "then attack"
-- marks the terminal step. Mirrors the FOG_PREFIX shape so localizers
-- already have the pattern. MP cost is omitted: the engine consumes all
-- remaining MP on attack and promotion bonuses can grant extra attacks,
-- so any predicted MP-after-attack number would be wrong.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] =
    "este turno, {1_Steps} y luego atacar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    one = "{1_Turns} turno, {2_Steps} y luego atacar",
    other = "{1_Turns} turnos, {2_Steps} y luego atacar",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "sin ruta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "demasiado lejos para calcular"
-- Discriminative path-failure diagnostics. PathDiagnostic.discriminativePath
-- runs the strict pathfinder, then re-runs with progressively relaxed flag
-- combos; whichever relaxation recovers the path names the cause. Closest-
-- reachable is rendered as the cursor-relative direction string used by the
-- scanner / bookmarks / surveyor, so the spatial vocabulary stays uniform
-- across the mod. _NO_DIR variants fire when the closest-reachable tile is
-- the cursor itself (unit can't get any closer than where you're pointing,
-- e.g. unit already at start with no exit).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "bloqueado por fronteras de {1_Civ}, más cercano alcanzable {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "bloqueado por fronteras de {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] =
    "bloqueado por fronteras cerradas, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "bloqueado por fronteras cerradas"
-- Stacking / enemy collapse to one shape: "blocked by [civ-adjective]
-- [unit name]" -- the adjective distinguishes your-own ("Roman Warrior")
-- from foreign ("Mongol Warrior") naturally. UNIT_DESCRIPTOR is the
-- adj+name combiner so the locale can reorder ({2_Name} {1_Adj}) without
-- touching the parent strings.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] = "bloqueado por {1_Unit}, más cercano alcanzable {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "bloqueado por {1_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] =
    "bloqueado por una unidad, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "bloqueado por una unidad"
-- Fog-of-war variants. When the blocker unit's plot isn't visible to the
-- active team, naming the unit would leak intelligence the sighted UI
-- doesn't expose either. The message says only that the path is blocked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED"] = "bloqueado, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED_NO_DIR"] = "bloqueado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] = "sin ruta, más cercano alcanzable {1_Dir}"
-- Unreachable-branch sub-causes. PathDiagnostic identifies these by
-- inspecting the unit's tech state (no embark / no astronomy), the
-- closest-reachable's neighbors toward target (mountain / natural
-- wonder), the destination's units (foreign-unit blocker for non-combat
-- units, sharing the existing BLOCKED_UNIT format), and the unit's
-- domain + target's water-area mismatch (naval no water connection).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] =
    "sin tecnología de embarque, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "sin tecnología de embarque"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] = "requiere Astronomía, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "requiere Astronomía"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] =
    "bloqueado por montañas, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "bloqueado por montañas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] =
    "bloqueado por {1_Wonder}, más cercano alcanzable {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "bloqueado por {1_Wonder}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] =
    "sin conexión marítima, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "sin conexión marítima"
-- Domain-incompatible combat. Land warrior can't melee a trireme on
-- water (engine's ATTACK gate at CvUnit.cpp:2583 hard-rejects
-- domain==LAND + water plot regardless of embark state). Naval unit
-- can't enter non-city land tiles to attack land units. Surfacing
-- these as "cannot attack from [unit's domain]" tells the user the
-- block is fundamental, not a tech gap.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "no puede atacar desde tierra, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "no puede atacar desde tierra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "no puede atacar desde el agua, más cercano alcanzable {1_Dir}"

-- Batch 2 (lines 422-642): translates TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_* through TXT_KEY_CIVVACCESS_BUTTON_DISABLED.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] = "no puede atacar desde el agua"
-- Naval unit targeting empty / peaceful-occupied non-city land. Same
-- engine block as cantAttackFromWater but no combat intent on the user
-- side, so the framing is "travel" not "attack".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] =
    "no puede viajar a tierra, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "no puede viajar a tierra"
-- Embark / disembark hint appended to a successful move-path preview
-- when the start and destination share a domain but the route crosses
-- the opposite one (land -> water -> land, or water -> land -> water).
-- Cross-domain endpoints (land -> water, water -> land) need no hint
-- because the destination's domain already implies the transition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "requiere embarcarse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "requiere desembarcar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "sin objetivo aquí"
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
    one = "{1_N} casilla",
    other = "{1_N} casillas",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    one = "{1_N} turno",
    other = "{1_N} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    one = "{1_Tiles} casilla, no hay trabajo pendiente",
    other = "{1_Tiles} casillas, no hay trabajo pendiente",
}
-- Route-to water blocker. The only route-failure cause without a move-to
-- analog -- move-to handles water via embark/astronomy unlocks, whereas
-- BuildRouteValid rejects every water step outright. Mountain and
-- borders reuse PATH_BLOCKED_MOUNTAIN / PATH_BLOCKED_BORDERS_CIV; same
-- cause, same wording, no need for route-flavored duplicates.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER"] =
    "bloqueado por agua, más cercano alcanzable {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER_NO_DIR"] = "bloqueado por agua"
-- Per-mode "cannot X here" strings for the special interface modes whose
-- legality is the only sighted feedback (highlight tint). Spoken when the
-- engine's per-target Can*At check returns false; legal targets fall
-- through to the destination plot's glance summary instead.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "no se puede lanzar en paracaídas aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "no se puede transportar por aire aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "no se puede reubicar aquí"
-- Rebase destination entry in the unit action menu's Rebase drill-in. The
-- menu replaces engine target mode (cursor probe) with a proximity-sorted
-- list of valid destinations so a blind player can pick by name; the
-- distance suffix is the salient distinguishing feature when several
-- candidates share a label (e.g. multiple unnamed Aircraft Carriers).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    one = "{1_Name}, {2_N} casilla",
    other = "{1_Name}, {2_N} casillas",
}
-- Spoken when the user activates the Rebase action menu entry but no
-- friendly cities or air-cargo units are within rebase range. The action
-- itself is available (the unit satisfies canRebase) but no destination
-- qualifies; surface that explicitly rather than letting the entry
-- silently disappear.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] = "sin destinos de reubicación en alcance"
-- Spoken on rebase resolution. The pending machinery normally speaks
-- moveResult ("moved, N moves left" / "stopped short"), but rebase calls
-- finishMoves before setXY so MovesLeft is always 0 -- the moveResult
-- phrasing would imply a partial / failed move. The user already picked
-- the destination by name from the action menu; the confirm names what
-- they picked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "reubicado en {1_Name}"
-- Airlift sub-menu. Two-stage picker: pick a destination city from this
-- list (own-team cities with airports that have at least one valid hex
-- around them), then the cursor jumps there and target mode opens so the
-- user can pick the exact landing tile (the city plot or any of its six
-- neighbors). Preamble explains the two stages on menu open; DEST is the
-- per-city entry; NO_DESTINATIONS surfaces when the unit can't reach any
-- friendly airport from its current plot.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "Elige una ciudad a la que transportar esta unidad por aire. Una vez seleccionada, elige la casilla exacta donde aterrizará la unidad, no puede estar a más de 1 casilla de la ciudad."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    one = "{1_Name}, {2_N} casilla",
    other = "{1_Name}, {2_N} casillas",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] = "sin destinos de transporte aéreo disponibles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "no se puede embarcar aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "no se puede desembarcar aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "no se puede lanzar bomba nuclear aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "no se puede regalar la unidad aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "no se puede mejorar aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "sin interceptores visibles"
-- Action-affirming legal previews. Spoken on Space when the cursor is on
-- a valid target hex for the active picker, in place of the cursor's
-- tile glance (which the user already heard while navigating). Each
-- mirrors its ILLEGAL counterpart but names what the action will do
-- rather than re-describing what's at the hex. NUKE additionally surfaces
-- the engine's NUKE_BLAST_RADIUS so the user can judge collateral. GIFT_*
-- name the recipient and the gifted unit / connected resource so the
-- Space probe answers "what will happen if I commit here" rather than
-- "what's at this hex."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "transportar por aire aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "lanzar en paracaídas aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] =
    "lanzar bomba nuclear aquí, radio de explosión {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "regalar {1_Unit} a {2_Recipient}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] = "mejorar {1_Resource} para {2_Recipient}"
-- Unit control help overlay entries. Chord labels merge each binding
-- cluster into one line so the ? screen doesn't list six Alt+letter rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Punto, coma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "Cambiar a la unidad siguiente o anterior"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Control más punto o coma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "Cambiar a la unidad siguiente o anterior, incluidas las que ya han actuado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Barra oblicua"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] =
    "Leer información de combate y ascensos de la unidad seleccionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Control más barra oblicua"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] =
    "Centrar el cursor hexagonal en la unidad seleccionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tabulador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Abrir el menú de acciones de la unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt más Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Mover la unidad seleccionada una casilla (pulsa dos veces para confirmar ataque)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt más M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "Abrir el selector de destino de movimiento; apunta con las teclas del cursor, Espacio para previsualizar, Intro para confirmar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt más S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] =
    "Fortificar una unidad militar, o poner a dormir una civil"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt más F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] =
    "Guardia, durmiendo hasta que un enemigo entre en visión"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt más W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "Despertar una unidad dormida o fortificada, o cancelar un movimiento en cola o una automatización"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt más X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "Saltar el turno de la unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt más H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "Curar hasta estar lleno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt más R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "Abrir el selector de objetivo de ataque a distancia; apunta con las teclas del cursor, Espacio para previsualizar, Intro para confirmar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt más P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "Saquear la casilla de la unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt más U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "Mejorar la unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt más N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "Renombrar la unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} no disponible"
-- Combat-result payload from the engine fork's CombatResolved hook.
-- Damage values speak absolute-delta ("attacker -8 hp") rather than
-- before/after because the before is already known from the last
-- selection announce.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "atacante {1_Name} -{2_Dmg} PV"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "defensor {1_Name} -{2_Dmg} PV"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "atacante {1_Name} ileso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "defensor {1_Name} ileso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} aniquilado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} capturado"
-- Substituted for the attacker / defender name in AI-vs-AI combat on a
-- visible plot when one side is invisible to the active team (e.g., AI
-- submarine ambushing AI ship). Matches what sighted players perceive:
-- an unseen hit on a visible target. Active-player-involved combats
-- always use full names regardless of invisibility because attacks
-- reveal identity in base game's defender-side messages.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "desconocido"
-- Air-strike intercept clause. Omitted unless the engine fork's hook
-- reports a landed intercept (interceptorDamage > 0); failed / evaded
-- intercepts surface no clause to match base game's UI.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "interceptado por {1_Name}"
-- Air-sweep prefix. The engine reports combatKind = 1 for sweep into
-- ground AA (one-sided), combatKind = 2 for sweep into another fighter
-- (two-sided dogfight). The prefix lets the user know the combat result
-- they're about to hear came from a sweep they triggered.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "intercepción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "combate aéreo"
-- Air-sweep no-target. Engine fork's CivVAccessAirSweepNoTarget hook
-- fires when the user issues a sweep but no interceptor is in range to
-- engage. Mirrors base game's TXT_KEY_AIR_PATROL_FOUND_NOTHING which
-- lands in the sighted notification log we don't subscribe to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "sin interceptores"
-- Nuclear strike speech. Composed from the engine fork's NukeStart /
-- NukeUnitAffected / NukeCityAffected / NukeEnd hook stream. Sections
-- are elided when empty -- a nuke that finds nothing emits the header
-- + NO_TARGETS line; one with city damage but no unit damage drops
-- the units clause. Each entity entry is built from CIV_NAME +
-- HP_DELTA + optional pop / kill / destroy suffixes joined Lua-side.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "ataque nuclear de {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "objetivo {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "bajas {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "unidades {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "ningún objetivo alcanzado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} PV"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} población"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "aniquilado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "destruido"
-- City-capture announcements. SerialEventCityCaptured fires for empty
-- city captures (no combat resolution) and for capture-after-defender-
-- killed transitions; the active player's perspective decides which line
-- wins.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "capturado {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "perdido {1_Name}"
-- Self-plot action confirms. Keyed by action hash token so the menu can
-- dispatch without a per-action if-ladder. FORTIFY / SLEEP / ALERT / WAKE /
-- AUTOMATE / DISBAND / BUILD / PROMOTION map 1:1 to the commit path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "fortificado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "durmiendo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "en alerta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "despierto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "automatizado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "licenciado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "curando"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "saqueado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "turno omitido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "mejorado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "cancelado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "iniciado {1_Build}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "ascendido a {1_Name}"
-- Generic "this control is currently un-clickable" suffix appended to
-- button labels whose engine control reports IsDisabled. Mirrored from
-- the FrontEnd copy (the front-end Context has its own sandboxed table).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "desactivado"

-- Batch 3 (lines 643-861): translates TXT_KEY_CIVVACCESS_LABEL_DISABLED through TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, desactivado"

-- Cursor / hex-grid handler. Direction tokens are short forms (e, ne, ...)
-- because experienced screen-reader users prefer shorter speech and these
-- appear in tight contexts (per-move river edges, capital orientation).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "e"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "ne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "se"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "so"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "o"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "no"
-- Compass-only tokens (no direct hex step lands due north or south, but
-- HexGeom.compassDirectionString reports those bearings when the endpoint
-- delta resolves there on the unit circle).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_N"] = "n"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_S"] = "s"

-- Compact "<count><dir>" glue used by HexGeom.directionString /
-- stepListString to assemble run-length step lists ("2e, 1se, 3nw").
-- Tight glue (no separator) is the EN form; positional template lets
-- locales insert a space or reorder count and direction.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "borde del mapa"

-- Spoken by Cursor.move when civvaccess_shared.mapScope rejects the target.
-- Generic wording rather than CityView-specific so Phase 8's ranged-strike
-- target picker (scope = valid strike targets) reuses it verbatim.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "borde del alcance"

-- Tile-state words appended to the cursor glance when the plot is unowned
-- (UNCLAIMED), never seen by the active player (UNEXPLORED), or seen once
-- but currently outside view (FOG). UNEXPLORED hides every other plot detail
-- because the user does not yet have rights to know what is there.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "sin reclamar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "sin explorar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "niebla"

-- Cursor prefix that fires while the engine is in a ranged-attack interface
-- mode (unit ranged, airstrike, city ranged) when the attacker has no
-- geometric line of sight to the target plot (mountain, hill chain, or
-- forest in the way). The companion "out of range" prefix reuses
-- TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE so target-mode preview text
-- and cursor-prefix text stay in sync across locales.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "no visible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "capital"

-- Spoken when the user presses Ctrl+S to jump to their capital before
-- founding a city. Mirrors the bookmark "no bookmark" pattern -- silence
-- is indistinguishable from a broken keystroke for a blind player, so we
-- close the loop with a short status word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "sin capital"

-- Modified-offset coordinate, capital-relative. {1_X} can be a half-integer
-- (NE / NW / SE / SW steps land on .5); {2_Y} is always an integer.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    one = "{1_Moves} movimiento",
    other = "{1_Moves} movimientos",
}

-- River and fresh-water tokens spoken in the cursor's tile glance.
-- {1_Directions} is a comma-joined run of short edge tokens (e.g. "ne, se, s")
-- naming the hex sides the river touches; ALL_SIDES is the degenerate
-- six-edge case. FRESH_WATER fires for tiles adjacent to a river or lake.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "río {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "río por todos los lados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "agua dulce"

-- Numbered step on the head-selected unit's queued path. Speaks on cursor
-- glance and as the scanner item name for the "waypoints" category.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "punto de ruta {1_Index} de {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} saqueado"

-- Macro-terrain tokens. Spoken inside the cursor glance for plots the engine
-- does not give a per-terrain TXT key for (hills are a flag on top of base
-- terrain, lakes are technically a feature, mountains are a base-terrain
-- type but the engine's TXT key includes punctuation we strip).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "colinas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "montaña"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "lago"

-- Generic HP format used wherever a single HP number is spoken without a
-- max (cursor glance for friendly units below full HP, etc.). The
-- max-bearing form is UNIT_HP_FRACTION above.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} PV"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    one = "{1_Build} {2_Turns} turno",
    other = "{1_Build} {2_Turns} turnos",
}

-- Yield + count glue used by per-plot yields and the surveyor radius
-- sum. {2_Yield} is a pre-resolved noun ("food", "production"...);
-- positional template lets number-after-noun locales reorder.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"

-- "Controlled" = plot:GetWorkingCity(): the tile is part of this city's
-- workable area (the engine's term is "working city," but no citizen need
-- be assigned). "Worked" elsewhere means IsWorkingPlot = a citizen is
-- actually there. Kept the wording distinct so the two never collide.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "controlado por {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "controlado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} por ciento de defensa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "en zona de control enemiga"
-- Cursor-move prefix used by the optional adjacent-enemy warning (Settings
-- toggle). Counts visible enemy units across the six neighbor tiles; same
-- predicate as the X-key ZoC line but drops the IsCombatUnit filter so
-- workers / settlers / naval-on-coast all count, since this warning is
-- about presence not ZoC.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NEARBY_ENEMIES"] = {
    one = "{1_N} enemigo cercano",
    other = "{1_N} enemigos cercanos",
}

-- Cursor help-overlay key labels: chord forms shared with the main letter
-- cluster. One TXT_KEY per chord because Help dedupes by keyLabel string and
-- the chords don't merge cleanly into a single label (Q is its own meaning).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "grupo Q, W, E, A, S, D, Z, X, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] =
    "Mueve el cursor por casilla (Q no, E ne, A o, D e, Z so, C se)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] = "Teclado numérico 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] =
    "Refleja Q, W, E, A, S, D, Z, X, C con los mismos modificadores (en el teclado numérico, 5 corresponde a S, con Bloq Num activado)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "Lee la unidad en la casilla actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Mayúsculas más S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "Coordenadas del cursor relativas a la capital original, en notación de desplazamiento modificado (cada paso al este suma uno en x, cada paso al noreste suma 0,5 en x y uno en y, cada paso al sureste suma 0,5 en x y resta uno en y)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Control más S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "Salta el cursor a tu capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "Detalles económicos de la casilla actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "Detalles de combate de la casilla actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PATH_PREVIEW"] = "Espacio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PATH_PREVIEW"] =
    "Vista previa de la ruta y el coste de movimiento de la unidad seleccionada hasta la casilla actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "Identidad y combate de la ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "Producción y crecimiento de la ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "Religión de la ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] = "Notas diplomáticas de la ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "Selecciona una unidad, o abre la pantalla de ciudad (ventana de anexión para títeres, diplomacia con una civilización mayor ya contactada), en la casilla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Control más I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "Abre la Civilopedia para todo lo que haya en la casilla del cursor (unidades, maravillas del mundo, mejora, recurso, elemento del terreno, río, lago, terreno, colinas, montaña, ruta)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "Artículos en la casilla"

-- City-info speech tokens. Four keys (1 identity + combat, 2 development
-- or city-state influence, 3 religion breakdown, 4 diplomatic notes);
-- shape mirrors the BNW CityBannerManager per-ownership tier. Unmet
-- cities stop at one word across all four keys. Identity leads with
-- actionable signals (can-attack, capital or city-state trait+friendship),
-- then status flags, then pop/defense/HP, then garrison on team banners.
-- Enemy HP reuses the unit color-band keys so "hp full / green / yellow
-- / red" stays one vocabulary across unit and city queries.
-- Spoken alone (no further fields) for cities whose owner the active
-- player has not yet met; everything else in the city info line is
-- suppressed because the engine does not reveal those fields.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "sin contactar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "puede atacar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "no hay ciudad aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "culta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "militarista"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "marítima"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "mercantil"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "religiosa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "amigo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "aliado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "guerra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "guerra permanente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    one = "arrasando {1_Turns} turno",
    other = "arrasando {1_Turns} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    one = "resistencia {1_Turns} turno",
    other = "resistencia {1_Turns} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "ocupada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "títere"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} de población"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} de defensa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} de {2_Max} PV"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "guarnecida por {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    one = "produciendo {1_Name} {2_Turns} turno",
    other = "produciendo {1_Name} {2_Turns} turnos",
}

-- Process production (Wealth / Research / etc.) has no completion turn or
-- progress fraction -- absence of the turn count is the audible signal that
-- this is a perpetual process rather than a buildable item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "produciendo {1_Name}"

-- City development tokens (the "2" key, second tier of the city-info
-- triplet). Production block: NOT_PRODUCING when the queue is empty,
-- PRODUCTION_PROGRESS / PRODUCTION_PER_TURN to read the current item's
-- meter and rate. Growth block: GROWS_IN for next-pop ETA, STARVING when
-- food is negative and population will shrink, STOPPED_GROWING when food
-- is exactly zero and population holds, plus the FOOD_PROGRESS /
-- FOOD_PER_TURN / FOOD_LOSING readouts.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "sin producir"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} de {2_Needed} producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} por turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    one = "crece en {1_Turns} turno",
    other = "crece en {1_Turns} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "en hambruna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "crecimiento detenido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} de {2_Threshold} comida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} por turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "perdiendo {1_Num} por turno"

-- Spoken when key 2 fires on a met foreign-major city: production and
-- growth aren't on the banner (and a spy in the city alone doesn't
-- expose them either), so we point at the Espionage Overview where
-- sighted players see what each foreign civ is producing.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] =
    "producción oculta, consulta la Perspectiva de Espionaje"

-- City religion tokens (the "3" key). Full breakdown matching the
-- banner's GetReligionTooltip iteration: every religion present, with
-- holy-city marker, follower count, pressure-per-turn, and trade-route
-- count when nonzero. NO_RELIGION_PRESENT speaks when religion is on but
-- this city has zero followers; STATUS_FAITH_OFF (defined elsewhere) is
-- reused for the GAMEOPTION_NO_RELIGION case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    one = "vía {1_N} ruta comercial",
    other = "vía {1_N} rutas comerciales",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "sin religión presente"

-- City diplomatic notes (the "4" key, miscellany the banner exposes that
-- isn't combat or trajectory). ORIGINALLY_CS fires whenever the city's
-- original founder was a city-state and the city has since changed
-- hands -- mirrors the banner's MinorIndicator ornament (persistent,
-- not war-gated). WARMONGER / LIBERATION previews fire only when at war,
-- matching the banner's tooltip gate. SPY / DIPLOMAT announce the active
-- foreign agent in the city; rank is the engine's tier name (Recruit,
-- Agent, Special Agent, etc.). NO_DIPLO_NOTES is the empty-state token
-- so the user knows key 4 fired but had no payload.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "originalmente {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "avance de belicosidad: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "avance de liberación: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "espía {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "diplomático {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "sin notas diplomáticas"

-- Batch 4 (lines 862-1027): translates TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE through TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "modo de mapa"

-- Type-ahead search feedback (see FrontEnd strings for the authoring
-- rationale). Mirrored here because TypeAheadSearch runs from in-game
-- BaseMenu contexts whose string table is sandboxed from the FrontEnd copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "sin coincidencias para {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "búsqueda borrada"

-- Help overlay strings (see FrontEnd strings for the authoring rationale).
-- Duplicated here because Contexts are sandboxed: in-game Contexts that
-- eventually wire SetInputHandler through InputRouter need their own copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Ayuda"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Letras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Arriba o abajo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Inicio o fin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Intro o Espacio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Izquierda o derecha"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Mayúsculas más izquierda o derecha"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Control más arriba o abajo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt más izquierda o derecha"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tabulador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Mayúsculas más Tabulador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control más I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Signo de interrogación"

-- Description tokens of the help overlay (paired with the KEY_* labels
-- above; the two halves combine via HELP_ENTRY = "{1_Key}, {2_Description}").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Escribe para buscar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Navegar entre elementos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "Ir al primero o al último"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Activar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "Ajustar valor o entrar en detalle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "Ajustar valor en pasos grandes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "Ir al grupo anterior o siguiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Pestaña siguiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Pestaña anterior"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Leer encabezado de pantalla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "Abrir entrada de Civilopedia para el elemento actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Cancelar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Cerrar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Cancelar edición"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Confirmar edición"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Control más Mayúsculas más F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Abrir configuración"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Cerrar configuración"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "Pausar o reanudar el mod"

-- BaseTable: 2D table viewer (used by F2 cities, future demographics, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, descendente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, ascendente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, orden borrado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "botón de ordenación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "Moverse entre filas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "Moverse entre columnas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "Primera o última fila"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "Activar celda u ordenar por columna"

-- Settings overlay strings. Reachable from every Context that routes
-- through InputRouter, so duplicated in the FrontEnd copy as well.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Configuración"
-- Etiquetas de nivel superior para los grupos de configuración.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_UI"] = "Configuración de interfaz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_CURSOR"] = "Configuración del cursor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_BEACON"] = "Configuración de baliza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_SCANNER"] = "Configuración del escáner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_NOTIFICATIONS"] = "Notificaciones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Iconos de audio del terreno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Solo voz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Voz y señales de audio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "Anuncios detallados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Solo señales de audio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "Volumen de iconos de audio del terreno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] =
    "Volumen de iconos de audio del terreno, {1_Num} por ciento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME"] = "Volumen de baliza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME_VALUE"] = "Volumen de baliza, {1_Num} por ciento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "Distancia audible del faro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] = "Distancia audible del faro, {1_Num} hexágonos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "Movimiento automático del cursor del escáner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "El cursor sigue a la unidad seleccionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "Coordenadas del cursor al moverse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Desactivado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "Hablar antes del anuncio de movimiento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "Hablar después del anuncio de movimiento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] =
    "Anunciar siempre el territorio en la lectura de casilla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_ENEMY_ADJACENT_WARN"] = "Avisar al estar adyacente a un enemigo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "El escáner muestra coordenadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COMPASS_DIRECTION"] = "El escáner usa dirección de brújula"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_DIRECTION_BEEP"] = "El escáner reproduce pitido direccional"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Leer subtítulos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "Anunciar cambios de visibilidad al moverse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "Anunciar resoluciones de combate de la IA"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] =
    "Anunciar cambios de visibilidad al inicio del turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "Anunciar campamentos y ruinas reclamados por otros en el campo de visión"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_TURN_START_SOUND"] =
    "Reproducir sonido al inicio del turno en un jugador"

-- Widget-generic strings spoken by BaseMenuItems Choice / Checkbox /
-- Textfield and BaseMenuEditMode. Mirrored from the FrontEnd copy because
-- Contexts are sandboxed: an in-game screen that uses these item kinds
-- needs them present in the InGame Context's string table.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "seleccionado"
-- Compositional form: "selected, <label>" for Choice items that surface
-- the selection marker as a prefix on the entry's own text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "seleccionado, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "activado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "desactivado"
-- Compositional form: "<label>, <state>" for VirtualToggle items that
-- assemble a label and a CHECK_ON / CHECK_OFF (or other) state token.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_STATE"] = "{1_Label}, {2_State}"
-- Generic "<label> <value>" template for label-and-bare-number lines
-- (POP_SCORE / DEMOGRAPHICS_RANK on Hall of Fame and Leaderboard rows).
-- Positional args expose label and value separately so locales can drop
-- the space, add a particle, or reverse order.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_VALUE"] = "{1_Label} {2_Value}"
-- Generic "<label> <list>" template for header-then-list lines (e.g.
-- the ReligionOverview "Possible Great People" row, with either the
-- list or a "none" fallback as the second arg).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABELED_LIST"] = "{1_Label} {2_List}"
-- Diplomacy gold offer in read-only deal description: "<gold>, <amount>".
-- Comma form is distinct from LABEL_VALUE's space form so the existing
-- speech cadence is preserved; locales can collapse to one shape if
-- desired.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT"] = "{1_Label}, {2_Amount}"
-- Diplomacy gold-per-turn read-only line: "<label>, <amount>, <turns>".
-- {3_TurnsLine} is the already-localized turns clause from
-- TXT_KEY_DIPLO_TURNS so the template holds only the separator pattern.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE"] = "{1_Label}, {2_Amount}, {3_TurnsLine}"
-- Compact "<value> <unit>" template used by Demographics rows that
-- append a measurement noun (Bushels, Soldiers, Tons) to the active
-- player's value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_VALUE_UNIT"] = "{1_Value} {2_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "editar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "vacío"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "editando {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restaurado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "botón"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "interruptor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "control deslizante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "cuadro combinado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "submenú"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "tabla"
-- "enlace" en el sentido de hipervínculo (referencia cruzada a otro artículo
-- de la Civilopedia), no de cadena ni de conexión.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_LINK"] = "enlace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "{1_Num} de {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "fila {1_Num} de {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "columna {1_Num} de {2_Num}"

-- GameMenu (Esc pause menu) strings. Details tab reuses the base game's
-- TXT_KEY_POPUP_GAME_DETAILS, so no mod-authored tab label here.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "Menú de pausa"

-- GenericPopup (the shared Context behind AnnexCity / PuppetCity /
-- ConfirmCommand / DeclareWar / BarbarianRansom / etc.). One display name
-- for all of them; the per-popup text comes from the base via preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "Emergente"

-- Informational popups that have no engine-side title to reuse: TextPopup
-- is a generic notification, WonderPopup only carries the wonder name
-- (dynamic), LeagueSplash's title is dynamic per-session.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "Notificación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "Maravilla completada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "Congreso Mundial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "Fin de partida"

-- Ranking tab row labels. The HistoricRankings table is fixed leader tiers
-- with thresholds; the matched row replaces "score <threshold>" with the
-- player's actual score and tacks on the leader's quote.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, puntuación {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] =
    "{1_Rank} {2_Leader}, tu puntuación {3_Score}, {4_Quote}"

-- Drillable label for a per-turn group of replay messages. Source is
-- Game.GetReplayMessages() at end-game; children are the non-empty Text
-- entries on that turn, with the turn prefix dropped since the group
-- label provides it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "Turno {1_Turn}"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "Declarar guerra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "Saludo de ciudad-estado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "Ciudad-estado"

-- Fallback for LeaderHeadRoot / DiscussionDialog before TitleText is
-- populated. In practice the onShow hook overwrites handler.displayName
-- with the live leader title (e.g. "Suleiman the Magnificent") that
-- LeaderMessageHandler just set.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "Diplomacia"

-- DiscussionDialog sub-menu display names. Denounce confirm is a yes/no
-- overlay; coop-war leader picker is a scroll list of civs the AI could
-- ally with against us.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "Denunciar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "Objetivo de guerra conjunta"

-- Great-work splash (archaeology / wonder / cultural-victory completion).
-- Title is either the great work's artist or the "written artifact" label;
-- description and quote come from GameInfo.GreatWorks.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "Gran obra"

-- Batch 5 (lines 1028-1247): translates TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD through TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY.

-- Choose* popup screen display names. These are spoken as the handler's
-- title on open and on F1. "Ruinas antiguas" is the game's ES_ES term for
-- Goody Huts (TXT_KEY_GAME_OPTION_NO_GOODY_HUTS -> "Sin Ruinas antiguas").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "Elegir recompensa de Ruinas antiguas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WARRIOR"] = "Guerrero"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_POPULATION"] = "Población"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_CULTURE"] = "Cultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PANTHEON_FAITH"] = "Fe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PROPHET_FAITH"] = "Gran profeta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_NEARBY_BARBS"] = "Revelar bárbaros cercanos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_GOLD"] = "Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_LOW_GOLD"] = "Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HIGH_GOLD"] = "Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_MAP"] = "Revelar mapa cercano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_TECH"] = "Tecnología gratuita"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_RESOURCE"] = "Revelar recurso cercano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_UPGRADE_UNIT"] = "Mejorar unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SETTLER"] = "Colono"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SCOUT"] = "Batidor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WORKER"] = "Trabajador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_EXPERIENCE"] = "Experiencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HEALING"] = "Sanar unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "Elegir gran personaje gratuito"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "Elegir gran personaje de la fe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "Elegir bonificación maya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "Fundar un panteón"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "Elegir ideología"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "Hallazgo arqueológico"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "Cambiar almirante de puerto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "Cambiar ciudad de origen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "Establecer ruta comercial"
-- Confirm-overlay sub-handler pushed on top of a Choose* picker when the
-- player activates an item. Display name only; the actual prompt text
-- (e.g. "Are you sure you wish to found X?") comes from Controls.ConfirmText
-- as a function preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Confirmar"
-- ChooseReligionPopup (BUTTONPOPUP_FOUND_RELIGION). Same Context wraps both
-- founding (Option1=true) and enhancing (Option1=false); the display name
-- resolves per phase. Change Religion Name is a sub-handler covering the
-- engine's ChangeNamePopup overlay (Textfield + OK / Default / Cancel).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "Fundar una religión"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "Potenciar una religión"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "Cambiar nombre de religión"
-- Belief-slot label formats. {1_Slot} is the slot's short name (Pantheon
-- belief, Founder belief, Follower belief, Follower belief 2, Enhancer
-- belief, Bonus belief); {2_Belief} is the short description of whichever
-- belief currently fills the slot. States: UNCHOSEN (editable with nothing
-- picked), CHOSEN (either editable with a selection or already committed;
-- both spoken identically - commit state is reflected by whether drill-in
-- opens a belief list), LATER (locked; slot unlocks next phase), and
-- BYZANTINES_ONLY (locked; only reachable with the Byzantine civ trait).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, no elegido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, disponible más adelante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, solo para los Bizantinos"
-- Religion-picker row. Unselected in founding mode before the user picks
-- from the religion list; selected after SelectReligion fires. Enhance mode
-- replaces the row with a read-only Text showing the player's own religion.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "religión, no elegida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "religión, {1_Name}"
-- Name row. Founding lets the user open ChangeNamePopup to rename; enhance
-- shows read-only. The row is gated on ReligionPanel visibility so only
-- runs once a religion is selected.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "nombre, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "nombre de religión"
-- NotificationLogPopup (BUTTONPOPUP_NOTIFICATION_LOG). Split into Active /
-- Dismissed tabs by the engine's per-notification dismissed flag. Item
-- label inlines the turn so the user can place each entry in history
-- without a separate key.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Registro de notificaciones"
-- LeagueProjectPopup (BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED). Each contributor
-- entry is one navigable Text item: rank, civ name, contribution score, tier
-- earned. Tier maps from base's iTier int (0..3) to the bronze/silver/gold
-- vocabulary the project rewards-table uses; "no reward" covers iTier == 0
-- (contributed too little to qualify for any tier).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "Proyecto del Congreso completado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} producción, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "recompensa de nivel oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "recompensa de nivel plata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "recompensa de nivel bronce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "sin recompensa"
-- VoteResultsPopup (BUTTONPOPUP_VOTE_RESULTS). Each entry is rank, voter,
-- who they voted for, and the votes they themselves received.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "Resultados de votación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    one = "{1_Rank}, {2_Name} votó por {3_Cast}, recibió {4_Votes} voto",
    other = "{1_Rank}, {2_Name} votó por {3_Cast}, recibió {4_Votes} votos",
}
-- WhosWinningPopup (BUTTONPOPUP_WHOS_WINNING). Engine-fired ranking pop with
-- a randomly-chosen metric. Player rows mirror the engine's "rank, name,
-- score" order so the user hears the rank first; the active player's tag
-- and the unmet placeholder come from the engine's own keys. Tourism-mode
-- rows include the owner because the sighted column shows the leader
-- portrait + civ icon next to the city name (info absent from the city's
-- own label). Unmet city rows degrade to "Unmet Player" with no city or
-- owner, matching what base displays.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "Quién va ganando"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"
-- Advisors tutorial banner (Events.AdvisorDisplayShow). Static screen
-- name; the per-tutorial title, body, and advisor type are spoken through
-- the preamble from live Controls. "Tutorial Advisor" distinguishes this
-- surface from the combat-interrupt AdvisorModal and the concept-browser
-- AdvisorInfoPopup that question buttons drill into.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "Asesor tutorial"
-- NotificationLogPopup tab labels and item format. The popup itself has
-- its title at SCREEN_NOTIFICATION_LOG; these are its three tabs (Active
-- holds undismissed alerts the user can act on, Turn Log is the read-only
-- per-turn event stream, Dismissed is the archive), the placeholder
-- spoken when a tab has no rows, and the item-row format combining the
-- engine-supplied notification text with the turn it fired on.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "Activas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "Registro de turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "Descartadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "Sin notificaciones."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, turno {2_Turn}"
-- Combat Log group inside the Turn Log tab. Contains one entry per combat
-- announced to the player while the AI was taking its turn (between End
-- Turn and the next turn start). Drilled into from the level-0 group label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "Registro de combate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "Sin combates este turno."
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur} de {3_Max} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "Suministro: {1_Use} de {2_Cap}"
-- Idle status fallback. The engine hides the status column when a unit
-- has no fortify / sleep / sentry / heal / build / automation state.
-- In speech an empty cell would leave the user wondering whether the
-- screen reader cut off, so we name the idle case explicitly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "inactivo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_MOVING"] = "en movimiento"
-- Tab labels. Two tabs: Units (BaseTable) and Great People (BaseMenu).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "Unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "Grandes personajes"
-- Units tab column headers. Name / Status reuse engine plain-noun keys.
-- Movement / Max moves / Strength / Ranged are mod-authored because the
-- engine's TXT_KEY_MO_SORT_* strings ("Sort By Strength") read awkwardly
-- as a column name and the engine's visible columns are icon-only.
-- Distance is mod-authored: leftmost column, sortKey is cube-distance
-- (nearest first on ascending), cell uses HexGeom.directionString --
-- the same compact "<count><dir>" format the scanner speaks ("3e",
-- "2nw, 1ne"). On the cursor's own hex the cell speaks SCANNER_HERE.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "Distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "Movimientos restantes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "Movimientos máximos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "Fuerza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "A distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_ENEMIES_ADJACENT"] = "Enemigos adyacentes"
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
    "{1_City}: {2_Turns}, {3_Progress} de {4_Threshold}, más {5_Rate} por turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] =
    "{1_City}: {2_Progress} de {3_Threshold}, sin progreso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "turno siguiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    one = "{1_N} turno",
    other = "{1_N} turnos",
}
-- AdvisorCounselPopup (BUTTONPOPUP_ADVISOR_COUNSEL). Four tabs, one per
-- advisor. Page item label is composed at Lua level from the engine's
-- TXT_KEY_ADVISOR_COUNSEL_PAGE_DISPLAY fraction + the counsel body so the
-- user hears "i/N, <paragraph>" only when the advisor has more than one
-- page. Empty-advisor fallback when Game.GetAdvisorCounsel() returns
-- nothing for that slot (early-game Science is the usual case). F10 help
-- entry covers the BaselineHandler binding that opens the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "Sin asesoramiento."
-- Function-row help entries. F1-F9 describe engine passthroughs (no mod
-- binding; BaselineHandler's passthroughKeys lets the keycode reach the
-- engine's own action). F10 is our advisor-counsel rebind; the strategic
-- view toggle the engine binds here is suppressed. Authored as help text
-- only so the map-mode help list documents the full function-row vocab
-- the user can reach from the map.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "Abrir la Civilopedia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "Abrir el asesor económico"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "Abrir el asesor militar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "Abrir el asesor diplomático"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "Abrir la pantalla de políticas sociales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "Abrir el árbol tecnológico"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "Abrir el registro de turnos y eventos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "Abrir la pantalla de progreso hacia la victoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "Abrir la pantalla de estadísticas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "Abrir el asesoramiento"
-- CityView hub. Preamble is spoken on open (and via F1). Yield names lead
-- each token so distinguishing information is at the front -- "food 3"
-- not "3 food" -- per the concise-announcement rule.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "Ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "conectada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} desempleados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "comida {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "producción {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "oro {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "ciencia {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "fe {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "turismo {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "cultura {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Punto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "Ciudad siguiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Coma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "Ciudad anterior"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "no hay ciudad siguiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "no hay ciudad anterior"
-- Hub items that push a sub-handler on Enter. The unemployed action is
-- an item on the hub itself, not a sub; its label carries the live count
-- so the user hears it when arrowing past and doesn't have to drill in
-- just to check.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "Estadísticas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "Maravillas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "Progreso de grandes personajes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "Enfoque del trabajador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "Desempleados: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "No hay maravillas construidas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "Sin generación de grandes personajes."

-- Batch 6 (lines 1248-1451): CITYVIEW_GP_ENTRY through CITYVIEW_FOREIGN_NO_SLACKER.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} de {3_Max}"
-- Focus item label when the current focus matches. Read by labelFn on
-- every navigate so flipping focus is reflected immediately.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, seleccionado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "Evitar crecimiento, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "Restablecer asignaciones de casillas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} seleccionado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "asignaciones de casillas restablecidas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "sin desempleados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "asignado"
-- Buildings sub-handler (§3.7). Drill-in opens on Enter over any building
-- entry; Sell is conditional on pCity:IsBuildingSellable and not-puppet, so
-- a non-sellable entry lands the user on a drill-in with just Back. The
-- sell-confirm modal speaks the engine's own TXT_KEY_SELL_BUILDING_INFO
-- so blind and sighted players see / hear the same confirmation text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "Edificios"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "No hay edificios."
-- Specialists sub-handler (§3.6). One item per slot across specialist-
-- capable buildings. Labels use labelFn so Enter-driven add/remove flips
-- the "empty" / "filled" suffix on the next navigate without rebuilding.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "Especialistas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "No hay ranuras de especialista."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] =
    "{1_Building} {2_Specialist} ranura {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "vacía"
-- _FILLED_STATE substitutes into SPECIALIST_SLOT's {4_State} as the
-- in-list state token. _FILLED is the standalone confirmation spoken on
-- Enter when an unfilled slot just became filled. Two keys with identical
-- value so each can move independently if a future tense / particle
-- requires divergent forms in the target language.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "ocupada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "ocupada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "libre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] =
    "ocupada, trabajador retirado de la casilla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] =
    "libre, trabajador asignado a la casilla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "no se puede añadir especialista"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "Control manual de especialistas, {1_State}"
-- Great works sub-handler (§3.12). One item per great-work slot, grouped by
-- building in label. Slot-type label is the work category ("art", "writing",
-- "music"), not the great-person class, because that's what occupies the
-- slot and what the player reasons about. Synthetic theming-bonus entry
-- per building when the bonus is non-zero -- label carries the bonus magnitude
-- and engine's theming tooltip text so the rule is audible inline.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "Grandes obras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "arte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "literatura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "música"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} ranura de {2_Slot} {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} ranura de {2_Slot} {3_N}, vacía"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} bonificación de temática más {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "No hay ranuras de Gran obra."
-- Production queue sub-handler (§3.1). Slot 1 is the currently-producing
-- item, so its announcement carries the production meter percent; slots 2+
-- only have name + turns. Processes (ORDER_MAINTAIN) have no turns line.
-- Drill-in moves and removes via GAMEMESSAGE_SWAP_ORDER / _POP_ORDER.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "Cola de producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "Cola vacía."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    one = "Ranura 1, {1_Name}, {2_Turns} turno, {3_Percent} por ciento. {4_Help}",
    other = "Ranura 1, {1_Name}, {2_Turns} turnos, {3_Percent} por ciento. {4_Help}",
}
-- _TRAIN_INFINITE fires for buildable items (units / buildings / wonders)
-- whose remaining turns cannot be estimated from the current production
-- rate (typical for queued slots 2+ where the city has not yet started
-- accumulating progress towards the item). _PROCESS fires for
-- ORDER_MAINTAIN entries (Wealth, Research, Faith, Defense) that have no
-- completion turn or progress meter at any slot because they are
-- perpetual conversions, not buildable items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "Ranura 1, {1_Name}, {2_Percent} por ciento. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "Ranura 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    one = "Ranura {1_N}, {2_Name}, {3_Turns} turno. {4_Help}",
    other = "Ranura {1_N}, {2_Name}, {3_Turns} turnos. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "Ranura {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "Ranura {1_N}, {2_Name}"
-- Slot-specific remaining figure: substitutes for the helper's
-- "[ICON_PRODUCTION] Cost: X" line. Slot 2+ shows full needed; the head
-- slot subtracts whatever the engine has accumulated. The
-- [ICON_PRODUCTION] adjacent to "Production" collapses through the
-- TextFilter dedup so the screen reader hears "Production remaining: N".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "[ICON_PRODUCTION] Producción restante: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "Acciones de {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "Subir"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "Bajar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "Retirar de la cola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "Atrás"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "subido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "bajado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "retirado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "Modo cola, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "Elegir producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "Comprar con oro o fe"
-- Hex map sub-handler (§3.2). Arrow keys walk the cursor across the city's
-- own tile, its workable ring, and purchasable tiles. Tile announcement
-- composes yield line, worked-state word, buy cost, and PlotComposers.glance.
-- Enter over a workable ring plot issues TASK_CHANGE_WORKING_PLOT; over an
-- affordable purchasable plot issues SendCityBuyPlot; over an unaffordable
-- purchasable plot speaks "cannot afford" without sending.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Gestionar territorio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "gestionar territorio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "trabajada"
-- "Pinned" = IsForcedWorkingPlot: a worker is here AND the citizen manager
-- won't pull them off. Vanilla's visual is a star/pin icon, so the metaphor
-- matches. Pressing Enter on a "not worked" tile lands here in one step --
-- the engine's TASK_CHANGE_WORKING_PLOT both assigns and forces in a single
-- task, same as a mouse left-click.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "fijada"
-- BLOCKED: tile cannot be worked at all (enemy unit on it, foreign
-- territory, or otherwise outside the city's reachable working set).
-- NOT_WORKED: workable in principle but no citizen is currently assigned
-- (an Enter press here triggers TASK_CHANGE_WORKING_PLOT to assign one).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "no trabajada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "comprable, {1_Gold} oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "comprable, {1_Gold} oro, no alcanza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "no alcanza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "Mover cursor por las casillas de la ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "Trabajar o comprar casilla"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Volver al centro de ciudad"
-- Ranged strike sub-handler (§3.5). Hub item closes the city screen, enters
-- INTERFACEMODE_CITY_RANGE_ATTACK, and pushes a target picker. Cursor moves
-- freely via Baseline's QAZEDC; Space speaks a strike-specific preview
-- (target identity if in range, "cannot strike" otherwise); Enter commits
-- with a "fired" confirmation. Exit (commit, cancel, or external pop)
-- returns to the world map -- the city screen does not re-open.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "Ataque a distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "ataque a distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "no puede atacar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "disparado"
-- City-attacker damage preview. Mirrors the unit ranged preview shape
-- ("{name}, {my} vs {theirs}, ..."): the cursor already spoke the target
-- tile's full info, so this only names what is being shot at and the
-- engine-computed strengths and damage. No verdict (cities don't get
-- GetCombatPrediction) and no retaliation (city ranged is one-way).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] = "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Dmg} de daño"
-- Gift-unit / gift-improvement target picker (audit §7.7). Pushed from
-- the city-state diplo popup when the user chooses Gift > Unit or Gift >
-- Improvement; the engine's INTERFACEMODE_GIFT_UNIT and INTERFACEMODE_
-- GIFT_TILE_IMPROVEMENT are hex-click-only modes with no engine keyboard
-- path. Cursor moves freely via Baseline; Space speaks legality + plot
-- glance; Enter commits (gift-unit chains into BUTTONPOPUP_GIFT_CONFIRM,
-- gift-improvement calls Game.DoMinorGiftTileImprovement directly).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "regalar unidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "regalar mejora"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "mejora entregada"
-- Rename / Raze hub items (§3.13, §3.14). Rename fires BUTTONPOPUP_RENAME_CITY,
-- whose accessibility is handled by SetCityNameAccess. Raze fires the Yes/No
-- confirmation popup (BUTTONPOPUP_CONFIRM_CITY_TASK with TASK_RAZE), handled
-- by GenericPopupAccess. Unraze is a direct Network.SendDoTask -- no popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "Renombrar ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "Arrasar ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "Detener arrasamiento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "arrasamiento detenido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_TOO_SHORT"] = "El nombre debe tener al menos 3 caracteres. Cancelado."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_INVALID_CHARS"] = "El nombre contiene caracteres no válidos. Cancelado."
-- Foreign / spy-screen refusals. Spying on a foreign city opens CityView
-- in viewing mode (UI.IsCityScreenViewingMode true and / or owner not the
-- active player). Vanilla disables every write surface; we surface the same
-- items but speak a refusal on press so a blind player hears why nothing
-- happened. The HEX_PURCHASABLE_FOREIGN variant strips the gold cost from
-- the buy-cost line because that number is mod-authored intel vanilla
-- doesn't show on the espionage view.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "espiando"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] =
    "el ciclo de ciudades no está disponible mientras espías"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "no puedes lanzar ataques a distancia en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "no puedes cambiar la producción en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "no puedes trabajar casillas en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] =
    "no puedes comprar casillas en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] =
    "no puedes vender edificios en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] =
    "no puedes cambiar el enfoque en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "no puedes gestionar especialistas en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "no puedes ver las grandes obras en una ciudad que no es tuya"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "no puedes asignar ciudadanos en una ciudad que no es tuya"

-- Batch 7 (lines 1452-1671): CITYVIEW_HEX_PURCHASABLE_FOREIG* through PEDIA_NO_NEXT_HISTORY.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "comprable"
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
    one = "{1_Num} casilla descubierta",
    other = "{1_Num} casillas descubiertas",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "Descubierto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "Enemigo: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "Unidades: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "Ciudades: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "Recursos: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "Oculto"
-- Foreign-unit watch. Four lines spoken at the start of each player turn
-- summarising what foreign units entered / left view during the AI turn
-- just past, split by hostile (at-war + barb) and neutral (everyone else
-- not on the active team). The list arg is comma-joined "{count} {civ-
-- adjective} {unit-name}" pieces; count is omitted when 1. Bare unit name
-- without a plural suffix is intentional (Civ V text data has no plural
-- TXT keys; hand-rolling per-locale plural rules is a maintenance trap).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] = "Nuevas unidades hostiles a la vista: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] = "Unidades hostiles que han salido de la vista: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] = "Nuevas unidades neutrales a la vista: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] =
    "Unidades neutrales que han salido de la vista: {1_List}"
-- Foreign-clear watch. One line spoken at the start of each player turn
-- summarising goody huts and barbarian camps that some other civ cleared
-- on a plot the active team could see during the AI turn just past. Camps
-- and ruins are tallied separately and joined with the AND key when both
-- are non-zero. Pluralized via Text.formatPlural; PREFIX / AND / SUFFIX
-- are bare strings so translators get full control of word order.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "Otro jugador ha reclamado "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " y "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    one = "{1_Num} campamento bárbaro visible",
    other = "{1_Num} campamentos bárbaros visibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    one = "{1_Num} ruina antigua visible",
    other = "{1_Num} ruinas antiguas visibles",
}
-- Gone-on-revisit. RevealAnnounce speaks this as the third line of its
-- flush (after Revealed: and Hidden:) when a barbarian camp / ancient
-- ruins disappeared from a plot the active team had previously seen
-- it on. Singular form drops the count for naturalness ("Gone:
-- barbarian camp" beats "Gone: 1 barbarian camp"); plural prefixes
-- the count. AND-join reuses TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND
-- since the connective is the same.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "Desaparecido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    one = "campamento bárbaro",
    other = "{1_Num} campamentos bárbaros",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    one = "ruinas antiguas",
    other = "{1_Num} ruinas antiguas",
}
-- Turn lifecycle speech. Turn-start is the game-side "Turn: N" label plus
-- the game's AD/BC year, joined by a comma so the moving parts (number
-- first, year second) read as a single line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "Turno terminado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "Fin de turno cancelado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control más espacio o Control más Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] = "Terminar turno, o anunciar y abrir el primer bloqueo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] =
    "Control más Mayúsculas más espacio o Control más Mayúsculas más Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "Terminar turno ignorando el aviso de unidades sin órdenes; otros bloqueos se anuncian y abren igualmente"
-- Empire status readouts (T/R/G/H/F/P/I bare-letter keys in baseline). Each
-- key speaks one composed line; conditional clauses join with comma. Help
-- entries describe the underlying readout, not the panel item, since the
-- speech composes data from multiple panel surfaces.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "{1_Num} sobre el límite de unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    one = "{1_Turns} turno para {2_Tech}, ciencia +{3_Rate}",
    other = "{1_Turns} turnos para {2_Tech}, ciencia +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} completada, ciencia +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "Sin investigación, ciencia +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "Ciencia desactivada"
-- Plural is driven by {4_Avail}: "1 of 1 trade route" vs "1 of 5 trade
-- routes". The Used count can be 1 even when Avail is many.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    one = "+{1_Rate} de oro, {2_Total} total, {3_Used} de {4_Avail} ruta comercial",
    other = "+{1_Rate} de oro, {2_Total} total, {3_Used} de {4_Avail} rutas comerciales",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    one = "menos {1_Rate} de oro, {2_Total} total, {3_Used} de {4_Avail} ruta comercial",
    other = "menos {1_Rate} de oro, {2_Total} total, {3_Used} de {4_Avail} rutas comerciales",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "sin {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_STILL_PLAYING"] = "aún jugando: {1_Names}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"
-- Section labels for Shift+letter detail readouts. Inserted as
-- "{Label}: " between sections by newDetail.compose() at transitions
-- the engine's first item doesn't already anchor (Help and Income
-- reuse engine TXT_KEY_HELP / TXT_KEY_EO_INCOME).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "Edad de Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "Religiones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "Grandes personajes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "Influencia"
-- Empire status readout payloads. Each STATUS_* below is one composed line
-- spoken by a bare-letter empire-status key (T/R/G/H/F/P/I) or its Shift+
-- detail variant; the active variant is selected by the live engine state
-- (e.g. STATUS_HAPPY when net happiness is non-negative, STATUS_UNHAPPY
-- between -1 and -9, STATUS_VERY_UNHAPPY below). _OFF tokens fire when the
-- corresponding system is disabled in the game options. The HELP_KEY /
-- HELP_DESC pairs further down cover all of these for the help overlay.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} felicidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "Infeliz menos {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "Muy infeliz menos {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    one = "Edad de Oro durante {1_Turns} turno",
    other = "Edad de Oro durante {1_Turns} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "{1_Cur} de {2_Threshold} para la Edad de Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "Felicidad desactivada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} de fe, {2_Total} total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "Religión desactivada"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PANTHEON, which inlines a long rules
-- explainer after the data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "{1_Num} de fe para el siguiente panteón"
-- Replaces TXT_KEY_TP_FAITH_PANTHEONS_LOCKED, a four-sentence rules
-- paragraph with no live data.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "no hay panteones disponibles"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PROPHET, a one-sentence verbose phrasing
-- that wraps a single data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "{1_Num} de fe para el siguiente gran profeta"
-- Replaces TXT_KEY_TP_TECH_CITY_COST and TXT_KEY_TP_CULTURE_CITY_COST,
-- both one-sentence explainers wrapping a single percent. The engine's
-- policy version also tacks on a "don't expand too much!" rules nudge.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "+{1_Pct}% de coste de tecnología por ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "+{1_Pct}% de coste de política por ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    one = "+{1_Rate} cultura, {2_Turns} turno para política",
    other = "+{1_Rate} cultura, {2_Turns} turnos para política",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "+{1_Rate} cultura, no quedan políticas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] =
    "sin cultura, {1_Cur} de {2_Cost} para la siguiente política"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "Políticas desactivadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} turismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    one = "+{1_Rate} turismo, influyente en {2_Count} civilización",
    other = "+{1_Rate} turismo, influyente en {2_Count} civilizaciones",
}
-- Plural is driven by {3_Total}: "1 of 1 civ" vs "1 of 5 civs". {2_Count}
-- can be 1 even when Total is many.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    one = "+{1_Rate} turismo, influyente en {2_Count} de {3_Total} civilización",
    other = "+{1_Rate} turismo, influyente en {2_Count} de {3_Total} civilizaciones",
}
-- Help-overlay entries for the empire status readout keys above. Each
-- pair is one row in the help screen: KEY_* names the keystroke, DESC_*
-- summarises what the key reads. The bare-letter variants (T R G H F P I)
-- speak the headline summary; the Shift+letter _DETAIL variants speak the
-- per-source breakdown.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "Turno y fecha, con suministro de unidades si se supera el límite y escasez de recursos estratégicos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "Investigación activa y ciencia por turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "Oro por turno, total y rutas comerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "Felicidad del imperio, número de lujos que aportan felicidad y Edad de Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "Fe por turno y total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] =
    "Cultura por turno y tiempo para la siguiente política"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] =
    "Turismo por turno y número de civilizaciones bajo influencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Mayúsculas más R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "Desglose de ciencia por fuente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Mayúsculas más G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "Ingresos y gastos de oro por fuente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Mayúsculas más H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "Fuentes de felicidad, fuentes de infelicidad y efecto de la Edad de Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Mayúsculas más F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "Desglose de fe por fuente y tiempo para el siguiente profeta o panteón"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Mayúsculas más P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "Desglose de cultura por fuente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Mayúsculas más I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "Grandes obras, ranuras vacías y número de civilizaciones bajo influencia"
-- Task list readout. Scenario-driven objective tracker; silent when no
-- active tasks exist (the common case outside scenarios and tutorials).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Mayúsculas más T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "Leer tareas activas del escenario"
-- GameMenu (Esc pause menu) tab labels and mod-list payloads. Tab labels
-- sit alongside the engine-keyed Details tab (TXT_KEY_POPUP_GAME_DETAILS).
-- The Mods tab lists every mod active in the current save: NO_MODS for the
-- empty-list state, MOD_ENTRY for each row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "Acciones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "No hay mods activados."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, versión {2_Version}"
-- Civilopedia (picker/reader two-tab) strings. PICKER_READER_EMPTY and
-- _NO_SELECTION are the two empty-state words used by the shared
-- PickerReader widget; they are mirrored in the FrontEnd strings file
-- because PickerReader serves both Contexts (saves picker, mods picker,
-- replay picker on the front-end side; civilopedia on the in-game side).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "Categorías"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "Contenido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "No hay texto de artículo disponible."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "No hay contenido para esta entrada."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "Ninguna entrada seleccionada. Cambia a la pestaña de categorías para elegir una."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "Introducción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "Inicio del historial."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "Fin del historial."

-- Batch 8 (lines 1672-1854): HELP_DESC_PEDIA_HISTORY through TECHTREE_HELP_KEY_CLOSE.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "Artículo anterior o siguiente del historial"
-- AdvisorInfoPopup (BUTTONPOPUP_ADVISOR_INFO). Concept drill-down reachable
-- from the tutorial advisor question buttons and from any related concept
-- link within the popup itself. The boundary announcements reuse
-- TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY / _NO_NEXT_HISTORY -- same
-- "Start of history." / "End of history." text, no reason to duplicate.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] = "Concepto anterior o siguiente del historial"
-- SaveMenu. Two-tab picker/reader over the in-game Save screen. Picker lists
-- existing saves (or cloud slots); reader shows header fields and exposes
-- the Overwrite / Save-to-slot / Delete actions behind pushed Yes/No subs.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "Partidas guardadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "Detalles de la partida guardada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "No hay partidas guardadas en esta lista."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "Nombre de la partida guardada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] = "El nombre está vacío o contiene caracteres no válidos."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "Sobreescribir esta partida guardada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "Guardar en este espacio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "Sobreescribir {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] =
    "Sobreescribir el espacio {1_Num} de Steam Cloud?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "Eliminar {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "Partida guardada eliminada."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Espacio {1_Num} de Steam Cloud: vacío"
-- Spoken replacements for [ICON_*] markup. Registered into TextFilter by
-- CivVAccess_Icons.lua; the filter substitutes the bracket token inline
-- with the spoken text. Singular / plural wording is deliberately relaxed
-- ("turns", "whales") because screen-reader users tolerate minor grammar
-- over awkward branching, and Civ's text uses these icons in both counts.
-- Mirrored in the FrontEnd strings file (each Context has its own
-- sandboxed CivVAccess_Strings table). Keep the two in sync when adding
-- or renaming icon keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "comida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "cultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "ciencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "ciencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "fe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "turismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "grandes personajes"
-- Dedup-only alias. Engine source: the singular pairings in base text such
-- as TXT_KEY_RELIGION_GREAT_PERSON_FOCUS ("Great Person Focus") and "a
-- Great Person of your choice" boilerplate. Match the singular form the
-- engine uses next to the icon. See the "_ALT keys" note in the orientation
-- block above for translator guidance.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "gran personaje"
-- Per-specialist title aliases. Engine source: TXT_KEY_SPECIALIST_<X>_TITLE
-- in CIV5GameTextInfos_Objects.xml -- ARTIST, ENGINEER, MERCHANT, SCIENTIST.
-- en_US prints "Great <X> Points:"; locales whose phrasings share no common
-- prefix (e.g. fr_FR "Points d'artistes illustres :", "Points de savants
-- illustres :") need one entry per specialist. Match the literal engine
-- phrase in the target locale; do NOT translate the en_US value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "puntos de gran artista"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "puntos de gran ingeniero"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "puntos de gran mercader"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "puntos de gran científico"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "gran obra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "fuerza de combate"
-- Dedup-only alias. Engine source: TXT_KEY_PRODUCTION_STRENGTH (en_US
-- "[ICON_STRENGTH] Strength: N", es_ES "[ICON_STRENGTH] Fuerza: N").
-- Match the bare strength word the engine prints in the target locale.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = "fuerza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "fuerza de combate a distancia"
-- Dedup-only alias. Engine source: TXT_KEY_PRODUCTION_RANGED_STRENGTH
-- (en_US "[ICON_RANGE_STRENGTH] Ranged Strength: N", es_ES
-- "[ICON_RANGE_STRENGTH] Fuerza a distancia: N"). Match the engine phrase.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = "fuerza a distancia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "movimientos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "felicidad"
-- Dedup-only alias. Engine source: base text pairs the positive-happy glyph
-- with "Happy" as well as "Happiness" (TXT_KEY_LOCAL_CITY_HAPPY_TEXT and
-- the per-yield TXT_KEY_PRODUCTION_BUILDING_HAPPINESS line which uses
-- "Happiness"). Match the shorter form ("happy" / locale equivalent).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "infelicidad"
-- Dedup-only alias. Same pattern: base text pairs the unhappy glyph with
-- "unhappy" alongside "unhappiness". Match the shorter form.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "izquierda"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "derecha"
-- ChooseProduction popup. Wrapped BaseMenu with two tabs (Produce, Purchase)
-- and five groups per tab (Units, Buildings, Wonders, Other, Current queue).
-- Append-mode commit speaks post-commit queue length so the player hears the
-- fill state as they chain picks; queue-full closes the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "Elegir producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "Producir"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "Comprar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "Cola actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "marioneta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "añadido, espacio {1_Slot} en cola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "cola llena"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "la cola está vacía"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "la cola tiene {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    one = "{1_Num} turno",
    other = "{1_Num} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} fe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "construyendo {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "comprado {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    one = "{1_Name}, {2_Turns} turno",
    other = "{1_Name}, {2_Turns} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"
-- ChooseTech popup. Flat BaseMenu list of researchable techs with the current
-- research pinned on top in free / stealing modes. Activate commits via
-- Network.SendResearch; F6 and the bottom-of-list item both escalate to the
-- full tree through OpenTechTree (defined in TechPopup.lua, same Context).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "Elegir investigación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "tecnología gratis, quedan {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "robando a {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} ciencia por turno"
-- Plural is driven by {2_Turns}.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    one = "investigando ahora {1_Name}, {2_Turns} turno",
    other = "investigando ahora {1_Name}, {2_Turns} turnos",
}
-- Per-tech state words on the picker. FREE fires only in free-tech mode
-- (Liberty finisher, Great Scientist bulb, etc.) for techs that count as
-- gainable for free. CURRENT marks the active research line. QUEUED marks
-- a slot in the planned queue; {1_Slot} is the 1-based queue position
-- counted after the current research (slot 1 = first queued, not the
-- active one).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "gratis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "investigando ahora"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "espacio {1_Slot} en cola"
-- Plural driven by {1_Num} (turn count).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    one = "{1_Num} turno",
    other = "{1_Num} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "Abrir árbol de tecnologías"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "investigando {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "obtenido {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "robado {1_Name}"
-- Tech Tree screen. TabbedShell with a hand-rolled DAG cursor tab and a
-- BaseMenu read-only queue tab. Landing speech on every arrow move
-- composes name, status, queue slot (if queued), turns, and unlocks
-- prose. Mode preamble reuses CHOOSETECH_PREAMBLE_* keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "Árbol de tecnologías"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "Todas las tecnologías"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "Cola"
-- Per-tech state words. AVAILABLE: pickable now. UNAVAILABLE: prereqs not
-- met by the player's current research state. LOCKED: in the queue but
-- waiting on an earlier-queued tech to finish (a sequential block, not a
-- prerequisite block). RESEARCHED: already complete.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "investigada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "requisitos previos no cumplidos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "sin investigación actual, cola vacía"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "en cola {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "ya investigada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "no disponible como tecnología gratis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "no se puede robar"
-- Tree-tab arrow help is mode-aware. The screen swaps which of the two
-- DESC strings is shown based on the active mode (grid vs tree). KEY is
-- the same chord set in both modes; the description is what changes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Arriba/Abajo/Izquierda/Derecha"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Arriba/Abajo por la columna de era, Izquierda/Derecha por la fila"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Derecha para tecnología dependiente, Izquierda para requisito previo, Arriba/Abajo para hermanas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Espacio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] =
    "Alternar navegación en cuadrícula o en árbol"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "cuadrícula"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "árbol"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "Investigar tecnología seleccionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Mayúsculas más Intro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "Poner en cola la tecnología seleccionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Control más I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "Abrir entrada de Civilopedia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "Letra / dígito / espacio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "Escribe para buscar por nombre o desbloqueos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "Cerrar árbol de tecnologías"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"

-- Batch 9 (lines 1855-2008): TECHTREE_HELP_DESC_CLOSE through DIPLO_INFLUENCE.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "Cerrar árbol de tecnologías"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "Políticas sociales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "Políticas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "Ideología"
-- Branch-level status words (top tier of the policy tree). OPENED: at
-- least one policy in the branch is adopted. FINISHED: every policy in
-- the branch is adopted. ADOPTABLE: branch is closed but the player has
-- the culture to open it. LOCKED_ERA / LOCKED_RELIGION / LOCKED: cannot
-- open yet because of era requirement, missing religion, or unmet
-- prerequisite. BLOCKED: a mutually-exclusive branch was opened first
-- (the policy UI shows this as a red-X, separate from the "needs prereq"
-- lock the tech tree spells "locked").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "abierta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "completada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "adoptable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "bloqueada, requiere {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] =
    "bloqueada, requiere una religión fundada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} de {2_Total} adoptadas"
-- Individual-policy status words (one tier down, applies to each policy
-- inside an opened branch). OPENER / FINISHER mark the two automatic
-- bookend policies. ADOPTED: chosen and active. ADOPTABLE: selectable now
-- with the player's current culture. BLOCKED: prerequisite policy in the
-- same branch hasn't been adopted yet (a within-branch sequencing block,
-- distinct from STATUS_BLOCKED above which is a cross-branch ideology
-- conflict). LOCKED: the parent branch isn't opened.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] = "apertura, otorgada gratis al abrir la rama"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] = "cierre, concedida al completar la rama"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "adoptada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "adoptable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "bloqueada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "bloqueada, requiere {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "abrir {1_Branch}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] =
    "{1_Cur} de {2_Cost} cultura, {3_Per} por turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    one = "{1_Turns} turno para la siguiente política",
    other = "{1_Turns} turnos para la siguiente política",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    one = "{1_Num} política gratis disponible",
    other = "{1_Num} políticas gratis disponibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    one = "{1_Num} doctrina gratis disponible",
    other = "{1_Num} doctrinas gratis disponibles",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "ideología no adoptada aún"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "ideología desactivada en esta partida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "Doctrinas de nivel 1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "Doctrinas de nivel 2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "Doctrinas de nivel 3"
-- Ideology tenet-slot rows. {1_Num} is the slot index within its level.
-- _FILLED carries the picked tenet's name and short effect; _NAME_ONLY
-- omits the effect (used in compact contexts). The four EMPTY_* variants
-- describe why the slot can't be picked yet: AVAILABLE means it can be
-- picked now; REQ_SLOT means another slot in the same level must be
-- filled first ({2_Req} is that slot's index); REQ_CROSS means the
-- prerequisite is in a different level ({2_Level} is the ideology tier
-- 1 / 2 / 3, {3_Req} is the slot index within that tier); CULTURE means
-- the player does not have enough culture for any tenet right now.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "ranura {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "ranura {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "ranura {1_Num}, vacía, disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
    "ranura {1_Num}, vacía, requiere ranura {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "ranura {1_Num}, vacía, requiere ranura {3_Req} de nivel {2_Level}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] =
    "ranura {1_Num}, vacía, cultura insuficiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "cambiar ideología"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "cambiar ideología, no disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "infelicidad {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "Elegir doctrina"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "no hay doctrinas disponibles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "Adoptar {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "Abrir rama {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "Adoptar {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "Cambiar ideología?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "adoptada {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "abierta {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "doctrina adoptada {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "cambio de ideología solicitado"
-- Number-entry primitive (BaseMenuNumberEntry). Digits / Backspace / Enter /
-- Esc bindings with their own help strings because the digit surface isn't
-- covered by the menu's standard A-Z search entry.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Dígitos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Retroceso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "Añadir dígito"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "Eliminar último dígito"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "Confirmar cantidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "introduce {1_Label}, máximo {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "vacío"
-- Diplomacy trade screen. Labels for the flat top-level menu (Your / Their
-- Offer), drawer tab names, quantity-bearing Offering lines, and the Other
-- Players group for third-party peace / war actions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "Comercio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "Comercio con {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "Tu oferta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "Su oferta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "Oferta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "Disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, población {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "compromiso de voto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "hacer las paces con {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "declarar la guerra a {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "Hacer las paces"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "Declarar la guerra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "Otros jugadores"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "ninguno disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "nada sobre la mesa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "tú tienes {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "ellos tienen {1_Num}"
-- DiploCurrentDeals review labels. Each deal renders as one Text leaf
-- whose label inlines the full contents; these are the side prefixes the
-- builder concatenates around the per-item descriptions. Colon-then-list
-- form, distinct from LABEL_VALUE's space form and DIPLO_GOLD_AMOUNT's
-- comma form; the colon reads as a brief pause before the list of items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "damos: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "dan: {1_List}"
-- Past-tense variants for the Historical Deals group, where the deal has
-- already concluded.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "dimos: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "dieron: {1_List}"
-- DiploCurrentDeals tab title and the Historical Deals group label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "Acuerdos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "Acuerdos históricos"
-- Diplomatic Overview (Relations / Global tabs). Per-civ composed lines,
-- trade / third-party fragment prefixes, section group headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader} de {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "puntuación {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "oro {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "oro por turno {1_N}"
-- Per-resource entry inside strategic / luxury / nearby lists.
-- {1_Name} is the resource's localized name, {2_N} is the count owned.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "estratégicos: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "de lujo: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "cercanos: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "adicionales: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "políticas: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "maravillas: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "Civilizaciones mayores"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "Ciudades-estado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "Ninguna civilización conocida."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "Ningún acuerdo."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "propuesta entrante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "esperando respuesta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "equipo {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "investigando {1_Tech}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} influencia"

-- Batch 10 (lines 2009-2196): DIPLO_INFLUENCE_PER_TURN through LEADER_DESC_MISSING.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} por turno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "anclado a {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} cultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} felicidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} fe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} comida en la capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} comida en otras ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} ciencia"
-- Plural driven by {1_N} (turns until next gift unit arrives).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    one = "siguiente unidad de regalo en {1_N} turno",
    other = "siguiente unidad de regalo en {1_N} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "exportando {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "fronteras abiertas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "intimidable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "aliado de {1_Civ}"
-- F4 Diplomatic Overview tabs (Majors / Minors). Tab names reuse the
-- _MAJORS_GROUP / _MINORS_GROUP labels above. Column-header strings are
-- spoken when the user navigates onto a column; cell-content templates are
-- separate keys below. Headers stay terse since the column name already
-- carries the type and the cell value supplies the data.
-- Major civ columns. _YOUR_RELATIONSHIP carries the AI's stance toward us
-- (war / hostile / guarded / etc.) followed by active treaties (embassies,
-- open borders, defensive pact, research agreement, trade-agreement
-- legality). _FOREIGN_RELATIONS carries the same civ's third-party state
-- (their wars with other majors, DoFs, denouncements, CS alliances).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "tu relación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "relaciones exteriores"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "recursos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "era"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "políticas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "maravillas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "puntuación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_DECLARE_WAR"] = "declarar la guerra"
-- Minor civ columns. _RELATIONSHIP carries the bonuses currently flowing
-- from a Friends / Allies CS (culture, food, science, faith, happiness,
-- spawn estimate). _TRAIT_PERSONALITY carries trait then personality as a
-- thematic pair. Influence column carries value + per-turn + anchor +
-- threshold-gap to the next state. Allied-with carries the current ally
-- (or "nobody") plus displacement value. Quests and Nearby resources
-- carry their respective lists.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "relación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "rasgo y personalidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "influencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "aliado con"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "misiones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "recursos cercanos"
-- Empty-cell labels. "none" for absent items in a list-shaped cell;
-- "nobody" for the Allied-with column where the absence is an actor, not
-- an item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "ninguno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "nadie"
-- Gold cell: gold on hand plus per-turn rate. {2_GPT} carries its sign so
-- the same template covers gain and loss.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, {2_GPT} por turno"
-- Influence threshold gap fragments, appended after the value / per-turn /
-- anchor block in the Influence cell. _TO_FRIENDS shows when below friends
-- threshold; _TO_ALLIES shows when between thresholds.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "{1_N} necesario para ser amigos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "{1_N} necesario para ser aliados"
-- Allied-with cell variants. _ALLY_IS_YOU when we're the ally (no
-- displacement number to compute). _ALLY_AND_DISPLACE when someone else is
-- allied: civ short name plus the influence we'd need to gain over the
-- current ally.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "tú"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, {2_N} necesario para desplazar"
-- Unmet-ally variant: a civ we haven't met holds the alliance. The
-- displacement number is still meaningful (we know our own influence
-- and can read the engine's record of theirs) but we can't name them,
-- so the cell distinguishes from "nobody" (the genuine no-ally case)
-- with a generic civ word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] =
    "civilización desconocida, {1_N} necesario para desplazar"
-- Trait-and-personality cell. Trait first, personality second, paired
-- since trait determines what kind of bonus would flow and personality
-- modifies how easily influence shifts.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL"] = "{1_Trait}, {2_Personality}"
-- City Stats drillable. The Stats hub item pushes a sub-handler whose
-- top-level items are these category groups. Per-yield drill-ins reuse
-- the existing CITYVIEW_YIELD_* one-line headers (food / production /
-- gold / etc.) so the per-turn label is identical whether the user reads
-- it from the Yields-group root or the individual yield's drill-in
-- header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "Rendimientos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "Religión"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "Rutas comerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "Recursos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "desglose no disponible"
-- Storage / threshold tail appended to the food and culture yield rows.
-- Bare numerator-of-denominator since the row's headline already names
-- the resource ("food 5, 12 of 22, grows in 4 turns").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{1_Cur} de {2_Threshold}"
-- Culture's next-tile countdown. Borrowed by both the culture yield's
-- extras tail (CityStats) and the hex-cursor culture readout
-- (CitySpeech.borderGrowthToken); shared so the wording stays
-- consistent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    one = "siguiente casilla en {1_Num} turno",
    other = "siguiente casilla en {1_Num} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "expansión de casillas detenida"
-- Happiness one-liner: local-only contribution from buildings here, plus
-- the per-city slice of the empire's unhappiness pool (population /
-- occupied / specialists already folded in by the engine).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] =
    "felicidad local {1_Local}, infelicidad {2_Unhappiness}"
-- Religion group: one row per religion present, holy-city flag inlined
-- when applicable so the user hears it together with that religion's
-- numbers rather than as a separate line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    one = "{1_Religion}, {2_Followers} seguidor, {3_Pressure} presión",
    other = "{1_Religion}, {2_Followers} seguidores, {3_Pressure} presión",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    one = "{1_Religion}, ciudad santa, {2_Followers} seguidor, {3_Pressure} presión",
    other = "{1_Religion}, ciudad santa, {2_Followers} seguidores, {3_Pressure} presión",
}
-- Resource group: name leads (matches the rest of the section's
-- distinguishing-info-first ordering), count second.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RESOURCE_LINE"] = "{1_Name} {2_Num}"
-- ChooseInternationalTradeRoutePopup row format: destination identifier
-- (city, plus civ for major-civ rows), hex distance, then yields split
-- into "you get" / "they get" sides matching the engine's myBonuses /
-- theirBonuses bucketing. Religion-pressure direction verified against
-- Community-Patch-DLL CvLuaPlayer.cpp lGetPotentialInternationalTrade
-- RouteDestinations.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
-- Plural driven by {1_Num} (hex distance to destination).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = {
    one = "{1_Num} hex",
    other = "{1_Num} hexes",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "Obtienes {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "Obtienen {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} obtiene {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} presión de {2_Religion}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "No hay destinos válidos."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "No hay ciudades de origen válidas."
-- Trade Route Overview (TRO) screen. Distinct from the per-pick
-- ChooseInternationalTradeRoutePopup above: TRO is the standalone Ctrl+T
-- screen that surveys every trade route currently active in the game.
-- Three tabs: Yours (your active routes), Available (routes you could
-- start but haven't), and With You (routes other civs run to your
-- cities). Domain words distinguish caravan (land) from cargo ship (sea).
-- ROUTE_HEADER carries five placeholders: domain word, source city, source
-- civ, destination city, destination civ.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Control más T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "Abrir vista general de rutas comerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "Tus rutas comerciales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "Rutas comerciales disponibles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "Rutas comerciales con tus ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "caravana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "barco de carga"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} a {3_To}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "la ciudad-estado de {1_City}"
-- Plural driven by {1_Num} (turns until the route arrives at its
-- destination and resolves).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    one = "{1_Num} turno restante",
    other = "{1_Num} turnos restantes",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "No hay rutas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "No hay desglose de origen disponible."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "Ordenar por: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "Ordenar por"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "oro recibido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "ciencia recibida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "comida recibida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "producción recibida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "presión religiosa al destino"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "Describir líder"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "No hay descripción disponible para este líder."

-- Leader-portrait prose. Spoken in full when the user inspects a leader
-- portrait. Multi-paragraph descriptive prose; treat as literary text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "George Washington, primer presidente de los Estados Unidos, está de pie en un interior con paneles de madera entre pesadas cortinas rojas recogidas a ambos lados, las manos sueltas en las caderas. Viste la ropa civil negra de un caballero americano de finales del siglo XVIII: un oscuro abrigo cruzado cortado largo sobre los muslos, con dos filas de botones de latón en el frente, un chaleco a juego debajo, un jabot blanco fruncido en el cuello y puños blancos en las muñecas. Su cabello está empolvado de blanco, peinado hacia atrás desde una frente alta, rizado a los lados sobre las orejas y recogido en la nuca con una coleta atada con una cinta de seda negra. A su izquierda, un gran globo terráqueo reposa sobre un pie torneado de madera; sobre una pequeña mesa junto al pie, un volumen encuadernado yace abierto con un marcador de cinta azul que cae de sus páginas. A su derecha, una repisa de piedra pálida sostiene un alto candelabro de latón con velas sin encender, y encima cuelga un paisaje enmarcado en un marco dorado. Entre las cortinas abiertas detrás de él, una columna acanalada se eleva contra un cielo diurno y un atisbo de campiña verde ondulada. La composición recrea el retrato Lansdowne de Gilbert Stuart de 1796, con la espada ceremonial y los documentos de Estado sustituidos aquí por el globo y el libro."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "Harun al-Rashid, Comendador de los Creyentes y quinto califa de los abasíes, está sentado en un jardín de palacio a media mañana, con un patio empedrado que se abre detrás de él hacia una pálida columnata de piedra de arcos apuntados y una cúpula lejana que emerge entre la bruma al fondo. Es barbudo y de cabello oscuro, sentado en una silla baja de madera tallada cuyos reposabrazos terminan en remates redondeados, la cabeza envuelta en un alto turbante azafrán con un gorro blando que se eleva en su cima. Una ancha faja del mismo paño azafrán, con los extremos brocados y ribeteados de flecos dorados, le cruza el pecho desde el hombro derecho y se recoge en la cadera izquierda sobre una holgada túnica blanca que cae hasta los tobillos, con el bajo de la túnica bordeado del mismo brocado dorado. La mano derecha, alzada cerca del hombro, sujeta un qalam, el cálamo árabe de caña, entre el pulgar y el índice; la mano izquierda reposa plana sobre el regazo. Los pies están posados sobre una alfombra redonda tejida en medallones azules, crema y óxido, y sobre las losas a su lado yacen dos códices encuadernados, el superior de tapa roja intensa gofrada en oro. Cícadas y helechos en macetas de loza azul vidriada flanquean la silla a uno y otro lado, una alta urna de terracota se alza a la derecha, y oscuros setos cierran el plano medio bajo la arcada."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "Asurbanipal, Rey del Mundo, Rey de Asiria, está de pie en una sala con columnas de su palacio, con una tablilla de piedra pálida sostenida en posición vertical contra su pecho con la mano derecha, los dedos curvados sobre el borde superior. Es de hombros anchos y brazos desnudos, con la piel cálida bajo la luz. Su barba es larga y recortada en cuadrado, peinada en apretados rizos paralelos hasta el pecho, con el cabello negro cayendo en bucles a juego hasta el hombro. Una baja diadema de oro le rodea la frente, con la banda trabajada con rosetas. Lleva el chal real hasta los tobillos de la corte asiria: una túnica interior de azul intenso sembrada de rosetas doradas, cubierta por un pesado manto magenta cuyo borde con flecos discurre en diagonal por el torso, sobre el hombro izquierdo y por la espalda, con los dobladillos bordeados de bordado dorado y rojo. Amplias muñequeras de oro sujetan ambas muñecas, y una banda a juego rodea su brazo derecho por el bícep. Detrás de él se eleva un nicho en arco enmarcado por esbeltas columnas con capiteles de volutas pálidas; a cada lado, sobre pedestales, se alzan las oscuras figuras barbadas de lamassu, los toros alados con cabeza humana que guardaban las puertas de los palacios asirios. En la pared del fondo, bajos relieves de piedra muestran caballos de perfil en un friso horizontal, a semejanza de los paneles de caza y carro de su palacio de Nínive. El suelo está pavimentado con losetas pálidas y la sala se pierde en sombras a ambos lados."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "María Teresa, por la Gracia de Dios Emperatriz viuda de los Romanos, Reina de Hungría, de Bohemia, de Dalmacia, de Croacia, de Eslavonia, de Galitzia, de Lodomiria, Archiduquesa de Austria (y así sucesivamente), está de pie en una logia de piedra con arcadas, una galería cubierta cuyos altos arcos de medio punto se abren por un lado a un paisaje alpino de cimas nevadas, y por el otro a un suelo pulido con un pasillo de alfombra roja tendido a lo largo de la columnata. Paneles de damasco rojo cuelgan entre los arcos en el muro interior, y la luz del sol procedente de la izquierda proyecta largas sombras sobre la piedra. Está de pie en tres cuartos, los brazos cruzados ligeramente a la cintura, la cabeza vuelta levemente hacia otro lado. El cabello, de rubio pálido, está recogido y prendido en lo alto al estilo de la corte. Su vestido es de seda gris azulado pálido; el corpiño está ceñido con cordones hasta una punta en la cintura y lleva en el frente un peto, el panel decorado y rígido trabajado en bordado de plata y pequeñas joyas. Una amplia falda con aros se extiende sobre los panier, el mismo bordado de plata recorriendo en una franja ondulante el frente abierto de la sobrefalda. Las mangas terminan en el codo en cortos frunces ribeteados de encaje blanco. Un pañuelo de encaje fino se pliega sobre los hombros y se mete en el escote. No lleva corona ni joyas visibles. Detrás de ella los arcos se alejan en piedra pálida, la balaustrada de pilares torneados se prolonga hacia la lejanía, los Alpes resplandecientes y el cielo despejado."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "Moctezuma Xocoyotzin, Huey Tlatoani de los mexicas, está de pie ante un gran brasero cuyas llamas se alzan entre él y el espectador, iluminada la sala que lo rodea únicamente por ese fuego. Es de torso desnudo y complexión robusta, la piel oscura a la luz del fuego, el rostro medio en sombra. Su corona es el quetzalapanecayotl, un penacho de largas plumas tornasoladas de la cola del quetzal en verde y azul sujeto con una diadema de oro. Carretes de oro perforan sus orejas, un collar de jade y oro rodea su cuello, anchos brazaletes de jade y oro ciñen sus muñecas, y bandas de oro circundan cada bíceps. Detrás de él, embutido en un muro de mampostería roja, un gran disco tallado muestra bandas concéntricas de glifos en torno a un rostro central, a semejanza de la Piedra del Sol azteca. Las paredes a uno y otro lado están talladas en hileras de calaveras estilizadas, el tzompantli, el bastidor de cráneos expuesto en los templos aztecas; sobre cada bastidor se alza una gran máscara tallada de una deidad azteca, y una urna de piedra en lo alto de cada muro arde con una llama alta. Toda la sala resplandece en el rojo y el oro de la lumbre."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "Nabucodonosor II, Rey de Babilonia, está sentado en un trono de piedra maciza en una sala de mampostería bañada en luz verde, con las paredes que se pierden en la penumbra a su espalda. Lleva el agu, el alto gorro redondeado de los reyes neobabilónicos, con una banda en la frente. Su barba es larga, oscura y peinada en hileras escalonadas de apretados rizos tubulares. Su túnica es de un rojo intenso, de manga corta y cubierta por completo de rosetas doradas equidistantes, ceñida en la cintura con un ancho fajín bordado; la falda cae recta hasta sus pies descalzos, ribeteada con una cenefa de flecos pálidos. Pesadas muñequeras de oro sujetan cada muñeca. Sus manos reposan con las palmas hacia abajo sobre los anchos brazos del trono, que terminan al frente en ménsulas talladas en forma de cabeza de león con las fauces abiertas vueltas hacia fuera a la altura de sus rodillas; un par menor de cabezas de león a juego sobresale de la base del trono junto a sus pies. A ambos lados del trono se alzan dos altos pedestales de piedra tallados con cuerpos serpentinos enroscados, cada uno rematado por un cuenco ancho y poco profundo del que surge una llama verde pálido, la única luz de la sala, que proyecta su enfermizo verde sobre las paredes de piedra, el rostro del rey y su túnica."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "Dom Pedro II, Emperador del Brasil, está sentado ante un amplio escritorio de madera en un oscuro estudio con paneles, y la escena queda encuadrada como si el espectador estuviera al otro lado del escritorio frente a él. Es un hombre mayor, de hombros anchos y complexión robusta, con una larga barba blanca que le cae muy por debajo del cuello y el cabello blanco, algo escaso, peinado hacia atrás desde una frente despejada y alta. Viste una levita oscura sobre un chaleco oscuro y una camisa blanca de cuello alto con una corbata oscura en la garganta. En el pecho izquierdo lleva prendida la estrella enjoyada de la Orden Imperial de la Cruz del Sur, de la que era Gran Maestre. Ambas manos reposan planas sobre el escritorio; delante de él hay papeles sueltos y un pequeño tintero, y una pluma de ave está erguida en un portaplumas redondo junto a su mano derecha. Sobre el escritorio, a su izquierda, se alza una lámpara de aceite encendida con una larga chimenea de vidrio transparente y una base de latón bruñido; su llama es el punto más luminoso de la imagen y la fuente principal de la luz que ilumina su rostro y sus manos. Detrás de él y a los lados, las paredes están cubiertas de arriba abajo por estanterías de libros sumidas en la penumbra. Una alta ventana junto a su hombro izquierdo muestra un fragmento de cielo nocturno en azul intenso a través de celosías de madera en ángulo, con frondas de palma recortadas más allá en silueta. En el extremo izquierdo del encuadre, una ventana más pequeña de vidrio emplomado con rombos recoge los tonos más cálidos de un cielo crepuscular, y un pequeño reloj de repisa descansa en un estante bajo ella. El suelo está cubierto por una alfombra de motivos en rojos y dorados apagados."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "Teodora, Augusta de los romanos, está recostada en un diván bajo de brocado dorado sobre una terraza abierta con columnata, con un brazo apoyado a lo largo de un cojín cilíndrico y el otro reposando en su regazo. Su corona es un stemma enjoyado, el casquete abovedado del tocado imperial bizantino, cuya banda está guarnecida con una hilera de piedras cabujón. Una joya verde ocupa un lugar prominente en la frente; el remate que se alza sobre ella llega hasta una segunda piedra verde engastada en filigrana de oro. El cabello está recogido bajo la corona y cae largo sobre el hombro derecho. Los pendilia, los colgantes con perlas del stemma, enmarcán su rostro; un maniakis le rodea la garganta, el collar imperial enjoyado del Oriente. Su vestido es de capas superpuestas: un corpiño ceñido de rojo intenso abrochado en el centro con un medallón de oro, una falda de seda verde dorada con motivos de volutas que cae sobre el regazo, y bajo ella una larga falda interior de azul verdoso oscuro ribeteada en el bajo con una estrecha franja dorada. Puños de oro le ciñen las muñecas. Una pesada cortina roja cae detrás de ella a la derecha, apartada para revelar la escena más allá. La terraza está pavimentada en piedra cálida y delimitada por una balaustrada tallada con urnas de flores rojas, con dos columnas de mármol pálido que enmarcan la vista. Al otro lado de un amplio valle se alza la Hagia Sophia, con su amplia cúpula central flanqueada por una semidome inferior, las paredes leonadas bajo la luz del sol, y las colinas bajas desvaneciéndose en azul detrás bajo un cielo despejado."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "Dido, reina fundadora de Cartago, está de pie en una terraza del palacio de noche. Detrás de ella, el cielo es azul profundo y tachonado de estrellas, con un lejano promontorio apenas visible en el horizonte sobre un bajo parapeto. Un banco de piedra curvo hay a su espalda, con el remate tallado en un friso de volutas, y columnas pálidas se alzan por detrás. A ambos lados de la terraza, dos grandes arbustos en maceteros de piedra pálida tienen hojas oscuras y pequeñas flores rojas: granados, cuyo nombre latino punicum los señala como el árbol de Cartago. Es de tez clara, con el cabello oscuro partido por el centro y cayendo más allá de los hombros, y una fina diadema dorada en la frente. Su vestido es un chiton pálido, casi blanco, la túnica griega prendida en los hombros y ceñida en la cintura, con la falda hasta el suelo sembrada de un tenue dibujo tejido. Unas mangas cortas con abertura están prendidas a intervalos por el brazo con pequeños broches, y un ancho fajín azul intenso le rodea la cintura y cae en un largo panel por el frente de la falda. En la garganta lleva un amplio pectoral de piedras oscuras engarzadas en oro, y una fina pulsera dorada rodea una muñeca. Sus manos reposan a los lados, la piedra a su alrededor fría bajo la luz nocturna."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "Boudicca, Reina de los icenos, está de pie en la ladera herbosa de una fortaleza en lo alto de una colina. A la izquierda hay una pared de piedra rematada por una empalizada de madera de estacas afiladas, con el tejado cónico de paja de una cabaña circular asomando por encima; a la derecha, una cadena de colinas verdes desciende bajo un cielo gris plomizo. Su cabello está recortado corto y es de un rojo cobrizo vivo, con un trozo de tela pálida atado en la parte trasera de la cabeza y cayendo por detrás del hombro. Una pequeña marca azul oscuro aparece en su pómulo bajo un ojo, del tipo de tinte vegetal que los antiguos britanos usaban como pintura corporal. Un torc celta, retorcido en oro y rígido, le rodea el cuello. Su vestido es una túnica sin mangas hasta la rodilla en un tejido a cuadros azul y verde, ceñida en la cintura con un cinturón de cuero y hebilla redonda. Unos vambraces de cuero están atados sobre sus muñecas y una protección a juego le rodea el brazo, las pantorrillas al aire sobre botas bajas de cuero. En su mano izquierda sostiene una espada corta de doble filo de La Tène, con la hoja que se afila hasta una punta y la empuñadura pequeña y lisa; su mano derecha agarra el asta vertical de una lanza clavada con la culata en el suelo. A su izquierda se encuentra un ligero carro de dos ruedas, con una sola rueda con radios de llanta de hierro y un haz de lanzas largas inclinadas hacia arriba desde su caja."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "Wu Zetian, Huangdi de la dinastía Tang, está de pie en el centro de una sala oscura entre pesadas cortinas rojas recogidas a ambos lados. Tras ella, una hilera de cálidas linternas doradas cuelga en la penumbra, y la pared oscura que las sostiene está decorada con paneles de celosía tallada. Su cabello negro está recogido y apilado en lo alto de la cabeza, sujeto en la parte delantera con un buyao, un adorno de oro y perlas. Viste un ruqun en capas superpuestas. Una túnica interior de seda dorada pálida se cruza en el pecho sobre un rígido panel dorado bordado con un medallón; una vívida faja roja, anudada en lo alto bajo el busto, cae como una larga falda hasta el suelo. Sobre todo esto lleva una túnica exterior de seda rojo intenso decorada con círculos dorados, con amplias mangas que descienden más allá de las manos y un largo ruedo extendido sobre el suelo en torno a sus pies. Sostiene con ambas manos una pequeña vasija dorada a la altura de la cintura, levantada ligeramente como si la ofrendara. Su tez es pálida, su expresión serena, su mirada tranquila. Las cortinas rojas, la túnica roja y las linternas doradas calientan el encuadre frente a la oscuridad de la sala."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "Harald 'Bluetooth' Gormsson, Rey de los daneses y de Noruega, está de pie a media eslora en la cubierta abierta de un drakkar. Es ancho y de complexión robusta; la barba, de un rubio rojizo, bifurcada en dos coletas trenzadas que caen por debajo del cuello, y el bigote largo y caído. La cabeza va descubierta, con el cabello recogido en un moño. Un manto de piel larga de color pardo rojizo descansa sobre sus hombros. Bajo él viste una túnica gris verdosa con un canesú más oscuro, cuyo dobladillo y puños están decorados con bandas cinceladas de entrelazado nórdico. Un ancho cinturón de cuero trabajado cruza su cintura, abrochado con una pesada hebilla cuadrada, y una segunda correa corre en diagonal sobre el pecho; ambas manos reposan sobre el cinturón a la altura del vientre. Su casco yace en cubierta junto a sus pies, una cúpula de hierro oscuro con refuerzo en la frente y en la nariz, y los laterales abiertos en redondeados faldones de gruesa piel parda rojiza. A su izquierda, el codaste de proa se curva hacia arriba y hacia adentro en una alta espiral de madera tallada a semejanza de una cabeza de dragón. Tras su hombro derecho los cabos del aparejo bajan desde el mástil, y por encima de ellos una vela cuelga en anchas franjas verticales de rojo y blanco. A lo largo de la regala un escudo redondo de madera está montado de cara al exterior, con su umbón de hierro en el centro. El cielo que se abre sobre ellos es azul, cruzado por altas nubes."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "Ramsés II, Faraón de las Dos Tierras, está sentado en un trono en lo alto de una corta escalinata, con una sala de altas columnas pintadas de azul que se abre a cada lado. Su rostro es joven y está rasurado, la piel de un bronce intenso y los ojos perfilados con un kohl oscuro. Su tocado es un nemes, un paño de rayas azules y doradas recogido junto a las sienes y cayendo en palapas plisadas hasta el pecho. En su frente se alza el uraeus, una cobra erecta que señala la realeza. A través de los hombros y el pecho lleva un wesekh, un amplio collar de hileras de cuentas apiladas en azul lapislázuli y dorado. Lleva un shendyt, un faldellín plisado faraónico de lino blanco largo, ceñido en la cintura por un ancho fajín azul y dorado que cae por delante en un rígido panel con dibujos. Los pies van con sandalias y reposan en el escalón superior. En la mano izquierda sostiene un alto bastón contra el hombro; la derecha descansa sobre el brazo del trono. Las columnas que lo flanquean están pintadas en registros de azul, oro y rojo, con capiteles en forma de haces de papiro y talladas en hileras de jeroglíficos y figuras erguidas. Ante el trono, a cada lado, se alzan dos grandes estatuas doradas de Isis y Neftis, las diosas protectoras, con las alas extendidas hacia delante y las plumas representadas en largas láminas doradas. Hojas de palmera se inclinan desde ambos lados y los escalones de piedra amarilla a sus pies están incisos con hileras de pequeños motivos triangulares. Toda la sala está bañada en un cálido dorado, siendo los azules de las columnas y el collar las únicas notas frescas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "Isabel I, por la Gracia de Dios Reina de Inglaterra, Francia e Irlanda, Defensora de la Fe, está sentada en un alto trono tallado flanqueado por dos candelabros sobre pedestales de piedra, con las velas sin encender. Sobre ella se alza un dosel de Estado, de pesado terciopelo rojo recogido en pliegues por cordones de flecos dorados, apenas visible la oscuridad de la cámara al fondo. El cabello, apilado en lo alto en apretados rizos de rubio rojizo, queda sujeto por una pequeña corona de pedrería; el cuello luce el gorguera abierto y rígido de la tardía corte Tudor. Su vestido es de brocado dorado bordado en negro, el corpiño ceñido y tachonado de joyas, las mangas abullonadas en el hombro y estrechándose hasta los puños de encaje, la falda extendida ampliamente sobre el farthingale. Largas sartas de perlas cruzan su pecho y caen desde la cintura, llevadas en su época como emblema de virginidad. Sus manos pálidas reposan sobre los brazos del trono."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "Haile Selassie I, Emperador de Etiopía, Elegido de Dios, León Conquistador de la Tribu de Judá, está de pie en una larga sala de recepciones de su palacio, con un pálido techo artesonado sobre su cabeza, altas ventanas a su derecha y una araña de cristal suspendida entre ellas. Es de complexión menuda y postura erguida, con barba oscura y el cabello cortado al ras. Viste una túnica militar oscura abotonada hasta el cuello, pantalones oscuros lisos y un ancho cinturón de cuero negro. Desde el hombro derecho hasta la cadera izquierda corre una amplia faja de moire verde esmeralda, la cinta de la Orden del Sello de Salomón. Cuatro filas de cintas en miniatura se agrupan en la parte alta de su pecho izquierdo, condecoraciones de campaña y honor acumuladas a lo largo de su reinado. Por debajo cuelgan dos grandes estrellas de pecho de las órdenes imperiales superiores, de ocho puntas y trabajadas en oro y esmalte. La mano izquierda descansa a su costado; la derecha sostiene un par de guantes. A su izquierda se alza el trono imperial: un sillón de respaldo alto tapizado en crema pálido y azul, con su coronamiento tallado en forma de corona arqueada y cubierto por un pano bordado, dispuesto sobre una alfombra roja de dibujos que recorre toda la longitud de la sala. Sillas tapizadas de tonos claros bordean las paredes detrás de él, perdiéndose en la profundidad de la estancia."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "Napoleón Bonaparte, Emperador de los Franceses, cabalga sobre un caballo gris claro en un campo crepuscular de hierba seca, con un cielo pardo rojizo y árboles desnudos a sus espaldas. Viste una casaca azul oscuro con pesadas charreteras doradas, chaleco blanco, calzón blanco y altas botas de montar negras. El bicornio lo lleva de través, con las dos puntas orientadas hacia los hombros, la postura que él prefería para distinguirse de sus oficiales. El freno del caballo es de cuero rojo tachonado con dorados; la mantilla que cubre la silla está ribeteada en rojo y oro. La composición evoca el cuadro Napoleón cruzando los Alpes de Jacques-Louis David, aunque detenida: sin caballo encabritado, sin mano señalando, solo una figura solitaria en el paisaje al atardecer."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "Otto von Bismarck, ministro-presidente de Prusia y primer canciller del Imperio Alemán, está de pie en una alta sala de Estado iluminada por la luz del día que entra a raudales por los ventanales emplomados que tiene a su espalda, cada hoja dividida en pequeños cuadrados por esbeltas junquillos. Pesados cortinajes carmesí caen drapeados y recogidos en cada ventana en pliegues profundos, con el forro interior de un rojo más oscuro. El suelo, pulido como un espejo, recoge la luz de las ventanas en largas bandas pálidas. A su izquierda, una pequeña mesa auxiliar sostiene una lámpara de globo blanco. Es alto y de hombros anchos, calvo en la coronilla con un cerco corto de cabello gris plateado a los lados y por detrás, y lleva un espeso bigote blanco, largo y vuelto hacia afuera en las puntas. Su abrigo es una levita militar de doble botonadura en pizarra oscura profunda, abrochada por el pecho con dos hileras paralelas de botones dorados, el cuello alto ribeteado en oro, los hombros cargados con pesadas charreteras de alamares dorados cuyo fleco cae hasta la parte alta del brazo. Justo debajo del cuello pende una pequeña cruz pálida sobre una cinta oscura, el Pour le Mérite, la más alta condecoración militar de Prusia. Está colocado en tres cuartos respecto al espectador, erguido e inmóvil, la mirada fija más allá del hombro del espectador."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "Alejandro Magno, Rey de Macedonia y Hegemon de los helenos, cabalga a horcajadas sobre su semental negro, Bucéfalo, refrenándolo en un verde prado de altura rodeado de cadenas de montañas grises a ambos lados y una sola cima nevada que se eleva a la derecha. Es joven y lampiño, con el cabello castaño partido al centro y levantado desde la frente en una anastole, el mechón alzado que se convirtió en rasgo distintivo de sus retratos. Viste una linothorax, armadura corporal helenística de capas de lino y cuero con revestimiento de placa dorada, cuyos yugos de hombro se atan sobre el pecho con cortas cuerdas. En el centro del pecho, una placa cuadrada dorada lleva un gorgoneion, la cabeza de Medusa en relieve. Desde los hombros y desde la cintura ceñida cuelgan pteruges, hileras de tiras de cuero rígido que protegen la parte superior de los brazos y los muslos, cada tira ribeteada en rojo y rematada con un remache dorado. Los brazos están desnudos, con una amplia pulsera de oro en la muñeca derecha; no lleva casco ni porta arma visible. Los arreos del caballo son de cuero oscuro trabajado con rojo, con el frontal y los montantes tachonados, y un solo ramal cruzado sobre el cuello sujeto en su mano izquierda. Bajo la silla de montar, una piel de leopardo moteada cubre el flanco del caballo, con las patas aún unidas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "Atila, Rey de los hunos, está sentado en un trono de madera de respaldo alto sobre un estrado elevado, con la sala a su alrededor iluminada en rojos profundos y dorado. Está recostado con comodidad, una pierna cruzada sobre la otra y una espada desenvainada tendida sobre su regazo; una mano reposa sobre la hoja y la otra sostiene una copa. Su túnica es roja y de manga larga, ribeteada en oro, y se lleva sobre unos pantalones azul oscuro metidos en altas botas de cuero suave ribeteadas de piel en el puño. Un gorro cónico de piel oscura con una banda dorada le cubre la cabeza. Lleva barba y bigote largo, el rostro medio iluminado desde la derecha. Los reposabrazos del trono terminan en cabezas de león talladas y una pesada piel está echada sobre el respaldo. Detrás de él, una pared de cortinaje rojo está flanqueada por paneles colgados con discos de bronce redondos de tamaño escalonado, en los que se refleja la luz del fuego. A la derecha del estrado, un alto candelero de hierro arde con una única vela. Más allá, en el suelo, un gran cuenco de latón eriza sus bordes con las empuñaduras de espadas enfundadas en pie. Pasado eso, un cofre de madera abierto derrama monedas sobre una alfombra con dibujos."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "Pachacuti Inca Yupanqui, Sapa Inca de Tahuantinsuyu, está sentado en un alto trono de piedra sobre una terraza que domina Machu Picchu; el trono está tallado con filas de motivos geométricos entrelazados resaltados en oro y rojo. Sobre él, a su derecha, fijado a un pilar de piedra, un gran disco solar de oro muestra en su centro un rostro humano estilizado rodeado de un anillo de rayos que irradian hacia afuera. Cumbres peladas se alzan abruptamente a su izquierda, y por debajo se despliegan construcciones bajas de techo de paja sobre plataformas agrícolas escalonadas. Luce una mascapaycha, una franja de lana roja que cae sobre la frente como emblema de la soberanía inca, ceñida por un llauto, una cinta de cabeza multicolor, y coronada con un penacho de plumas erectas rojas y oscuras. Su cabello es negro y le llega hasta los hombros. Del cuello le cuelga un pesado pectoral en forma de disco de oro. Su túnica es una prenda sin mangas, de largo hasta la rodilla, decorada con un audaz tablero de ajedrez en blanco y negro, con un cuello en rojo y oro a la altura del pecho. Por debajo de las rodillas, las piernas están ceñidas con cordones rojos con flecos. En la mano derecha sostiene un alto bastón coronado por una figura de ave en oro, con el astil adornado de borlas rojas dispuestas en niveles."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "Mohandas Karamchand Gandhi, Mahatma, líder de la independencia de la India, está de pie en una costa india de hierba seca y amarilla, un promontorio rocoso y un mar apagado. Es delgado, calvo y con gafas, con un bigote gris recortado muy corto. Viste la ropa de sus últimos años: un simple dhoti blanco enrollado en la cintura, un chal echado sobre un hombro y bajo el brazo opuesto, el pecho al descubierto. La tela no está teñida y es hilada a mano, un rechazo deliberado al paño británico que se convirtió en el emblema de su movimiento. El escenario evoca las largas caminatas que hizo hacia el mar durante la lucha por la independencia, una figura solitaria al borde del subcontinente."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "Gajah Mada, Mahapatih del Imperio Majapahit de Java, está de pie al borde de un arrozal anegado, cuya agua reluce como un espejo entre los bajos caballones de tierra verde. Tras él, un bosque tropical tupido asciende por una ladera envuelta en niebla pálida, y de esa niebla emerge la esbelta silueta escalonada de un candi, una torre-templo de ladrillo rojo cuyo tejado por niveles se disuelve entre las nubes. Es de hombros anchos y torso desnudo; el cabello oscuro recogido en un moño, con un pequeño mechón de barba en la barbilla. Bandas de oro ciñen cada bíceps y cada muñeca. Un ancho cinturón descansa alto en su cintura, abrochado con una gran placa de oro en forma de concha labrada en el estilo floral Majapahit. Por debajo del cinturón, un sarong rojo envuelve y se anuda al frente, con los pliegues cayendo en pesados paneles sobre una tela interior amarilla que asoma por el dobladillo. En su cadera derecha, colgado de un cordón pasado por el cinturón, pende un kris enfundado cuya oscura vaina de madera se afila hasta un punto estrecho, con el puño inclinado hacia adelante en ángulo oblicuo."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "Hiawatha, fundador de la Confederación Haudenosaunee, está de pie en un claro iluminado por el sol, con un gran peñasco gris que se eleva a la altura de su hombro y esbeltos troncos de haya y abedul perdiéndose en la vegetación verde que queda tras él. Es de torso desnudo y complexión delgada; la piel de un cálido tono moreno bajo la luz moteada. El cabello lleva el corte de scalplock: los flancos de la cabeza rasurados al ras y una estrecha cresta de pelo oscuro que recorre la parte superior de adelante hacia atrás, con dos plumas verticales fijadas en la nuca. Bandas de pintura oscura rodean la parte alta de cada brazo. Un collar ceñido de cuentas blancas de concha, un wampum, descansa en su garganta, y una sola correa cruza su pecho desde el hombro derecho hasta la cadera izquierda, sosteniendo una aljaba de flechas cuyos extremos con plumas asoman por encima del hombro. En la cintura, un taparrabos de piel de ciervo beige pálido cae en un largo faldón frontal hasta mediados del muslo. Polainas de piel de ciervo con flecos le cubren las pantorrillas desde el tobillo hasta la rodilla, atadas bajo la rodilla y abiertas en el muslo donde lo cubre el taparrabos. Está descalzo sobre la tierra compacta del claro, los brazos a los costados, con la luz del bosque cayendo sobre su lado derecho."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "Oda Nobunaga, daimyo del clan Oda y primero de los grandes unificadores, está de pie en un ondulado paisaje verde de hierba alta y piedras blancas dispersas, con una cordillera de montañas azules que se aleja hacia el horizonte bajo un cielo luminoso de nubes apiladas. La cabeza la lleva rasurada en la coronilla al modo sakayaki: la frente y la parte superior afeitadas para que el casco asiente con firmeza y frescura, con el resto del cabello recogido hacia atrás. Luce un bigote cerrado y una barba corta en la barbilla. Su armadura es tosei gusoku, un arnés de la época Sengoku: placas de hierro lacado enlazadas en hileras horizontales con cordones de seda, la coraza y las placas de la falda sujetas en bandas alternas de azul oscuro y bermellón. Los guardas de los hombros cuelgan con las mismas placas enlazadas sobre cada brazo. Encima lleva una casaca de combate sin mangas de color beige, con los paneles delanteros abiertos para mostrar la coraza enlazada. Una amplia faja roja se anuda en la cintura, atravesada por un sable con el filo hacia arriba; en el costado derecho cuelga un segundo sable, con la mano derecha sobre su empuñadura. Juntos forman el daisho, el par de sables largo y corto que todo samurái portaba. Asomando por encima del hombro derecho, cruzado en la espalda, se distingue el largo y oscuro guardamonte y el esbelto cañón de un tanegashima, el arcabuz de mecha cuya adopción masiva es el legado por el que Nobunaga es recordado. Está solo en campo abierto, rodeado únicamente de hierba, piedras y montañas lejanas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "Sejong el Grande, cuarto rey de la dinastía Joseon, está sentado en el centro de una tarima de madera elevada en el salón del trono, sosteniendo un libro abierto con ambas manos sobre el regazo. Viste un gonryongpo, la túnica de seda roja bordada con dragones que llevaban los reyes de Joseon, con el pecho y los hombros adornados en medallones dorados de dragones de cuatro garras y enmarcados en filigrana de oro. Un ancho cinturón de jade cruza su cintura. En la cabeza lleva un ikseongwan, un rígido gorro de gasa negra con dos pequeñas aletas levantadas que surgen en la parte posterior como hojas plegadas. Está afeitado, salvo por un discreto bigote oscuro y una barba corta en la barbilla. Tras él se alza el Irworobongdo, el biombo plegable del sol, la luna y los cinco picos colocado siempre detrás del trono de Joseon, donde el rey era el sol ante la luna de la reina: un disco de luna blanco en el ángulo superior izquierdo, un disco de sol rojo en el ángulo superior derecho, picos dentados en verde intenso y pinos de rojo oscuro desplegándose en el registro inferior. El trono en sí está lacado en rojo, con los paneles laterales tallados en medallones de tigres. Balaustradas y columnas lacadas en rojo enmarcan la tarima a ambos lados; farolillos de papel cuelgan en los bordes del salón, irradiando luz amarilla; un corto tramo de escalones de piedra desciende hacia el espectador."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "K'inich Janaab' Pacal, K'uhul Ajaw de B'aakal, el Sagrado Señor de Palenque, está de pie en la terraza de un palacio de caliza sobre su capital al mediodía, con templos piramidales escalonados que emergen de la selva al fondo, sus cresterías talladas y erosionadas hasta un rosa pálido. Detrás de los hombros se despliega un gran armazón dorsal, un bastidor de madera abierto en abanico con largas plumas de la cola del quetzal en franjas de verde, azul y rojo intenso, montado sobre una placa rectangular de glifos tallados y pintados. El tocado es alto y escalonado, coronado con más plumas de quetzal. El cabello, largo y oscuro, cae hasta el hombro. Un amplio collar de placas de jade tallado yace sobre su pecho, un pectoral cuadrado de jade pende en el centro, y discos de jade perforan sus lóbulos. Un cinturón de cuentas recoge a la cintura una falda de tela anudada y plumas, flecos de largas plumas de longitud de rodilla cuelgan a uno y otro lado, y sus sandalias se atan con correas hasta la parte alta de la pantorrilla. Con la mano izquierda empuña el cetro manikin de K'awiil, un alto báculo rematado por una pequeña cabeza tallada de la deidad del rayo cuya efigie los gobernantes mayas portaban como emblema de la realeza. A su izquierda, al borde de la terraza, se alza un ancho brasero de piedra, con el borde orlado de restos de ofrendas quemadas. La ciudad que se extiende al fondo se pierde entre la bruma, pirámide tras pirámide descendiendo en escalones hacia una llanura fluvial."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "Gengis Kan, Gran Kan de los mongoles, está montado sobre un caballo negro en la estepa abierta, mostrado de cintura para arriba y girado tres cuartos hacia el espectador. Su casco es alto y cónico, rematado en un pináculo afilado, con una banda oscura en la frente y orejeras que enmarcan un bigote fino y un pequeño mechón de barba en el mentón. Su armadura es el arnés de caballería mongol remachado, con el pecho dominado por un gran disco de bronce circular grabado con un diseño en espiral; amplias hombreras descansan sobre los hombros, y bandas tachonadas envuelven los brazos. Una capa oscura cae desde sus hombros, con un forro de color malva apagado donde cuelga detrás de la silla. Los arreos del caballo son de cuero liso, un simple bocado con apenas una frontalera y las riendas recogidas hacia delante. Detrás de él, suaves colinas verdes se extienden bajo un cielo gris pálido; en la ladera media se levanta un campamento de gers, las redondas tiendas de fieltro blanco de los mongoles, con pálidas manchas de ganado dispersas por la hierba a su alrededor."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "Ahmad al-Mansur, sultán saadí de Marruecos, está de pie al borde de un campamento sahariano bajo un cielo de azul profundo. Una fina luna creciente y estrellas dispersas cuelgan sobre cadenas montañosas oscuras y bajas en el horizonte. Tiene barba, la piel cálida bajo la luz de las lámparas y la mirada directa, vuelta hacia el espectador. Viste la indumentaria en capas del Magreb: una larga djellaba blanca, una túnica con capucha de longitud hasta los tobillos propia del norte de África. Sobre ella cae un selham, una capa de lana fina propia de príncipes y gobernantes, con la capucha reposando entre los omóplatos. Un turbante blanco le ciñe la cabeza. En el pecho lleva colgado un panel rectangular bordado en crema y oro, con el trazado de geometría entrelazada del ornamento islámico. Una amplia faja de franjas verticales rojas y crema le rodea la cintura dos veces y se anuda en la parte delantera, con los extremos recogidos hacia dentro. Tras él y a su izquierda, una gran tienda de caravana de forma redondeada, confeccionada en tela oscura a rayas, irradia luz desde su interior, y la abertura abierta derrama un cálido resplandor anaranjado sobre la arena; dos camellos descansan en la arena junto a ella. Un fulgor menor arde en la distancia, y un grupo de palmeras datileras se yergue contra las colinas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "Guillermo I, Príncipe de Orange, padre de la independencia holandesa, está de pie en una sala con azulejos iluminada por una alta ventana emplomada a la izquierda, cuyos pequeños rombos de vidrio quedan enmarcados por pesados cortinajes rojos recogidos a un lado. El suelo está dispuesto en cuadros de mármol blanco y negro. En la pared del fondo, tras él, cuelga un cuadro de paisaje con marco dorado que representa las tierras bajas bajo un cielo plomizo, con un río serpenteando entre llanos campos verdes hacia una ciudad distante. A su derecha, un taburete de madera sostiene un globo terráqueo cuyo aro meridiáno de latón recoge la luz de la ventana. A su izquierda, una mesa de escritura cubierta con un paño rojo muestra un libro encuadernado en cuero abierto y hojas sueltas de papel, y tras ella se alza una silla de respaldo alto tapizada en azul. El conjunto del interior evoca los cuartos de estudio del Geógrafo y del Astrónomo de Vermeer, aunque Guillermo pertenece a la generación anterior a ese estilo. Es un hombre barbado de mediana edad, el cabello oscuro cortado al ras bajo un pequeño gorro plano, con bigote y barba bifurcada recortados al ras y una amplia gorguera blanca plegada que sobresale a la altura del cuello. Sobre los hombros cae una larga capa negra, echada hacia atrás por la derecha para liberar los brazos. El jubón es de seda brocada en oro apagado, muy ceñido al torso y abrochado al frente en una sola fila de botones. Los calzones son gregüescos acuchillados, construidos con largas tiras verticales de tela roja y blanca dispuestas en franjas alternas sobre un forro interior más holgado y que terminan a mitad del muslo. Medias lisas de color oscuro cubren las piernas inferiores y llegan hasta unos zapatos bajos de cuero sobre el suelo a cuadros. En la mano derecha sostiene un bastón de mando alzado a la altura del pecho; la mano izquierda reposa cerca de la cadera, donde la empuñadura de una espada asoma apenas bajo el vuelo de la capa."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "Solimán el Magnífico, Kanuni el Legislador, Sultán de los otomanos, está de pie en el Palacio de Topkapi bajo una cúpula nervada, en una sala de arcos apuntados revestidos de azulejo de Iznik en azul y blanco. Rayos de luz diurna caen desde ventanas invisibles sobre las pálidas columnas de piedra que quedan tras él. Tiene barba, ojos oscuros, bigote y barba recortados al ras en torno a una boca fina. Su turbante es el alto y redondo kavuk por el que era conocido, una gran envoltura de tela blanca ceñida sobre una armazón cónica que se eleva bien por encima de la frente. En su cima se alza un sorguç, un penacho verde que señala el rango del sultán. Sobre una túnica interior viste un largo kaftan de seda amarilla tejida con una pálida trama de vides y rosas, abierto al frente hasta la cintura. Una amplia banda de piel gris suave bordea toda su longitud, distinguiéndolo como kapanice, la más alta ropa de honor. Una faja oscura cruza el kaftan a la altura de la cintura. En la mano derecha, sostenido verticalmente contra el pecho, porta un volumen encuadernado en cuero oscuro. La otra mano reposa a su costado. La sala que queda tras él se hunde en la penumbra entre los arcos revestidos."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "Darío I el Grande, Rey de Reyes del Imperio aqueménida, está de pie en lo alto de un corto tramo de escalones a la cabecera de una gran sala, con un haz de luz cayendo sobre él desde arriba. Es de hombros anchos y barba plena, la barba larga, cortada en cuadrado y fuertemente rizada. En la cabeza lleva el kidaris, la alta corona almenada de los reyes persas, un cilindro de oro rodeado de almenas cuadradas. Su manto es una larga túnica amarilla azafrán que cae hasta sus pies, bordeada en el pecho, los puños y el bajo con bordado rojo y dorado. Una faja roja lo recoge a la cintura. Pesados brazaletes de oro ciñen cada bíceps. Flanqueándole sobre pedestales a uno y otro lado se alzan dos colosales lamassu, toros alados, sus cuerpos y alas plegadas cubiertos de oro, las figuras guardianas de la Puerta de Todas las Naciones en Persépolis, representadas aquí en la versión de cabeza humana reducida al toro solo. El muro del fondo está tallado en bajorrelieve con una procesión de figuras en largas túnicas y gorros blandos, a semejanza de los relieves de los portadores de tributos de la escalinata de la Apadana. La piedra de la plataforma y los escalones es de un verde azulado pálido, con remates dorados en las esquinas."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "Casimiro III el Grande, Rey de Polonia y último de los reyes Piast, está de pie en la boca de una puerta de piedra iluminada por apliques de hierro en la pared cuyas llamas arrojan una cálida luz rojo-dorada sobre la mampostería. Es de hombros anchos y barba poblada, la barba oscura y recortada al ras, con la mirada serena. Su corona es un cerco de arcos dorados engastado con piedras rojas, cuyos arcos se cierran arriba en un remate de joyas. Sobre los hombros descansa un amplio tippet de armiño blanco, la piel trabajada con pequeños mechones de cola negros. Bajo él, su manto es una larga túnica carmesí abotonada por el pecho en una hilera de pequeños broches dorados y ceñida a la cintura con un ancho cinturón dorado. En una mano sostiene un cetro dorado erguido ante el pecho; en la cadera lleva el Szczerbiec, la espada de Estado de los Piast. A ambos lados, pesadas cadenas de hierro descienden desde la oscuridad superior a lo largo de las caras interiores de la puerta. Tras él, enmarcado en el arco al fondo de la cámara, un panel rojo muestra el coronado Aguila Blanca de Polonia con las alas desplegadas. El aguila aparece en silueta oscura sobre el campo rojo, en lugar del plateado habitual. La piedra es maciza y bien ajustada; la luz se concentra en el rey y cae bruscamente en las bóvedas en sombra a cada lado."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "Kamehameha el Grande, unificador de las Islas Hawaianas y primer Mo'i del reino, está de pie descalzo sobre una playa de arena blanca, con las aguas turquesas poco profundas de una bahía abrigada detrás de él y una escarpada cresta boscosa que se eleva más allá. Es alto y de constitución poderosa, con el torso desnudo y la piel de un marrón profundo bajo el sol tropical. Sobre un hombro cuelga un ahu'ula, una capa de plumas de los ali'i hawaianos, de rojo intenso y que le cae casi hasta los tobillos. Una amplia faja del mismo rojo le cruza el pecho desde el hombro izquierdo, con bordes amarillos guarnecidos de pequeños bloques geométricos rojos. Un panel a juego de rojo y amarillo cuelga en la parte delantera de su malo, un taparrabos enrollado en las caderas. En la cabeza lleva un mahiole, un casco de cresta baja con una estrecha cresta longitudinal que va de la frente a la nuca, trabajado en rojo con franjas amarillas y una banda amarilla en la base. En la mano derecha sostiene una alta lanza de madera con la punta dentada; el brazo izquierdo cuelga a su costado. A su derecha, varadas en la arena, yacen dos wa'a kaulua, canoas polinesicas de casco doble para navegación de altura, con sus dos cascos unidos por travesanos atados. Las velas son triangulares, con el vértice en la base del mástil y el borde superior curvado hacia afuera en una amplia U; la lona es pálida y está remendada. Una tercera canoa fondea un poco más adentro en la bahía. En la orilla, detrás de su hombro izquierdo, se alza un hale de paja, una casa hawaiana de armazón de postes y techo de hierba seca, medio sombreada por las frondas de las palmeras cocoterас. El cielo sobre la cresta es azul con nubes blancas a gran altura."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "María I, Reina de Portugal, del Algarve y de los dominios portugueses allende el mar, está de pie en la terraza del Palácio da Pena en Sintra, una galería de piedra pálida bajo una hilera de pesados arcos románicos. El Atlántico se abre al fondo entre sus columnas. Su vestido es de seda azul intenso, con el corpiño muy ceñido en punta en la cintura, las mangas hasta el codo rematadas en puños blancos y la falda amplia sobre miriñaque que cae en anchos pliegues hasta la piedra. Una capa corta roja queda prendida en los hombros y se arrastra tras ella. Cruzando el pecho le corre una ancha banda blanca ribeteada en rojo, la banda de la Orden portuguesa de Cristo, que llevaban los soberanos portugueses como Grandes Maestres, con una hilera de adornos de pedrería cosida en su frente. El cabello oscuro se lleva alto, apilado sobre la frente y fijado con una aigrette, un pequeño ornamento negro rematado con una pluma vertical. La mano derecha reposa a su costado sobre el pomo de un esbelto cetro cuyo oscuro vástago cae contra el azul de la falda. A su derecha, al otro lado de la balaustrada, una estrecha ensenada marina discurre entre acantilados rojizos. Dos Naus de aparejo cuadro con las velas plegadas están fondeadas en el canal. A su izquierda se alza un torreón de muros amarillos coronado por una cúpula abultada de franjas doradas y de azulejo. Almenas amarillas descienden en escalones hacia la terraza donde ella está. El cielo está despejado, la luz es la de una tarde atlántica luminosa, y los arcos la enmarcan entre el agua a un lado y la arquitectura real al otro."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "Augusto César, primer emperador de Roma, está sentado en un asiento de estilo curul entre dos cabezas de esfinge de bronce con los lisos rostros vueltos hacia afuera. Tiene la cara afeitada y el cabello oscuro y corto peinado hacia adelante sobre la frente, el flequillo de la tradición de la Prima Porta. Una toga picta, la toga ceremonial de color púrpura que se lucía en los triunfos romanos, le envuelve la túnica blanca y cae sobre el regazo antes de subir sobre el hombro izquierdo. El escote de la túnica está ribeteado en oro. La mano derecha reposa abierta sobre una de las cabezas de esfinge; la izquierda descansa suelta sobre la rodilla. Tras él, una sala oscura de paredes rojo intenso está flanqueada de columnas estriadas y decorada con estandartes verticales de rojo y oro. En la pared del fondo, un medallón redondo de bronce muestra una cabeza de león en relieve. Haces de luz diurna pálida caen desde la izquierda sobre su rostro y su pecho, dejando el lado opuesto de la sala en penumbra; dos pequeños braseros sobre soportes de hierro a cada lado del trono arden con llama tenue."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "Catalina II, Emperatriz y Autócrata de todas las Rusias, está de pie en la Sala de la Luz, el Gran Salón del Palacio de Catalina en Tsárskoye Seló. Su cuerpo está girado en tres cuartos hacia el espectador y la mirada es directa. El cabello oscuro está recogido y peinado en lo alto según la moda de la corte europea de finales del siglo XVIII. Un pequeño diadema enjoyado lo sujeta en la cúspide, cuyos puntos evocan en miniatura los altos arcos en forma de flor de la Gran Corona Imperial de Rusia. Su vestido es el traje de corte en seda color marfil: un corpiño ceñido con un panel central bordado en oro a lo largo de la parte delantera, mangas abullonadas a media longitud en azul intenso ribeteadas en el hombro con bandas de armiño blanco. Por debajo se despliega una falda de vuelo pleno bordada en oro con el águila bicéfala de las armas imperiales rusas dispersa como motivo repetitivo. Desde el hombro derecho hasta la cadera izquierda corre una amplia faja de moire azul pálido, la cinta de la Orden de San Andrés el Primero Llamado. Las altas ventanas arqueadas a lo largo de la pared derecha están colgadas con cortinas azul pálido recogidas en festones, y los haces de luz diurna caen en franjas visibles sobre un suelo de mármol en blanco y negro pulido como un espejo. En la pared izquierda, una sucesión de talla rococó dorada, con motivos de volutas y follaje, enmarca paneles de espejo."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "Pocatello, jefe de los shoshones del noroeste, está sentado sobre un montículo de rocas rojas erosionadas al borde de una cuenca intermontana, con una llanura llana de artemisia extendiéndose detrás de él hasta unas mesas bajas recortadas en el horizonte bajo un cielo crepuscular de rosa y violeta pálido. Es de hombros anchos, con el largo cabello negro partido por el centro y cayendo hasta el pecho, con una pluma de águila vertical sujeta en la parte trasera de la cabeza. Una segunda pluma oscura asciende detrás de su hombro desde el carcaj que lleva a la espalda. Un arco corto de madera está colgado junto al carcaj, con el extremo superior sobresaliendo por encima del hombro derecho. En su mano derecha sostiene una larga lanza clavada con la culata contra la roca, con el asta envuelta en cuero y un mechón oscuro colgando cerca de la punta. Sobre el torso lleva un chaleco de piel, cruzado por una ancha correa de cuero curtido trabajada en hileras de abalorios que va desde el hombro derecho hasta la cadera izquierda, con una corta funda de cuchillo colgando en el extremo inferior. Los brazos le están envueltos con apiladas bandas de plata. De la cintura para abajo lleva polainas oscuras de cuero con flecos que caen hasta el tobillo, y un taparrabos entre ellas. La mano izquierda reposa abierta sobre el muslo; su postura es quieta, el peso asentado sobre la piedra. La luz es baja y cálida, arrancando destellos del rojo de las rocas y el filo de la lanza, y el paisaje que se extiende detrás de él es la tierra de artemisia de la Gran Cuenca, la patria de los shoshones entre las Rocosas y la Sierra."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "Ramkhamhaeng el Grande, Rey de Sukhothai, está de pie en el jardín soleado de un palacio. La bruma verde de una selva tropical y las pálidas siluetas de lejanas chedis, estupas budistas en forma de campana de Tailandia, emergen a través de una niebla baja detrás de él. Es esbelto y va con el pecho descubierto, de piel morena cálida y el rostro girado levemente hacia su izquierda con una leve sonrisa. Su corona es alta, escalonada y puntiaguda, y se eleva hacia una aguja esbelta: una chada, la corona cónica de los reyes tailandeses. Un ancho collar pectoral de oro descansa sobre sus hombros y su pecho, trabajado en relieve de volutas y engarzado en el centro con una sola piedra roja; unas bandas doradas más estrechas sujetan cada brazo por el bícep. Un fajín de seda blanca está enrollado y anudado en su cintura, con los extremos retorcidos cayendo hasta los muslos. Bajo él lleva un paño envuelto de rojo intenso estampado en oro, con una capa interior más oscura visible en el dobladillo. A su derecha, al borde de un estanque sereno salpicado de flores de loto rosadas y sus grandes hojas planas, se alza una pequeña escultura de piedra: una serena cabeza de Buda con los ojos bajos, colocada sobre un pedestal en forma de capullo de loto. Un sendero de arena pálida se curva hacia su izquierda entre orillas de arbustos de flores rojas, conduciéndolo de vuelta hacia las torres neblinosas de la capital."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "Mohamed I, Askia el Grande de Songhai, está de pie sobre un promontorio rocoso al atardecer con una larga espada al hombro y una ciudad en llamas a su espalda. Es de piel oscura, barba corta, los ojos fijos en el espectador. La cabeza está envuelta en un tagelmust, un turbante saheliano de color crema pálido enrollado en alto y recogido a un lado. Sobre los hombros le cae un largo boubou carmesí, la túnica de mangas anchas de la nobleza de África Occidental, con el panel frontal y el pecho bordados en densas bandas de dibujo geométrico de hilo dorado y oscuro. Bajo él, una faja pálida se enrolla en torno a la cintura y se anuda de modo que los extremos cuelgan sueltos a la cadera, sobre unos pantalones del mismo carmesí que la túnica. Sujeta la espada por la empuñadura con la mano derecha y deja que la hoja descanse a lo largo del hombro; es larga y de dorso recto con una ligera curva hacia la punta. A su derecha la tierra desciende hacia una llanura bajo un cielo rojo anaranjado, una montaña oscura recortada contra el sol bajo. A su izquierda arde una ciudad: muros de adobe y un alto alminar cuadrado tachonado de hileras de toron de madera salientes, vigas de palma que sobresalen del enlucido. Las llamas trepan por la torre y se extienden por las calles que hay debajo; fogatas menores se dispersan por la llanura entre la ciudad y el acantilado donde él está de pie."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "Isabel I, Reina de Castilla y León, Reina consorte de Aragón, está de pie en una de las galerías con columnas de la Alhambra de Granada, cuya arquería se abre a un jardín de setos recortados y topiarios en maceta, con colinas que se difuminan en la bruma al fondo. Tras ella, esbeltas columnas pareadas de capiteles tallados se elevan hasta arcos lobulados y festoneados rellenos de celosía, con las enjutas encima labradas en denso estuco de motivos geométricos y vegetales en tonos de oro pálido y arena. Es menuda y de tez clara, las manos entrelazadas una sobre otra a la altura de la cintura. La cabeza va cubierta a la moda castellana de su corte: una toca blanca ajustada bajo el mentón y sobre la garganta, un velo blanco acomodado sobre la parte superior de la cabeza, y por encima una pequeña corona cerrada de oro engastada con piedras rojas y verdes. Sobre los hombros cae un largo manto rojo forrado y ribeteado en oro, abierto al frente. La saya que lleva debajo es de brocado crema con un oscuro motivo repetido, entallada en el cuerpo, con un panel ribeteado en oro que baja por el centro de la falda. En el pecho, prendida donde el manto se separa, luce una joya roja. La luz es la cálida y baja luz de una tarde avanzada, que arranca destellos del estuco de la arquería y de la pálida piedra del suelo de la galería."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "Gustavo Adolfo, Rey de los suecos, godos y vendos, el León del Norte, está de pie en una cámara de palacio dorada. A su lado, un profundo hogar arde con troncos partidos, con llama baja y viva. Es alto y de complexión robusta, con una barba rojiza plena que le cae hasta el pecho y un espeso bigote vuelto hacia arriba, el cabello peinado hacia atrás desde una frente alta. Lleva una coraza de acero ennegrecido, cincelada con bandas doradas en los bordes y a lo largo del nervio central, ajustada sobre un jubón de ante de cuero de buey grueso, pálido y aceitado. La armadura continúa hacia abajo en escarcelas de acero articuladas que se abren hasta la mitad del muslo sobre una falda inferior amarilla. Una ancha faja de seda turquesa le cruza desde el hombro derecho hasta la cadera izquierda, anudada y cayendo en un pliegue suelto contra el peto. Pequeños puños de encaje asoman en las muñecas, y un volante de encaje pálido bordea los calzones por encima de las botas. Está de pie con el peso echado hacia atrás, cada mano enguantada apoyada en un bastón de mando clavado en el suelo con la punta hacia abajo frente a él. Detrás de él el marco de la chimenea está tallado y dorado, la repisa orlada con roleos de acanto barrocos. A la izquierda, dos pinturas con marcos dorados cuelgan contra un muro de damasco verde y dorado. La más cercana muestra a un hombre barbudo con armadura oscura, Erico XIV, un rey anterior de Suecia. La más lejana muestra a una mujer pálida con un ligero vestido de corte, María Leonor de Brandeburgo, la esposa de Gustavo. Bajo los cuadros, una mesa pulida de madera oscura sostiene una fuente de peltre poco honda colmada de fruta, y un alto candelabro de latón se alza en el extremo próximo de la mesa con las velas sin encender. La habitación está iluminada casi en su totalidad por el fuego. El cálido reflejo anaranjado cae sobre la coraza, el estucado dorado y el lado derecho de su rostro, dejando el muro del fondo en sombra."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "Enrico Dandolo, dux de la Serenísima República de Venecia, está de pie sobre un puente de piedra sobre un canal de noche, una mano enguantada recogida contra el pecho. Es anciano: una larga barba gris le cae hasta el pecho, el cabello gris asoma en las sienes y su rostro está profundamente surcado de arrugas. En la cabeza lleva el corno ducale, el birrete ducal rígido en forma de cuerno de brocado rojo herrumbre que se eleva hasta una punta roma por detrás como un gorro frigio, llevado aquí sobre un camauro de lino blanco de corte ceñido cuyo borde asoma por debajo a la altura de la frente. Sobre los hombros le cae un pesado manto gris ribeteado de piel clara, abierto por delante y forrado del mismo rojo herrumbre que el gorro. Debajo lleva una larga túnica de brocado carmesí profundo ceñida a la cintura con un cordón de oro anudado. La balaustrada del puente es de hierro forjado, con paneles rellenos de esbeltos arcos apuntados a la manera del gótico veneciano. Detrás de él el canal se pierde en la oscuridad, flanqueado por palacios cuyas ventanas brillan en cálido naranja contra la noche azul. Una estrecha góndola está amarrada al muelle de la izquierda, y el cielo estrellado se abre entre las nubes sobre los tejados."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "Shaka kaSenzangakhona, Rey de los zulúes, está de pie en el terreno abierto de un poblado real, con los pies bien plantados, el escudo extendido a su lado izquierdo y la lanza corta a su derecha. Es de torso desnudo, piel oscura y musculatura poderosa, el torso cruzado por delgados cordones ensartados con pequeñas cuentas. En torno a la cabeza lleva un umqhele, una gruesa banda circular de piel de leopardo moteada que distingue el rango real y de alto rango. Fijado a ella a la altura de la frente se yergue un penacho de plumas blancas con las puntas rojas. A la cintura le cuelga un delantal de piel de leopardo que cae sobre las caderas, y debajo de él una franja de largos flecos de piel pálida se mece contra los muslos. Bandas de la misma piel moteada envuelven sus tobillos. En la mano izquierda lleva un isihlangu, un alto escudo de guerra ovalado y apuntado de cuero de buey; su superficie es parda y blanca con manchas irregulares, con un listón de madera recto que recorre su centro y queda sujeto por presillas de cuero. En la mano derecha, baja y en posición de alerta, sostiene un iklwa, una lanza de asta corta para el combate cuerpo a cuerpo con una larga hoja ancha en forma de hoja de árbol. Detrás de él se curva una hilera de iqukwane, las chozas de colmena de hierba y paja abovedadas de un umuzi zulú, con sus superficies tejidas capturando la luz del sol. Flanqueando el claro a uno y otro lado se alzan postes de madera coronados con cráneos de reses de largos cuernos, los grandes cuernos curvados aún intactos, riqueza y sacrificio expuestos a la entrada. El suelo es tierra pálida y seca, una mesa de cima plana se distingue en la lejana distancia, y el cielo sobre él es un azul pálido y despejado surcado de nubes finas."

-- Batch 11 (lines 2285-2497): EO_TAB_CITIES through CO_TAB_VICTORY.

-- Economic Overview (F2 / Domestic Advisor): tab names, column labels,
-- group / row text consumed by CivVAccess_EconomicOverviewAccess.lua.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "Ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "Felicidad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "Recursos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "Población"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "Fuerza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "Comida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "Ciencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "Oro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "Cultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "Fe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "Producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "títere"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "ocupada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "ocupada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "sin entradas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "sin producción"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    one = "{1_Turns} turno: {2_Name}",
    other = "{1_Turns} turnos: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "{1_PerTurn} por turno, {2_Cell}"
-- Population and defense cells append a status clause: growth state on the
-- population cell (reuses CITY_GROWS_IN / CITY_STARVING / CITY_STOPPED_GROWING
-- via CitySpeech.growthToken), HP fraction on the defense cell.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
-- Food cell appends stored / threshold via CITY_FOOD_PROGRESS; culture cell
-- appends the next-tile countdown via CitySpeech.borderGrowthToken.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "Oro total, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "Ingresos, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "Gastos, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "Neto por turno, {1_Value}"
-- Mirrors the engine's "Penalty From Gold Deficit" tooltip: only present
-- when net gold per turn is negative (the engine debits science 1:1 against
-- the deficit), so the row is omitted entirely the rest of the time rather
-- than reading a misleading 0.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "Ciencia perdida por déficit de oro, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "Ciudades, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "Diplomática, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "Religión, {1_Value}"
-- Engine renamed this from "Trade routes" to "City connections" in BNW
-- (TXT_KEY_EO_INCOME_TRADE = "Income From City Connections") to disambiguate
-- the legacy road-network gold (GetCityConnectionGoldTimes100, what this
-- row reads) from BNW's caravan trade-route system shown on the F4 Trade
-- Route Overview. Internal key keeps the legacy name to avoid churn.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "Conexiones entre ciudades, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "Unidades, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "Edificios, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "Mejoras, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "Diplomática, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "Felicidad total, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "Fuentes de felicidad"
-- Luxuries header value is the full GetHappinessFromResources() total.
-- The drilldown contains the per-resource rows plus three bottom rows
-- (variety, multiplied bonus, misc) so the children sum to the header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "Lujos, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "Variedad de lujos, {1_Value}"
-- Multiplied total of (per-luxury bonus rate * number of luxuries).
-- Lives as a bottom row in the Luxuries drilldown alongside the
-- per-resource entries, so the value's role as an additive contribution
-- (not a per-luxury rate) is clear from context.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "Bonificación por lujos, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "Otras bonificaciones de lujos, {1_Value}"
-- City happiness wrapper drillable. Header value is the empire-wide sum
-- of three engine accessors (GetHappinessFromCities + GetHappinessFromBuildings
-- + GetExtraHappinessPerCity * GetNumCities) so the user gets the
-- aggregate up front and drills in for the breakdown.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "Felicidad de ciudades, {1_Value}"
-- Engine "Local City Happiness". Per-city local happiness from buildings,
-- garrison, religion, and policy synergies; capped at city population.
-- Renamed because most happiness buildings (Colosseum, Theatre, Stadium,
-- etc.) feed THIS row, not the engine "Buildings" row -- the engine label
-- gets it backwards. Tooltip explains the engine source for cross-reference.
-- Per-city local happiness from buildings, garrisons, religion, and
-- policy synergies; capped at city population. Most regular happiness
-- buildings (Colosseum, Theatre, Stadium, Circus Maximus, Hotel) feed
-- this row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "Edificios, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "Felicidad de edificios, guarniciones, religión y sinergia de políticas en cada ciudad. "
    .. "Limitada a la población de la ciudad."
-- Engine "City Buildings" -- niche bucket for empire-wide BuildingClass
-- synergies, the rare UnmoddedHappiness attribute, and the
-- happiness-per-X-policies wonder bonus. Most of these are wonder effects;
-- normal happiness buildings DON'T feed this row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "Bonificaciones de maravillas, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "Felicidad de maravillas con efectos especiales: sinergia de clases de edificio, "
    .. "felicidad no modificada o bonificaciones por política. La mayoría de los edificios de felicidad "
    .. "cuentan en Edificios (por ciudad), no aquí."
-- Residual row inside the Wonder bonuses drilldown. Empire-wide
-- BuildingClass synergies and the happiness-per-X-policies wonder bonus
-- don't decompose per city, so the per-city children sum to less than
-- the parent header for any player who owns those wonders. This row
-- carries the difference.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "Bonificaciones de todo el imperio, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "Rutas comerciales, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "Ciudades-estado, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "Políticas, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "Religión, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "Maravillas naturales, {1_Value}"
-- Engine "Free Happiness Per City" -- buildings/policies with the
-- HappinessPerCity attribute. Already multiplied by city count (engine
-- shows the multiplied total too).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "Bonificaciones por ciudad, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "Felicidad de edificios o políticas que otorgan una cantidad fija por ciudad. "
    .. "Multiplicada por el número de ciudades."
-- Engine TXT_KEY_HAPPINESS_FROM_LEAGUES is "World Congress"; ignore the
-- internal "Leagues" naming and surface the BNW concept name to players.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "Congreso Mundial, {1_Value}"
-- Difficulty handicap residual: total happiness minus all other listed
-- sources. Engine has no accessor; both engine and we back-compute it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "Nivel de dificultad, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "Infelicidad total, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "Fuentes de infelicidad"
-- Count leads with its noun ("8 cities") so the listener can't mistake
-- the count for the unhappiness amount; the second number is explicitly
-- nouned ("unhappiness 8.5"). Plural-aware so "1 city" / "N cities" both
-- read naturally. Engine row labels "# of Cities (N)" / "# of Occupied
-- Cities (N)" / "Citizens (N)" / "Occupied Citizens (N)" with the value
-- column carrying the unhappiness amount; we collapse both into one row
-- since speech has no left/right column distinction.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    one = "{1_Count} ciudad, {2_Value} infelicidad",
    other = "{1_Count} ciudades, {2_Value} infelicidad",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    one = "{1_Count} ciudad ocupada, {2_Value} infelicidad",
    other = "{1_Count} ciudades ocupadas, {2_Value} infelicidad",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    one = "{1_Count} ciudadano, {2_Value} infelicidad",
    other = "{1_Count} ciudadanos, {2_Value} infelicidad",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    one = "{1_Count} ciudadano ocupado, {2_Value} infelicidad",
    other = "{1_Count} ciudadanos ocupados, {2_Value} infelicidad",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "Opinión pública, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "Desglose por ciudad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "Disponible"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "Usado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "Local"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "Importado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_FROM_CITY_STATES"] = "De ciudades-estado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "Exportado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "n/a"
-- Victory Progress (F8 / Who is winning): two-tab layout. Tab 1 is the
-- score table (one row per civ, columns from DiploList's score-breakdown
-- tooltip); Tab 2 is the victory-conditions menu (Time, Domination,
-- Science, Diplomatic, Cultural). Score column headers reuse engine
-- TXT_KEY_VP_CITIES / _POPULATION / _LAND / _WONDERS / _TECH /
-- _FUTURE_TECH / _POLICIES / _GREAT_WORKS / _RELIGION / _SCENARIO1-4
-- so only the Total header and row-state suffix are mod-authored.
-- Disabled-victory and tooltip sentence strings reuse engine TXT_KEY_VP_*
-- keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "Puntuación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "Victorias"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "Total"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, capital perdida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "Dominación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "Ciencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "Diplomática"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "Cultural"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "equipo {1_Num}"
-- Plural driven by {1_Num} (count of boosters built for the spaceship,
-- vanilla allows up to 3).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    one = "{1_Num} propulsor",
    other = "{1_Num} propulsores",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "cabina"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "cámara de criosueño"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "motor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, Apolo no construido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, Apolo construido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "Apolo construido, sin piezas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, Apolo construido, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "Apolo construido, {1_Parts}"
-- Plural is driven by {2_Total}: "1 of 1 prerequisite researched" vs
-- "1 of 5 prerequisites researched".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    one = "{1_Have} de {2_Total} requisito previo investigado",
    other = "{1_Have} de {2_Total} requisitos previos investigados",
}
-- Demographics (F9): one row per metric, speaking name, rank, the active
-- player's value, then rival best (with civ name), average, and worst
-- (with civ name) -- vanilla column order. Metric name and unmet-civ /
-- "you of <Civ>" fillers reuse engine TXT_KEYs so the format key stays
-- pure positional substitution.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, posición {2_Rank}, {3_Value}, mejor {4_BestCiv} {5_BestVal}, promedio {6_AvgVal}, peor {7_WorstCiv} {8_WorstVal}"
-- Vanilla's TXT_KEY_DEMOGRAPHICS_GOLD label is "GNP", which spells out
-- letter-by-letter in TTS and tells a non-economist nothing. Mod-authored
-- override only -- the engine label stays "GNP" for sighted players.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "Producto Nacional Bruto"
-- Culture Overview (Ctrl+C). Four-tab popup: Your Culture (per-city GW
-- management with click-to-move/view toggle), Swap Great Works (designate
-- swappable + foreign-offerings list + send), Culture Victory (per-civ
-- influence/tourism/ideology/public-opinion), Player Influence
-- (perspective picker + per-target modifier breakdown / level / trend).
-- Most enum-derived strings (influence levels, trend, public opinion)
-- reuse engine TXT_KEY_CO_* keys directly so phrasing matches what
-- sighted players see; mod-authored keys here only cover row formats,
-- action labels, and our drill-in framing.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "Tu cultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "Intercambiar grandes obras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "Victoria cultural"

-- Batch 12 (lines 2498-2695): CO_TAB_INFLUENCE through LEAGUE_VOTE_FOR_CIV.

-- ===== Culture Overview =====

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "Influencia del jugador"
-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] =
    "Yacimientos de antigüedad: {1_Visible} visibles, {2_Hidden} ocultos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    one = "{1_Name}, cultura {2_Cul}, turismo {3_Tou}, gran obra {4_Filled} de {5_Total}",
    other = "{1_Name}, cultura {2_Cul}, turismo {3_Tou}, grandes obras {4_Filled} de {5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    one = "{1_Name}, cultura {2_Cul}, turismo {3_Tou}, gran obra {4_Filled} de {5_Total}, dañado {6_Pct} por ciento",
    other = "{1_Name}, cultura {2_Cul}, turismo {3_Tou}, grandes obras {4_Filled} de {5_Total}, dañado {6_Pct} por ciento",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "títere"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "ocupada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "Sin edificios de Gran obra aún"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "Sin ciudades"
-- Slot type words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "espacio de escritura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "espacio de arte o artefacto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "espacio de música"
-- Multi-slot building entry inside a city.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled} de {4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled} de {4_Total}, bonificación de temática más {5_Bonus}"
-- Single-slot building rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, vacío"
-- Per-slot leaf inside a multi-slot building.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, vacío"
-- Work-class words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "escritura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "arte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "artefacto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "música"
-- Slot tooltip built from primitives.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class} de {2_Artist}, {3_OriginCiv}, {4_Era}, más {5_Cul} cultura, más {6_Tou} turismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "de {1_Artist}, {2_OriginCiv}, {3_Era}, más {4_Cul} cultura, más {5_Tou} turismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, más {4_Cul} cultura, más {5_Tou} turismo"
-- GW move flow feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "marcado como origen del movimiento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "movido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "origen del movimiento borrado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] = "tipo de espacio incorrecto para el origen actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "no se puede mover desde un espacio vacío"
-- Tab 2 (Swap Great Works).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "Tus ofertas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "Escritura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "Arte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "Artefacto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "ninguno designado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "Borrar designación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "Disponible de otras civilizaciones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "Ninguna civilización ofrece obras intercambiables"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "Sin obras intercambiables"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] =
    "Elige una obra de otra civilización para intercambiar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "Sin {1_Type} designado para ofrecer por {2_TheirName} de {3_TheirCiv}; designa uno en tus ofertas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "Intercambia tu {1_YourName} por {2_TheirName} de {3_TheirCiv}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "intercambio enviado"
-- Tab 3 (Culture Victory).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N} de {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "sin ideología"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "sin opinión pública"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "Influyendo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "Turismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "Ideología"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "Opinión pública"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] = "Infelicidad por opinión pública"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "Felicidad excedente"
-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    one = "estimado {1_N} turno para ser influyente",
    other = "estimados {1_N} turnos para ser influyente",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "Cambiar perspectiva"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "Nivel de influencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "Porcentaje de influencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "Modificador de turismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "Tasa de turismo sobre ellos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "Tendencia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "generando {1_N} turismo por turno, pulsa Intro para cambiar a esta perspectiva"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] = "ahora viendo desde {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N} por ciento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "tu turismo de {1_Yours} sobre su cultura acumulada de {2_Theirs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N} por ciento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "cayendo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "estático"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "subiendo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "subiendo lentamente"
-- Hotkey help (BaselineHandler / map-mode help list).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control más C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "Abrir Descripción general de cultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] =
    "La descripción general de cultura está desactivada en esta partida"

-- ===== League Overview (World Congress / United Nations) =====

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "Congreso Mundial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control más L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "Abrir descripción general del Congreso Mundial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "Estado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "Propuestas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "Efectos"
-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "Renombrar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(tú)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "presidente"
-- Plural driven by {1_N} (delegate count).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    one = "{1_N} delegado",
    other = "{1_N} delegados",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "puede proponer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "Diplomático en su capital"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "Sin Congreso Mundial"
-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "Sin acciones disponibles en esta sesión."
-- Plural driven by {1_N} (proposals the player can submit).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    one = "{1_N} propuesta disponible.",
    other = "{1_N} propuestas disponibles.",
}
-- Plural driven by {1_N} (delegates not yet allocated).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    one = "{1_N} delegado restante.",
    other = "{1_N} delegados restantes.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "Sin propuestas en esta sesión."
-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "Promulgar: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "Derogar: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "Propuesto por {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "Propuesto por ti"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "En espera"
-- Vote-state suffix appended to proposal row in Vote mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "tu voto: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "abstención"
-- Yea / Nay vote-label bundles.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    one = "{1_N} a favor",
    other = "{1_N} a favor",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    one = "{1_N} en contra",
    other = "{1_N} en contra",
}
-- Cast-vote row for Diplomatic Victory voting.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} para {2_Civ}"

-- Batch 13 (lines 2696-2872): LEAGUE_SLOT_EMPTY through INGAME_CHAT_HELP_DESC_CLOSE.

-- League / World Congress proposal slots and section headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "Ranura de propuesta vacía {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "Ranura {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "Ranura de propuesta {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "Resoluciones activas para derogar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "Resoluciones para proponer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "Otras resoluciones"
-- Mod prefaces for the GetResolutionDetails opinion sections. The engine
-- emits a verbose preface ("Based on our knowledge of other Civilizations'
-- desires, our count for this proposal stands at:") followed by bulleted
-- counts; we replace the preface with these terser strings and reorder so
-- the opinion lands before the resolution description (otherwise the user
-- has to wade through several sentences of help text to reach the live
-- counts that drive their vote decision). The propose-flow lists are flat
-- civ names, joined with commas mod-side rather than the engine's per-civ
-- bullets.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] =
    "Nuestra estimación de votos para esta propuesta es:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] = "Civs que aprobarían: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] = "Civs que se opondrían: {1_Civs}"
-- View All sections reuse the engine's TXT_KEY_LEAGUE_OVERVIEW_*_RESOLUTIONS
-- keys directly (Enacted Resolutions / Possible Resolutions / Other Resolutions).
-- Religion Overview. TabbedShell over the engine's BUTTONPOPUP_RELIGION_OVERVIEW:
-- tab 1 Your Religion (status / beliefs / faith / great people / auto-purchase),
-- tab 2 World Religions (one row per founded religion plus OVERALL STATUS footer),
-- tab 3 Beliefs (one Group per religion / pantheon, drilling into beliefs).
-- Screen title and tab names reuse engine TXT_KEY_RELIGION_OVERVIEW and
-- TXT_KEY_RO_TAB_*; only the hotkey-help pair and the world-row composition
-- have no engine equivalent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control más R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "Abrir resumen de religión"
-- "You are the founder of X" replaces the engine's bare "Founder of X" so
-- the status row reads as a sentence about the active player rather than a
-- column heading. {1_Religion} is the religion's localized name (custom
-- if the founder renamed it).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "Eres el fundador de {1_Religion}"
-- Belief type word with " belief" suffix. The engine's TXT_KEY_RO_BELIEF_TYPE_*
-- ("Founder", "Follower", ...) reads as a noun about the player on its own;
-- the suffix disambiguates that this row is a belief slot of that type.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "creencia de tipo {1_Type}"
-- World Religions row composition. Religion name leads; holy city and
-- founder follow as framing prepositions; trailing follower-city count is
-- the religion-level statistic ("Christianity, ..., 12 cities") sighted
-- players read in the engine row. The row is also a drillable group whose
-- children are cities following the religion -- the count is religion-level
-- (Game.GetNumCitiesFollowing across all civs), not a "how many entries
-- in this drilldown" count, so it stays.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    one = "{1_Religion}, ciudad santa {2_HolyCity}, fundada por {3_Founder}, {4_NumCities} ciudad",
    other = "{1_Religion}, ciudad santa {2_HolyCity}, fundada por {3_Founder}, {4_NumCities} ciudades",
}
-- Espionage Overview (BNW only). TabbedShell over the engine's
-- BUTTONPOPUP_ESPIONAGE_OVERVIEW: tab 1 agents (flat list, drill in for
-- actions), tab 2 cities (Your / Their groups, drill in for per-column
-- detail with engine tooltips), tab 3 intrigue messages. Screen title and
-- the Your / Their / Agents / View / Coup / Relocate row labels reuse
-- engine TXT_KEY_EO_* keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Control más E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "Abrir resumen de espionaje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "Agentes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "Ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "Intriga"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "El espionaje está desactivado en esta partida"
-- Agent row. {1_Rank} is the engine's tier name (Recruit, Agent, Special
-- Agent, ...); {2_Name} is the spy's proper name; {3_Where} is either a
-- city name (when stationed) or the engine's "in your hideout" / "in
-- transit" phrase; {4_Activity} is the current mission verb from the
-- engine (e.g. "establishing surveillance", "stealing technology",
-- "rigging election"). The _TURNS variant adds the time remaining.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    one = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} turno",
    other = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} muerto en combate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", diplomático"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "Acciones de {1_Rank} {2_Name}"
-- City row pieces. Civ + city + potential + population + spy clause.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "civilización {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "ciudad {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "población {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "potencial {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "potencial base {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "desglose: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "potencial desconocido"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] = "ciudad-estado, elección manipulable"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] = "ciudad-estado, manipulando la elección"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "agente {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "diplomático {1_Name}"
-- Intrigue row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "Turno {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "de tu espía {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "compartido por {1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "desconocido"
-- Move-agent sub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "Mover {1_Rank} {2_Name}"

-- Bookmarks: per-session digit-keyed cursor positions. Ctrl + 1-0 saves
-- the cursor cell, Shift + 1-0 jumps there (with scanner backspace return),
-- Alt + 1-0 speaks distance and direction (and capital-relative coord when
-- the scanner coord setting is on -- so empty / saved direction / coord
-- fragments stay byte-identical with the scanner's End readout).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "marcador guardado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "sin marcador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Control más una tecla numérica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] =
    "Guardar un marcador en la casilla del cursor en la ranura correspondiente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Mayúsculas más una tecla numérica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "Saltar el cursor al marcador de esa ranura, Retroceso para volver"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt más una tecla numérica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "Distancia y dirección desde el cursor al marcador de esa ranura"

-- Beacons: spatial-audio markers anchored at bookmarked cells. Ctrl+Shift
-- + 1-0 toggles the beacon for that slot. While a beacon is active, a
-- looping point source plays from the bookmark's position with the
-- cursor as listener: pan and pitch encode bearing, volume encodes
-- distance (silent past 30 hexes). The slot number is the same digit
-- the player pressed; phrasing leads with activated / deactivated so
-- the action verb is the distinguishing word per keystroke.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "baliza {1_Slot} activada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "baliza {1_Slot} desactivada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] = "guarda primero un marcador en esta ranura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] = "Control más Mayúsculas más una tecla numérica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "Activar o desactivar una baliza de audio espacial en el marcador de esa ranura"

-- Message buffer: scrollable history of speech-worthy events
-- (notifications, reveals, foreign-unit-watch lines, combat resolutions).
-- [ / ] step within the active filter; Ctrl+ jumps to ends; Shift+ cycles
-- the filter category and re-anchors at the newest matching entry.
-- Filter labels lead the announcement on Shift+, comma-joined to the
-- newest matching entry. Walking off either end of the buffer re-speaks
-- the current entry rather than announcing a separate edge marker, so
-- only the "no messages" key remains for the empty-buffer case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "Todos los mensajes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "Notificaciones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "Descubrimientos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "Combate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "Chat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "sin mensajes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "Corchete de apertura y corchete de cierre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "Mensaje anterior y siguiente en el historial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] = "Control más corchete de apertura y corchete de cierre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] = "Mensaje más antiguo y más reciente del historial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] =
    "Mayúsculas más corchete de apertura y corchete de cierre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "Cambiar el filtro del historial, omitiendo las categorías vacías"

-- Multiplayer chat. Backslash toggles a two-tab BaseMenu over DiploCorner's
-- existing chat panel: Messages reads civvaccess_shared._inGameChatLog
-- (newest-first), Compose wraps Controls.ChatEntry as a Textfield committed
-- via base's SendChat. Single-player no-ops with a spoken marker. Chat
-- target types (all / team / whisper) format the inline announce and the
-- MessageBuffer "chat" entries so the user can tell whom a message went to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Barra invertida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] =
    "Abrir panel de chat multijugador, sin efecto en un jugador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "El chat es solo multijugador"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "Chat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "Mensajes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "Redactar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "Mensaje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "Sin mensajes de chat aún"
-- {1_Name} sender, {2_Text} message body. Same shape used for the inline
-- speech announce, the MessageBuffer "chat" category entry, and the
-- Messages-tab list item, so the user hears one consistent line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} al equipo: {2_Text}"
-- {2_To} recipient name (or "you" when the local player is the target).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} a {2_To}: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "Barra invertida o Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "Cerrar panel de chat"

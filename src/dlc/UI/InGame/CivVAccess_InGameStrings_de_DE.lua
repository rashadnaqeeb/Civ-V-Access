-- Mod-authored strings, de_DE overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}
-- the user knows the mod attached.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "Civilization V Barrierefreiheit im Spiel geladen."
-- Hotseat-mute toggle (Ctrl+Shift+F12).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "Mod pausiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "Mod fortgesetzt"
-- Unit speech.
-- Tile recommendation announcement prefix.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "Empfehlung: {1_Name}"
-- Settler recs have no per-build name.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "Stadtplatz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "gewassert {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} TP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} Bewegungspunkte"
-- Cargo / stationed aircraft count.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} Flugzeuge"
-- Trailing token when the unit can take a new promotion.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "Beförderung verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    one = "{1_What} {2_Turns} Runde",
    other = "{1_What} {2_Turns} Runden",
}
-- Spoken when a unit is mid-execution on ACTIVITY_MISSION.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "eingereiht Bewegung"
-- Engine-fork form of the queued rung.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO"] = {
    one = "eingereiht Bewegung {1_Dir}, {2_Turns} Runde",
    other = "eingereiht Bewegung {1_Dir}, {2_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} Nahkampf"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} Fernkampf, Radius {2_Range}"
-- Enemy form of ranged strength.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} Fernkampf"
-- Aircraft replacement for the moves fraction.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "Radius {1_Strike}, Verlege-Radius {2_Rebase}"
-- Spoken on a friendly combat unit that has used its per-turn attack budget.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "keine Angriffe mehr"
-- Aircraft "done for the turn" signal.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "keine Bewegungspunkte mehr"
-- Enemy HP speaks as a color band.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "TP {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "grün"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "gelb"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "rot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "voll"
-- Unit info-line tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "Level {1_Lvl}, {2_Cur}/{3_Next} EP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "Modernisierung zu {1_Name}, {2_Gold} Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "Beförderungen: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    one = "bewegt, {1_Num} Bewegungspunkt verbleibend",
    other = "bewegt, {1_Num} Bewegungspunkte verbleibend",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "vor Ziel gestoppt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    one = "vor Ziel gestoppt, {1_Num} Runde bis Ankunft",
    other = "vor Ziel gestoppt, {1_Num} Runden bis Ankunft",
}
-- Generic "the action you tried did not happen" tail.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "Aktion fehlgeschlagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "eingereiht für nächste Runde"
-- Alt+QAZEDC prechecks.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "Fernkampfeinheit, Fernkampfangriff verwenden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "Lufteinheit, Fernkampfangriff verwenden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "kann nicht angreifen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "keine Angriffe mehr"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "keine Bewegungspunkte mehr"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "Flugzeug kann nicht so bewegt werden, Verlegen nutzen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "nicht benachbart"
-- Target-specific attack refusals.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "greift nur Städte an"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "Marineeinheit kann kein Land angreifen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "kann dieses Ziel nicht angreifen"
-- Empty-state tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "keine Einheiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "keine Aktionen"
-- Suffix appended when committing would trigger a war declaration.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "wird Krieg erklären"
-- Display names for the in-place menus.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Einheitenaktionen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "Geländefeld aktivieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Beförderungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Modernisierungen bauen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE_WITH_REASON"] = "nicht verfügbar, {1_BuildName}, {2_Reason}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE"] = "nicht verfügbar, {1_BuildName}"
-- Spoken on entering a target-picker mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "Zielmodus"
-- Confirms when shift+enter appends a leg to the unit's mission queue.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "eingereiht"
-- Spoken when shift+enter is pressed in a non-queueable mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "Angriff kann nicht eingereiht werden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_PREVIEW"] = "Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_PREVIEW"] = "Aktion auf dem Zielfeld voranzeigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_COMMIT"] = "Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_COMMIT"] = "Aktion auf dem Zielfeld bestätigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_QUEUE"] = "Umschalt plus Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_QUEUE"] = "Aktion in die Missionsliste der Einheit einreihen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_CANCEL"] = "Zielmodus abbrechen"
-- Generic "the action was abandoned" feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "abgebrochen"
-- Combat preview vocabulary.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "außerhalb der Reichweite"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, {5_DmgToMe} Schaden für mich, {6_DmgToThem} für sie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "Unterstützungsfeuer {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "Einnahme-Chance {1_Pct} Prozent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "meine Boni {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "ihre Boni {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "plus {1_N} Prozent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "minus {1_N} Prozent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, {5_DmgToThem} Schaden für sie"
-- City-defender preview variants.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "Stadt {1_Name}, {2_MyStr} vs {3_TheirStr}, {4_DmgToMe} Schaden für mich, {5_DmgToThem} für sie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "Stadt {1_Name}, {2_MyStr} vs {3_TheirStr}, {4_DmgToThem} Schaden für sie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} für mich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    one = "{1_N} Abfangjäger",
    other = "{1_N} Abfangjäger",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "bewegen nach {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} verbleibend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    one = "{1_MP} MP, {2_Turns} Runde, {3_Left} verbleibend",
    other = "{1_MP} MP, {2_Turns} Runden, {3_Left} verbleibend",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "diese Runde, unerforschtes Gebiet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    one = "{1_Turns} Runde, unerforschtes Gebiet",
    other = "{1_Turns} Runden, unerforschtes Gebiet",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "diese Runde, {1_Steps} dann unerforscht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    one = "{1_Turns} Runde, {2_Steps} dann unerforscht",
    other = "{1_Turns} Runden, {2_Steps} dann unerforscht",
}
-- Combat-with-pathfinding suffix.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] =
    "diese Runde, {1_Steps} dann Angriff"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    one = "{1_Turns} Runde, {2_Steps} dann Angriff",
    other = "{1_Turns} Runden, {2_Steps} dann Angriff",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "kein Pfad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "zu weit für Berechnung"
-- Discriminative path-failure diagnostics.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "blockiert durch {1_Civ}-Grenzen, nächsterreichbar {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "blockiert durch {1_Civ}-Grenzen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] =
    "blockiert durch geschlossene Grenzen, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "blockiert durch geschlossene Grenzen"
-- Stacking / enemy collapse to one shape.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] = "blockiert durch {1_Unit}, nächsterreichbar {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "blockiert durch {1_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] =
    "blockiert durch eine Einheit, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "blockiert durch eine Einheit"
-- Fog-of-war variants. When the blocker unit's plot isn't visible to the
-- active team, naming the unit would leak intelligence the sighted UI
-- doesn't expose either. The message says only that the path is blocked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED"] = "blockiert, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED_NO_DIR"] = "blockiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] = "kein Pfad, nächsterreichbar {1_Dir}"
-- Unreachable-branch sub-causes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] =
    "keine Einwasserungstechnologie, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "keine Einwasserungstechnologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] = "benötigt Astronomie, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "benötigt Astronomie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] = "blockiert durch Berge, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "blockiert durch Berge"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] = "blockiert durch {1_Wonder}, nächsterreichbar {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "blockiert durch {1_Wonder}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] = "keine Wasserverbindung, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "keine Wasserverbindung"
-- Domain-incompatible combat.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "kann nicht von Land angreifen, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "kann nicht von Land angreifen"

-- ===== Naval unit path errors =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "Angriff von Wasser nicht möglich, nächstes erreichbares {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] = "Angriff von Wasser nicht möglich"
-- Naval unit targeting empty / peaceful-occupied non-city land. Same
-- engine block as cantAttackFromWater but no combat intent on the user
-- side, so the framing is "travel" not "attack".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] =
    "Reise zu Land nicht möglich, nächstes erreichbares {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "Reise zu Land nicht möglich"
-- Embark / disembark hint appended to a successful move-path preview
-- when the start and destination share a domain but the route crosses
-- the opposite one (land -> water -> land, or water -> land -> water).
-- Cross-domain endpoints (land -> water, water -> land) need no hint
-- because the destination's domain already implies the transition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "erfordert Einschiffung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "erfordert Ausschiffung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "kein Ziel hier"
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
    one = "{1_N} Geländefeld",
    other = "{1_N} Geländefelder",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    one = "{1_N} Runde",
    other = "{1_N} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    one = "{1_Tiles} Geländefeld, kein Baubedarf",
    other = "{1_Tiles} Geländefelder, kein Baubedarf",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD"] = "keine Route verfügbar"
-- Route-to water blocker. The only route-failure cause without a move-to
-- analog -- move-to handles water via embark/astronomy unlocks, whereas
-- BuildRouteValid rejects every water step outright. Mountain and
-- borders reuse PATH_BLOCKED_MOUNTAIN / PATH_BLOCKED_BORDERS_CIV; same
-- cause, same wording, no need for route-flavored duplicates.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER"] = "blockiert durch Wasser, nächsterreichbar {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER_NO_DIR"] = "blockiert durch Wasser"
-- Per-mode "cannot X here" strings for the special interface modes whose
-- legality is the only sighted feedback (highlight tint). Spoken when the
-- engine's per-target Can*At check returns false; legal targets fall
-- through to the destination plot's glance summary instead.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "Fallschirmsprung hier nicht möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "Lufttransport hier nicht möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "Verlegung hier nicht möglich"
-- Rebase destination entry in the unit action menu's Rebase drill-in. The
-- menu replaces engine target mode (cursor probe) with a proximity-sorted
-- list of valid destinations so a blind player can pick by name; the
-- distance suffix is the salient distinguishing feature when several
-- candidates share a label (e.g. multiple unnamed Aircraft Carriers).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    one = "{1_Name}, {2_N} Geländefeld",
    other = "{1_Name}, {2_N} Geländefelder",
}
-- Spoken when the user activates the Rebase action menu entry but no
-- friendly cities or air-cargo units are within rebase range. The action
-- itself is available (the unit satisfies canRebase) but no destination
-- qualifies; surface that explicitly rather than letting the entry
-- silently disappear.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] = "keine Verlegungsziele in Reichweite"
-- Spoken on rebase resolution. The pending machinery normally speaks
-- moveResult ("moved, N moves left" / "stopped short"), but rebase calls
-- finishMoves before setXY so MovesLeft is always 0 -- the moveResult
-- phrasing would imply a partial / failed move. The user already picked
-- the destination by name from the action menu; the confirm names what
-- they picked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "verlegt nach {1_Name}"
-- Airlift sub-menu. Two-stage picker: pick a destination city from this
-- list (own-team cities with airports that have at least one valid hex
-- around them), then the cursor jumps there and target mode opens so the
-- user can pick the exact landing tile (the city plot or any of its six
-- neighbors). Preamble explains the two stages on menu open; DEST is the
-- per-city entry; NO_DESTINATIONS surfaces when the unit can't reach any
-- friendly airport from its current plot.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "Wählt eine Stadt, in die diese Einheit per Lufttransport gebracht werden soll. Nach der Auswahl wählt Ihr das genaue Geländefeld, auf dem die Einheit landet - höchstens 1 Geländefeld von der Stadt entfernt."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    one = "{1_Name}, {2_N} Geländefeld",
    other = "{1_Name}, {2_N} Geländefelder",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] = "keine Lufttransport-Ziele verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "Einschiffung hier nicht möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "Ausschiffung hier nicht möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "Atomwaffenangriff hier nicht möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "Einheit hier nicht schenkbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "Modernisierung hier nicht möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "keine sichtbaren Abfangjäger"
-- Action-affirming legal previews. Spoken on Space when the cursor is on
-- a valid target hex for the active picker, in place of the cursor's
-- tile glance (which the user already heard while navigating). Each
-- mirrors its ILLEGAL counterpart but names what the action will do
-- rather than re-describing what's at the hex. NUKE additionally surfaces
-- the engine's NUKE_BLAST_RADIUS so the user can judge collateral. GIFT_*
-- name the recipient and the gifted unit / connected resource so the
-- Space probe answers "what will happen if I commit here" rather than
-- "what's at this hex."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "Lufttransport hier"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "Fallschirmsprung hier"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] = "Atomwaffenangriff hier, Explosionsradius {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "{1_Unit} an {2_Recipient} schenken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] =
    "{1_Resource} für {2_Recipient} modernisieren"
-- Unit control help overlay entries. Chord labels merge each binding
-- cluster into one line so the ? screen doesn't list six Alt+letter rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Punkt, Komma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "Zur nächsten oder vorherigen Einheit wechseln"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Strg plus Punkt oder Komma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "Zur nächsten oder vorherigen Einheit wechseln, auch solche, die bereits gehandelt haben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Schrägstrich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] =
    "Kampf- und Beförderungsinfo der ausgewählten Einheit vorlesen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Strg plus Schrägstrich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] =
    "Hexfeld-Cursor auf die ausgewählte Einheit zentrieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Einheitenaktionsmenü öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt plus Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Ausgewählte Einheit ein Hexfeld bewegen (zweimal drücken zum Angriff bestätigen)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt plus M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "Bewegungsziel-Auswahl öffnen; mit Cursortasten zielen, Leertaste zum Voranzeigen, Eingabe zum Bestätigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] =
    "Militäreinheit befestigen oder Zivileinheit schlafen lassen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] =
    "Wachposten stellen, schläft bis ein Feind in Sichtweite kommt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt plus W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "Schlafende oder befestigte Einheit aufwecken oder eingereihte Bewegung bzw. Automatisierung abbrechen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt plus X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "Runde der Einheit überspringen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "Heilen bis voll"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "Fernkampf-Zielauswahl öffnen; mit Cursortasten zielen, Leertaste zum Voranzeigen, Eingabe zum Bestätigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "Geländefeld der Einheit plündern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt plus U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "Einheit modernisieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt plus N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "Einheit umbenennen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} nicht verfügbar"
-- Combat-result payload from the engine fork's CombatResolved hook.
-- Damage values speak absolute-delta ("attacker -8 hp") rather than
-- before/after because the before is already known from the last
-- selection announce.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "Angreifer {1_Name} -{2_Dmg} TP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "Verteidiger {1_Name} -{2_Dmg} TP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "Angreifer {1_Name} unversehrt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "Verteidiger {1_Name} unversehrt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} gefallen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} gefangen"
-- Substituted for the attacker / defender name in AI-vs-AI combat on a
-- visible plot when one side is invisible to the active team (e.g., AI
-- submarine ambushing AI ship). Matches what sighted players perceive:
-- an unseen hit on a visible target. Active-player-involved combats
-- always use full names regardless of invisibility because attacks
-- reveal identity in base game's defender-side messages.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "unbekannt"
-- Air-strike intercept clause. Omitted unless the engine fork's hook
-- reports a landed intercept (interceptorDamage > 0); failed / evaded
-- intercepts surface no clause to match base game's UI.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "abgefangen von {1_Name}"
-- Air-sweep prefix. The engine reports combatKind = 1 for sweep into
-- ground AA (one-sided), combatKind = 2 for sweep into another fighter
-- (two-sided dogfight). The prefix lets the user know the combat result
-- they're about to hear came from a sweep they triggered.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "Abfangmanöver"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "Luftkampf"
-- Air-sweep no-target. Engine fork's CivVAccessAirSweepNoTarget hook
-- fires when the user issues a sweep but no interceptor is in range to
-- engage. Mirrors base game's TXT_KEY_AIR_PATROL_FOUND_NOTHING which
-- lands in the sighted notification log we don't subscribe to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "keine Abfangjäger"
-- Nuclear strike speech. Composed from the engine fork's NukeStart /
-- NukeUnitAffected / NukeCityAffected / NukeEnd hook stream. Sections
-- are elided when empty -- a nuke that finds nothing emits the header
-- + NO_TARGETS line; one with city damage but no unit damage drops
-- the units clause. Each entity entry is built from CIV_NAME +
-- HP_DELTA + optional pop / kill / destroy suffixes joined Lua-side.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "Atomwaffenangriff von {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "Ziel {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "Verluste {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "Einheiten {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "keine Ziele getroffen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} TP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} Bev."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "gefallen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "zerstört"
-- City-capture announcements. SerialEventCityCaptured fires for empty
-- city captures (no combat resolution) and for capture-after-defender-
-- killed transitions; the active player's perspective decides which line
-- wins.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "{1_Name} erobert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "{1_Name} verloren"
-- Self-plot action confirms. Keyed by action hash token so the menu can
-- dispatch without a per-action if-ladder. FORTIFY / SLEEP / ALERT / WAKE /
-- AUTOMATE / DISBAND / BUILD / PROMOTION map 1:1 to the commit path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "befestigt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "schläft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "in Alarmbereitschaft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "aufgeweckt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "automatisiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "aufgelöst"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "heilt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "geplündert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "übersprungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "modernisiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "abgebrochen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "{1_Build} begonnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "befördert zu {1_Name}"

-- ===== Button / label disabled markers =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "deaktiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, deaktiviert"

-- ===== Cursor direction tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "o"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "no"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "so"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "sw"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "w"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "nw"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_N"] = "n"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_S"] = "s"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "Kartenrand"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "Rand der Reichweite"

-- ===== Tile ownership / visibility states =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "unbesetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "unerforscht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "Nebel"

-- ===== Target mode prefix =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "verdeckt"

-- ===== Capital jump tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "Hauptstadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "keine Hauptstadt"

-- ===== Coordinate and movement =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    one = "{1_Moves} Bewegungspunkt",
    other = "{1_Moves} Bewegungspunkte",
}

-- ===== River and water tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "Fluss {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "Fluss ringsum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "Süßwasser"

-- ===== Waypoint =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "Wegpunkt {1_Index} von {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} geplündert"

-- ===== Macro-terrain tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "Hügel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "Berg"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "See"

-- ===== HP and build progress =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} TP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    one = "{1_Build} {2_Turns} Runde",
    other = "{1_Build} {2_Turns} Runden",
}

-- ===== Yield count =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"

-- ===== Plot control =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "kontrolliert von {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "kontrolliert"

-- ===== Defense and zone of control =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} Prozent Verteidigung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "in feindlichem Einflussbereich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ENEMY_ADJACENT"] = "Feind in der Nähe"

-- ===== Cursor help overlay =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Q, W, E, A, S, D, Z, X, C Gruppe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] =
    "Cursor um ein Geländefeld bewegen (Q nw, E no, A w, D o, Z sw, C so)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] = "Ziffernblock 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] =
    "Spiegelt Q, W, E, A, S, D, Z, X, C mit denselben Modifikatortasten wider (im Ziffernblock entspricht 5 dem S, bei aktivem Num-Lock)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "Einheit auf dem aktuellen Geländefeld vorlesen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Umschalt plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "Koordinaten des Cursors relativ zur ursprünglichen Hauptstadt, in modifizierter Offset-Notation (jeder Schritt nach Osten ist plus eins in x, jeder NO-Schritt ist plus 0,5 in x und plus eins in y, jeder SO-Schritt ist plus 0,5 in x und minus eins in y)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Strg plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "Cursor zur Hauptstadt springen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "Wirtschaftsdetails des aktuellen Geländefelds"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "Kampfdetails des aktuellen Geländefelds"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "Stadtidentität und Kampf"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "Stadtproduktion und Wachstum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "Stadtreligion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] = "Diplomatische Hinweise zur Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "Einheit auswählen oder Stadtbildschirm öffnen (Annexions-Popup für Marionetten, Diplomatie mit einer bekannten Großzivilisation) auf dem Geländefeld"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Strg plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "Civilopedia für alles auf dem Geländefeld des Cursors öffnen (Einheiten, Weltwunder, Modernisierung, Ressource, Geländemerkmal, Fluss, See, Gelände, Hügel, Berg, Route)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "Artikel zum Geländefeld"

-- ===== City info tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "unbekannt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "angreifbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "keine Stadt hier"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "kultiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "militaristisch"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "maritim"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "geschäftstüchtig"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "religiös"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "befreundet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "verbündet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "Krieg"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "dauerhafter Krieg"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    one = "wird niedergebrannt, {1_Turns} Runde",
    other = "wird niedergebrannt, {1_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    one = "Widerstand {1_Turns} Runde",
    other = "Widerstand {1_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "besetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "Marionette"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "blockiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} Einwohner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} Verteidigung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} von {2_Max} TP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "Garnison {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    one = "produziert {1_Name} {2_Turns} Runde",
    other = "produziert {1_Name} {2_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "produziert {1_Name}"

-- ===== City development tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "produziert nichts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} von {2_Needed} Produktion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    one = "wächst in {1_Turns} Runde",
    other = "wächst in {1_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "hungert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "Wachstum gestoppt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} von {2_Threshold} Nahrung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "verliert {1_Num} pro Runde"

-- ===== Foreign city development =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] =
    "Produktion verborgen, siehe Spionage-Übersicht"

-- ===== City religion tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    one = "über {1_N} Handelsweg",
    other = "über {1_N} Handelswege",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "keine Religion vertreten"

-- ===== City diplomatic notes =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "ursprünglich {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "Kriegstreiber-Vorschau: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "Befreiungsvorschau: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "Spion {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "Diplomat {1_Name}, {2_Rank}"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "keine diplomatischen Notizen"
-- Spoken when Scanner becomes the top handler: on boot, after a popup
-- closes, after a sub-handler (ScannerInput, UnitActionMenu) pops. Gives
-- the user a consistent audible landmark that the hex-viewer cursor is
-- live again -- functioning as the "closed" confirmation that popup
-- dismissal would otherwise need case-by-case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "Kartenmodus"
-- Type-ahead search feedback (see FrontEnd strings for the authoring
-- rationale). Mirrored here because TypeAheadSearch runs from in-game
-- BaseMenu contexts whose string table is sandboxed from the FrontEnd copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "kein Treffer für {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "Suche geleert"
-- Help overlay strings (see FrontEnd strings for the authoring rationale).
-- Duplicated here because Contexts are sandboxed: in-game Contexts that
-- eventually wire SetInputHandler through InputRouter need their own copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Hilfe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Buchstaben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Auf oder ab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Pos1 oder Ende"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Eingabe oder Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Links oder rechts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Umschalt plus links oder rechts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Strg plus auf oder ab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt plus links oder rechts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Umschalt plus Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Strg plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Fragezeichen"
-- Description tokens of the help overlay (paired with the KEY_* labels
-- above; the two halves combine via HELP_ENTRY = "{1_Key}, {2_Description}").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Tippen zum Suchen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Zwischen Elementen navigieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "Zum ersten oder letzten springen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Aktivieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "Wert anpassen oder Detail aufrufen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "Wert in größeren Schritten anpassen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "Zur vorherigen oder nächsten Gruppe springen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Nächster Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Vorheriger Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Bildschirmkopf vorlesen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "Civilopedia-Eintrag für das aktuelle Element öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Abbrechen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Schließen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Bearbeitung abbrechen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Bearbeitung bestätigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Strg plus Umschalt plus F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Einstellungen öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Einstellungen schließen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "Mod pausieren oder fortsetzen"
-- BaseTable: 2D table viewer (used by F2 cities, future demographics, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, absteigend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, aufsteigend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, Sortierung aufgehoben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "Sortierschaltfläche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "Zwischen Zeilen wechseln"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "Zwischen Spalten wechseln"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "Erste oder letzte Zeile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "Zelle aktivieren oder nach Spalte sortieren"
-- Settings overlay strings. Reachable from every Context that routes
-- through InputRouter, so duplicated in the FrontEnd copy as well.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Einstellungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_UI"] = "Benutzeroberflächeneinstellungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_CURSOR"] = "Cursoreinstellungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_BEACON"] = "Signal-Einstellungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_SCANNER"] = "Scanner-Einstellungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_NOTIFICATIONS"] = "Benachrichtigungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Gelände-Earcons"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Nur Sprache"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Sprache und Audiohilfen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "Ausführliche Ansagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Nur Audiohilfen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "Gelände-Earcon-Lautstärke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "Gelände-Earcon-Lautstärke, {1_Num} Prozent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME"] = "Signal-Lautstärke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME_VALUE"] = "Signal-Lautstärke, {1_Num} Prozent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "Hörweite des Signals"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] = "Hörweite des Signals, {1_Num} Felder"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "Scanner bewegt Cursor automatisch"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "Cursor folgt ausgewählter Einheit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "Cursorkoordinaten beim Bewegen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Aus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "Vor der Bewegungsansage sprechen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "Nach der Bewegungsansage sprechen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] = "Gebiet beim Feldauslesen stets ansagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_ENEMY_ADJACENT_WARN"] = "Bei benachbartem Feind warnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "Scanner zeigt Koordinaten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COMPASS_DIRECTION"] = "Scanner verwendet Himmelsrichtung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_DIRECTION_BEEP"] = "Scanner spielt Richtungston ab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Untertitel vorlesen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "Sichtbarkeitsänderungen beim Bewegen ansagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "KI-Kampfergebnisse ansagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] =
    "Sichtbarkeitsänderungen zu Rundenbeginn ansagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "Lager und Ruinen ansagen, die andere im Sichtfeld beansprucht haben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_TURN_START_SOUND"] = "Ton zu Rundenbeginn im Einzelspieler abspielen"
-- Widget-generic strings spoken by BaseMenuItems Choice / Checkbox /
-- Textfield and BaseMenuEditMode. Mirrored from the FrontEnd copy because
-- Contexts are sandboxed: an in-game screen that uses these item kinds
-- needs them present in the InGame Context's string table.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "ausgewählt"
-- Compositional form: "selected, <label>" for Choice items that surface
-- the selection marker as a prefix on the entry's own text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "ausgewählt, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "an"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "aus"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "bearbeiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "{1_Label} bearbeiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} wiederhergestellt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "Schaltfläche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "Umschalter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "Schieberegler"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "Kombinationsfeld"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "Untermenü"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "Tabelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_LINK"] = "Link"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "{1_Num} von {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "Zeile {1_Num} von {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "Spalte {1_Num} von {2_Num}"
-- GameMenu (Esc pause menu) strings. Details tab reuses the base game's
-- TXT_KEY_POPUP_GAME_DETAILS, so no mod-authored tab label here.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "Pausemenü"
-- GenericPopup (the shared Context behind AnnexCity / PuppetCity /
-- ConfirmCommand / DeclareWar / BarbarianRansom / etc.). One display name
-- for all of them; the per-popup text comes from the base via preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "Fenster"
-- Informational popups that have no engine-side title to reuse: TextPopup
-- is a generic notification, WonderPopup only carries the wonder name
-- (dynamic), LeagueSplash's title is dynamic per-session.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "Meldung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "Weltwunder fertiggestellt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "Weltkongress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "Spielende"
-- Ranking tab row labels. The HistoricRankings table is fixed leader tiers
-- with thresholds; the matched row replaces "score <threshold>" with the
-- player's actual score and tacks on the leader's quote.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, Punktzahl {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] =
    "{1_Rank} {2_Leader}, Eure Punktzahl {3_Score}, {4_Quote}"
-- Drillable label for a per-turn group of replay messages. Source is
-- Game.GetReplayMessages() at end-game; children are the non-empty Text
-- entries on that turn, with the turn prefix dropped since the group
-- label provides it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "Runde {1_Turn}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "Krieg erklären"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "Stadtstaat-Begrüßung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "Stadtstaat"
-- Fallback for LeaderHeadRoot / DiscussionDialog before TitleText is
-- populated. In practice the onShow hook overwrites handler.displayName
-- with the live leader title (e.g. "Suleiman the Magnificent") that
-- LeaderMessageHandler just set.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "Diplomatie"
-- DiscussionDialog sub-menu display names. Denounce confirm is a yes/no
-- overlay; coop-war leader picker is a scroll list of civs the AI could
-- ally with against us.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "Denunzieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "Ziel des gemeinsamen Krieges"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "Großes Werk"
-- Choose-family popup screen names.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "Alte-Ruinen-Bonus wählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WARRIOR"] = "Krieger"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_POPULATION"] = "Bevölkerung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_CULTURE"] = "Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PANTHEON_FAITH"] = "Glauben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PROPHET_FAITH"] = "Großer Prophet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_NEARBY_BARBS"] = "Nahe Barbaren aufdecken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_LOW_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HIGH_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_MAP"] = "Nahe Karte aufdecken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_TECH"] = "Kostenlose Technologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_RESOURCE"] = "Nahe Ressource aufdecken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_UPGRADE_UNIT"] = "Einheit modernisieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SETTLER"] = "Siedler"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SCOUT"] = "Späher"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WORKER"] = "Bautrupp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_EXPERIENCE"] = "Erfahrung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HEALING"] = "Einheit heilen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "Kostenlose Große Persönlichkeit wählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] =
    "Große Persönlichkeit durch Glauben wählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "Maya-Bonus wählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "Pantheon gründen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "Ideologie-Auswahl"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "Archäologie-Fund"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "Admiralshafen ändern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "Heimatstadt der Handelseinheit ändern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "Handelsweg einrichten"
-- Confirm-overlay sub-handler.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Bestätigen"
-- ChooseReligionPopup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "Religion gründen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "Religion verbessern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "Religionsnamen ändern"
-- Belief-slot label formats.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, nicht gewählt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, später verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, nur für die Byzantiner"
-- Religion-picker row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "Religion, nicht gewählt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "Religion, {1_Name}"
-- Name row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "Name, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "Religionsname"
-- NotificationLogPopup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Benachrichtigungsprotokoll"
-- LeagueProjectPopup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "Kongress-Projekt abgeschlossen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} Produktion, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "Gold-Belohnung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "Silber-Belohnung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "Bronze-Belohnung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "keine Belohnung"
-- VoteResultsPopup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "Abstimmungsergebnisse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    one = "{1_Rank}, {2_Name} hat für {3_Cast} gestimmt, {4_Votes} Stimme erhalten",
    other = "{1_Rank}, {2_Name} hat für {3_Cast} gestimmt, {4_Votes} Stimmen erhalten",
}
-- WhosWinningPopup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "Wer führt?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"
-- Advisors tutorial banner.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "Tutorial-Berater"
-- NotificationLogPopup tab labels and item format.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "Aktiv"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "Rundenprotokoll"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "Geschlossen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "Keine Benachrichtigungen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, Runde {2_Turn}"
-- Combat Log group inside the Turn Log tab.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "Kampfprotokoll"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "Kein Kampf in dieser Runde."
-- MilitaryOverview (F3).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur} von {3_Max} EP"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "Versorgung: {1_Use} von {2_Cap}"
-- Idle status fallback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "untätig"
-- Tab labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "Einheiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "Große Persönlichkeiten"
-- Units tab column headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "Entfernung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "Verbleibende Bewegung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "Maximale Bewegung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "Stärke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "Fernkampf"
-- Great People tab.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress} von {4_Threshold}, plus {5_Rate} pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] =
    "{1_City}: {2_Progress} von {3_Threshold}, kein Fortschritt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "nächste Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    one = "{1_N} Runde",
    other = "{1_N} Runden",
}
-- AdvisorCounselPopup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "Kein Rat verfügbar."
-- Function-row help entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "Civilopedia öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "Wirtschaftsberater öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "Militärberater öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "Diplomatie-Berater öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "Sozialpolitik-Bildschirm öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "Technologiebaum öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "Runden- und Ereignisprotokoll öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "Siegfortschritt öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "Demografien öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "Beraterrat öffnen"
-- CityView hub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "verbunden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} arbeitslos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "Nahrung {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "Produktion {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "Gold {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "Forschung {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "Glaube {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "Tourismus {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "Kultur {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Punkt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "Nächste Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Komma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "Vorherige Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "keine nächste Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "keine vorherige Stadt"
-- Hub items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "Statistiken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "Weltwunder"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "Fortschritt Große Persönlichkeiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "Arbeiterschwerpunkt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "Arbeitslos: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "Keine Weltwunder errichtet."

-- ===== Great person generation (CityView) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "Keine Erzeugung Großer Persönlichkeiten."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} von {3_Max}"

-- Focus item label when the current focus matches.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, ausgewählt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "Wachstum vermeiden, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "Geländefeld-Zuweisung zurücksetzen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} ausgewählt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "Geländefeld-Zuweisung zurückgesetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "keine Arbeitslosen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "zugewiesen"

-- Buildings sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "Gebäude"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "Keine Gebäude."

-- Specialists sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "Spezialisten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "Keine Spezialisten-Felder."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] = "{1_Building} {2_Specialist} Feld {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "besetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "besetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "unbesetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] =
    "besetzt, Arbeiter vom Geländefeld abgezogen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] =
    "unbesetzt, Arbeiter dem Geländefeld zugewiesen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "Spezialist kann nicht hinzugefügt werden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "Manuelle Spezialistenkontrolle, {1_State}"

-- Great works sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "Große Werke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "Kunst"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "Schrift"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "Musik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} Feld {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} Feld {3_N}, leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] = "{1_Building} Themenbonus plus {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "Keine Felder für Große Werke."

-- Production queue sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "Produktionswarteschlange"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "Warteschlange leer."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    one = "Slot 1, {1_Name}, {2_Turns} Runde, {3_Percent} Prozent. {4_Help}",
    other = "Slot 1, {1_Name}, {2_Turns} Runden, {3_Percent} Prozent. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "Slot 1, {1_Name}, {2_Percent} Prozent. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "Slot 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    one = "Slot {1_N}, {2_Name}, {3_Turns} Runde. {4_Help}",
    other = "Slot {1_N}, {2_Name}, {3_Turns} Runden. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "Slot {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "Slot {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "[ICON_PRODUCTION] Produktion verbleibend: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "{1_Name} Aktionen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "Nach oben verschieben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "Nach unten verschieben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "Aus der Warteschlange entfernen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "Zurück"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "nach oben verschoben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "nach unten verschoben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "entfernt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "Warteschlangenmodus, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "Produktion wählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "Mit Gold oder Glauben kaufen"

-- Hex map sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Gebiet verwalten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "Gebiet verwalten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "bebaut"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "angeheftet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "blockiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "nicht bebaut"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "käuflich, {1_Gold} Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "käuflich, {1_Gold} Gold, nicht leistbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "nicht leistbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "Cursor über Stadtfelder bewegen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "Feld bebauen oder kaufen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Zurück zum Stadtüberblick"

-- Ranged strike sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "Fernkampfangriff"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "Fernkampfangriff"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "kein Angriff möglich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "gefeuert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] = "{1_Name}, {2_MyStr} gegen {3_TheirStr}, {4_Dmg} Schaden"
-- Gift-unit / gift-improvement target picker
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "Einheit schenken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "Modernisierung schenken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "Modernisierung übergeben"
-- Rename / Raze hub items
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "Stadt umbenennen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "Stadt niederbrennen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "Niederbrennen beenden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "Niederbrennen beendet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_TOO_SHORT"] = "Name muss mindestens 3 Zeichen lang sein. Abgebrochen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_INVALID_CHARS"] = "Name enthält ungültige Zeichen. Abgebrochen."

-- Foreign / spy-screen refusals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "Spionage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] = "Stadtdurchlauf nicht verfügbar während Spionage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "Ihr könnt keine Fernkampfangriffe für eine Stadt starten, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "Ihr könnt die Produktion einer Stadt nicht ändern, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "Ihr könnt keine Geländefelder für eine Stadt bebauen, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] =
    "Ihr könnt keine Geländefelder für eine Stadt kaufen, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] =
    "Ihr könnt keine Gebäude in einer Stadt verkaufen, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] =
    "Ihr könnt den Fokus einer Stadt nicht ändern, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "Ihr könnt keine Spezialisten in einer Stadt verwalten, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "Ihr könnt keine Großen Werke in einer Stadt einsehen, die Euch nicht gehört"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "Ihr könnt keine Bürger in einer Stadt zuweisen, die Euch nicht gehört"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "kaufbar"
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
    one = "{1_Num} Geländefeld enthüllt",
    other = "{1_Num} Geländefelder enthüllt",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "Enthüllt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "Feind: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "Einheiten: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "Städte: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "Ressourcen: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "Verborgen"
-- Foreign-unit watch. Four lines spoken at the start of each player turn
-- summarising what foreign units entered / left view during the AI turn
-- just past, split by hostile (at-war + barb) and neutral (everyone else
-- not on the active team). The list arg is comma-joined "{count} {civ-
-- adjective} {unit-name}" pieces; count is omitted when 1. Bare unit name
-- without a plural suffix is intentional (Civ V text data has no plural
-- TXT keys; hand-rolling per-locale plural rules is a maintenance trap).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] = "Neue feindliche Einheiten in Sichtweite: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] =
    "Feindliche Einheiten nicht mehr in Sichtweite: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] = "Neue neutrale Einheiten in Sichtweite: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] = "Neutrale Einheiten nicht mehr in Sichtweite: {1_List}"
-- Foreign-clear watch. One line spoken at the start of each player turn
-- summarising goody huts and barbarian camps that some other civ cleared
-- on a plot the active team could see during the AI turn just past. Camps
-- and ruins are tallied separately and joined with the AND key when both
-- are non-zero. Pluralized via Text.formatPlural; PREFIX / AND / SUFFIX
-- are bare strings so translators get full control of word order.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "Jemand anderes hat beansprucht: "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " und "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    one = "{1_Num} sichtbares Barbarenlager",
    other = "{1_Num} sichtbare Barbarenlager",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    one = "{1_Num} sichtbare antike Ruine",
    other = "{1_Num} sichtbare antike Ruinen",
}
-- Gone-on-revisit. RevealAnnounce speaks this as the third line of its
-- flush (after Revealed: and Hidden:) when a barbarian camp / ancient
-- ruins disappeared from a plot the active team had previously seen
-- it on. Singular form drops the count for naturalness ("Gone:
-- barbarian camp" beats "Gone: 1 barbarian camp"); plural prefixes
-- the count. AND-join reuses TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND
-- since the connective is the same.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "Verschwunden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    one = "Barbarenlager",
    other = "{1_Num} Barbarenlager",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    one = "antike Ruinen",
    other = "{1_Num} antike Ruinen",
}
-- Turn lifecycle speech. Turn-start is the game-side "Turn: N" label plus
-- the game's AD/BC year, joined by a comma so the moving parts (number
-- first, year second) read as a single line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "Runde beendet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "Rundenende abgebrochen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Strg plus Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] = "Runde beenden oder erste Blockade ansagen und öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Strg plus Umschalt plus Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "Runde trotz der Abfrage für Einheiten ohne Befehle beenden; andere Blockaden werden weiterhin angesagt und geöffnet"
-- Empire status readouts (T/R/G/H/F/P/I bare-letter keys in baseline). Each
-- key speaks one composed line; conditional clauses join with comma. Help
-- entries describe the underlying readout, not the panel item, since the
-- speech composes data from multiple panel surfaces.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "{1_Num} über dem Einheitenlimit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    one = "{1_Turns} Runde zu {2_Tech}, Forschung +{3_Rate}",
    other = "{1_Turns} Runden zu {2_Tech}, Forschung +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} abgeschlossen, Forschung +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "keine Forschung, Forschung +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "Forschung deaktiviert"
-- Plural is driven by {4_Avail}: "1 of 1 trade route" vs "1 of 5 trade
-- routes". The Used count can be 1 even when Avail is many.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    one = "+{1_Rate} Gold, {2_Total} gesamt, {3_Used} von {4_Avail} Handelsweg",
    other = "+{1_Rate} Gold, {2_Total} gesamt, {3_Used} von {4_Avail} Handelswegen",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    one = "minus {1_Rate} Gold, {2_Total} gesamt, {3_Used} von {4_Avail} Handelsweg",
    other = "minus {1_Rate} Gold, {2_Total} gesamt, {3_Used} von {4_Avail} Handelswegen",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "kein {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"
-- Section labels for Shift+letter detail readouts. Inserted as
-- "{Label}: " between sections by newDetail.compose() at transitions
-- the engine's first item doesn't already anchor (Help and Income
-- reuse engine TXT_KEY_HELP / TXT_KEY_EO_INCOME).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "Goldenes Zeitalter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "Religionen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "Große Persönlichkeiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "Einfluss"
-- Empire status readout payloads. Each STATUS_* below is one composed line
-- spoken by a bare-letter empire-status key (T/R/G/H/F/P/I) or its Shift+
-- detail variant; the active variant is selected by the live engine state
-- (e.g. STATUS_HAPPY when net happiness is non-negative, STATUS_UNHAPPY
-- between -1 and -9, STATUS_VERY_UNHAPPY below). _OFF tokens fire when the
-- corresponding system is disabled in the game options. The HELP_KEY /
-- HELP_DESC pairs further down cover all of these for the help overlay.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} Zufriedenheit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "Unzufrieden minus {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "Sehr unzufrieden minus {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    one = "Goldenes Zeitalter für {1_Turns} Runde",
    other = "Goldenes Zeitalter für {1_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "{1_Cur} von {2_Threshold} zum Goldenen Zeitalter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "Zufriedenheit deaktiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} Glaube, {2_Total} gesamt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "Religion deaktiviert"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PANTHEON, which inlines a long rules
-- explainer after the data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "{1_Num} Glaube für nächstes Pantheon"
-- Replaces TXT_KEY_TP_FAITH_PANTHEONS_LOCKED, a four-sentence rules
-- paragraph with no live data.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "keine Pantheons verfügbar"
-- Replaces TXT_KEY_TP_FAITH_NEXT_PROPHET, a one-sentence verbose phrasing
-- that wraps a single data value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "{1_Num} Glaube für nächsten Großen Propheten"
-- Replaces TXT_KEY_TP_TECH_CITY_COST and TXT_KEY_TP_CULTURE_CITY_COST,
-- both one-sentence explainers wrapping a single percent. The engine's
-- policy version also tacks on a "don't expand too much!" rules nudge.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "+{1_Pct}% Forschungskosten pro Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "+{1_Pct}% Sozialpolitikkosten pro Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    one = "+{1_Rate} Kultur, {2_Turns} Runde bis zur Sozialpolitik",
    other = "+{1_Rate} Kultur, {2_Turns} Runden bis zur Sozialpolitik",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] =
    "+{1_Rate} Kultur, keine Sozialpolitiken mehr verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] =
    "keine Kultur, {1_Cur} von {2_Cost} bis zur nächsten Sozialpolitik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "Sozialpolitiken deaktiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} Tourismus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    one = "+{1_Rate} Tourismus, einflussreich bei {2_Count} Zivilisation",
    other = "+{1_Rate} Tourismus, einflussreich bei {2_Count} Zivilisationen",
}
-- Plural is driven by {3_Total}: "1 of 1 civ" vs "1 of 5 civs". {2_Count}
-- can be 1 even when Total is many.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    one = "+{1_Rate} Tourismus, einflussreich bei {2_Count} von {3_Total} Zivilisation",
    other = "+{1_Rate} Tourismus, einflussreich bei {2_Count} von {3_Total} Zivilisationen",
}
-- Help-overlay entries for the empire status readout keys above. Each
-- pair is one row in the help screen: KEY_* names the keystroke, DESC_*
-- summarises what the key reads. The bare-letter variants (T R G H F P I)
-- speak the headline summary; the Shift+letter _DETAIL variants speak the
-- per-source breakdown.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "Runde und Datum, mit Einheitenlimit bei Überschreitung und strategischen Ressourcenengpässen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "Aktuelle Forschung und Forschung pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "Gold pro Runde, Gesamtgold und Handelswege"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "Zufriedenheit des Reiches, Anzahl der Luxusgüter die Zufriedenheit bringen, und Goldenes Zeitalter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "Glaube pro Runde und insgesamt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] =
    "Kultur pro Runde und Zeit bis zur nächsten Sozialpolitik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] =
    "Tourismus pro Runde und Anzahl beeinflusster Zivilisationen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Umschalt plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "Forschung nach Quellen aufgeschlüsselt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Umschalt plus G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "Goldeinnahmen und -ausgaben nach Quellen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Umschalt plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "Quellen der Zufriedenheit, Quellen der Unzufriedenheit und Effekt des Goldenen Zeitalters"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Umschalt plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "Glaube nach Quellen aufgeschlüsselt sowie Zeitpunkt des nächsten Propheten oder Pantheons"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Umschalt plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "Kultur nach Quellen aufgeschlüsselt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Umschalt plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "Große Werke, freie Plätze und Anzahl beeinflusster Zivilisationen"
-- Task list readout. Scenario-driven objective tracker; silent when no
-- active tasks exist (the common case outside scenarios and tutorials).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Umschalt plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "Aktive Szenarioaufgaben vorlesen"
-- GameMenu (Esc pause menu) tab labels and mod-list payloads. Tab labels
-- sit alongside the engine-keyed Details tab (TXT_KEY_POPUP_GAME_DETAILS).
-- The Mods tab lists every mod active in the current save: NO_MODS for the
-- empty-list state, MOD_ENTRY for each row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "Aktionen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "Keine Mods aktiviert."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, Version {2_Version}"
-- Civilopedia (picker/reader two-tab) strings. PICKER_READER_EMPTY and
-- _NO_SELECTION are the two empty-state words used by the shared
-- PickerReader widget; they are mirrored in the FrontEnd strings file
-- because PickerReader serves both Contexts (saves picker, mods picker,
-- replay picker on the front-end side; civilopedia on the in-game side).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "Kategorien"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "Inhalt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "Kein Artikeltext verfügbar."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "Kein Inhalt für diesen Eintrag."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "Kein Eintrag ausgewählt. Wechselt zum Tab Kategorien, um einen auszuwählen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "Einleitung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "Beginn der Historie."

-- Civilopedia (end of history/advisor boundaries)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "Ende des Verlaufs."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "Vorheriger oder nächster Artikel im Verlauf"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] = "Vorheriges oder nächstes Konzept im Verlauf"

-- SaveMenu
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "Speicherstände"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "Speicherdetails"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "Keine Speicherstände in dieser Liste."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "Speichername"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] = "Speichername ist leer oder enthält ungültige Zeichen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "Diesen Spielstand überschreiben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "In diesen Slot speichern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "{1_Name} überschreiben?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] = "Steam-Cloud-Slot {1_Num} überschreiben?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "{1_Name} löschen?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "Spielstand gelöscht."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Steam-Cloud-Slot {1_Num}: leer"

-- Icon spoken replacements
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "Nahrung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "Produktion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "Forschung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "Forschung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "Glaube"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "Tourismus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "Große Persönlichkeiten"
-- Dedup alias: singular form adjacent to icon. Engine source: TXT_KEY_RELIGION_GREAT_PERSON_FOCUS etc.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "Große Persönlichkeit"
-- Per-specialist title aliases. Engine source: TXT_KEY_SPECIALIST_<X>_TITLE.
-- DE_DE pattern follows Units_Expansion2.xml: "Großer-Musiker-Punkte:" etc.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "Gr.-Künstler-Punkte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "Gr.-Ingenieur-Punkte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "Gr.-Händler-Punkte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "Gr.-Wissensch.-Punkte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "Großes Werk"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "Kampfstärke"
-- Dedup alias. Engine source: TXT_KEY_PRODUCTION_STRENGTH ("[ICON_STRENGTH] Stärke: N").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = "Stärke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "Fernkampfstärke"
-- Dedup alias. Engine source: TXT_KEY_PRODUCTION_RANGED_STRENGTH. Primary and engine forms
-- both start with "Fernkampfstärke", so alias is dormant; empty is fine.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "Bewegungspunkte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "Zufriedenheit"
-- Dedup alias. Engine source: shorter "Happy" / "Zufrieden" pairing in per-yield lines.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "zufrieden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "Unzufriedenheit"
-- Dedup alias. Same pattern as happy alias.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "unzufrieden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "links"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "rechts"

-- ChooseProduction popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "Produktion auswählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "Produzieren"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "Kaufen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "Aktuelle Warteschlange"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "Marionette"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] =
    "hinzugefügt, Slot {1_Slot} in der Warteschlange"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "Warteschlange voll"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "Warteschlange leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "Warteschlange hat {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    one = "{1_Num} Runde",
    other = "{1_Num} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} Glaube"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "Gebäude {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "{1_Name} gekauft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    one = "{1_Name}, {2_Turns} Runde",
    other = "{1_Name}, {2_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"

-- ChooseTech popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "Forschung auswählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "kostenlose Technologie, noch {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "stehlen von {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} Forschung pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    one = "aktuell erforscht: {1_Name}, {2_Turns} Runde",
    other = "aktuell erforscht: {1_Name}, {2_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "kostenlos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "aktuell erforscht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "eingereiht, Slot {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    one = "{1_Num} Runde",
    other = "{1_Num} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "Technologiebaum öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "erforscht {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "{1_Name} erhalten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "{1_Name} gestohlen"

-- Tech Tree screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "Technologiebaum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "Alle Technologien"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "Warteschlange"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "erforscht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "Voraussetzungen nicht erfüllt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "gesperrt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "keine aktuelle Forschung, Warteschlange leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "aktuell"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "{1_Name} eingereiht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "bereits erforscht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "nicht als kostenlose Technologie verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "kann nicht gestohlen werden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Oben/Unten/Links/Rechts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Oben/Unten durch die Zeitalter-Spalte, Links/Rechts durch die Reihe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Rechts zur abhängigen Technologie, Links zur Voraussetzung, Oben/Unten für Geschwistertechnologien"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] = "Raster- oder Baumnavigation umschalten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "Raster"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "Baum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "Fokussierte Technologie erforschen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Umschalt plus Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "Fokussierte Technologie einreihen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Strg plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "Civilopedia-Eintrag öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "Buchstabe / Ziffer / Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "Tippen zum Suchen nach Name oder Entdeckungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "Technologiebaum schließen"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "Technologiebaum schließen"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "Sozialpolitiken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "Politiken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "Ideologie"
-- Branch-level status words (top tier of the policy tree). OPENED: at
-- least one policy in the branch is adopted. FINISHED: every policy in
-- the branch is adopted. ADOPTABLE: branch is closed but the player has
-- the culture to open it. LOCKED_ERA / LOCKED_RELIGION / LOCKED: cannot
-- open yet because of era requirement, missing religion, or unmet
-- prerequisite. BLOCKED: a mutually-exclusive branch was opened first
-- (the policy UI shows this as a red-X, separate from the "needs prereq"
-- lock the tech tree spells "locked").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "geöffnet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "abgeschlossen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "annehmbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "gesperrt, erfordert {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] =
    "gesperrt, erfordert eine gegründete Religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "gesperrt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "blockiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} von {2_Total} angenommen"
-- Individual-policy status words (one tier down, applies to each policy
-- inside an opened branch). OPENER / FINISHER mark the two automatic
-- bookend policies. ADOPTED: chosen and active. ADOPTABLE: selectable now
-- with the player's current culture. BLOCKED: prerequisite policy in the
-- same branch hasn't been adopted yet (a within-branch sequencing block,
-- distinct from STATUS_BLOCKED above which is a cross-branch ideology
-- conflict). LOCKED: the parent branch isn't opened.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] =
    "Eröffner, kostenlos gewährt wenn der Zweig geöffnet wird"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] =
    "Abschluss, vergeben wenn der Zweig vollständig ist"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "angenommen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "annehmbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "blockiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "gesperrt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "gesperrt, erfordert {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "{1_Branch} öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] =
    "{1_Cur} von {2_Cost} Kultur, {3_Per} pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    one = "{1_Turns} Runde bis zur nächsten Sozialpolitik",
    other = "{1_Turns} Runden bis zur nächsten Sozialpolitik",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    one = "{1_Num} kostenlose Sozialpolitik verfügbar",
    other = "{1_Num} kostenlose Sozialpolitiken verfügbar",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    one = "{1_Num} kostenloser Grundsatz verfügbar",
    other = "{1_Num} kostenlose Grundsätze verfügbar",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "Ideologie noch nicht eingeführt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "Ideologie in diesem Spiel deaktiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "Grundsätze der Stufe 1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "Grundsätze der Stufe 2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "Grundsätze der Stufe 3"
-- Ideology tenet-slot rows. {1_Num} is the slot index within its level.
-- _FILLED carries the picked tenet's name and short effect; _NAME_ONLY
-- omits the effect (used in compact contexts). The four EMPTY_* variants
-- describe why the slot can't be picked yet: AVAILABLE means it can be
-- picked now; REQ_SLOT means another slot in the same level must be
-- filled first ({2_Req} is that slot's index); REQ_CROSS means the
-- prerequisite is in a different level ({2_Level} is the ideology tier
-- 1 / 2 / 3, {3_Req} is the slot index within that tier); CULTURE means
-- the player does not have enough culture for any tenet right now.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "Platz {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "Platz {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "Platz {1_Num}, leer, verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
    "Platz {1_Num}, leer, erfordert Platz {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "Platz {1_Num}, leer, erfordert Stufe {2_Level} Platz {3_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] = "Platz {1_Num}, leer, unzureichende Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "Ideologie ändern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "Ideologie ändern, nicht verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "Unzufriedenheit {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "Grundsatz wählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "keine Grundsätze verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "{1_Name} annehmen?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "Zweig {1_Name} öffnen?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "{1_Name} annehmen?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "Ideologie ändern?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "{1_Name} angenommen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "{1_Name} geöffnet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "Grundsatz {1_Name} angenommen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "Ideologiewechsel beantragt"
-- Number-entry primitive (BaseMenuNumberEntry). Digits / Backspace / Enter /
-- Esc bindings with their own help strings because the digit surface isn't
-- covered by the menu's standard A-Z search entry.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Ziffern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "Ziffer hinzufügen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "Letzte Ziffer entfernen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "Betrag bestätigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "{1_Label} eingeben, max. {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "leer"
-- Diplomacy trade screen. Labels for the flat top-level menu (Your / Their
-- Offer), drawer tab names, quantity-bearing Offering lines, and the Other
-- Players group for third-party peace / war actions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "Handel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "Handel mit {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "Euer Angebot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "Ihr Angebot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "Angeboten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "Verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, Bevölkerung {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "Stimmenzusage"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "Frieden schließen mit {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "Krieg erklären gegen {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "Frieden schließen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "Krieg erklären"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "Andere Spieler"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "nichts verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "nichts auf dem Tisch"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "Ihr habt {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "sie haben {1_Num}"
-- DiploCurrentDeals review labels. Each deal renders as one Text leaf
-- whose label inlines the full contents; these are the side prefixes the
-- builder concatenates around the per-item descriptions. Colon-then-list
-- form, distinct from LABEL_VALUE's space form and DIPLO_GOLD_AMOUNT's
-- comma form; the colon reads as a brief pause before the list of items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "wir geben: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "sie geben: {1_List}"
-- Past-tense variants for the Historical Deals group, where the deal has
-- already concluded.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "wir gaben: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "sie gaben: {1_List}"
-- DiploCurrentDeals tab title and the Historical Deals group label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "Abkommen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "Vergangene Abkommen"
-- Diplomatic Overview (Relations / Global tabs). Per-civ composed lines,
-- trade / third-party fragment prefixes, section group headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader} von {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "Punktzahl {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "Gold {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "Gold pro Runde {1_N}"
-- Per-resource entry inside strategic / luxury / nearby lists.
-- {1_Name} is the resource's localized name, {2_N} is the count owned.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "strategisch: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "Luxus: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "in der Nähe: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "Bonus: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "Politiken: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "Weltwunder: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "Große Zivilisationen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "Stadtstaaten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "Keine Zivilisationen getroffen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "Keine Abkommen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "eingehender Vorschlag"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "Antwort abgewartet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "Team {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "erforscht {1_Tech}"

-- Diplomacy / influence / CS bonuses
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} Einfluss"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} pro Runde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "verankert bei {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} Zufriedenheit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} Glaube"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} Nahrung in der Hauptstadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} Nahrung in anderen Städten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} Forschung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    one = "nächste Geschenkeinheit in {1_N} Runde",
    other = "nächste Geschenkeinheit in {1_N} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "exportiert {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "offene Grenzen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "einschüchterbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "Verbündete von {1_Civ}"

-- F4 Diplomatic Overview column headers (major civs)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "Eure Beziehung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "auswärtige Beziehungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "Ressourcen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "Zeitalter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "Politiken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "Weltwunder"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "Punktzahl"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_DECLARE_WAR"] = "Krieg erklären"

-- F4 Diplomatic Overview column headers (minor civs / city-states)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "Beziehung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "Merkmal und Persönlichkeit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "Einfluss"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "verbündet mit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "Quests"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "nahe Ressourcen"

-- Empty-cell labels
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "keine"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "niemand"

-- Gold cell
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, {2_GPT} pro Runde"

-- Influence threshold gap fragments
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "{1_N} benötigt, um Freunde zu werden"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "{1_N} benötigt, um Verbündete zu werden"

-- Allied-with cell variants
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "Ihr"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, {2_N} zum Verdrängen benötigt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] =
    "unbekannte Zivilisation, {1_N} zum Verdrängen benötigt"

-- Trait-and-personality cell
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL"] = "{1_Trait}, {2_Personality}"

-- City Stats drillable groups
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "Erträge"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "Religion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "Handelswege"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "Ressourcen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "keine Aufschlüsselung verfügbar"

-- Storage / threshold tail
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{1_Cur} von {2_Threshold}"

-- Culture's next-tile countdown
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    one = "nächstes Geländefeld in {1_Num} Runde",
    other = "nächstes Geländefeld in {1_Num} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "Geländefelderweiterung gestoppt"

-- Happiness one-liner
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] =
    "lokale Zufriedenheit {1_Local}, Unzufriedenheit {2_Unhappiness}"

-- Religion group rows
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    one = "{1_Religion}, {2_Followers} Anhänger, {3_Pressure} Druck",
    other = "{1_Religion}, {2_Followers} Anhänger, {3_Pressure} Druck",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    one = "{1_Religion}, heilige Stadt, {2_Followers} Anhänger, {3_Pressure} Druck",
    other = "{1_Religion}, heilige Stadt, {2_Followers} Anhänger, {3_Pressure} Druck",
}

-- Resource group row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RESOURCE_LINE"] = "{1_Name} {2_Num}"

-- ChooseInternationalTradeRoutePopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = {
    one = "{1_Num} Hexfeld",
    other = "{1_Num} Hexfelder",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "Ihr erhaltet {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "Sie erhalten {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} erhält {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} Druck"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "Keine gültigen Ziele."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "Keine gültigen Heimatstädte."

-- Trade Route Overview (TRO)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Strg plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "Handelsweg-Übersicht öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "Eure Handelswege"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "Verfügbare Handelswege"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "Handelswege mit Euch"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "Karawane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "Frachter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} nach {3_To}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "der Stadtstaat {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    one = "{1_Num} Runde verbleibend",
    other = "{1_Num} Runden verbleibend",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "Keine Handelswege."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "Keine Quellenaufschlüsselung verfügbar."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "Sortieren nach: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "Sortieren nach"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "erhaltenes Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "erhaltene Forschung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "erhaltene Nahrung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "erhaltene Produktion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "religiöser Druck zum Ziel"

-- Leader description infrastructure
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "Anführer beschreiben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "Keine Beschreibung für diesen Anführer verfügbar."

-- Leader portrait descriptions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "George Washington, erster Präsident der Vereinigten Staaten, steht in einem getäfelten Innenraum zwischen schweren roten Vorhängen, die zu beiden Seiten zurückgezogen sind, die Hände locker an den Hüften. Er trägt das schwarze Zivilgewand eines amerikanischen Gentleman des späten achtzehnten Jahrhunderts: einen dunklen zweireihigen Rock, der lang über die Oberschenkel geschnitten ist, mit zwei Reihen messingfarbener Knöpfe auf der Vorderseite, darunter eine passende Weste, an der Kehle ein gekräuseltes weißes Jabot und an den Handgelenken weiße Manschetten. Sein Haar ist weiß gepudert, vom hohen Stirnbereich zurückgekämmt, an den Seiten über den Ohren gelockt und hinten in einem Zopf zusammengefasst, der mit einer schwarzen Seidenband gebunden ist. Zu seiner Linken steht ein großer Erdglobus auf einem gedrechselten Holzständer; auf einem kleinen Tisch daneben liegt ein gebundener Band aufgeschlagen, ein blaues Lesebändchen hängt aus seinen Seiten. Zu seiner Rechten trägt ein heller Steinsimsrahmen einen hohen Messingkandelaber mit noch unangezündeten Kerzen, und darüber hängt eine gerahmte Landschaft in einem vergoldeten Rahmen. Zwischen den auseinandergezogenen Vorhängen hinter ihm erhebt sich eine kannelierte Säule vor einem taghellen Himmel und einem flüchtigen Blick auf hügeliges grünes Land. Die Komposition orientiert sich an Gilbert Stuarts Lansdowne-Porträt von 1796, wo das Zeremonieschwert und die Staatsdokumente hier durch den Globus und das Buch ersetzt wurden."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "Harun al-Rashid, Befehlshaber der Gläubigen und fünfter Kalif der Abbasiden, sitzt am späten Vormittag in einem Palastgarten; hinter ihm öffnet sich ein gepflasterter Innenhof auf eine helle Steinkolonnade mit Spitzbögen, dahinter wölbt sich eine ferne Kuppel durch den Dunst. Er ist bärtig und dunkelhaarig, auf einem niedrigen geschnitzten Holzstuhl sitzend, dessen Armlehnen in runden Endknöpfen enden; sein Kopf ist in einen hohen Safranturban gewickelt, aus dessen Spitze eine weiche Kappe emporsteigt. Eine breite Schärpe aus demselben Safranstoff, an ihren Enden goldbrokat-besetzt und goldfransen-besäumt, ist von der rechten Schulter über seine Brust gewickelt und an der linken Hüfte über einem weiten weißen Gewand zusammengeführt, das bis auf die Knöchel fällt; der Saum des Gewandes ist mit demselben Goldbrokat besetzt. Seine rechte Hand ist in Schulterhöhe erhoben und hält einen qalam, die arabische Rohrfeder, zwischen Daumen und Zeigefinger; seine linke Hand liegt flach auf dem Schoß. Seine Füße stehen auf einem runden Teppich, der in blauen, cremefarbenen und rostfarbenen Medaillons gewebt ist; auf dem Pflaster daneben liegen zwei gebundene Kodizes, der oberste ein tiefrotes, goldgeprägtes Brett. Bepflanzte Palmfarne und Farne in glasierten blauen Schalen stehen zu beiden Seiten des Stuhls, rechts erhebt sich ein hoher Terrakottakrug, und dunkle Hecken schließen den Mittelgrund unter der Arkade ab."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "Ashurbanipal, König der Welt, König von Assyrien, steht in einem Säulensaal seines Palastes; in seiner rechten Hand hält er eine Tafel aus hellem Stein aufrecht vor seiner Brust, die Finger über den oberen Rand gekrümmt. Er ist breitschultrig und hat bloße Arme, die Haut warm im Licht. Sein Bart ist lang und gerade geschnitten, in dichten parallelen Locken bis zur Brust frisiert; sein schwarzes Haar fällt in gleichen Ringellocken bis zur Schulter. Ein flaches Golddiadem umzieht seine Stirn, das Band mit Rosetten gearbeitet. Er trägt den knöchellangen königlichen Schulterschal des assyrischen Hofes: ein tiefblaues Untergewand, das mit Goldrosetten übersät ist, darüber einen schweren Magentamantel, dessen Fransensaum diagonal über seinen Rumpf, über die linke Schulter und den Rücken hinabläuft, die Säume mit Gold- und Rotstickerei besetzt. Breite Goldmanschetten umklammern beide Handgelenke, und ein entsprechendes Band umzieht seinen rechten Oberarm. Hinter ihm erhebt sich eine Bogennische, gerahmt von schlanken Säulen mit hellen Volutenkapitellen; zu beiden Seiten, auf Sockeln, stehen die dunklen bärtigen Gestalten der Lamassu, der menschenköpfigen geflügelten Stiere, die die Tore assyrischer Paläste bewachten. An der Rückwand zeigen flache Steinreliefs Pferde im Profil in einem horizontalen Register, nach den Jagd- und Wagenszenen seines Palastes in Ninive. Der Boden ist in hellen Fliesen gelegt, der Saal fällt zu beiden Seiten ins Dunkel ab."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "Maria Theresia, von Gottes Gnaden verwitwete Kaiserin des Heiligen Römischen Reiches, Königin von Ungarn, Böhmen, Dalmatien, Kroatien, Slawonien, Galizien und Lodomerien, Erzherzogin von Österreich (und so weiter und so fort), steht auf einer überdachten Bogengalerie aus Stein, deren hohe Rundbögen auf einer Seite eine Alpenlandschaft mit schneebedeckten Gipfeln freigeben und auf der anderen auf einen polierten Boden mit einem roten Teppichläufer entlang der Kolonnade. Rote Damastpaneele hängen zwischen den Bögen an der Innenwand, und das von links einfallende Sonnenlicht wirft lange Schatten über den Stein. Sie steht in Dreiviertelansicht, die Arme leicht vor der Taille verschränkt, den Kopf leicht abgewandt. Ihr Haar ist hellblond, zurückgesteckt und im Hofstil hoch aufgesteckt. Ihr Gewand ist aus blassblaugrauer Seide; das Mieder ist eng bis zu einem spitzen Ende an der Taille geschnürt und vorne durch einen Brustharnisch abgeschlossen, das steife verzierte Paneel mit Silberstickerei und kleinen Edelsteinen gearbeitet. Ein weiter Reifrock breitet sich über Paniers aus, dieselbe Silberstickerei verläuft als schleppender Streifen die offene Vorderseite des Überrocks hinunter. Die Ärmel enden am Ellbogen in kurzen Bauschärmeln, mit weißer Spitze besetzt. Ein transparentes Spitzentuch ist über die Schultern gelegt und in den Ausschnitt gesteckt. Sie trägt keine Krone und keinen sichtbaren Schmuck. Hinter ihr weichen die Bögen in hellem Stein zurück, das Geländer aus gedrechselten Säulen verliert sich in der Ferne, die Alpen hell und der Himmel klar."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "Montezuma Xocoyotzin, Huey Tlatoani der Mexica, steht vor einem großen Kohlenbecken, dessen Flammen zwischen ihm und dem Betrachter emporschlagen; der Saal um ihn herum ist allein von diesem Feuer erleuchtet. Er ist mit nacktem Oberkörper und kräftig gebaut, die Haut dunkel im Feuerschein, das Gesicht halb im Schatten. Seine Krone ist das Quetzalapanecayotl, ein Aufsatz aus langen schillernden Quetzalschwanzfedern in Grün und Blau, mit einem goldenen Stirnband gebunden. Goldene Spulen durchbohren seine Ohren, ein Jade-Gold-Kragen umzieht seinen Hals, breite Jade-Gold-Manschetten umklammern seine Handgelenke, und Goldbänder umringen jeden Bizeps. Hinter ihm ist in eine Wand aus rotem Mauerwerk eine große geschnitzte Scheibe eingelassen, die konzentrische Bänder aus Glyphen um ein zentrales Gesicht zeigt, nach dem aztekischen Sonnenstein. Die Wände zu beiden Seiten sind in Reihen stilisierter Schädel geschnitzt, dem Tzompantli, dem an aztekischen Tempeln ausgestellten Schädelgestell; über jedem Gestell erhebt sich eine große geschnitzte aztekische Göttermaske, und ein Steinurne an der Spitze jeder Wand brennt mit einer hohen Flamme. Der gesamte Saal leuchtet im Rot und Gold des Feuerscheins."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "Nebukadnezar II., König von Babylon, sitzt auf einem massiven Steinthron in einem Saal aus grün beleuchteten Mauerwerk, die Wände hinter ihm verlieren sich im Schatten. Er trägt das Agu, die hohe gerundete Kappe der neubabylonischen Könige, die an der Stirn von einem Band eingefasst ist. Sein Bart ist lang, dunkel und in gestaffelten Reihen eng gerollter röhrenförmiger Locken frisiert. Sein Gewand ist tiefrot, kurzärmelig und über und über mit gleichmäßig verteilten Goldrosetten gemustert; es ist an der Taille mit einer breiten bestickten Schärpe gegürtet, der Rock fällt gerade bis zu seinen nackten Füßen und ist mit einem Streifen heller Fransen gesäumt. Schwere Goldmanschetten umklammern jedes Handgelenk. Seine Hände liegen mit den Handflächen nach unten auf den breiten Armlehnen des Throns, die vorne in geschnitzte Löwenkopfkonsolen enden, die knurrenden Mäuler auf Kniehöhe nach außen gerichtet; ein kleineres passendes Löwenkopfpaar ragt aus dem Sockel des Throns zu seinen Füßen. Flankierend stehen neben dem Thron zwei hohe Steinsockel, in gewundene Schlangenleibern geschnitzt, jeder mit einer breiten flachen Schale gekrönt, aus der eine blassgrüne Flamme aufsteigt; sie ist das einzige Licht in der Kammer und wirft ihr fahles Grün über die Steinwände, sein Gesicht und sein Gewand."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "Dom Pedro II., Kaiser von Brasilien, sitzt an einem breiten hölzernen Schreibtisch in einem dunklen getäfelten Arbeitszimmer; die Szene ist so gerahmt, als stünde der Betrachter ihm gegenüber am Tisch. Er ist ein älterer Mann, breitschultrig und kräftig gebaut, mit einem vollen weißen Bart, der weit unter den Kragen fällt, und schütterem weißen Haar, das von einer hohen Stirn zurückgestrichen ist. Er trägt einen dunklen Gehrock über einer dunklen Weste und einem weißen Hemd mit hohem Kragen, an der Kehle eine dunkle Krawatte. An seiner linken Brust ist der juwelenverzierte Stern des Kaiserlichen Ordens des Südlichen Kreuzes befestigt, dessen Großmeister er war. Beide Hände liegen flach auf dem Tisch; lose Papiere und ein kleines Tintenfass liegen vor ihm, und eine Federkiel steht aufrecht in einem runden Federhalter neben seiner rechten Hand. Auf dem Tisch zu seiner Linken steht eine angezündete Öllampe mit einem hohen klaren Glaszylinder und einem polierten Messingsockel; ihre Flamme ist der hellste Punkt im Bild und die Hauptlichtquelle, die auf sein Gesicht und seine Hände fällt. Hinter ihm und zu den Seiten sind die Wände vom Boden bis zur Decke mit Bücherregalen im tiefen Schatten gesäumt. Ein hohes Fenster an seiner linken Schulter zeigt durch schräge Holzjalousien einen Streifen Nachthimmel in tiefem Blau, dahinter sind Palmwedel silhouettiert. Ganz links im Bild fängt ein kleineres Bleiglasfenster mit Rautenfeldern die wärmeren Farben eines Abendhimmels auf, und eine kleine Kaminuhr steht auf einem Regal darunter. Der Boden ist mit einem gemusterten Teppich in gedämpften Rot- und Goldtönen bedeckt."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "Theodora, Augusta der Römer, lehnt auf einem niedrigen Ruhebett aus Goldbrokat auf einer offenen Säulenterrasse, einen Arm über ein Kissen drapiert, den anderen im Schoß ruhend. Ihre Krone ist ein juwelenverziertes Stemma, die gewölbte Kappe des byzantinischen Kaiserkopfschmucks, das Band mit einer Reihe Cabochonsteine besetzt. Ein grüner Edelstein sitzt markant an der Stirn, der Aufsatz darüber steigt zu einem zweiten grünen Stein auf, der in Goldarbeit gefasst ist. Ihr Haar ist darunter zurückgekämmt und fällt lang über ihre rechte Schulter. Pendilia, die perlenverziertes Anhänger des Stemmas, hängen neben ihrem Gesicht; ein Maniakis umzieht ihre Kehle, das juwelenverzierte Kaiserhalsband des Ostens. Ihr Gewand ist vielschichtig: ein eng anliegendes tiefrotes Mieder, in der Mitte mit einem Goldmedaillon geschlossen, ein Goldgrünrock mit Rankenmuster über ihrem Schoß und darunter ein langer Unterrock aus dunklem Blaugrün, am Saum mit schmalem Gold besetzt. Goldmanschetten umringen ihre Handgelenke. Ein schwerer roter Vorhang fällt hinter ihr rechts herab, zur Seite gezogen, um den Blick dahinter freizugeben. Die Terrasse ist mit warmem Stein gepflastert und von einer geschnitzten Balustrade mit roten Blumenurnen eingefasst, zwei helle Marmorsäulen rahmen die Aussicht. Jenseits eines breiten Tals erhebt sich die Hagia Sophia, die breite Mittelkuppel flankiert von einer niedrigeren Halbkuppel, ihre Wände goldbraun im Sonnenlicht, dahinter verblassen niedrige Hügel in einem klaren Himmel ins Blaue."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "Dido, Gründungskönigin von Karthago, steht nachts auf einer Palastterrasse. Hinter ihr ist der Himmel tiefblau und mit Sternen übersät; ein fernes Vorgebirge zeichnet sich schemenhaft am Horizont über einer niedrigen Brüstung ab. Eine geschwungene Steinbank steht hinter ihr, ihr Abschlussteil mit einem Rollenfries geschnitzt, und helle Säulen ragen dahinter auf. Die Terrasse flankierend tragen zwei große Sträucher in hellen Steinkübeln dunkle Blätter und kleine rote Blüten: Granatäpfel, deren lateinischer Name punicum sie als den Baum Karthagos kennzeichnet. Sie ist hellhäutig, ihr dunkles Haar in der Mitte gescheitelt und bis über die Schultern fallend, ein schlankes Golddiadem an der Stirn. Ihr Gewand ist ein helles, fast weißes Chiton, die griechische Tunika, an den Schultern genadelt und an der Taille gegürtet, ihr bodenlanger Rock mit einem zarten Webmuster besetzt. Kurze geschlitzte Ärmel sind in Abständen am Oberarm mit kleinen Spangen befestigt, und eine breite Schärpe in tiefem Blau umschlingt ihre Taille und hängt als langes Paneel an der Vorderseite des Rocks. An ihrer Kehle liegt ein breites Pektoral aus dunklen, in Gold gefassten Steinen, und ein schmales Goldarmband umzieht ein Handgelenk. Ihre Hände ruhen an den Seiten, der Stein um sie herum kühl im Nachtlicht."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "Boudicca, Königin der Icener, steht auf der grasigen Anhöhe einer Bergfestung. Links befindet sich eine Steinmauer, auf der eine hölzerne Palisade aus zugespitzten Pfählen sitzt, über die das kegelförmige Strohdach eines Rundhauses herausragt; rechts fällt eine Kette grüner Hügel unter einem schweren grauen Himmel ab. Ihr Haar ist kurz geschnitten und leuchtendes Kupferrot; ein helles Tuchstück ist im Nacken gebunden und hängt hinter ihrer Schulter herab. Ein kleiner dunkelblauer Fleck sitzt auf ihrem Wangenknochen unter einem Auge, Waid, wie ihn die alten Britannier als Körperbemalung verwendeten. Ein keltischer Torques, gedrehtes Gold und steif, umzieht ihren Hals. Ihr Kleid ist eine ärmelloser knielanges Gewand in einem blau-grünen Karomuster, an der Taille durch einen Ledergürtel mit runder Schnalle gestrafft. Lederne Unterarmschienen sind über ihren Handgelenken geschnürt, eine passende Schutzmanschette um den Oberarm gestritten, die Waden über niedrigen Lederstiefeln nackt. In ihrer linken Hand hält sie ein gerades zweischneidiges La-Tène-Kurzschwert, die Klinge zu einer Spitze verjüngt und das Heft klein und schlicht; ihre rechte Hand umgreift den aufrechten Schaft eines Speers, der mit dem Schaftende in den Rasen gestoßen ist. Zu ihrer Linken steht ein leichter zweirädriger Streitwagen, sein einzelnes Speichenrad mit einem Eisenreifen beschlagen, ein Bündel langer Speere schräg aus dem Wagenkasten ragend."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "Wu Zetian, Huangdi der Tang, steht in der Mitte eines dämmrigen Saales zwischen schweren roten Vorhängen, die zu beiden Seiten zurückgezogen sind. Hinter ihr hängt eine Reihe warmer goldener Laternen in der Dunkelheit, die dunkle Wand dahinter mit Paneelen aus geschnitztem Gitterwerk besetzt. Ihr schwarzes Haar ist zusammengerafft und hoch auf dem Kopf aufgetürmt, vorne mit einem Buyao befestigt, einem Gold- und Perlenschmuck. Sie trägt ein Ruqun in mehreren Lagen. Ein inneres Gewand aus blassem Goldseide kreuzt sich an der Brust über einem steifen Goldpaneel, das mit einem Medaillon bestickt ist; eine lebhafte rote Schärpe, hoch unter der Brust gebunden, fällt als langer Rock bis zum Boden. Darüber trägt sie ein äußeres Gewand aus tiefrote Seide mit goldenen Medaillons, die breiten Ärmel über ihre Hände hängend und der schleppende Saum auf dem Boden um ihre Füße gebreitet. Sie hält ein kleines goldenes Gefäß mit beiden Händen an der Taille, leicht angehoben, als würde es dargeboten. Ihre Haut ist blass, ihr Ausdruck gefasst, ihr Blick ruhig. Rote Vorhänge, rotes Gewand und goldene Laternen erwärmen den Rahmen gegen das Dunkel des Saales."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "Harald 'Blauzahn' Gormsson, König der Dänen und Norwegens, steht mittschiffs auf dem offenen Deck eines Langschiffs. Er ist breit und kräftig gebaut; sein Bart ist rötlich blond und teilt sich in zwei geflochtene Strähnen, die ihm bis über den Kragen fallen, der Schnurrbart lang und herabhängend. Sein Kopf ist unbedeckt, das Haar zu einem Knoten hochgebunden. Ein Mantel aus langem rotbraunem Fell liegt über seinen Schultern. Darunter trägt er eine graugrüne Tunika mit dunklerem Schulterfeld, deren Saum und Ärmelenden mit gearbeiteten Bändern nordischen Flechtmusters besetzt sind. Ein breiter Gürtel aus bearbeitetem Leder spannt sich um seine Taille, mit einer schweren quadratischen Schnalle geschlossen, und ein zweiter Riemen läuft diagonal über seine Brust; beide Hände ruhen vorn auf dem Gürtel. Sein Helm liegt auf dem Deck neben seinen Füßen, ein Dom aus dunklem Eisen mit verstärkendem Stirn- und Nasenband, die Seiten zu gerundeten Klappen aus dickem rotbraunem Fell ausgestellt. Zu seiner Linken schwingt sich der Stevenpfosten des Schiffs hoch und nach innen in einer hohen hölzernen Spirale, die einem Drachenkopf nachgebildet ist. Hinter seiner rechten Schulter laufen Tauwerk-Leinen an einem Mast herab, und darüber hängt ein Segel in breiten senkrechten Streifen aus Rot und Weiß. Entlang der Reling ist ein runder Holzschild mit dem Gesicht nach außen befestigt, der eiserne Buckel in der Mitte. Der Himmel darüber ist weit und blau, von hohen Wolkenbändern durchzogen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "Ramesses II., Pharao der Beiden Länder, sitzt auf einem Thron an der Spitze einer kurzen Stufenfolge, während sich zu beiden Seiten eine Halle hoher blau bemalter Säulen öffnet. Sein Gesicht ist jung und glatt rasiert, die Haut tief bronzefarben, die Augen mit dunklem Kohl umrandet. Sein Kopfputz ist ein nemes, ein gestreiftes gold-blaues Kopftuch, das an den Schläfen eng anliegt und in gefältelten Lappen bis auf die Brust fällt. An seiner Stirn erhebt sich der Uräus, eine aufgerichtete Kobra als Zeichen des Königtums. Über Schultern und Brust liegt ein wesekh, ein breiter Kragen aus gestapelten Perlreihen in Gold und Lapislazuli-Blau. Er trägt einen shendyt, einen pharaonischen Faltenrock aus langem weißem Leinen, der an der Taille von einer breiten Schärpe aus Gold und Blau gehalten wird, die vorn in einem steifen gemusterten Streifen herabfällt. Seine sandalbeschuhten Füße ruhen auf der obersten Stufe. In der Linken hält er einen hohen Stab an die Schulter gelehnt; die Rechte ruht auf der Armlehne des Throns. Die ihn flankierenden Säulen sind in Registern aus Blau, Gold und Rot bemalt, ihre Kapitelle als Papyrusbündel geformt und mit Reihen von Hieroglyphen und stehenden Figuren beschnitzt. Vor dem Thron stehen zu beiden Seiten zwei große goldene Statuen von Isis und Nephthys, den schützenden Göttinnen, ihre Flügel ausgebreitet und nach vorn geschwungen, die Federn als lange vergoldete Blätter gearbeitet. Palmwedel neigen sich von beiden Seiten herein, und die gelben Steinstufen zu seinen Füßen sind mit Reihen kleiner dreieckiger Motive eingetieft. Die gesamte Halle liegt in warmem Gold getaucht, das Blau der Säulen und des Kragens der einzige kühle Ton darin."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "Elisabeth I., von Gottes Gnaden Königin von England, Frankreich und Irland, Verteidigerin des Glaubens, sitzt auf einem hohen geschnitzten Thron, flankiert von zwei Kandelabern auf steinernen Sockeln, deren Kerzen unangezündet sind. Hinter ihr erhebt sich ein Baldachin aus schwerstem rotem Samt, der von quastenbehangenen Goldschnüren in tiefen Falten zurückgezogen ist; die Dunkelheit des dahinterliegenden Gemachs ist kaum sichtbar. Ihr Haar ist hoch aufgesteckt in engen Locken aus rötlichem Blond, von einem kleinen juwelenbesetzten Krönchen gehalten; ihr Kragen ist die steife offene Halskrause des späten Tudor-Hofes. Ihr Gewand ist goldener Brokat, schwarz bestickt, das Mieder eng geschnitten und mit Edelsteinen besetzt, die Ärmel an der Schulter gebauscht und zu Spitzenbündchen verjüngt, der Rock weit über einem Reifrock ausgestellt. Lange Perlenschnüre kreuzen ihre Brust und hängen von der Taille herab, in ihrer Zeit als Zeichen der Jungfräulichkeit getragen. Ihre bleichen Hände ruhen auf den Armlehnen des Throns."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "Haile Selassie I., Kaiser von Äthiopien, Auserwählter Gottes, Siegreicher Löwe aus dem Stamm Juda, steht in einem langen Empfangssaal seines Palastes, eine helle Kassettendecke über ihm, hohe Fenster zu seiner Rechten, ein Kristallleuchter zwischen ihnen hängend. Er ist schlank und aufrecht, dunkelbartig, das Haar kurz geschoren. Er trägt eine dunkle Militärtunika, bis zum Hals geknöpft, schlichte dunkle Hosen und einen breiten schwarzen Ledergürtel. Von seiner rechten Schulter bis zur linken Hüfte verläuft eine breite Schärpe aus smaragdgrünem Moire, das Band des Ordens vom Siegel Salomos. Vier Reihen kleiner Bandschnallen drängen sich hoch auf seiner linken Brust, Feldzugs- und Ehrendekorationen, die sich über seine Regentschaft angesammelt haben. Darunter hängen zwei große Bruststerne höchster kaiserlicher Orden, achtspitzig und in Gold und Email gearbeitet. Seine linke Hand ruht an der Seite, die rechte hält ein Paar Handschuhe. Zu seiner Linken steht der kaiserliche Thron: ein hochlehniger Stuhl, bezogen in hellem Creme und Blau, dessen Bekrönung zu einer geschwungenen Krone geschnitzt und mit einem bestickten Tuch behangen ist, aufgestellt auf einem rot gemusterten Teppich, der die Länge des Saals durchläuft. Helle gepolsterte Stühle säumen die Wände hinter ihm und verlieren sich in den Raum hinein."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "Napoleon Bonaparte, Kaiser der Franzosen, sitzt rittlings auf einem blassgrauen Pferd auf einem dämmerlichen Feld aus trockenem Gras, hinter ihm ein rötlich-brauner Himmel und kahle Bäume. Er trägt einen dunkelblau en Mantel mit schweren goldenen Epauletten, eine weiße Weste, weiße Reithosen und hohe schwarze Reitstiefel. Sein Zweispitz ist quer aufgesetzt, die beiden Spitzen zu den Schultern hin gewandt, in jener Ausrichtung, die er bevorzugte, um sich von seinen Offizieren abzuheben. Das Zaumzeug des Pferdes ist rotes, mit Vergoldungen beschlagenes Leder; die darunter liegende Schabracke ist in Rot und Gold eingefasst. Die Komposition erinnert an Jacques-Louis Davids Napoleon beim Überqueren der Alpen, doch ist sie zum Stillstand gebracht: kein aufsteigendes Streitross, keine weisende Hand, nur eine Gestalt allein in der Landschaft im Zwielicht."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "Otto von Bismarck, Ministerpräsident von Preußen und erster Kanzler des Deutschen Reiches, steht in einem hohen Staatssaal, der von Tageslicht durchflutet wird, das durch Bleiglasfenster hinter ihm fällt, jede Scheibe durch schmale Sprossen in kleine Quadrate gegliedert. Schwere karmesinrote Vorhänge sind an jedem Fenster in tiefen Falten gebauscht und zurückgebunden, ihr Innenfutter von dunklerem Rot. Der Boden ist spiegelblank poliert und fängt das Fensterlicht in langen blassen Bahnen. Zu seiner Linken trägt ein kleiner Beistelltisch eine weiße Kugellampe. Er ist groß und breitschultrig, oben kahl mit einem kurzen Saum silbergrauen Haares an Seiten und Hinterkopf, und trägt einen schweren weißen Schnurrbart, lang und an den Spitzen nach außen geschwungen. Sein Mantel ist ein dunkel zweirehiger Militärrock in tiefem Schieferblau, über der Brust durch zwei parallele Reihen goldener Knöpfe geschlossen, der Stehkragen in Gold eingefasst, die Schultern mit schweren goldenen Bullionepauletten beschwert, deren Franse bis zum Oberarm reicht. Knapp unterhalb des Kragens hängt ein kleines helles Kreuz an einem dunklen Band, der Pour le Mérite, Preußens höchster militärischer Verdienstorden. Er steht dem Betrachter in Dreiviertelperspektive zugewandt, aufrecht und reglos, den Blick über die Schulter des Betrachters hinaus gerichtet."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "Alexander der Große, König von Makedonien und Hegemon der Hellenen, sitzt rittlings auf seinem rabenschwarzen Hengst Bukephalos und hält ihn auf einer grünen Hochlandwiese in Zaum, mit Reihen grauer Berge zu beiden Seiten und einem einzelnen schneebedeckten Gipfel, der sich rechts erhebt. Er ist jung und glatt rasiert, sein braunes Haar in der Mitte gescheitelt und von der Stirn in einer Anastole aufgebauscht, jenem angehobenen Stirnlockenschopf, der zu einem Erkennungszeichen seiner Porträts wurde. Er trägt einen Linothorax, hellenistische Körperrüstung aus Schichten von Leinen und Leder, mit vergoldeten Platten verkleidet, deren Schulterjochen durch kurze Schnüre auf der Brust festgebunden sind. In der Mitte der Brust trägt eine quadratische vergoldete Platte ein Gorgoneion, den Kopf der Medusa in Relief. Von den Schultern und vom gegürteten Hüftbereich hängen Pteryges herab, Reihen versteifter Lederstreifen zum Schutz der Oberarme und Oberschenkel, jeder Streifen rot eingefasst und mit einer goldenen Niete abgeschlossen. Seine Arme sind nackt, ein breites Goldband am rechten Handgelenk; er trägt keinen Helm und führt keine sichtbare Waffe. Das Zaumzeug des Pferdes ist dunkles, mit Rot gearbeitetes Leder, Stirn- und Backenriemen mit Nieten beschlagen, ein einzelner Zügel in seiner linken Hand über den Hals gezogen. Unter dem Sattel drapiert ein gesprenkeltes Leopardenfell die Flanke des Pferdes, die Pfoten noch daran."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "Attila, König der Hunnen, sitzt auf einem hochlehnigen Holzthron auf einem erhöhten Podest, die Halle um ihn herum in tiefem Rot und Gold erleuchtet. Er lehnt entspannt zurück, ein Bein über das andere geschlagen, ein blankes Schwert über seinen Schoß gelegt; eine Hand ruht auf der Klinge, die andere hält einen Becher. Seine Tunika ist rot und langärmelig, mit Gold eingefasst, über dunkelblauen Hosen getragen, die in hohe weiche Lederstiefel gesteckt sind, an den Stulpen mit Fell besetzt. Eine kegelförmige Mütze aus dunklem Fell mit einem goldenen Band sitzt auf seinem Kopf. Er ist bärtig und trägt einen langen Schnurrbart, sein Gesicht von rechts halb beleuchtet. Die Armlehnen des Throns enden in geschnitzten Löwenköpfen, und ein schweres Fell ist über die Rückenlehne geworfen. Hinter ihm ist eine Wand roter Vorhänge von Tafeln flankiert, die mit runden Bronzescheiben in abgestufter Größe behangen sind, in denen das Feuerlicht aufblitzt. Rechts vom Podest brennt ein hoher eiserner Kerzenständer mit einer einzelnen Kerze. Dahinter auf dem Boden streckt eine große Messingschale einem die Griffe aufrecht stehender Schwerter entgegen. Weiter hinten schüttet eine offene Holztruhe Münzen über einen gemusterten Teppich."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "Pachacuti Inca Yupanqui, Sapa Inca von Tahuantinsuyu, sitzt auf einem hohen Steinthron auf einer Terrasse über Machu Picchu; der Thron ist mit Reihen ineinandergreifender geometrischer Motive geschnitzt, die in Gold und Rot herausgearbeitet sind. Über ihm zu seiner Rechten zeigt eine große goldene Sonnenscheibe, an einem Steinpfeiler befestigt, ein stilisiertes menschliches Gesicht in ihrer Mitte, umgeben von einem Kranz nach außen strahlender Zacken. Kahle Gipfel steigen steil zu seiner Linken auf, und niedrige strohgedeckte Bauten sind auf gestuften Anbauterrassen darunter angelegt. Er trägt eine mascapaycha, eine rote Wollfranse, die als Zeichen der Inca-Souveränität über die Stirn fällt, gehalten von einem llauto, einem mehrfarbigen Stirnband, und gekrönt von einem Fächer aufrecht stehender roter und dunkler Federn. Sein Haar ist schwarz und schulterlang. Um seinen Hals hängt ein schweres goldenes Brustscheibenornament. Seine Tunika ist ein ärmelloses knielanges Gewand in einem kräftigen schwarz-weißen Schachbrettmuster mit einem rot-goldenen Schulterfeld auf der Brust. Unterhalb der Knie sind seine Beine mit roten Fransenkordelschnüren gebunden. In der rechten Hand hält er einen hohen Stab, der von einer goldenen Vogelfigur bekrönt wird; der Schaft ist mit gestaffelten roten Quasten behangen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "Mohandas Karamchand Gandhi, Mahatma, Anführer der indischen Unabhängigkeitsbewegung, steht an einer indischen Küste aus trockenem gelbem Gras, felsigem Vorgebirge und blassem Meer. Er ist mager, kahl, trägt eine Brille und einen kurz gestutzten grauen Schnurrbart. Er trägt die Kleidung seines späteren Lebens: ein schlichtes weißes Dhoti um die Hüften gewickelt, einen Schal über eine Schulter und unter dem gegenüberliegenden Arm drapiert, die Brust nackt. Der Stoff ist ungefärbt und handgesponnen, eine bewusste Absage an britisches Tuch, die zum Sinnbild seiner Bewegung wurde. Der Ort erinnert an die langen Märsche, die er im Kampf um die Unabhängigkeit auf das Meer zu unternahm, eine einsame Gestalt am Rand des Subkontinents."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "Gajah Mada, Mahapatih des Majapahit-Reiches auf Java, steht am Rand eines überschwemmten Reisfeldes, das Wasser spiegelblank zwischen niedrigen grünen Dämmen. Hinter ihm erklimmt dichter Tropenwald einen in blassem Dunst gehüllten Hügelhang, und aus diesem Dunst erhebt sich die schlanke gestufte Silhouette eines candi, eines rotgeziegelten Tempelturms, dessen abgestufte Dachkrone sich in den Wolken auflöst. Er ist breitschultrig und nackter Oberkörper, das dunkle Haar zu einem Knoten hochgebunden, ein kleiner Bartbüschel am Kinn. Goldbänder umschließen jeden Oberarm und jedes Handgelenk. Ein breiter Gürtel sitzt hoch an seiner Taille, mit einer großen, im Majapahit-Blumenstil gearbeiteten Goldschnalle mit Muschelrand geschlossen. Unterhalb des Gürtels ist ein roter Sarong vorn gewickelt und geknotet, die Falten fallen in schweren Bahnen über ein gelbes Untergewand, das am Saum sichtbar wird. An seiner rechten Hüfte hängt, an einer durch den Gürtel gefädelten Schnur, ein gescheideter Kris, dessen dunkle Holzscheide sich zu einer schmalen Spitze verjüngt, der Griff in schräger Haltung nach vorn ragend."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "Hiawatha, Gründer der Haudenosaunee-Konföderation, steht in einer sonnendurchfluteten Lichtung; ein großer grauer Felsblock ragt an seiner Schulter auf, und schlanke Buchen- und Birkenstämme verlieren sich im grünen Unterholz hinter ihm. Er ist oberkörperfrei und schlank, seine Haut warm-braun im gefleckten Licht. Sein Haar ist als Scalplock frisiert: Die Seiten des Kopfes sind kurz geschoren, und ein schmaler Kamm dunklen Haars verläuft von vorn nach hinten über den Scheitel, an dessen Ende zwei aufrechte Federn befestigt sind. Bänder dunkler Farbe umringeln jeden Oberarm. Ein eng anliegender Halsreif aus weißen Muschelperlen, ein Wampum, sitzt an seiner Kehle, und ein einzelner Riemen kreuzt seine Brust von der rechten Schulter zur linken Hüfte und trägt einen Köcher, dessen befiederte Pfeilenden über seine Schulter ragen. An seiner Hüfte fällt ein Schurz aus hellem gelblich-braunem Hirschleder als langer Vorderlappen bis zur Oberschenkelmitte herab. Gefranste Hirschleder-Gamaschen umhüllen seine Wadenbeine vom Knöchel bis zum Knie, sind unterhalb des Knies gebunden und am Oberschenkel offen gelassen, wo der Schurz ihn bedeckt. Er steht barfuß auf dem festgetretenen Boden der Lichtung, die Arme an den Seiten, während das Waldlicht seine rechte Seite streift."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "Oda Nobunaga, Daimyo des Oda-Clans und erster der großen Einiger, steht in einem hügeligen grünen Land aus hohem Gras und verstreuten weißen Steinen; eine Reihe blauer Berge verliert sich unter einem hellen, wolkentürmenden Himmel am Horizont. Sein Haupt ist nach der sakayaki-Art über den Scheitel geschoren - Stirn und Oberkopf rasiert, damit ein Helm kühl und fest sitze -, das verbliebene Haar nach hinten zusammengefasst. Er trägt einen schmal gehaltenen Schnurrbart und einen kurzen Kinnbart. Seine Rüstung ist tosei gusoku, eine moderne Rüstung der Sengoku-Ära: lackierte Eisenplatten, in waagerechten Reihen durch Seidenschnüre verbunden, Brustpanzer und Rockplatten in abwechselnden Bändern von Dunkelblau und Zinnoberrot gefasst. Die Schulterplatten hängen in denselben geschnürten Platten über jedem Arm. Darüber trägt er einen ärmellosen, gelblich-braunen Kampfmantel, dessen Vorderbahnen offen stehen und den geschnürten Brustpanzer darunter zeigen. Eine breite rote Schärpe ist an seiner Hüfte geknüpft, ein Schwert mit der Schneide nach oben durch sie gesteckt; an seiner rechten Seite hängt ein zweites Schwert, dessen Heft seine rechte Hand umfasst. Zusammen bilden sie das daisho, das Paar aus langem und kurzem Schwert, das jeder Samurai trägt. Hinter seiner rechten Schulter auftauchend und quer über seinen Rücken gelegt ragt der lange dunkle Schaft und der schlanke Lauf eines tanegashima, jener Luntenschlossflinte, deren massenhafte Einführung Nobunaga in Erinnerung geblieben ist. Er steht allein im offenen Land, nur das Gras, die Steine und die fernen Berge um sich."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "Sejong der Große, vierter König der Joseon-Dynastie, sitzt mittig auf einem erhöhten hölzernen Podest im Thronsaal, ein aufgeschlagenes Buch mit beiden Händen in seinem Schoß haltend. Er trägt ein gonryongpo, eine rote Seidenroben der Joseon-Könige, deren Brust und Schultern mit goldenen Medaillons vierklauiger Drachen bestickt und mit goldenem Rankenschmuck eingefasst sind. Ein breiter, mit Jade besetzter Gürtel umschließt seine Hüfte. Auf dem Kopf trägt er ein ikseongwan, eine steife schwarze Gazekopfbedeckung mit zwei kleinen nach oben gebogenen Flügeln, die wie gefaltete Blätter vom Hinterkopf aufragen. Er ist glattrasiert, bis auf einen sorgfältig gestutzten dunklen Schnurrbart und einen kurzen Kinnbart. Hinter ihm erhebt sich das Irworobongdo, der Faltschirm mit Sonne, Mond und fünf Gipfeln, der hinter jedem Joseon-Thron stand, wobei der König der Sonne und die Königin dem Mond entsprach: eine weiße Mondscheibe oben links, eine rote Sonnenscheibe oben rechts, gezackte Gipfel in sattem Grün und dunkelrote Kiefern, die sich entlang des unteren Registers ausbreiten. Der Thron selbst ist rot lackiert, seine Seitenplatten mit Tigermédaillons geschnitzt. Rot lackierte Balustraden und Pfosten rahmen das Podest zu beiden Seiten; Papierlaternen hängen an den Rändern des Saals und leuchten gelb; eine kurze Steintreppe führt zum Betrachter hin herab."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "K'inich Janaab' Pacal, K'uhul Ajaw von Bʼaakal, der Heilige Herr von Palenque, steht zur Mittagszeit auf der Terrasse eines Kalksteinpalastes oberhalb seiner Hauptstadt; gestufte Pyramidentempel erheben sich aus dem Dschungel dahinter, ihre Dachkämme gemeißelt und von der Witterung zu einem blassen Rosa ausgebleicht. Hinter seinen Schultern entfaltet sich ein mächtiger Rückenaufsatz, ein hölzernes Gestell, das mit langen Quetzal-Schwanzfedern in Bändern aus Grün, Blau und tiefem Rot gefächert ist und über einer rechteckigen Platte aus gemeißelten und bemalten Glyphen sitzt. Sein Kopfschmuck ist hoch und abgestuft, von weiteren Quetzal-Federn bekrönt. Sein Haar fällt lang und dunkel bis auf die Schulter. Ein breiter Kragen aus geschnitzten Jadeplaketten liegt über seiner Brust, ein quadrektaler Jade-Brustschmuck hängt in seiner Mitte, und Jade-Ohrflares durchstechen seine Ohrläppchen. Ein Perlengürtel fasst einen Schurz aus geknotetem Tuch und Federn an der Hüfte; kniehohe Fransen aus langen Federn hängen zu beiden Seiten, und seine Sandalen sind hoch am Wadenbein geschnallt. In seiner linken Hand hält er das Manikin-Zepter des K'awiil, einen hohen Stab, der mit einem kleinen gemeißelten Kopf der Blitzgottheit gekrönt ist, deren Abbild Maya-Herrscher als Herrschaftssymbol trugen. Zu seiner Linken, am Rand der Terrasse, steht ein breites steinernes Kohlenbecken, dessen Rand von den Stümpfen verbrannter Opfergaben umringt ist. Die Stadt dahinter verliert sich im Dunst, Pyramide um Pyramide staffelt sich zur Flussebene hin hinab."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "Dschingis Khan, Großkhan der Mongolen, sitzt zu Pferde auf einem schwarzen Hengst in der offenen Steppe, von der Taille aufwärts gezeigt und drei Viertel zum Betrachter gewandt. Sein Helm ist hoch und kegelförmig, läuft in eine scharfe Spitze aus, und sein dunkles Stirnband sowie die Wangenlappen rahmen einen schmalen Schnurrbart und ein kleines Bartbüschel am Kinn. Seine Rüstung ist genietetés mongolisches Kavalleriegeschirr; die Brust wird von einem großen runden Bronzebuckel mit eingestanztem Spiralmuster beherrscht, breite Schulterplatten sitzen über den Schultern, und genietete Bänder umschließen die Oberarme. Ein dunkler Mantel fällt von seinen Schultern, sein Futter gedämpft lila, wo er hinter dem Sattel herabfließt. Das Zaumzeug des Pferdes ist schlichtes Leder, ein einfaches Zaumgestell mit nichts als Stirnband und nach vorn gezogenen Zügeln. Hinter ihm wogen niedrige grüne Hügel unter einem bleichen bedeckten Himmel; am Mittelhang steht ein Lager aus Gers, den runden weißen Filzelten der Mongolen, um die herum blasse Flecken von Vieh auf dem Gras verteilt sind."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "Ahmad al-Mansur, saadischer Sultan von Marokko, steht am Rand eines Saharalagers unter einem tief blauen Himmel. Eine schmale Mondsichel und vereinzelte Sterne hängen über niedrigen dunklen Höhenzügen am Horizont. Er ist bärtig, seine Haut warm im Lampenlicht, sein Blick ruhig und dem Betrachter zugewandt. Er trägt die geschichtete Kleidung des Maghreb: eine lange weiße Djellaba, ein knöchellanges Kapuzengewand Nordafrikas. Darüber liegt ein Selham, ein feiner Wollmantel der Fürsten und Herrscher, dessen Kapuze zwischen seinen Schulterblättern nach hinten zurückfällt. Ein weißer Turban ist um seinen Kopf gewunden. An seiner Brust hängt ein rechteckiges besticktes Paneel in Creme und Gold, gemustert in der verschlungenen Geometrie islamischen Ornaments. Eine breite Schärpe aus senkrechten roten und cremefarbenen Streifen ist zweimal um seine Hüfte gewickelt und vorn geknüpft, die Enden darunter eingesteckt. Hinter ihm und zu seiner Linken leuchtet ein großes, gewölbtes Karawanenzelt aus dunkel gestreiftem Tuch von innen heraus, sein offener Eingang wirft warmes orangefarbenes Licht auf den Sand; zwei Kamele ruhen daneben auf dem Sand. Ein kleineres Licht brennt weiter entfernt, und eine Gruppe Dattelpalmen hebt sich gegen die Hügel ab."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "Wilhelm I., Prinz von Oranien, Vater der niederländischen Unabhängigkeit, steht in einem gekachelten Gemach, das von einem hohen Bleiglasfenster links beleuchtet wird, dessen kleine rautenförmige Scheiben von schweren roten Vorhängen eingefasst sind, die zur Seite zurückgezogen sind. Der Boden ist in schwarzen und weißen Marmorquadraten verlegt. Hinter ihm hängt an der gegenüberliegenden Wand ein vergoldet gerahmtes Landschaftsgemälde der Niederungen unter schwerem Himmel, ein Fluss windet sich durch flache grüne Felder auf eine ferne Stadt zu. Zu seiner Rechten trägt ein hölzerner Schemel einen Erdglobus, dessen Messingmeridianring das Fensterlicht auffängt. Zu seiner Linken hält ein mit rotem Tuch bedeckter Schreibtisch ein aufgeschlagenes ledergebundenes Buch und lose Blätter, und dahinter steht ein hochlehniger, blau gepolsterter Stuhl. Das gesamte Interieur erinnert an die Gelehrtenstuben von Vermeers Geograph und Astronom, obwohl Wilhelm einer Generation vor diesem Stil angehört. Er ist ein bärtiger Mann mittleren Alters, dunkles Haar kurz geschnitten unter einer kleinen flachen Kappe, Schnurrbart und gespaltener Bart eng gestutzt, eine breite weiße gefältelte Halskrause tritt an seiner Kehle vor. Über seinen Schultern hängt ein langer schwarzer Mantel, rechts zurückgeschlagen, um seine Arme freizulassen. Sein Wams ist mattgoldene gemusterte Seide, eng an den Torso geschnitten, die Front in einer einzigen Reihe geknöpft. Seine Hose ist gepanzerte Kniehose, aus langen senkrechten Streifen aus rotem und weißem Stoff gefertigt, in abwechselnden Streifen über einem volleren Futter angeordnet und bis zur Oberschenkelmitte reichend. Schlichtes dunkles Strumpfzeug bedeckt die Unterschenkel und trifft auf niedrige Lederschuhe auf dem Schachbrettboden. In seiner rechten Hand hält er einen Amtsstab auf Brusthöhe erhoben; seine linke Hand ruht nahe der Hüfte, wo ein Schwertgriff knapp unter dem Fallen des Mantels sichtbar ist."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "Süleyman der Prächtige, Kanuni der Gesetzgeber, Sultan der Osmanen, steht im Topkapi-Palast unter einer gerippten Kuppel, in einem Saal spitzer Bögen, die mit blau-weißen Iznik-Kacheln verkleidet sind. Tageslichtbündel fallen von unsichtbaren Fenstern auf die blassen Steinsäulen hinter ihm. Er ist bärtig, dunkläugig, Schnurrbart und Bart eng gestutzt um einen schmalen Mund. Sein Turban ist der hohe, runde kavuk, für den er bekannt war - ein gewaltiger Wickel weißen Tuchs um ein kegelförmiges Gestell gebunden und weit über seine Stirn aufragend. An seiner Spitze erhebt sich ein sorguç, eine grüne Feder, die den Rang des Sultans kennzeichnet. Über einem inneren Gewand trägt er einen langen Kaftan aus gelbem Seidengewebe mit einem blassen Muster aus Ranken und Rosetten, die Front bis zur Hüfte geöffnet. Ein breites Band weichen grauen Pelzes säumt ihn in voller Länge und weist ihn als kapanice aus, den höchsten Ehrenmantel. Eine dunkle Schärpe kreuzt den Kaftan an der Hüfte. In seiner rechten Hand, aufrecht gegen seine Brust gehalten, liegt ein in dunkles Leder gebundenes Buch. Seine andere Hand ruht an seiner Seite. Der Saal hinter ihm verliert sich im Schatten zwischen den gekachelten Bögen."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "Darius I., der Große, König der Könige des Achämenidenreiches, steht am oberen Ende einer niedrigen Treppe am Kopf eines großen Saales, ein Lichtstrahl fällt von oben auf ihn herab. Er ist breitschultrig und vollbärtig, der Bart lang, stumpf geschnitten und eng gelockt. Auf seinem Haupt sitzt die kidaris, die hohe zinnenbekrönte Krone der persischen Könige, ein goldener Zylinder, der mit quadratischen Zinnen geringelt ist. Sein Gewand ist ein langes safrangelbes Kleid, das bis zu seinen Füßen fällt, an Brust, Manschetten und Saum mit roter und goldener Stickerei gebändert. Eine rote Schärpe fasst es an der Hüfte. Schwere goldene Armreifen umschließen jeden Bizeps. Zu beiden Seiten flankieren ihn auf Sockeln zwei kolossale Lamassu, geflügelte Stiere, deren Körper und gefaltete Flügel mit Gold bedeckt sind - die Wächterfiguren des Tores aller Nationen in Persepolis, hier in der Fassung mit Menschenhaupt auf den Stier allein zurückgeführt. Die Rückwand ist in flachem Relief mit einem Zug von Gestalten in langen Gewändern und weichen Kappen gemeißelt, nach den Tributträger-Reliefs der Apadana-Treppe. Der Stein des Podests und der Stufen ist ein blasses Blaugrün, an den Ecken mit goldenen Buckelknöpfen hervorgehoben."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "Kasimir III. der Große, König von Polen und letzter der Piasten-Könige, steht im Eingang eines steinernen Torhauses, beleuchtet von eisernen Wandleuchtern, deren Flammen ein warmes rotgoldenes Licht über das Mauerwerk werfen. Er ist breitschultrig und vollbärtig, der Bart dunkel und eng gestutzt, sein Blick ruhig. Seine Krone ist ein goldenes gewölbtes Reif mit roten Steinen besetzt, dessen Bögen sich oben in einem juwelenbesetzten Abschluss schließen. Um seine Schultern liegt ein breites Tippet aus weißem Hermelin, das Fell mit kleinen schwarzen Schwanzspitzen verziert. Darunter ist sein Mantel eine lange Karmesinrobe, die an der Brust in einer Reihe kleiner goldener Knöpfe zugeknöpft und an der Hüfte mit einem breiten vergoldeten Gürtel gefasst ist. In einer Hand hält er ein goldenes Zepter aufrecht vor seiner Brust; an seiner Hüfte hängt der Szczerbiec, das Piastenstaatsschwert. Zu beiden Seiten von ihm steigen schwere Eisenketten aus der oberen Dunkelheit entlang der Innenflächen des Torhauses herab. Hinter ihm, eingelassen in den Torbogen am hinteren Ende des Gemachs, trägt ein rotes Feld den gekrönten Weißen Adler Polens mit ausgebreiteten Flügeln. Der Adler ist in dunkler Silhouette auf dem roten Feld dargestellt statt in dem sonst üblichen Silber. Das Gestein ist massiv und eng gefügt, das Licht bündelt sich auf dem König und fällt zu beiden Seiten scharf in die beschatteten Gewölbe ab."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "Kamehameha der Große, Einiger der Hawaiianischen Inseln und erster Mo'i des Königreichs, steht barfuß auf einem weißen Sandstrand, hinter ihm die türkisfarbenen Untiefen einer geschützten Bucht und dahinter ein dunkler bewaldeter Bergrücken. Er ist groß und kräftig gebaut, oberkörperfrei, seine Haut tief braun in der Tropensonne. Über einer Schulter hängt ein ahu'ula, ein Federumhang hawaiianischer ali'i, tief rot und fast bis zu seinen Knöcheln reichend. Eine breite Schärpe desselben Rots kreuzt seine Brust von der linken Schulter, ihre gelben Ränder mit kleinen geometrischen roten Blöcken besetzt. Ein passendes Paneel aus Rot und Gelb hängt an der Vorderseite seines malo, eines an den Hüften gewickelten Lendentuchs. Auf seinem Kopf sitzt ein mahiole, ein flacher Kammhelm mit einem schmalen Kamm von vorn nach hinten, der von der Stirn bis zum Nacken aufsteigt, in Rot mit gelber Streifung gearbeitet und mit einem gelben Band an seiner Basis. In seiner rechten Hand hält er einen hohen Holzspeer mit widerhakiger Spitze; sein linker Arm hängt an seiner Seite. Zu seiner Rechten, auf den Sand gezogen, liegen zwei wa'a kaulua, polynesische doppelrümpfige Seefahrtskanus, deren Zwillingsrümpfe durch gezurrte Querhölzer verbunden sind. Die Segel sind dreieckig, die Spitze am Mastfuß und die obere Kante wölbt sich in einem langen U nach außen; das Tuch ist hell und geflickt. Ein drittes Kanu liegt weiter draußen in der Bucht vor Anker. Am Ufer hinter seiner linken Schulter steht ein strohgedecktes hale, ein hawaiianisches Haus aus Pfählen und einem Dach aus getrocknetem Gras, halb beschattet von den Wedeln der Kokospalmen. Der Himmel über dem Bergrücken ist blau mit hohen weißen Wolken."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "Maria I., Königin von Portugal, der Algarve und der portugiesischen Besitzungen jenseits des Meeres, steht auf der Terrasse des Palácio da Pena in Sintra, einer hellen Steingalerie unter einer Reihe schwerer romanischer Bögen. Der Atlantik öffnet sich jenseits ihrer Säulen. Ihr Kleid ist aus tiefblauer Seide. Das Mieder ist eng anliegend mit einer spitzen Taille, die ellbogenlangen Ärmel enden in weißen Manschetten, der weite Rock liegt über Reifröcken und fällt in breiten Falten bis auf den Stein. Ein kurzer roter Umhang ist an ihren Schultern befestigt und schleppt hinter ihr nach. Quer über ihre Brust verläuft eine breite weiße Schärpe mit rotem Rand, die Schärpe des portugiesischen Christusordens, die portugiesische Herrscher als Großmeister tragen. Vorn ist ein Band aus Juwelenverzierungen angebracht. Ihr dunkles Haar ist hoch aufgesteckt, über der Stirn aufgetürmt und mit einer Aigrette befestigt, einem kleinen schwarzen Schmuckstück, das mit einer aufrechten Feder versehen ist. Ihre rechte Hand ruht seitlich am Griff eines schlanken Zepters, dessen dunkler Schaft gegen das Blau ihres Rocks fällt. Zu ihrer Rechten, jenseits der Balustrade, zieht sich eine schmale Meeresbucht zwischen roten Klippen hindurch. Zwei rahgetakelte Naus mit gereften Segeln liegen im Kanal vor Anker. Zu ihrer Linken erhebt sich ein gelbwandiger Bergfried, der von einer bauchigen Kuppel aus vergoldeten und gekachelten Bändern bekrönt wird. Zinnenbesetzte gelbe Wälle führen stufenweise zur Terrasse hinab, auf der sie steht. Der Himmel ist klar, das Licht ist das eines hellen atlantischen Nachmittags, und die Bögen rahmen sie ein - auf der einen Seite Wasser, auf der anderen königliche Architektur."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "Augustus Caesar, der erste Kaiser Roms, sitzt auf einem kurulischen Stuhl zwischen zwei bronzenen Sphinxköpfen, deren glatte Gesichter nach außen gewandt sind. Er ist glattrasiert, mit kurzem dunklem Haar, das über die Stirn nach vorn gekämmt ist, dem Pony der Prima-Porta-Tradition. Eine Toga picta, eine purpurne Festtoga, die beim römischen Triumph getragen wurde, ist über seine weiße Tunika gewickelt und über den Schoß sowie die linke Schulter gezogen. Der Halsausschnitt der Tunika ist mit Gold eingefasst. Seine rechte Hand liegt offen auf einem der Sphinxköpfe; die linke ruht locker über seinem Knie. Hinter ihm ist ein schwach beleuchteter Saal mit dunkelroten Wänden, in dem kannelierte Säulen stehen und vertikale Banner in Rot und Gold hängen. An der Rückwand trägt ein rundes Bronzemedaillon einen Löwenkopf in Relief. Blasse Tageslichtstrahlen fallen von links über sein Gesicht und seine Brust und lassen die andere Seite des Saals im Schatten; zwei kleine Kohlenbecken auf eisernen Ständern zu beiden Seiten des Throns brennen niedrig."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "Katharina II., Kaiserin und Alleinherrscherin aller Reußen, steht im Lichtsaal, dem Großen Saal des Katharinenpalastes in Zarskoje Selo. Ihr Körper ist dem Betrachter zu drei Vierteln zugewandt, ihr Blick ist ruhig. Ihr dunkles Haar ist hochgesteckt und nach der europäischen Hofmode des späten 18. Jahrhunderts aufgetürmt. Ein kleines mit Juwelen besetztes Diadem hält es an der Spitze zusammen; seine Zacken erinnern im Kleinen an die hohen lilienförmigen Bögen der Großen Kaiserkrone Russlands. Ihr Kleid ist Hofgewand aus elfenbeinfarbener Seide: ein eng geschnittenes Mieder mit einem goldgestickten Mittelpanel vorn, bauschige halblange Ärmel in Dunkelblau, an der Schulter mit weißen Hermelin-Borten besetzt. Darunter breitet sich ein weiter Rock aus, in Gold mit dem Doppeladler des russischen Kaiserwappens als wiederholtem Motiv bestickt. Quer über ihren Körper, von der rechten Schulter bis zur linken Hüfte, verläuft eine breite hellblaue Moiré-Schärpe, das Band des Ordens des Heiligen Andreas des Erstberufenen. Hohe Bogenfenster entlang der rechten Wand sind mit hellblauen Vorhängen behangen, die in Schwingen zurückgezogen sind; Tageslichtstrahlen fallen in sichtbaren Balken auf einen schwarz-weißen Marmorboden, der spiegelblank poliert ist. An der linken Wand rahmt eine Reihe vergoldeter Rokoko-Schnitzereien aus Voluten und Blattwerk verspiegelte Paneele."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "Pocatello, Häuptling der Nordwest-Shoshone, sitzt auf einem Steinhaufen aus verwitterten roten Felsbrocken am Rand eines Gebirgsbeckens. Hinter ihm erstreckt sich eine flache Salbeisteppe bis zu niedrigen Tafelbergen, die sich gegen den Horizont unter einem Dämmerungshimmel aus Rosa und blassem Violett abzeichnen. Er ist breitschultrig, sein langes schwarzes Haar ist in der Mitte gescheitelt und fällt bis zur Brust; eine aufrechte Adlerfeder ist am Hinterkopf befestigt. Eine zweite dunkle Feder ragt hinter seiner Schulter aus dem Köcher hervor, der an seinem Rücken befestigt ist. Ein kurzer Holzbogen ist neben dem Köcher umgehängt, sein oberer Arm ragt über seine rechte Schulter. In seiner rechten Hand hält er einen langen Speer, der mit dem Schaft nach unten gegen den Fels gestemmt ist; der Schaft ist mit Leder umwickelt und trägt nahe der Spitze einen dunklen Büschel. Über dem Oberkörper trägt er eine Pelzweste, die von einem breiten Riemen aus gegerbtem Leder gekreuzt wird, der in Reihen von Perlstickerei gearbeitet ist und von der rechten Schulter zur linken Hüfte verläuft; an seinem unteren Ende hängt eine kurze Messerscheide. Seine Oberarme sind mit gestapelten Silberbändern umwickelt. Von der Hüfte abwärts trägt er dunkle, gefranste Ledergamaschen bis zum Knöchel und dazwischen ein Lendenschurz. Seine linke Hand liegt offen auf dem Oberschenkel; seine Haltung ist still, das Gewicht auf dem Stein gesammelt. Das Licht ist tief und warm, es fängt das Rot der Felsen und die Kante des Speers ein, und die Weite hinter ihm ist das Salbeiland des Great Basin, der Heimat der Shoshone zwischen den Rocky Mountains und der Sierra."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "Ramkhamhaeng der Große, König von Sukhothai, steht in einem sonnendurchfluteten Palastgarten. Das grüne Dunst eines tropischen Waldes und die blassen Silhouetten ferner Chedis, glockenförmiger buddhistischer Stupas Thailands, steigen hinter ihm durch einen niedrigen Nebel auf. Er ist schlank und nacktoberig, seine Haut ist warmbraun, sein Gesicht leicht zu seiner Linken gewandt mit einem feinen Lächeln. Seine Krone ist hoch, gestuft und spitz und läuft in eine schlanke Spire aus: eine Chada, die kegelförmige Krone der thailändischen Könige. Ein breites goldenes Brustgeschmeide liegt über seinen Schultern und seiner Brust, in rollenden Treibarbeiten gearbeitet und in der Mitte mit einem einzelnen roten Stein besetzt; schmalere Goldbänder umfassen jeden Oberarm. Eine weiße Seidenschärpe ist um seine Taille gewickelt und geknotet, die verdrehten Enden fallen auf seine Oberschenkel. Darunter trägt er ein Wickelgewand aus tiefem Rot mit Goldmuster, darunter ist eine dunklere Unterschicht am Saum sichtbar. Zu seiner Rechten, am Rand eines stillen Teichs, der mit rosa Lotusblüten und ihren breiten flachen Blättern bestreut ist, steht eine kleine Steinskulptur: ein heiterer Buddhakopf mit gesenkten Augen, auf einem Lotus-Knospen-Sockel. Ein blasser Sandweg schlängelt sich zu seiner Linken zwischen Büschen mit roten Blüten hindurch und führt zurück zu den im Nebel verhüllten Türmen der Hauptstadt."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "Mohammad I., Askia der Große von Songhai, steht bei Sonnenuntergang auf einem felsigen Steilhang mit einer langen Klinge auf der Schulter und einer brennenden Stadt im Rücken. Er ist dunkelhäutig, trägt einen kurzen Bart, sein Blick ist auf den Betrachter gerichtet. Sein Kopf ist in ein tagelmust gehüllt, einen cremefarbenen Sahelianischen Turban, der hoch aufgewickelt und an einer Seite zusammengefasst ist. Über seinen Schultern fällt ein langer purpurroter boubou, ein weitärmeliges Gewand des westafrikanischen Adels, dessen Vorderpanel und Brust in dichten, gemusterten Bändern aus Gold- und dunklem Faden bestickt sind. Darunter ist eine helle Schärpe um seine Taille gewickelt und so geknotet, dass die Enden locker an der Hüfte hängen, über Hosen in demselben Karmesin wie das Gewand. Er hält das Schwert mit der rechten Hand am Griff und lässt die Klinge an seiner Schulter zurückruhen; sie ist lang und geradlinig mit einer leichten Krümmung zur Spitze hin. Zu seiner Rechten fällt das Land zu einer Ebene unter einem rotorangefarbenen Himmel ab, ein dunkler Berg zeichnet sich gegen eine tief stehende Sonne ab. Zu seiner Linken brennt eine Stadt: Lehmziegelwände und ein hoher quadratischer Minarett, der mit Reihen herausragender hölzerner toron besetzt ist; Palmbalken ragen aus dem Putz. Flammen erklimmen den Turm und rollen durch die Straßen darunter; kleinere Feuer verstreuen sich über die Ebene zwischen der Stadt und dem Steilhang, auf dem er steht."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "Isabella I., Königin von Kastilien und León, Gemahlin des Königs von Aragonien, steht in einer der Säulengalerien der Alhambra in Granada, deren Arkaden auf einen Garten aus gestutzten Hecken und topfgepflanzten Formgehölzen öffnen, dahinter verschwimmen Hügel im Dunst. Schlanke Doppelsäulen mit gemeißelten Kapitellen erheben sich hinter ihr zu gelappten und gemuschten Bögen, die mit Maßwerk gefüllt sind; die Zwickel darüber sind in dichtem geometrischem und pflanzlichem Stuck in blassem Gold und Sandtönen geschnitzt. Sie ist zierlich und blass, ihre Hände übereinander an der Taille gefaltet. Ihr Kopf ist nach der kastilischen Mode ihres Hofes bedeckt: ein weißes Gebände, das eng unter dem Kinn und über die Kehle gelegt ist, ein weißer Schleier über dem Oberkopf und darüber eine kleine geschlossene Krone aus Gold, mit roten und grünen Steinen besetzt. Über ihren Schultern hängt ein langer roter Mantel, mit Gold gefüttert und eingefasst, der vorn offen fällt. Ihr Gewand darunter ist cremefarbener Brokat in einem dunklen, sich wiederholenden Muster, enganliegend bodiced, mit einem goldumrandeten Panel in der Mitte des Rocks. An ihrer Brust ist dort, wo der Mantel auseinandergeht, ein roter Edelstein befestigt. Das Licht ist das warme, flache Licht eines späten Nachmittags, das den Stuck der Arkade und den hellen Stein des Galerienbodens einfängt."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "Gustav Adolf, König der Schweden, Goten und Wenden, der Löwe des Nordens, steht in einem vergoldeten Palastsaal. Neben ihm brennt ein tiefer Kamin mit gespaltenen Holzscheiten, niedrig und hell. Er ist groß und kräftig gebaut, mit einem vollen rötlichen Bart bis zur Brust und einem dicken, aufgedrehten Schnurrbart; sein Haar ist von einer hohen Stirn zurückgestrichen. Er trägt einen geschwärzten Stahlkürass, an den Rändern und entlang des mittleren Grats mit vergoldeten Bändern getrieben, der über einem Kollett aus dickem, blassem, geöltem Ochsenleder sitzt. Die Rüstung setzt sich nach unten in gegliederte Stahlschoßplatten fort, die bis zur Mitte der Oberschenkel über einem gelben Unterrock ausgestellt sind. Eine breite Schärpe aus türkisfarbener Seide verläuft von seiner rechten Schulter zur linken Hüfte, geknüpft und in einer losen Falte gegen das Brustteil fallend. Kleine Spitzenbündchen zeigen sich an seinen Handgelenken, und eine Rüsche aus blasser Spitze säumt die Kniehosen über den Stiefeln. Er steht mit zurückgelehntem Gewicht, jede behandschuhte Hand ruht auf einem Feldstab, der mit der Spitze nach unten auf dem Boden vor ihm aufgesetzt ist. Hinter ihm ist die Kaminumrahmung geschnitzt und vergoldet, die Konsole mit barockem Akanthusblattwerk gebändert. Zur Linken hängen zwei vergoldet gerahmte Gemälde an einer Wand aus grünem und goldenem Damast. Das nähere zeigt einen bärtigen Mann in dunkler Rüstung, Erik XIV., einen früheren König von Schweden. Das weiter entfernte zeigt eine blasse Frau in einem hellen Hofgewand, Maria Eleonora von Brandenburg, Gustav Adolfs Gemahlin. Unter den Gemälden trägt ein polierter Tisch aus dunklem Holz eine flache Zinnsschale, die mit Früchten gehäuft ist, und ein hoher Messingkandelaber erhebt sich am nahen Ende des Tisches, seine Kerzen unangezündet. Der Raum wird fast ausschließlich vom Feuer beleuchtet. Der warme Orangeschein fällt über den Kürass, die vergoldeten Stuckverzierungen und die rechte Seite seines Gesichts und lässt die gegenüberliegende Wand im Schatten."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "Enrico Dandolo, Doge der Serenissima Republik Venedig, steht nachts auf einer steinernen Brücke über einem Kanal, eine behandschuhte Hand an die Brust gezogen. Er ist alt: ein langer grauer Bart fällt bis zur Brust, graues Haar zeigt sich an seinen Schläfen, und sein Gesicht ist tief durchfurcht. Auf seinem Kopf sitzt das corno ducale, eine steife hornförmige Dogemütze aus rostrotem Brokat, die hinten zu einem stumpfen Punkt aufsteigt wie eine Phrygische Mütze, hier über einem eng anliegenden weißen Leinencamauro getragen, dessen Rand an der Stirn darunter sichtbar ist. Über seinen Schultern liegt ein schwerer grauer Mantel, mit blassem Pelz besetzt, der vorn offen fällt und mit demselben Rostrot wie die Mütze gefüttert ist. Darunter trägt er eine lange Robe aus tiefrotem Brokat, die an der Taille mit einer geknoteten goldenen Schnur gegürtet ist. Das Brückengeländer ist aus Schmiedeeisen, seine Felder mit schlanken spitzen Bögen im venezianisch-gotischen Stil gefüllt. Hinter ihm zieht sich der Kanal in die Dunkelheit zurück, flankiert von Palazzi, deren Fenster warm orange gegen die blaue Nacht leuchten. Eine schmale Gondel liegt am Kai zur Linken vertäut, der Sternenhimmel bricht über den Dächern durch Wolken."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "Shaka kaSenzangakhona, König der Zulu, steht auf dem offenen Grund eines königlichen Gehöfts, die Füße fest gepflanzt, das Schild an seiner linken Seite ausgestreckt und den kurzen Speer zur Rechten. Er ist nackt-obeig, dunkelhäutig und stark muskulös; sein Oberkörper ist von schlanken Schnüren mit kleinen Perlen gekreuzt. Um seinen Kopf liegt ein umqhele, ein breites kreisrundes Stirnband aus geflecktem Leopardenfell, das königlichen und hohen Rang anzeigt. Daran ist an der Stirn eine aufrechte weiße Federbüschel befestigt, die Spitzen rot. An seiner Taille hängt eine Schürze aus Leopardenfell, die über die Hüften fällt; darunter schaukeln lange blasse Fellquasten gegen seine Oberschenkel. Bänder desselben gefleckten Fells umwickeln seine Knöchel. In seiner linken Hand trägt er ein isihlangu, einen hohen, spitz-ovalen Kriegsschild aus Ochsenhaut; seine Oberfläche ist braun und weiß gefleckt, ein gerader hölzerner Stab verläuft durch seine Mitte und ist durch Lederösen gesichert. In seiner rechten Hand, tief und bereit gehalten, ist ein iklwa, ein kurzschaftiger Stoßspeer mit einer langen, breiten, blattförmigen Klinge. Hinter ihm biegt sich eine Reihe von iqukwane, gewölbten Bienenkorb-Hütten aus Gras und Stroh eines Zulu-umuzi, ihre geflochtenen Oberflächen im Sonnenlicht. Zu beiden Seiten der Lichtung erheben sich Holzpfosten, die mit den Schädeln langgehörnter Rinder gekrönt sind; die mächtigen geschwungenen Hörner noch daran, Reichtum und Opfer am Tor zur Schau gestellt. Der Boden ist trockene blasse Erde, in der Ferne zeichnet sich ein Tafelberg ab, und der Himmel darüber ist ein klares blasses Blau, von dünnen Wolken durchzogen."

-- Economic Overview (F2 / Domestic Advisor): tab names, column labels,
-- group / row text consumed by CivVAccess_EconomicOverviewAccess.lua.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "Städte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "Zufriedenheit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "Ressourcen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "Bevölkerung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "Kampfstärke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "Nahrung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "Forschung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "Gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "Glaube"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "Produktion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "Hauptstadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "Marionette"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "besetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "besetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "keine Einträge"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "keine Produktion"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    one = "{1_Turns} Runde: {2_Name}",
    other = "{1_Turns} Runden: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "{1_PerTurn} pro Runde, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "Gold gesamt, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "Einnahmen, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "Ausgaben, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "Netto pro Runde, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "Forschungsverlust durch Golddefizit, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "Städte, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "Diplomatie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "Religion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "Stadtverbindungen, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "Einheiten, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "Gebäude, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "Modernisierungen, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "Diplomatie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "Zufriedenheit gesamt, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "Quellen der Zufriedenheit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "Luxusgüter, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "Luxusgüter-Vielfalt, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "Bonus durch Luxusgüter, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "Weitere Luxusgüter-Boni, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "Stadtzufriedenheit, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "Gebäude, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "Zufriedenheit aus Gebäuden, Garnisonen, Religion und Politiksynergien in jeder Stadt. "
    .. "Begrenzt auf die Stadtbevölkerung."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "Wunderboni, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "Zufriedenheit aus Wundern mit Sondereffekten: Gebäudeklassen-Synergien, "
    .. "unmodifizierte Zufriedenheit oder Boni pro Politik. Die meisten Zufriedenheitsgebäude "
    .. "zählen zu Gebäude (pro Stadt), nicht zu dieser Zeile."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "Reichsweite Boni, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "Handelswege, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "Stadtstaaten, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "Politik, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "Religion, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "Naturwunder, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "Boni pro Stadt, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "Zufriedenheit aus Gebäuden oder Politiken, die einen festen Betrag pro eigener Stadt gewähren. "
    .. "Multipliziert mit Eurer Stadtanzahl."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "Weltkongress, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "Schwierigkeitsgrad, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "Unzufriedenheit gesamt, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "Quellen der Unzufriedenheit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    one = "{1_Count} Stadt, {2_Value} Unzufriedenheit",
    other = "{1_Count} Städte, {2_Value} Unzufriedenheit",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    one = "{1_Count} besetzte Stadt, {2_Value} Unzufriedenheit",
    other = "{1_Count} besetzte Städte, {2_Value} Unzufriedenheit",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    one = "{1_Count} Bürger, {2_Value} Unzufriedenheit",
    other = "{1_Count} Bürger, {2_Value} Unzufriedenheit",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    one = "{1_Count} besetzter Bürger, {2_Value} Unzufriedenheit",
    other = "{1_Count} besetzte Bürger, {2_Value} Unzufriedenheit",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "Öffentliche Meinung, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "Aufschlüsselung pro Stadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "Verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "Verwendet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "Lokal"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "Importiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_FROM_CITY_STATES"] = "Von Stadtstaaten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "Exportiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "n/a"

-- Victory Progress (F8 / Who is winning): two-tab layout.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "Punktzahl"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "Siege"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "Gesamt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, Hauptstadt verloren"

-- Victory Progress screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "Herrschaft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "Wissenschaft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "Diplomatisch"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "Kulturell"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "Team {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    one = "{1_Num} Booster",
    other = "{1_Num} Booster",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "Cockpit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "Stasiskammer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "Triebwerk"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, Apollo-Programm nicht gebaut"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, Apollo-Programm gebaut"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "Apollo-Programm gebaut, keine Teile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, Apollo-Programm gebaut, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "Apollo-Programm gebaut, {1_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    one = "{1_Have} von {2_Total} Voraussetzung erforscht",
    other = "{1_Have} von {2_Total} Voraussetzungen erforscht",
}

-- Demographics (F9)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, Rang {2_Rank}, {3_Value}, Bester {4_BestCiv} {5_BestVal}, Durchschnitt {6_AvgVal}, Schlechtester {7_WorstCiv} {8_WorstVal}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "Bruttosozialprodukt"

-- Culture Overview (Ctrl+C)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "Eure Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "Große Werke tauschen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "Kultursieg"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "Einfluss durch Spieler"

-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] =
    "Altertumsstätten: {1_Visible} sichtbar, {2_Hidden} verborgen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    one = "{1_Name}, Kultur {2_Cul}, Tourismus {3_Tou}, Großes Werk {4_Filled} von {5_Total}",
    other = "{1_Name}, Kultur {2_Cul}, Tourismus {3_Tou}, Große Werke {4_Filled} von {5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    one = "{1_Name}, Kultur {2_Cul}, Tourismus {3_Tou}, Großes Werk {4_Filled} von {5_Total}, beschädigt {6_Pct} Prozent",
    other = "{1_Name}, Kultur {2_Cul}, Tourismus {3_Tou}, Große Werke {4_Filled} von {5_Total}, beschädigt {6_Pct} Prozent",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "Hauptstadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "Marionette"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "besetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "Noch keine Gebäude für Große Werke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "Keine Städte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "Literaturplatz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "Kunst- oder Artefaktplatz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "Musikplatz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled} von {4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled} von {4_Total}, Themen-Bonus plus {5_Bonus}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, leer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "Literatur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "Kunst"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "Artefakt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "Musik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class} von {2_Artist}, {3_OriginCiv}, {4_Era}, plus {5_Cul} Kultur, plus {6_Tou} Tourismus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "von {1_Artist}, {2_OriginCiv}, {3_Era}, plus {4_Cul} Kultur, plus {5_Tou} Tourismus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, plus {4_Cul} Kultur, plus {5_Tou} Tourismus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "als Verschiebequelle markiert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "verschoben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "Verschiebequelle zurückgesetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] = "falscher Platztyp für aktuelle Quelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "Verschieben aus leerem Platz nicht möglich"

-- Tab 2 (Swap Great Works).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "Eure Angebote"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "Literatur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "Kunst"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "Artefakt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "nichts ausgewählt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "Auswahl aufheben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "Verfügbar von anderen Zivilisationen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "Keine Zivilisation bietet tauschbare Werke an"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "Keine tauschbaren Werke"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] =
    "Wählt ein Werk einer anderen Zivilisation zum Tauschen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "Kein {1_Type} für {2_TheirName} von {3_TheirCiv} ausgewählt; wählt eines in Euren Angeboten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "Euer {1_YourName} gegen {2_TheirName} von {3_TheirCiv} tauschen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "Tausch gesendet"

-- Tab 3 (Culture Victory).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N} von {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "keine Ideologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "keine öffentliche Meinung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "Einflussreich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "Tourismus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "Ideologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "Öffentliche Meinung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] = "Unzufriedenheit aus öffentlicher Meinung"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "Überschuss-Zufriedenheit"

-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    one = "voraussichtlich {1_N} Runde bis Einflussreich",
    other = "voraussichtlich {1_N} Runden bis Einflussreich",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "Perspektive wechseln"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "Einflussstufe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "Einfluss in Prozent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "Tourismusmodifikator"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "Tourismus auf sie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "Trend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "erzeugt {1_N} Tourismus pro Runde, Eingabe drücken um zu dieser Perspektive zu wechseln"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] = "jetzt Ansicht von {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N} Prozent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "Euer {1_Yours} Tourismus im Vergleich zu ihrer {2_Theirs} lebenslanger Kultur"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N} Prozent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "sinkend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "unverändert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "steigend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "steigt langsam"

-- Hotkey help (BaselineHandler / map-mode help list).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Steuerung plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "Kulturübersicht öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] = "Kulturübersicht ist in diesem Spiel deaktiviert"

-- League Overview (World Congress / United Nations).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "Weltkongress"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Steuerung plus L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "Weltkongress-Übersicht öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "Status"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "Vorschläge"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "Effekte"

-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "Umbenennen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(Ihr)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "Gastgeber"
-- Plural driven by {1_N} (delegate count this member holds in the league).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    one = "{1_N} Abgeordneter",
    other = "{1_N} Abgeordnete",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "kann vorschlagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "Diplomat in ihrer Hauptstadt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "Kein Weltkongress"
-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "Keine Aktionen in dieser Sitzung verfügbar."
-- Plural driven by {1_N} (proposals the player can submit this session).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    one = "{1_N} Vorschlag verfügbar.",
    other = "{1_N} Vorschläge verfügbar.",
}
-- Plural driven by {1_N} (delegates the player has not yet allocated
-- to a vote in the current session).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    one = "{1_N} Abgeordneter verbleibend.",
    other = "{1_N} Abgeordnete verbleibend.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "Keine Vorschläge in dieser Sitzung."
-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "Durchsetzen: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "Aufheben: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "Vorgeschlagen von {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "Von Euch vorgeschlagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "Ausstehend"
-- Vote-state suffix appended to proposal row in Vote mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "Euer Votum: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "enthalten"
-- Yea / Nay are invariant in English ("1 Yea" / "5 Yea"); bundle stays
-- degenerate but lets a future translator pluralize for languages that
-- inflect the vote-label noun.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    one = "{1_N} Ja",
    other = "{1_N} Ja",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    one = "{1_N} Nein",
    other = "{1_N} Nein",
}
-- Cast-vote row used in Diplomatic Victory voting where each delegate slot
-- can name a specific civ. {1_N} is the count of votes cast (1 per
-- delegate); {2_Civ} is the civ they were cast for.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} für {2_Civ}"
-- Slot picker (Propose mode).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "Leerer Vorschlagsplatz {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "Platz {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "Vorschlagsplatz {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "Aktive Resolutionen zum Aufheben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "Resolutionen zum Vorschlagen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "Andere Resolutionen"
-- Mod prefaces for the GetResolutionDetails opinion sections.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] =
    "Unsere geschätzte Zählung für diesen Vorschlag steht bei:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] =
    "Zivilisationen, die zustimmen würden: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] = "Zivilisationen, die ablehnen würden: {1_Civs}"
-- Religion Overview.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Strg plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "Religionsübersicht öffnen"
-- "You are the founder of X" replaces the engine's bare "Founder of X".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "Ihr seid Gründer von {1_Religion}"
-- Belief type word with " belief" suffix.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "{1_Type}-Glaubenssatz"
-- World Religions row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    one = "{1_Religion}, Heilige Stadt {2_HolyCity}, gegründet von {3_Founder}, {4_NumCities} Stadt",
    other = "{1_Religion}, Heilige Stadt {2_HolyCity}, gegründet von {3_Founder}, {4_NumCities} Städte",
}
-- Espionage Overview (BNW only).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Strg plus E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "Spionage-Übersicht öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "Agenten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "Städte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "Intrigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "Spionage ist in diesem Spiel deaktiviert"
-- Agent row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    one = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} Runde",
    other = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} Runden",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} im Einsatz gefallen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", Diplomat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "Aktionen von {1_Rank} {2_Name}"
-- City row pieces.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "Zivilisation {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "Stadt {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "Bevölkerung {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "Potential {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "Basispotential {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "Aufschlüsselung: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "Potential unbekannt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] = "Stadtstaat, Wahl manipulierbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] = "Stadtstaat, Wahl wird manipuliert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "Agent {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "Diplomat {1_Name}"
-- Intrigue row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "Runde {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "von Eurem Spion {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "geteilt von {1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "unbekannt"
-- Move-agent sub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "{1_Rank} {2_Name} verlegen"

-- Bookmarks
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "Lesezeichen gesetzt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "kein Lesezeichen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Strg plus Zifferntaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] =
    "Lesezeichen am Cursor im entsprechenden Platz speichern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Umschalt plus Zifferntaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "Cursor zum Lesezeichen in diesem Platz springen, Rücktaste kehrt zurück"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt plus Zifferntaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "Entfernung und Richtung vom Cursor zum Lesezeichen in diesem Platz"

-- Beacons
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "Bake {1_Slot} aktiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "Bake {1_Slot} deaktiviert"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] = "zuerst ein Lesezeichen in diesem Platz setzen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] = "Strg plus Umschalt plus Zifferntaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "Räumliche Audiobake am Lesezeichen in diesem Platz umschalten"

-- Message buffer
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "Alle Nachrichten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "Benachrichtigungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "Entdeckungen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "Kampf"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "Chat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "keine Nachrichten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "Linke und rechte eckige Klammer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "Vorherige und nächste Nachricht im Puffer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] = "Strg plus linke und rechte eckige Klammer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] = "Älteste und neueste Nachricht im Puffer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] = "Umschalt plus linke und rechte eckige Klammer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "Puffer-Filterkategorie wechseln, leere Kategorien überspringen"

-- Multiplayer chat
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Rückstrich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] =
    "Mehrspieler-Chat öffnen, im Einzelspieler wirkungslos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "Chat ist nur im Mehrspielermodus verfügbar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "Chat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "Nachrichten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "Verfassen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "Nachricht"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "Noch keine Chat-Nachrichten"
-- {1_Name} sender, {2_Text} message body.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} an Team: {2_Text}"
-- {2_To} recipient name (or "you" when the local player is the target).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} an {2_To}: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "Rückstrich oder Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "Chat-Panel schließen"

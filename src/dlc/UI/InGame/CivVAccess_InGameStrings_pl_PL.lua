-- Mod-authored strings, pl_PL overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== ingame_batch_01.lua =====
-- Batch 01 (lines 120-421): boot, mute, unit speech, paths
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "Civilization V: funkcje dostępności załadowane."

-- ===== Mute / hotseat toggle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "mod wstrzymano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "mod wznowiono"

-- Unit speech.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "rekomendacja: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "Miejsce na miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "zaokrętowany {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} ruchów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} samolotów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "awans dostępny"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    one = "{1_What} {2_Turns} tura",
    few = "{1_What} {2_Turns} tury",
    many = "{1_What} {2_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "ruch w kolejce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_MOVE_CHUNK"] = {
    one = "ruch w kolejce, {2_Turns} tura: {1_Segments}",
    few = "ruch w kolejce, {2_Turns} tury: {1_Segments}",
    many = "ruch w kolejce, {2_Turns} tur: {1_Segments}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_ROUTE_CHUNK"] = {
    one = "{3_RouteName} w kolejce, {2_Turns} tura: {1_Segments}",
    few = "{3_RouteName} w kolejce, {2_Turns} tury: {1_Segments}",
    many = "{3_RouteName} w kolejce, {2_Turns} tur: {1_Segments}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO_JOINER"] = ", potem "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_ARRIVE"] = ", przybycie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_HERE"] = {
    one = "{1_Turns} tura tutaj",
    few = "{1_Turns} tury tutaj",
    many = "{1_Turns} tur tutaj",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} siła walki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} siła ataku dystansowego, zasięg {2_Range}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} siła ataku dystansowego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "zasięg {1_Strike}, zasięg przemieszczenia {2_Rebase}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "atak wyczerpany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "ruch wyczerpany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "pż {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "zielony"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "żółty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "czerwony"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "pełne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "poziom {1_Lvl}, {2_Cur}/{3_Next} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "ulepszenie do {1_Name}, {2_Gold} złota"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "awanse: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    one = "przemieszczono, {1_Num} ruch pozostał",
    few = "przemieszczono, {1_Num} ruchy pozostały",
    many = "przemieszczono, {1_Num} ruchów pozostało",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "zatrzymano przed celem"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    one = "zatrzymano przed celem, {1_Num} tura do przybycia",
    few = "zatrzymano przed celem, {1_Num} tury do przybycia",
    many = "zatrzymano przed celem, {1_Num} tur do przybycia",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "akcja nie powiodła się"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "w kolejce na następną turę"

-- Alt+QAZEDC prechecks
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "jednostka dystansowa, użyj ataku dystansowego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "jednostka powietrzna, użyj ataku dystansowego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "nie można atakować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "atak wyczerpany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "ruch wyczerpany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "samolot nie może być przemieszczany w ten sposób, użyj przemieszczenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "nie sąsiaduje"

-- Target-specific attack refusals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "atakuje tylko miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "jednostka morska nie atakuje lądu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "nie można atakować tego celu"

-- Empty-state tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "brak jednostek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "brak akcji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "zostanie wypowiedziana wojna"

-- Menu names
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Akcje jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "Aktywuj pole"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Awanse"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Buduj ulepszenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE_WITH_REASON"] = "niedostępne, {1_BuildName}, {2_Reason}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE"] = "niedostępne, {1_BuildName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "tryb wyboru celu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "w kolejce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "nie można ustawić ataku w kolejce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_PREVIEW"] = "Podgląd akcji na wskazanym polu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_COMMIT"] = "Wykonaj akcję na wskazanym polu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_QUEUE"] = "Shift plus enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_QUEUE"] = "Ustaw akcję w kolejce misji jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_CANCEL"] = "Anuluj tryb wyboru celu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "anulowano"

-- Combat preview vocabulary
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "poza zasięgiem"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, {5_DmgToMe} obrażeń dla mnie, {6_DmgToThem} dla nich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "ostrzał wsparcia {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "szansa zdobycia {1_Pct} procent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "moje bonusy {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "ich bonusy {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "plus {1_N} procent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "minus {1_N} procent {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, {5_DmgToThem} obrażeń dla nich"

-- City-defender preview variants
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "miasto {1_Name}, {2_MyStr} vs {3_TheirStr}, {4_DmgToMe} obrażeń dla mnie, {5_DmgToThem} dla nich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "miasto {1_Name}, {2_MyStr} vs {3_TheirStr}, {4_DmgToThem} obrażeń dla nich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} dla mnie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    one = "{1_N} przechwytywacz",
    few = "{1_N} przechwytywacze",
    many = "{1_N} przechwytwywaczy",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "przemieść do {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} pozostało"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    one = "{1_MP} MP, {2_Turns} tura, {3_Left} pozostało",
    few = "{1_MP} MP, {2_Turns} tury, {3_Left} pozostało",
    many = "{1_MP} MP, {2_Turns} tur, {3_Left} pozostało",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "w tej turze, niezbadany obszar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    one = "{1_Turns} tura, niezbadany obszar",
    few = "{1_Turns} tury, niezbadany obszar",
    many = "{1_Turns} tur, niezbadany obszar",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "w tej turze, {1_Steps} potem niezbadany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    one = "{1_Turns} tura, {2_Steps} potem niezbadany",
    few = "{1_Turns} tury, {2_Steps} potem niezbadany",
    many = "{1_Turns} tur, {2_Steps} potem niezbadany",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] = "w tej turze, {1_Steps} potem atak"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    one = "{1_Turns} tura, {2_Steps} potem atak",
    few = "{1_Turns} tury, {2_Steps} potem atak",
    many = "{1_Turns} tur, {2_Steps} potem atak",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "brak drogi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "za daleko, by wyliczyć"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "zablokowane przez granice {1_Civ}, najbliższy osiągalny {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "zablokowane przez granice {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] =
    "zablokowane przez zamknięte granice, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "zablokowane przez zamknięte granice"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] =
    "zablokowane przez {1_Unit}, najbliższy osiągalny {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "zablokowane przez {1_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] =
    "zablokowane przez jednostkę, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "zablokowane przez jednostkę"
-- Fog-of-war variants. When the blocker unit's plot isn't visible to the
-- active team, naming the unit would leak intelligence the sighted UI
-- doesn't expose either. The message says only that the path is blocked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED"] = "zablokowane, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED_NO_DIR"] = "zablokowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] = "brak drogi, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] =
    "brak technologii zaokrętowania, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "brak technologii zaokrętowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] = "wymagana astronomia, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "wymagana astronomia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] =
    "zablokowane przez góry, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "zablokowane przez góry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] =
    "zablokowane przez {1_Wonder}, najbliższy osiągalny {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "zablokowane przez {1_Wonder}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] =
    "brak połączenia wodnego, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "brak połączenia wodnego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "nie można atakować z lądu, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "nie można atakować z lądu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "nie można atakować z wody, najbliższy osiągalny {1_Dir}"

-- ===== ingame_batch_02.lua =====
-- Batch 02 (lines 422-637): paths, unit confirms, button states

-- Domain-incompatible combat (continued)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] = "nie można atakować z wody"
-- Naval unit targeting empty / peaceful-occupied non-city land.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] =
    "nie można dotrzeć na ląd, najbliższy dostępny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "nie można dotrzeć na ląd"
-- Embark / disembark hint appended to a successful move-path preview.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "wymaga zaokrętowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "wymaga wylądowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "brak celu tutaj"
-- Route-to (auto-route) preview.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TILES_CLAUSE"] = {
    one = "{1_N} pole",
    few = "{1_N} pola",
    many = "{1_N} pól",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    one = "{1_N} tura",
    few = "{1_N} tury",
    many = "{1_N} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    one = "{1_Tiles} pole, bez pracy",
    few = "{1_Tiles} pola, bez pracy",
    many = "{1_Tiles} pól, bez pracy",
}
-- Route-to water blocker. The only route-failure cause without a move-to
-- analog -- move-to handles water via embark/astronomy unlocks, whereas
-- BuildRouteValid rejects every water step outright. Mountain and
-- borders reuse PATH_BLOCKED_MOUNTAIN / PATH_BLOCKED_BORDERS_CIV; same
-- cause, same wording, no need for route-flavored duplicates.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER"] =
    "zablokowane przez wodę, najbliższy osiągalny {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER_NO_DIR"] = "zablokowane przez wodę"
-- Per-mode "cannot X here" strings.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "nie można tutaj desantować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "nie można tutaj przetransportować lotniczo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "nie można tutaj zmienić bazy"
-- Rebase destination entry in the unit action menu's Rebase drill-in.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    one = "{1_Name}, {2_N} pole",
    few = "{1_Name}, {2_N} pola",
    many = "{1_Name}, {2_N} pól",
}
-- Spoken when no rebase destination is available.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] = "brak miejsc docelowych zmiany bazy w zasięgu"
-- Spoken on rebase resolution.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "zmieniono bazę na {1_Name}"
-- Airlift sub-menu.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "Wybierz miasto, do którego przetransportować tę jednostkę. Po wyborze wskaż dokładny heks lądowania, nie może być dalej niż 1 pole od miasta."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    one = "{1_Name}, {2_N} pole",
    few = "{1_Name}, {2_N} pola",
    many = "{1_Name}, {2_N} pól",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] =
    "brak dostępnych miejsc docelowych transportu lotniczego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "nie można tutaj zaokrętować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "nie można tutaj wylądować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "nie można tutaj użyć broni nuklearnej"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "nie można tutaj podarować jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "nie można tutaj ulepszyć"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "brak widocznych przechwytujących"
-- Action-affirming legal previews.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "transport lotniczy tutaj"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "desant tutaj"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] = "atak nuklearny tutaj, promień rażenia {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "podaruj {1_Unit} dla {2_Recipient}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] = "ulepsz {1_Resource} dla {2_Recipient}"
-- Unit control help overlay entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Kropka, przecinek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "Przejdź do następnej lub poprzedniej jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Control plus kropka lub przecinek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "Przejdź do następnej lub poprzedniej jednostki, w tym tych, które już wykonały akcję"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Ukośnik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] = "Odczytaj informacje bojowe i awanse wybranej jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Control plus ukośnik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] = "Wyśrodkuj kursor heksowy na wybranej jednostce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Otwórz menu akcji jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt plus Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Przesuń wybraną jednostkę o jeden heks (dwukrotne naciśnięcie potwierdza atak)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt plus M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "Otwórz wybór celu ruchu; celuj klawiszami kursora, spacja podgląd, Enter zatwierdź"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] = "Umocnij jednostkę wojskową lub uśpij cywilną"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] =
    "Wartownik, śpi do czasu pojawienia się wroga w zasięgu wzroku"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt plus W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "Obudź śpiącą lub umocnioną jednostkę albo anuluj kolejkowany ruch lub automatyzację"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt plus X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "Pomiń turę jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "Leczenie do pełni pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "Otwórz wybór celu ataku na dystans; celuj klawiszami kursora, spacja podgląd, Enter zatwierdź"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "Splądruj pole jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt plus U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "Ulepsz jednostkę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt plus N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "Zmień nazwę jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} niedostępna"
-- Combat-result payload.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "atakujący {1_Name} -{2_Dmg} pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "broniący {1_Name} -{2_Dmg} pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "atakujący {1_Name} bez obrażeń"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "broniący {1_Name} bez obrażeń"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} poległo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} schwytano"
-- Substituted for the attacker / defender name in AI-vs-AI combat.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "nieznane"
-- Air-strike intercept clause.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "przechwycono przez {1_Name}"
-- Air-sweep prefix.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "przechwycenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "walka lotnicza"
-- Air-sweep no-target.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "brak przechwytujących"
-- Nuclear strike speech.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "{1_Civ} atak nuklearny"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "cel {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "ofiary {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "jednostki {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "brak trafionych celów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} pop"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "poległo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "zniszczono"
-- City-capture announcements.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "zdobyto {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "utracono {1_Name}"
-- Self-plot action confirms.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "umocniono"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "śpi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "w pogotowiu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "przebudzona"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "zautomatyzowano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "rozwiązano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "leczy się"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "splądrowano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "pominięto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "ulepszono"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "anulowano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "rozpoczęto {1_Build}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "awansowano na {1_Name}"

-- ===== ingame_batch_03.lua =====
-- Batch 03 (lines 638-855): directions, screen labels, city
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "wyłączone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, wyłączone"
-- Cursor / hex-grid handler. Direction tokens are short forms (e, ne, ...)
-- because experienced screen-reader users prefer shorter speech and these
-- appear in tight contexts (per-move river edges, capital orientation).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "w"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "pn-w"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "pd-w"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "pd-z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "pn-z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_N"] = "pn"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_S"] = "pd"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "krawędź mapy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "krawędź zasięgu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "niezajęte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "nieodkryte"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "mgła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "niewidoczne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "stolica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "brak stolicy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    one = "{1_Moves} ruch",
    few = "{1_Moves} ruchy",
    many = "{1_Moves} ruchów",
}
-- River and fresh-water tokens spoken in the cursor's tile glance.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "rzeka {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "rzeka ze wszystkich stron"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "słodka woda"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "punkt trasy {1_Index} z {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} splądrowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "wzgórza"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "góra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "jezioro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    one = "{1_Build} {2_Turns} tura",
    few = "{1_Build} {2_Turns} tury",
    many = "{1_Build} {2_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "kontrolowane przez {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "kontrolowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} procent obrony"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "w strefie kontroli wroga"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NEARBY_ENEMIES"] = {
    one = "{1_N} pobliski wróg",
    few = "{1_N} pobliskich wrogów",
    many = "{1_N} pobliskich wrogów",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Q, W, E, A, S, D, Z, X, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] =
    "Przesuń kursor o pole (Q pn-z, E pn-w, A z, D w, Z pd-z, C pd-w)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] = "Klawiatura numeryczna 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] =
    "Odzwierciedla Q, W, E, A, S, D, Z, X, C z tymi samymi modyfikatorami (na klawiaturze numerycznej 5 odpowiada S, przy włączonym NumLock)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "Odczytaj jednostkę na bieżącym polu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Shift plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "Współrzędne kursora względem pierwotnej stolicy w zmodyfikowanym układzie współrzędnych (każdy krok na wschód to plus jeden w x, każdy krok pn-w to plus 0,5 w x i plus jeden w y, każdy krok pd-w to plus 0,5 w x i minus jeden w y)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Control plus S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "Przenieś kursor do swojej stolicy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "Szczegóły ekonomiczne bieżącego pola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "Szczegóły walki na bieżącym polu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PATH_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PATH_PREVIEW"] =
    "Podgląd trasy wybranej jednostki i kosztu ruchu do bieżącego pola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "Tożsamość i walka miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "Produkcja i wzrost miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "Religia miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] = "Notatki dyplomatyczne miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "Wybierz jednostkę lub otwórz ekran miasta (okno aneksji dla marionetek, Dyplomacja z poznaną cywilizacją) na polu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Control plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "Otwórz Cywilipedię dla wszystkich elementów na polu kursora (jednostki, cuda świata, ulepszenia, zasoby, cechy terenu, rzeka, jezioro, teren, wzgórza, góra, szlak)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "Artykuły na polu"
-- City-info speech tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "nieznane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "można atakować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "brak miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "kulturowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "militarystyczne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "morskie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "kupieckie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "religijne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "neutralne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "przyjaciel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "sojusznik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "wojna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "stała wojna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    one = "niszczone {1_Turns} tura",
    few = "niszczone {1_Turns} tury",
    many = "niszczone {1_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    one = "opór {1_Turns} tura",
    few = "opór {1_Turns} tury",
    many = "opór {1_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "okupowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "marionetka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "zablokowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} mieszkańców"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} obrona"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} z {2_Max} pż"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "garnizon {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    one = "produkuje {1_Name} {2_Turns} tura",
    few = "produkuje {1_Name} {2_Turns} tury",
    many = "produkuje {1_Name} {2_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "produkuje {1_Name}"
-- City development tokens (the "2" key).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "nic nie produkuje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} z {2_Needed} produkcji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    one = "wzrost za {1_Turns} turę",
    few = "wzrost za {1_Turns} tury",
    many = "wzrost za {1_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "głoduje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "wzrost zatrzymany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} z {2_Threshold} żywności"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "traci {1_Num} na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] =
    "produkcja ukryta, sprawdź Przegląd szpiegostwa"
-- City religion tokens (the "3" key).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    one = "przez {1_N} szlak handlowy",
    few = "przez {1_N} szlaki handlowe",
    many = "przez {1_N} szlaków handlowych",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "brak religii"
-- City diplomatic notes (the "4" key).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "pierwotnie {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "podgląd ekspansjonizmu: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "podgląd wyzwolenia: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "szpieg {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "dyplomata {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "brak notatek dyplomatycznych"

-- ===== ingame_batch_04.lua =====
-- Batch 04 (lines 856-1023): popup screens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "tryb mapy"
-- Type-ahead search feedback (see FrontEnd strings for the authoring
-- rationale). Mirrored here because TypeAheadSearch runs from in-game
-- BaseMenu contexts whose string table is sandboxed from the FrontEnd copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "brak dopasowań dla {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "wyszukiwanie wyczyszczone"
-- Help overlay strings (see FrontEnd strings for the authoring rationale).
-- Duplicated here because Contexts are sandboxed: in-game Contexts that
-- eventually wire SetInputHandler through InputRouter need their own copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Pomoc"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Litery"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Góra lub dół"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home lub End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter lub spacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Lewo lub prawo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift plus lewo lub prawo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Ctrl plus góra lub dół"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt plus lewo lub prawo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift plus tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Znak zapytania"
-- Description tokens of the help overlay (paired with the KEY_* labels
-- above; the two halves combine via HELP_ENTRY = "{1_Key}, {2_Description}").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Wpisz, aby szukać"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Przejdź między elementami"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "Przejdź do pierwszego lub ostatniego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Aktywuj"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "Zmień wartość lub wejdź głębiej"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "Zmień wartość większymi krokami"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "Przejdź do poprzedniej lub następnej grupy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Następna karta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Poprzednia karta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Odczytaj nagłówek ekranu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "Otwórz wpis Cywilipedii dla bieżącego elementu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Anuluj"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Zamknij"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Anuluj edycję"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Zatwierdź edycję"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Control plus Shift plus F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Otwórz ustawienia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Zamknij ustawienia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "Wstrzymaj lub wznów mod"
-- BaseTable: 2D table viewer (used by F2 cities, future demographics, etc.).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, malejąco"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, rosnąco"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, sortowanie wyczyszczone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "przycisk sortowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "Przejdź między wierszami"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "Przejdź między kolumnami"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "Pierwszy lub ostatni wiersz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "Aktywuj komórkę lub posortuj według kolumny"
-- Settings overlay strings. Reachable from every Context that routes
-- through InputRouter, so duplicated in the FrontEnd copy as well.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Ustawienia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_UI"] = "Ustawienia interfejsu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_CURSOR"] = "Ustawienia kursora"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_BEACON"] = "Ustawienia sygnału"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_SCANNER"] = "Ustawienia skanera"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_NOTIFICATIONS"] = "Powiadomienia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Ikony dźwiękowe terenu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Tylko mowa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Mowa i sygnały dźwiękowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "Szczegółowe komunikaty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Tylko sygnały dźwiękowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "Głośność ikon dźwiękowych terenu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "Głośność ikon dźwiękowych terenu, {1_Num} procent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME"] = "Głośność sygnału"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME_VALUE"] = "Głośność sygnału, {1_Num} procent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "Zasięg słyszalności sygnału"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] = "Zasięg słyszalności sygnału, {1_Num} heksów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "Automatyczne przesuwanie kursora skanera"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "Kursor śledzi wybraną jednostkę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "Współrzędne kursora podczas ruchu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Wył."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "Mów przed ogłoszeniem ruchu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "Mów po ogłoszeniu ruchu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] = "Zawsze ogłaszaj terytorium w opisie pola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_ENEMY_ADJACENT_WARN"] = "Ostrzegaj o sąsiednim wrogu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "Skaner pokazuje współrzędne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COMPASS_DIRECTION"] = "Skaner używa kierunku kompasowego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_DIRECTION_BEEP"] = "Skaner odgrywa sygnał kierunkowy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Czytaj napisy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "Ogłaszaj zmiany widoczności podczas ruchu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "Ogłaszaj rozstrzygnięcia walk AI"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] =
    "Ogłaszaj zmiany widoczności na początku tury"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "Ogłaszaj obozy i ruiny przejęte przez innych w polu widzenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_TURN_START_SOUND"] =
    "Odtwarzaj dźwięk na początku tury w grze jednoosobowej"
-- Widget-generic strings spoken by BaseMenuItems Choice / Checkbox /
-- Textfield and BaseMenuEditMode. Mirrored from the FrontEnd copy because
-- Contexts are sandboxed: an in-game screen that uses these item kinds
-- needs them present in the InGame Context's string table.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "wybrane"
-- Compositional form: "selected, <label>" for Choice items that surface
-- the selection marker as a prefix on the entry's own text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "wybrane, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "wł."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "wył."
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "edytuj"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "puste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "edytowanie {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} przywrócono"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "przycisk"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "przełącznik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "suwak"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "lista rozwijana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "podmenu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_LINK"] = "link"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "tabela"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "{1_Num} z {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "wiersz {1_Num} z {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "kolumna {1_Num} z {2_Num}"
-- GameMenu (Esc pause menu) strings. Details tab reuses the base game's
-- TXT_KEY_POPUP_GAME_DETAILS, so no mod-authored tab label here.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "Menu pauzy"
-- GenericPopup (the shared Context behind AnnexCity / PuppetCity /
-- ConfirmCommand / DeclareWar / BarbarianRansom / etc.). One display name
-- for all of them; the per-popup text comes from the base via preamble.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "Wyskakujące okienko"
-- Informational popups that have no engine-side title to reuse: TextPopup
-- is a generic notification, WonderPopup only carries the wonder name
-- (dynamic), LeagueSplash's title is dynamic per-session.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "Powiadomienie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "Cud ukończony"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "Kongres Światowy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "Koniec gry"
-- Ranking tab row labels. The HistoricRankings table is fixed leader tiers
-- with thresholds; the matched row replaces "score <threshold>" with the
-- player's actual score and tacks on the leader's quote.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, wynik {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] = "{1_Rank} {2_Leader}, twój wynik {3_Score}, {4_Quote}"
-- Drillable label for a per-turn group of replay messages. Source is
-- Game.GetReplayMessages() at end-game; children are the non-empty Text
-- entries on that turn, with the turn prefix dropped since the group
-- label provides it.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "Tura {1_Turn}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "Wypowiedz wojnę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "Powitanie miasta-państwa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "Miasto-państwo"
-- Fallback for LeaderHeadRoot / DiscussionDialog before TitleText is
-- populated. In practice the onShow hook overwrites handler.displayName
-- with the live leader title (e.g. "Suleiman the Magnificent") that
-- LeaderMessageHandler just set.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "Dyplomacja"
-- DiscussionDialog sub-menu display names. Denounce confirm is a yes/no
-- overlay; coop-war leader picker is a scroll list of civs the AI could
-- ally with against us.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "Potępienie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "Cel wspólnej wojny"

-- ===== ingame_batch_05.lua =====
-- Batch 05 (lines 1024-1246): cityview start, popups
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "Wielkie dzieło"
-- Choose-family popup screen names. Each popup's body text (what you're
-- picking among) is spoken as preamble from live engine controls; the
-- display name here is just the screen header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "Wybierz nagrodę za wioskę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WARRIOR"] = "wojownik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_POPULATION"] = "populacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_CULTURE"] = "kultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PANTHEON_FAITH"] = "wiara"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PROPHET_FAITH"] = "wielki prorok"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_NEARBY_BARBS"] = "odkryj pobliskich barbarzyńców"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_GOLD"] = "złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_LOW_GOLD"] = "złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HIGH_GOLD"] = "złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_MAP"] = "odkryj pobliską mapę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_TECH"] = "darmowa technologia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_RESOURCE"] = "odkryj pobliski surowiec"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_UPGRADE_UNIT"] = "ulepsz jednostkę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SETTLER"] = "osadnik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SCOUT"] = "zwiadowca"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WORKER"] = "robotnik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_EXPERIENCE"] = "doświadczenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HEALING"] = "ulecz jednostkę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "Wybierz bezpłatnego wielkiego człowieka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "Wybierz wielkiego człowieka za wiarę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "Wybierz bonus Majów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "Wybierz panteon"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "Wybierz ideologię"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "Wybierz wynik wykopalisk"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "Wybierz nowy port dla admirała"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "Wybierz nowy dom dla jednostki handlowej"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "Ustanów szlak handlowy"
-- Confirm-overlay sub-handler pushed on top of a Choose* picker when the
-- player activates an item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Potwierdź"
-- ChooseReligionPopup (BUTTONPOPUP_FOUND_RELIGION).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "Wybierz religię"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "Wzmocnij religię"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "Zmień nazwę religii"
-- Belief-slot label formats.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, nie wybrano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, dostępne później"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, tylko dla Bizancjum"
-- Religion-picker row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "religia, nie wybrano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "religia, {1_Name}"
-- Name row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "nazwa, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "nazwa religii"
-- NotificationLogPopup (BUTTONPOPUP_NOTIFICATION_LOG).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Dziennik powiadomień"
-- LeagueProjectPopup (BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "Projekt ligi ukończony"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} produkcji, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "nagroda złota"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "nagroda srebrna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "nagroda brązowa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "brak nagrody"
-- VoteResultsPopup (BUTTONPOPUP_VOTE_RESULTS).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "Wyniki głosowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    one = "{1_Rank}, {2_Name} zagłosował na {3_Cast}, otrzymał {4_Votes} głos",
    few = "{1_Rank}, {2_Name} zagłosował na {3_Cast}, otrzymał {4_Votes} głosy",
    many = "{1_Rank}, {2_Name} zagłosował na {3_Cast}, otrzymał {4_Votes} głosów",
}
-- WhosWinningPopup (BUTTONPOPUP_WHOS_WINNING).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "Kto wygrywa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"
-- Advisors tutorial banner (Events.AdvisorDisplayShow).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "Doradca samouczkowy"
-- NotificationLogPopup tab labels and item format.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "Aktywne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "Dziennik tury"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "Odrzucone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "Brak powiadomień."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, tura {2_Turn}"
-- Combat Log group inside the Turn Log tab.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "Dziennik walki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "Brak walk w tej turze."
-- MilitaryOverview (BUTTONPOPUP_MILITARY_OVERVIEW, F3).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur} z {3_Max} pd"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "Zaopatrzenie: {1_Use} z {2_Cap}"
-- Idle status fallback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "bezczynny"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_MOVING"] = "w ruchu"
-- Tab labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "Jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "Wielcy ludzie"
-- Units tab column headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "Odległość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "Pozostałe ruchy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "Maksymalne ruchy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "Siła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "Walka na odległość"
-- Great People tab.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress} z {4_Threshold}, plus {5_Rate} na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] =
    "{1_City}: {2_Progress} z {3_Threshold}, brak postępu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "następna tura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    one = "{1_N} tura",
    few = "{1_N} tury",
    many = "{1_N} tur",
}
-- AdvisorCounselPopup (BUTTONPOPUP_ADVISOR_COUNSEL).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "Brak rady."
-- Function-row help entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "Otwórz Cywilipedię"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "Otwórz doradcę ekonomicznego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "Otwórz doradcę wojskowego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "Otwórz doradcę dyplomatycznego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "Otwórz ekran instytucji społecznych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "Otwórz drzewo technologii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "Otwórz dziennik tury i zdarzeń"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "Otwórz ekran postępu do zwycięstwa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "Otwórz ekran demografii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "Otwórz radę doradców"
-- CityView hub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "Miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "połączone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} bezrobotnych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "żywność {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "produkcja {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "złoto {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "nauka {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "wiara {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "turystyka {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "kultura {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Kropka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "Następne miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Przecinek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "Poprzednie miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "brak następnego miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "brak poprzedniego miasta"
-- Hub items that push a sub-handler on Enter.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "Statystyki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "Cuda"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "Postęp wielkich ludzi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "Specjalizacja robotników"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "Bezrobotni: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "Nie zbudowano żadnych cudów."

-- ===== ingame_batch_06.lua =====
-- Batch 06 (lines 1247-1449): cityview foreign
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "Brak produkcji wielkich ludzi."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} z {3_Max}"
-- Focus item label when the current focus matches. Read by labelFn on
-- every navigate so flipping focus is reflected immediately.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, wybrane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "Unikaj wzrostu, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "Resetuj przypisania pól"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} wybrane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "przypisania pól zresetowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "brak bezrobotnych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "przypisano"
-- Buildings sub-handler (ss3.7). Drill-in opens on Enter over any building
-- entry; Sell is conditional on pCity:IsBuildingSellable and not-puppet, so
-- a non-sellable entry lands the user on a drill-in with just Back. The
-- sell-confirm modal speaks the engine's own TXT_KEY_SELL_BUILDING_INFO
-- so blind and sighted players see / hear the same confirmation text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "Budynki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "Brak budynków."
-- Specialists sub-handler (ss3.6). One item per slot across specialist-
-- capable buildings. Labels use labelFn so Enter-driven add/remove flips
-- the "empty" / "filled" suffix on the next navigate without rebuilding.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "Specjaliści"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "Brak slotów dla specjalistów."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] = "{1_Building} {2_Specialist} slot {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "puste"
-- _FILLED_STATE substitutes into SPECIALIST_SLOT's {4_State} as the
-- in-list state token. _FILLED is the standalone confirmation spoken on
-- Enter when an unfilled slot just became filled. Two keys with identical
-- value so each can move independently if a future tense / particle
-- requires divergent forms in the target language.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "wypełnione"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "wypełnione"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "niewypełnione"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] =
    "wypełnione, pracownik zwolniony z pola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] =
    "niewypełnione, pracownik przypisany do pola"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "nie można dodać specjalisty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "Ręczne zarządzanie specjalistami, {1_State}"
-- Great works sub-handler (ss3.12). One item per great-work slot, grouped by
-- building in label. Slot-type label is the work category ("art", "writing",
-- "music"), not the great-person class, because that's what occupies the
-- slot and what the player reasons about. Synthetic theming-bonus entry
-- per building when the bonus is non-zero -- label carries the bonus magnitude
-- and engine's theming tooltip text so the rule is audible inline.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "Wielkie dzieła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "sztuka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "pismo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "muzyka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} slot {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} slot {3_N}, puste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} bonus tematyczny plus {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "Brak slotów wielkich dzieł."
-- Production queue sub-handler (ss3.1). Slot 1 is the currently-producing
-- item, so its announcement carries the production meter percent; slots 2+
-- only have name + turns. Processes (ORDER_MAINTAIN) have no turns line.
-- Drill-in moves and removes via GAMEMESSAGE_SWAP_ORDER / _POP_ORDER.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "Kolejka produkcji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "Kolejka pusta."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    one = "Slot 1, {1_Name}, {2_Turns} tura, {3_Percent} procent. {4_Help}",
    few = "Slot 1, {1_Name}, {2_Turns} tury, {3_Percent} procent. {4_Help}",
    many = "Slot 1, {1_Name}, {2_Turns} tur, {3_Percent} procent. {4_Help}",
}
-- _TRAIN_INFINITE fires for buildable items (units / buildings / wonders)
-- whose remaining turns cannot be estimated from the current production
-- rate (typical for queued slots 2+ where the city has not yet started
-- accumulating progress towards the item). _PROCESS fires for
-- ORDER_MAINTAIN entries (Wealth, Research, Faith, Defense) that have no
-- completion turn or progress meter at any slot because they are
-- perpetual conversions, not buildable items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "Slot 1, {1_Name}, {2_Percent} procent. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "Slot 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    one = "Slot {1_N}, {2_Name}, {3_Turns} tura. {4_Help}",
    few = "Slot {1_N}, {2_Name}, {3_Turns} tury. {4_Help}",
    many = "Slot {1_N}, {2_Name}, {3_Turns} tur. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "Slot {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "Slot {1_N}, {2_Name}"
-- Slot-specific remaining figure: substitutes for the helper's
-- "[ICON_PRODUCTION] Cost: X" line. Slot 2+ shows full needed; the head
-- slot subtracts whatever the engine has accumulated. The
-- [ICON_PRODUCTION] adjacent to "Production" collapses through the
-- TextFilter dedup so the screen reader hears "Production remaining: N".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "[ICON_PRODUCTION] Pozostała produkcja: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "Akcje dla {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "Przesuń w górę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "Przesuń w dół"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "Usuń z kolejki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "Wróć"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "przesunięto w górę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "przesunięto w dół"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "usunięto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "Tryb kolejki, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "Wybierz produkcję"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "Kup za złoto lub wiarę"
-- Hex map sub-handler (ss3.2). Arrow keys walk the cursor across the city's
-- own tile, its workable ring, and purchasable tiles. Tile announcement
-- composes yield line, worked-state word, buy cost, and PlotComposers.glance.
-- Enter over a workable ring plot issues TASK_CHANGE_WORKING_PLOT; over an
-- affordable purchasable plot issues SendCityBuyPlot; over an unaffordable
-- purchasable plot speaks "cannot afford" without sending.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Zarządzaj terytorium"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "zarządzanie terytorium"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "uprawiane"
-- "Pinned" = IsForcedWorkingPlot: a worker is here AND the citizen manager
-- won't pull them off. Vanilla's visual is a star/pin icon, so the metaphor
-- matches. Pressing Enter on a "not worked" tile lands here in one step --
-- the engine's TASK_CHANGE_WORKING_PLOT both assigns and forces in a single
-- task, same as a mouse left-click.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "przypięte"
-- BLOCKED: tile cannot be worked at all (enemy unit on it, foreign
-- territory, or otherwise outside the city's reachable working set).
-- NOT_WORKED: workable in principle but no citizen is currently assigned
-- (an Enter press here triggers TASK_CHANGE_WORKING_PLOT to assign one).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "zablokowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "nieuprawiane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "do kupienia, {1_Gold} złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "do kupienia, {1_Gold} złoto, nie stać"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "nie stać"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "Przesuń kursor po polach miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "Uprawiaj lub kup pole"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Wróć do centrum miasta"
-- Ranged strike sub-handler (ss3.5). Hub item closes the city screen, enters
-- INTERFACEMODE_CITY_RANGE_ATTACK, and pushes a target picker. Cursor moves
-- freely via Baseline's QAZEDC; Space speaks a strike-specific preview
-- (target identity if in range, "cannot strike" otherwise); Enter commits
-- with a "fired" confirmation. Exit (commit, cancel, or external pop)
-- returns to the world map -- the city screen does not re-open.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "Atak na odległość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "atak na odległość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "nie można zaatakować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "wystrzelono"
-- City-attacker damage preview. Mirrors the unit ranged preview shape
-- ("{name}, {my} vs {theirs}, ..."): the cursor already spoke the target
-- tile's full info, so this only names what is being shot at and the
-- engine-computed strengths and damage. No verdict (cities don't get
-- GetCombatPrediction) and no retaliation (city ranged is one-way).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Dmg} obrażeń dla nich"
-- Gift-unit / gift-improvement target picker (audit ss7.7). Pushed from
-- the city-state diplo popup when the user chooses Gift > Unit or Gift >
-- Improvement; the engine's INTERFACEMODE_GIFT_UNIT and INTERFACEMODE_
-- GIFT_TILE_IMPROVEMENT are hex-click-only modes with no engine keyboard
-- path. Cursor moves freely via Baseline; Space speaks legality + plot
-- glance; Enter commits (gift-unit chains into BUTTONPOPUP_GIFT_CONFIRM,
-- gift-improvement calls Game.DoMinorGiftTileImprovement directly).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "podarunek jednostki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "podarunek ulepszenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "ulepszenie przekazane"
-- Rename / Raze hub items (ss3.13, ss3.14). Rename fires BUTTONPOPUP_RENAME_CITY,
-- whose accessibility is handled by SetCityNameAccess. Raze fires the Yes/No
-- confirmation popup (BUTTONPOPUP_CONFIRM_CITY_TASK with TASK_RAZE), handled
-- by GenericPopupAccess. Unraze is a direct Network.SendDoTask -- no popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "Przemianuj miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "Zniszcz miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "Zatrzymaj niszczenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "niszczenie zatrzymane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_TOO_SHORT"] = "Nazwa musi mieć co najmniej 3 znaki. Anulowano."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_INVALID_CHARS"] = "Nazwa zawiera niedozwolone znaki. Anulowano."
-- Foreign / spy-screen refusals. Spying on a foreign city opens CityView
-- in viewing mode (UI.IsCityScreenViewingMode true and / or owner not the
-- active player). Vanilla disables every write surface; we surface the same
-- items but speak a refusal on press so a blind player hears why nothing
-- happened. The HEX_PURCHASABLE_FOREIGN variant strips the gold cost from
-- the buy-cost line because that number is mod-authored intel vanilla
-- doesn't show on the espionage view.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "szpiegostwo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] =
    "przełączanie miast niedostępne podczas szpiegowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "nie możesz strzelać z miasta, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "nie możesz zmieniać produkcji w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "nie możesz uprawiać pól w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] =
    "nie możesz kupować pól w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] =
    "nie możesz sprzedawać budynków w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] =
    "nie możesz zmieniać fokusu w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "nie możesz zarządzać specjalistami w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "nie możesz przeglądać wielkich dzieł w mieście, którego nie posiadasz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "nie możesz przydzielać obywateli w mieście, którego nie posiadasz"

-- ===== ingame_batch_07.lua =====
-- Batch 07 (lines 1450-1670): cityview / pedia

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "do kupienia"

-- Reveal-announce
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_COUNT"] = {
    one = "{1_Num} pole odkryte",
    few = "{1_Num} pola odkryte",
    many = "{1_Num} pól odkrytych",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "Odkryto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "Wrogowie: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "Jednostki: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "Miasta: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "Zasoby: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "Ukryto"

-- Foreign-unit watch
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] = "Nowe wrogie jednostki w zasięgu wzroku: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] = "Wrogie jednostki opuściły zasięg wzroku: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] =
    "Nowe neutralne jednostki w zasięgu wzroku: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] =
    "Neutralne jednostki opuściły zasięg wzroku: {1_List}"

-- Foreign-clear watch
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "Inna cywilizacja przejęła "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " i "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    one = "{1_Num} widoczny obóz barbarzyńców",
    few = "{1_Num} widoczne obozy barbarzyńców",
    many = "{1_Num} widocznych obozów barbarzyńców",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    one = "{1_Num} widoczne starożytne ruiny",
    few = "{1_Num} widoczne starożytne ruiny",
    many = "{1_Num} widocznych starożytnych ruin",
}

-- Gone-on-revisit
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "Zniknęło"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    one = "obóz barbarzyńców",
    few = "{1_Num} obozy barbarzyńców",
    many = "{1_Num} obozów barbarzyńców",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    one = "starożytne ruiny",
    few = "{1_Num} starożytne ruiny",
    many = "{1_Num} starożytnych ruin",
}

-- Turn lifecycle speech
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "Tura zakończona"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "zakończenie tury anulowano"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control plus spacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] =
    "Zakończ turę lub ogłoś i otwórz pierwsze zdarzenie blokujące"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Control plus Shift plus spacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "Zakończ turę pomijając monit o jednostkach bez rozkazów; inne zdarzenia blokujące nadal są ogłaszane i otwierane"

-- Empire status readouts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "{1_Num} powyżej limitu jednostek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    one = "{1_Turns} tura do {2_Tech}, nauka +{3_Rate}",
    few = "{1_Turns} tury do {2_Tech}, nauka +{3_Rate}",
    many = "{1_Turns} tur do {2_Tech}, nauka +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} ukończona, nauka +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "brak badań, nauka +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "nauka wyłączona"

-- Plural driven by {4_Avail}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    one = "+{1_Rate} złota, {2_Total} łącznie, {3_Used} z {4_Avail} szlaku handlowego",
    few = "+{1_Rate} złota, {2_Total} łącznie, {3_Used} z {4_Avail} szlaków handlowych",
    many = "+{1_Rate} złota, {2_Total} łącznie, {3_Used} z {4_Avail} szlaków handlowych",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    one = "minus {1_Rate} złota, {2_Total} łącznie, {3_Used} z {4_Avail} szlaku handlowego",
    few = "minus {1_Rate} złota, {2_Total} łącznie, {3_Used} z {4_Avail} szlaków handlowych",
    many = "minus {1_Rate} złota, {2_Total} łącznie, {3_Used} z {4_Avail} szlaków handlowych",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "brak {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_STILL_PLAYING"] = "jeszcze grają: {1_Names}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"

-- Section labels for Shift+letter detail readouts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "Złota era"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "Religie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "Wielcy ludzie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "Wpływy"

-- Empire status readout payloads
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} szczęścia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "niezadowolenie minus {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "bardzo niezadowolone minus {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    one = "złota era, {1_Turns} tura",
    few = "złota era, {1_Turns} tury",
    many = "złota era, {1_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "{1_Cur} z {2_Threshold} do złotej ery"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "szczęście wyłączone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} wiary, {2_Total} łącznie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "religia wyłączona"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "{1_Num} wiary do następnego panteonu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "brak dostępnych panteonów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "{1_Num} wiary do następnego wielkiego proroka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "+{1_Pct}% kosztu technologii za każde miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "+{1_Pct}% kosztu instytucji za każde miasto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    one = "+{1_Rate} kultury, {2_Turns} tura do instytucji",
    few = "+{1_Rate} kultury, {2_Turns} tury do instytucji",
    many = "+{1_Rate} kultury, {2_Turns} tur do instytucji",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "+{1_Rate} kultury, brak dostępnych instytucji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] =
    "brak kultury, {1_Cur} z {2_Cost} do następnej instytucji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "instytucje wyłączone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} turystyki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    one = "+{1_Rate} turystyki, wpływ na {2_Count} cywilizację",
    few = "+{1_Rate} turystyki, wpływ na {2_Count} cywilizacje",
    many = "+{1_Rate} turystyki, wpływ na {2_Count} cywilizacji",
}
-- Plural driven by {3_Total}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    one = "+{1_Rate} turystyki, wpływ na {2_Count} z {3_Total} cywilizacji",
    few = "+{1_Rate} turystyki, wpływ na {2_Count} z {3_Total} cywilizacji",
    many = "+{1_Rate} turystyki, wpływ na {2_Count} z {3_Total} cywilizacji",
}

-- Help-overlay entries for empire status readout keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "Tura i data; limit jednostek gdy przekroczony; braki zasobów strategicznych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "Aktualne badania i nauka na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "Złoto na turę, łącznie i szlaki handlowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "Szczęście imperium, liczba luksusów zapewniających szczęście i złota era"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "Wiara na turę i łącznie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] = "Kultura na turę i czas do następnej instytucji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] =
    "Turystyka na turę i liczba cywilizacji pod wpływem"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Shift plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "Szczegółowe źródła nauki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Shift plus G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] =
    "Szczegółowe źródła dochodów i wydatki złota"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Shift plus H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "Źródła szczęścia, źródła niezadowolenia i efekt złotej ery"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Shift plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "Szczegółowe źródła wiary i czas do wielkiego proroka lub panteonu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Shift plus P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "Szczegółowe źródła kultury"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Shift plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "Wielkie dzieła, puste miejsca i liczba cywilizacji pod wpływem"

-- Task list readout
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Shift plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "Odczytaj aktywne zadania scenariusza"

-- GameMenu tab labels and mod-list payloads
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "Akcje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Mody"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "Brak aktywnych modów."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, wersja {2_Version}"

-- Civilopedia strings
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "Kategorie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "Zawartość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "Brak tekstu artykułu."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "Brak zawartości dla tego wpisu."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "Nie wybrano wpisu. Przejdź do karty kategorii, aby wybrać jeden."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "Wstęp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "Początek historii."

-- ===== ingame_batch_08.lua =====
-- Batch 08 (lines 1671-1853): pedia help, techtree

-- Pedia / AdvisorInfo history navigation
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "Koniec historii."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "Poprzedni lub następny artykuł w historii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] =
    "Poprzednia lub następna koncepcja w historii"

-- SaveMenu
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "Zapisy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "Szczegóły zapisu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "Brak zapisów na tej liście."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "Nazwa zapisu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] = "Nazwa zapisu jest pusta lub zawiera niedozwolone znaki."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "Nadpisz ten zapis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "Zapisz w tym slocie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "Nadpisać {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] = "Nadpisać slot Steam Cloud {1_Num}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "Usunąć {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "Zapis usunięty."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Slot Steam Cloud {1_Num}: pusty"

-- Icon spoken replacements
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "żywność"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "produkcja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "kultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "nauka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "nauka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "wiara"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "turystyka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "wielki człowiek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "wielki człowiek"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "Pkt. wiel. artysty:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "Pkt. wiel. inżyniera:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "Pkt. wiel. kupca:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "Pkt. wiel. naukowca:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "wielkie dzieło"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "siła bojowa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = "Siła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "siła ostrzału"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = "siła ostrzału"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "ruch"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "zadowolenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "zadowolenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "niezadowolenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "niezadowolenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "lewo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "prawo"

-- ChooseProduction popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "Wybierz produkcję"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "Produkuj"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "Kup"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "Bieżąca kolejka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "marionetka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "dodano, slot {1_Slot} w kolejce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "kolejka pełna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "kolejka jest pusta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "w kolejce {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    one = "{1_Num} tura",
    few = "{1_Num} tury",
    many = "{1_Num} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} złota"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} wiary"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "budujemy {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "kupiono {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    one = "{1_Name}, {2_Turns} tura",
    few = "{1_Name}, {2_Turns} tury",
    many = "{1_Name}, {2_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"

-- ChooseTech popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "Wybierz badanie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "darmowa technologia, pozostało {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "kradniemy od {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} nauki na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    one = "aktualnie badane {1_Name}, {2_Turns} tura",
    few = "aktualnie badane {1_Name}, {2_Turns} tury",
    many = "aktualnie badane {1_Name}, {2_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "darmowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "aktualnie badane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "w kolejce, slot {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    one = "{1_Num} tura",
    few = "{1_Num} tury",
    many = "{1_Num} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "Otwórz drzewko technologii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "badamy {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "uzyskano {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "skradziono {1_Name}"

-- Tech Tree screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "Drzewko technologii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "Wszystkie technologie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "Kolejka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "zbadane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "dostępne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "wymagania niespełnione"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "zablokowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "brak aktualnego badania, kolejka pusta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "aktualne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "dodano do kolejki: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "już zbadane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "niedostępne jako darmowa technologia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "nie można ukraść"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Góra/Dół/Lewo/Prawo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Góra/Dół w kolumnie epoki, Lewo/Prawo w wierszu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Prawo do zależnej technologii, Lewo do wymagania, Góra/Dół między sąsiednimi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] = "Przełącz nawigację: siatka lub drzewo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "siatka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "drzewo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "Badaj zaznaczoną technologię"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Shift plus Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "Dodaj zaznaczoną technologię do kolejki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Control plus I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "Otwórz wpis w Cywilopedii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "Litera / cyfra / spacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "Wpisz, aby wyszukać po nazwie lub odblokowaniach"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "Zamknij drzewko technologii"

-- ===== ingame_batch_09.lua =====
-- Batch 09 (lines 1854-2007): techtree, diplo

-- Tech Tree
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "Zamknij drzewo technologii"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "Instytucje społeczne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "Instytucje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "Ideologia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "otwarta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "ukończona"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "dostępna do przyjęcia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "zablokowana, wymaga {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] = "zablokowana, wymaga założonej religii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "zablokowana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "zablokowana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} z {2_Total} przyjętych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] =
    "otwierająca, przyznawana bezpłatnie przy otwarciu gałęzi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] =
    "zamykająca, przyznawana po ukończeniu gałęzi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "przyjęta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "dostępna do przyjęcia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "zablokowana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "zablokowana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "zablokowana, wymaga {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "otwórz {1_Branch}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] = "{1_Cur} z {2_Cost} kultury, {3_Per} na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    one = "{1_Turns} tura do następnej instytucji",
    few = "{1_Turns} tury do następnej instytucji",
    many = "{1_Turns} tur do następnej instytucji",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    one = "dostępna {1_Num} bezpłatna instytucja",
    few = "dostępne {1_Num} bezpłatne instytucje",
    many = "dostępnych {1_Num} bezpłatnych instytucji",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    one = "dostępny {1_Num} bezpłatny dogmat",
    few = "dostępne {1_Num} bezpłatne dogmaty",
    many = "dostępnych {1_Num} bezpłatnych dogmatów",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "ideologia jeszcze nie przyjęta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "ideologia wyłączona w tej grze"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "Dogmaty poziomu 1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "Dogmaty poziomu 2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "Dogmaty poziomu 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "slot {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "slot {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "slot {1_Num}, pusty, dostępny"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] = "slot {1_Num}, pusty, wymaga slotu {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "slot {1_Num}, pusty, wymaga slotu {3_Req} poziomu {2_Level}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] =
    "slot {1_Num}, pusty, niewystarczająca kultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "zmiana ideologii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "zmiana ideologii, niedostępna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "niezadowolenie {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "Wybierz dogmat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "brak dostępnych dogmatów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "Przyjąć {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "Otworzyć gałąź {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "Przyjąć {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "Zmienić ideologię?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "przyjęto {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "otwarto {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "przyjęto dogmat {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "wysłano prośbę o zmianę ideologii"

-- Number-entry primitive
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Cyfry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "Dodaj cyfrę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "Usuń ostatnią cyfrę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "Zatwierdź ilość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "podaj {1_Label}, maks. {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "puste"

-- Diplomacy trade screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "Handel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "Handel z {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "Twoja oferta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "Ich oferta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "Oferowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "Dostępne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, populacja {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "zobowiązanie głosowania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "zawrzyj pokój z {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "wypowiedz wojnę {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "Zawrzyj pokój"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "Wypowiedz wojnę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "Inni gracze"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "brak dostępnych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "stół jest pusty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "masz {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "mają {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "dajemy: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "dają: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "daliśmy: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "dali: {1_List}"

-- DiploCurrentDeals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "Umowy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "Historyczne umowy"

-- Diplomatic Overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader} z {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "punkty {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "złoto {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "złoto na turę {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "strategiczne: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "luksusowe: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "w pobliżu: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "bonusowe: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "instytucje: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "cuda świata: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "Wielkie cywilizacje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "Miasta-państwa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "Nie napotkano żadnych cywilizacji."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "Brak umów."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "przychodząca propozycja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "oczekiwanie na odpowiedź"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "drużyna {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "bada {1_Tech}"

-- ===== ingame_batch_10.lua =====
-- Batch 10 (lines 2008-2196): final pre-leader block

CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} wpływów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} na turę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "zakotwiczone na {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} kultury"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} szczęścia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} wiary"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} żywności w stolicy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} żywności w innych miastach"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} nauki"
-- Plural driven by {1_N} (turns until next gift unit arrives).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    one = "następna jednostka w prezencie za {1_N} turę",
    few = "następna jednostka w prezencie za {1_N} tury",
    many = "następna jednostka w prezencie za {1_N} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "eksport: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "otwarte granice"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "można zastraszyć"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "sojusznik {1_Civ}"

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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "twoje relacje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "stosunki zagraniczne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "zasoby"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "era"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "doktryny"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "cuda świata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "punkty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_DECLARE_WAR"] = "wypowiedz wojnę"
-- Minor civ columns. _RELATIONSHIP carries the bonuses currently flowing
-- from a Friends / Allies CS (culture, food, science, faith, happiness,
-- spawn estimate). _TRAIT_PERSONALITY carries trait then personality as a
-- thematic pair. Influence column carries value + per-turn + anchor +
-- threshold-gap to the next state. Allied-with carries the current ally
-- (or "nobody") plus displacement value. Quests and Nearby resources
-- carry their respective lists.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "relacje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "cecha i osobowość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "wpływy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "sojusznik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "zadania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "pobliskie zasoby"
-- Empty-cell labels. "none" for absent items in a list-shaped cell;
-- "nobody" for the Allied-with column where the absence is an actor, not
-- an item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "brak"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "nikt"
-- Gold cell: gold on hand plus per-turn rate. {2_GPT} carries its sign so
-- the same template covers gain and loss.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, {2_GPT} na turę"
-- Influence threshold gap fragments, appended after the value / per-turn /
-- anchor block in the Influence cell. _TO_FRIENDS shows when below friends
-- threshold; _TO_ALLIES shows when between thresholds.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "{1_N} potrzeba do przyjaźni"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "{1_N} potrzeba do sojuszu"
-- Allied-with cell variants. _ALLY_IS_YOU when we're the ally (no
-- displacement number to compute). _ALLY_AND_DISPLACE when someone else is
-- allied: civ short name plus the influence we'd need to gain over the
-- current ally.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "ty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, {2_N} potrzeba do wyparcia"
-- Unmet-ally variant: a civ we haven't met holds the alliance. The
-- displacement number is still meaningful (we know our own influence
-- and can read the engine's record of theirs) but we can't name them,
-- so the cell distinguishes from "nobody" (the genuine no-ally case)
-- with a generic civ word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] = "nieznana cywilizacja, {1_N} potrzeba do wyparcia"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "Plony"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "Religia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "Szlaki handlowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "Zasoby"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "brak szczegółowego podziału"
-- Storage / threshold tail appended to the food and culture yield rows.
-- Bare numerator-of-denominator since the row's headline already names
-- the resource ("food 5, 12 of 22, grows in 4 turns").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{1_Cur} z {2_Threshold}"
-- Culture's next-tile countdown. Borrowed by both the culture yield's
-- extras tail (CityStats) and the hex-cursor culture readout
-- (CitySpeech.borderGrowthToken); shared so the wording stays
-- consistent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    one = "następne pole za {1_Num} turę",
    few = "następne pole za {1_Num} tury",
    many = "następne pole za {1_Num} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "ekspansja granic wstrzymana"
-- Happiness one-liner: local-only contribution from buildings here, plus
-- the per-city slice of the empire's unhappiness pool (population /
-- occupied / specialists already folded in by the engine).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] =
    "lokalne szczęście {1_Local}, niezadowolenie {2_Unhappiness}"
-- Religion group: one row per religion present, holy-city flag inlined
-- when applicable so the user hears it together with that religion's
-- numbers rather than as a separate line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    one = "{1_Religion}, {2_Followers} wyznawca, {3_Pressure} presja",
    few = "{1_Religion}, {2_Followers} wyznawców, {3_Pressure} presja",
    many = "{1_Religion}, {2_Followers} wyznawców, {3_Pressure} presja",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    one = "{1_Religion}, święte miasto, {2_Followers} wyznawca, {3_Pressure} presja",
    few = "{1_Religion}, święte miasto, {2_Followers} wyznawców, {3_Pressure} presja",
    many = "{1_Religion}, święte miasto, {2_Followers} wyznawców, {3_Pressure} presja",
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
    one = "{1_Num} pole",
    few = "{1_Num} pola",
    many = "{1_Num} pól",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "Ty otrzymujesz {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "Oni otrzymują {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} otrzymuje {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} presja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "Brak prawidłowych celów."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "Brak prawidłowych miast bazowych."
-- Trade Route Overview (TRO) screen. Distinct from the per-pick
-- ChooseInternationalTradeRoutePopup above: TRO is the standalone Ctrl+T
-- screen that surveys every trade route currently active in the game.
-- Three tabs: Yours (your active routes), Available (routes you could
-- start but haven't), and With You (routes other civs run to your
-- cities). Domain words distinguish caravan (land) from cargo ship (sea).
-- ROUTE_HEADER carries five placeholders: domain word, source city, source
-- civ, destination city, destination civ.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Control plus T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "Otwórz przegląd szlaków handlowych"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "Twoje szlaki handlowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "Dostępne szlaki handlowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "Szlaki handlowe z tobą"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "karawana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "statek handlowy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} do {3_To}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "miasto-państwo {1_City}"
-- Plural driven by {1_Num} (turns until the route arrives at its
-- destination and resolves).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    one = "{1_Num} tura pozostała",
    few = "{1_Num} tury pozostały",
    many = "{1_Num} tur pozostało",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "Brak szlaków."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "Brak szczegółowego podziału źródła."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "Sortuj według: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "Sortuj według"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "otrzymane złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "otrzymana nauka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "otrzymana żywność"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "otrzymana produkcja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "presja religijna do celu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "Opisz przywódcę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "Brak opisu dla tego przywódcy."

-- ===== ingame_batch_11.lua =====
-- Batch 11 (lines 2283-2449): economic overview, victory progress

-- Economic Overview (F2 / Domestic Advisor): tab names, column labels,
-- group / row text consumed by CivVAccess_EconomicOverviewAccess.lua.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "Miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "Złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "Zadowolenie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "Zasoby"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "Populacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "Siła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "Żywność"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "Nauka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "Złoto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "Kultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "Wiara"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "Produkcja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "stolica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "marionetka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "okupowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "okupowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "brak wpisów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "brak produkcji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    one = "{1_Turns} tura: {2_Name}",
    few = "{1_Turns} tury: {2_Name}",
    many = "{1_Turns} tur: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "{1_PerTurn} na turę, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "Złoto łącznie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "Dochody, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "Wydatki, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "Netto na turę, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "Nauka utracona z powodu deficytu złota, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "Miasta, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "Dyplomacja, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "Religia, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "Połączenia miejskie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "Jednostki, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "Budynki, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "Ulepszenia, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "Dyplomacja, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "Zadowolenie łącznie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "Źródła zadowolenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "Luksusy, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "Różnorodność luksusów, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "Bonus za luksusy, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "Pozostałe bonusy luksusów, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "Zadowolenie z miast, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "Budynki, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "Zadowolenie z budynków, garnizonów, religii i synergii instytucji w każdym mieście. "
    .. "Ograniczone populacją miasta."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "Bonusy z cudów, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "Zadowolenie z cudów o specjalnych efektach: synergie klas budynków, "
    .. "niemodyfikowane zadowolenie lub bonusy za instytucje. Większość budynków "
    .. "zadowolenia wchodzi do sekcji Budynki (na miasto), nie tutaj."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "Bonusy w skali imperium, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "Szlaki handlowe, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "Miasta-państwa, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "Instytucje, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "Religia, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "Cuda natury, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "Bonusy za każde miasto, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "Zadowolenie z budynków lub instytucji dających stały bonus za każde posiadane miasto. "
    .. "Mnożone przez liczbę miast."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "Kongres Światowy, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "Poziom trudności, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "Niezadowolenie łącznie, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "Źródła niezadowolenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    one = "{1_Count} miasto, {2_Value} niezadowolenia",
    few = "{1_Count} miasta, {2_Value} niezadowolenia",
    many = "{1_Count} miast, {2_Value} niezadowolenia",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    one = "{1_Count} okupowane miasto, {2_Value} niezadowolenia",
    few = "{1_Count} okupowane miasta, {2_Value} niezadowolenia",
    many = "{1_Count} okupowanych miast, {2_Value} niezadowolenia",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    one = "{1_Count} obywatel, {2_Value} niezadowolenia",
    few = "{1_Count} obywatele, {2_Value} niezadowolenia",
    many = "{1_Count} obywateli, {2_Value} niezadowolenia",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    one = "{1_Count} okupowany obywatel, {2_Value} niezadowolenia",
    few = "{1_Count} okupowani obywatele, {2_Value} niezadowolenia",
    many = "{1_Count} okupowanych obywateli, {2_Value} niezadowolenia",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "Opinia publiczna, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "Podział na miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "Dostępne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "Używane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "Lokalne"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "Importowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_FROM_CITY_STATES"] = "Od państw-miast"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "Eksportowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "n/d"
-- Victory Progress (F8 / Who is winning): two-tab layout. Tab 1 is the
-- score table (one row per civ, columns from DiploList's score-breakdown
-- tooltip); Tab 2 is the victory-conditions menu (Time, Domination,
-- Science, Diplomatic, Cultural). Score column headers reuse engine
-- TXT_KEY_VP_CITIES / _POPULATION / _LAND / _WONDERS / _TECH /
-- _FUTURE_TECH / _POLICIES / _GREAT_WORKS / _RELIGION / _SCENARIO1-4
-- so only the Total header and row-state suffix are mod-authored.
-- Disabled-victory and tooltip sentence strings reuse engine TXT_KEY_VP_*
-- keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "Wynik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "Zwycięstwa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "Łącznie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, stolica utracona"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "Dominacja"

-- ===== ingame_batch_12.lua =====
-- Batch 12 (lines 2450-2638): league

CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "Nauka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "Dyplomacja"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "Kultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "drużyna {1_Num}"
-- Plural driven by {1_Num} (count of boosters built for the spaceship,
-- vanilla allows up to 3).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    one = "{1_Num} wspomagacz",
    few = "{1_Num} wspomagacze",
    many = "{1_Num} wspomagaczy",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "kabina pilota"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "komora kriogeniczna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "silnik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, Apollo nie zbudowany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, Apollo zbudowany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "Apollo zbudowany, brak części"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, Apollo zbudowany, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "Apollo zbudowany, {1_Parts}"
-- Plural is driven by {2_Total}: "1 of 1 prerequisite researched" vs
-- "1 of 5 prerequisites researched".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    one = "{1_Have} z {2_Total} wymaganie zbadane",
    few = "{1_Have} z {2_Total} wymagania zbadane",
    many = "{1_Have} z {2_Total} wymagań zbadanych",
}
-- Demographics (F9): one row per metric, speaking name, rank, the active
-- player's value, then rival best (with civ name), average, and worst
-- (with civ name) -- vanilla column order. Metric name and unmet-civ /
-- "you of <Civ>" fillers reuse engine TXT_KEYs so the format key stays
-- pure positional substitution.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, miejsce {2_Rank}, {3_Value}, najlepszy {4_BestCiv} {5_BestVal}, średnia {6_AvgVal}, najgorszy {7_WorstCiv} {8_WorstVal}"
-- Vanilla's TXT_KEY_DEMOGRAPHICS_GOLD label is "GNP", which spells out
-- letter-by-letter in TTS and tells a non-economist nothing. Mod-authored
-- override only -- the engine label stays "GNP" for sighted players.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "Produkt Narodowy Brutto"
-- Culture Overview (Ctrl+C). Four-tab popup: Your Culture (per-city GW
-- management with click-to-move/view toggle), Swap Great Works (designate
-- swappable + foreign-offerings list + send), Culture Victory (per-civ
-- influence/tourism/ideology/public-opinion), Player Influence
-- (perspective picker + per-target modifier breakdown / level / trend).
-- Most enum-derived strings (influence levels, trend, public opinion)
-- reuse engine TXT_KEY_CO_* keys directly so phrasing matches what
-- sighted players see; mod-authored keys here only cover row formats,
-- action labels, and our drill-in framing.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "Twoja kultura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "Wymiana arcydzieł"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "Zwycięstwo kulturowe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "Wpływy gracza"
-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] =
    "Miejsca wykopalisk: {1_Visible} widocznych, {2_Hidden} ukrytych"
-- Per-city label. {1_Name} already includes the capital/puppet/occupied
-- prefix when applicable (mirrors engine's CityDisplayName composition).
-- Plural is driven by {5_Total}: when the city has 1 great-work slot
-- ("1 of 1 great work") vs many ("3 of 5 great works").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    one = "{1_Name}, kultura {2_Cul}, turystyka {3_Tou}, arcydzieło {4_Filled} z {5_Total}",
    few = "{1_Name}, kultura {2_Cul}, turystyka {3_Tou}, arcydzieła {4_Filled} z {5_Total}",
    many = "{1_Name}, kultura {2_Cul}, turystyka {3_Tou}, arcydzieł {4_Filled} z {5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    one = "{1_Name}, kultura {2_Cul}, turystyka {3_Tou}, arcydzieło {4_Filled} z {5_Total}, uszkodzone {6_Pct} procent",
    few = "{1_Name}, kultura {2_Cul}, turystyka {3_Tou}, arcydzieła {4_Filled} z {5_Total}, uszkodzone {6_Pct} procent",
    many = "{1_Name}, kultura {2_Cul}, turystyka {3_Tou}, arcydzieł {4_Filled} z {5_Total}, uszkodzone {6_Pct} procent",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "stolica"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "marionetka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "okupowane"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "Brak budynków na arcydzieła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "Brak miast"
-- Slot type words. Used as a fixed phrase ("art or artifact slot") on the
-- building label so the user knows what kind of work fits before drilling.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "miejsce na piśmiennictwo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "miejsce na sztukę lub artefakt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "miejsce na muzykę"
-- Multi-slot building entry inside a city. Theming bonus shown when active.
-- Single-slot buildings collapse to one row (see CO_BUILDING_SINGLE_*).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled} z {4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled} z {4_Total}, bonus tematyczny plus {5_Bonus}"
-- Single-slot building rows. The building row is the slot; activation
-- runs the move state machine directly. No drill-in.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, puste"
-- Per-slot leaf inside a multi-slot building. Slot index is 1-based.
-- The slot-type word lives on the parent label, not repeated per leaf.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, puste"
-- Work-class words used inside the slot tooltip ("art by ...").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "piśmiennictwo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "sztuka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "artefakt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "muzyka"
-- Slot tooltip built from primitives. Replaces engine's GetGreatWorkTooltip
-- which packed fields together with no labels and stripped icons.
--
-- Three forms by work class:
--   AUTHORED -- art works (Museum/Cathedral/Palace etc. slot type is
--     ART_ARTIFACT and accepts either kind, so the class word disambiguates).
--   NOCLASS  -- writing and music. Their slot types (LITERATURE, MUSIC) only
--     accept that one class, so the parent row's slot-type word already
--     conveys it; repeating the class would just double up.
--   ARTIFACT -- archaeology works. No human author; class word kept because
--     ART_ARTIFACT slots are ambiguous and need to distinguish from art.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class} autora {2_Artist}, {3_OriginCiv}, {4_Era}, plus {5_Cul} kultury, plus {6_Tou} turystyki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "autor {1_Artist}, {2_OriginCiv}, {3_Era}, plus {4_Cul} kultury, plus {5_Tou} turystyki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, plus {4_Cul} kultury, plus {5_Tou} turystyki"
-- GW move flow feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "oznaczone jako źródło przeniesienia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "przeniesione"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "źródło przeniesienia wyczyszczone"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] = "błędny typ miejsca dla wybranego źródła"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "nie można przenieść z pustego miejsca"
-- Tab 2 (Swap Great Works). Three top-level rows: your offerings (drills
-- into per-type pulldowns), available from other civs (drills into civ
-- groups, then into each civ's non-empty slots), trade item with state-
-- aware label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "Twoje oferty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "Piśmiennictwo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "Sztuka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "Artefakt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "brak wskazania"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "Wyczyść wskazanie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "Dostępne od innych cywilizacji"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "Żadna cywilizacja nie oferuje arcydzieł do wymiany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "Brak arcydzieł do wymiany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] =
    "Wybierz arcydzieło od innej cywilizacji do wymiany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "Brak wskazanego {1_Type} do zaoferowania za {2_TheirName} z {3_TheirCiv}; wskaż jedno w swoich ofertach"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "Wymień swoje {1_YourName} za {2_TheirName} z {3_TheirCiv}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "wymiana wysłana"
-- Tab 3 (Culture Victory). BaseTable: row label is the civ short name,
-- columns expose the engine's seven-column victory data. Public Opinion and
-- Public Opinion Unhappiness cells append the engine's breakdown tooltip.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N} z {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "brak ideologii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "brak opinii publicznej"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "Wpływanie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "Turystyka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "Ideologia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "Opinia publiczna"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] = "Niezadowolenie z opinii publicznej"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "Nadmiar zadowolenia"
-- Tab 4 (Player Influence). BaseTable: row label is the row civ's display
-- name, columns are the engine's six. Column 1 ("Change perspective") folds
-- the engine's perspective picker plus the perspective's overall-tourism
-- header into per-row cells: each cell carries that civ's overall tourism
-- generation, and Enter switches g_iSelectedPlayerID. Other column tooltips
-- surface the engine's breakdowns (modifier, influence percent decomposition,
-- bonuses-at-level callout, estimated turns to Influential).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    one = "szacunkowo {1_N} tura do wpływowych",
    few = "szacunkowo {1_N} tury do wpływowych",
    many = "szacunkowo {1_N} tur do wpływowych",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "Zmień perspektywę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "Poziom wpływów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "Procent wpływów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "Modyfikator turystyki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "Turystyka na nich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "Trend"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "generuje {1_N} turystyki na turę, naciśnij Enter, aby przejść do tej perspektywy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] = "teraz oglądasz z perspektywy {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N} procent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "twoja turystyka {1_Yours} wobec ich kultury dorobkowej {2_Theirs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N} procent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "spada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "bez zmian"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "rośnie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "rośnie powoli"
-- Hotkey help (BaselineHandler / map-mode help list).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "Otwórz Przegląd kultury"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] = "Przegląd kultury jest wyłączony w tej grze"
-- League Overview (World Congress / United Nations). TabbedShell over the
-- engine's BUTTONPOPUP_LEAGUE_OVERVIEW: tab 1 status / members, tab 2 current
-- proposals (View / Propose / Vote modes), tab 3 ongoing effects.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "Kongres Światowy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control plus L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "Otwórz przegląd Kongresu Światowego"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "Status"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "Propozycje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "Efekty"

-- ===== ingame_batch_13.lua =====
-- Batch 13 (lines 2639-2872): league members, religion, in-game chat

-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "Zmień nazwę"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(ty)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "gospodarz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    one = "{1_N} delegat",
    few = "{1_N} delegaci",
    many = "{1_N} delegatów",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "może zgłaszać"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "Dyplomata w ich stolicy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "Brak Kongresu Światowego"

-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "Brak dostępnych działań w tej sesji."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    one = "{1_N} wniosek dostępny.",
    few = "{1_N} wnioski dostępne.",
    many = "{1_N} wniosków dostępnych.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    one = "{1_N} delegat nieprzydzielony.",
    few = "{1_N} delegaci nieprzydzieleni.",
    many = "{1_N} delegatów nieprzydzielonych.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "Brak wniosków w tej sesji."

-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "Uchwal: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "Uchyl: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "Zgłoszone przez {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "Zgłoszone przez ciebie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "Wstrzymane"

-- Vote-state suffix appended to proposal row in Vote mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "twój głos: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "wstrzymaj się"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    one = "{1_N} za",
    few = "{1_N} za",
    many = "{1_N} za",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    one = "{1_N} przeciw",
    few = "{1_N} przeciw",
    many = "{1_N} przeciw",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} za {2_Civ}"

-- Slot picker (Propose mode).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "Pusty slot wniosku {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "Slot {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "Slot wniosku {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "Aktywne rezolucje do uchylenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "Rezolucje do uchwalenia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "Inne rezolucje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] =
    "Nasza szacunkowa liczba głosów za tym wnioskiem:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] = "Cywilizacje, które zatwierdzą: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] = "Cywilizacje, które się sprzeciwią: {1_Civs}"

-- Religion Overview.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control plus R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "Otwórz przegląd religii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "Jesteś założycielem {1_Religion}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "dogmat {1_Type}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    one = "{1_Religion}, święte miasto {2_HolyCity}, założono przez {3_Founder}, {4_NumCities} miasto",
    few = "{1_Religion}, święte miasto {2_HolyCity}, założono przez {3_Founder}, {4_NumCities} miasta",
    many = "{1_Religion}, święte miasto {2_HolyCity}, założono przez {3_Founder}, {4_NumCities} miast",
}

-- Espionage Overview (BNW only).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Control plus E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "Otwórz przegląd szpiegostwa"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "Agenci"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "Miasta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "Intrygi"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "Szpiegostwo jest wyłączone w tej grze"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    one = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} tura",
    few = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} tury",
    many = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} tur",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} poległ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", dyplomata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "Działania {1_Rank} {2_Name}"

-- City row pieces.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "cywilizacja {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "miasto {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "populacja {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "potencjał {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "potencjał bazowy {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "szczegóły: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "potencjał nieznany"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] =
    "miasto-państwo, wybory można sfałszować"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] = "miasto-państwo, trwa fałszowanie wyborów"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "agent {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "dyplomata {1_Name}"

-- Intrigue row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "Tura {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "od twojego szpiega {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "przekazano przez {1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "nieznane"

-- Move-agent sub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "Przesuń {1_Rank} {2_Name}"

-- Bookmarks.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "zakładka dodana"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "brak zakładki"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Control plus klawisz cyfry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] =
    "Zapisz zakładkę w odpowiednim slocie w miejscu kursora"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Shift plus klawisz cyfry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "Przejdź kursorem do zakładki w danym slocie, cofasz się klawiszem Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt plus klawisz cyfry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "Odległość i kierunek od kursora do zakładki w danym slocie"

-- Beacons.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "aktywowano sygnał {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "dezaktywowano sygnał {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] = "najpierw zapisz zakładkę w tym slocie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] = "Control plus Shift plus klawisz cyfry"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "Włącz lub wyłącz sygnał dźwiękowy przy zakładce w danym slocie"

-- Message buffer.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "Wszystkie wiadomości"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "Powiadomienia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "Odkrycia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "Walka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "Czat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "brak wiadomości"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "Lewy nawias i prawy nawias"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "Poprzednia i następna wiadomość w buforze"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] = "Control plus lewy nawias i prawy nawias"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] = "Najstarsza i najnowsza wiadomość w buforze"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] = "Shift plus lewy nawias i prawy nawias"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "Przełącz kategorię filtru bufora, pomijając puste kategorie"

-- Multiplayer chat.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Lewy ukośnik"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] =
    "Otwórz panel czatu w grze wieloosobowej, bez efektu w trybie jednoosobowym"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "Czat jest dostępny tylko w trybie wieloosobowym"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "Czat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "Wiadomości"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "Napisz"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "Wiadomość"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "Brak wiadomości w czacie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} do zespołu: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} do {2_To}: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "Lewy ukośnik lub Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "Zamknij panel czatu"

-- ===== leader-prose placeholders (English baseline; merged later) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "George Washington, pierwszy prezydent Stanów Zjednoczonych, stoi w boazeriowanym wnętrzu między ciężkimi czerwonymi kotarami rozchylonymi po obu stronach, ręce trzyma swobodnie przy biodrach. Ubrany jest w czarny strój cywilny amerykańskiego dżentelmena z końca osiemnastego wieku: ciemny dwurzędowy surdut skrojony długo nad udami, z dwoma rzędami mosiężnych guzików z przodu, pasujący do niego żakiet pod spodem, biały jabot z falbaną przy szyi i białe mankiety przy nadgarstkach. Włosy upudrowane na biało, zaczesane do tyłu od wysokiego czoła, zakręcone po bokach nad uszami i zebrane z tyłu w warkocz przewiązany czarną jedwabną wstążką. Po jego lewej stronie duży globus ziemski spoczywa na toczonej drewnianej podstawie; na małym stoliku obok stoi otwarta oprawna księga z niebieską zakładką zwisającą z kart. Po prawej stronie na jasnym kamiennym kominku stoi wysoki mosiężny świecznik z nieopalonymi świecami, a nad nim wisi w złoconej ramie pejzaż. Między rozchylonymi kotarami za jego plecami flankowana kolumna wznosi się na tle rozjaśnionego nieba, za którą widać ułamek falistego, zielonego kraju. Kompozycja przywołuje portret z Lansdowne pędzla Gilberta Stuarta z 1796 roku, w którym ceremonialny miecz i dokumenty państwowe zastąpiono globusem i księgą."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "Harun ar-Raszid, Wódz Wiernych i piąty kalif Abbasydów, siedzi w ogrodzie pałacowym w późny poranek; brukowany dziedziniec za jego plecami otwiera się na jasny kamienny portyk ostrołukowych arkad, a gdzieś w oddali przez mgłę wyłania się kopuła. Ma brodę i ciemne włosy, siedzi na niskim rzeźbionym drewnianym krześle, którego poręcze kończą się zaokrąglonymi kulami; głowę owija wysoki szafranowy turban z miękką czapeczką na szczycie. Szeroka szarfa z tej samej szafranowej tkaniny, z końcami haftowanymi i obramowanymi złotą frędzlą, przewija się przez pierś od prawego ramienia i zbiera przy lewym biodrze, nakładając się na luźną białą szatę opadającą do kostek, której rąbek obszyty jest tym samym złotym brokatem. Prawa dłoń uniesiona przy ramieniu trzyma qalam - arabski trzcinowy pióropusz - między kciukiem a wskazującym; lewa dłoń spoczywa płasko na kolanach. Stopy opiera na okrągłym dywanie tkanym w niebieskie, kremowe i rdzawe medaliony, a na płytach chodnikowych obok leżą dwa oprawione kodeksy, z których wierzchni ma głęboczerwone deski toolowane złotem. Po obu stronach krzesła stoją w glazurowanych niebieskich misach doniczkowe sagowce i paprocie, po prawej wznosi się wysoki wazon z terakoty, a ciemne żywopłoty zamykają przestrzeń w głębi pod arkadą."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "Aszurbanipal, Król Świata, Król Asyrii, stoi w kolumnowej sali swojego pałacu, trzymając prawą ręką jasną kamienną tabliczkę opartą pionowo o pierś, z palcami zaciśniętymi na jej górnej krawędzi. Ma szerokie ramiona i gołe ramiona, skóra ciepło jarzy się w świetle. Broda długa i kwadratowo przycięta, ułożona w ciasne równoległe loki sięgające piersi, czarne włosy opadają w podobnych pierścieniach na ramiona. Niski złoty diadem okrąża czoło, jego obwód zdobiony rozetami. Odziany jest w sięgającą kostek królewską szatę dworską Asyrii: ciemnoniebieską suknię podszytą złotymi rozetami, przykrytą ciężkim szkarłatnym płaszczem, którego frędzlowany brzeg biegnie ukośnie przez tors, przez lewe ramię i w dół pleców, a rąbki obszyto złotym i czerwonym haftem. Szerokie złote bransolety spinają oba nadgarstki, a podobna opaska okrąża jego prawe ramię. Za nim wznosi się łukowa nisza oprawiona w smukłe kolumny z jasnymi wolutowymi kapitelami; po obu stronach, na cokolikach, stoją ciemnobrodze figury lamassu - uskrzydlonych byków o ludzkich głowach, strzegących bram asyryjskich pałaców. Na tylnej ścianie płytkie kamienne reliefy ukazują konie z profilu w poziomym rejestrze, wzorowane na panelach myśliwskich i rydwanowych jego pałacu w Niniwie. Podłoga wyłożona jest jasną terakotą, a sala gubi się w cieniu po obu stronach."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "Maria Teresa, z Łaski Bożej cesarzowa-wdowa Rzymian, królowa Węgier, Czech, Dalmacji, Chorwacji, Sławonii, Galicji, Lodomerii, arcyksiężna Austrii (i tak dalej, i tak dalej), stoi na arkadowej kamiennej loggii - krytej galerii, której wysokie okrągłe arkady z jednej strony otwierają się na alpejski krajobraz ośnieżonych szczytów, z drugiej zaś na wypolerowaną podłogę z czerwonym chodnikiem wzdłuż kolumnady. Czerwone tkaniny adamaszkowe zwisają między arkadami na wewnętrznej ścianie, a słoneczne światło z lewej rzuca długie cienie na kamień. Stoi w ujęciu trzy czwarte, ramiona skrzyżowane lekko w talii, głowa delikatnie odwrócona. Włosy jasnoplate, zaczesane do tyłu i wysoko upięte w dworskim stylu. Suknia z bladoniebiesko-szarego jedwabiu; gorset ciasno sznurowany do szpica w talii i ozdobiony przyszytym przodem - sztywną dekorowaną płytką haftowaną srebrem i drobnymi klejnotami. Szeroka spódnica na fiszbinach rozchyla się nad panierek, ten sam srebrny haft biegnie w opadającym pasie wzdłuż otwartego przodu wierzchniej spódnicy. Rękawy kończą się przy łokciach krótkimi bufkami obszytymi białą koronką. Przeźroczysta koronkowa chusteczka złożona jest na ramionach i zatknięta w dekolt. Nie nosi korony ani widocznych klejnotów. Za jej plecami arkady oddalają się w jasnym kamieniu, balustrada z toczonych słupków biegnie w dal, Alpy jasno błyszczą, a niebo jest bezchmurne."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "Montezuma Xocoyotzin, Huey Tlatoani Meksykanów, stoi przed wielkim paleniskiem, którego płomienie wznoszą się między nim a patrzącym, a cała sala oświetlona jest jedynie tym ogniem. Ma nagą pierś i masywną budowę ciała, skóra ciemna w łunie ognia, twarz w połowie skryta w cieniu. Jego korona to quetzalapanecayotl - grzebień z długich opalizujących piór ogonowych quetzala w zieleni i błękicie, spięty złotą opaską na czole. Złote szpule przekłuwają uszy, kołnierz z jadeitu i złota okrąża szyję, szerokie bransolety z jadeitu i złota spajają nadgarstki, a złote opaski okrążają każdy biceps. Za nim, wmurowany w ścianę z czerwonej cegły, wielki rzeźbiony krąg ukazuje koncentryczne pasy glifów wokół centralnej twarzy - wzorowane na azteckim Kamieniu Słońca. Boczne ściany pokryte są rzeźbionymi rzędami stylizowanych czaszek - tzompantli, czyli stelaż czaszek wystawianych w azteckich świątyniach; nad każdym stelaże wznosi się duża rzeźbiona maska azteckiego bóstwa, a kamienny wazon u szczytu każdej ściany płonie wysokim płomieniem. Cała sala jarzy się w czerwieni i złocie łuny ognia."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "Nabuchodonozor II, Król Babilonu, siedzi na masywnym kamiennym tronie w sali z zielono oświetloną murarką, której ściany za jego plecami giną w mroku. Nosi agu - wysoką zaokrągloną czapkę nowowavilońskich królów, przepasaną opaską na czole. Broda długa, ciemna, ułożona w piętrowe rzędy ciasnych cylindrycznych loków. Szata głębokoczerwona, krótkorękawna, pokryta w równych odstępach złotymi rozetami, przepasana w talii szeroką haftowaną szarfą; spódnica opada prosto do bosych stóp, obszyta pasem bladej frędzli. Ciężkie złote bransolety spinają oba nadgarstki. Dłonie spoczywają wewnętrzną stroną na szerokich poręczach tronu, które od przodu kończą się rzeźbionymi wsporniczkami w kształcie lwich głów - warczące paszcze zwrócone na zewnątrz na wysokości kolan; mniejsza para podobnych lwich głów wystaje z podstawy tronu przy jego stopach. Po obu stronach tronu stoją dwa wysokie kamienne cokołki rzeźbione w spiralne wężowe cielska, każdy zwieńczony szeroką, płytką misą, z której unosi się blady zielony płomień - jedyne światło w komnacie, rzucające chorobliwą zieleń na kamienne ściany, twarz i szatę."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "Dom Pedro II, cesarz Brazylii, siedzi przy szerokim drewnianym biurku w ciemnym, boazeriowanym gabinecie; ujęcie skomponowane jest tak, jakby patrzący stał naprzeciwko niego po drugiej stronie biurka. Jest starszym mężczyzną, barczystym i tęgim, z gęstą białą brodą opadającą znacznie poniżej kołnierzyka i rzednącymi białymi włosami zaczesanymi do tyłu od wysokiego czoła. Nosi ciemny surdut na ciemnym żakiecie i białą koszulę z wysokim kołnierzem, przy szyi ciemna krawata. Przy lewej piersi przypięta jest klejnotami gwiazdą Cesarskiego Orderu Krzyża Południa, którego był Wielkim Mistrzem. Obie dłonie spoczywają płasko na biurku; przed nim leżą luźne kartki i mały kałamarz, a przy prawej dłoni w okrągłym stojaku tkwi pióro. Na biurku po lewej stronie stoi zapalona lampa oliwna z wysokim przezroczystym szklanym kloszem i wypolerowaną mosiężną podstawą - jej płomień jest najjaśniejszym punktem obrazu i głównym źródłem światła padającego na twarz i ręce. Za nim i po bokach ściany od podłogi do sufitu wyłożone są półkami z książkami w głębokim mroku. Wysokie okno przy lewym ramieniu ukazuje skrawek nocnego nieba w głębokiej niebieskości przez ukośne drewniane żaluzje, za którymi sylwetkują się liście palm. Na lewym skraju kadru mniejsze okno z ołowianymi szybami diamentowymi łapie cieplejsze barwy zmierzchowego nieba, a pod nim na półce stoi mały zegar kominkowy. Podłogę pokrywa wzorzysty dywan w stonowanych czerwieniach i złoceniach."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "Teodora, Augusta Rzymian, spoczywa na niskiej sofie z złotego brokatu na otwartym, kolumnowym tarasie, jedno ramię wsparte na wałku, drugie leży na kolanach. Korona to klejnotami zdobiony stemma - kopułkowata czapka bizantyjskiego cesarskiego nakrycia głowy, której opaska wysadzana jest rzędem kaboszonów. Zielony klejnot wyróżnia się przy czole, a grzebień powyżej wznosi się ku drugiemu zielonemu kamieniowi ujętemu w złotą oprawę. Włosy zaczesane pod nim i opadają długo na prawe ramię. Pendylia - perłowe zawieszki stemmy - zwisają przy twarzy; maniakis okrąża gardło, klejnotami wysadzany cesarski kołnierz Wschodu. Suknia jest warstwowa: przylegający, głęboczerwony gorset zapięty pośrodku złotym medalionu, spódnica ze złocistożielonego jedwabiu w arabeskowy wzór leży na kolanach, a pod nią długa spódnica ze spodniego ciemnoniebiesko-zielonego jedwabiu obszyta przy rąbku wąskim złotem. Złote bransolety okrążają nadgarstki. Ciężka czerwona kotara opada z tyłu po prawej stronie, odsunięta na bok, odsłaniając krajobraz za nią. Taras ma posadzkę z ciepłego kamienia i obwiedziony jest rzeźbioną balustradą ozdobioną urnami czerwonych kwiatów, dwie jasne marmurowe kolumny oprawiają widok. W poprzek szerokiej doliny stoi Hagia Sophia - szeroką centralną kopułę flankuje niższa półkopuła, ściany miodowo-brązowe w słońcu, niskie wzgórza bledną błękitem za nimi pod czystym niebem."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "Dydona, królowa-założycielka Kartaginy, stoi nocą na pałacowym tarasie. Za jej plecami niebo jest głęboko niebieskie i nakrapiane gwiazdami, a w oddali na horyzoncie nad niskim murem ledwo widoczny przylądek. U jej pleców stoi wygięta kamienna ławka, której wezgłowie zdobi rzeźbiony fryz z arabeskami, za nią wznoszą się jasne kolumny. Po obu stronach tarasu dwa wielkie krzewy w jasnych kamiennych donicach noszą ciemne liście i drobne czerwone kwiaty - granaty, których łacińska nazwa punicum znaczy je jako drzewo Kartaginy. Ma jasną cerę, ciemne włosy rozdzielone pośrodku i opadające za ramiona, na czole wąski złoty diadem. Suknia to bladoniebielska, prawie biała chitona - grecka tunika spięta na ramionach i przepasana w talii, jej sięgająca podłogi spódnica pokryta ledwo widocznym tkanym wzorem. Krótkie rozcięte rękawy spięte są w regularnych odstępach wzdłuż ramienia małymi broszami, a szeroka szarfa z ciemnego błękitu owija talię i zwisa długim płatem z przodu spódnicy. Przy gardle leży szeroki pektoral z ciemnych kamieni oprawionych w złoto, cienka złota bransoleta okrąża jeden nadgarstek. Ręce spoczywają wzdłuż boków, a kamień wokół niej chłodny w nocnym świetle."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "Boudika, królowa Icenów, stoi na trawiastym zboczu warowni na wzgórzu. Po lewej stronie kamienny mur zwieńczony jest drewnianą palisadą z zaostrzonych pali, a nad nim wychyla się stożkowy strzechowy dach okrągłego domu; po prawej łańcuch zielonych wzgórz opada w dół pod ciężkim szarym niebem. Włosy ma krótko ostrzyżone, żywo miedzianoczerwone, z tyłu głowy zawiązana jest blada wstążka płótna zwisająca za ramię. Na kości policzkowej pod jednym okiem widnieje mały ciemnoniebieskie znak - uaid w rodzaju, jakiego starożytni Brytowie używali do malowania ciała. Celtycki torc - skręcone złoto, sztywne - okrąża jej szyję. Suknia to bezrękawnikowa tunika sięgająca kolan, tkana w niebiesko-zieloną kratę, ściągnieta w talii skórzanym pasem z okrągłą klamrą. Skórzane naramienniki zasznurowane są na nadgarstkach, a podobna osłona opasuje górne ramię; łydki nagie powyżej niskich skórzanych butów. W lewej dłoni trzyma prosty obosieczny krótki miecz La Tene z zwężonym do szpica ostrzem i małą, prostą rękojeścią; prawa dłoń ściska pionowy trzonek włóczni wbitej kolbą w ziemię. Po jej lewej stronie stoi lekki dwukołowy rydwan z jednym szprychowym, obręczowanym żelazem kołem, a z jego skrzyni wycelowany jest w górę pęk długich włóczni."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "Wu Zetian, Huangdi dynastii Tang, stoi pośrodku mrocznej sali między ciężkimi czerwonymi kotarami odchylonymi na boki. Za jej plecami w ciemności zwisa rząd ciepłych złocistych latarni, a ciemna ściana za nimi ozdobiona jest rzeźbionymi kratownicowymi płytami. Czarne włosy zebrane i upięte wysoko na głowie, z przodu spięte buyao - złotą i perłową ozdobą. Ubrana w ruqun, noszony warstwami. Wewnętrzna szata z bladozłotego jedwabiu krzyżuje się na piersi powyżej sztywnej złotej płyty haftowanej medalonem; żywa czerwona szarfa, zawiązana wysoko pod biustem, opada jak długa spódnica do podłogi. Na to nałożona zewnętrzna szata z ciemnoczerwonegoj edwabiu z wzorem złotych medalionów, jej szerokie rękawy zwisają poza dłonie, a wlokący się rąbek rozpostarty jest po podłodze wokół stóp. Trzyma oburącz przy talii mały złoty naczyńko, uniesione nieco, jakby je ofiarowywała. Cera blada, wyraz twarzy opanowany, spojrzenie spokojne. Czerwone kotary, czerwona szata i złote latarnie rozgrzewają kadr na tle mroku sali."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    'Harald "Sinozęby" Gormsson, król Duńczyków i Norwegii, stoi na śródokręciu odkrytego pokładu longshipu. Jest szeroki w barach i masywnie zbudowany; jego broda, czerwonaworudoblond, rozdziela się w dwa zaplatane warkocze opadające poniżej kołnierza, a wąsy są długie i zwisające. Głowę ma odkrytą, włosy spięte w kok na czubku. Przez ramiona przerzucił płaszcz z długiego rdzawobrązowego futra. Pod nim nosi szarozielony kaftan z ciemniejszym karczkiem, którego rąbek i mankiety ozdobione są rytowanymi pasami nordyckiego plecionkowego motywu. Szeroki pas z rypowanej skóry opasuje go w talii, spięty masywną kwadratową klamrą, a drugi rzemień biegnie ukośnie przez pierś; obydwie dłonie spoczywają na pasie z przodu. Hełm leży na pokładzie przy jego stopach: kopuła z ciemnego żelaza z wzmacniającym nanosnikiem i naczółkiem, z bokami rozchodzącymi się w zaokrąglone klapy z grubego rdzawego futra. Po jego lewej stronie dziobowy słup wznosi się i wygina ku środkowi w wysoki drewniany spiralny kształt, wyrzeźbiony w postaci smoczej głowy. Za jego prawym ramieniem liny olinowania opadają od masztu, a ponad nimi żagiel zwisa w szerokich pionowych paskach czerwieni i bieli. Wzdłuż burty zamocowana jest twarzą na zewnątrz okrągła drewniana tarcza z żelaznym umbem pośrodku. Niebo powyżej jest otwarte i błękitne, poprzecinane smugami wysokich obłoków.'
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "Ramzes II, faraon Dwóch Krain, siedzi na tronie na szczycie krótkiego biegu schodów, a po obu jego stronach rozciąga się sala wysokich kolumn malowanych na niebiesko. Twarz ma młodzieńczą i gładko ogoloną, skórę ciemnobronzową, oczy obwiedzione ciemnym kohlem. Jego nakrycie głowy to nemes, prążkowana złotowoniebieska chusta zebrana ciasno przy skroniach i opadająca w plisowanych łopatkach na pierś. Nad czołem wznosi się uraeus, podniesiona kobra symbolizująca władzę królewską. Przez ramiona i pierś spływa wesekh, szeroka obroża z ułożonych rzędami złotych i lazurowych koralików. Nosi shendyt, faraońską plisowaną przepaskę z długiego białego lnu, przepasaną w talii szerokim szarfą w złocie i błękicie, która z przodu opada w sztywnym wzorzystym płacie. Sandałami obute stopy spoczywają na górnym stopniu. W lewej ręce trzyma przy ramieniu wysoki laskę; prawa spoczywa na poręczy tronu. Flankujące go kolumny malowane są w strefach błękitu, złota i czerwieni, a ich głowice uformowane w kształt pęków papirusu i pokryte rzędami hieroglifów oraz stojących postaci. Po obu stronach tronu stoją dwa wielkie złote posągi Izydy i Neftydy, bogiń ochrony, ze skrzydłami rozpostartymi i wysuniętymi ku przodowi, piórami oddanymi w długich złocistych płaszczyznach. Liście palmowe opadają z obu stron, a żółte kamienne stopnie u jego stóp żłobione są rzędami drobnych trójkątnych motywów. Cała sala jest zalana ciepłym złotym blaskiem, a niebieskie tony kolumn i obroży są jedynymi chłodnymi akcentami w tej złotej przestrzeni."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "Elżbieta I, z Bożej Łaski Królowa Anglii, Francji i Irlandii, Obrończyni Wiary, siedzi na wysokim rzeźbionym tronie, po którego bokach stoją dwa świeczniki na kamiennych cokołach ze zgaszonymi świecami. Za nią wznosi się baldachim ceremonialny, ciężki czerwony aksamit odciągnięty w fałdy złoconymi sznurami z kutasami, a mrok komnaty za nim ledwie przebija się przez tę zasłonę. Włosy ma wysoko upięte w ciasnych kędziorach rudoblond, spinane małą klejnotową koronką; kołnierz to sztywna, otwarta kryza późnotudorskiego dworu. Suknia jest ze złotego brokatu haftowanego w czerni, stanik ciasno skrojony i obszyty klejnotami, rękawy bufiaste przy ramionach i zwężające się ku koronkowym mankietom, a spódnica rozłożona szeroko na fartyngale. Długie sznury pereł krzyżują się na jej piersi i zwisają od talii, noszone wówczas jako symbol dziewictwa. Blade dłonie spoczywają na poręczach tronu."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "Hajle Selasje I, cesarz Etiopii, Wybrany Boży, Zwyciężający Lew z Pokolenia Judy, stoi w długiej sali recepcyjnej swego pałacu, pod jasnym kasetonowym sufitem, z wysokimi oknami po prawej stronie i kryształowym żyrandolem zawieszonym między nimi. Jest szczupły i wyprostowany, ciemnobrodaty, włosy przystrzyżone krótko. Nosi ciemną wojskową kurtkę zapiętą pod szyją, zwykłe ciemne spodnie i szeroki czarny skórzany pas. Przez prawe ramię na lewy biodra biegnie szeroka szmaragdowozielona szarfa z moaru, wstęga Orderu Pieczęci Salomona. Na lewej piersi skupiają się cztery rzędy miniaturowych wstążek, odznaczeń bojowych i honorowych zgromadzonych przez całe jego panowanie. Poniżej zwisają dwie wielkie gwiazdowe odznaki najwyższych orderów imperialnych, ośmioramienne, wykonane w złocie i emaliowane. Lewa ręka spoczywa wzdłuż ciała, prawa trzyma parę rękawiczek. Po jego lewej stronie stoi tron cesarski: fotel z wysokim oparciem obity jasnym kremem i błękitem, ze zwieńczeniem wyrzeźbionym w łukową koronę i przykrytym haftowaną tkaniną, ustawiony na czerwonym wzorzystym dywanie biegnącym przez całą długość sali. Jasne tapicerowane krzesła stoją rzędem pod ścianami za nim, oddalając się w głąb komnaty."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    'Napoleon Bonaparte, cesarz Francuzów, siedzi okrakiem na jasnoszarym koniu na zmierzchającym polu suchej trawy, na tle czerwonawobrązowego nieba i nagich drzew. Nosi ciemnoniebieski płaszcz z ciężkimi złotymi epoletami, biały kamizol, białe bryczesy i wysokie czarne buty jeździeckie. Dwuróg nosi w poprzek, z dwoma rogami zwróconymi ku ramionom, tak jak lubił, by wyróżniać się spośród swoich oficerów. Uzda konia to czerwona skóra nabijana złocistymi ćwiekami; czaprak pod spodem obszyty jest czerwienią i złotem. Kompozycja przywodzi na myśl obraz Jacquesa-Louisa Davida "Napoleon przekracza Alpy", choć zatrzymaną: żadnego stającego dęba rumaka, żadnej wskazującej dłoni, jedynie samotna postać w krajobrazie o zmierzchu.'
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "Otto von Bismarck, Minister Prezydent Prus i pierwszy Kanclerz Cesarstwa Niemieckiego, stoi w wysokiej sali reprezentacyjnej, w której dzienne światło wpada przez ołowiane okna za jego plecami, każda szyba podzielona drobnymi kwadratami przez smukłe szprosów. Ciężkie karmazynowe zasłony są podwieszone i związane przy każdym oknie w głębokich fałdach, ich wewnętrzna podszewka jest ciemniejszą czerwienią. Podłoga wypolerowana na lustro odbija okienne światło w długich jasnych smugach. Po jego lewej stronie mały stolik pomocniczy dźwiga białą kulkową lampę. Jest wysoki i barczysty, łysy na czubku głowy z krótkim wieńcem srebrznoszarych włosów z boków i z tyłu, i nosi gęste białe wąsy, długie, z końcami wygiętymi na zewnątrz. Jego płaszcz to ciemny dwurzędowy wojskowy mundur w głębokiej szarej łupkowej barwie, zapięty na piersi dwoma równoległymi rzędami złotych guzików, ze stojącym kołnierzem wykończonym złotem, a ramiona obciążają ciężkie złote epolety z kutasami opadającymi na ramię. Tuż poniżej kołnierza zwisa mały jasny krzyż na ciemnej wstążce, Pour le Merite, najwyższy pruski order zasługi wojskowej. Stoi trzy czwarte do widza, wyprostowany i nieruchomy, wzrok utkwiony gdzieś ponad jego ramieniem."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "Aleksander Wielki, król Macedonii i hegemon Hellenów, siedzi okrakiem na swoim siwoczarnym ogierze, Bucefale, powściągając go na zielonej górskiej łące, po obu stronach której ciągną się pasma szarych gór, a po prawej wznosi się jeden ośnieżony szczyt. Jest młody i gładko ogolony, brunatne włosy rozdzielone pośrodku i uniesione ku górze od czoła w anastole, dęby kosmyk czoła, który stał się znakiem rozpoznawczym jego portretów. Nosi linothoraks, hellenistyczny pancerz z warstw lnu i skóry, pokryty złoconymi płytami, z jarzmami ramion przywiązanymi na piersi krótkimi sznurami. Na środku piersi kwadratowa złocona płytka nosi gorgoneion, głowę Meduzy w reliefie. Od ramion i od przepasanej talii zwisają pteryges, rzędy usztywnione pasów skórzanych chroniących górne ramiona i uda, każdy z pasków obszyty czerwienią i zakończony złotym gwoździem. Ramiona ma nagie, na prawym nadgarstku szeroka złota bransoleta; nie nosi hełmu ani żadnej widocznej broni. Rzęd konia to ciemna skóra obrobiona czerwienią, nanosnik i policzki nabijane ćwiekami, a w lewej ręce Aleksandra spoczywa jedna uzda przerzucona przez kark zwierzęcia. Pod siodłem skóra cętkowanego leoparda drapi bok konia, łapy wciąż przytwierdzone."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "Attyla, król Hunów, siedzi na wysokim drewnianym tronie ze złożonym oparciem na podwyższeniu, a sala wokół niego skąpana jest w głębokiej czerwieni i złocie. Odchyla się swobodnie, z jedną nogą skrzyżowaną na drugiej; dobyta szpada leży mu na kolanach, jedna dłoń spoczywa na ostrzu, druga ściska czarę. Tunika jest czerwona, długorękawowa, obrzeżona złotem, nosi ją na granatowych spodniach wetknietych w wysokie miękkie skórzane buty z futrzanym wykończeniem przy mankiecie. Na głowie siedzi stożkowa czapka z ciemnego futra z złotym pasem. Jest brodaty i długowąsy, twarz oświetlona z prawej strony. Podłokietniki tronu kończą się rzeźbionymi głowami lwów, a ciężkie futro jest przerzucone przez oparcie. Za nim ściana z czerwonych draperii flankowana jest panelami z okrągłymi brązowymi dyskami różnej wielkości, w których łapie się blask ognia. Na prawo od podwyższenia wysoki żelazny lichtarz płonie pojedynczą świecą. Dalej na podłodze wielka mosiężna misa jeży się rękojeściami szablonowo pochowanych mieczy stojących prosto. Za nią otwarta drewniana skrzynia rozsypuje monety po wzorzystym dywanie."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "Pachacuti Inca Yupanqui, Sapa Inka z Tahuantinsuyu, siedzi na wysokim kamiennym tronie na tarasie nad Machu Picchu; tron wyrzeźbiony jest w rzędach zazębiających się motywów geometrycznych wyróżnionych złotem i czerwienią. Powyżej niego, po prawej stronie, przymocowany do kamiennego filara wielki złoty dysk słoneczny ukazuje stylizowaną ludzką twarz pośrodku w pierścieniu promieniujących na zewnątrz promieni. Nagie szczyty wznoszą się stromo po jego lewej stronie, a niskie kryte strzechą budynki rozmieszczone są na tarasowych platformach rolniczych w dole. Nosi mascapaycha, czerwoną wełnianą grzywkę opadającą przez czoło jako godło inkijskiej władzy, oplecioną przez llauto, wielobarwną opaską, i zwieńczoną pękiem stojących czerwonych i ciemnych piór. Włosy ma czarne, do ramion. Na szyi wisi ciężki złoty pektoral w kształcie dysku. Tunika to bezrękawna szata do kolan, wzorzysta w śmiałą czarno-białą szachownicę ze złotoczerwonym karczkiem na piersi. Poniżej kolan nogi opasane są czerwono frędzlowanymi sznurami. W prawej ręce dzierży wysoki berło zwieńczone złotą figurą ptaka, którego trzon ozdabiają tiulowe czerwone chwosty."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "Mohandas Karamchand Gandhi, Mahatma, przywódca indyjskiej walki o niepodległość, stoi na indyjskim wybrzeżu porośniętym suchą żółtą trawą, z skalistym przylądkiem i bladym morzem w tle. Jest szczupły, łysy i w okularach, z krótko przystrzyżonymi szarymi wąsami. Nosi strój ze swojej późniejszej fazy życia: proste białe dhoti owinięte w talii, szal przerzucony przez jedno ramię i pod przeciwległe ramię, pierś odkryta. Tkanina jest nefarbowana i ręcznie przędzona, świadome odrzucenie brytyjskiego sukna, które stało się godłem jego ruchu. Sceneria przywodzi na myśl długie marsze, które odbywał ku morzu podczas walki o niepodległość, samotna postać na skraju subkontynentu."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "Gajah Mada, Mahapatih Imperium Majapahit z Jawy, stoi na skraju zalanego pola ryżowego; woda błyszczy jak zwierciadło między niskimi grzbietami zieleni. Za nim gęsty tropikalny las wspina się po zboczu wzgórza owiniętego bladą mgłą, a z tej mgły wyłania się smukła schodkowa sylwetka candi, czerwono-ceglanej wieży świątynnej, której tiulowy dach rozpływa się w chmurach. Jest barczysty i z gołą piersią, ciemne włosy spięte w kok na czubku głowy, mały pęczek brody na brodzie. Złote opaski spinają każdy biceps i każdy nadgarstek. Szeroki pas leży wysoko na talii, spięty dużą złotą plakietą z festonowanym wzorem w kwiaty w stylu Majapahit. Poniżej pasa czerwone sarong owinięte i zawiązane z przodu, a jego fałdy opadają w ciężkich płatach nad żółtą podtkaninę widoczną przy rąbku. Na prawym biodrze, zawieszony na sznurze przez pas, wisi pochowany kris, którego ciemna drewniana pochwa zwęża się ku wąskiemu czubkowi, z rękojeścią wysuniętą ku przodowi pod skośnym kątem."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "Hiawatha, założyciel Konfederacji Haudenosaunee, stoi w nasłonecznionej polanie, z dużym szarym głazem wznoszącym się przy jego ramieniu i smukłymi pniami buka i brzozy ustępującymi w zielone zarośla za nim. Jest szczupły i z gołą piersią, skóra ciepłobrązowa w plamkowanym świetle. Włosy ułożone są w scalplock: boki głowy ogolone krótko, a wąski grzbiet ciemnych włosów biegnący od czoła ku tyłowi, z dwoma stojącymi piórami przypiętymi z tyłu. Pasy ciemnej farby oplatają każde górne ramię. Ciasno przylegający naszyjnik z białych muszlowych paciorków, wampum, leży przy jego gardle, a pojedynczy pasek przechodzi przez pierś od prawego ramienia do lewego biodra, podtrzymując kołczan ze strzałami, których opierzone końce wystają ponad ramię. W talii przepaska z jasnobrązowej skóry jelenia opada w długim przednim płacie do połowy uda. Obszyty frędzlami skórzany nagoleniki z jelenia owijają łydki od kostki do kolana, przywiązane poniżej kolana i otwarte na udzie, gdzie przykrywa go przepaska. Stoi boso na ubitej ziemi polany, z rękami wzdłuż boków, a leśne światło pada na jego prawą stronę."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "Oda Nobunaga, daimyo klanu Oda i pierwszy z wielkich zjednoczycieli, stoi na falującym zielonym terenie wysokiej trawy i rozrzuconych białych kamieni, z pasmem błękitnych gór cofającym się ku horyzontowi pod jasnym niebem napiętrzonych chmur. Głowa ma ogolona na czubku zgodnie z metodą sakayaki: czoło i wierzch ogolone tak, by hełm siedział pewnie i chłodno, a pozostałe włosy zebrane z tyłu. Nosi krótkie wąsy i krótką bródkę. Jego zbroja to tosei gusoku, nowoczesna uprząż z epoki Sengoku: lakierowane żelazne płytki sznurowane w poziomych rzędach jedwabnymi sznurami, napierśnik i płytki spódnicy przepasane naprzemiennymi pasami ciemnoniebieskiego i szkarłatu. Naramienniki zwisają z tych samych sznurowanych płyt nad każdym ramieniem. Nad zbroją nosi bezrękawny piaskowy płaszcz bojowy, którego przednie skrzydła otwierają się, ukazując sznurowany napierśnik pod spodem. Szeroka czerwona szarfa zawiązana jest w talii, z mieczem wsuniętym przez nią ostrzem ku górze; po prawej stronie zwisa drugi miecz, prawa dłoń na jego rękojeści. Razem tworzą daisho, sparowane długie i krótkie miecze noszone przez każdego samuraja. Za jego prawym ramieniem, niesiony na plecach, wznosi się długa ciemna kolba i smukła lufa tanegashimy, broni palnej na zamek lontowy, której masowe przyjęcie Nobunaga jest pamiętany. Stoi sam na otwartym terenie, otoczony tylko trawą, kamieniami i dalekimi górami."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "Sejong Wielki, czwarty król dynastii Joseon, siedzi pośrodku podwyższonego drewnianego podestu w sali tronowej, trzymając na kolanach otwartą księgę obiema rękami. Odziany jest w gonryongpo, czerwoną jedwabną szatę z wyszytymi smokami, noszoną przez królów Joseon, na piersi i ramionach ozdobioną złotymi medalionami z czteroszponiastymi smokami i złotym arabeskowym obramowaniem. Szeroki pas z jadeitowymi okuciami przepasuje go w talii. Na głowie nosi ikseongwan, sztywną czarną czapkę z gazy z dwoma małymi uniesionymi skrzydełkami wyrastającymi z tyłu niczym złożone liście. Jest gładko ogolony, tylko podstrzyżony ciemny wąs i krótka bródka zdobią twarz. Za nim wznosi się Irworobongdo, parawan ze sceną słońca, księżyca i pięciu szczytów ustawiany za każdym tronem Joseon, gdzie król był słońcem, a królowa księżycem: biały dysk księżyca w lewym górnym rogu, czerwony dysk słońca w prawym górnym rogu, postrzępione szczyty w głębokiej zieleni, a ciemnoczerwone sosny rozłożone wzdłuż dolnej krawędzi. Sam tron jest lakierowany na czerwono, jego boczne panele rzeźbione w medaliony z tygrysami. Czerwono lakierowane balustrady i słupy obramowują podest po obu stronach; papierowe latarnie zwisają przy krawędziach sali, jaśniejąc żółtym blaskiem; kilka kamiennych stopni schodzi w stronę patrzącego."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "Pakal, K'uhul Ajaw Bʼaakal, Święty Pan Palenque, stoi na tarasie wapiennego pałacu górującego nad swoją stolicą w południe; schodkowe świątynie piramid wyrastają z dżungli za nim, ich grzebieniowe nadbudówki są rzeźbione i wyblakłe do bladogorączkowego różu. Za jego ramionami rozpostarty jest wielki nagrzbietnik, drewniana rama osadzona długimi piórami ogona kwezala w pasmach zieleni, błękitu i głębokiej czerwieni, umocowana nad prostokątną płytą z rzeźbionymi i malowanymi glifami. Nakrycie głowy jest wysokie i wielopoziomowe, uwieńczone kolejnymi piórami kwezala. Długie ciemne włosy opadają mu na ramiona. Szeroki naszyjnik z rzeźbionych jadeitowych płytek leży na piersi, pośrodku zwisa kwadratowy jadeitowy pektoral, a jadeitowe ozdoby uszu przewleczone są przez płatki. Paciorkowaty pas zbiera kilt z splecionego materiału i piór w talii, frędzle długich piór spływają po obu stronach do kolan, a sandały są zapięte wysoko na łydce. W lewej ręce ściska berło-manikin K'awiila, wysoki laska zwieńczona małą rzeźbioną głową boga błyskawic, której wizerunek władcy Majów dzierżyli jako znak królewskości. Po jego lewej stronie, przy krawędzi tarasu, stoi szeroki kamienny kadzielnik, a na jego krawędzi widnieją resztki spalonych ofiar. Miasto w oddali ginie w mgle, piramida za piramidą schodzą ku równinie rzeki."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "Czyngis-chan, Wielki Chan Mongołów, siedzi na czarnym koniu na otwartym stepie, ukazany od pasa w górę, trójćwierćobrotowo zwrócony ku patrzącemu. Jego hełm jest wysoki i stożkowy, wieńczy go ostry zwieńcznik, ciemna opaska na czoło i policzniki obramowują wąski wąs i mały kępczyk brody na brodzie. Zbroja to nitowana mongolska uprząż kawalerzysty, z dużym okrągłym brązowym nitem wytłoczonym w spiralny wzór pośrodku piersi; szerokie naramienniki spoczywają na ramionach, a nabijane opaski owijają ramiona. Ciemny płaszcz spada z ramion, jego podszewka w stonowanym fiolecie tam, gdzie opada za siodłem. Oporządzenie konia jest ze zwykłej skóry, prosta uzdeczka z samą opaską na czoło i zebranymi z przodu lejcami. Za nim niskie zielone wzgórza falują pod bladym, zachmurzonym niebem; w połowie zbocza rozbity jest obóz ger, okrągłych białych filcowych namiotów Mongołów, a blade plamy bydła rozproszone są po trawie wokół nich."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "Ahmad al-Mansur, saadyjski sułtan Maroka, stoi na skraju saharyjskiego obozu pod głęboko błękitnym niebem. Cienki sierp księżyca i rozsypane gwiazdy świecą nad niskimi, ciemnymi pasmami gór na horyzoncie. Jest brodaty, jego skóra ciepło złoci się w świetle lampy, a spojrzenie spokojne, skierowane ku patrzącemu. Odziany jest w warstwowe stroje Maghrebu: długą białą dżelabę, sięgającą kostek szatę z kapturem, noszoną w Afryce Północnej. Na niej leży selham, delikatna wełniana peleryna władców i książąt, kaptur opada między łopatkami. Biały turban owija jego głowę. Na piersi zwisa prostokątny haftowany panel w kolorze kremowym i złotym, zdobiony przeplatającą się geometrią islamskiego ornamentu. Szeroka szarfa w pionowe czerwono-kremowe pasy jest podwójnie owinięta w talii i zawiązana z przodu, a jej końce schowane pod spodem. Za nim, nieco w lewo, wielki zaokrąglony namiot karawanowy z ciemnego paskowanego płótna jarzy się od wewnątrz, a jego otwarty fartuch oblewa piasek ciepłym pomarańczowym światłem; dwa wielbłądy odpoczywają na piasku obok namiotu. Dalej tleje mniejsze światło, a gęstwina palm daktylowych wznosi się na tle wzgórz."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "Wilhelm I, książę Orański, ojciec niderlandzkiej niepodległości, stoi w wyłożonej kafelkami komnacie oświetlonej wysokim oknem z ołowianych szybek po lewej, którego małe romboidalne tafle obramowane są ciężkimi czerwonymi draperiami odsuniętymi na bok. Podłoga ułożona jest z czarno-białych marmurowych kwadratów. Za nim na odległej ścianie wisi oprawiony w złocone ramy krajobraz nizinnego kraju pod ciężkim niebem, gdzie rzeka wije się przez płaskie zielone pola ku odległemu miasteczku. Po jego prawej stronie drewniany stołek dźwiga globus ziemski, którego mosiężna obręcz południkowa łapie światło okna. Po lewej, nakryty czerwonym obrusem stolik do pisania niesie otwartą księgę w skórzanej oprawie i luźne arkusze papieru, a za nim stoi fotel z wysokim oparciem obity niebieską tkaniną. Cała ta izba przypomina gabinety uczonego z Geografa i Astronoma Vermeera, choć Wilhelm należy do pokolenia starszego niż ten styl. Jest brodatym mężczyzną w średnim wieku, ciemne włosy przycięte krótko pod małą płaską czapeczką, wąs i rozdwojona broda starannie podstrzyżone, szeroka biała marszczona kryza stoi przy gardle. Z ramion opada długi czarny płaszcz, odciągnięty z prawej strony, by uwolnić ręce. Kaftan z matowego złocistego jedwabiu w deseniu jest dopasowany do tułowia i zapinany z przodu na jeden rząd guzików. Spodnie to bufiasty trunk hose, uszyty z długich pionowych pasków czerwono-białego materiału ułożonych w naprzemienne pasy na pełniejszej podszewce i kończący się w połowie uda. Zwykłe ciemne pończochy okrywają nogi od kolan i spotykają się z niskimi skórzanymi butami na wzorzystej posadzce. W prawej ręce trzyma buławę dowódczą uniesioną na wysokość piersi, lewa spoczywa przy biodrze, gdzie spod fałd płaszcza ledwie prześwituje rękojeść szpady."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "Sulejman Wspaniały, Kanuni Prawodawca, sułtan Osmanów, stoi w pałacu Topkapi pod żebrowaną kopułą, w sali ostrołukowych arkad okładzinowych niebiesko-białymi płytkami z Izniku. Smugi dziennego światła padają z niewidocznych okien na blade kamienne kolumny za nim. Jest brodaty, ciemnooki, wąs i broda starannie przycięte wokół wąskich ust. Turban to wysoki, okrągły kavuk, z którym był znany, wielkie zwinięcie białego materiału owinięte wokół stożkowej podstawy i wyrastające wysoko nad czoło. Na jego szczycie unosi się sorguç, zielone pióropusz oznaczający rangę sułtana. Na wewnętrzną szatę nałożył długi kaftan z żółtego jedwabiu utkanego bladym wzorem winorośli i rozet, z przodu rozchylony do pasa. Szeroki pas miękkiego szarego futra obszywał go na całej długości, co wskazuje na kapanice, najwyższą szatę honorową. Ciemna szarfa przeplata kaftan w talii. W prawej ręce, trzymanej pionowo przy piersi, spoczywa oprawiony w ciemną skórę wolumin. Druga ręka opada wzdłuż boku. Sala za nim ginie w cieniu między wyłożonymi płytkami arkadami."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "Dariusz I Wielki, Król Królów Imperium Achemenidów, stoi na szczycie kilku stopni u wejścia do wielkiej sali, a z góry pada na niego smuga światła. Jest barczysty i gęstobrodaty, broda długa, prostokątnie przystrzyżona i ciasno kędzierzawa. Na głowie nosi kidaris, wysoka, krenelażowa korona perskich królów, złoty cylinder opasany kwadratowymi merlonami. Szata to długa safranowożółta suknia opadająca do stóp, ozdobiona na piersi, mankietach i rąbku czerwono-złotym haftem. Czerwona szarfa zgarnia ją w talii. Ciężkie złote bransolety spinają każdy biceps. Po obu stronach, na cokołach, wznoszą się dwa kolosalne lamassu, uskrzydlone byki, ich ciała i złożone skrzydła pokryte złotem, postaci strażnicze Bramy Wszystkich Narodów w Persepolis, tu w wersji z ludzką głową sprowadzonej do samego byka. Tylna ściana jest rzeźbiona w niskim reliefie z procesją postaci w długich szatach i miękkich czapkach, wzorowaną na reliefach niosących daniny ze schodów Apadany. Kamień podestu i stopni ma bladozielonkawy odcień, zaakcentowany złotymi guzami w narożnikach."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "Kazimierz III Wielki, król Polski i ostatni z królów piastowskich, stoi w przejściu kamiennej bramy oświetlonej żelaznymi kinkietami ściennymi, których płomienie kładą ciepłą czerwonozłotą poświatę na mury. Jest barczysty i gęstobrodaty, broda ciemna i starannie przystrzyżona, spojrzenie spokojne. Korona to złoty arkadowy krążek z czerwonymi kamieniami, łuki zamykają się u góry w klejnotowym zwieńczniku. Wokół ramion leży szeroka peleryna z białego gronostaja, futro przetykane małymi czarnymi kępkami ogonków. Pod nią płaszcz, długa karmazynowa szata zapinana na piersi w rządek małych złotych guzów i przepasana w talii szerokim pozłacanym pasem. W jednej ręce trzyma złote berło wyprostowane przy piersi; u boku zwisa Szczerbiec, piastowski miecz koronacyjny. Po obu jego stronach ciężkie żelazne łańcuchy opadają z ciemności z góry wzdłuż wewnętrznych ścian bramy. Za nim, osadzona w arkadzie na tylnej ścianie komnaty, czerwona tarcza nosi ukoronowanego Białego Orła Polski z rozpostartymi skrzydłami. Orzeł jest oddany w ciemnej sylwetce na czerwonym tle, a nie w tradycyjnej srebrnej barwie. Kamień jest masywny i starannie spasowany, światło skupia się na królu i stromo opada w zacienione sklepienia po obu stronach."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "Kamehameha Wielki, zjednoczyciel Wysp Hawajskich i pierwszy Mo'i królestwa, stoi boso na plaży o białym piasku, za nim turkusowe wody spokojnej zatoki i ciemna, zalesiona grań wznosząca się w oddali. Jest wysoki i masywnie zbudowany, z odsłoniętą piersią, skóra głęboko brązowa w tropikalnym słońcu. Na jednym ramieniu zwisa ahu'ula, peleryna z piór hawajskich ali'i, głęboko czerwona, opadająca niemal do kostek. Szeroka szarfa w tym samym czerwonym kolorze biegnie przez pierś od lewego ramienia, a jej żółte obramowania zdobią małe czerwone geometryczne bloki. Pasująca do niej płyta w czerwono-żółte pasy zwisa z przodu jego malo, przepaski biodrowej owiniętej w talii. Na głowie siedzi mahiole, niski hełm z grzebieniem, z wąskim grzbietem biegnącym od czoła do karku, wykonany w czerwieni z żółtymi pasami i żółtą przepaską u podstawy. W prawej ręce trzyma wysoki drewniany oszczep z zadziorem; lewa ręka opada wzdłuż boku. Po jego prawej stronie, wyciągnięte na piasek, leżą dwa wa'a kaulua, polinezyjskie kanu z podwójnym kadłubem, których bliźniacze poszycia spięte są przytrzonkowanymi poprzecznicami. Żagle są trójkątne, z wierzchołkiem przy stopie masztu i górną krawędzią wygiętą na zewnątrz w długie U; płótno jest blade i połatane. Trzecia łódź stoi na kotwicy dalej w zatoce. Na brzegu za lewym ramieniem stoi kryty strzechą hale, hawajski dom ze słupową konstrukcją i dachem z suszonej trawy, napół ocieniony liśćmi palm kokosowych. Niebo nad granią jest błękitne z wysokimi białymi obłokami."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "Maria I, królowa Portugalii, Algarvów i posiadłości portugalskich za morzem, stoi na tarasie Palácio da Pena w Sintrze, w bladej kamiennej galerii pod rzędem ciężkich arkad romańskich. Ocean Atlantycki rozciąga się za ich kolumnami. Suknia jest z głęboko niebieskiego jedwabiu. Stanik jest ściśle dopasowany, z zaostrzonym wcięciem w talii, rękawy do łokcia wykończone białymi mankietami, spódnica pełna na krinolinie i opadająca szerokim fałdami na kamień. Krótka czerwona peleryna zapięta jest na ramionach i wlecze się za nią. Przez pierś biegnie szeroka biała szarfa obszyta czerwienią, szarfa Portugalskiego Orderu Chrystusa, noszona przez władców Portugalii jako Wielkich Mistrzów. Na jej przedniej części osadzone są klejnotowe ozdoby. Ciemne włosy uczesane wysoko, upięte ponad czołem i przytrymane aigrette, małą czarną ozdobą spiętą stojącym piórkiem. Prawa ręka spoczywa z boku na rękojeści smukłego berła, którego ciemna rózga opada na błękit spódnicy. Po jej prawej stronie, za balustradą, wąska morska cieśnina biegnie między czerwonymi klifami. Dwa rejowe Naus ze zrolowanym płótnem stoją na kotwicy w kanale. Po lewej wznosi się żółta wieża donżon uwieńczona bulwiastą kopułą ze złoconych i kafelkowanych pasm. Krenelażowe żółte blanki schodzą ku tarasowi, na którym stoi. Niebo jest czyste, światło to jasne atlantyckie popołudnie, a arkady obramiają ją z jednej strony wodą, z drugiej królewską architekturą."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "Cezar August, pierwszy cesarz Rzymu, siedzi na krześle kurulnym między dwiema brązowymi głowami sfinksów, których gładkie oblicza zwrócone są na zewnątrz. Jest gładko ogolony, krótkie ciemne włosy zaczesane do przodu na czoło, grzywka zgodna z tradycją Prima Porta. Toga picta, uroczysta purpurowa toga noszona podczas triumfu rzymskiego, owinięta jest na białą tunikę, przerzucona przez kolana i zarzucona na lewe ramię. Kołnierz tuniki obrzeżony jest złotem. Prawa ręka spoczywa otwarta na jednej z głów sfinksów, lewa luźno leży na kolanie. Za nim mroczna sala o ciemnoczerwonych ścianach ozdobiona jest żłobkowanymi kolumnami i zawieszona pionowymi chorągwiami w czerwieni i złocie. Na tylnej ścianie okrągły brązowy medalion nosi głowę lwa w reliefie. Smugi bladego dziennego światła padają z lewej na jego twarz i pierś, pozostawiając dalszą część sali w cieniu; dwa małe kadzielniki na żelaznych podstawach po obu stronach tronu tlą się przygaszonym ogniem."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "Katarzyna II, cesarzowa i autokratka Wszechrusi, stoi w Sali Świetlistej, Wielkiej Sali Pałacu Katarzyny w Carskim Siole. Ciało ma obrócone w trzech czwartych ku widzowi, wzrok spokojny i poziomy. Ciemne włosy upięte są wysoko w stylu europejskich dworów schyłku osiemnastego wieku. Spina je u góry niewielki ozdobny diadem, którego szpice przywołują na myśl w miniaturze wysokie łuki w kształcie lilii z Wielkiej Cesarskiej Korony Rosji. Suknia to strój dworski z kości słoniowej jedwabiu: ściśle skrojony gorset ze złoto haftowanym środkowym pasem biegnącym wzdłuż dekoltu, nabierany półrękaw głębokiego błękitu, wykończony na ramionach pasami białego gronostaja. Pełna spódnica rozlewa się poniżej, wyszywana złotem w dwugłowego orła rosyjskich herbów cesarskich rozsianego jako powtarzający się motyw. Przez całą sylwetkę, od prawego ramienia po lewe biodro, biegnie szeroka blado-błękitna szarfa z jedwabiu moiré - wstęga Orderu Świętego Andrzeja Apostoła Pierwszego Powołania. Wysokie okna o łukowych zwieńczeniach wzdłuż prawej ściany zasłonięte są bladoniebieskimi kotarami odchylonymi w festony, a smugi dziennego światła padają widocznymi pasami na czarno-białą posadzkę marmurową wypolerowną na lustro. Na lewej ścianie ciąg złoconych rzeźbień rokokowych, wijących się i liściastych, oprawia zwierciadlane tafle."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "Pocatello, wódz Szoszoni Północno-Zachodnich, siedzi na kopcu zwietrzałych czerwonych głazów na skraju kotliny śródgórskiej, a za nim rozciąga się płaski step pokryty bylicą aż po niskie mesy rysujące się sylwetkami na horyzoncie pod zmierzchowym niebem w kolorze różu i bladego fioletu. Ma szerokie ramiona, długie czarne włosy przedziela na środku - opadają na pierś - a z tyłu głowy tkwi pionowe orle pióro. Drugie, ciemne pióro wyrasta zza jego ramienia z kołczanu przypiętego do pleców. Obok kołczanu przewieszone jest krótkie łuczysko, którego górne ramię sterczy ponad jego prawym barkiem. W prawej dłoni trzyma długą włócznię wbitą trzonkiem w skałę; drzewiec owinięty jest skórą, a tuż pod grotem zwisa ciemny pęk sierści. Na torsie ma futrzaną kamizelkę, przez którą biegnie ukośnie szeroki rzemień z garbowanej skóry zdobiony rzędami paciorków, od prawego ramienia do lewego biodra, a na jego dolnym końcu zwisa krótka pochewka na nóż. Górne ramiona okala kilka nałożonych na siebie srebrnych opasek. W dół od pasa nosi ciemne frędzlowane nogawice ze skóry, opadające aż do kostki, a między nimi przepaskę biodrową. Lewa dłoń spoczywa otwarta na udzie; siedzi nieruchomo, ciężarem osadzony na kamieniu. Światło jest niskie i ciepłe, wydobywa czerwień skał i blask grotu włóczni, a dal za jego plecami to kraj bylicy Wielkiej Kotliny, ojczyzna Szoszoni między Skalistymi a Sierra Nevada."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "Ramkhamhaeng Wielki, król Sukhothai, stoi w ogrodzie pałacowym skąpanym w słońcu. Zielona mgła tropikalnego lasu i blade sylwetki odległych chedis - dzwonowatych buddyjskich stup Tajlandii - wyłaniają się z nisko zalegającej mgły za jego plecami. Jest smukły, ma gołą pierś, skórę ciepłej brązu i twarz odwróconą lekko w lewo z ledwie dostrzegalnym uśmiechem. Jego korona jest wysoka, wielopiętrowa i zaostrzająca się ku górze, zwieńczona smukłą iglicą - to chada, stożkowa korona tajskich królów. Przez ramiona i pierś rozłożony jest szeroki złoty naszyjnik-pektorał, zdobiony repoussé w wolutowe wzory i osadzony pośrodku jednym czerwonym kamieniem; węższe złote opaski obejmują każde z ramion powyżej łokcia. Jedwabna biała szarfa jest owinięta i zawiązana w pasie, a jej skręcone końce opadają ku udom. Pod nią nosi przepaskę z tkaniny w głębokiej czerwieni z złotym wzorem, z widoczną ciemniejszą podwarstwą przy rąbku. Po jego prawej stronie, na skraju spokojnego stawu usianego różowymi kwiatami lotosu i ich szerokimi płaskimi liśćmi, stoi mała kamienna rzeźba: spokojna głowa Buddy z opuszczonymi oczami, ustawiona na cokole w kształcie pąku lotosu. Blada piaszczysta ścieżka zakręca w lewo między krzewami okrytymi czerwonymi kwiatami i prowadzi w stronę owianych mgłą wież stolicy."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "Mohammad I, Askia Wielki z Songhaju, stoi na skalistym klifie o zachodzie słońca z długim ostrzem opartym o ramię i płonącym miastem za plecami. Ma ciemną skórę i krótką brodę, wzrok utkwiony w widza. Głowę owija tagelmust, jasnobrązowy sahelijski turban, wysoko nawinięty i zebrany po jednej stronie. Przez ramiona spada długi karmazynowy bubu - szerokopołowy strój szlachty Afryki Zachodniej - z przednią klapą i klatką piersiową wyszywaną gęsto wzorzystymi pasami złotej i ciemnej nici. Pod nim blada szarfa owinięta jest w pasie i zawiązana tak, że końce zwisają luźno na biodrach, ponad spodniami w tym samym karmazynowym odcieniu co szata. Miecz trzyma za rękojeść w prawej dłoni, a ostrzem pozwala mu spoczywać wzdłuż ramienia; jest długi, z prostym grzbietem i ledwie dostrzegalnym wygięciem ku końcowi. Po jego prawej stronie teren opada ku równinie pod czerwono-pomarańczowym niebem, gdzie ciemna góra rysuje się sylwetą na tle nisko zawieszonego słońca. Po jego lewej stronie płonie miasto: mury z suszonej cegły i wysoki kwadratowy minaret najeżony rzędami wystających drewnianych toron, palmowych belek pozostawionych tkwiących w tynku. Płomienie wspinają się po wieży i przetaczają przez ulice poniżej; mniejsze ognie rozsiane są po równinie między miastem a klifem, na którym stoi."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "Izabela I, królowa Kastylii i Leonu, królowa-małżonka Aragonii, stoi w jednej z kolumnowych galerii Alhambry w Grenadzie; arkada otwiera się na ogród starannie przystrzyżonych żywopłotów i doniczkowych topiariów, a wzgórza nikną w mgle w oddali. Za jej plecami smukłe kolumny parami wznoszą się ku płatowym i ząbkowanym łukom wypełnionym ażurowym ornamentem, a pendentywy powyżej rzeźbione są gęsto w geometryczne i roślinne sztukaterie w bladym złocie i piaskowych tonach. Jest drobna i blada, dłonie złożone jedna na drugiej w pasie. Głowę nakrywa w kastylijskiej modzie swojego dworu: biały welon opinający podbródek i owijający szyję, biała zasłona nałożona na czubek głowy, a ponad nią niewielka zamknięta korona ze złota osadzona czerwonymi i zielonymi kamieniami. Przez ramiona spada długi czerwony płaszcz podbity i obszyty złotem, rozchylony z przodu. Suknia pod nim jest z kremowego brokatu z ciemnym powtarzającym się wzorem, z obcisłym gorsetem i złoto obramowanym pasem biegnącym środkiem spódnicy. Na piersi przypięty jest czerwony klejnot w miejscu, gdzie płaszcz się rozchyla. Światło jest ciepłe i niskie, jak późnym popołudniem - ślizga się po sztukateriach arkady i jasnym kamieniu posadzki galerii."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "Gustaw Adolf, król Szwedów, Gotów i Wendów, Lew Północy, stoi w złoconej komnacie pałacowej. Obok niego w głębokim kominku płoną rąbane polana, ogień niski i jasny. Jest wysoki i ciężkiej budowy ciała, ma gęstą rudawą brodę sięgającą piersi i gęste podkręcone wąsy, a włosy zaczesane do tyłu od wysokiego czoła. Nosi przyciemnioną stalową kirysę zdobioną złoconymi pasami przy krawędziach i wzdłuż środkowego grzbietu, nałożoną na bufiasty kaftan z grubej, bladej, natłuszczonej skóry wołowej. Zbroja przechodzi niżej w artykułowane stalowe tasety rozszerzające się do połowy uda ponad żółtą spódnicą. Szeroka szarfa z turkusowego jedwabiu biegnie od prawego ramienia do lewego biodra, zawiązana i opadająca luźną fałdą na napierśnik. Przy nadgarstkach widać niewielkie koronkowe mankiety, a jasna koronkowa falbana obszywa spodnie powyżej butów. Stoi z ciężarem odchylonym ku tyłowi, każda rękawiczona dłoń wsparta na polowym buławie wbitej ostrzem w podłogę przed nim. Za nim kamienna obudowa kominka jest rzeźbiona i złocona, gzyms przewiązany barokowymi wolutami z akantu. Po lewej stronie dwa obrazy w złoconych ramach wiszą na ścianie z zielonego i złotego adamaszku. Bliższy ukazuje brodatego mężczyznę w ciemnej zbroi - Eryka XIV, wcześniejszego króla Szwecji. Dalszy ukazuje bladą kobietę w jasnej sukni dworskiej - Marię Eleonorę Brandenburską, małżonkę Gustawa. Poniżej obrazów przy wypolerowanym ciemnodrewnianym stole stoi płytka cynowa misa przysypana owocami, a przy bliższym końcu stołu wznosi się wysoki mosiężny świecznik z niezapalonymi świecami. Komnatę oświetla niemal wyłącznie ogień. Ciepła pomarańczowa poświata pada na kirysę, złocone stiuki i prawą stronę jego twarzy, pozostawiając dalszą ścianę w cieniu."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "Enrico Dandolo, doża Najjaśniejszej Republiki Wenecji, stoi na kamiennym moście nad kanałem nocną porą, jedną rękawiczoną dłoń uniósł do piersi. Jest stary: długa siwa broda opada mu na pierś, siwe włosy widać na skroniach, a twarz poorana jest głębokimi zmarszczkami. Na głowie spoczywa corno ducale - sztywna rogata boneta książęca z rdzawo-czerwonego brokatu, wyrastająca z tyłu w tępo zakończony czubek na wzór czapki frygijskiej, tu noszona na obcisłym białym lnianym camauro, którego brzeg wystaje spod niej nad czołem. Przez ramiona leży ciężki szary płaszcz obszywany bladym futrem, rozchylony z przodu i podszyty tym samym rdzawo-czerwonym odcieniem co boneta. Pod nim nosi długą szatę z ciemnoczerwonego brokatu przepasaną w talii węzłowym złotym sznurem. Balustrada mostu wykonana jest z kutego żelaza, jej pola wypełniają smukłe ostrołukowe arkady w stylu weneckiego gotyku. Za jego plecami kanał ucieka w ciemność, po bokach flankonwany pałacami, których okna żarzą się ciepłą pomarańczą na tle błękitnej nocy. Przy nabrzeżu po lewej stronie cumuje wąska gondola, a gwiaździste niebo przebija przez chmury ponad dachami."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "Shaka kaSenzangakhona, król Zulusów, stoi na otwartym placu królewskiej siedziby, z nogami szeroko rozstawionymi, tarczą wysuniętą po lewej stronie i krótką włócznią po prawej. Ma gołą pierś, ciemną skórę i dobrze umięśnione ciało; tors przecinają mu smukłe rzemyki nawleczone drobnymi koralikami. Wokół głowy opasuje go umqhele - gruby okrągły opaskowy nakrycie głowy z cętkowanej skóry lamparta, oznaka godności królewskiej i starszyzny. Na czole do opaski przymocowany jest pionowy kitasz białych piór z czerwonymi końcówkami. W pasie zwisa fartuch ze skóry lamparta opadający przez biodra, a pod nim szmaty z długich jasnych frędzli futrzanych kołyszą się przy udach. Te same cętkowane paski owijają kostki. W lewej dłoni niesie isihlangu - wysoki, spiczasto-owalny wojenny okrąglik z wołowej skóry; powierzchnia jest plamkowana brązem i bielą, a przez środek biegnie prosta drewniana żerdź umocowana skórzanymi pętlami. W prawej dłoni, opuszczonej nisko i gotowej do uderzenia, trzyma iklwa - krótkotrzonową włócznię do pchnięć z długim, szerokim ostrzem w kształcie liścia. Za nim łukiem rozciąga się rząd iqukwane - kopułastych słomianych chat-uli zuluskiej umuzi, których tkane ściany łapią promienie słońca. Po obu stronach polany wznoszą się drewniane słupy zwieńczone czaszkami długorożnego bydła z wciąż przytwierdzonymi rozłożystymi rogami - bogactwo i ofiara wystawione na widok przy bramie. Ziemia jest sucha i blada, w dalekiej odległości rysuje się płaskowyż o ściętym wierzchołku, a niebo powyżej jest czysto bladoniebieskie z cienkimi smugami chmur."

-- Mod-authored strings, ru_RU overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Boot =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] =
    "Civilization V: специальные возможности загружены."

-- ===== Mute / hotseat toggle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "мод на паузе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "мод возобновлён"

-- ===== Unit speech =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "рекомендация: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "место для города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "на борту {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} ходов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} самолётов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "доступно повышение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    one = "{1_What} {2_Turns} ход",
    few = "{1_What} {2_Turns} хода",
    many = "{1_What} {2_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "движение в очереди"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO"] = {
    one = "движение в очереди {1_Dir}, {2_Turns} ход",
    few = "движение в очереди {1_Dir}, {2_Turns} хода",
    many = "движение в очереди {1_Dir}, {2_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} ближний бой"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] =
    "{1_Num} дальний бой, дальность {2_Range}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} дальний бой"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] =
    "дальность {1_Strike}, дальность перебазирования {2_Rebase}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "атаки исчерпаны"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "ходы исчерпаны"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "hp {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "зелёный"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "жёлтый"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "красный"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "заполнен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "уровень {1_Lvl}, {2_Cur}/{3_Next} xp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "улучшить до {1_Name}, {2_Gold} золота"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "продвижения: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    one = "перемещён, {1_Num} ход остался",
    few = "перемещён, {1_Num} хода осталось",
    many = "перемещён, {1_Num} ходов осталось",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "остановился раньше цели"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    one = "остановился раньше цели, {1_Num} ход до прибытия",
    few = "остановился раньше цели, {1_Num} хода до прибытия",
    many = "остановился раньше цели, {1_Num} ходов до прибытия",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "действие не выполнено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] =
    "добавлено в очередь на следующий ход"

-- Alt+QAZEDC prechecks
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] =
    "юнит дальнего боя, используйте дальнюю атаку"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] =
    "воздушный юнит, используйте дальнюю атаку"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "атака невозможна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "атаки исчерпаны"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "ходы исчерпаны"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "самолёт нельзя перемещать таким способом, используйте перебазирование"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "не смежная клетка"

-- Target-specific attack refusals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "атакует только города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] =
    "морской юнит не может атаковать сушу"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] =
    "атака этой цели невозможна"

-- Empty-state tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "нет юнитов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "нет действий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "будет объявлена война"

-- Menu names
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "Действия юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "Активировать клетку"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "Продвижения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "Строить улучшения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE_WITH_REASON"] =
    "недоступно, {1_BuildName}, {2_Reason}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE"] = "недоступно, {1_BuildName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "режим выбора цели"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "добавлено в очередь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] =
    "постановка атаки в очередь невозможна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_PREVIEW"] =
    "Предпросмотр действия для выбранной клетки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_COMMIT"] =
    "Выполнить действие для выбранной клетки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_QUEUE"] = "Shift плюс enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_QUEUE"] =
    "Добавить действие в список заданий юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_CANCEL"] = "Отменить режим выбора цели"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "отмена"

-- Combat preview vocabulary
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "вне досягаемости"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} против {3_TheirStr}, {4_Result}, {5_DmgToMe} урона мне, {6_DmgToThem} им"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "огонь поддержки {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] =
    "шанс захвата {1_Pct} процентов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "мои бонусы {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "их бонусы {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "плюс {1_N} процент {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "минус {1_N} процент {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} против {3_TheirStr}, {4_Result}, {5_DmgToThem} урона им"

-- City-defender preview variants
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "город {1_Name}, {2_MyStr} против {3_TheirStr}, {4_DmgToMe} урона мне, {5_DmgToThem} им"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "город {1_Name}, {2_MyStr} против {3_TheirStr}, {4_DmgToThem} урона им"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} мне"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    one = "{1_N} перехватчик",
    few = "{1_N} перехватчика",
    many = "{1_N} перехватчиков",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "переместиться {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} остаток"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    one = "{1_MP} MP, {2_Turns} ход, {3_Left} остаток",
    few = "{1_MP} MP, {2_Turns} хода, {3_Left} остаток",
    many = "{1_MP} MP, {2_Turns} ходов, {3_Left} остаток",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] =
    "в этот ход, неизведанная территория"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    one = "{1_Turns} ход, неизведанная территория",
    few = "{1_Turns} хода, неизведанная территория",
    many = "{1_Turns} ходов, неизведанная территория",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "в этот ход, {1_Steps} затем неизведанная территория"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    one = "{1_Turns} ход, {2_Steps} затем неизведанная территория",
    few = "{1_Turns} хода, {2_Steps} затем неизведанная территория",
    many = "{1_Turns} ходов, {2_Steps} затем неизведанная территория",
}

-- Combat-with-pathfinding suffix
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] =
    "в этот ход, {1_Steps} затем атака"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    one = "{1_Turns} ход, {2_Steps} затем атака",
    few = "{1_Turns} хода, {2_Steps} затем атака",
    many = "{1_Turns} ходов, {2_Steps} затем атака",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "нет пути"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] =
    "слишком далеко для расчёта"

-- Path-failure diagnostics
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "заблокирован границами {1_Civ}, ближайшая достижимая клетка {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] =
    "заблокирован границами {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] =
    "заблокирован закрытыми границами, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] =
    "заблокирован закрытыми границами"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] =
    "заблокирован {1_Unit}, ближайшая достижимая клетка {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "заблокирован {1_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] =
    "заблокирован юнитом, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "заблокирован юнитом"
-- Fog-of-war variants. When the blocker unit's plot isn't visible to the
-- active team, naming the unit would leak intelligence the sighted UI
-- doesn't expose either. The message says only that the path is blocked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED"] =
    "заблокирован, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED_NO_DIR"] = "заблокирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] =
    "нет пути, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] =
    "нет технологии погрузки, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "нет технологии погрузки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] =
    "требуется астрономия, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "требуется астрономия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] =
    "заблокирован горами, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "заблокирован горами"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] =
    "заблокирован {1_Wonder}, ближайшая достижимая клетка {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "заблокирован {1_Wonder}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] =
    "нет водного сообщения, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "нет водного сообщения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "атака с суши невозможна, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] =
    "атака с суши невозможна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "атака с воды невозможна, ближайшая достижимая клетка {1_Dir}"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] =
    "невозможно атаковать с воды"
-- Naval unit targeting empty / peaceful-occupied non-city land. Same
-- engine block as cantAttackFromWater but no combat intent on the user
-- side, so the framing is "travel" not "attack".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] =
    "невозможно переместиться на сушу, ближайшая достижимая {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] =
    "невозможно переместиться на сушу"
-- Embark / disembark hint appended to a successful move-path preview
-- when the start and destination share a domain but the route crosses
-- the opposite one (land -> water -> land, or water -> land -> water).
-- Cross-domain endpoints (land -> water, water -> land) need no hint
-- because the destination's domain already implies the transition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "требуется посадка на борт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "требуется высадка на берег"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "цели здесь нет"
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
    one = "{1_N} клетка",
    few = "{1_N} клетки",
    many = "{1_N} клеток",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    one = "{1_N} ход",
    few = "{1_N} хода",
    many = "{1_N} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    one = "{1_Tiles} клетка, работа не требуется",
    few = "{1_Tiles} клетки, работа не требуется",
    many = "{1_Tiles} клеток, работа не требуется",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD"] = "маршрут недоступен"
-- Route-to water blocker. The only route-failure cause without a move-to
-- analog -- move-to handles water via embark/astronomy unlocks, whereas
-- BuildRouteValid rejects every water step outright. Mountain and
-- borders reuse PATH_BLOCKED_MOUNTAIN / PATH_BLOCKED_BORDERS_CIV; same
-- cause, same wording, no need for route-flavored duplicates.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER"] =
    "заблокирован водой, ближайшая достижимая клетка {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER_NO_DIR"] = "заблокирован водой"
-- Per-mode "cannot X here" strings for the special interface modes whose
-- legality is the only sighted feedback (highlight tint). Spoken when the
-- engine's per-target Can*At check returns false; legal targets fall
-- through to the destination plot's glance summary instead.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] =
    "десантирование здесь невозможно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] =
    "воздушная переброска здесь невозможна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] =
    "смена базы здесь невозможна"
-- Rebase destination entry in the unit action menu's Rebase drill-in. The
-- menu replaces engine target mode (cursor probe) with a proximity-sorted
-- list of valid destinations so a blind player can pick by name; the
-- distance suffix is the salient distinguishing feature when several
-- candidates share a label (e.g. multiple unnamed Aircraft Carriers).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    one = "{1_Name}, {2_N} клетка",
    few = "{1_Name}, {2_N} клетки",
    many = "{1_Name}, {2_N} клеток",
}
-- Spoken when the user activates the Rebase action menu entry but no
-- friendly cities or air-cargo units are within rebase range. The action
-- itself is available (the unit satisfies canRebase) but no destination
-- qualifies; surface that explicitly rather than letting the entry
-- silently disappear.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] =
    "нет пунктов назначения для смены базы в радиусе досягаемости"
-- Spoken on rebase resolution. The pending machinery normally speaks
-- moveResult ("moved, N moves left" / "stopped short"), but rebase calls
-- finishMoves before setXY so MovesLeft is always 0 -- the moveResult
-- phrasing would imply a partial / failed move. The user already picked
-- the destination by name from the action menu; the confirm names what
-- they picked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "перебазирован в {1_Name}"
-- Airlift sub-menu. Two-stage picker: pick a destination city from this
-- list (own-team cities with airports that have at least one valid hex
-- around them), then the cursor jumps there and target mode opens so the
-- user can pick the exact landing tile (the city plot or any of its six
-- neighbors). Preamble explains the two stages on menu open; DEST is the
-- per-city entry; NO_DESTINATIONS surfaces when the unit can't reach any
-- friendly airport from its current plot.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "Выберите город для переброски юнита по воздуху. После выбора укажите точную клетку приземления - не далее 1 клетки от города."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    one = "{1_Name}, {2_N} клетка",
    few = "{1_Name}, {2_N} клетки",
    many = "{1_Name}, {2_N} клеток",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] =
    "нет доступных пунктов назначения для воздушной переброски"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] =
    "посадка на борт здесь невозможна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] =
    "высадка на берег здесь невозможна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] =
    "ядерный удар здесь невозможен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] =
    "передать юнит здесь невозможно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] =
    "улучшить здесь невозможно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] =
    "видимых перехватчиков нет"
-- Action-affirming legal previews. Spoken on Space when the cursor is on
-- a valid target hex for the active picker, in place of the cursor's
-- tile glance (which the user already heard while navigating). Each
-- mirrors its ILLEGAL counterpart but names what the action will do
-- rather than re-describing what's at the hex. NUKE additionally surfaces
-- the engine's NUKE_BLAST_RADIUS so the user can judge collateral. GIFT_*
-- name the recipient and the gifted unit / connected resource so the
-- Space probe answers "what will happen if I commit here" rather than
-- "what's at this hex."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "воздушная переброска сюда"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "десантирование сюда"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] =
    "ядерный удар сюда, радиус взрыва {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] =
    "передать {1_Unit} цивилизации {2_Recipient}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] =
    "улучшить {1_Resource} для {2_Recipient}"
-- Unit control help overlay entries. Chord labels merge each binding
-- cluster into one line so the ? screen doesn't list six Alt+letter rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Точка, запятая"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] =
    "Переключиться на следующий или предыдущий юнит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Control плюс period или comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "Переключиться на следующий или предыдущий юнит, включая уже выполнивших действие"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Слэш"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] =
    "Прочитать боевые характеристики и продвижения выбранного юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Control плюс slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] =
    "Центрировать курсор клеток на выбранном юните"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "Открыть меню действий юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt плюс Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "Переместить выбранный юнит на одну клетку (двойное нажатие для подтверждения атаки)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt плюс M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "Открыть выбор цели перемещения: наведите курсорными клавишами, пробел для предпросмотра, Enter для подтверждения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt плюс S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] =
    "Укрепить военный юнит или усыпить мирный"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt плюс F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] =
    "Дозор: юнит спит до появления врага в поле зрения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt плюс W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "Разбудить спящий или укреплённый юнит, либо отменить запланированное перемещение или автоматизацию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt плюс X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "Пропустить ход юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt плюс H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] =
    "Лечиться до полного восстановления"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt плюс R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "Открыть выбор цели дальней атаки: наведите курсорными клавишами, пробел для предпросмотра, Enter для подтверждения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt плюс P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "Разграбить клетку юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt плюс U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "Улучшить юнит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt плюс N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "Переименовать юнит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} недоступно"
-- Combat-result payload from the engine fork's CombatResolved hook.
-- Damage values speak absolute-delta ("attacker -8 hp") rather than
-- before/after because the before is already known from the last
-- selection announce.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "атакующий {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "защитник {1_Name} -{2_Dmg} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "атакующий {1_Name} без потерь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "защитник {1_Name} без потерь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} уничтожен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} захвачен"
-- Substituted for the attacker / defender name in AI-vs-AI combat on a
-- visible plot when one side is invisible to the active team (e.g., AI
-- submarine ambushing AI ship). Matches what sighted players perceive:
-- an unseen hit on a visible target. Active-player-involved combats
-- always use full names regardless of invisibility because attacks
-- reveal identity in base game's defender-side messages.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "неизвестный"
-- Air-strike intercept clause. Omitted unless the engine fork's hook
-- reports a landed intercept (interceptorDamage > 0); failed / evaded
-- intercepts surface no clause to match base game's UI.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "перехвачен {1_Name}"
-- Air-sweep prefix. The engine reports combatKind = 1 for sweep into
-- ground AA (one-sided), combatKind = 2 for sweep into another fighter
-- (two-sided dogfight). The prefix lets the user know the combat result
-- they're about to hear came from a sweep they triggered.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "перехват"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "воздушный бой"
-- Air-sweep no-target. Engine fork's CivVAccessAirSweepNoTarget hook
-- fires when the user issues a sweep but no interceptor is in range to
-- engage. Mirrors base game's TXT_KEY_AIR_PATROL_FOUND_NOTHING which
-- lands in the sighted notification log we don't subscribe to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "перехватчиков нет"
-- Nuclear strike speech. Composed from the engine fork's NukeStart /
-- NukeUnitAffected / NukeCityAffected / NukeEnd hook stream. Sections
-- are elided when empty -- a nuke that finds nothing emits the header
-- + NO_TARGETS line; one with city damage but no unit damage drops
-- the units clause. Each entity entry is built from CIV_NAME +
-- HP_DELTA + optional pop / kill / destroy suffixes joined Lua-side.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "ядерный удар {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "цель {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "потери {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "юниты {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "цели не поражены"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} нас."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "уничтожен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "разрушен"
-- City-capture announcements. SerialEventCityCaptured fires for empty
-- city captures (no combat resolution) and for capture-after-defender-
-- killed transitions; the active player's perspective decides which line
-- wins.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "захвачен {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "потерян {1_Name}"
-- Self-plot action confirms. Keyed by action hash token so the menu can
-- dispatch without a per-action if-ladder. FORTIFY / SLEEP / ALERT / WAKE /
-- AUTOMATE / DISBAND / BUILD / PROMOTION map 1:1 to the commit path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "укреплён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "спит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "в дозоре"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "разбужен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "автоматизирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "расформирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "лечится"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "разграблен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "пропущен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "улучшен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "отмена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "начато {1_Build}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "получено продвижение {1_Name}"
-- Generic "this control is currently un-clickable" suffix appended to
-- button labels whose engine control reports IsDisabled. Mirrored from
-- the FrontEnd copy (the front-end Context has its own sandboxed table).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "недоступен"

-- Compositional form: "<label>, disabled" for buttons that surface a
-- pre-composed label (an engine control's GetText / a built-up offer
-- string) plus the disabled marker.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, недоступен"
-- Cursor / hex-grid handler. Direction tokens are short forms (в, св, ...)
-- because experienced screen-reader users prefer shorter speech.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "в"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "св"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "юв"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "юз"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "з"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "сз"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_N"] = "с"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_S"] = "ю"
-- Compact "<count><dir>" glue used by HexGeom.directionString /
-- stepListString to assemble run-length step lists ("2e, 1se, 3nw").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "край карты"
-- Spoken by Cursor.move when civvaccess_shared.mapScope rejects the target.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "край зоны"
-- Tile-state words appended to the cursor glance.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "ничья"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "не исследована"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "туман"
-- Cursor prefix in ranged-attack interface mode when no line of sight.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "невидима"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "столица"
-- Spoken when the user presses Ctrl+S to jump to their capital before
-- founding a city.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "нет столицы"
-- Modified-offset coordinate, capital-relative.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    one = "{1_Moves} ход",
    few = "{1_Moves} хода",
    many = "{1_Moves} ходов",
}
-- River and fresh-water tokens spoken in the cursor's tile glance.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "река {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "река со всех сторон"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "пресная вода"
-- Numbered step on the head-selected unit's queued path.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "путевая точка {1_Index} из {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} разграблено"
-- Macro-terrain tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "холмы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "гора"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "озеро"
-- Generic HP format used wherever a single HP number is spoken without a max.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    one = "{1_Build} {2_Turns} ход",
    few = "{1_Build} {2_Turns} хода",
    many = "{1_Build} {2_Turns} ходов",
}
-- Yield + count glue used by per-plot yields and the surveyor radius sum.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"
-- "Controlled" = plot:GetWorkingCity(): the tile is part of this city's
-- workable area.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "под управлением {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "под управлением"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} процентов защиты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "в зоне контроля врага"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ENEMY_ADJACENT"] = "враг рядом"
-- Cursor help-overlay key labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Группа клавиш Q, W, E, A, S, D, Z, X, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] =
    "Переместить курсор по гексу (Q сз, E св, A з, D в, Z юз, C юв)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] =
    "Цифровая клавиатура 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] =
    "Дублирует Q, W, E, A, S, D, Z, X, C с теми же модификаторами (на цифровой клавиатуре 5 соответствует S, при включённом Num Lock)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] =
    "Прочитать юнит на текущей клетке"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Shift плюс S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "Координаты курсора относительно первоначальной столицы в модифицированной смещённой нотации (каждый шаг на восток прибавляет 1 к x, каждый шаг на северо-восток прибавляет 0.5 к x и 1 к y, каждый шаг на юго-восток прибавляет 0.5 к x и вычитает 1 из y)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Control плюс S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] =
    "Переместить курсор к Вашей столице"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] =
    "Экономические данные текущей клетки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] =
    "Боевые данные текущей клетки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "Идентификация города и бой"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "Производство города и рост"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "Религия города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] =
    "Дипломатические заметки о городе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "Выбрать юнит или открыть экран города (всплывающее окно аннексии для городов-сателлитов, дипломатия с известной крупной цивилизацией) на клетке"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Control плюс I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "Открыть Цивилопедию для всего на клетке курсора (юниты, чудеса света, улучшение, ресурс, особенность, река, озеро, ландшафт, холмы, гора, маршрут)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "Статьи на клетке"
-- City-info speech tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "неизвестен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "можно атаковать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "нет города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "культурный"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "милитаристский"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "морской"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "торговый"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "религиозный"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "нейтральный"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "друг"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "союзник"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "война"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "постоянная война"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    one = "разрушение {1_Turns} ход",
    few = "разрушение {1_Turns} хода",
    many = "разрушение {1_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    one = "сопротивление {1_Turns} ход",
    few = "сопротивление {1_Turns} хода",
    many = "сопротивление {1_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "оккупирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "город-сателлит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "в блокаде"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} населения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} защита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} из {2_Max} hp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "гарнизон {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    one = "производит {1_Name} {2_Turns} ход",
    few = "производит {1_Name} {2_Turns} хода",
    many = "производит {1_Name} {2_Turns} ходов",
}
-- Process production (Wealth / Research / etc.) has no completion turn.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "производит {1_Name}"
-- City development tokens (the "2" key).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "ничего не производит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} из {2_Needed} производства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} за ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    one = "рост через {1_Turns} ход",
    few = "рост через {1_Turns} хода",
    many = "рост через {1_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "голод"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "рост остановлен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} из {2_Threshold} пищи"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} за ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "потеря {1_Num} за ход"
-- Spoken when key 2 fires on a met foreign-major city.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] =
    "производство скрыто, см. обзор шпионажа"
-- City religion tokens (the "3" key).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    one = "через {1_N} торговый путь",
    few = "через {1_N} торговых пути",
    many = "через {1_N} торговых путей",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "нет религии"
-- City diplomatic notes (the "4" key).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "изначально {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] =
    "предупреждение о поджигателе войны: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] =
    "предупреждение об освобождении: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "шпион {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "дипломат {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "нет дипломатических заметок"

-- Spoken when Scanner becomes the top handler: on boot, after a popup
-- closes, after a sub-handler (ScannerInput, UnitActionMenu) pops.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "режим карты"
-- Type-ahead search feedback. Mirrored here because TypeAheadSearch runs
-- from in-game BaseMenu contexts sandboxed from the FrontEnd copy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "нет совпадений для {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "поиск сброшен"
-- ===== Help overlay =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Помощь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Буквы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Вверх или вниз"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home или End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter или пробел"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Влево или вправо"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift плюс влево или вправо"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Ctrl плюс вверх или вниз"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt плюс влево или вправо"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift плюс tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control плюс I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Знак вопроса"
-- Description tokens of the help overlay
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Введите для поиска"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Перемещаться по элементам"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] =
    "Перейти к первому или последнему"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Активировать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] =
    "Изменить значение или перейти вглубь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] =
    "Изменить значение большими шагами"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] =
    "Перейти к предыдущей или следующей группе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Следующая вкладка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Предыдущая вкладка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Прочитать заголовок экрана"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] =
    "Открыть статью Цивилопедии для текущего элемента"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Отмена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Закрыть"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Отменить редактирование"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Применить редактирование"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Control плюс Shift плюс F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Открыть настройки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Закрыть настройки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] =
    "Поставить мод на паузу или возобновить"
-- ===== BaseTable: 2D table viewer =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, по убыванию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, по возрастанию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, сортировка сброшена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "кнопка сортировки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "Перемещаться по строкам"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "Перемещаться по столбцам"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] =
    "Первая или последняя строка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] =
    "Активировать ячейку или сортировать по столбцу"
-- ===== Settings overlay =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Настройки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_UI"] = "Настройки интерфейса"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_CURSOR"] = "Настройки курсора"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_BEACON"] = "Настройки маяка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_SCANNER"] = "Настройки сканера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_NOTIFICATIONS"] = "Уведомления"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Звуковые сигналы местности"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Только речь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Речь и звуковые сигналы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "Подробные сообщения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Только звуковые сигналы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] =
    "Громкость звуковых сигналов местности"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] =
    "Громкость звуковых сигналов местности, {1_Num} процентов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME"] = "Громкость маяка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME_VALUE"] =
    "Громкость маяка, {1_Num} процентов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "Дальность слышимости маяка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] =
    "Дальность слышимости маяка, {1_Num} гексов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] =
    "Автоматическое перемещение курсора сканера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] =
    "Курсор следует за выбранным юнитом"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] =
    "Координаты курсора при движении"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Выкл."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] =
    "Говорить перед объявлением движения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] =
    "Говорить после объявления движения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] =
    "Всегда объявлять территорию в описании клетки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_ENEMY_ADJACENT_WARN"] =
    "Предупреждать о смежном враге"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] =
    "Сканер показывает координаты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COMPASS_DIRECTION"] =
    "Сканер использует компасное направление"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_DIRECTION_BEEP"] =
    "Сканер воспроизводит направленный сигнал"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Читать субтитры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] =
    "Объявлять изменения видимости при движении"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] =
    "Объявлять результаты боёв ИИ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] =
    "Объявлять изменения видимости в начале хода"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "Объявлять лагеря и руины, захваченные другими в поле зрения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_TURN_START_SOUND"] =
    "Воспроизводить звук в начале хода в одиночной игре"
-- ===== Widget-generic strings =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "выбран"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "выбран, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "вкл."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "выкл."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_STATE"] = "{1_Label}, {2_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_VALUE"] = "{1_Label} {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABELED_LIST"] = "{1_Label} {2_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT"] = "{1_Label}, {2_Amount}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE"] = "{1_Label}, {2_Amount}, {3_TurnsLine}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_VALUE_UNIT"] = "{1_Value} {2_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "редактировать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "пусто"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "редактирование {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} восстановлено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "кнопка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "переключатель"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "ползунок"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "поле со списком"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "подменю"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_LINK"] = "ссылка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "таблица"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "{1_Num} из {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "строка {1_Num} из {2_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "столбец {1_Num} из {2_Num}"
-- ===== Screen names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "Меню паузы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "Всплывающее окно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "Уведомление"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "Чудо завершено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "Мировой конгресс"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "Конец игры"
-- ===== End-game ranking =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, очки {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] =
    "{1_Rank} {2_Leader}, ваши очки {3_Score}, {4_Quote}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "Ход {1_Turn}"
-- ===== Diplomacy screens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "Объявить войну"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] =
    "Приветствие города-государства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "Город-государство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "Дипломатия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "Осуждение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "Цель совместной войны"
-- ===== Great Work popup =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "Шедевр"

-- Choose-family popup screen names. Each popup's body text is spoken as preamble from live engine controls; the display name here is just the screen header.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] =
    "Выбор бонуса древних руин"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WARRIOR"] = "Воин"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_POPULATION"] = "Население"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_CULTURE"] = "Культура"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PANTHEON_FAITH"] = "Вера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PROPHET_FAITH"] = "Великий пророк"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_NEARBY_BARBS"] =
    "Раскрыть ближайших варваров"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_GOLD"] = "Золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_LOW_GOLD"] = "Золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HIGH_GOLD"] = "Золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_MAP"] = "Раскрыть ближайшую карту"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_TECH"] = "Бесплатная технология"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_RESOURCE"] =
    "Раскрыть ближайший ресурс"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_UPGRADE_UNIT"] = "Улучшить юнит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SETTLER"] = "Поселенец"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SCOUT"] = "Разведчик"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WORKER"] = "Рабочий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_EXPERIENCE"] = "Опыт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HEALING"] = "Исцелить юнит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] =
    "Выбор бесплатного великого человека"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] =
    "Выбор великого человека за веру"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "Выбор бонуса майя"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "Выбор пантеона"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "Выбор идеологии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "Выбор результата раскопок"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] =
    "Выбор нового порта для адмирала"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] =
    "Выбор нового дома торговой единицы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] =
    "Открытие торгового пути"

-- Confirm-overlay sub-handler pushed on top of a Choose* picker when the player activates an item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "Подтверждение"

-- ChooseReligionPopup (BUTTONPOPUP_FOUND_RELIGION).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "Основать религию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "Укрепить религию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] =
    "Изменить название религии"

-- Belief-slot label formats.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, не выбрано"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, доступно позже"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] =
    "{1_Slot}, только для Византии"

-- Religion-picker row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "религия, не выбрана"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "религия, {1_Name}"

-- Name row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "название, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "название религии"

-- NotificationLogPopup (BUTTONPOPUP_NOTIFICATION_LOG).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "Журнал уведомлений"

-- LeagueProjectPopup (BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "Проект лиги завершён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] =
    "{1_Rank}, {2_Name}, {3_Score} производства, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "золотая награда"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "серебряная награда"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "бронзовая награда"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "без награды"

-- VoteResultsPopup (BUTTONPOPUP_VOTE_RESULTS).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "Результаты голосования"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    one = "{1_Rank}, {2_Name} проголосовал за {3_Cast}, получил {4_Votes} голос",
    few = "{1_Rank}, {2_Name} проголосовал за {3_Cast}, получил {4_Votes} голоса",
    many = "{1_Rank}, {2_Name} проголосовал за {3_Cast}, получил {4_Votes} голосов",
    other = "{1_Rank}, {2_Name} проголосовал за {3_Cast}, получил {4_Votes} голосов",
}

-- WhosWinningPopup (BUTTONPOPUP_WHOS_WINNING).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "Кто побеждает"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"

-- Advisors tutorial banner (Events.AdvisorDisplayShow).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "Советник-наставник"

-- NotificationLogPopup tab labels and item format.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "Активные"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "Журнал хода"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "Отклонённые"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "Нет уведомлений."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, ход {2_Turn}"

-- Combat Log group inside the Turn Log tab.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "Журнал боя"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "Боёв в этом ходу не было."

-- MilitaryOverview (BUTTONPOPUP_MILITARY_OVERVIEW, F3).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur} из {3_Max} оп"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "Снабжение: {1_Use} из {2_Cap}"

-- Idle status fallback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "бездействует"

-- Tab labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "Юниты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "Великие люди"

-- Units tab column headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "Расстояние"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "Ходов осталось"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "Максимум ходов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "Сила"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "Дальний бой"

-- Great People tab.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress} из {4_Threshold}, плюс {5_Rate} в ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] =
    "{1_City}: {2_Progress} из {3_Threshold}, нет прогресса"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "следующий ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    one = "{1_N} ход",
    few = "{1_N} хода",
    many = "{1_N} ходов",
    other = "{1_N} ходов",
}

-- AdvisorCounselPopup (BUTTONPOPUP_ADVISOR_COUNSEL).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "Нет совета."

-- Function-row help entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "Открыть Цивилопедию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "Открыть советника по экономике"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "Открыть военного советника"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] =
    "Открыть советника по дипломатии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] =
    "Открыть экран общественных институтов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "Открыть дерево технологий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "Открыть журнал хода и событий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] =
    "Открыть экран прогресса к победе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "Открыть экран демографии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "Открыть совет советников"

-- CityView hub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "Город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "подключён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} безработных"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "пища {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "производство {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "золото {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "наука {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "вера {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "туризм {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "культура {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Точка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "Следующий город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Запятая"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "Предыдущий город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "нет следующего города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "нет предыдущего города"

-- Hub items that push a sub-handler on Enter.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "Статистика"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "Чудеса"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "Прогресс великих людей"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "Специализация рабочих"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "Безработные: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "Чудес не построено."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] =
    "Нет производства великих людей."

-- Great People progress sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} из {3_Max}"

-- Focus item label when the current focus matches
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, выбран"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "Избегать роста, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "Сбросить назначения клеток"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} выбран"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] =
    "назначения клеток сброшены"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "нет безработных"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "назначен"

-- Buildings sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "Здания"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "Нет зданий."

-- Specialists sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "Специалисты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] =
    "Нет слотов для специалистов."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] =
    "{1_Building} {2_Specialist} слот {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "пусто"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "заполнен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "заполнен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "не заполнен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] =
    "заполнен, работник снят с клетки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] =
    "не заполнен, работник назначен на клетку"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] =
    "нельзя добавить специалиста"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] =
    "Ручное управление специалистами, {1_State}"

-- Great works sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "Шедевры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "изобразительное искусство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "письменность"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "музыка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} слот {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} слот {3_N}, пусто"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} тематический бонус плюс {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "Нет слотов для шедевров."

-- Production queue sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "Очередь производства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "Очередь пуста."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    one = "Слот 1, {1_Name}, {2_Turns} ход, {3_Percent} процент. {4_Help}",
    few = "Слот 1, {1_Name}, {2_Turns} хода, {3_Percent} процент. {4_Help}",
    many = "Слот 1, {1_Name}, {2_Turns} ходов, {3_Percent} процент. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "Слот 1, {1_Name}, {2_Percent} процент. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "Слот 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    one = "Слот {1_N}, {2_Name}, {3_Turns} ход. {4_Help}",
    few = "Слот {1_N}, {2_Name}, {3_Turns} хода. {4_Help}",
    many = "Слот {1_N}, {2_Name}, {3_Turns} ходов. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "Слот {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "Слот {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] =
    "[ICON_PRODUCTION] Производство осталось: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "Действия с {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "Переместить выше"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "Переместить ниже"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "Убрать из очереди"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "Назад"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "перемещён выше"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "перемещён ниже"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "убран"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "Режим очереди, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "Выбрать производство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "Купить за золото или веру"

-- Hex map sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "Управление территорией"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "управление территорией"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "обрабатывается"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "закреплён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "заблокирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "не обрабатывается"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] =
    "доступна для покупки, {1_Gold} золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] =
    "доступна для покупки, {1_Gold} золото, недостаточно средств"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "недостаточно средств"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] =
    "Переместить курсор по клеткам города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] =
    "Обрабатывать или купить клетку"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "Назад в меню города"

-- Ranged strike sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "Дальний удар"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "дальний удар"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "удар невозможен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "выстрел произведён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] =
    "{1_Name}, {2_MyStr} против {3_TheirStr}, {4_Dmg} урона им"
-- Gift-unit / gift-improvement target picker
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "передача юнита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "передача улучшения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "улучшение передано"

-- Rename / Raze hub items
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "Переименовать город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "Разрушить город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "Остановить разрушение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "разрушение остановлено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_TOO_SHORT"] =
    "Имя должно содержать не менее 3 символов. Отменено."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_INVALID_CHARS"] =
    "Имя содержит недопустимые символы. Отменено."

-- Foreign / spy-screen refusals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "шпионаж"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] =
    "переключение городов недоступно во время шпионажа"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "Вы не можете наносить дальние удары за чужой город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "Вы не можете менять производство в чужом городе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "Вы не можете обрабатывать клетки чужого города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] =
    "Вы не можете покупать клетки чужого города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] =
    "Вы не можете продавать здания в чужом городе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] =
    "Вы не можете менять фокус в чужом городе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "Вы не можете управлять специалистами в чужом городе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "Вы не можете просматривать шедевры в чужом городе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "Вы не можете назначать жителей в чужом городе"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "можно купить"

-- Reveal-announce
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_COUNT"] = {
    one = "{1_Num} клетка открыта",
    few = "{1_Num} клетки открыто",
    many = "{1_Num} клеток открыто",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "Открыто"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "Враги: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "Юниты: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "Города: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "Ресурсы: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "Скрыто"

-- Foreign-unit watch
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] =
    "Новые враждебные юниты в поле зрения: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] =
    "Враждебные юниты вышли из поля зрения: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] =
    "Новые нейтральные юниты в поле зрения: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] =
    "Нейтральные юниты вышли из поля зрения: {1_List}"

-- Foreign-clear watch
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] =
    "Другая цивилизация захватила "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " и "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    one = "{1_Num} видимый варварский лагерь",
    few = "{1_Num} видимых варварских лагеря",
    many = "{1_Num} видимых варварских лагерей",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    one = "{1_Num} видимые древние руины",
    few = "{1_Num} видимых древних руин",
    many = "{1_Num} видимых древних руин",
}

-- Gone-on-revisit
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "Исчезло"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    one = "варварский лагерь",
    many = "{1_Num} варварских лагерей",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    one = "древние руины",
    many = "{1_Num} древних руин",
}

-- Turn lifecycle speech
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "Ход завершён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "завершение хода отменено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control плюс пробел"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] =
    "Завершить ход или объявить о первом блокирующем событии и открыть его"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Control плюс Shift плюс пробел"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "Завершить ход, игнорируя запрос о юнитах без приказов; остальные блокирующие события по-прежнему объявляются и открываются"

-- Empire status readouts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "{1_Num} сверх лимита юнитов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    one = "{1_Turns} ход до {2_Tech}, наука +{3_Rate}",
    few = "{1_Turns} хода до {2_Tech}, наука +{3_Rate}",
    many = "{1_Turns} ходов до {2_Tech}, наука +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} завершена, наука +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "нет исследования, наука +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "наука отключена"

-- Plural driven by {4_Avail}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    one = "+{1_Rate} золота, {2_Total} всего, {3_Used} из {4_Avail} торгового маршрута",
    few = "+{1_Rate} золота, {2_Total} всего, {3_Used} из {4_Avail} торговых маршрутов",
    many = "+{1_Rate} золота, {2_Total} всего, {3_Used} из {4_Avail} торговых маршрутов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    one = "минус {1_Rate} золота, {2_Total} всего, {3_Used} из {4_Avail} торгового маршрута",
    few = "минус {1_Rate} золота, {2_Total} всего, {3_Used} из {4_Avail} торговых маршрутов",
    many = "минус {1_Rate} золота, {2_Total} всего, {3_Used} из {4_Avail} торговых маршрутов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "нет {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_STILL_PLAYING"] = "ещё играют: {1_Names}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"

-- Section labels for Shift+letter detail readouts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "Золотой век"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "Религии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "Великие люди"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "Влияние"

-- Empire status readout payloads
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} настроение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "недовольство минус {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] =
    "сильное недовольство минус {1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    one = "золотой век, {1_Turns} ход",
    few = "золотой век, {1_Turns} хода",
    many = "золотой век, {1_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] =
    "{1_Cur} из {2_Threshold} до золотого века"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "настроение отключено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} веры, {2_Total} всего"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "религия отключена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] =
    "{1_Num} веры до следующего пантеона"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "пантеоны недоступны"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] =
    "{1_Num} веры до следующего великого пророка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] =
    "+{1_Pct}% к стоимости технологий за каждый город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] =
    "+{1_Pct}% к стоимости институтов за каждый город"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    one = "+{1_Rate} культуры, {2_Turns} ход до института",
    few = "+{1_Rate} культуры, {2_Turns} хода до института",
    many = "+{1_Rate} культуры, {2_Turns} ходов до института",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] =
    "+{1_Rate} культуры, доступных институтов нет"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] =
    "культуры нет, {1_Cur} из {2_Cost} до следующего института"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "институты отключены"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} туризма"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    one = "+{1_Rate} туризма, влияние на {2_Count} цивилизацию",
    few = "+{1_Rate} туризма, влияние на {2_Count} цивилизации",
    many = "+{1_Rate} туризма, влияние на {2_Count} цивилизаций",
}
-- Plural driven by {3_Total}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    one = "+{1_Rate} туризма, влияние на {2_Count} из {3_Total} цивилизации",
    few = "+{1_Rate} туризма, влияние на {2_Count} из {3_Total} цивилизаций",
    many = "+{1_Rate} туризма, влияние на {2_Count} из {3_Total} цивилизаций",
}

-- Help-overlay entries for empire status readout keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "Ход и дата; лимит юнитов, если он превышен; нехватка стратегических ресурсов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] =
    "Текущее исследование и наука за ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] =
    "Золото за ход, всего и торговые маршруты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "Настроение империи, количество роскоши, обеспечивающей настроение, и золотой век"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "Вера за ход и всего"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] =
    "Культура за ход и время до следующего института"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] =
    "Туризм за ход и число цивилизаций под влиянием"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Shift плюс R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] =
    "Детальный источник науки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Shift плюс G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] =
    "Источники дохода и расходы по золоту"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Shift плюс H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "Источники настроения, источники недовольства и эффект золотого века"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Shift плюс F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "Детальный источник веры и сроки великого пророка или пантеона"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Shift плюс P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] =
    "Детальный источник культуры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Shift плюс I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "Шедевры, свободные ячейки и число цивилизаций под влиянием"

-- Task list readout
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Shift плюс T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] =
    "Прочитать активные задачи сценария"

-- GameMenu tab labels and mod-list payloads
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "Действия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Моды"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "Моды не активированы."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, версия {2_Version}"

-- Civilopedia strings
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "Категории"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "Содержимое"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "Текст статьи недоступен."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] =
    "Нет содержимого для этой записи."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "Запись не выбрана. Перейдите на вкладку категорий, чтобы выбрать одну."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "Введение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "Начало истории."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "Конец истории."

-- Pedia / AdvisorInfo history navigation
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] =
    "Предыдущая или следующая статья в истории"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] =
    "Предыдущая или следующая концепция в истории"

-- SaveMenu
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "Сохранения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "Сведения о сохранении"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "В этом списке нет сохранений."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "Название сохранения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] =
    "Название сохранения пустое или содержит недопустимые символы."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "Перезаписать это сохранение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "Сохранить в этот слот"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "Перезаписать {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] =
    "Перезаписать слот Steam Cloud {1_Num}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "Удалить {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "Сохранение удалено."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Слот Steam Cloud {1_Num}: пусто"

-- Icon spoken replacements
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "пища"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "производство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "культура"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "наука"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "наука"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "вера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "туризм"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "великий человек"
-- Dedup-only alias. Engine source: TXT_KEY_RELIGION_GREAT_PERSON_FOCUS and related
-- base-game strings using the singular "великий человек".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "великих людей"
-- Per-specialist title aliases. Engine source: TXT_KEY_SPECIALIST_<X>_TITLE
-- in CIV5GameTextInfos_Objects.xml. RU_RU prints
-- "Очки великого художника:", "Очки великого инженера:", etc.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "Очки вел.художников:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "Очки вел.инженеров:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "Очки вел.торговцев:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "Очки вел.ученых:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "шедевр"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "боевая мощь"
-- Dedup-only alias. Engine source: TXT_KEY_PRODUCTION_STRENGTH
-- ("[ICON_STRENGTH] Сила: {1_Num}" in RU_RU).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = "к боевой мощи"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "мощь дальнего боя"
-- Dedup-only alias. Engine source: TXT_KEY_PRODUCTION_RANGED_STRENGTH.
-- RU_RU primary and engine emission share the same leading word, so alias is
-- dormant; empty is fine.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = "к мощи дальнего боя"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "передвижение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "настроение"
-- Dedup-only alias. Engine source: TXT_KEY_LOCAL_CITY_HAPPY_TEXT and
-- TXT_KEY_PRODUCTION_BUILDING_HAPPINESS. RU_RU uses "Настроение".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "настроение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "недовольство"
-- Dedup-only alias. RU_RU uses "Недовольство".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "недовольство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "влево"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "вправо"

-- ChooseProduction popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "Выбор производства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "Производить"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "Купить"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "Текущая очередь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "город-сателлит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] =
    "добавлено, слот {1_Slot} в очереди"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "очередь заполнена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "очередь пуста"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "в очереди {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    one = "{1_Num} ход",
    few = "{1_Num} хода",
    many = "{1_Num} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} золота"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} веры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "строим {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "куплено {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    one = "{1_Name}, {2_Turns} ход",
    few = "{1_Name}, {2_Turns} хода",
    many = "{1_Name}, {2_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"

-- ChooseTech popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "Выбор исследования"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] =
    "бесплатная технология, осталось {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "кража у {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "{1_N} науки в ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    one = "сейчас изучается {1_Name}, {2_Turns} ход",
    few = "сейчас изучается {1_Name}, {2_Turns} хода",
    many = "сейчас изучается {1_Name}, {2_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "бесплатно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "сейчас изучается"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "в очереди, слот {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    one = "{1_Num} ход",
    few = "{1_Num} хода",
    many = "{1_Num} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "Открыть дерево технологий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "изучается {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "получено {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "похищено {1_Name}"

-- Tech Tree screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "Дерево технологий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "Все технологии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "Очередь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "изучено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "доступно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "требования не выполнены"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "закрыто"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] =
    "нет текущего исследования, очередь пуста"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "текущее"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "добавлено в очередь: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "уже изучено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] =
    "недоступно в качестве бесплатной технологии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "нельзя похитить"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Вверх/Вниз/Влево/Вправо"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Вверх/Вниз по колонке эпохи, Влево/Вправо по ряду"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Вправо к зависимой технологии, Влево к предпосылке, Вверх/Вниз по смежным"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] =
    "Переключить навигацию: сетка или дерево"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "сетка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "дерево"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] =
    "Исследовать выбранную технологию"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Shift плюс Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] =
    "Добавить выбранную технологию в очередь"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Control плюс I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] =
    "Открыть статью в Цивилопедии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "Буква / цифра / пробел"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] =
    "Печатайте для поиска по названию или открываемому контенту"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "Закрыть дерево технологий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"

-- Tech Tree
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "Закрыть дерево технологий"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "Общественные институты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "Институты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "Идеология"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "открыта"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "завершена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "доступна для принятия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "закрыто, требуется {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] =
    "закрыто, требуется основанная религия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "закрыто"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "заблокировано"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num} из {2_Total} принято"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] =
    "открывающий, выдаётся бесплатно при открытии ветки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] =
    "завершающий, выдаётся при завершении ветки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "принят"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "доступен для принятия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "заблокирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "закрыт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] =
    "закрыт, требуется {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "открыть {1_Branch}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] =
    "{1_Cur} из {2_Cost} культуры, {3_Per} за ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    one = "{1_Turns} ход до следующего института",
    few = "{1_Turns} хода до следующего института",
    many = "{1_Turns} ходов до следующего института",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    one = "доступен {1_Num} бесплатный институт",
    few = "доступно {1_Num} бесплатных института",
    many = "доступно {1_Num} бесплатных институтов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    one = "доступен {1_Num} бесплатный догмат",
    few = "доступно {1_Num} бесплатных догмата",
    many = "доступно {1_Num} бесплатных догматов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] =
    "идеология ещё не принята"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] =
    "идеология отключена в этой игре"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "Догматы 1 уровня"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "Догматы 2 уровня"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "Догматы 3 уровня"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "слот {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "слот {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] =
    "слот {1_Num}, пусто, доступен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
    "слот {1_Num}, пусто, требуется слот {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "слот {1_Num}, пусто, требуется слот {3_Req} уровня {2_Level}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] =
    "слот {1_Num}, пусто, недостаточно культуры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "смена идеологии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] =
    "смена идеологии, недоступно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "недовольство {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "Выбор догмата"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "нет доступных догматов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "Принять {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "Открыть ветку {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "Принять {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "Сменить идеологию?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "принято {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "открыто {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "принят догмат {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] =
    "запрос на смену идеологии отправлен"

-- Number-entry primitive
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Цифры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "Добавить цифру"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "Удалить последнюю цифру"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "Подтвердить количество"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "введите {1_Label}, максимум {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "пусто"

-- Diplomacy trade screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "Торговля"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "Торговля с {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "Ваше предложение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "Их предложение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "Предложено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "Доступно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, население {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "обязательство голосования"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "заключить мир с {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "объявить войну {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "Заключить мир"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "Объявить войну"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "Другие игроки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "нет доступных"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "стол пуст"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "у вас {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "у них {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "мы даём: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "они дают: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "мы дали: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "они дали: {1_List}"

-- DiploCurrentDeals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "Сделки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "Исторические сделки"

-- Diplomatic Overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader} из {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "очки {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "золото {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "золото за ход {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "стратегические: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "предметы роскоши: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "рядом: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "бонусные: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "институты: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "чудеса: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "Великие цивилизации"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "Города-государства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "Цивилизаций не встречено."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "Сделок нет."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "входящее предложение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "ожидание ответа"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "команда {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "исследует {1_Tech}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} влияния"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} за ход"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "закреплено на {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} культуры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} настроения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} веры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} пищи в столице"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} пищи в других городах"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} науки"
-- Plural driven by {1_N} (turns until next gift unit arrives).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    one = "следующий подарочный юнит через {1_N} ход",
    few = "следующий подарочный юнит через {1_N} хода",
    many = "следующий подарочный юнит через {1_N} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "экспорт: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "открытые границы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "можно запугать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "союзник {1_Civ}"

-- F4 Diplomatic Overview tabs (Majors / Minors).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "ваши отношения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "внешние отношения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "ресурсы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "эра"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "институты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "чудеса"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "очки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_DECLARE_WAR"] = "объявить войну"

-- Minor civ columns.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "отношения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "черта и характер"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "влияние"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "союзник"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "задания"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "ближайшие ресурсы"

-- Empty-cell labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "нет"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "никого"

-- Gold cell.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, {2_GPT} за ход"

-- Influence threshold gap fragments.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "{1_N} нужно для дружбы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "{1_N} нужно для союза"

-- Allied-with cell variants.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "вы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] =
    "{1_Civ}, {2_N} нужно для вытеснения"

-- Unmet-ally variant.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] =
    "незнакомая цивилизация, {1_N} нужно для вытеснения"

-- Trait-and-personality cell.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL"] = "{1_Trait}, {2_Personality}"

-- City Stats drillable.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "Производительность"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "Религия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "Торговые пути"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "Ресурсы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "детализация недоступна"

-- Storage / threshold tail.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{1_Cur} из {2_Threshold}"

-- Culture's next-tile countdown.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    one = "следующая клетка через {1_Num} ход",
    few = "следующая клетка через {1_Num} хода",
    many = "следующая клетка через {1_Num} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] =
    "расширение границ остановлено"

-- Happiness one-liner.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] =
    "местное настроение {1_Local}, недовольство {2_Unhappiness}"

-- Religion group.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    one = "{1_Religion}, {2_Followers} последователь, {3_Pressure} давление",
    few = "{1_Religion}, {2_Followers} последователя, {3_Pressure} давление",
    many = "{1_Religion}, {2_Followers} последователей, {3_Pressure} давление",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    one = "{1_Religion}, священный город, {2_Followers} последователь, {3_Pressure} давление",
    few = "{1_Religion}, священный город, {2_Followers} последователя, {3_Pressure} давление",
    many = "{1_Religion}, священный город, {2_Followers} последователей, {3_Pressure} давление",
}

-- Resource group.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RESOURCE_LINE"] = "{1_Name} {2_Num}"

-- ChooseInternationalTradeRoutePopup row format.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
-- Plural driven by {1_Num} (hex distance to destination).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = {
    one = "{1_Num} клетка",
    few = "{1_Num} клетки",
    many = "{1_Num} клеток",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "Вы получаете {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "Они получают {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} получает {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} давление"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] =
    "Нет допустимых направлений."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] =
    "Нет допустимых домашних городов."

-- Trade Route Overview (TRO) screen.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Ctrl плюс T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "Открыть обзор торговых путей"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "Ваши торговые пути"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "Доступные торговые пути"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "Торговые пути с вами"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "торговый караван"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "торговое судно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} - {3_To}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "город-государство {1_City}"
-- Plural driven by {1_Num} (turns until the route resolves).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    one = "{1_Num} ход остался",
    few = "{1_Num} хода осталось",
    many = "{1_Num} ходов осталось",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "Нет путей."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] =
    "Детализация источника недоступна."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "Сортировка: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "Сортировать по"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "золото получено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "наука получена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "пища получена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "производство получено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] =
    "религиозное давление до пункта назначения"

-- Leader descriptions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "Описать лидера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] =
    "Описание этого лидера недоступно."

-- Leader portrait descriptions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "Джордж Вашингтон, первый президент Соединённых Штатов, стоит в интерьере с деревянными панелями между тяжёлыми красными портьерами, отдёрнутыми по обе стороны, его руки свободно опущены к бёдрам. Он облачён в чёрный гражданский костюм американского джентльмена конца восемнадцатого века: тёмный двубортный сюртук с длинными полами, застёгнутый на два ряда латунных пуговиц, под ним такой же жилет, у горла - белый жабо с рюшем, на запястьях - белые манжеты. Волосы напудрены до белизны, зачёсаны назад от высокого лба, завиты у висков над ушами и собраны сзади в косицу, перевязанную чёрной шёлковой лентой. Слева от него большой земной глобус стоит на точёной деревянной подставке; на небольшом столике рядом с подставкой лежит раскрытый переплетённый том с синей закладкой, свисающей между страницами. Справа на светлом каменном камине стоит высокий латунный канделябр с незажжёнными свечами, а над ним в позолоченной раме висит пейзаж. Между раздвинутыми портьерами за его спиной рифлёная колонна поднимается на фоне дневного неба, а вдали видна зелёная холмистая местность. Композиция воспроизводит Лансдаунский портрет работы Гилберта Стюарта 1796 года, где церемониальный меч и государственные бумаги заменены глобусом и книгой."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "Харун ар-Рашид, Повелитель правоверных и пятый халиф Аббасидов, сидит в дворцовом саду поздним утром; мощёный двор за его спиной выходит на светлую каменную колоннаду с заострёнными арками, а сквозь дымку в глубине виднеется далёкий купол. Он бородат, темноволос и восседает на низком резном деревянном кресле, чьи подлокотники завершаются округлыми навершиями; его голова обёрнута высоким шафрановым тюрбаном с мягкой шапочкой поверху. Широкий пояс из той же шафрановой ткани с парчовыми концами, украшенными золотой бахромой, обмотан поперёк груди от правого плеча и собран у левого бедра поверх свободного белого халата, ниспадающего до щиколоток; подол халата окаймлён той же золотой парчой. Правая рука поднята у плеча и держит между большим и указательным пальцами калам - арабское тростниковое перо; левая рука спокойно лежит на коленях. Ноги стоят на круглом ковре, вытканном синими, кремовыми и ржаво-красными медальонами; рядом на каменных плитах лежат два переплетённых кодекса, верхний - в тёмно-красной обложке с золотым тиснением. По обе стороны кресла в покрытых глазурью синих вазах стоят саговники и папоротники, справа поднимается высокая терракотовая урна, а тёмные живые изгороди замыкают средний план под аркадой."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "Ашшурбанипал, Царь Мира, Царь Ассирии, стоит в колонном зале своего дворца; правой рукой он держит у груди вертикально поставленную светлую каменную табличку, пальцы обхватывают её верхний край. Он широкоплеч и обнажён до пояса, кожа его тепло освещена. Длинная борода подстрижена прямоугольником и уложена в тугие параллельные завитки до самой груди; чёрные волосы падают на плечи такими же кольцеобразными локонами. Невысокая золотая диадема опоясывает лоб, её полоса украшена розетками. На нём - длиннополая царская шаль ассирийского двора: тёмно-синяя нижняя роба, усыпанная золотыми розетками, поверх которой накинута тяжёлая пурпурно-малиновая мантия с бахромчатым краем, проходящим по диагонали через торс, через левое плечо и вниз по спине; подолы мантии окаймлены золотым и красным шитьём. Широкие золотые браслеты охватывают оба запястья, такая же перевязь обхватывает правое предплечье. За его спиной в нише, обрамлённой стройными колоннами с бледными волютными капителями, поднимается арка; по обе стороны на постаментах стоят тёмные бородатые фигуры ламасу - человекоголовых крылатых быков, охранявших ворота ассирийских дворцов. На задней стене неглубокие каменные рельефы изображают лошадей в профиль в горизонтальном регистре - в духе охотничье-колесничных панелей его дворца в Ниневии. Пол выложен светлой плиткой, зал уходит в тень по обе стороны."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "Мария Терезия, Божьей милостью вдовствующая императрица Священной Римской империи, королева Венгрии, Богемии, Далмации, Хорватии, Славонии, Галиции и Лодомерии, эрцгерцогиня Австрии (и так далее, и тому подобное), стоит на аркадной каменной лоджии - крытой галерее, высокие округлые арки которой с одной стороны открываются на альпийский пейзаж со снежными вершинами, а с другой - на полированный пол с красной ковровой дорожкой вдоль колоннады. Красные дамасские панно свисают между арками на внутренней стене, и солнечный свет слева бросает длинные тени на камень. Она стоит в три четверти, руки легко скрещены на талии, голова чуть повёрнута в сторону. Волосы светло-золотистые, зачёсаны назад и высоко закреплены в придворном стиле. Платье из бледно-голубовато-серого шёлка; корсаж туго зашнурован до острого мыска на талии и спереди прикрыт стомакером - жёстким декоративным нагрудником, расшитым серебром и мелкими самоцветами. Широкая юбка на фижмах расходится над панье, и та же серебряная вышивка стелется полосой вниз по открытому переднему полотнищу верхней юбки. Рукава завершаются у локтей короткими буфами, отделанными белым кружевом. На плечи наброшен прозрачный кружевной платок, заправленный в вырез. Ни короны, ни видимых украшений на ней нет. За её спиной арки уходят вдаль в светлом камне, балюстрада из точёных столбиков теряется в глубине, Альпы сияют, небо ясно."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "Монтесума Шокойоцин, Уэй Тлатоани мешиков, стоит перед огромной жаровней, чьи языки пламени поднимаются между ним и смотрящим; весь зал вокруг освещён лишь этим огнём. Он обнажён до пояса и крепко сложён, кожа его темна в отблесках огня, лицо наполовину в тени. Его корона - кетцальапанекайотл, плюмаж из длинных переливчатых хвостовых перьев кетцаля в зелёных и синих тонах, стянутых золотым налобником. Золотые катушки вдеты в уши, нефритово-золотой ошейник охватывает шею, широкие нефритово-золотые браслеты охватывают запястья, а золотые перевязи обхватывают оба бицепса. За его спиной в красную каменную кладку вставлен большой резной диск с концентрическими поясами глифов вокруг центрального лика - по образцу ацтекского Камня Солнца. Стены по обе стороны украшены рядами стилизованных черепов - цомпантли, стоек для черепов, выставлявшихся при ацтекских храмах; над каждой стойкой возвышается большая резная маска ацтекского божества, а каменная урна на верхнем краю каждой стены горит высоким пламенем. Весь зал полыхает красным и золотом пляшущего огня."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "Навуходоносор II, Царь Вавилона, восседает на массивном каменном троне в зале с зеленоватой каменной кладкой; стены за его спиной уходят во тьму. На нём агу - высокая закруглённая шапка нововавилонских царей с полосой на уровне лба. Борода длинная, тёмная, уложена ярусными рядами тугих трубчатых завитков. Одежда тёмно-красная, с короткими рукавами, равномерно усыпана золотыми розетками по всему полю и перетянута на талии широким вышитым поясом; юбка падает прямо до босых ног, окаймлённая полосой светлой бахромы. Тяжёлые золотые браслеты охватывают каждое запястье. Руки лежат ладонями вниз на широких подлокотниках трона, завершающихся спереди резными головами львов с оскаленными пастями, обращёнными наружу на уровне колен; меньшая пара таких же голов выступает из основания трона у его ног. По бокам трона стоят два высоких каменных постамента с вырезанными на них свернувшимися змеиными телами; каждый увенчан широкой плоской чашей, из которой поднимается бледно-зелёное пламя - единственный свет в зале, заливающий болезненной зеленью каменные стены, его лицо и его одежду."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "Дон Педру II, Император Бразилии, сидит за широким деревянным письменным столом в тёмном кабинете с панельной обшивкой; сцена выстроена так, словно смотрящий находится напротив него по другую сторону стола. Он немолодой, широкоплечий, грузный мужчина с густой белой бородой, ниспадающей значительно ниже воротника, и редеющими белыми волосами, зачёсанными назад от высокого лба. На нём тёмный сюртук поверх тёмного жилета и белая рубашка с высоким воротником, у горла - тёмный галстук-кравата. На левой стороне груди прикреплена ювелирная звезда Императорского ордена Южного Креста, гроссмейстером которого он являлся. Обе руки лежат на столе ладонями вниз; перед ним рассыпаны листы бумаги и стоит небольшая чернильница, а гусиное перо торчит вертикально в круглой подставке рядом с правой рукой. На столе слева от него стоит зажжённая масляная лампа с высоким прозрачным стеклянным колпаком и полированным латунным основанием - её пламя является самой яркой точкой картины и главным источником света, падающего на его лицо и руки. За его спиной и по сторонам стены от пола до потолка уставлены книжными полками, тонущими в глубокой тени. Высокое окно у его левого плеча сквозь наклонные деревянные жалюзи открывает узкую полосу ночного тёмно-синего неба, на фоне которого темнеют силуэты пальмовых ветвей. В самом левом углу рамы небольшое свинцовое витражное окно с ромбическими стёклами улавливает более тёплые оттенки вечерних сумерек, под ним на полке стоят маленькие каминные часы. Пол застелен узорным ковром в приглушённых красных и золотистых тонах."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "Феодора, Августа римлян, возлежит на низкой кушетке, обитой золотой парчой, на открытой колонной террасе; одна рука свесилась вдоль валика, другая покоится на коленях. Её корона - стемма с самоцветами, куполообразный убор византийского императорского головного убора, чья полоса усажена рядом кабошонов. У лба выделяется крупный зелёный камень, а гребень над ним поднимается ко второму зелёному камню в золотой оправе. Волосы убраны под корону и длинной прядью спадают на правое плечо. Pendilia - жемчужные подвески стеммы - свисают по обе стороны лица; шею охватывает maniakis - ювелирный императорский воротник Востока. Одеяние многослойное: облегающий тёмно-красный корсаж, застёгнутый по центру золотым медальоном; юбка из золотисто-зелёного шёлка с орнаментом в виде завитков, лежащая поперёк колен; под ней - длинная нижняя юбка тёмного сине-зелёного цвета, подол которой окаймлён узкой золотой полосой. На запястьях - золотые браслеты. Справа за её спиной спадает тяжёлый красный занавес, отдёрнутый в сторону, чтобы открыть вид за террасой. Пол террасы выложен тёплым камнем; её края обрамляет резная балюстрада с урнами красных цветов, а вид обрамляют две бледные мраморные колонны. Через широкую долину видна Айя-София: широкий центральный купол в окружении более низкого полукупола, охристые стены в лучах солнца, а низкие холмы синеют позади под ясным небом."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "Дидона, царица-основательница Карфагена, стоит на дворцовой террасе ночью. За её спиной небо глубокого синего цвета, усеянное звёздами; над низким парапетом на горизонте едва угадывается далёкий мыс. У неё за спиной стоит изогнутая каменная скамья, торец которой украшен резным фризом со спиральным орнаментом, а позади неё поднимаются бледные колонны. По краям террасы два высоких куста в светлых каменных вазонах покрыты тёмными листьями и мелкими красными цветами: это гранаты, чьё латинское название punicum делает их деревом Карфагена. Она светлокожа, тёмные волосы разделены прямым пробором и падают ниже плеч; у лба - тонкая золотая диадема. Платье - бледный, почти белый хитон, греческая туника, скреплённая на плечах и перехваченная поясом на талии; длинная до полу юбка покрыта едва заметным тканым узором. Короткие рукава с разрезами застёгнуты через равные промежутки по длине плеча маленькими фибулами, а широкий пояс глубокого синего цвета охватывает талию и длинной полосой свисает по переднему полотнищу юбки. На горле лежит широкий пекторальный нагрудник из тёмных камней в золотой оправе, тонкий золотой браслет охватывает одно запястье. Руки опущены по сторонам, а камень вокруг неё холоден в ночном свете."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "Боудикка, королева иценов, стоит на поросшем травой склоне у вершинного укрепления. Слева - каменная стена, увенчанная деревянным частоколом из заострённых кольев; над ней выглядывает конусообразная соломенная крыша круглого дома. Справа гряда зелёных холмов спускается вниз под тяжёлым серым небом. Волосы у неё коротко острижены и ярко-медно-рыжие; за головой завязана бледная полоса ткани, свободный конец которой свисает за плечо. На скуле под одним глазом - небольшое тёмно-синее пятно: вайда, которую древние британцы использовали как краску для тела. Кельтский торк - витое жёсткое золотое кольцо - охватывает шею. Её одежда - безрукавная туника длиной до колен из сине-зелёной клетчатой ткани, перехваченная на талии кожаным ремнём с круглой пряжкой. На запястьях зашнурованы кожаные наручи, на предплечье - такой же наруч; голени открыты над невысокими кожаными сапогами. В левой руке она держит прямой обоюдоострый короткий меч латенского типа: клинок сужается к острию, рукоять простая и небольшая. Правая рука сжимает прямое древко копья, воткнутого торцом в дёрн. Слева от неё стоит лёгкая двухколёсная колесница с единственным спицевым колесом в железном ободе; из кузова наискосок торчит связка длинных копий."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "У Цзэтянь, Хуанди династии Тан, стоит в центре тёмного зала между тяжёлыми красными занавесями, отдёрнутыми по обе стороны. За её спиной в темноте висит ряд тёплых золотых фонарей, а тёмная стена за ними украшена резными решётчатыми панелями. Чёрные волосы собраны и высоко уложены на голове, спереди закреплены буяо - золотым и жемчужным украшением. На ней жуцюнь, надетый в несколько слоёв. Внутренний халат из бледно-золотистого шёлка перекрещивается на груди над жёстким золотым нагрудником, расшитым медальоном; яркий красный кушак, высоко завязанный под грудью, падает длинной юбкой до пола. Поверх надет внешний халат из тёмно-красного шёлка с узором из золотых медальонов; его широкие рукава свисают ниже кистей, а шлейф подола расстелен по полу вокруг её ног. Обеими руками на уровне пояса она держит небольшой золотой сосуд, слегка приподнятый, словно поднесённый в дар. Лицо у неё бледное, выражение спокойное, взгляд невозмутимый. Красные занавеси, красный халат и золотые фонари согревают раму на фоне тёмного зала."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "Харальд «Синезубый» Гормссон, король данов и Норвегии, стоит на миделе открытой палубы драккара. Он широкоплеч и массивно сложён: рыжевато-русая борода раздваивается на два плетёных хвоста, падающих ниже воротника, усы длинные и поникшие. Голова не покрыта, волосы собраны в пучок на макушке. На плечи накинута мантия из длинного рыжего меха. Под ней он носит сине-серую тунику с более тёмной кокеткой; подол и манжеты отделаны чеканными полосами скандинавского плетёного орнамента. Широкий пояс из тиснёной кожи охватывает талию, застёгнутый тяжёлой квадратной пряжкой; второй ремень наискось пересекает грудь. Обе руки лежат на поясе спереди. Рядом с его ногами на палубе лежит шлем - купол тёмного железа с усиленным назатыльником, наносником и боками, расширяющимися в округлые клапаны из густого рыжего меха. Слева от него форштевень корабля изгибается вверх и внутрь высокой деревянной спиралью, вырезанной в виде головы дракона. За его правым плечом такелажные снасти уходят вниз от мачты; над ними парус висит широкими вертикальными полосами красного и белого. Вдоль планширя круглый деревянный щит закреплён лицевой стороной наружу, с железным умбоном в центре. Небо над ним открытое и синее, расчерченное высокими облаками."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "Рамсес II, фараон Обеих Земель, восседает на троне в вершине короткого марша ступеней; по обе стороны от него раскрывается зал высоких колонн, окрашенных в синий цвет. Его лицо молодо и безбородо, кожа глубокого бронзового тона, глаза обведены тёмной подводкой из кхоля. Головной убор - nemes, полосатый золото-синий плат, плотно собранный у висков и ниспадающий на грудь в плиссированных лопастях. Надо лбом вздымается uraeus - вставшая на хвост кобра, знак царской власти. Через плечи и грудь переброшен wesekh - широкий воротник из рядов нанизанных бусин золота и лазурита. На нём shendyt, фараонская плиссированная юбка из длинного белого льна, перепоясанная у талии широким поясом из золота и синего, что ниспадает по центру спереди жёстким узорным полотнищем. Ноги в сандалиях покоятся на верхней ступени. В левой руке он держит высокий посох, прислонённый к плечу; правая лежит на подлокотнике трона. Фланкирующие его колонны расписаны поясами синего, золотого и красного; их капители выполнены в виде папирусных снопов и покрыты рядами иероглифов и стоящих фигур. Перед троном по обе стороны стоят две большие золотые статуи Исиды и Нефтиды, богинь-хранительниц: их крылья распростёрты и выдвинуты вперёд, а перья переданы длинными позолоченными пластинами. С обеих сторон склоняются пальмовые ветви, а жёлтые каменные ступени у его ног прорезаны рядами мелких треугольных мотивов. Весь зал освещён тёплым золотым светом; синева колонн и воротника - единственные холодные ноты на этом фоне."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "Елизавета I, Божией милостию королева Англии, Франции и Ирландии, Защитница Веры, восседает на высоком резном троне, по обе стороны которого на каменных постаментах стоят два канделябра с незажжёнными свечами. За её спиной поднимается балдахин: тяжёлый красный бархат собран в складки и перехвачен золотыми шнурами с кистями, темнота покоя за ним едва различима. Волосы уложены высоко в тугих завитках рыжевато-русого цвета, скреплённых небольшой ювелирной короной; воротник - жёсткий открытый рёфф позднетюдорского двора. Платье из золотой парчи вышито чёрным; корсаж облегающий, украшенный камнями; рукава пышные у плеча, сужающиеся к кружевным манжетам; юбка широко распростёрта поверх farthingale. Длинные нити жемчуга пересекают её грудь и спускаются от пояса - в её эпоху они носились как символ девственности. Бледные руки покоятся на подлокотниках трона."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "Хайле Селассие I, Император Эфиопии, Избранник Бога, Побеждающий Лев из колена Иудина, стоит в длинном приёмном зале своего дворца. Над головой - светлый кессонный потолок, справа - высокие окна, меж которых подвешена хрустальная люстра. Он строен и держится прямо, с тёмной аккуратной бородой, волосы коротко острижены. На нём тёмный военный китель, застёгнутый до горла, простые тёмные брюки и широкий чёрный кожаный пояс. Через правое плечо к левому бедру проходит широкая изумрудно-зелёная муаровая лента - знак ордена Печати Соломона. На левой груди высоко расположены четыре ряда орденских колодок - боевые и почётные награды, собранные за годы царствования. Ниже свисают две большие нагрудные звезды высших имперских орденов, восьмиконечные, исполненные в золоте и эмали. Левая рука опущена вдоль тела, в правой он держит перчатки. Слева от него стоит императорский трон: кресло с высокой спинкой, обитое светло-кремовой и синей тканью; навершие вырезано в виде арочной короны и задрапировано вышитым полотном; трон установлен на красном узорчатом ковре, протянутом вдоль всего зала. За его спиной вдоль стен уходят в глубину комнаты светлые обитые кресла."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "Наполеон Бонапарт, Император французов, сидит верхом на светло-сером коне в сумеречном поле сухой травы; позади него красновато-коричневое небо и голые деревья. На нём тёмно-синий мундир с тяжёлыми золотыми эполетами, белый жилет, белые кюлоты и высокие чёрные сапоги для верховой езды. Bicorne надет поперёк, два угла развёрнуты к плечам - так он предпочитал носить его, чтобы отличаться от своих офицеров. Уздечка коня из красной кожи с позолоченными заклёпками; нагрудник и вальтрап отделаны красным и золотым. Композиция напоминает «Наполеона на перевале Сен-Бернар» Жака-Луи Давида, но лишена движения: ни вздыбленного скакуна, ни указующей руки - только фигура, одинокая в сумеречном пейзаже."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "Отто фон Бисмарк, министр-президент Пруссии и первый рейхсканцлер Германской империи, стоит в высоком парадном зале, освещённом дневным светом, падающим сквозь переплётные окна за его спиной; каждое стекло разделено на мелкие квадраты тонкими горбылями. Тяжёлые пурпурные гардины задрапированы и перехвачены у каждого окна глубокими складками; изнанка их тёмно-красная. Пол отполирован до зеркального блеска и отражает оконный свет длинными светлыми полосами. Слева от него небольшой столик несёт белую шаровую лампу. Он высок и широкоплеч, на макушке лыс, по бокам и сзади - короткая оторочка серебристо-серых волос; носит густые белые усы, длинные, с загнутыми наружу концами. Мундир - тёмный двубортный форменный сюртук глубокого серо-синего цвета; грудь застёгнута двумя параллельными рядами золотых пуговиц; стоячий воротник отделан золотом; плечи отягощены тяжёлыми эполетами из золотой канители, бахрома которых спускается до верхней части руки. Чуть ниже воротника на тёмной ленте висит небольшой светлый крест - Pour le Merite, высший прусский военный орден за заслуги. Он стоит в три четверти к зрителю, прямо и неподвижно, его взгляд направлен поверх плеча смотрящего."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "Александр Великий, царь Македонии и гегемон эллинов, сидит верхом на своём вороном жеребце Буцефале, сдерживая его на зелёном горном лугу; по обе стороны тянутся гряды серых гор, и лишь одна снежная вершина поднимается справа. Он молод и безбород; каштановые волосы разделены на прямой пробор и приподняты надо лбом в anastole - характерном хохолке, ставшем отличительной чертой его портретов. На нём linothorax, эллинистический нагрудник из слоёного льна и кожи, облицованный позолоченными пластинами; нагрудные нашивки на плечах стянуты к груди короткими шнурами. В центре груди квадратная позолоченная пластина несёт gorgoneion - голову Медузы в рельефе. С плеч и от застёгнутого пояса свисают pteruges - ряды жёстких кожаных полос, защищающих плечи и бёдра; каждая полоса окаймлена красным и увенчана золотой заклёпкой. Руки обнажены; на правом запястье широкий золотой обруч. Шлема нет, оружия на виду нет. Снаряжение коня - тёмная кожа с красной отделкой; налобник и щёчные ремни в заклёпках; в левой руке всадника натянут один повод, перекинутый через шею лошади. Под седлом на боку коня лежит пятнистая леопардовая шкура с нетронутыми лапами."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "Аттила, царь гуннов, сидит на высоком деревянном троне на возвышенном помосте; зал вокруг него освещён в глубоких красных и золотых тонах. Он откинулся назад в непринуждённой позе, нога закинута на ногу, обнажённый меч лежит поперёк колен; одна рука покоится на клинке, другая сжимает кубок. Его туника длиннорукавная, красная, с золотой каймой, надета поверх тёмно-синих шаровар, заправленных в высокие сапоги из мягкой кожи с меховой опушкой по голенищу. На голове конусообразная шапка из тёмного меха, опоясанная золотой лентой. Борода и длинные усы; лицо наполовину освещено справа. Подлокотники трона заканчиваются резными львиными головами; на спинку наброшена тяжёлая шкура. За его спиной стена красных драпировок фланкирована панелями, увешанными бронзовыми дисками разного диаметра, в которых играет отблеск огня. Справа от помоста высокий железный подсвечник горит одной свечой. Дальше на полу большой латунный таз ощетинился рукоятями ножен вертикально поставленных мечей. За ним открытый деревянный сундук рассыпает монеты по узорчатому ковру."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "Пачакути Инка Юпанки, Сапа Инка Тауантинсуйу, восседает на высоком каменном троне на террасе над Мачу-Пикчу; трон вырезан рядами переплетающихся геометрических мотивов, выделенных золотом и красным. Выше и правее него к каменному столбу прикреплён большой золотой солнечный диск: в его центре, в кольце расходящихся лучей, изображено стилизованное человеческое лицо. Слева круто поднимаются голые пики; ниже на ступенчатых земледельческих платформах расположены низкие крытые соломой постройки. На голове у него mascapaycha - красная шерстяная бахрома, падающая на лоб как символ власти Инков; она закреплена повязкой llauto из разноцветных нитей и увенчана пучком прямых красных и тёмных перьев. Волосы чёрные, до плеч. На шее - тяжёлый нагрудный диск из золота. Туника - безрукавное одеяние до колен, покрытое смелым чёрно-белым орнаментом в клетку; грудь отделана красно-золотой кокеткой. Ниже колен ноги перевязаны красными бахромчатыми шнурами. В правой руке он держит высокий посох, увенчанный золотой фигурой птицы; по древку многоярусными рядами свисают красные кисти."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "Мохандас Карамчанд Ганди, Махатма, вождь движения за независимость Индии, стоит на индийском берегу - среди сухой жёлтой травы, скалистого мыса и бледного моря. Он худощав, лыс, в очках, с аккуратно подстриженными седыми усами. На нём одежда поздних лет: простое белое дхоти, обёрнутое у пояса, шаль, переброшенная через одно плечо и проходящая под противоположной рукой; грудь открыта. Ткань некрашеная и самодельная - намеренный отказ от британского сукна, ставший символом его движения. Место действия напоминает долгие пешие переходы, которые он совершал к морю в годы борьбы за независимость: одинокая фигура на краю субконтинента."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "Гаджа Мада, Махапатих империи Маджапахит на Яве, стоит у края затопленного рисового поля; вода зеркально сверкает меж низких зелёных гряд. За его спиной густой тропический лес поднимается по склону, окутанному бледным туманом; из этого тумана выступает стройный ступенчатый силуэт candi - башни-храма из красного кирпича, чья ярусная кровля растворяется в облаках. Он широкоплеч и обнажён до пояса; тёмные волосы собраны в пучок на макушке, на подбородке небольшая бородка. Золотые обручи охватывают каждое плечо и каждое запястье. Широкий пояс высоко лежит на талии, застёгнутый большой фестончатой золотой пластиной, исполненной в цветочном стиле Маджапахит. Ниже пояса красный саронг обёрнут и завязан спереди; тяжёлые складки падают поверх жёлтой нижней ткани, проглядывающей у подола. У правого бедра на шнуре, пропущенном через пояс, висит kris в ножнах: тёмные деревянные ножны сужаются к узкому острию, рукоять выдвинута вперёд под углом."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "Гайавата, основатель Конфедерации Хауденосауни, стоит на освещённой солнцем поляне: за его плечом высится большой серый валун, а тонкие стволы бука и берёзы уходят в зелёные заросли позади. Он строен и гол по пояс, кожа его отливает тёплым коричневым в пятнистом свете. Волосы уложены в скальный пучок: бока головы гладко выбриты, а узкий тёмный гребень проходит спереди назад по темени; в задней части закреплены два прямых пера. Полосы тёмной краски охватывают каждое плечо. На горле плотно сидит ожерелье-чокер из белых раковинных бусин - вампум; единственная лямка пересекает грудь от правого плеча к левому бедру, удерживая колчан со стрелами, оперённые концы которых поднимаются над плечом. На поясе из светло-бежевой оленьей кожи свисает набедренная повязка - длинный передний клапан, закрывающий ноги до середины бедра. Бахромчатые оленьи гетры облегают голени от щиколотки до колена, завязаны под коленом и оставлены открытыми на бедре там, где их прикрывает повязка. Он стоит босиком на утоптанной земле поляны, руки опущены вдоль тела, лесной свет падает на его правый бок."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "Ода Нобунага, даймё клана Ода и первый из великих объединителей, стоит на холмистых зелёных просторах среди высокой травы и редких белых камней; гряда синих гор уходит к горизонту под ярким небом в нагромождении облаков. Голова его выбрита сакаяки: лоб и темя зачищены так, чтобы шлем сидел прохладно и надёжно, оставшиеся волосы собраны сзади. На лице - аккуратные усы и короткая борода на подбородке. Его доспех - тосэй гусоку, современная броня эпохи Сэнгоку: лакированные железные пластины, горизонтальными рядами скреплённые шёлковыми шнурами; кираса и набедренные пластины перевязаны чередующимися полосами тёмно-синего и киноварного. Наплечники из таких же переплетённых пластин нависают над каждой рукой. Поверх надет безрукавный боевой плащ цвета загара, его передние полы раздвинуты и открывают зашнурованную кирасу. Широкий красный кушак завязан на поясе; сквозь него вдет меч лезвием вверх; у правого бока висит второй меч, правая рука лежит на его рукояти. Вместе они составляют дайсё - пару длинного и короткого мечей, которые носит каждый самурай. Из-за правого плеча, переброшенный за спину, поднимается длинное тёмное ложе и тонкий ствол танэгасимы - фитильного огнестрельного оружия, массовое внедрение которого связано с именем Нобунаги. Он стоит один в открытом поле - вокруг лишь трава, камни и далёкие горы."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "Седжон Великий, четвёртый король династии Чосон, сидит в центре приподнятого деревянного помоста в тронном зале, держа обеими руками раскрытую книгу на коленях. На нём конрёнпхо - красное шёлковое одеяние с драконами, которое носили короли Чосона; грудь и плечи украшены золотыми медальонами с четырёхкоготными драконами, края оторочены золотыми завитками. Широкий пояс, отделанный нефритом, пересекает талию. На голове - ыксонгван, жёсткая чёрная газовая шапка с двумя небольшими загнутыми вверх крыльями, поднимающимися сзади наподобие сложенных листьев. Лицо гладко выбрито, если не считать аккуратных тёмных усов и короткой бородки на подбородке. Позади него возвышается Ирворобонгдо - складная ширма с изображением солнца, луны и пяти вершин, которую ставили позади каждого чосонского трона: белый диск луны в левом верхнем углу, красный диск солнца в правом, зубчатые вершины в глубоком зелёном цвете и тёмно-красные сосны, разбегающиеся по нижнему регистру. Сам трон лакирован красным, его боковые панели украшены резными медальонами с тиграми. Красные лакированные балюстрады и столбы обрамляют помост с обеих сторон; бумажные фонари свисают по краям зала, светясь жёлтым; короткие каменные ступени спускаются к зрителю."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "Пакаль - К'инич Жанааб' Пакаль, К'ухуль Ахав Б'ааакаля, Священный владыка Паленке, - стоит на террасе известнякового дворца над своей столицей в полдень; за ним из джунглей поднимаются ступенчатые пирамидальные храмы, их гребни выветрились до бледно-розового. За плечами раскинулся большой заспинный убор - деревянная рама, веером составленная из длинных хвостовых перьев кецаля полосами зелёного, синего и тёмно-красного, закреплённая над прямоугольной плитой с резными и расписными глифами. Головной убор высок и многоярусен, увенчан дополнительными перьями кецаля. Длинные тёмные волосы спадают на плечи. Широкий воротник из резных нефритовых пластин лежит на груди; в его центре висит квадратный нефритовый пектораль; нефритовые расширяющиеся серьги пронзают мочки ушей. Бусинный пояс стягивает на талии килт из связанной ткани и перьев; по бокам свисают перьевые бахромы длиной до колена; сандалии высоко зашнурованы по голени. В левой руке он держит скипетр-марионетку К'авиля - высокий посох, увенчанный небольшой резной головой бога молнии, чей кумир правители майя держали как эмблему царской власти. Слева, у края террасы, стоит широкая каменная жаровня, край которой окружён огарками сожжённых приношений. Город за ним тает в дымке - пирамида за пирамидой спускаются к речной равнине."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "Чингисхан, великий хан монголов, сидит верхом на чёрном коне в открытой степи, показанный по пояс, в три четверти к зрителю. Шлем его высокий и конический, заострённый навершием; тёмный налобник и нащёчники обрамляют тонкие усы и небольшой пучок бороды на подбородке. Доспех - клёпаная монгольская кавалерийская броня; грудь занимает большая круглая бронзовая бляха с чеканным завитым узором; широкие наплечники лежат на плечах, клёпаные полосы охватывают плечи. Тёмный плащ спадает с плеч, его подкладка отливает приглушённым пурпуром там, где он свисает за седлом. Конское снаряжение - простая кожа: скромная уздечка с одним лишь налобником и стянутыми вперёд поводьями. Позади него невысокие зелёные холмы катятся под бледным пасмурным небом; на среднем склоне стоит лагерь из гэров - круглых белых войлочных юрт монголов; вокруг на траве разбросаны светлые пятнышки скота."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "Ахмад аль-Мансур, саадийский султан Марокко, стоит на краю сахарского лагеря под глубоким синим небом. Тонкий серп луны и редкие звёзды повисли над тёмными низкими горными грядами на горизонте. Он бородат, кожа его теплится в свете фонаря, взгляд ровный, обращённый к зрителю. На нём многослойный убор Магриба: длинная белая джеллаба - одеяние до щиколотки с капюшоном, распространённое в Северной Африке. Поверх наброшена сельхам - тонкий шерстяной плащ знатных и правителей; её капюшон откинут и лежит между лопатками. Голова обмотана белым тюрбаном. На груди висит прямоугольная вышитая панель кремового и золотого цвета с геометрическим узором исламского орнамента. Широкий кушак из вертикальных красно-кремовых полос дважды обёрнут вокруг талии и завязан спереди, концы заправлены. Позади и слева большой округлый верблюжий шатёр из тёмной полосатой ткани светится изнутри; приоткрытый полог льёт тёплый оранжевый свет на песок; рядом на песке отдыхают два верблюда. Вдали горит ещё один огонёк, и группа финиковых пальм тянется вверх на фоне гор."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "Виллем I, принц Оранский, отец нидерландской независимости, стоит в облицованном плиткой зале, освещённом высоким свинцовым окном слева, чьи мелкие ромбовидные стёкла обрамлены тяжёлыми красными портьерами, отдёрнутыми в сторону. Пол выложен чёрно-белыми мраморными квадратами. На дальней стене за его спиной висит пейзаж в позолоченной раме: низинная местность под тяжёлым небом, река вьётся среди плоских зелёных полей к далёкому городу. Справа деревянный табурет несёт земной глобус; его латунное меридиональное кольцо ловит оконный свет. Слева письменный стол, покрытый красным сукном, - на нём раскрытая книга в кожаном переплёте и россыпь листов бумаги; за столом стоит кресло с высокой спинкой, обитое синим. Весь интерьер напоминает кабинеты учёных с картин Вермера - 'Географа' и 'Астронома', хотя Виллем принадлежит к поколению, предшествовавшему этому стилю. Это бородатый мужчина средних лет; тёмные волосы коротко острижены под маленькой плоской шапочкой, усы и раздвоенная бородка аккуратно подстрижены; широкий белый гофрированный воротник-руф высится у горла. На плечах - длинный чёрный плащ, откинутый назад справа, чтобы освободить руки. Дублет из тусклого золотого узорного шёлка плотно облегает торс, спереди застёгнут в один ряд. Штаны - разрезные панталоны, сшитые из длинных вертикальных полос красной и белой ткани, уложенных чередующимися полосами поверх объёмной подкладки; заканчиваются на середине бедра. Простые тёмные чулки закрывают голени и встречаются с невысокими кожаными туфлями на узорном полу. В правой руке он держит жезл на уровне груди; левая рука покоится у бедра, где из-под полы плаща едва виднеется рукоять меча."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "Сулейман Великолепный, Кануни Законодатель, султан Османской империи, стоит во дворце Топкапы под ребристым куполом - в зале с заострёнными арками, облицованными бело-голубой изникской плиткой. Лучи дневного света падают из невидимых окон на бледные каменные колонны за его спиной. Он бородат, темноглаз; усы и борода аккуратно подстрижены вокруг тонкого рта. Тюрбан его - высокий круглый кавук, прославивший своего носителя: огромное полотнище белой ткани, намотанное на конический каркас и поднимающееся далеко над лбом. На вершине возвышается соргуч - зелёное перо, знак султанского сана. Поверх исподней одежды на нём длинный кафтан из жёлтого шёлка с бледным тканым узором из лоз и розеток; перед распахнут до пояса. Широкая полоса мягкого серого меха оторачивает его по всей длине - это признак капанице, высшего почётного одеяния. Тёмный пояс пересекает кафтан на талии. В правой руке, поднятой вертикально к груди, он держит переплетённый том в тёмной коже. Другая рука покоится вдоль тела. Зал за ним уходит в тень между облицованными плиткой арками."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "Дарий I Великий, царь царей Ахеменидской империи, стоит на вершине невысокой лестницы у торца великого зала; сверху на него падает луч света. Он широкоплеч и носит густую бороду - длинную, обрезанную прямо и туго завитую. На голове - кидарис, высокая зубчатая корона персидских царей: золотой цилиндр, опоясанный квадратными зубцами. Одеяние - длинное шафраново-жёлтое платье до ног; грудь, манжеты и подол отделаны красной и золотой вышивкой. Красный кушак стягивает его на талии. Массивные золотые нарукавники застёгнуты на каждом бицепсе. По обе стороны от него на постаментах возвышаются два исполинских ламассу - крылатых быка; их тела и сложенные крылья покрыты золотом. Это хранители Ворот всех народов в Персеполе, здесь представленные в упрощённом варианте: человеческая голова уступила место бычьей. Задняя стена украшена низким рельефом с процессией фигур в длинных одеяниях и мягких шапках - по образцу рельефов с данниками на лестнице Ападаны. Камень платформы и ступеней бледно-голубовато-зелёный, углы отмечены золотыми розетками."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "Казимир III Великий, король Польши и последний из королей династии Пястов, стоит в проёме каменной надвратной башни, освещённой железными настенными бра; их пламя бросает тёплый красно-золотой свет на кладку. Он широкоплеч и носит густую бороду - тёмную, коротко подстриженную; взгляд ровный. Корона - золотой обруч с арками, усыпанный красными камнями; арки смыкаются вверху в украшенном самоцветами навершии. На плечах широкая пелерина из белого горностая с мелкими чёрными хвостиками. Под ней мантия - длинное алое одеяние, застёгнутое на груди рядом маленьких золотых пуговиц и опоясанное широким позолоченным поясом. В одной руке он держит золотой скипетр вертикально перед грудью; у бедра висит Щербец - государственный меч Пястов. По обе стороны от него тяжёлые железные цепи спускаются из верхней тьмы вдоль внутренних стен башни. Позади, в арке в глубине камеры, на красном поле изображён увенчанный короной Белый орёл Польши с распростёртыми крыльями. Орёл выполнен тёмным силуэтом на красном фоне, а не привычным серебром. Камень массивный и плотно подогнанный; свет сосредоточен на короле и резко обрывается в затенённых сводах по обе стороны."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "Камехамеха Великий, объединитель Гавайских островов и первый Мо'и королевства, стоит босиком на пляже с белым песком; за ним бирюзовое мелководье защищённой бухты, а вдали поднимается тёмный лесистый хребет. Он высок и крепко сложён, гол по пояс; кожа его глубокого коричневого цвета под тропическим солнцем. С одного плеча свисает аху'ула - перьевой плащ гавайских вождей али'и, насыщенно-красный, ниспадающий почти до щиколоток. Широкая перевязь того же красного цвета пересекает грудь от левого плеча; жёлтая кайма украшена маленькими геометрическими блоками красного. Такой же красно-жёлтый прямоугольник свисает спереди с мало - набедренной повязки, охватывающей бёдра. На голове - махиоле, низкий шлем с гребнем; узкий гребень идёт спереди назад от лба до затылка; шлем красный с жёлтыми полосами и жёлтой полосой у основания. В правой руке он держит высокое деревянное копьё с зазубренным наконечником; левая рука свободно опущена. Справа на песке лежат две ва'а каулуа - полинезийские двухкорпусные мореходные каноэ; два корпуса каждого соединены перевязанными поперечинами. Паруса треугольные: острый угол у основания мачты, верхняя кромка выгибается наружу широкой дугой; парусина светлая, в заплатах. Третье каноэ стоит на якоре дальше в бухте. На берегу за левым плечом стоит крытый соломой хале - гавайский дом на деревянных столбах с крышей из сухой травы, наполовину скрытый в тени листьев кокосовых пальм. Небо над хребтом синее, с высокими белыми облаками."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "Мария I, королева Португалии, Алгарве и португальских владений за морями, стоит на террасе дворца Пена в Синтре, в светлой каменной галерее под рядом тяжёлых романских арок. За их колоннами открывается Атлантический океан. Её платье сшито из тёмно-синего шёлка. Лиф плотно облегает фигуру с заострённой талией, рукава до локтя завершаются белыми манжетами, пышная юбка на паньерах ниспадает широкими складками до каменного пола. Короткий красный плащ застёгнут на плечах и струится позади неё. Через её грудь проходит широкая белая лента с красной каймой - лента португальского Ордена Христа, которую португальские государи носят в качестве великих магистров. По переднему краю ленты проходит полоса ювелирного орнамента. Тёмные волосы уложены высоко, взбиты надо лбом и закреплены эгреткой - небольшим чёрным украшением с вертикальным пером. Правая рука покоится сбоку на рукояти тонкого скипетра, тёмный стержень которого ниспадает вдоль синей юбки. Справа от неё, за балюстрадой, между красными скалами вьётся узкий морской залив. В канале стоят на якоре два прямопарусных нау с убранными парусами. Слева поднимается башня с жёлтыми стенами, увенчанная луковичным куполом из позолоченных и изразцовых полос. Зубчатые жёлтые стены уступами спускаются к террасе, где она стоит. Небо ясное, свет яркого атлантического полудня, и арки обрамляют её: с одной стороны вода, с другой - королевская архитектура."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "Август Цезарь, первый император Рима, сидит на курульном кресле между двумя бронзовыми головами сфинксов, обращёнными гладкими ликами наружу. Он чисто выбрит, тёмные короткие волосы зачёсаны вперёд на лоб в манере, известной по статуе из Примапорты. Toga picta, пурпурная церемониальная тога, надеваемая на римском триумфе, обёрнута поверх белой туники, перекинута через колени и поднята на левое плечо. Вырез туники обшит золотом. Правая рука свободно лежит на одной из голов сфинкса, левая расслабленно покоится на колене. За ним в полутёмном зале с тёмно-красными стенами стоят рифлёные колонны и висят вертикальные стяги красного и золотого цветов. На задней стене круглый бронзовый медальон несёт рельефную львиную голову. Слабые лучи дневного света падают слева на его лицо и грудь, оставляя дальний край зала в тени; две небольшие жаровни на железных подставках по обе стороны от трона тлеют слабым огнём."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "Екатерина II, императрица и самодержица Всероссийская, стоит в Парадном зале Екатерининского дворца в Царском Селе. Её тело повёрнуто в три четверти к зрителю, взгляд спокойный и прямой. Тёмные волосы подобраны и уложены высоко в манере европейского придворного костюма конца XVIII века. Небольшая ювелирная диадема венчает причёску; её зубцы словно воспроизводят в миниатюре высокие арки Большой императорской короны России. Платье - парадный придворный туалет из слоновой кости: плотно скроенный лиф с золотым шитьём по центральной вставке спереди, пышные полурукава тёмно-синего цвета, отделанные у плеча полосами белого горностая. Внизу расстилается широкая юбка, расшитая золотом: двуглавый орёл российского императорского герба рассыпан по ней как повторяющийся мотив. Наискосок через фигуру от правого плеча до левого бедра протянута широкая голубая муаровая лента - знак ордена Святого Андрея Первозванного. Высокие арочные окна вдоль правой стены задрапированы голубыми занавесями, собранными в фалды; лучи дневного света ложатся видимыми полосами на чёрно-белый мраморный пол, отполированный до зеркального блеска. На левой стене позолоченная рокайльная резьба, завитки которой охватывают зеркальные панели."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "Покателло, вождь северо-западных шошонов, сидит на груде выветренных красных валунов у края межгорной котловины. За его спиной тянется плоская равнина, поросшая полынью, до невысоких плоскогорий, силуэтами вырисовывающихся на горизонте под сумеречным небом цвета розы и бледного фиолетового. Он широкоплечий, длинные чёрные волосы разделены прямым пробором и спадают на грудь; сзади в волосы вставлено прямостоящее орлиное перо. Второе тёмное перо поднимается из-за плеча от колчана, притороченного к спине. Рядом с колчаном перекинут короткий деревянный лук, его верхнее плечо выступает над правым плечом. В правой руке он держит длинное копьё, вонзённое тупым концом в скалу; древко обмотано кожей, а у острия свисает тёмная кисть. На торс надет меховой жилет, пересечённый широкой полосой дублёной кожи с рядами бисера, проходящей от правого плеча к левому бедру; на нижнем конце этой полосы висят небольшие ножны для ножа. Верхняя часть рук охвачена рядами серебряных браслетов. Ниже пояса - тёмные кожаные штаны с бахромой, опускающиеся до щиколоток, и набедренная повязка между ними. Левая рука открытой ладонью лежит на бедре; поза спокойная, тяжесть тела оседает на камень. Свет низкий и тёплый, он подчёркивает красноту скал и грань копья; вдали за его спиной простирается полынная страна Большого бассейна - родина шошонов между Скалистыми горами и Сьеррой."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "Рамкхамхэнг Великий, король Сукотаи, стоит в залитом солнцем дворцовом саду. Зелёная дымка тропического леса и бледные силуэты далёких чеди - колоколовидных буддийских ступ Таиланда - поднимаются сквозь низкий туман за его спиной. Он стройный, с обнажённым торсом, кожа тёплого коричневого оттенка, лицо слегка повёрнуто влево с лёгкой улыбкой. Его корона высокая, многоярусная, с острием - чада, коническая корона тайских королей. Широкий золотой нагрудный воротник лежит на плечах и груди, украшенный чеканным орнаментом в виде завитков и инкрустированный в центре одним красным камнем; более узкие золотые обручи охватывают каждое плечо. Белый шёлковый пояс обёрнут и завязан на талии, скрученные концы ниспадают до бёдер. Под ним - набедренная повязка из тёмно-красной ткани с золотым узором; у края подола виден более тёмный нижний слой. Справа от него, у кромки тихого пруда, усыпанного розовыми цветками лотоса на широких плоских листьях, стоит небольшая каменная скульптура: безмятежная голова Будды с опущенными глазами на постаменте в виде бутона лотоса. Светлая песчаная дорожка изгибается влево от него между зарослями кустарников с красными цветами и ведёт обратно к затянутым туманом башням столицы."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "Мухаммад I, Аския Великий из Сонгай, стоит на скалистом обрыве в час заката с длинным клинком, положенным на плечо, и горящим городом за спиной. Он темнокожий, с короткой бородой, взгляд направлен прямо на зрителя. Голова обёрнута таджелмустом - бледно-кремовым сахельским тюрбаном, намотанным высоко и подобранным сбоку. На плечи ниспадает длинный пурпурный бубу - просторный халат с широкими рукавами западноафриканской знати; передняя панель и грудь расшиты плотными узорчатыми полосами из золотой и тёмной нити. Под ним у пояса обёрнут и завязан светлый кушак, его концы свободно свисают на бедро поверх брюк того же пурпурного цвета, что и халат. Меч он держит за рукоять в правой руке, позволяя клинку лежать вдоль плеча; клинок длинный и прямой, со слабым изгибом к острию. Справа местность обрывается к равнине под красно-оранжевым небом, тёмная гора силуэтом выступает против низкого солнца. Слева горит город: глинобитные стены и высокий квадратный минарет, ощетинившийся рядами выступающих деревянных торон - пальмовых балок, торчащих из штукатурки. Пламя взбирается по башне и катится по улицам под ней; меньшие пожары рассыпаются по равнине между городом и обрывом, на котором он стоит."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "Изабелла I, королева Кастилии и Леона, королева-консорт Арагона, стоит в одной из колонных галерей Альгамбры в Гранаде; аркада открывается на сад с подстриженными изгородями и кадочными топиариями, а холмы вдали растворяются в дымке. Стройные парные колонны с резными капителями поднимаются за её спиной в лопастные и фестончатые арки, заполненные ажурной резьбой; пазухи над ними покрыты плотной геометрической и растительной лепниной в бледно-золотых и песочных тонах. Она хрупкая и светлолицая, руки сложены одна поверх другой у пояса. Голова покрыта в кастильской придворной манере: белый вимпл облегает подбородок и горло, белое покрывало уложено поверх волос, а над ним - небольшая закрытая золотая корона с красными и зелёными камнями. На плечи наброшена длинная красная мантия, подбитая и обшитая золотом, спереди распахнутая. Под ней - платье из кремовой парчи с тёмным повторяющимся узором, с плотным лифом и панелью с золотой каймой по центру юбки. На груди там, где мантия расходится, приколот красный камень. Свет - тёплый низкий свет позднего послеполудня; он скользит по лепнине аркады и светлому камню пола галереи."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "Густав II Адольф, король шведов, готов и вендов, Лев Севера, стоит в позолоченных покоях дворца. Рядом с ним глубокий камин горит на расколотых поленьях - тихо и ярко. Он высокий и крепко сложенный, с густой рыжеватой бородой до груди и пышными закрученными усами; волосы зачёсаны назад с высокого лба. На нём надета вороная стальная кираса, чеканенная золочёными полосами по краям и вдоль центрального гребня, поверх баффкота из толстой, светлой, пропитанной маслом воловьей кожи. Доспех продолжается книзу в шарнирные стальные тассеты, расклёшивающиеся до середины бедра поверх жёлтой нижней юбки. Широкая лента из бирюзового шёлка наискосок проходит от правого плеча к левому бедру, завязана узлом и свисает свободной складкой на нагрудник. На запястьях видны небольшие кружевные манжеты, а бриджи над сапогами отделаны оборкой из светлого кружева. Он стоит, отклонившись назад; каждая рука в перчатке покоится на полевом жезле, вонзённом острием в пол перед ним. Позади каминная облицовка резная и позолоченная, полка украшена барочными завитками из листьев аканта. Слева на стене из зелёно-золотой дамасской ткани висят два портрета в золочёных рамах. Ближний изображает бородатого мужчину в тёмных доспехах - Эрика XIV, более раннего шведского короля. Дальний - бледную женщину в светлом придворном платье, Марию Элеонору Бранденбургскую, жену Густава. Под портретами полированный тёмный деревянный стол несёт неглубокую оловянную чашу с горкой фруктов; у ближнего конца стола поднимается высокий бронзовый канделябр с незажжёнными свечами. Комната освещена почти исключительно огнём. Тёплые оранжевые отблески скользят по кирасе, позолоченной лепнине и правой стороне его лица, оставляя дальнюю стену в тени."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "Энрико Дандоло, дож Светлейшей Венецианской республики, стоит на каменном мосту над каналом ночью, одна рука в перчатке прижата к груди. Он стар: длинная седая борода спадает до груди, виски тронуты сединой, лицо в глубоких морщинах. На голове у него corno ducale - жёсткий рогообразный герцогский берет из ржаво-красной парчи, поднимающийся сзади тупым выступом наподобие фригийского колпака; надет он поверх плотно прилегающей белой льняной камауро, край которой виден у лба. На плечи наброшен тяжёлый серый плащ с отделкой из светлого меха, спереди распахнутый и подбитый той же ржаво-красной тканью, что и берет. Под ним - длинная мантия из тёмно-красной парчи, стянутая на талии завязанным золотым шнуром. Перила моста кованые, их панели заполнены стройными заострёнными арками в духе венецианской готики. Позади него канал уходит в темноту, по берегам которого стоят палаццо, чьи окна светятся тёплым оранжевым на фоне синей ночи. Слева у набережной пришвартована узкая гондола; усеянное звёздами небо пробивается сквозь тучи над крышами."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "Чака каСензангакхона, король зулусов, стоит на открытом дворе королевского крааля, ноги твёрдо расставлены, щит выставлен в левой руке, короткое копьё - в правой. Он с обнажённым торсом, темнокожий, мощно сложенный; через грудь перекинуты тонкие нити с мелкими бусинами. На голове - умхкеле, широкий круговой обруч из пятнистого леопардового меха, знак королевского и высшего ранга. Спереди к нему прикреплён вертикальный пучок белых перьев с красными кончиками. На поясе свисает передник из леопардовой шкуры, покрывающий бёдра, а под ним длинные светлые меховые кисти покачиваются у бёдер. Щиколотки тоже охвачены полосами того же пятнистого меха. В левой руке - исихланду, высокий заострённый овальный боевой щит из воловьей кожи; его поверхность пятнистая - коричневая с белым; по центру идёт прямое деревянное древко, закреплённое кожаными петлями. В правой руке, опущенной и готовой к удару, - иклва, короткодревковое колющее копьё с длинным широким лезвием в форме листа. За его спиной изгибается ряд иквакане - купольных ульеобразных хижин зулусского умузи из травы и тростника, чьи плетёные стенки ловят солнечный свет. По обе стороны поляны стоят деревянные столбы, увенчанные черепами длиннорогого скота - могучие расходящиеся рога по-прежнему на месте, богатство и жертвоприношение выставлены у ворот. Земля сухая и светлая, вдали едва виден плосковершинный холм, а небо над головой - ясное бледно-голубое, прочерченное тонкими облаками."

-- Economic Overview (F2 / Domestic Advisor)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "Города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "Золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "Настроение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "Ресурсы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "Население"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "Защита"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "Пища"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "Наука"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "Золото"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "Культура"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "Вера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "Производство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "столица"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "сателлит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "оккупирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "оккупирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "нет записей"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "нет производства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    one = "{1_Turns} ход: {2_Name}",
    few = "{1_Turns} хода: {2_Name}",
    many = "{1_Turns} ходов: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "{1_PerTurn} в ход, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "Золото всего, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "Доходы, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "Расходы, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "Чистый доход в ход, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] =
    "Наука потеряна из-за дефицита золота, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "Города, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "Дипломатия, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "Религия, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "Городские связи, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "Юниты, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "Здания, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "Улучшения, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "Дипломатия, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "Настроение всего, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "Источники настроения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "Предметы роскоши, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "Разнообразие роскоши, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "Бонус за роскошь, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "Прочие бонусы роскоши, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "Настроение от городов, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "Здания, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "Настроение от зданий, гарнизонов, религии и синергии институтов в каждом городе. "
    .. "Ограничено населением города."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "Бонусы чудес, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "Настроение от чудес со специальными эффектами: синергия классов зданий, "
    .. "немодифицированное настроение или бонусы за институты. Большинство зданий "
    .. "настроения входит в раздел 'Здания (за город)', а не сюда."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] =
    "Бонусы в масштабе империи, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "Торговые маршруты, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "Города-государства, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "Институты, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "Религия, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "Природные чудеса, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] =
    "Бонусы за каждый город, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "Настроение от зданий или институтов, дающих фиксированный бонус за каждый ваш город. "
    .. "Умножается на количество городов."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "Мировой конгресс, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "Уровень сложности, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "Недовольство всего, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "Источники недовольства"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    one = "{1_Count} город, {2_Value} недовольства",
    few = "{1_Count} города, {2_Value} недовольства",
    many = "{1_Count} городов, {2_Value} недовольства",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    one = "{1_Count} оккупированный город, {2_Value} недовольства",
    few = "{1_Count} оккупированных города, {2_Value} недовольства",
    many = "{1_Count} оккупированных городов, {2_Value} недовольства",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    one = "{1_Count} гражданин, {2_Value} недовольства",
    few = "{1_Count} гражданина, {2_Value} недовольства",
    many = "{1_Count} граждан, {2_Value} недовольства",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    one = "{1_Count} оккупированный гражданин, {2_Value} недовольства",
    few = "{1_Count} оккупированных гражданина, {2_Value} недовольства",
    many = "{1_Count} оккупированных граждан, {2_Value} недовольства",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "Общественное мнение, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "Разбивка по городам"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "Доступно"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "Использовано"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "Местные"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "Импортировано"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_FROM_CITY_STATES"] = "От городов-государств"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "Экспортировано"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "н/д"

-- Victory Progress (F8 / Who is winning)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "Счёт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "Победы"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "Итого"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, столица потеряна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "Господство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "Наука"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "Дипломатия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "Культура"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "команда {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    one = "{1_Num} ускоритель",
    few = "{1_Num} ускорителя",
    many = "{1_Num} ускорителей",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "кабина пилота"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "криокамера"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "двигатель"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, Аполлон не построен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, Аполлон построен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] =
    "Аполлон построен, деталей нет"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] =
    "{1_Name}, Аполлон построен, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "Аполлон построен, {1_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    one = "{1_Have} из {2_Total} предпосылки изучены",
    few = "{1_Have} из {2_Total} предпосылок изучены",
    many = "{1_Have} из {2_Total} предпосылок изучены",
}

-- Demographics (F9)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, место {2_Rank}, {3_Value}, лучший {4_BestCiv} {5_BestVal}, среднее {6_AvgVal}, худший {7_WorstCiv} {8_WorstVal}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "Валовой национальный продукт"

-- Culture Overview (Ctrl+C)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "Ваша культура"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "Обмен шедеврами"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "Культурная победа"

-- Culture Overview tabs and content (Your Culture tab).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "Влияние игрока"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] =
    "Места раскопок: {1_Visible} видимых, {2_Hidden} скрытых"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    one = "{1_Name}, культура {2_Cul}, туризм {3_Tou}, шедевр {4_Filled} из {5_Total}",
    few = "{1_Name}, культура {2_Cul}, туризм {3_Tou}, шедевры {4_Filled} из {5_Total}",
    many = "{1_Name}, культура {2_Cul}, туризм {3_Tou}, шедевров {4_Filled} из {5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    one = "{1_Name}, культура {2_Cul}, туризм {3_Tou}, шедевр {4_Filled} из {5_Total}, повреждён {6_Pct} процентов",
    few = "{1_Name}, культура {2_Cul}, туризм {3_Tou}, шедевры {4_Filled} из {5_Total}, повреждён {6_Pct} процентов",
    many = "{1_Name}, культура {2_Cul}, туризм {3_Tou}, шедевров {4_Filled} из {5_Total}, повреждён {6_Pct} процентов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "столица"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "город-сателлит"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "оккупирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "Пока нет зданий для шедевров"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "Нет городов"

-- Slot type words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "ячейка для письменности"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] =
    "ячейка для искусства или артефакта"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "ячейка для музыки"

-- Multi-slot and single-slot building entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled} из {4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled} из {4_Total}, бонус тематики плюс {5_Bonus}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, пусто"

-- Per-slot leaf entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, пусто"

-- Work-class words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "письменность"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "искусство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "артефакт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "музыка"

-- Slot tooltips.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class} от {2_Artist}, {3_OriginCiv}, {4_Era}, плюс {5_Cul} культуры, плюс {6_Tou} туризма"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "от {1_Artist}, {2_OriginCiv}, {3_Era}, плюс {4_Cul} культуры, плюс {5_Tou} туризма"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, плюс {4_Cul} культуры, плюс {5_Tou} туризма"

-- GW move flow feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] =
    "отмечен как источник перемещения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "перемещён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "источник перемещения сброшен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] =
    "неверный тип ячейки для текущего источника"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] =
    "нельзя переместить из пустой ячейки"

-- Tab 2 (Swap Great Works).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "Ваши предложения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "Письменность"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "Искусство"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "Артефакт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "не назначено"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "Сбросить назначение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] =
    "Доступно от других цивилизаций"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] =
    "Нет цивилизаций, предлагающих шедевры для обмена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "Нет шедевров для обмена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] =
    "Выберите шедевр другой цивилизации для обмена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "Нет назначенного {1_Type} для обмена на {2_TheirName} из {3_TheirCiv}; назначьте в своих предложениях"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "Обменять Ваш {1_YourName} на {2_TheirName} из {3_TheirCiv}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "обмен отправлен"

-- Tab 3 (Culture Victory).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N} из {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "нет идеологии"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "нет общественного мнения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "Влияние"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "Туризм"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "Идеология"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "Общественное мнение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] =
    "Недовольство от общественного мнения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "Избыток настроения"

-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    one = "до уровня влияния примерно {1_N} ход",
    few = "до уровня влияния примерно {1_N} хода",
    many = "до уровня влияния примерно {1_N} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "Сменить перспективу"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "Уровень влияния"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "Процент влияния"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "Модификатор туризма"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "Темп туризма на них"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "Тенденция"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "генерирует {1_N} туризма за ход, нажмите Enter для переключения на эту перспективу"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] =
    "теперь просматривается с точки зрения {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N} процентов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "Ваш туризм {1_Yours} относительно их накопленной культуры {2_Theirs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N} процентов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "падает"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "стабильна"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "растёт"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "медленно растёт"

-- Hotkey help (Culture Overview).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control плюс C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "Открыть обзор культуры"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] =
    "Обзор культуры недоступен в этой игре"

-- League Overview (World Congress / United Nations).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "Всемирный конгресс"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control плюс L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] =
    "Открыть обзор Всемирного конгресса"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "Статус"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "Предложения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "Эффекты"

-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "Переименовать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(вы)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "хозяин"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    one = "{1_N} делегат",
    few = "{1_N} делегата",
    many = "{1_N} делегатов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "может предлагать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "Дипломат в их столице"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "Нет Всемирного конгресса"

-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] =
    "В этой сессии нет доступных действий."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    one = "{1_N} предложение доступно.",
    few = "{1_N} предложения доступно.",
    many = "{1_N} предложений доступно.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    one = "{1_N} делегат не распределён.",
    few = "{1_N} делегата не распределено.",
    many = "{1_N} делегатов не распределено.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] =
    "В этой сессии нет предложений."

-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "Принять: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "Отменить: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "Предложено {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "Предложено вами"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "Отложено"

-- Vote-state suffix.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "ваш голос: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "воздержаться"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    one = "{1_N} за",
    few = "{1_N} за",
    many = "{1_N} за",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    one = "{1_N} против",
    few = "{1_N} против",
    many = "{1_N} против",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} за {2_Civ}"

-- Slot picker (Propose mode).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "Пустой слот предложения {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "Слот {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "Слот предложения {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] =
    "Действующие резолюции для отмены"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "Резолюции для принятия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "Другие резолюции"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] =
    "Наша оценка голосов за это предложение:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] =
    "Цивилизации, которые одобрят: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] =
    "Цивилизации, которые выступят против: {1_Civs}"

-- Religion Overview. TabbedShell over the engine's BUTTONPOPUP_RELIGION_OVERVIEW:
-- tab 1 Your Religion (status / beliefs / faith / great people / auto-purchase),
-- tab 2 World Religions (one row per founded religion plus OVERALL STATUS footer),
-- tab 3 Beliefs (one Group per religion / pantheon, drilling into beliefs).
-- Screen title and tab names reuse engine TXT_KEY_RELIGION_OVERVIEW and
-- TXT_KEY_RO_TAB_*; only the hotkey-help pair and the world-row composition
-- have no engine equivalent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control плюс R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "Открыть обзор религий"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "Вы основатель {1_Religion}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "догмат {1_Type}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    one = "{1_Religion}, священный город {2_HolyCity}, основана {3_Founder}, {4_NumCities} город",
    few = "{1_Religion}, священный город {2_HolyCity}, основана {3_Founder}, {4_NumCities} города",
    many = "{1_Religion}, священный город {2_HolyCity}, основана {3_Founder}, {4_NumCities} городов",
}

-- Espionage Overview (BNW only). TabbedShell over the engine's
-- BUTTONPOPUP_ESPIONAGE_OVERVIEW: tab 1 agents (flat list, drill in for
-- actions), tab 2 cities (Your / Their groups, drill in for per-column
-- detail with engine tooltips), tab 3 intrigue messages. Screen title and
-- the Your / Their / Agents / View / Coup / Relocate row labels reuse
-- engine TXT_KEY_EO_* keys directly.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Control плюс E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "Открыть обзор шпионажа"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "Агенты"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "Города"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "Интриги"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "Шпионаж в этой игре отключён"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    one = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} ход",
    few = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} хода",
    many = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} ходов",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} погиб"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", дипломат"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "Действия: {1_Rank} {2_Name}"

-- City row pieces. Civ + city + potential + population + spy clause.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "цивилизация {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "город {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "население {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "потенциал {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "базовый потенциал {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "разбивка: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "потенциал неизвестен"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] =
    "город-государство, выборы можно фальсифицировать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] =
    "город-государство, идёт фальсификация выборов"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "агент {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "дипломат {1_Name}"

-- Intrigue row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "Ход {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "от вашего шпиона {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "передано {1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "неизвестно"

-- Move-agent sub.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "Переместить {1_Rank} {2_Name}"

-- Bookmarks: per-session digit-keyed cursor positions. Ctrl + 1-0 saves
-- the cursor cell, Shift + 1-0 jumps there (with scanner backspace return),
-- Alt + 1-0 speaks distance and direction (and capital-relative coord when
-- the scanner coord setting is on -- so empty / saved direction / coord
-- fragments stay byte-identical with the scanner's End readout).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "закладка добавлена"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "нет закладки"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Control плюс цифровая клавиша"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] =
    "Сохранить закладку на позиции курсора в соответствующий слот"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Shift плюс цифровая клавиша"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "Переместить курсор к закладке в этом слоте, Backspace - возврат"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt плюс цифровая клавиша"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "Расстояние и направление от курсора до закладки в этом слоте"

-- Beacons: spatial-audio markers anchored at bookmarked cells. Ctrl+Shift
-- + 1-0 toggles the beacon for that slot. While a beacon is active, a
-- looping point source plays from the bookmark's position with the
-- cursor as listener: pan and pitch encode bearing, volume encodes
-- distance (silent past 30 hexes). The slot number is the same digit
-- the player pressed; phrasing leads with activated / deactivated so
-- the action verb is the distinguishing word per keystroke.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "маяк {1_Slot} активирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "маяк {1_Slot} деактивирован"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] =
    "сначала установите закладку в этот слот"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] =
    "Control плюс Shift плюс цифровая клавиша"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "Переключить пространственный аудиомаяк на закладке в этом слоте"

-- Message buffer: scrollable history of speech-worthy events
-- (notifications, reveals, foreign-unit-watch lines, combat resolutions).
-- [ / ] step within the active filter; Ctrl+ jumps to ends; Shift+ cycles
-- the filter category and re-anchors at the newest matching entry.
-- Filter labels lead the announcement on Shift+, comma-joined to the
-- newest matching entry. Walking off either end of the buffer re-speaks
-- the current entry rather than announcing a separate edge marker, so
-- only the "no messages" key remains for the empty-buffer case.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "Все сообщения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "Уведомления"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "Открытия"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "Бой"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "Чат"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "нет сообщений"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "Левая скобка и правая скобка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] =
    "Предыдущее и следующее сообщение в буфере"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] =
    "Control плюс левая скобка и правая скобка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] =
    "Самое старое и самое новое сообщение в буфере"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] =
    "Shift плюс левая скобка и правая скобка"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "Переключить категорию фильтра буфера, пропуская пустые категории"

-- Multiplayer chat. Backslash toggles a two-tab BaseMenu over DiploCorner's
-- existing chat panel: Messages reads civvaccess_shared._inGameChatLog
-- (newest-first), Compose wraps Controls.ChatEntry as a Textfield committed
-- via base's SendChat. Single-player no-ops with a spoken marker. Chat
-- target types (all / team / whisper) format the inline announce and the
-- MessageBuffer "chat" entries so the user can tell whom a message went to.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Обратная косая черта"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] =
    "Открыть панель чата многопользовательской игры, в одиночной игре не работает"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] =
    "Чат доступен только в многопользовательской игре"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "Чат"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "Сообщения"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "Написать"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "Сообщение"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "Сообщений в чате пока нет"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} команде: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} для {2_To}: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] =
    "Обратная косая черта или Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "Закрыть панель чата"

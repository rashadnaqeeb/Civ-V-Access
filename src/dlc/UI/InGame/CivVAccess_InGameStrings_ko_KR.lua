-- Mod-authored strings, ko_KR overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "문명 V 접근성이 게임 내에서 로드되었습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "모드 일시 정지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "모드 재개"
-- Unit speech.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "추천: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "도시 건설 위치"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "승선한 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} 체력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} 이동력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} 항공기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "승급 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    other = "{1_What} {2_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "이동 대기 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_MOVE_CHUNK"] = {
    other = "이동 대기 중, {2_Turns} 턴: {1_Segments}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_ROUTE_CHUNK"] = {
    other = "{3_RouteName} 대기 중, {2_Turns} 턴: {1_Segments}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO_JOINER"] = ", 다음 "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_ARRIVE"] = ", 도착"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_HERE"] = {
    other = "{1_Turns} 턴 작업 중",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} 근접"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} 원거리, 사거리 {2_Range}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} 원거리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "사거리 {1_Strike}, 재배치 사거리 {2_Rebase}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "공격 소진"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "이동력 소진"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "체력 {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "녹색"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "황색"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "적색"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "가득"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "레벨 {1_Lvl}, {2_Cur}/{3_Next} 경험치"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "{1_Name}으로 업그레이드, {2_Gold} 금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "승급: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    other = "이동 완료, {1_Num} 이동력 남음",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "목표에 못 미침"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    other = "목표에 못 미침, {1_Num} 턴 후 도착",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "행동 실패"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "다음 턴 대기 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "원거리 유닛, 원거리 공격 사용"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "항공 유닛, 원거리 공격 사용"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "공격 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "공격 소진"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "이동력 소진"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "항공기는 이 방법으로 이동 불가, 재배치 사용"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "인접하지 않음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "도시만 공격 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "해군 유닛은 육지를 공격할 수 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "이 대상 공격 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "유닛 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "행동 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "선전포고 예정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "유닛 행동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "타일 활성화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "승급"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "개선 건설"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE_WITH_REASON"] = "사용 불가, {1_BuildName}, {2_Reason}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_UNAVAILABLE"] = "사용 불가, {1_BuildName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "대상 선택 모드"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "대기 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "공격 대기 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_PREVIEW"] = "대상 타일에 대한 행동 미리 보기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_COMMIT"] = "대상 타일에 대한 행동 실행"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_QUEUE"] = "Shift 플러스 Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_QUEUE"] = "유닛의 임무 목록에 행동 추가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_HELP_DESC_CANCEL"] = "대상 선택 모드 취소"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "취소됨"
-- ===== Combat preview.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "사거리 밖"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} 대 {3_TheirStr}, {4_Result}, 내 피해 {5_DmgToMe}, 상대 피해 {6_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "지원 사격 {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "포획 확률 {1_Pct} 퍼센트"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "내 보너스 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "상대 보너스 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "{1_N} 퍼센트 증가 {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "{1_N} 퍼센트 감소 {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} 대 {3_TheirStr}, {4_Result}, 상대 피해 {5_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "도시 {1_Name}, {2_MyStr} 대 {3_TheirStr}, 내 피해 {4_DmgToMe}, 상대 피해 {5_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "도시 {1_Name}, {2_MyStr} 대 {3_TheirStr}, 상대 피해 {4_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "내 피해 {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    other = "요격기 {1_N}대",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "{1_Dir}으로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} 남음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    other = "{1_MP} MP, {2_Turns} 턴, {3_Left} 남음",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "이번 턴, 미탐험 지역"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    other = "{1_Turns} 턴, 미탐험 지역",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "이번 턴, {1_Steps} 후 미탐험"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    other = "{1_Turns} 턴, {2_Steps} 후 미탐험",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] = "이번 턴, {1_Steps} 후 공격"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    other = "{1_Turns} 턴, {2_Steps} 후 공격",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "경로 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "계산하기에 너무 멀리 있음"
-- ===== Path diagnostics.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "{1_Civ} 국경에 막힘, 가장 가까운 도달 가능 위치 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "{1_Civ} 국경에 막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] =
    "폐쇄 국경에 막힘, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "폐쇄 국경에 막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] =
    "{1_Unit}에 막힘, 가장 가까운 도달 가능 위치 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "{1_Unit}에 막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] =
    "유닛에 막힘, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "유닛에 막힘"
-- Fog-of-war variants. When the blocker unit's plot isn't visible to the
-- active team, naming the unit would leak intelligence the sighted UI
-- doesn't expose either. The message says only that the path is blocked.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED"] = "막힘, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_FOGGED_NO_DIR"] = "막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] =
    "경로 없음, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] =
    "승선 기술 없음, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "승선 기술 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] =
    "천문학 필요, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "천문학 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] =
    "산에 막힘, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "산에 막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] =
    "{1_Wonder}에 막힘, 가장 가까운 도달 가능 위치 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "{1_Wonder}에 막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] =
    "수상 연결 없음, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "수상 연결 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "육지에서 공격 불가, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "육지에서 공격 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "수상에서는 공격할 수 없습니다. 가장 가까운 도달 가능한 방향: {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] =
    "수상에서는 공격할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] =
    "육지로 이동할 수 없습니다. 가장 가까운 도달 가능한 방향: {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "육지로 이동할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "승선 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "상륙 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "이 위치에 대상 없음"

-- Route-to preview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TILES_CLAUSE"] = {
    other = "{1_N} 타일",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    other = "{1_N} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    other = "{1_Tiles} 타일, 작업 필요 없음",
}
-- Route-to water blocker. The only route-failure cause without a move-to
-- analog -- move-to handles water via embark/astronomy unlocks, whereas
-- BuildRouteValid rejects every water step outright. Mountain and
-- borders reuse PATH_BLOCKED_MOUNTAIN / PATH_BLOCKED_BORDERS_CIV; same
-- cause, same wording, no need for route-flavored duplicates.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER"] =
    "물에 막힘, 가장 가까운 도달 가능 위치 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_ROUTE_BLOCKED_WATER_NO_DIR"] = "물에 막힘"

-- Special interface mode illegal previews
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "이 위치에 강습할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "이 위치에 공수할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "이 위치로 재주둔할 수 없습니다."

-- Rebase destination and confirmation
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    other = "{1_Name}, {2_N} 타일",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] =
    "사거리 내에 재주둔 가능한 목적지 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "{1_Name}(으)로 재주둔했습니다."

-- Airlift sub-menu
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "이 유닛을 공수할 도시를 선택하십시오. 도시를 선택한 후, 유닛이 착륙할 정확한 타일을 선택하십시오. 도시에서 1타일 이내여야 합니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    other = "{1_Name}, {2_N} 타일",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] = "사용 가능한 공수 목적지 없음"

-- Embark / disembark / nuke / gift illegal previews
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "이 위치에서 승선할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "이 위치에서 상륙할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "이 위치를 핵 공격할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] =
    "이 위치에서 유닛을 증여할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] =
    "이 위치를 개선할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "보이는 요격기 없음"

-- Action-affirming legal previews
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "이 위치로 공수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "이 위치로 강습"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] = "이 위치 핵 공격, 폭발 반경 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "{2_Recipient}에게 {1_Unit} 증여"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] =
    "{2_Recipient}을 위해 {1_Resource} 개선"

-- Unit control help overlay
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "마침표, 쉼표"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "다음 또는 이전 유닛으로 순환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Ctrl 플러스 마침표 또는 쉼표"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "이미 행동한 유닛을 포함하여 다음 또는 이전 유닛으로 순환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "슬래시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] = "선택된 유닛의 전투 및 승급 정보 읽기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Ctrl 플러스 슬래시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] = "선택된 유닛에 육각형 커서 재중심"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "유닛 행동 메뉴 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt 플러스 Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "선택된 유닛을 한 타일 이동 (공격 확인은 두 번 누르기)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt 플러스 M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "이동 목적지 선택기 열기. 방향키로 조준, 스페이스로 미리보기, Enter로 확정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt 플러스 S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] =
    "군사 유닛 방어 태세 또는 민간 유닛 휴식"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt 플러스 F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] =
    "경계. 적이 시야에 들어올 때까지 대기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt 플러스 W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "휴식 중이거나 방어 태세인 유닛을 깨우거나, 대기 중인 이동 또는 자동화 취소"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt 플러스 X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "유닛의 이번 턴 대기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt 플러스 H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "완전히 회복할 때까지 방어 태세"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt 플러스 R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "원거리 공격 목적지 선택기 열기. 방향키로 조준, 스페이스로 미리보기, Enter로 확정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt 플러스 P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "유닛의 타일 약탈"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt 플러스 U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "유닛 업그레이드"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt 플러스 N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "유닛 이름 변경"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} 사용 불가"

-- Combat result announcements
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "공격자 {1_Name} -{2_Dmg} 체력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "방어자 {1_Name} -{2_Dmg} 체력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "공격자 {1_Name} 피해 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "방어자 {1_Name} 피해 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} 전사"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} 포획"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "불명"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "{1_Name}에 의해 요격됨"

-- Air sweep / interception prefixes
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "요격"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "공중전"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "요격기 없음"

-- Nuclear strike
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "{1_Civ} 핵 공격"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "목표 {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "사상자 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "유닛 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "피해 목표 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} 체력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} 인구"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "전사"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "파괴됨"

-- City capture
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "{1_Name} 점령"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "{1_Name} 상실"

-- Unit action confirmations
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "방어 태세"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "휴식 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "경계 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "깨어남"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "자동화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "해체됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "회복 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "약탈"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "대기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "업그레이드됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "취소됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "{1_Build} 시작"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "{1_Name}(으)로 승급"

-- Button state
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "비활성화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, 비활성화"
-- Cursor / hex-grid handler.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "북동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "남동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "남서"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "서"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "북서"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_N"] = "북"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_S"] = "남"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "지도 끝"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "범위 끝"
-- Tile-state words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "무소유"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "미탐험"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "안개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "시야 밖"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "수도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "수도 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    other = "{1_Moves} 이동력",
}
-- River and fresh-water tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "강 {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "강 전방위"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "담수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "경유지 {1_Index}/{2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} 약탈됨"
-- Macro-terrain tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "구릉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "산"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "호수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} 체력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    other = "{1_Build} {2_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "{1_City}이 통제"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "통제"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_IN_CIV_TERRITORY"] = "{1_CivAdjective} 영토 내"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_IN_YOUR_TERRITORY"] = "자국 영토 내"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "방어 {1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "적 통제 지역 내"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NEARBY_ENEMIES"] = {
    other = "인근 적 {1_N}",
}
-- Cursor help-overlay key labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Q, W, E, A, S, D, Z, X, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] =
    "커서 이동 (Q: 북서, E: 북동, A: 서, D: 동, Z: 남서, C: 남동)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] = "숫자 키패드 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] =
    "동일한 보조 키와 함께 Q, W, E, A, S, D, Z, X, C를 반영 (숫자 키패드 5는 S에 해당, NumLock 켜짐)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "현재 타일의 유닛 읽기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Shift+S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "수도 기준 커서 좌표 (동쪽 이동 시 x +1, 북동 이동 시 x +0.5 y +1, 남동 이동 시 x +0.5 y -1)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Ctrl+S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "커서를 수도로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "현재 타일 경제 정보"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "현재 타일 전투 정보"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PATH_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PATH_PREVIEW"] =
    "선택된 유닛의 현재 타일까지 경로 및 이동력 비용 미리 보기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "도시 정보 및 전투"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "도시 생산 및 성장"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "도시 종교"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] = "도시 외교 정보"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "유닛 선택 또는 도시 화면 열기 (괴뢰 도시는 합병 팝업, 만난 주요 문명은 외교)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Ctrl+I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "커서 위치의 항목 문명 백과 열기 (유닛, 불가사의, 개선, 자원, 특징, 강, 호수, 지형, 구릉, 산, 경로)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "타일 항목"
-- City-info speech tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "미접촉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "공격 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "도시 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "문화적"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "군사적"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "해양성"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "상업적"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "종교적"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "중립"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "우호"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "동맹"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "전쟁"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "영구 전쟁"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    other = "파괴 중 {1_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    other = "저항 {1_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "점령"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "괴뢰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "봉쇄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "인구 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "방어 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur}/{2_Max} 체력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "주둔 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    other = "{1_Name} 생산 중 {2_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "{1_Name} 생산 중"
-- City development tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "생산 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur}/{2_Needed} 생산"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "턴당 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    other = "{1_Turns} 턴 후 성장",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "기근"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "성장 정지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur}/{2_Threshold} 식량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "턴당 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "턴당 {1_Num} 손실"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] = "생산 정보 숨김, 첩보 개요 참조"
-- City religion tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    other = "교역로 {1_N}개 경유",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "종교 없음"
-- City diplomatic notes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "원래 {1_Civ} 소속"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "전쟁광 예고: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "해방 예고: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "스파이 {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "외교관 {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "외교적 메모 없음"

-- Map mode
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "지도 모드"

-- Type-ahead search
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "{1_Buffer}에 대한 검색 결과 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "검색 초기화됨"

-- Help overlay
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "도움말"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "문자"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "위 또는 아래"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home 또는 End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter 또는 Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "왼쪽 또는 오른쪽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift 플러스 왼쪽 또는 오른쪽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Control 플러스 위 또는 아래"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt 플러스 왼쪽 또는 오른쪽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift 플러스 Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control 플러스 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "물음표"

-- Help description tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "검색하려면 입력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "항목 간 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "처음 또는 마지막으로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "활성화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "값 조정 또는 하위 항목으로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "값을 큰 단위로 조정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "이전 또는 다음 그룹으로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "다음 탭"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "이전 탭"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "화면 헤더 읽기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "현재 항목의 시빌로피디아 항목 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "취소"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "닫기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "편집 취소"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "편집 확인"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Control 플러스 Shift 플러스 F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "설정 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "설정 닫기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "모드 일시 정지 또는 재개"

-- BaseTable
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, 내림차순"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, 오름차순"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, 정렬 초기화됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "정렬 버튼"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "행 간 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "열 간 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "첫 번째 또는 마지막 행"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "셀 활성화 또는 열 기준 정렬"

-- Settings overlay
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "설정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_UI"] = "UI 설정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_CURSOR"] = "커서 설정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_BEACON"] = "비콘 설정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_SCANNER"] = "스캐너 설정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_GROUP_NOTIFICATIONS"] = "알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "지형 오디오 신호"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "음성만"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "음성 및 오디오 신호"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "상세 음성 안내"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "오디오 신호만"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "지형 오디오 신호 볼륨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "지형 오디오 신호 볼륨, {1_Num} 퍼센트"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME"] = "비콘 볼륨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME_VALUE"] = "비콘 볼륨, {1_Num} 퍼센트"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "비콘 청취 거리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] = "비콘 청취 거리, {1_Num} 헥스"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "스캐너 자동 커서 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "커서가 선택된 유닛을 따라감"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "이동 중 커서 좌표 표시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "꺼짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "이동 알림 전에 읽기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "이동 알림 후에 읽기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] = "타일 읽기 시 항상 영토 알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_ENEMY_ADJACENT_WARN"] = "적과 인접 시 경고"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "스캐너에 좌표 표시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COMPASS_DIRECTION"] = "스캐너 나침반 방향 사용"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_DIRECTION_BEEP"] = "스캐너 방향 신호음 재생"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "자막 읽기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "이동 중 가시성 변화 알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "AI 전투 결과 알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] = "턴 시작 시 가시성 변화 알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "시야 내 다른 세력이 야영지 또는 유적 점령 시 알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_TURN_START_SOUND"] =
    "싱글 플레이에서 턴 시작 시 소리 재생"

-- Widget-generic: Choice / Checkbox / Textfield
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "선택됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "선택됨, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "켜짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "꺼짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_STATE"] = "{1_Label}, {2_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_VALUE"] = "{1_Label} {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABELED_LIST"] = "{1_Label} {2_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT"] = "{1_Label}, {2_Amount}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE"] = "{1_Label}, {2_Amount}, {3_TurnsLine}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_VALUE_UNIT"] = "{1_Value} {2_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "편집"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "비어 있음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "{1_Label} 편집 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} 복원됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "버튼"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "토글"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "슬라이더"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "콤보 상자"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "하위 메뉴"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "테이블"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_LINK"] = "링크"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "{2_Num}개 중 {1_Num}번째"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "{2_Num}행 중 {1_Num}행"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "{2_Num}열 중 {1_Num}열"

-- GameMenu (Esc pause menu)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "일시 정지 메뉴"

-- GenericPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "팝업"

-- Informational popups
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "불가사의 완성"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "세계 의회"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "게임 종료"

-- End-game ranking
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, 점수 {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] = "{1_Rank} {2_Leader}, 내 점수 {3_Score}, {4_Quote}"

-- Replay turn group
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "{1_Turn} 턴"

-- Diplomacy screens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "선전포고"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "도시 국가 인사"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "도시 국가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "외교"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "비난"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "협동 전쟁 대상"

-- Great-work splash
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "위대한 예술품"

-- Choose-family popup screen names
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "고대 유적 보너스 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WARRIOR"] = "전사"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_POPULATION"] = "인구"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_CULTURE"] = "문화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PANTHEON_FAITH"] = "신앙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PROPHET_FAITH"] = "위대한 선지자"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_NEARBY_BARBS"] = "야만인 위치 공개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_LOW_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HIGH_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_MAP"] = "지도 공개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_TECH"] = "무료 기술"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_RESOURCE"] = "자원 공개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_UPGRADE_UNIT"] = "유닛 업그레이드"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SETTLER"] = "개척자"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SCOUT"] = "정찰병"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WORKER"] = "일꾼"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_EXPERIENCE"] = "경험치"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HEALING"] = "유닛 치료"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "위인 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "신앙 위인 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "마야 보너스 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "종교관 세우기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "사상 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "고고학 결과 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "제독 항구 변경"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "거래 유닛 출발지 변경"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "교역로 건설"

-- Confirm-overlay sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "확인"

-- ChooseReligionPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "종교 창시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "종교 강화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "종교 이름 변경"

-- Belief-slot label formats
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, 미선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, 나중에 사용 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, 비잔틴 제국만 가능"

-- Religion-picker row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "종교, 미선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "종교, {1_Name}"

-- Name row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "이름, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "종교 이름"

-- NotificationLogPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "알림 로그"

-- LeagueProjectPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "세계 의회 프로젝트 완료"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} 생산, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "금상 보상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "은상 보상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "동상 보상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "없음"

-- VoteResultsPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "투표 결과"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    other = "{1_Rank}, {2_Name}은 {3_Cast}에 투표, {4_Votes}표 획득",
}

-- WhosWinningPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "이기고 있는 플레이어"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"

-- Advisors tutorial banner
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "튜토리얼 보좌관"

-- NotificationLogPopup tab labels and item format
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "활성"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "턴 기록"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "닫은 알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "알림 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, {2_Turn} 턴"

-- Combat Log group
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "전투 기록"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "이번 턴에 전투 없음."

-- MilitaryOverview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur}/{3_Max} 경험치"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "보급: {1_Use}/{2_Cap}"

-- Idle status fallback
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "대기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_MOVING"] = "이동 중"

-- Tab labels
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "위인"

-- Units tab column headers
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "거리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "남은 이동력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "최대 이동력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "전투력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "원거리 전투력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_ENEMIES_ADJACENT"] = "인접한 적"

-- Great People tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress}/{4_Threshold}, 턴당 {5_Rate} 증가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] = "{1_City}: {2_Progress}/{3_Threshold}, 진행 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "다음 턴"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    other = "{1_N} 턴",
}

-- AdvisorCounselPopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "조언 없음."

-- Function-row help entries
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "시빌로피디아 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "경제 보좌관 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "군사 보좌관 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "외교 보좌관 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "사회 정책 화면 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "기술 트리 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "턴 및 이벤트 기록 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "승리 진행 화면 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "인구 통계 화면 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "보좌관 조언 열기"

-- CityView hub
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "연결됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} 실업"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "식량 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "생산 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "금 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "과학 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "신앙 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "관광 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "문화 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "마침표"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "다음 도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "쉼표"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "이전 도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "다음 도시 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "이전 도시 없음"

-- Hub items
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "통계"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "불가사의"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "위인 진행도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "노동자 집중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "실업: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "건설된 불가사의 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "위인 생성 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur}/{3_Max}"

-- Focus
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, 선택됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "성장 억제, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "타일 배정 초기화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} 선택됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "타일 배정 초기화됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "실업자 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "배정됨"

-- Buildings
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "건물"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "건물 없음."

-- Specialists
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "전문가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "전문가 슬롯 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] =
    "{1_Building} {2_Specialist} 슬롯 {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "비어 있음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "채움"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "채움"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "비어 있음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] =
    "채움, 타일에서 노동자 배정 해제됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] =
    "비어 있음, 노동자 타일에 배정됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "전문가를 추가할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "수동 전문가 관리, {1_State}"

-- Great works
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "위대한 예술품"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "미술"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "문학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "음악"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} 슬롯 {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} 슬롯 {3_N}, 비어 있음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} 테마 보너스 +{2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "위대한 예술품 슬롯 없음."

-- Production queue
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "생산 대기열"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "대기열 비어 있음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    other = "슬롯 1, {1_Name}, {2_Turns} 턴, {3_Percent} 퍼센트. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "슬롯 1, {1_Name}, {2_Percent} 퍼센트. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "슬롯 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    other = "슬롯 {1_N}, {2_Name}, {3_Turns} 턴. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "슬롯 {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "슬롯 {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "[ICON_PRODUCTION] 남은 생산: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "{1_Name} 작업"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "위로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "아래로 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "대기열에서 제거"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "뒤로"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "위로 이동됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "아래로 이동됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "제거됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "대기열 모드, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "생산 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "금 또는 신앙으로 구매"

-- Hex map / Manage territory
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "영토 관리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "영토 관리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "작업 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "고정됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "작업 안 됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "구매 가능, {1_Gold} 금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "구매 가능, {1_Gold} 금, 구매 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "구매 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "도시 타일에서 커서 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "타일 작업 또는 구매"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "도시 허브로 돌아가기"

-- Ranged strike
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "원거리 공격"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "원거리 공격"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "공격 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "발사됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] =
    "{1_Name}, {2_MyStr} 대 {3_TheirStr}, 상대방에게 {4_Dmg} 피해"

-- Gift unit / improvement
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "유닛 증여"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "개선 증여"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "개선 증여됨"

-- Rename / Raze
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "도시 이름 변경"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "도시 파괴"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "파괴 중지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "파괴 중지됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_TOO_SHORT"] = "이름은 3자 이상이어야 합니다. 취소됨."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RENAME_INVALID_CHARS"] =
    "이름에 유효하지 않은 문자가 포함되어 있습니다. 취소됨."

-- Foreign / spying refusals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "스파이 활동 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] =
    "스파이 활동 중에는 도시 전환 사용 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "소유하지 않은 도시에서 원거리 공격을 실행할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "소유하지 않은 도시의 생산을 변경할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "소유하지 않은 도시의 타일을 작업할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] =
    "소유하지 않은 도시의 타일을 구매할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] =
    "소유하지 않은 도시의 건물을 판매할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] =
    "소유하지 않은 도시의 집중을 변경할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "소유하지 않은 도시의 전문가를 관리할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "소유하지 않은 도시의 위대한 예술품을 열람할 수 없습니다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "소유하지 않은 도시에서는 시민을 배치할 수 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "구매 가능"

-- Reveal-announce
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_COUNT"] = {
    other = "{1_Num} 타일 공개됨",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "공개됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "적: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "유닛: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "도시: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "자원: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "숨겨짐"

-- Foreign-unit watch
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] =
    "새로 시야에 들어온 적대적 유닛: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] = "시야에서 사라진 적대적 유닛: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] = "새로 시야에 들어온 중립 유닛: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] = "시야에서 사라진 중립 유닛: {1_List}"

-- Foreign-clear watch
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "다른 문명이 "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " 및 "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "을(를) 점령했습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    other = "가시 범위 내 야만인 주둔지 {1_Num}개",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    other = "가시 범위 내 고대 유적 {1_Num}개",
}

-- Gone-on-revisit
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "사라짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    other = "야만인 주둔지 {1_Num}개",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    other = "고대 유적 {1_Num}개",
}

-- Turn lifecycle
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "턴 종료"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "턴 종료 취소됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control 플러스 Space 또는 Control 플러스 Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] =
    "턴 종료, 또는 첫 번째 차단 항목을 알리고 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] =
    "Control 플러스 Shift 플러스 Space 또는 Control 플러스 Shift 플러스 Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "유닛 명령 필요 알림을 무시하고 턴 종료. 다른 차단 항목은 계속 알리고 열림."

-- Empire status readouts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "유닛 상한 {1_Num} 초과"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    other = "{2_Tech}까지 {1_Turns} 턴, 과학 +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} 완료, 과학 +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "연구 없음, 과학 +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "과학 꺼짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    other = "금 +{1_Rate}, 총 {2_Total}, 교역로 {4_Avail}개 중 {3_Used}개 사용 중",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    other = "금 -{1_Rate}, 총 {2_Total}, 교역로 {4_Avail}개 중 {3_Used}개 사용 중",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "{1_Resource} 부족"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_STILL_PLAYING"] = "플레이 중: {1_Names}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"

-- Section labels for Shift+letter detail readouts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "황금기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "종교"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "위인"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "영향력"

-- Empire status readout payloads
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "행복 +{1_Excess}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "불행 -{1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "극심한 불행 -{1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    other = "황금기 {1_Turns} 턴 남음",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "황금기까지 {2_Threshold}점 중 {1_Cur}점"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "행복도 꺼짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "신앙 +{1_Rate}, 총 {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "종교 꺼짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "다음 만신전까지 신앙 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "사용 가능한 만신전 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "다음 위대한 예언자까지 신앙 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "도시당 기술 비용 +{1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "도시당 정책 비용 +{1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    other = "문화 +{1_Rate}, 다음 정책까지 {2_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "문화 +{1_Rate}, 남은 정책 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] =
    "문화 없음, 다음 정책까지 {2_Cost}점 중 {1_Cur}점"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "정책 꺼짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "관광 +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    other = "관광 +{1_Rate}, {2_Count}개 문명에 영향력 있음",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    other = "관광 +{1_Rate}, {3_Total}개 문명 중 {2_Count}개에 영향력 있음",
}

-- Help-overlay entries for empire status readout keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "턴 및 날짜. 유닛 상한 초과 시 공급 현황과 전략 자원 부족 항목 포함."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "현재 연구 중인 기술과 턴당 과학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "턴당 금, 총 보유량, 교역로 현황"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "제국 행복도, 행복을 제공하는 사치 자원 수, 황금기 현황"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "턴당 신앙과 총 보유량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] = "턴당 문화와 다음 정책까지 남은 시간"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] = "턴당 관광과 영향력 있는 문명 수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Shift 플러스 R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "출처별 과학 세부 내역"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Shift 플러스 G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "출처별 금 수입 및 지출"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Shift 플러스 H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "행복 원천, 불행 원천, 황금기 효과"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Shift 플러스 F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "출처별 신앙 세부 내역과 예언자 또는 만신전 획득 시기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Shift 플러스 P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "출처별 문화 세부 내역"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Shift 플러스 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "걸작, 빈 슬롯, 영향력 있는 문명 수"

-- Task list readout
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Shift 플러스 T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "활성화된 시나리오 임무 읽기"

-- GameMenu (Esc pause menu)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "행동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "모드"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "활성화된 모드가 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, 버전 {2_Version}"

-- Civilopedia (picker/reader)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "분류"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "내용"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "표시할 항목 내용이 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "이 항목에 내용이 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "선택된 항목이 없습니다. 분류 탭으로 이동하여 항목을 선택하십시오."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "소개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "기록의 시작입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "기록의 끝입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "기록에서 이전 또는 다음 항목"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] = "기록에서 이전 또는 다음 개념"

-- SaveMenu
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "저장 목록"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "저장 정보"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "이 목록에 저장 파일이 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "저장 이름"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] =
    "저장 이름이 비어 있거나 유효하지 않은 문자가 포함되어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "이 저장 파일 덮어쓰기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "이 슬롯에 저장"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "{1_Name}을(를) 덮어쓰시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] =
    "Steam Cloud 슬롯 {1_Num}을(를) 덮어쓰시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "{1_Name}을(를) 삭제하시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "저장 파일이 삭제되었습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Steam Cloud 슬롯 {1_Num}: 비어 있음"

-- Icon spoken replacements
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "식량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "생산"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "문화"
-- Dedup alias copied from the game's localized text, not translated (see en_US). "" means the primary spoken form already collapses.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "과학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "과학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "신앙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "관광"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "위인"
-- Dedup alias: engine singular form next to the icon (TXT_KEY_RELIGION_GREAT_PERSON_FOCUS)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "위인"
-- Per-specialist title aliases (TXT_KEY_SPECIALIST_<X>_TITLE in ko_KR Objects XML)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "위대한 예술가 점수:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "위대한 기술자 점수:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "위대한 상인 점수:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "위대한 과학자 점수:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "위대한 예술품"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "전투력"
-- Dedup alias: engine emits "[ICON_STRENGTH] 전투력: N" -- prefix matches primary; dormant in ko_KR
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "원거리 전투력"
-- Dedup alias: engine emits "[ICON_RANGE_STRENGTH] 원거리 전투력: N" -- prefix matches primary; dormant in ko_KR
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "이동력"
-- Dedup alias copied from the game's localized text, not translated (see en_US). "" means the primary spoken form already collapses.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "행복도"
-- Dedup alias: engine emits "[ICON_HAPPINESS_1] 행복: +N" -- shorter form
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "행복"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "불행"
-- Dedup alias: shorter form used in engine texts alongside the unhappy glyph
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "불행"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "왼쪽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "오른쪽"

-- ChooseProduction popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "생산 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "생산"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "구매"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "현재 대기열"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "괴뢰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "추가됨, 대기열 슬롯 {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "대기열 가득"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "대기열 비어 있음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "대기열에 {1_N}개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    other = "{1_Num} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} 금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} 신앙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "{1_Name} 건물"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "{1_Name} 구매됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    other = "{1_Name}, {2_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"

-- ChooseTech popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "연구 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "무료 기술, {1_N}개 남음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "{1_Civ}에서 기술 훔치는 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "턴당 과학 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    other = "현재 {1_Name} 연구 중, {2_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "무료"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "현재 연구 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "대기열 슬롯 {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    other = "{1_Num} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "기술 트리 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "{1_Name} 연구 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "{1_Name} 획득"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "{1_Name} 훔침"

-- Tech Tree screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "기술 트리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "모든 기술"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "대기열"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "연구 완료"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "사용 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "선행 조건 미충족"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "잠김"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "현재 연구 없음, 대기열 비어 있음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "현재"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "{1_Name} 대기 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "이미 연구됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "무료 기술로 사용 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "훔칠 수 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Up/Down/Left/Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Up/Down으로 시대 열 이동, Left/Right으로 행 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Right로 연결 기술, Left로 선행 기술, Up/Down으로 형제 기술 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] = "격자 또는 트리 탐색 전환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "격자"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "트리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "선택한 기술 연구"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Shift 플러스 Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "선택한 기술 대기열에 추가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Control 플러스 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "문명백과 항목 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "문자, 숫자 또는 Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "이름 또는 개발 항목으로 검색"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "기술 트리 닫기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "기술 트리 닫기"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "사회 정책"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "정책"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "이념"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "개방됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "완료됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "채택 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "잠김, {1_Era} 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] = "잠김, 창시된 종교 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "잠김"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num}/{2_Total} 채택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] = "개방 정책, 분기 개방 시 무료 부여"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] = "완성 정책, 분기 완료 시 수여"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "채택됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "채택 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "막힘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "잠김"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "잠김, {1_Prereqs} 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "{1_Branch} 개방"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] = "{2_Cost}문화 중 {1_Cur}, 턴당 {3_Per}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    other = "다음 정책까지 {1_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    other = "무료 정책 {1_Num}개 사용 가능",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    other = "무료 교리 {1_Num}개 사용 가능",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "이념 미채택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "이번 게임에서 이념 비활성화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "레벨 1 교리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "레벨 2 교리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "레벨 3 교리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "슬롯 {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "슬롯 {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] =
    "슬롯 {1_Num}, 비어 있음, 사용 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
    "슬롯 {1_Num}, 비어 있음, 슬롯 {2_Req} 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "슬롯 {1_Num}, 비어 있음, 레벨 {2_Level} 슬롯 {3_Req} 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] =
    "슬롯 {1_Num}, 비어 있음, 문화 부족"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "이념 전환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "이념 전환, 사용 불가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "불행 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "교리 선택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "사용 가능한 교리 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] =
    "{1_Name}을(를) 채택하시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] =
    "{1_Name} 분기를 개방하시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "{1_Name}을(를) 채택하시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "이념을 전환하시겠습니까?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "{1_Name} 채택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "{1_Name} 개방"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "교리 {1_Name} 채택"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "이념 전환 요청됨"
-- Number-entry primitive (BaseMenuNumberEntry)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "숫자 키"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "숫자 추가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "마지막 숫자 삭제"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "수량 확정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "{1_Label} 입력, 최대 {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "비어 있음"
-- Diplomacy trade screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "교역"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "{1_Name}과(와) 교역"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "우리의 제안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "그들의 제안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "제안 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "사용 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, 인구 {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "투표 약속"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "{1_Name}과(와) 평화 협상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "{1_Name}에게 선전포고"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "평화 협상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "선전포고"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "다른 플레이어"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "제안 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "보유: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "상대 보유: {1_Num}"
-- DiploCurrentDeals review labels
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "우리가 제공: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "상대가 제공: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "우리가 제공했음: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "상대가 제공했음: {1_List}"
-- DiploCurrentDeals tab title and the Historical Deals group label
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "협정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "과거 협정"
-- Diplomatic Overview (Relations / Global tabs)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{2_Civ}의 {1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "점수 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "금 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "턴당 금 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "전략 자원: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "사치품: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "인근: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "보너스: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "정책: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "불가사의: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "주요 문명"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "도시 국가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "만난 문명 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "협정 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "수신 제안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "응답 대기 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "팀 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "{1_Tech} 연구 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} 영향력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "턴당 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "{1_N}에 고정"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} 문화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} 행복도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} 신앙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "수도에 +{1_N} 식량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "다른 도시에 +{1_N} 식량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} 과학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    other = "{1_N} 턴 후 선물 유닛 도착",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "{1_List} 수출 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "국경 개방"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "위협 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "{1_Civ}의 동맹"

-- F4 Diplomatic Overview tabs: Major civ columns
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "우리와의 관계"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "외교 관계"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "자원"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "시대"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "정책"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "불가사의"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "점수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_DECLARE_WAR"] = "선전포고"

-- F4 Diplomatic Overview tabs: Minor civ columns
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "관계"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "특성 및 성격"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "영향력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "동맹 대상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "퀘스트"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "인근 자원"

-- Empty-cell labels
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "없음"

-- Gold cell
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold} 금, 턴당 {2_GPT}"

-- Influence threshold gap fragments
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "우호 관계까지 {1_N} 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "동맹까지 {1_N} 필요"

-- Allied-with cell variants
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "우리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, 교체까지 {2_N} 필요"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] = "미접촉 문명, 교체까지 {1_N} 필요"

-- Trait-and-personality cell
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL"] = "{1_Trait}, {2_Personality}"

-- City Stats drillable groups
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "산출"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "종교"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "교역로"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "자원"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "상세 내역 없음"

-- Storage / threshold tail
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{1_Cur}/{2_Threshold}"

-- Culture next-tile countdown
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    other = "{1_Num} 턴 후 타일 확장",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "타일 확장 중단"

-- Happiness one-liner
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] = "지역 행복도 {1_Local}, 불행 {2_Unhappiness}"

-- Religion group rows
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    other = "{1_Religion}, 신자 {2_Followers}명, 압력 {3_Pressure}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    other = "{1_Religion}, 성도, 신자 {2_Followers}명, 압력 {3_Pressure}",
}

-- Resource group row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RESOURCE_LINE"] = "{1_Name} {2_Num}"

-- ChooseInternationalTradeRoutePopup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = {
    other = "{1_Num} 헥스",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "획득: {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "상대 획득: {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} 획득: {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} 압력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "유효한 목적지가 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "유효한 본거지 도시가 없습니다."

-- Trade Route Overview (TRO) screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Control 플러스 T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "교역로 현황 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "내 교역로"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "사용 가능한 교역로"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "나와의 교역로"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "대상"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "화물선"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From}에서 {3_To}까지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "도시 국가 {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    other = "{1_Num} 턴 남음",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "교역로 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "출처 세부 정보 없음."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "정렬 기준: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "정렬 기준"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "금 수령량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "과학 수령량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "식량 수령량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "생산 수령량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "목적지로의 종교적 압력"

-- Leader descriptions
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "지도자 묘사"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "이 지도자에 대한 설명이 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "미국의 초대 대통령 조지 워싱턴은 양쪽으로 묶어 젖힌 짙은 붉은 휘장 사이, 패널 벽으로 둘러싸인 실내에 서 있으며, 두 손은 허리 옆으로 자연스럽게 드리워져 있습니다. 그는 18세기 말 미국 신사의 검은 평복 차림입니다. 허벅지까지 길게 내려오는 어두운 색의 더블브레스트 코트 앞면에는 놋쇠 단추가 두 줄로 달려 있으며, 그 아래에는 같은 색의 조끼가 받쳐 입혀져 있습니다. 목에는 주름 장식이 달린 흰 자보가, 손목에는 흰 커프스가 드리워져 있습니다. 머리카락은 분을 발라 흰빛으로 손질되어 있으며, 높은 이마에서 뒤로 빗겨 넘기고 귀 위에서 컬로 말아 올린 뒤 검은 실크 리본으로 묶은 큐에 모아 두었습니다. 왼쪽에는 선반 위에 대형 지구의가 놓여 있으며, 그 옆 작은 탁자 위에는 펼쳐진 책 한 권이 있고 파란 리본 책갈피가 페이지 사이에서 흘러내려 있습니다. 오른쪽에는 연한 돌 벽난로 선반 위에 불이 꺼진 긴 초가 꽂힌 놋쇠 촛대가 높이 서 있고, 그 위에는 금박 액자에 담긴 풍경화가 걸려 있습니다. 그의 뒤로 양쪽으로 갈라진 휘장 사이에 홈이 파진 기둥 하나가 낮 하늘을 배경으로 솟아 있으며, 저 멀리 완만한 초록 들판이 엿보입니다. 이 구도는 1796년 길버트 스튜어트가 그린 랜스다운 초상화를 재연한 것으로, 원화의 의식용 검과 국가 문서 대신 지구의와 책으로 대체되어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "신자들의 지도자이자 압바스 왕조 제5대 칼리파 하룬 알라시드는 아침 늦게 궁전 정원에 앉아 있습니다. 그의 뒤로는 포장된 안뜰이 뾰족한 아치로 이루어진 연한 돌 열주랑으로 이어지며, 아득한 저편에 안개 너머로 원형 돔 하나가 솟아 있습니다. 그는 수염을 기르고 검은 머리카락을 가진 인물로, 끝이 둥근 장식으로 마무리된 낮은 조각 목재 의자에 앉아 있습니다. 머리에는 꼭대기에 부드러운 모자가 올라간 높은 사프란색 터번을 두르고 있습니다. 같은 사프란 천으로 만들어진 넓은 띠는 양 끝에 금사로 짠 브로케이드와 술 장식이 달려 있으며, 오른쪽 어깨에서 가슴을 가로질러 두르고 왼쪽 허리에서 묶인 뒤 발목까지 내려오는 헐렁한 흰 로브 위를 감싸고 있습니다. 로브의 단에도 같은 금 브로케이드 띠가 둘러져 있습니다. 오른손은 어깨 가까이 들어 올려 엄지와 검지 사이에 아랍의 갈대 펜인 칼람을 쥐고 있으며, 왼손은 무릎 위에 편평하게 놓여 있습니다. 발아래에는 파랑, 크림, 녹슨 갈색의 메달리온 문양이 짜인 원형 카펫이 깔려 있으며, 그 옆 포석 위에는 제본된 책 두 권이 놓여 있고 맨 위 것은 금박이 새겨진 진한 붉은 표지입니다. 의자 양쪽에는 유약을 입힌 파란 화분에 소철과 고사리가 심어져 있고, 오른쪽에는 테라코타 항아리가 높이 솟아 있으며, 아케이드 아래 중간 거리에는 어두운 생울타리가 늘어서 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "세계의 왕이자 아시리아의 왕 아슈르바니팔은 기둥이 늘어선 궁전 홀에 서 있으며, 오른손으로 연한 돌 서판을 세워 가슴에 대고 손가락을 윗면 가장자리에 걸쳐 쥐고 있습니다. 그는 어깨가 넓고 팔이 드러나 있으며, 빛 아래에서 피부색이 따뜻하게 빛납니다. 수염은 길고 네모지게 다듬어져 있으며 가슴까지 촘촘한 평행 컬로 손질되어 있고, 검은 머리카락은 같은 스타일의 링렛으로 어깨까지 흘러내립니다. 이마에는 장미꽃 문양이 새겨진 낮은 금 다이어뎀이 둘러져 있습니다. 그는 아시리아 궁정의 발목 길이 왕실 숄을 걸치고 있는데, 금 장미꽃 문양이 흩어진 진한 파란색 안쪽 로브 위에 무거운 마젠타색 망토를 두르고 있습니다. 망토의 술 달린 가장자리는 몸통을 대각선으로 가로질러 왼쪽 어깨 너머로 등 아래로 흘러내리며, 단에는 금색과 붉은색 자수가 놓여 있습니다. 넓은 금 커프스가 양 손목을 감싸고, 오른쪽 상완에는 같은 모양의 밴드가 둘려 있습니다. 그의 뒤로는 연한 소용돌이 주두를 가진 가느다란 기둥으로 테를 두른 아치형 벽감이 솟아 있으며, 양쪽 받침대 위에는 아시리아 궁전 문을 지키던 인면 유익 황소상인 라마수의 어두운 수염 달린 형상이 서 있습니다. 뒷벽에는 니네베 궁전의 사냥-전차 부조를 따른 얕은 돌 부조가 수평 단으로 말의 옆모습을 보여줍니다. 바닥은 연한 타일로 깔려 있으며, 홀의 양쪽은 그림자 속으로 사라집니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "신의 은총으로 로마인의 황태후이자 헝가리, 보헤미아, 달마티아, 크로아티아, 슬라보니아, 갈리치아, 로도메리아의 여왕이며 오스트리아 대공녀인 마리아 테레지아는 아치형 열주로 이루어진 돌 로지아에 서 있습니다. 이 지붕 달린 갤러리의 높은 반원형 아치는 한쪽으로는 눈 덮인 봉우리들이 이어지는 알프스 풍경으로 열려 있고, 반대편으로는 열주랑을 따라 붉은 카펫 러너가 깔린 광택 나는 바닥으로 이어집니다. 실내 벽의 아치 사이에는 붉은 다마스크 천 패널이 걸려 있으며, 왼쪽에서 들어오는 햇빛이 돌 바닥 위로 긴 그림자를 드리우고 있습니다. 그녀는 팔을 허리 앞에 가볍게 모으고 고개를 약간 돌린 채 사분의 삼 각도로 서 있습니다. 머리카락은 연한 금발로 궁정 양식에 따라 뒤로 당겨 높이 고정되어 있습니다. 가운은 연한 청회색 실크로, 허리에서 꽉 조인 보디스 앞면에는 은사 자수와 작은 보석으로 장식된 뻣뻣한 스토마커 패널이 달려 있습니다. 넓은 후프 스커트는 파니에 위로 퍼져 있으며, 같은 은사 자수가 오버스커트의 앞트임을 따라 길게 흘러내립니다. 소매는 팔꿈치 아래에서 흰 레이스로 장식된 짧은 퍼프로 마무리됩니다. 얇은 레이스 손수건이 어깨 위로 접혀 목선 안쪽으로 넣어져 있습니다. 왕관도 눈에 띄는 보석도 착용하지 않았습니다. 그녀 뒤로 연한 돌 아치가 원근에 따라 줄지어 이어지며, 선반 기둥의 난간이 저 멀리 뻗어 나가고, 알프스는 밝게 빛나며 하늘은 맑습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "멕시카의 최고 통치자 몬테수마 쇼코요친은 커다란 화로 앞에 서 있으며, 화로에서 치솟는 불꽃이 그와 보는 이 사이에 솟아 있습니다. 홀 안은 오직 그 불빛만으로 밝혀져 있습니다. 그는 가슴을 드러내고 있으며 체격이 육중하고, 피부는 불빛 아래에서 어둡게 빛나며, 얼굴의 절반은 그림자 속에 가려져 있습니다. 그의 왕관은 케찰아파네카요틀로, 금 장식띠로 묶인 녹색과 파란색의 긴 케찰 꼬리 깃털 다발로 이루어진 화관입니다. 귀에는 금 스풀이 뚫려 있고, 목에는 옥과 금으로 만든 목걸이가 둘려 있으며, 손목에는 넓은 옥과 금 커프스가, 양쪽 상완에는 금 밴드가 감겨 있습니다. 그의 뒤로는 붉은 석조 벽에 커다란 조각 원판이 박혀 있는데, 아스테카 태양석을 본뜬 것으로 중앙 얼굴 주위로 동심원 형태의 문자 띠가 새겨져 있습니다. 양쪽 벽에는 아스테카 신전에 전시된 해골 선반인 촘판틀리를 본뜬 양식화된 해골 줄무늬가 조각되어 있으며, 각 선반 위에는 크게 조각된 아스테카 신 가면이 솟아 있고, 각 벽 꼭대기의 돌 항아리에서는 높은 불꽃이 타오릅니다. 홀 전체가 불빛의 붉은색과 금색으로 물들어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "바빌론의 왕 네부카드네자르 2세는 녹색 빛으로 물든 석조 홀의 거대한 돌 왕좌에 앉아 있으며, 그의 뒤 벽은 그림자 속으로 사라집니다. 그는 신바빌로니아 왕들의 상징인 이마 부분에 띠가 둘린 높고 둥근 모자 아구를 쓰고 있습니다. 수염은 길고 어두운 색으로, 촘촘한 원통형 컬이 층층이 배열된 줄로 손질되어 있습니다. 로브는 진한 붉은색이며 짧은 소매에 전면에 등간격으로 금 장미꽃 문양이 수놓여 있으며, 허리에는 넓은 자수 띠를 두르고 있습니다. 스커트는 맨발까지 직선으로 내려오며 단에 연한 술 장식이 달려 있습니다. 양 손목에는 묵직한 금 커프스가 채워져 있습니다. 두 손은 손바닥이 아래를 향하도록 왕좌의 넓은 팔걸이 위에 올려져 있으며, 팔걸이 앞쪽 끝에는 으르렁대는 입이 무릎 높이로 바깥을 향하는 사자 머리 조각이 달려 있습니다. 발 아래 왕좌 기단에서는 더 작은 한 쌍의 사자 머리가 앞으로 돌출되어 있습니다. 왕좌 양옆에는 똬리를 튼 뱀 형상이 조각된 두 개의 높은 돌 받침대가 서 있으며, 각각의 꼭대기에 올린 넓고 얕은 그릇에서 연한 녹색 불꽃이 타오릅니다. 방 안에 유일한 빛인 이 불꽃의 창백한 녹빛이 돌 벽과 그의 얼굴, 그리고 로브 위로 퍼져 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "브라질 황제 동 페드로 2세는 어두운 패널 벽으로 둘러싸인 서재의 넓은 목재 책상에 앉아 있으며, 구도는 보는 이가 책상 맞은편에 서 있는 것처럼 설정되어 있습니다. 그는 나이 든 인물로, 어깨가 넓고 체격이 다부지며, 풍성한 흰 수염이 깃 아래로 길게 내려오고, 높은 이마에서 뒤로 넘긴 흰 머리카락은 숱이 많지 않습니다. 어두운 색의 프록코트 안에 어두운 색 조끼를 받쳐 입고, 높은 깃의 흰 셔츠에 어두운 색 크라바트를 목에 두르고 있습니다. 왼쪽 가슴에는 그가 대총장을 역임한 남십자성 황제 훈장의 보석 별장이 달려 있습니다. 두 손은 책상 위에 편평하게 놓여 있으며, 앞에는 흩어진 서류와 작은 잉크병이 있고 오른손 가까이에는 원형 펜꽂이에 꽂힌 깃털 펜이 세워져 있습니다. 왼쪽 책상 위에는 투명한 유리 갓과 광택 나는 놋쇠 받침대가 달린 기름 램프가 켜져 있으며, 그 불꽃이 그림에서 가장 밝은 지점이자 그의 얼굴과 손에 쏟아지는 빛의 주된 원천입니다. 그의 뒤와 양옆 벽은 바닥부터 천장까지 책장으로 가득 채워져 있으며 짙은 그림자에 잠겨 있습니다. 왼쪽 어깨 옆의 높은 창문으로는 비스듬한 목재 블라인드 사이로 깊은 파란색 밤하늘이 한 조각 보이며, 그 너머에 야자수 잎사귀가 실루엣으로 드리워져 있습니다. 화면 왼쪽 끝에는 마름모꼴 납유리 창문이 황혼 하늘의 따뜻한 색조를 담고 있으며, 그 아래 선반에는 작은 벽난로 시계가 놓여 있습니다. 바닥에는 차분한 붉은색과 금색의 문양 카펫이 깔려 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "로마인의 아우구스타 테오도라는 열주가 늘어선 테라스의 탁 트인 공간에서 금 브로케이드로 덮인 낮은 소파에 비스듬히 기대어 있으며, 한 팔은 길쭉한 베개 위로 늘어뜨리고 다른 팔은 무릎 위에 얹어 두고 있습니다. 그녀의 왕관은 보석 장식의 스테마로, 비잔티움 황실 머리장식의 돔형 모자이며, 그 띠에 카보숑 원석이 한 줄로 박혀 있습니다. 이마 중앙에는 초록 보석이 눈에 띄게 자리 잡고 있으며, 그 위의 장식 정점에는 금세공으로 감싼 두 번째 초록 원석이 달려 있습니다. 머리카락은 모자 아래로 단정히 당겨져 오른쪽 어깨 위로 길게 흘러내립니다. 스테마의 진주 펜던트인 펜딜리아가 얼굴 옆에 늘어져 있으며, 목에는 동방의 보석 황실 칼라인 마니아키스가 둘려 있습니다. 가운은 여러 겹으로 이루어져 있습니다. 금 메달리온으로 중앙을 여민 꼭 맞는 진한 붉은색 보디스 위에, 무릎을 가로질러 두루마리 문양이 짜인 금록색 실크 스커트가 놓여 있으며, 그 아래에는 단에 좁은 금 띠가 둘린 짙은 청록색 긴 속치마가 받쳐져 있습니다. 손목에는 금 커프스가 둘려 있습니다. 오른쪽 뒤로는 무거운 붉은 커튼이 드리워져 있으며, 옆으로 젖혀져 그 너머 풍경을 드러내고 있습니다. 테라스 바닥은 따뜻한 석재로 깔려 있고, 붉은 꽃이 담긴 항아리가 놓인 조각 난간으로 테두리가 지어져 있으며, 연한 대리석 기둥 두 개가 전망을 틀로 감싸고 있습니다. 넓은 계곡 너머로는 하기아 소피아가 서 있는데, 넓은 중앙 돔의 양옆에 낮은 반돔이 딸려 있으며, 햇빛 아래 황갈색으로 빛나는 벽 뒤로 낮은 구릉이 맑은 하늘 아래 파랗게 물러나고 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "카르타고의 건국 여왕 디도는 밤의 궁전 테라스에 서 있습니다. 그녀의 뒤로 하늘은 짙은 파란색으로 별이 촘촘히 박혀 있으며, 낮은 난간 위 지평선에 먼 곶이 어렴풋이 보입니다. 등 뒤에는 끝 부분에 소용돌이 프리즈가 조각된 곡선형 돌 벤치가 놓여 있고, 그 뒤로 연한 기둥들이 솟아 있습니다. 테라스 양쪽에는 연한 돌 화분에 심긴 커다란 관목 두 그루가 짙은 잎과 작은 붉은 꽃을 피우고 있습니다. 라틴어로 포에니쿰이라 불리는 석류나무로, 카르타고의 상징 나무입니다. 그녀는 피부가 밝으며, 짙은 머리카락이 가운데 가르마를 탄 채 어깨 너머로 흘러내리고, 이마에는 가느다란 금 다이어뎀이 둘려 있습니다. 가운은 연한 거의 흰색에 가까운 그리스 튜닉 키톤으로, 어깨에 핀으로 고정되고 허리에 벨트를 두르고 있으며, 발까지 내려오는 스커트에는 희미한 직조 문양이 흩어져 있습니다. 짧고 트인 소매는 상완을 따라 작은 브로치로 군데군데 고정되어 있으며, 넓은 진한 파란색 띠가 허리를 감싸고 스커트 앞면으로 길게 늘어져 있습니다. 목에는 금에 박힌 짙은 색 원석으로 만든 넓은 가슴 패널 장식이 놓여 있고, 한쪽 손목에는 가느다란 금 팔찌가 둘려 있습니다. 두 손은 옆으로 자연스럽게 내려져 있으며, 주변의 돌은 밤빛 아래 차갑게 빛나고 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "이케니족의 여왕 부디카는 언덕 꼭대기 요새의 풀이 우거진 능선에 서 있습니다. 왼쪽에는 뾰족하게 깎은 말뚝으로 이루어진 목재 울타리가 얹힌 돌벽이 있으며, 그 위로 원형 가옥의 원뿔형 초가지붕이 보입니다. 오른쪽으로는 짙은 회색 하늘 아래 초록 구릉이 완만하게 이어집니다. 머리카락은 짧게 잘려 있고 선명한 구릿빛 붉은색이며, 연한 천 조각이 머리 뒤에 묶여 어깨 뒤로 흘러내립니다. 한쪽 눈 아래 광대뼈에는 작은 짙은 파란색 표시가 있는데, 고대 브리튼인들이 몸에 바르던 대청 문신입니다. 꼬인 금으로 만들어진 단단한 켈트 토크가 목을 감싸고 있습니다. 옷은 파란색과 초록색 체크 짜임의 소매 없는 무릎 길이 튜닉으로, 허리에는 둥근 버클이 달린 가죽 벨트로 조여져 있습니다. 손목에는 가죽 완갑이 끈으로 묶여 있고, 상완에는 같은 모양의 가드가 묶여 있으며, 종아리는 낮은 가죽 부츠 위로 드러나 있습니다. 왼손에는 날이 직선으로 뻗은 양날 라텐 단검을 쥐고 있는데, 검신은 점점 가늘어지며 끝이 뾰족하고 손잡이는 작고 단순합니다. 오른손은 땅에 꽂힌 창의 곧게 선 자루를 잡고 있습니다. 왼쪽에는 가벼운 이륜 전차가 서 있으며, 하나뿐인 바퀴살 바퀴에는 철로 된 테가 둘려 있고, 차체에는 긴 창 묶음이 비스듬히 세워져 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "당나라의 황제 측천무후는 양쪽으로 젖혀 묶인 짙은 붉은 휘장 사이, 어두운 홀 한가운데에 서 있습니다. 그녀의 뒤로는 따뜻한 황금빛 등롱이 어둠 속에 줄지어 걸려 있으며, 등롱 뒤 어두운 벽에는 조각된 격자 문양 패널이 박혀 있습니다. 검은 머리카락은 높이 올려 쌓아 올려져 있으며, 앞쪽에는 금과 진주로 만든 장신구 보요로 고정되어 있습니다. 그녀는 여러 겹으로 차려 입은 루군 차림입니다. 연한 금색 실크 안쪽 로브는 가슴에서 여며져 있으며, 그 위로 메달리온이 자수로 놓인 뻣뻣한 금색 패널이 받쳐져 있습니다. 가슴 바로 아래 높이 묶인 선명한 붉은 띠는 바닥까지 길게 내려오는 스커트로 이어집니다. 그 위에는 금 원형 문양이 짜여진 짙은 붉은 실크 겉 로브를 걸치고 있는데, 넓은 소매가 손 너머로 늘어지고, 뒤로 흘러내린 단이 발 주위 바닥에 퍼져 있습니다. 두 손으로 작은 금 용기를 허리 앞에 들고 있으며, 마치 바치듯 살짝 들어 올려져 있습니다. 안색은 창백하고 표정은 차분하며 시선은 고요합니다. 붉은 휘장과 붉은 로브, 그리고 금빛 등롱이 홀의 어둠 속에서 화면을 따뜻하게 물들이고 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "덴마크와 노르웨이의 왕 하랄 블로탄 고름손은 롱십의 넓게 트인 갑판 한가운데에 서 있습니다. 체격이 크고 당당하며, 수염은 붉은빛이 도는 금발로 두 갈래로 갈라져 땋아 내려 칼라 아래로 드리워져 있고, 콧수염은 길고 아래로 처져 있습니다. 머리에는 아무것도 쓰지 않았으며 머리카락은 위로 묶어 상투처럼 올렸습니다. 어깨에는 긴 적갈색 모피 망토가 걸쳐져 있습니다. 그 아래에는 더 짙은 요크 부분이 있는 청록색 튜닉을 입고 있으며, 밑단과 소맷부리에는 북유럽 인터레이스 문양이 정교하게 새겨진 장식 띠가 둘러져 있습니다. 가공된 가죽으로 만든 넓은 벨트가 허리를 가로질러 무거운 사각 버클로 고정되어 있으며, 두 번째 끈이 가슴을 대각선으로 가로지릅니다. 두 손은 앞에서 벨트 위에 얹혀 있습니다. 헬멧은 발 옆 갑판에 놓여 있는데, 짙은 철제 반구형으로 이마와 코를 보강하는 밴드가 있고, 양옆은 두꺼운 적갈색 모피로 된 둥근 귀덮개 모양으로 펼쳐져 있습니다. 그의 왼편에는 배의 이물 기둥이 높은 목재 나선형으로 안쪽을 향해 휘어 올라가며 용머리 형태로 조각되어 있습니다. 오른쪽 어깨 너머로는 돛대에서 삭구 줄들이 내려오고 있으며, 그 위로는 빨강과 흰색의 굵은 세로 줄무늬로 이루어진 돛이 드리워져 있습니다. 뱃전을 따라 둥근 목제 방패가 앞면이 밖을 향하도록 장착되어 있으며, 중앙에는 철제 볼록 부분이 있습니다. 위로는 푸른 하늘이 트여 있고, 높은 구름 띠가 가로질러 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "두 땅의 파라오 람세스 2세는 짧은 계단 꼭대기 옥좌에 앉아 있으며, 양옆으로는 높은 파란 기둥이 줄지어 선 홀이 열려 있습니다. 젊은 얼굴에 수염이 없고, 피부는 짙은 청동빛이며, 눈가에는 짙은 콜이 둘러져 있습니다. 머리 장식은 네메스로, 금색과 파란색 줄무늬 머리천이 관자놀이 양옆으로 단단히 감기고 주름 잡힌 늘어진 부분이 가슴까지 드리워져 있습니다. 이마 위로는 왕권을 상징하는 우라에우스, 즉 몸을 세운 코브라가 솟아 있습니다. 어깨와 가슴에는 웨세크가 놓여 있는데, 금색과 청금석 파란색의 구슬이 겹겹이 쌓인 넓은 칼라입니다. 하의는 센디트로, 파라오 특유의 주름 잡힌 긴 흰 리넨 킬트이며, 금색과 파란색의 넓은 허리띠로 고정되어 앞면에 딱딱한 문양 패널이 아래로 드리워져 있습니다. 샌들을 신은 두 발은 계단 꼭대기에 얹혀 있습니다. 왼손에는 어깨에 기댄 높은 지팡이를 들고, 오른손은 옥좌의 팔걸이 위에 놓여 있습니다. 양옆의 기둥은 파란색, 금색, 빨간색의 층위로 채색되어 있으며, 기둥머리는 파피루스 묶음 형태로 상형문자와 서 있는 인물들의 행렬이 새겨져 있습니다. 옥좌 앞 양옆으로는 보호의 여신 이시스와 네프티스의 대형 황금 조각상이 서 있으며, 두 날개를 펼쳐 앞으로 뻗고 깃털은 길고 금빛 나는 날처럼 표현되어 있습니다. 양쪽에서 야자수 잎이 기울어져 있고, 발 아래 노란 돌 계단에는 작은 삼각형 문양의 행렬이 새겨져 있습니다. 홀 전체가 따뜻한 금빛으로 빛나며, 기둥과 칼라의 파란색만이 그 안에서 유일한 차가운 색조를 이룹니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "신의 은총으로 잉글랜드, 프랑스, 아일랜드의 여왕이자 신앙의 수호자인 엘리자베스 1세는 양옆에 돌 받침대 위의 두 촛대가 놓인 높은 조각 옥좌에 앉아 있으며, 초에는 불이 켜져 있지 않습니다. 뒤로는 금빛 술 달린 끈으로 주름지게 젖혀진 무거운 붉은 벨벳의 국가용 차양이 솟아 있고, 그 너머 방 안의 어둠이 희미하게 보입니다. 머리카락은 붉은빛이 도는 금발의 촘촘한 곱슬머리로 높이 쌓아 올려 작은 보석 장식 소관으로 고정되어 있으며, 칼라는 튜더 말기 궁정의 딱딱하게 펼쳐진 러프입니다. 가운은 검은 자수가 놓인 금색 브로케이드이며, 보디스는 몸에 딱 맞고 보석으로 장식되어 있고, 소매는 어깨에서 부풀어 올랐다가 레이스 소맷부리로 가늘어지며, 치마는 파딩게일 위로 넓게 펼쳐져 있습니다. 긴 진주 목걸이들이 가슴을 가로질러 허리에서 늘어뜨려져 있는데, 당시 정절의 표시로 착용하던 것입니다. 창백한 두 손은 옥좌의 팔걸이 위에 얹혀 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "에티오피아 황제이자 신의 선택자, 유다 지파의 정복하는 사자 하일레 셀라시에 1세는 왕궁의 긴 접견실에 서 있으며, 머리 위로는 밝은 색의 격자 천장이 있고 오른쪽으로는 높은 창문들이 줄지어 있으며 그 사이에 수정 샹들리에가 매달려 있습니다. 몸이 다소 가녀리고 곧게 서 있으며, 짙은 수염을 기르고 머리카락은 짧게 깎여 있습니다. 목까지 단추를 채운 짙은 색 군용 튜닉과 무늬 없는 짙은 색 바지를 입고, 넓은 검은 가죽 허리 벨트를 두르고 있습니다. 오른쪽 어깨에서 왼쪽 허리까지 넓은 에메랄드 그린 모아레 띠가 가로지르고 있는데, 이는 솔로몬 인장 훈장의 리본입니다. 왼쪽 가슴 위쪽에는 네 줄의 소형 리본이 모여 있으며, 재위 기간에 쌓인 전투 및 명예 훈장들입니다. 그 아래에는 최고위 황실 훈장의 대형 흉장 두 개가 늘어져 있으며, 여덟 개의 꼭짓점이 있고 금과 에나멜로 세공되어 있습니다. 왼손은 옆에 가만히 내리고, 오른손에는 장갑 한 켤레를 들고 있습니다. 그의 왼편에는 황제의 옥좌가 놓여 있는데, 옅은 크림색과 파란색으로 씌워진 등받이 높은 의자로, 기둥 머리 부분은 아치형 왕관으로 조각되어 있고 수놓인 천이 드리워져 있으며, 홀의 길이 방향으로 깔린 붉은 문양의 카펫 위에 놓여 있습니다. 그 뒤로 벽을 따라 옅은 색으로 씌워진 의자들이 줄지어 방 안쪽으로 이어져 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "프랑스 황제 나폴레옹 보나파르트는 황혼 무렵의 메마른 풀밭에서 옅은 회색 말에 올라 앉아 있으며, 뒤로는 붉은빛이 도는 갈색 하늘과 앙상한 나무들이 배경을 이룹니다. 짙은 파란색 코트에 묵직한 금색 견장을 달고, 흰 조끼와 흰 승마용 반바지, 키 높은 검은 승마 부츠를 착용하고 있습니다. 이각모는 가로로 눌러 쓰고 있어 두 꼭짓점이 어깨 쪽을 향하는데, 이는 그가 휘하 장교들과 차별화하기 위해 즐겨 택하던 착용 방식입니다. 말의 굴레는 금 장식이 박힌 붉은 가죽이며, 아래에 깔린 안장포는 빨강과 금색으로 테를 둘렀습니다. 이 구도는 자크-루이 다비드의 작품 '알프스를 넘는 나폴레옹'을 연상시키지만 고요하게 정지해 있습니다. 뒷발로 서는 군마도, 앞을 가리키는 손도 없이, 황혼의 풍경 속에 홀로 선 한 인물만이 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "프로이센 장관 총리이자 독일 제국의 초대 수상 오토 폰 비스마르크는 뒤쪽의 납 창문을 통해 쏟아지는 낮빛으로 밝혀진 높은 국가 접견실에 서 있습니다. 각 창문은 가느다란 창살로 작은 사각형들로 나뉘어 있습니다. 무거운 진홍색 커튼이 각 창문 옆에 깊이 주름져 뒤로 묶여 있으며, 안쪽 안감은 더 짙은 붉은빛입니다. 바닥은 거울처럼 광이 나며, 창문에서 들어오는 빛이 길고 밝은 띠 모양으로 반사됩니다. 왼편에는 작은 사이드 테이블 위에 흰 구형 램프가 놓여 있습니다. 키가 크고 어깨가 넓으며, 정수리는 벗어졌고 양옆과 뒤쪽에는 은회색 머리카락이 짧게 남아 있으며, 끝이 바깥으로 길게 뻗은 흰 콧수염을 기르고 있습니다. 코트는 짙은 슬레이트 색의 더블 브레스트 군용 프록코트로, 가슴에 두 줄의 금 단추가 나란히 고정되어 있고, 세운 칼라와 어깨는 금으로 장식되어 있으며, 무거운 금 술이 달린 견장은 위쪽 팔까지 내려옵니다. 칼라 바로 아래에는 짙은 리본에 작고 옅은 십자 훈장이 달려 있는데, 이는 프로이센 최고 군사 훈장인 푸르 르 메리트입니다. 관람자를 향해 4분의 3 각도로 곧게 서서 움직이지 않으며, 시선은 관람자의 어깨 너머 어딘가에 고정되어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "마케도니아의 왕이자 헬라스의 헤게몬 알렉산더 대왕은 순흑색 종마 부케팔로스에 올라 앉아 고삐를 당겨 멈추게 하고 있습니다. 배경은 양쪽으로 회색 산맥이 이어지는 초록빛 고지 초원이며, 오른쪽으로 눈 덮인 단독 봉우리가 솟아 있습니다. 젊고 수염이 없으며, 갈색 머리카락은 가운데 가르마를 타서 이마에서 위로 쓸어 올린 아나스톨레 스타일로, 그의 초상화에서 상징이 된 앞머리 위로 올리기 방식입니다. 리노토락스를 착용하고 있는데, 헬레니즘 시대의 겹겹이 쌓인 아마포와 가죽으로 만든 흉갑으로, 겉면에 금도금 판을 붙이고 어깨의 요크 부분은 짧은 끈으로 가슴에 묶여 있습니다. 가슴 한가운데에는 사각형 금도금 패에 메두사의 얼굴이 돋을새김된 고르고네이온이 있습니다. 어깨와 허리 벨트 아래로는 프테루게스, 즉 위쪽 팔과 허벅지를 보호하는 뻣뻣한 가죽 띠들이 줄지어 달려 있으며, 각 띠는 빨간 테두리에 금 장식 단추가 달려 있습니다. 두 팔은 맨살이며, 오른쪽 손목에는 넓은 금 팔찌를 차고 있습니다. 투구는 쓰지 않았고 눈에 보이는 무기도 없습니다. 말의 마구는 붉은 장식이 있는 짙은 가죽으로 이마 띠와 볼 부분에 장식 단추가 박혀 있으며, 왼손에 고삐 하나를 말 목 너머로 당겨 잡고 있습니다. 안장 아래에는 얼룩진 표범 가죽이 말의 옆구리를 덮고 있으며, 발은 그대로 붙어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "훈족의 왕 아틸라는 높은 연단 위에 놓인 등받이 높은 목제 옥좌에 앉아 있으며, 주변 홀은 짙은 붉은색과 금빛으로 빛납니다. 편안하게 등을 기대고 한쪽 다리를 다른 쪽 위에 걸쳐 놓고 있으며, 뽑아 든 칼이 무릎 위에 놓여 있습니다. 한 손은 칼날 위에 얹고, 다른 손에는 술잔을 들고 있습니다. 튜닉은 금 테두리가 달린 붉은색 긴소매이며, 소맷부리에 모피 장식이 있는 키 높은 부드러운 가죽 장화 안으로 접어 넣은 짙은 파란색 바지 위에 걸쳐 입고 있습니다. 머리에는 금 띠가 달린 짙은 모피 원뿔형 모자를 쓰고 있습니다. 수염과 긴 콧수염을 기르고 있으며, 얼굴 오른쪽에서 비치는 빛으로 반이 밝혀져 있습니다. 옥좌의 팔걸이 끝은 조각된 사자 머리로 마무리되어 있고, 등받이에는 두꺼운 모피가 걸쳐져 있습니다. 그 뒤로 붉은 휘장 벽이 있으며, 양옆으로는 크기가 다른 둥근 청동 원반들이 줄지어 매달린 패널이 늘어서 있고, 화염의 빛이 그 위에서 반짝입니다. 연단 오른편에는 키 높은 철제 촛대에 초 하나가 타오르고 있습니다. 그 너머 바닥에는 커다란 황동 그릇이 놓여 있고 칼집에 넣어 세워 둔 칼들의 손잡이들이 빽빽이 솟아 있습니다. 더 뒤쪽으로는 열린 목제 상자에서 동전들이 문양 있는 카펫 위로 쏟아져 나와 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "타완틴수유의 사파 잉카 파차쿠티 잉카 유판키는 마추픽추 위 테라스에 있는 높은 돌 옥좌에 앉아 있으며, 옥좌에는 금색과 붉은색으로 장식된 기하학 문양들이 연속으로 새겨져 있습니다. 그의 오른쪽 위, 돌기둥에 고정된 거대한 황금 태양 원반의 중앙에는 밖을 향해 뻗어 나가는 광선 고리 안에 양식화된 인물 얼굴이 새겨져 있습니다. 왼쪽으로는 민 봉우리들이 가파르게 솟아 있고, 아래쪽 계단식 농경 단지에는 낮은 초가 건물들이 배치되어 있습니다. 이마를 가로질러 드리워진 붉은 양모 술인 마스카파이차를 쓰고 있는데, 이는 잉카 주권의 상징으로 여러 색이 섞인 머리띠인 야우토로 묶고, 위로 선 붉은색과 짙은 색 깃털 장식으로 마무리되어 있습니다. 머리카락은 검은색이며 어깨 길이입니다. 목에는 무거운 황금 원반 흉장이 걸려 있습니다. 튜닉은 민소매에 무릎 길이의 옷으로, 굵은 흑백 체크 문양과 가슴 부분에 빨강과 금색의 요크가 있습니다. 무릎 아래 두 다리에는 붉은 술이 달린 끈이 감겨 있습니다. 오른손에는 황금 새 형상이 얹힌 높은 지팡이를 들고 있으며, 지팡이 몸체에는 층층이 배열된 붉은 술이 달려 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "마하트마자 인도 독립의 지도자 모한다스 카람찬드 간디는 메마른 누런 풀밭과 바위 곶, 옅은 빛의 바다로 이루어진 인도의 해안가에 서 있습니다. 마른 체형에 대머리이며, 안경을 쓰고 짧게 다듬은 회색 콧수염을 기르고 있습니다. 그의 만년 복장을 하고 있는데, 허리에 감은 평범한 흰 도티, 한쪽 어깨에 걸쳐 반대편 팔 아래로 두른 숄을 입고, 가슴은 드러나 있습니다. 천은 물들이지 않고 손으로 방적한 것으로, 영국산 직물을 의도적으로 거부한 것이며 그의 운동의 상징이 되었습니다. 이 배경은 독립 운동 시기에 그가 바다를 향해 걷던 긴 행진들을 떠올리게 하며, 아대륙의 가장자리에 홀로 선 한 인물의 모습입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "자바 마자파힛 제국의 마하파티 가자 마다는 침수된 논밭 가장자리에 서 있으며, 낮은 초록 두렁 사이로 물이 거울처럼 빛납니다. 그 뒤로 짙은 열대림이 옅은 안개에 휘감긴 언덕을 타고 오르고 있으며, 그 안개 속에서 칸디, 즉 붉은 벽돌로 쌓인 사원탑의 날렵한 계단형 실루엣이 솟아 올라 지붕의 층위들이 구름 속으로 녹아 들어갑니다. 어깨가 넓고 상체는 드러나 있으며, 짙은 머리카락은 위로 묶어 상투를 지었고 턱에는 작은 수염 뭉치가 있습니다. 위팔과 양 손목에는 금 밴드가 고정되어 있습니다. 허리 높이에 넓은 벨트가 있으며, 마자파힛 양식의 꽃 문양이 새겨진 큰 부채꼴 금 장식판으로 고정되어 있습니다. 벨트 아래로는 붉은 사롱이 앞쪽에서 매듭지어 감겨 있으며, 그 주름 아래로 밑단에서 드러나는 노란 속옷천 위로 두꺼운 패널처럼 흘러내립니다. 오른쪽 허리에는 벨트를 통해 묶인 끈에 칼집에 든 크리스가 매달려 있는데, 짙은 나무 칼집이 좁은 끝을 향해 가늘어지고 손잡이는 비스듬한 각도로 앞을 향해 튀어나와 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "하우데노쇼니 연맹의 창건자 히아와타는 햇살이 가득한 숲속 빈터에 서 있으며, 그의 어깨 옆으로 커다란 회색 바위가 솟아 있고 너도밤나무와 자작나무의 가느다란 줄기들이 초록빛 덤불 속으로 멀어집니다. 그는 상체를 드러낸 채 다부진 체격을 지녔으며, 얼룩진 빛 속에서 피부는 따뜻한 갈색으로 빛납니다. 머리는 스캘프락 양식으로 다듬어져, 양쪽 측면을 바짝 밀고 정수리를 따라 앞에서 뒤로 좁은 검은 머리카락 능선이 이어지며 뒤쪽에 두 개의 깃털이 꼿꼿이 꽂혀 있습니다. 짙은 물감 띠가 양쪽 상박을 감싸고 있습니다. 흰 조개껍데기 구슬로 만든 촘촘한 초커, 즉 왐픔이 목에 걸려 있으며, 하나의 끈이 오른쪽 어깨에서 왼쪽 허리까지 가슴을 가로질러 화살통을 받치고, 그 깃 달린 화살 끝들이 어깨 너머로 솟아 있습니다. 허리에는 옅은 황갈색 사슴 가죽으로 만든 샅바가 앞쪽으로 길게 늘어져 허벅지 중간까지 닿습니다. 술 달린 사슴 가죽 레깅스가 발목에서 무릎까지 종아리를 감싸며, 무릎 아래에서 묶이고 샅바가 덮는 허벅지 부분은 열려 있습니다. 그는 맨발로 빈터의 다져진 흙 위에 서서 두 팔을 옆으로 늘어뜨리고 있으며, 숲의 빛이 그의 오른쪽 옆면을 비춥니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "오다 씨의 다이묘이자 전국 통일의 선구자 오다 노부나가는 키 큰 풀밭과 드문드문 흩어진 흰 돌들이 있는 완만한 녹색 들판에 서 있으며, 구름이 높이 쌓인 밝은 하늘 아래 청색 산맥이 지평선을 향해 멀어집니다. 그의 머리는 사카야키 방식으로 이마와 정수리를 밀어, 투구가 시원하면서 단단하게 앉을 수 있도록 하였으며 나머지 머리카락은 뒤로 모아져 있습니다. 짧은 콧수염과 턱 아래의 짧은 수염을 갖추고 있습니다. 그의 갑옷은 도세이 구소쿠, 즉 전국 시대의 현대적 갑옷으로, 옻칠한 철판들이 비단 끈으로 수평 열을 이루며 연결되어 있고, 흉갑과 치마판은 짙은 청색과 주홍색 띠가 교대로 묶여 있습니다. 어깨 가리개도 같은 방식으로 연결된 판으로 양팔 위에 걸려 있습니다. 그 위에 소매 없는 황갈색 전투 코트를 걸쳤으며, 앞판이 열려 아래의 흉갑을 드러냅니다. 넓은 붉은 띠가 허리에서 매듭지어지고 그 사이에 칼날이 위를 향하도록 한 자루의 검이 꽂혀 있으며, 오른쪽에는 두 번째 검이 매달려 그의 오른손이 칼자루에 얹혀 있습니다. 이 두 자루는 모든 사무라이가 지니는 대소 한 쌍의 검, 다이쇼입니다. 오른쪽 어깨 뒤에서 솟아 등을 가로질러 뻗어 있는 것은 다네가시마, 즉 화승총의 길고 어두운 개머리판과 가느다란 총열로, 노부나가는 이 화기를 대규모로 도입한 것으로 기억됩니다. 그는 들판에 홀로 서 있으며, 주변에는 풀과 돌, 그리고 먼 산들만이 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "조선 왕조의 제4대 국왕 세종대왕은 정전의 높직한 목재 단 위 중앙에 앉아 두 손에 펼친 책을 무릎 위에 들고 있습니다. 조선의 왕이 착용하는 붉은 비단 왕포인 곤룡포를 입었으며, 가슴과 어깨에는 금빛 원형 문양 안에 사발톱 용이 수놓이고 금색 당초 문양으로 테두리가 장식되어 있습니다. 넓은 옥대가 허리를 가로지릅니다. 머리에는 익선관을 쓰고 있는데, 뒤쪽에서 접힌 잎처럼 두 개의 작은 날개가 위로 솟은 뻣뻣한 검은 사 모자입니다. 깔끔하게 다듬어진 짙은 콧수염과 턱 아래의 짧은 수염을 제외하면 수염이 없습니다. 그의 뒤로는 일월오봉도, 즉 모든 조선 왕좌 뒤에 놓이는 해와 달과 다섯 봉우리의 병풍이 펼쳐져 있으며, 왕은 왕비의 달에 대응하는 해였습니다. 왼쪽 상단에는 흰 달 원판, 오른쪽 상단에는 붉은 해 원판이 있고, 짙은 녹색의 험준한 봉우리들과 짙은 붉은 소나무들이 하단을 따라 퍼져 있습니다. 왕좌 자체는 붉은 옻칠이 되어 있으며, 양쪽 측면 판에는 호랑이 원형 문양이 조각되어 있습니다. 붉은 옻칠 난간과 기둥이 단의 양쪽을 장식하고, 종이 등불이 전각 가장자리에 매달려 노란빛으로 빛나며, 짧은 돌계단이 관람자 쪽으로 내려옵니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "바칼의 쿠훌 아자우이자 팔렌케의 성스러운 군주, 키니치 하나브 파칼은 수도 위 석회암 궁전의 테라스에 한낮에 서 있으며, 그 너머 정글에서는 층층이 쌓인 피라미드 신전들이 솟아 있고 그 지붕빗은 조각되어 옅은 장밋빛으로 풍화되어 있습니다. 그의 어깨 뒤로는 거대한 등판 장식이 펼쳐져, 초록색, 청색, 짙은 붉은색의 줄로 이루어진 긴 케찰 꼬리 깃털을 부채처럼 편 나무 틀이 조각되고 채색된 문자 판 위에 설치되어 있습니다. 그의 머리 장식은 높고 층층이 쌓여 더 많은 케찰 깃털로 장식되어 있습니다. 머리카락은 길고 짙게 어깨까지 드리워져 있습니다. 조각된 옥 판으로 만든 넓은 목걸이가 가슴을 가로지르고, 그 중앙에는 사각형의 옥 흉식이 매달려 있으며, 옥 귀 장식이 귀를 뚫고 있습니다. 구슬 허리띠가 매듭진 천과 깃털의 치마를 허리에서 모으며, 무릎 길이의 긴 깃털 술이 양쪽으로 늘어지고, 샌들의 끈은 종아리 높이까지 감겨 있습니다. 왼손에는 카위일의 인형 홀장을 쥐고 있는데, 번개 신의 작은 조각상 머리가 위에 얹힌 긴 지팡이로, 마야 통치자들은 이를 왕권의 상징으로 지녔습니다. 그의 왼쪽 테라스 끝에는 넓은 석제 향로가 서 있으며, 그 테두리에는 태워진 공물의 잔해들이 둘러져 있습니다. 그 너머 도시는 안개 속으로 사라지며 피라미드가 차례로 강 평원을 향해 내려갑니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "몽골의 대칸 징기스 칸은 탁 트인 초원에서 검은 말 위에 올라앉아 허리 위로 사분의 삼 각도로 관람자를 향해 있습니다. 그의 투구는 높고 원추형으로 날카로운 꼭대기 장식까지 솟아 있으며, 짙은 이마띠와 볼 가리개가 가는 콧수염과 턱의 작은 수염 다발을 에워쌉니다. 그의 갑옷은 몽골 기병 장갑으로, 가슴에는 소용돌이 문양이 새겨진 크고 둥근 청동 요철이 지배적이며, 넓은 어깨받이가 어깨 위를 덮고 스터드 박힌 띠가 상박을 감쌉니다. 어두운 망토가 어깨에서 흘러내리며, 안감은 안장 뒤로 드리운 곳에서 묵직한 자주색을 띱니다. 말의 마구는 소박한 가죽으로, 이마띠와 앞으로 모은 고삐만을 갖춘 단순한 굴레입니다. 그의 뒤로 낮은 녹색 구릉들이 옅은 흐린 하늘 아래 굽이치며, 중간 경사면에는 몽골인들의 둥글고 흰 천막 게르들이 모여 있고 주변 풀밭에는 옅은 점들로 가축이 흩어져 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "모로코의 사아디 왕조 술탄 아흐마드 알만수르는 짙은 청색 하늘 아래 사하라 야영지의 끝에 서 있습니다. 가는 초승달과 흩어진 별들이 지평선 위의 낮고 어두운 산맥 너머에 걸려 있습니다. 그는 수염을 기른 채 등불 속에서 피부가 따뜻하게 빛나며, 시선은 평온하게 관람자를 향합니다. 마그레브의 층층이 입는 복식을 갖추었는데, 북아프리카의 발목까지 닿는 두건 달린 긴 흰색 젤라바를 입었습니다. 그 위에는 셀함, 즉 왕자와 군주의 고급 양모 망토를 드리웠으며 그 두건은 어깨뼈 사이로 젖혀져 있습니다. 흰색 터번이 머리에 감겨 있습니다. 가슴에는 크림색과 금색의 직사각형 수놓인 판이 매달려 이슬람 장식의 격자 기하학 문양으로 꾸며져 있습니다. 세로 붉은색과 크림색 줄무늬의 넓은 띠가 허리를 두 번 감아 앞에서 매듭지어지고 끝은 안쪽으로 집어넣어져 있습니다. 그의 뒤 왼쪽에는 어두운 줄무늬 천의 크고 둥근 대상 천막이 안에서 빛나며, 열린 입구에서 따뜻한 주황빛이 모래 위로 쏟아지고, 옆에는 두 마리의 낙타가 모래 위에 쉬고 있습니다. 더 멀리에서 작은 불빛이 타오르고, 대추야자 나무들의 군락이 언덕을 배경으로 솟아 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "네덜란드 독립의 아버지 오라녜 공 윌리엄 1세는 왼쪽의 높은 납 유리창으로 빛이 드는 타일 깔린 방 안에 서 있으며, 창문의 작은 다이아몬드형 유리판은 양쪽에 젖혀진 무거운 붉은 커튼으로 둘러싸여 있습니다. 바닥은 흑백 대리석 정사각형으로 깔려 있습니다. 그의 뒤 먼 벽에는 금빛 액자의 저지대 풍경화가 걸려 있는데, 묵직한 하늘 아래 강이 평탄한 녹색 들판을 구불구불 지나 먼 마을을 향합니다. 그의 오른쪽에는 나무 발걸이 위에 지구본이 놓여 있어, 황동 자오선 고리가 창문 빛을 받습니다. 왼쪽에는 붉은 천이 덮인 글쓰기 책상에 열린 가죽 제본 책과 낱장의 종이들이 놓여 있고, 그 뒤로 파란 천을 씌운 등받이 높은 의자가 서 있습니다. 방 전체는 베르메르의 지리학자와 천문학자의 방을 떠올리게 하지만, 윌리엄은 그 양식보다 한 세대 앞선 인물입니다. 그는 중년의 수염 있는 남자로, 작은 납작한 모자 아래 짙은 머리카락을 짧게 자르고, 콧수염과 세 갈래 수염을 단정히 다듬었으며, 넓고 흰 주름 러프가 목 앞에 도드라집니다. 어깨 위로는 긴 검정 망토가 드리워져 오른쪽으로 밀어 두 팔을 자유롭게 하였습니다. 더블렛은 무광의 금빛 무늬 비단으로, 몸통에 딱 맞게 재단되어 앞면이 한 줄로 단추를 채웠습니다. 바지는 판상 트렁크 호즈로, 붉은색과 흰색 천의 긴 세로 조각들이 교대로 줄무늬를 이루며 충분한 안감 위에 구성되어 허벅지 중간에서 끝납니다. 평범한 짙은 호즈가 하퇴를 덮으며 체크무늬 바닥 위의 낮은 가죽 신발과 이어집니다. 오른손에는 직책 배턴을 가슴 높이로 들고 있으며, 왼손은 허리 근처에 얹혀 있어 망토 자락 아래로 검의 칼자루가 희미하게 보입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "장엄한 쉴레이만, 입법자 카누니, 오스만 제국의 술탄은 톱카프 궁전의 골조 돔 아래, 청백색 이즈니크 타일로 장식된 뾰족한 아치들의 전각 안에 서 있습니다. 보이지 않는 창문에서 햇살이 쏟아져 그의 뒤 옅은 석조 기둥 위를 비춥니다. 그는 수염을 기르고 짙은 눈빛을 지녔으며, 콧수염과 수염이 얇은 입 주위로 단정히 다듬어져 있습니다. 그의 터번은 그로 유명한 높고 둥근 카부크로, 원추형 틀에 흰 천이 두껍게 감겨 이마 위로 한참 솟아 있습니다. 그 정점에는 술탄의 지위를 나타내는 녹색 깃털 장식 소르구치가 솟습니다. 속옷 위에는 덩굴과 장미 문양이 옅게 짜인 노란 비단 카프탄을 걸쳤으며, 앞면은 허리까지 열려 있습니다. 부드러운 회색 모피의 넓은 띠가 전체 길이를 따라 장식되어, 이것이 최고의 영예 예복인 카파니체임을 나타냅니다. 짙은 허리띠가 허리에서 카프탄을 가로지릅니다. 오른손에는 짙은 가죽으로 제본된 책 한 권을 가슴에 세워 들고 있으며, 다른 손은 옆에 내려져 있습니다. 그의 뒤 전각은 타일 장식 아치들 사이로 어둠 속에 사라집니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "아케메네스 제국의 왕중왕 다리우스 1세 대왕은 대전의 맨 앞 낮은 계단 꼭대기에 서 있으며, 위에서 한 줄기 빛이 그를 비춥니다. 그는 넓은 어깨에 풍성한 수염을 기르고 있으며, 수염은 길고 네모지게 잘려 촘촘하게 말려 있습니다. 머리에는 키다리스, 즉 페르시아 왕들의 높고 흉벽 형상의 왕관을 쓰고 있는데, 사각형 흉벽 형태로 둘러진 황금 원통입니다. 그의 예복은 발 아래까지 내려오는 사프란 노란 장포로, 가슴과 소맷부리, 옷단에 붉은색과 금색 자수 띠가 장식되어 있습니다. 붉은 허리띠가 허리에서 이를 모아 줍니다. 두꺼운 금 팔찌가 양쪽 이두박근을 감쌉니다. 그의 양쪽 받침대에는 두 마리의 거대한 라마수, 즉 날개 달린 황소가 솟아 있으며, 몸통과 접힌 날개는 금으로 덮여 있는데, 이는 페르세폴리스의 만국의 문을 지키는 수호 형상으로, 여기에서는 인간 머리 형상 대신 황소만의 형태로 단순화되었습니다. 뒷벽에는 긴 예복과 부드러운 모자를 쓴 인물들의 행렬이 낮은 부조로 새겨져 있으며, 아파다나 계단의 공물 봉헌자 부조를 따른 것입니다. 단과 계단의 석재는 옅은 청록색으로, 모서리에는 금색 요철 장식이 박혀 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "폴란드의 왕이자 피아스트 왕조의 마지막 군주 카지미에시 3세 대왕은 철제 벽 횃불이 석조 벽면 전체에 따뜻한 붉은 금빛을 드리우는 돌로 된 성문 입구에 서 있습니다. 그는 넓은 어깨에 풍성한 수염을 기르고 있으며, 수염은 짙고 단정하게 다듬어져 있고 시선은 평온합니다. 그의 왕관은 붉은 보석이 박힌 금빛 아치형 테로, 아치들이 위에서 보석 박힌 꼭대기 장식으로 닫힙니다. 어깨 주위로는 흰 담비 모피의 넓은 어깨 덮개가 놓여 있으며, 모피에는 작은 검은 꼬리 술들이 장식되어 있습니다. 그 아래 망토는 긴 진홍색 예복으로, 작은 금 단추 한 줄이 가슴을 따라 채워지고 넓은 금빛 허리띠로 묶여 있습니다. 한 손에는 황금 홀을 가슴에 세워 들고, 허리에는 피아스트 왕가의 국가 검 슈체르비에치가 매달려 있습니다. 그의 양쪽으로 무거운 철 사슬들이 성문 안쪽 벽면을 따라 위의 어둠 속에서 내려옵니다. 그의 뒤, 방 뒤쪽 아치 안에는 붉은 판에 왕관 쓴 폴란드의 흰 독수리가 날개를 펼치고 있습니다. 독수리는 통상의 은색 대신 붉은 바탕에 짙은 실루엣으로 표현되었습니다. 석재는 육중하고 빈틈없이 맞춰져 있으며, 빛은 왕 위에 고이고 양쪽 그늘진 아치 천장 속으로 급격히 사라집니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "하와이 제도의 통일자이자 왕국의 초대 모이 카메하메하 대왕은 흰 모래 해변 위에 맨발로 서 있으며, 그의 뒤로는 보호된 만의 청록빛 얕은 물이 펼쳐지고 그 너머로 짙은 숲으로 뒤덮인 능선이 솟아 있습니다. 그는 키가 크고 다부진 체격으로 상체를 드러낸 채 열대 태양 아래 피부가 깊은 갈색으로 빛납니다. 한쪽 어깨에는 아후울라, 즉 하와이 알리이의 깃털 망토가 걸려 있는데, 짙은 붉은색으로 발목에 닿을 만큼 길게 드리워져 있습니다. 같은 붉은색의 넓은 띠가 왼쪽 어깨에서 가슴을 가로질러, 노란 테두리에 작은 붉은 기하학 문양 블록들이 배열되어 있습니다. 어울리는 붉은색과 노란색 판이 허리에 두르는 말로, 즉 요포 앞면에 매달려 있습니다. 머리에는 마히올레, 즉 이마에서 뒷목까지 좁은 능선이 솟은 낮은 볏 투구를 쓰고 있으며, 붉은색에 노란 줄무늬로 장식되고 밑동에 노란 띠가 있습니다. 오른손에는 끝이 가시 달린 높다란 나무 창을 들고 있으며, 왼팔은 옆으로 내려져 있습니다. 그의 오른쪽 모래 위에는 폴리네시아식 쌍동 항해 카누인 와아 카울루아 두 척이 끌어올려져 있으며, 두 선체가 묶인 가로대로 이어져 있습니다. 돛은 삼각형으로 아래 꼭지점이 돛대 발 아래에 오고 위 가장자리가 긴 U자형으로 바깥으로 휘며, 돛천은 옅고 기운 흔적이 있습니다. 세 번째 카누가 만 안쪽에서 닻을 내리고 있습니다. 그의 왼쪽 어깨 뒤 해안에는 하와이식 가옥 하레, 즉 기둥 뼈대에 말린 풀 지붕을 얹은 집이 서 있으며, 코코넛 야자의 잎에 반쯤 가려져 있습니다. 능선 위 하늘은 높이 떠 있는 흰 구름과 함께 파랗습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "포르투갈, 알가르브, 그리고 해외 포르투갈 영토의 여왕 마리아 1세는 신트라의 페나 궁전 테라스에 서 있으며, 두꺼운 로마네스크 아치가 줄지어 늘어선 창백한 석조 회랑이 그 아래로 펼쳐집니다. 기둥들 너머로 대서양이 열려 있습니다. 그녀의 드레스는 짙은 청색 실크로 만들어졌습니다. 보디스는 허리 부분이 뾰족하게 꼭 맞으며, 팔꿈치까지 오는 소매는 흰 커프스로 마무리되고, 치마는 파니에 위로 풍성하게 펼쳐져 넓은 주름을 이루며 석조 바닥까지 드리워집니다. 짧은 붉은 망토가 어깨에 고정된 채 뒤로 길게 늘어집니다. 가슴에는 붉은 테두리의 넓은 흰 새시가 걸쳐 있는데, 이는 포르투갈 군주가 그랜드 마스터로서 착용하는 포르투갈 그리스도 기사단의 새시입니다. 그 전면에는 보석으로 장식된 장식 띠가 세로로 달려 있습니다. 그녀의 검은 머리카락은 이마 위로 높게 올려 쌓이고, 깃털이 꽂힌 작은 검은 장식인 에그레트로 고정되어 있습니다. 오른손은 치마의 청색과 대비되는 가느다란 홀에 옆으로 얹혀 있으며, 홀의 검은 자루가 치마에 닿아 있습니다. 그녀의 오른쪽으로는 난간 너머 붉은 절벽 사이로 좁은 해양 수로가 이어집니다. 돛을 걷어 올린 사각 범장의 나우스 두 척이 수로에 정박해 있습니다. 왼쪽으로는 금빛과 타일 장식의 구근 형태 돔을 얹은 노란 벽의 탑이 솟아 있으며, 치형 흉벽이 있는 노란 성벽이 그녀가 서 있는 테라스 방향으로 단을 이루며 내려옵니다. 하늘은 맑고, 빛은 밝은 대서양 오후의 빛이며, 아치는 한쪽의 수면과 다른 한쪽의 왕실 건축물 사이에 그녀를 담아냅니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "로마의 초대 황제 아우구스투스 카이사르는 청동 스핑크스 두 개의 머리 사이, 그 매끄러운 얼굴이 바깥을 향한 곡면 의자에 앉아 있습니다. 그는 면도한 얼굴에 짧은 검은 머리를 이마 위로 빗어 넘겼으며, 이는 프리마 포르타 전통의 앞머리입니다. 흰 튜닉 위로 로마의 개선 의식에 착용하는 의례용 자주색 토가인 토가 픽타가 걸쳐져 있으며, 무릎 위와 왼쪽 어깨를 감아 올라갑니다. 튜닉의 목 테두리는 금으로 장식되어 있습니다. 오른손은 스핑크스 머리 하나 위에 활짝 펼쳐져 있으며, 왼손은 무릎 위에 느슨하게 얹혀 있습니다. 그의 뒤로는 홈 장식 기둥이 늘어선 어두운 붉은 벽의 흐릿한 홀이 펼쳐지고, 수직으로 내려진 붉은색과 금색의 깃발들이 걸려 있습니다. 뒷벽에는 원형 청동 메달리온에 사자 머리 부조가 새겨져 있습니다. 왼쪽에서 떨어지는 창백한 낮 빛이 그의 얼굴과 가슴을 가로지르며, 홀의 먼 쪽은 그늘 속에 잠겨 있습니다. 왕좌 양쪽의 철제 받침 위에 놓인 작은 화로 두 개가 낮게 타오르고 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "러시아의 황후이자 전제군주인 예카테리나 2세는 차르스코예 셀로의 예카테리나 궁전 대홀인 빛의 홀에 서 있습니다. 그녀의 몸은 관람자 쪽으로 사분의 삼 방향으로 돌려져 있으며, 시선은 정면을 향합니다. 검은 머리카락은 18세기 후반 유럽 궁정 양식으로 높게 올려 단장되어 있습니다. 작은 보석 장식의 관이 정수리에서 머리카락을 고정하고 있으며, 그 뾰족한 끝은 러시아 대제관의 키 큰 플뢰르 모양 아치를 축소한 형태를 연상시킵니다. 드레스는 궁정 의상으로 아이보리 실크로 만들어졌습니다. 전면 중앙에 금 자수 패널이 있는 꼭 맞는 보디스와, 어깨에 흰 담비 줄무늬로 장식된 짙은 청색의 부풀린 반소매로 이루어져 있습니다. 아래로는 풍성한 치마가 펼쳐지며, 러시아 황실의 상징인 쌍두 독수리가 반복 문양으로 금 자수되어 있습니다. 오른쪽 어깨에서 왼쪽 엉덩이로 넓은 연한 청색 무아레 새시가 걸쳐져 있는데, 이는 성 안드레아 일세 기사단의 리본입니다. 오른쪽 벽을 따라 늘어선 높은 아치형 창문에는 연한 청색 커튼이 너울 형태로 묶여 있으며, 햇빛이 거울처럼 닦인 흑백 대리석 바닥 위로 뚜렷한 줄기를 이루며 쏟아집니다. 왼쪽 벽에는 소용돌이와 잎사귀 장식의 금색 로코코 조각이 이어지며 거울 패널을 감싸고 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "북서부 쇼쇼니족의 추장 포카텔로는 산간 분지의 가장자리, 풍화된 붉은 바위 더미 위에 앉아 있으며, 장밋빛과 연한 보랏빛의 황혼 하늘 아래 낮은 대지들이 실루엣을 이루는 지평선까지 평탄한 세이지브러시 평원이 그의 뒤로 펼쳐집니다. 그는 떡 벌어진 어깨를 가졌으며, 긴 검은 머리카락은 가운데 가름마로 나뉘어 가슴까지 드리워지고, 독수리 깃털 하나가 머리 뒤쪽에 꽂혀 있습니다. 어깨 너머 등에 묶인 화살통에서 두 번째 검은 깃털이 솟아오릅니다. 짧은 나무 활이 화살통 옆으로 걸쳐져 있으며, 그 윗부분이 오른쪽 어깨 위로 불쑥 올라와 있습니다. 오른손에는 바위에 꽂혀 세워진 긴 창을 쥐고 있는데, 자루는 가죽으로 감겨 있고 창두 근처에 검은 술이 매달려 있습니다. 상체에는 모피 조끼를 걸치고 있으며, 오른쪽 어깨에서 왼쪽 엉덩이 방향으로 구슬 세공이 줄지어 새겨진 넓은 무두질 가죽 띠가 교차하고, 그 하단에 짧은 칼집이 매달려 있습니다. 위팔에는 은색 밴드가 겹겹이 감겨 있습니다. 허리 아래로는 어두운 가죽 술 달린 레깅스가 발목까지 드리워져 있으며, 그 사이로 허리 가리개가 걸쳐져 있습니다. 왼손은 허벅지 위에 펼쳐져 있으며, 자세는 고요하고 무게중심은 바위에 안정적으로 놓여 있습니다. 빛은 낮고 따뜻하여 바위의 붉은빛과 창의 테두리를 잡아내며, 그 너머 멀리는 로키산맥과 시에라네바다 산맥 사이 쇼쇼니족의 고향인 그레이트베이슨의 세이지브러시 땅이 펼쳐집니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "수코타이의 왕 람캄행 대왕은 햇살 가득한 궁전 정원에 서 있습니다. 열대 숲의 연두빛 안개와 태국의 종 모양 불교 스투파인 체디들의 흐릿한 실루엣이 낮게 깔린 안개 너머로 솟아오릅니다. 그는 가냘프고 상반신은 맨살이며, 피부는 따뜻한 갈색빛을 띠고, 고개는 약간 왼쪽으로 돌려 희미한 미소를 짓고 있습니다. 왕관은 높고 단을 이루며 뾰족하게 솟아 가는 첨탑으로 이어지는데, 이는 태국 왕의 원뿔형 왕관인 차다입니다. 넓은 금색 흉갑 칼라가 어깨와 가슴을 가로지르며, 소용돌이 타출 세공으로 장식되어 중앙에 붉은 보석이 하나 박혀 있고, 좁은 금색 밴드가 위팔을 각각 감싸고 있습니다. 흰 실크 새시가 허리에 감겨 매듭지어지며, 꼬인 끝이 허벅지까지 드리워집니다. 그 아래로 금빛 문양이 새겨진 짙은 붉은색 허리 감개가 걸쳐지고, 밑단에 더 어두운 아래 겹이 보입니다. 오른편으로는 고요한 연못가에 작은 석상이 서 있는데, 눈을 내려뜬 평온한 불두가 연꽃 봉오리 받침 위에 놓여 있으며, 연못에는 분홍빛 연꽃과 넓고 납작한 잎들이 떠 있습니다. 창백한 모래 오솔길이 왼쪽으로 붉은 꽃을 피운 관목 사이를 굽이쳐 수도의 안개 낀 탑들을 향해 뻗어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "송가이의 아스키아 대제 모하마드 1세는 석양 무렵 바위투성이 절벽 위에 서 있으며, 긴 칼날을 어깨에 메고 등 뒤로는 도시가 불타고 있습니다. 그는 검은 피부에 짧은 수염을 기르고 있으며, 눈은 관람자를 향해 고정되어 있습니다. 머리는 타겔무스트로 감싸여 있는데, 한쪽으로 모아진 연한 크림색의 사헬 터번이 높게 감겨 있습니다. 어깨에는 서아프리카 귀족의 넓은 소매 로브인 짙은 진홍색 부부가 드리워져 있으며, 전면 패널과 가슴에는 금색과 검은 실로 촘촘히 문양 수가 놓인 띠가 이어집니다. 그 아래로 연한 새시가 허리에 감겨 매듭지어지며 엉덩이 옆으로 끝이 느슨하게 늘어지고, 같은 진홍색의 바지 위로 걸쳐져 있습니다. 오른손으로 칼자루를 쥐고 칼날을 어깨 위로 눕혀 받치고 있으며, 칼은 길고 등이 곧으며 끝으로 갈수록 약간의 곡선을 이룹니다. 오른쪽으로 땅은 낮은 태양을 배경으로 검게 실루엣을 이룬 산이 붉은 주황빛 하늘 아래 평원으로 내려앉습니다. 왼쪽으로는 도시가 불타고 있습니다. 흙벽돌 성벽과 돌출된 나무 토론의 줄로 촘촘히 박힌 높은 사각 미나렛이 있으며, 석고에서 삐져나온 야자나무 들보가 그대로 남아 있습니다. 불길이 탑을 타오르며 아래 거리를 감싸고, 더 작은 불들이 도시와 그가 서 있는 절벽 사이 평원 곳곳에 흩어져 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "카스티야와 레온의 여왕이자 아라곤의 왕비인 이사벨라 1세는 그라나다 알람브라 궁전의 기둥 회랑 중 하나에 서 있으며, 아케이드는 다듬어진 생울타리와 화분 속 조형 수목이 있는 정원으로 열려 있고, 언덕들은 저 멀리 안개 속으로 희미해집니다. 조각된 주두를 가진 가느다란 쌍기둥이 그녀 뒤로 격자 세공으로 채워진 엽편 형태와 가리비 형태의 아치로 솟아오르며, 그 위 스팬드럴은 연한 금색과 모래색 톤의 촘촘한 기하학적, 식물 문양의 치장 벽토로 조각되어 있습니다. 그녀는 가냘프고 창백하며, 양손을 허리 앞에 포개고 있습니다. 머리는 카스티야 궁정 양식으로 덮여 있는데, 턱 아래와 목 앞으로 가깝게 드리운 흰 윔플, 머리 위에 꼭 맞는 흰 베일, 그리고 그 위로 붉은색과 초록색 보석이 박힌 작은 닫힌 금관이 얹혀 있습니다. 어깨에는 금 테두리로 장식되어 앞쪽으로 열린 긴 붉은 망토가 드리워져 있습니다. 그 아래 드레스는 어두운 반복 문양의 크림 브로케이드로, 꼭 맞는 보디스에 치마 중앙으로 금 테두리 패널이 내려옵니다. 가슴에는 망토가 벌어지는 곳에 붉은 보석이 고정되어 있습니다. 빛은 늦은 오후의 따뜻하고 낮은 빛으로, 아케이드의 치장 벽토와 회랑 석조 바닥을 잡아냅니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "스웨덴, 고트족, 벤드족의 왕이자 북쪽의 사자인 구스타브 아돌프는 금박이 입혀진 궁전 홀에 서 있습니다. 그의 옆으로는 깊은 벽난로에서 장작이 낮고 밝게 타오릅니다. 그는 키가 크고 건장하며, 가슴까지 내려오는 풍성한 불그스름한 수염과 굵게 위로 올린 콧수염을 가졌으며, 머리카락은 높은 이마에서 뒤로 빗어 넘겨져 있습니다. 금박 띠가 테두리와 중앙 능선을 따라 새겨진 검게 처리된 강철 흉갑을 걸치고 있으며, 이는 두껍고 창백한 기름 먹인 황소가죽의 버프 코트 위에 입혀져 있습니다. 갑옷은 아래로 이어져 허벅지 중반까지 퍼지는 관절형 강철 태스셋이 노란 안감 치마 위로 덮입니다. 오른쪽 어깨에서 왼쪽 엉덩이까지 청록색 실크 새시가 가로질러 매듭지어지며 흉갑 위로 느슨하게 접혀 드리워집니다. 손목에는 작은 레이스 커프스가 보이고, 부츠 위 바지 위로 연한 레이스 주름이 드리워져 있습니다. 그는 무게를 뒤로 실은 자세로, 양쪽 장갑 낀 손을 앞쪽 바닥에 꽂혀 세워진 지휘봉 위에 얹고 있습니다. 그의 뒤로 벽난로 주변은 조각되어 금박이 입혀져 있으며, 맨틀은 바로크식 아칸서스 소용돌이 세공의 띠로 장식되어 있습니다. 왼쪽으로는 금박 액자 그림 두 점이 초록색과 금색의 다마스크 벽 위에 걸려 있습니다. 가까운 그림은 이전 스웨덴 왕 에리크 14세로, 어두운 갑옷의 수염 난 남자입니다. 먼 그림은 브란덴부르크의 마리아 엘레오노라로, 구스타브의 아내이며 연한 궁정 가운을 입은 창백한 여인입니다. 그림들 아래 광택 나는 짙은 나무 탁자에는 과일이 수북이 담긴 얕은 퓨터 그릇이 놓여 있고, 탁자 가까운 쪽 끝에 키 큰 황동 촛대가 솟아 있으며 초들은 켜져 있지 않습니다. 방은 거의 전적으로 불빛만으로 밝혀져 있습니다. 따뜻한 주황빛이 흉갑, 금박 석고 세공, 그리고 그의 얼굴 오른편을 감싸며, 먼 쪽 벽은 그늘 속에 잠겨 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "베네치아 공화국의 도제 엔리코 단돌로는 밤의 운하 위 돌다리에 서 있으며, 장갑 낀 한 손을 가슴 앞으로 들어 올리고 있습니다. 그는 노인으로, 긴 회색 수염이 가슴까지 내려오고, 귀 밑으로 회백색 머리카락이 보이며, 얼굴에는 깊은 주름이 새겨져 있습니다. 머리에는 코르노 두칼레, 즉 뒤가 둔하게 솟아오른 프리기아 모자 모양의 녹슨 붉은 브로케이드 뻣뻣한 뿔 모양 도제 모자를 쓰고 있으며, 그 아래로 이마 테두리에 꼭 맞는 흰 리넨 카마우로의 테두리가 보입니다. 어깨에는 연한 모피로 장식된 무거운 회색 망토가 드리워져 앞쪽으로 열려 있고, 안쪽은 모자와 같은 녹슨 붉은색으로 되어 있습니다. 그 아래 짙은 붉은 브로케이드의 긴 로브가 금 끈으로 허리를 묶어 매듭지어져 있습니다. 다리 난간은 단조 철로 만들어졌으며, 패널은 베네치아 고딕 양식의 가느다란 뾰족 아치로 채워져 있습니다. 그의 뒤로 운하는 어둠 속으로 물러나며, 양쪽으로 창문이 청색 밤 하늘을 배경으로 따뜻한 주황빛으로 빛나는 팔라치들이 늘어서 있습니다. 구름 사이로 별빛이 비치는 하늘 아래 좁은 곤돌라가 왼편 부두에 정박해 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "줄루의 왕 샤카 카센잔가코나는 왕실 거주지의 개방된 터에 발을 굳게 딛고 서 있으며, 왼쪽에는 방패를, 오른쪽에는 짧은 창을 들고 있습니다. 그는 상반신이 맨살로 검은 피부에 단단한 근육을 가졌으며, 상체에는 가는 구슬을 꿴 끈들이 교차합니다. 머리에는 움켈레, 즉 왕족과 고위 신분을 나타내는 표범 가죽으로 만든 두꺼운 원형 머리띠를 두르고 있습니다. 이마에는 끝이 붉게 물든 흰 깃털 장식이 곧게 꽂혀 있습니다. 허리에는 표범 가죽 앞치마가 엉덩이 위로 드리워지고, 그 아래로 긴 연한 털 술들이 허벅지를 따라 흔들립니다. 같은 표범 가죽 밴드가 발목을 감싸고 있습니다. 왼손에는 이시흘란구, 즉 높고 뾰족한 타원형의 소가죽 전투 방패를 들고 있으며, 표면은 갈색과 흰색이 어울려 얼룩지고, 가운데로 곧은 나무 자루가 내려오며 가죽 고리로 고정되어 있습니다. 오른손에는 낮게 내려 언제든 쓸 수 있는 자세로 이클와, 즉 넓고 긴 잎새 형태의 날을 가진 짧은 자루의 찌르기 창을 쥐고 있습니다. 그의 뒤로는 이쿠크와네, 즉 줄루 우무지의 돔형 초가 벌집 오두막들이 줄지어 이어지며, 엮인 표면에 햇빛이 내려앉습니다. 터 양쪽으로는 뿔이 길고 넓게 뻗은 소의 두개골을 얹은 나무 기둥들이 솟아 있는데, 그 웅장한 뿔이 여전히 붙어 있어 문 앞에 재물과 제의로서 전시되어 있습니다. 땅은 건조하고 창백한 흙이며, 멀리 평정 대지가 보이고, 위의 하늘은 얇은 구름이 드리운 맑은 연한 청색입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "행복도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "자원"

-- Economy Overview columns
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "인구"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "방어력"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "식량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "과학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "금"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "문화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "신앙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "생산"

-- Economy Overview city annotations (tail tokens - no terminal punct)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "수도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "괴뢰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "점령"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "점령"

-- Economy Overview city row templates
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "항목 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "생산 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    other = "{1_Turns} 턴: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "턴당 {1_PerTurn}, {2_Cell}"

-- Economy Overview composite cells
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"

-- Economy Overview gold tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "총 금, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "수입, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "지출, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "턴당 순수익, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "금 적자로 인한 과학 손실, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "도시, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "외교, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "종교, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "도시 연결, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "유닛, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "건물, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "개선, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "외교, {1_Value}"

-- Economy Overview happiness tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "총 행복도, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "행복도 원천"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "사치 자원, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "사치 자원 다양성, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "사치 자원 보너스, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "기타 사치 자원 보너스, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "도시 행복도, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "건물, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "각 도시의 건물, 수비대, 종교, 정책 연동으로 인한 행복도. "
    .. "도시 인구를 상한으로 합니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "불가사의 보너스, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "건물 계열 연동, 미변경 행복도, 또는 정책당 보너스를 제공하는 "
    .. "불가사의로부터 얻는 행복도. 일반 행복도 건물은 이 항목이 아닌 "
    .. "건물 (도시별)에 반영됩니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "제국 전체 보너스, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "교역로, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "도시 국가, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "정책, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "종교, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "자연 불가사의, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "도시별 보너스, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "보유한 도시마다 일정 행복도를 제공하는 건물 또는 정책으로 인한 행복도. "
    .. "도시 수에 비례합니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "세계 대회, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "난이도, {1_Value}"

-- Economy Overview unhappiness tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "총 불행, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "불행 원천"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    other = "{1_Count} 도시, {2_Value} 불행",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    other = "{1_Count} 점령 도시, {2_Value} 불행",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    other = "{1_Count} 시민, {2_Value} 불행",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    other = "{1_Count} 점령 시민, {2_Value} 불행",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "여론, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "도시별 내역"

-- Economy Overview resources tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "사용 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "사용 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "국내"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "수입"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_FROM_CITY_STATES"] = "도시국가에서"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "수출"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "n/a"

-- Victory Progress (VP) tabs and columns
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "점수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "승리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "합계"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, 수도 상실"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "정복"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "과학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "외교"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "문화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "{1_Num}팀"

-- Victory Progress science parts
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    other = "{1_Num} 부스터",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "조종석"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "동면 캡슐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "엔진"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, 아폴로 계획 미건설"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, 아폴로 계획 건설"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "아폴로 계획 건설, 부품 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, 아폴로 계획 건설, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "아폴로 계획 건설, {1_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    other = "{1_Have}/{2_Total} 선행 기술 연구 완료",
}

-- Demographics (DEMO)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, {2_Rank}위, {3_Value}, 최고 {4_BestCiv} {5_BestVal}, 평균 {6_AvgVal}, 최저 {7_WorstCiv} {8_WorstVal}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "국민 총생산"

-- Culture Overview (CO) tabs
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "내 문화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "걸작 교환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "문화 승리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "플레이어 영향력"
-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] =
    "고대 유적지: {1_Visible}개 발견됨, {2_Hidden}개 숨겨짐"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    other = "{1_Name}, 문화 {2_Cul}, 관광 {3_Tou}, 걸작 {4_Filled}/{5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    other = "{1_Name}, 문화 {2_Cul}, 관광 {3_Tou}, 걸작 {4_Filled}/{5_Total}, 손상 {6_Pct}%",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "수도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "괴뢰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "점령"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "위대한 예술품 건물이 아직 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "도시 없음"
-- Slot type words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "문학 슬롯"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "미술 또는 유물 슬롯"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "음악 슬롯"
-- Multi-slot building entry inside a city.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled}/{4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled}/{4_Total}, 테마 보너스 +{5_Bonus}"
-- Single-slot building rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, 비어 있음"
-- Per-slot leaf inside a multi-slot building.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, 비어 있음"
-- Work-class words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "문학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "미술"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "유물"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "음악"
-- Slot tooltip forms.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class}, 제작자 {2_Artist}, {3_OriginCiv}, {4_Era}, 문화 +{5_Cul}, 관광 +{6_Tou}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "제작자 {1_Artist}, {2_OriginCiv}, {3_Era}, 문화 +{4_Cul}, 관광 +{5_Tou}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, 문화 +{4_Cul}, 관광 +{5_Tou}"
-- GW move flow feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "이동 원본으로 선택됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "이동됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "이동 원본 선택 취소됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] =
    "현재 원본과 슬롯 유형이 맞지 않습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "빈 슬롯에서 이동할 수 없습니다."
-- Tab 2 (Swap Great Works).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "내 제공 작품"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "문학"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "미술"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "유물"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "지정되지 않음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "지정 초기화"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "다른 문명에서 제공 가능한 작품"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] =
    "교환 가능한 작품을 제공하는 문명이 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "교환 가능한 작품 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] =
    "교환할 다른 문명의 작품을 선택하십시오."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "{3_TheirCiv}의 {2_TheirName}과 교환할 {1_Type}이 지정되지 않았습니다. 내 제공 작품에서 지정하십시오."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "내 {1_YourName}을 {3_TheirCiv}의 {2_TheirName}과 교환합니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "교환 전송됨"
-- Tab 3 (Culture Victory).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{2_Total}개 중 {1_N}개"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "이념 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "여론 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "영향 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "관광"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "이념"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "여론"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] = "여론 불행"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "잉여 행복도"
-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    other = "영향력 달성까지 약 {1_N} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "시점 전환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "영향력 수준"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "영향력 비율"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "관광 수정자"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "해당 문명에 대한 관광 속도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "추세"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "턴당 관광 {1_N} 생성 중, Enter 키를 눌러 이 시점으로 전환합니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] = "{1_Civ} 시점으로 전환됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "내 관광 {1_Yours}, 상대 누적 문화 {2_Theirs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "하락"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "정체"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "상승"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "완만한 상승"
-- Hotkey help.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control 플러스 C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "문화 개요 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] =
    "이 게임에서는 문화 개요를 사용할 수 없습니다."
-- League Overview (World Congress / United Nations).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "세계 의회"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control 플러스 L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "세계 의회 개요 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "현황"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "제안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "효과"
-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "이름 변경"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(나)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "호스트"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    other = "{1_N}명의 대표",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "제안 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "상대 수도 파견 외교관"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "세계 의회 없음"
-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "이번 회기에 가능한 행동이 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    other = "제안 가능 {1_N}건.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    other = "미배분 대표 {1_N}명.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "이번 회기에 제안이 없습니다."
-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "제정: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "폐지: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "{1_Civ} 제안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "내 제안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "보류 중"
-- Vote-state suffix.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "내 투표: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "기권"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    other = "{1_N} 찬성",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    other = "{1_N} 반대",
}
-- Cast-vote row.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{2_Civ}에 {1_N}표"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "빈 제안 슬롯 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "슬롯 {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "제안 슬롯 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "폐지할 활성 결의안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "제안할 결의안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "기타 결의안"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] = "이 제안에 대한 예상 표 수:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] = "찬성할 문명: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] = "반대할 문명: {1_Civs}"

-- Religion Overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control 플러스 R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "종교 개요 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "{1_Religion}의 창시자입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "{1_Type} 교의"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    other = "{1_Religion}, 성지 도시 {2_HolyCity}, {3_Founder} 창시, {4_NumCities}개 도시",
}

-- Espionage Overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Control 플러스 E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "첩보 개요 열기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "요원"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "정보"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] =
    "이 게임에서 첩보는 비활성화되어 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    other = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} 턴",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} 전사"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", 외교관"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "{1_Rank} {2_Name} 행동"
-- City row pieces
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "문명 {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "도시 {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "인구 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "잠재력 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "기본 잠재력 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "세부 내역: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "잠재력 알 수 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] = "도시 국가, 선거 조작 가능"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] = "도시 국가, 선거 조작 중"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "요원 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "외교관 {1_Name}"
-- Intrigue row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "{1_N} 턴"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "아군 스파이 {1_Name} 보고"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "{1_Leader}이(가) 공유"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "알 수 없음"
-- Move-agent sub
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "{1_Rank} {2_Name} 이동"

-- Bookmarks
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "북마크 추가됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "북마크 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Control 플러스 숫자 키"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] =
    "커서 위치를 해당 슬롯에 북마크로 저장합니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Shift 플러스 숫자 키"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "해당 슬롯의 북마크로 커서를 이동합니다. 뒤로 가기로 돌아올 수 있습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt 플러스 숫자 키"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "커서에서 해당 슬롯의 북마크까지의 거리와 방향"

-- Beacons
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "활성화: 비콘 {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "비활성화: 비콘 {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] = "먼저 이 슬롯에 북마크를 설정하십시오."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] = "Control 플러스 Shift 플러스 숫자 키"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "해당 슬롯의 북마크에 공간 음향 비콘을 켜거나 끕니다."

-- Message buffer
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "전체 메시지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "알림"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "발견"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "전투"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "채팅"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "메시지 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "왼쪽 대괄호와 오른쪽 대괄호"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "버퍼에서 이전 또는 다음 메시지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] =
    "Control 플러스 왼쪽 대괄호와 오른쪽 대괄호"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] = "버퍼에서 가장 오래된 또는 최신 메시지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] =
    "Shift 플러스 왼쪽 대괄호와 오른쪽 대괄호"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "버퍼 필터 분류를 순환합니다. 빈 분류는 건너뜁니다."

-- Multiplayer chat
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Backslash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] =
    "멀티 플레이 채팅 패널 열기. 싱글 플레이에서는 동작하지 않습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "채팅은 멀티 플레이 전용입니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "채팅"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "메시지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "작성"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "메시지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "채팅 메시지가 없습니다."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name}이(가) 팀에게: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name}이(가) {2_To}에게: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "백슬래시 또는 Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "채팅 패널 닫기"

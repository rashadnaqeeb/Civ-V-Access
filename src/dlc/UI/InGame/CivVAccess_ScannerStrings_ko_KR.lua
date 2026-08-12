-- Mod-authored strings, ko_KR overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "내 도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_TEAMMATE"] = "팀원 도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_CITY_STATES"] = "도시 국가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "중립 도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "적 도시"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "야만족 야영지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "내 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_TEAMMATE"] = "팀원 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "중립 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "적 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "시설"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "경작 중인 타일"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_YIELDS"] = "수확량"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "특수"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "추천"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "경유지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_GEOGRAPHY"] = "지리"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "전체"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "근접 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "기병 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "민간 유닛"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "야만족"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "내"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY_PILLAGED"] = "내 약탈됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TEAMMATE"] = "팀원"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "중립"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "적"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "기본 지형"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "고도"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_LANDMASSES"] = "육지"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_OCEANS"] = "바다"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"] = "미탐험"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"] = "{1_Count} 미탐험"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_LANDMASS"] = "육지 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_OCEAN"] = "바다 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_HEXES"] = {
    other = "{1_Name}, {2_Count} 타일",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_FULLY_REVEALED"] = "{1_Body}, 완전 탐험됨"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} / {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "여기"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "비어 있음"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "돌아갈 이동 없음"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "검색"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "검색 결과"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "{1_Buffer}에 해당하는 결과 없음"

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Page up 또는 Page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "하위 카테고리 내 항목 순환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Shift 더하기 Page up 또는 Page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "카테고리 내 하위 카테고리 순환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control 더하기 Page up 또는 Page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "카테고리 순환, 스냅샷 재구성"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt 더하기 Page up 또는 Page down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "항목 내 인스턴스 순환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CUSTOM_FLAT"] = "J, K 또는 L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CUSTOM_FLAT"] =
    "첫 번째, 두 번째 또는 세 번째 사용자 카테고리를 가장 가까운 항목부터 순환; Shift는 이전 항목으로 순환"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Home 또는 M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "현재 항목 위치로 커서 이동"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "커서에서 항목까지의 거리 및 방향"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control 더하기 F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "스캐너 항목 검색"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "이동 전 셀로 커서 복귀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_GROUP"] = "사용자 카테고리"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_ADD"] = "카테고리 추가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_DELETE"] = "카테고리 삭제"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL"] = "사용자 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM"] = "사용자 카테고리 {1_Num} 없음"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORDS_GROUP"] = "키워드"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADD"] = "키워드 추가"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADDED"] = "키워드 추가됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_REMOVED"] = "키워드 제거됨"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_DUPLICATE"] = "이미 추가된 키워드"

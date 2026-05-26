-- Mod-authored strings, zh_Hant_HK overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "我方城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_TEAMMATE"] = "隊友城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_CITY_STATES"] = "城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "中立城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "敵方城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "野蠻人營地"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "我方單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_TEAMMATE"] = "隊友單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "中立單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "敵方單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "改良設施"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "工作格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "特殊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "建議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "路徑點"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "全部"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "近戰單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "騎乘單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "平民單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "野蠻人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "我方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY_PILLAGED"] = "我方已劫掠"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TEAMMATE"] = "隊友"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "中立"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "敵方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "基本地形"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "海拔"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"] = "未探索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"] = "{1_Count} 未探索"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "第 {1_Index} 個, 共 {2_Total} 個"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "在此"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "空"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "沒有可返回的跳轉"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "搜尋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "搜尋結果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "找不到 {1_Buffer}"

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Page Up 或 Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "在子類別內循環項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Shift 加 Page Up 或 Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "在類別內循環子類別"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control 加 Page Up 或 Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "循環類別, 重建快照"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt 加 Page Up 或 Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "在項目內循環實例"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Home"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "將游標跳至當前項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "游標至項目的距離與方向"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control 加 F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "搜尋掃描器項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "返回跳轉前的游標位置"

-- Mod-authored strings, zh_Hant_HK overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- Batch 01 (lines 123-420): 100 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "文明5無障礙模組已在遊戲中載入."
-- Hotseat-mute toggle.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "模組已暫停"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "模組已恢復"
-- Unit speech.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "建議: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "城市選址"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "海運 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} 生命值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} 行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} 飛行器"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "可晉升"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    other = "{1_What} {2_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "已排程移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO"] = {
    other = "已排程移動 {1_Dir}, {2_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} 近戰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} 遠程戰鬥力, 射程 {2_Range}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} 遠程戰鬥力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "射程 {1_Strike}, 重新部署射程 {2_Rebase}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "攻擊次數已耗盡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "行動力已耗盡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "生命值 {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "綠"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "黃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "紅"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "滿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "等級 {1_Lvl}, {2_Cur}/{3_Next} 經驗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "升級為 {1_Name}, {2_Gold} 金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "晉升: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    other = "已移動, 剩餘 {1_Num} 行動力",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "提前停止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    other = "提前停止, 距抵達尚需 {1_Num} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "行動失敗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "已排程至下回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "遠程單位, 請使用遠程攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "空中單位, 請使用遠程攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "無法攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "攻擊次數已耗盡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "行動力已耗盡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "飛行器無法以此方式移動, 請使用重新部署"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "不相鄰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "僅可攻擊城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "海軍單位無法攻擊陸地"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "無法攻擊此目標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "無單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "無行動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "將宣戰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "單位行動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "啟動地格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "晉升"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "建造改良設施"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "目標模式"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "已排程"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "無法排程攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "已取消"
-- Combat preview vocabulary.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "超出射程"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} 對 {3_TheirStr}, {4_Result}, {5_DmgToMe} 傷害至我方, {6_DmgToThem} 傷害至對方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "火力支援 {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "俘獲機率 {1_Pct} 百分比"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "我方加成 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "對方加成 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "加 {1_N} 百分比 {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "減 {1_N} 百分比 {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} 對 {3_TheirStr}, {4_Result}, {5_DmgToThem} 傷害至對方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "城市 {1_Name}, {2_MyStr} 對 {3_TheirStr}, {4_DmgToMe} 傷害至我方, {5_DmgToThem} 傷害至對方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "城市 {1_Name}, {2_MyStr} 對 {3_TheirStr}, {4_DmgToThem} 傷害至對方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "{1_Dmg} 傷害至我方"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    other = "{1_N} 攔截機",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "移動至 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, {2_Left} 剩餘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    other = "{1_MP} MP, {2_Turns} 回合, {3_Left} 剩餘",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "本回合, 未探索區域"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    other = "{1_Turns} 回合, 未探索區域",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "本回合, {1_Steps} 後進入未探索區域"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    other = "{1_Turns} 回合, {2_Steps} 後進入未探索區域",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] = "本回合, {1_Steps} 後發動攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    other = "{1_Turns} 回合, {2_Steps} 後發動攻擊",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "無路徑"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "距離過遠, 無法計算"
-- ===== Path diagnostics =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "受 {1_Civ} 邊界阻擋, 最近可到達 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "受 {1_Civ} 邊界阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] = "受封閉邊界阻擋, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "受封閉邊界阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] = "受 {1_Unit} 阻擋, 最近可到達 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "受 {1_Unit} 阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] = "受單位阻擋, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "受單位阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] = "無路徑, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] = "缺乏海運科技, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "缺乏海運科技"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] = "需要天文學, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "需要天文學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] = "受山脈阻擋, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "受山脈阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] = "受 {1_Wonder} 阻擋, 最近可到達 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "受 {1_Wonder} 阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] = "無水路連接, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "無水路連接"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "無法從陸地發動攻擊, 最近可到達 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "無法從陸地發動攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "無法從水域發動攻擊, 最近可到達 {1_Dir}"

-- Batch 02 (lines 422-638): 100 keys

-- ===== Path failure =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] = "無法從水域發動攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] = "無法前往陸地, 最近可到達方向 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "無法前往陸地"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "需要海運"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "需要登陸"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "此處無目標"

-- ===== Route preview =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TILES_CLAUSE"] = {
    other = "{1_N} 格",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    other = "{1_N} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    other = "{1_Tiles} 格, 無需施工",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD"] = "無可用路線"

-- ===== Special mode previews =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "無法在此空降"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "無法在此空運"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "無法在此轉移基地"

-- ===== Rebase =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    other = "{1_Name}, {2_N} 格",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] = "射程內無轉移基地目標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "已轉移基地至 {1_Name}"

-- ===== Airlift =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "選擇空運目的地城市. 選定後, 再選擇單位降落的格子, 距城市不可超過 1 格."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    other = "{1_Name}, {2_N} 格",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] = "無可用空運目的地"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "無法在此海運"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "無法在此登陸"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "無法在此發射核武"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "無法在此贈送單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "無法在此改善"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "無可見攔截機"

-- ===== Legal action previews =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "在此空運"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "在此空降"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] = "在此發射核武, 爆炸半徑 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "贈送 {1_Unit} 予 {2_Recipient}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] = "為 {2_Recipient} 改善 {1_Resource}"

-- ===== Unit control help overlay =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "句號, 逗號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "切換至下一個或上一個單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Control 加 句號或逗號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "切換至下一個或上一個單位, 包含已行動的單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "斜線"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] = "讀取所選單位的戰鬥及晉升資訊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Control 加 斜線"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] = "將游標重新置中於所選單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "開啟單位行動選單"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt 加 Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "移動所選單位一格 (雙按確認攻擊)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt 加 M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "開啟移動目標選擇器, 以方向鍵瞄準, 空白鍵預覽, Enter 確認"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt 加 S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] = "駐紮軍事單位, 或使平民進入睡眠"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt 加 F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] = "哨戒, 直到發現敵方單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt 加 W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "喚醒睡眠中或駐紮的單位, 或取消已排程的移動或自動化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt 加 X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "跳過該單位本回合行動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt 加 H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "治療至滿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt 加 R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "開啟遠程攻擊目標選擇器, 以方向鍵瞄準, 空白鍵預覽, Enter 確認"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt 加 P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "掠奪單位所在格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt 加 U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "升級單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt 加 N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "重新命名單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} 不可用"

-- ===== Combat results =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "攻擊方 {1_Name} -{2_Dmg} 生命值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "防禦方 {1_Name} -{2_Dmg} 生命值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "攻擊方 {1_Name} 未受傷"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "防禦方 {1_Name} 未受傷"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} 陣亡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} 被俘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "未知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "被 {1_Name} 攔截"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "攔截"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "空戰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "無攔截機"

-- ===== Nuclear strike =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "{1_Civ} 核打擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "目標 {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "傷亡 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "單位 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "未命中任何目標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} 生命值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} 人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "陣亡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "已摧毀"

-- ===== City capture =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "攻佔 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "失去 {1_Name}"

-- ===== Unit action confirms =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "駐紮"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "睡眠中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "警戒中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "已喚醒"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "自動化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "已解散"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "治療中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "已掠奪"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "已跳過"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "已升級"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "已取消"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "開始 {1_Build}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "晉升為 {1_Name}"

-- ===== Button state =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "已停用"

-- Batch 03 (lines 643-856): 100 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, 已停用"
-- Cursor / hex-grid handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "東"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "東北"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "東南"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "西南"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "西"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "西北"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "地圖邊緣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "射程邊緣"
-- Tile-state words
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "未占領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "未探索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "迷霧"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "未看見"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "無首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    other = "{1_Moves} 行動力",
}
-- River and fresh-water tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "河流 {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "河流全側"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "淡水"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "路徑點 {1_Index}/{2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} 已劫掠"
-- Macro-terrain tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "丘陵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "山脈"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "湖泊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} 生命值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    other = "{1_Build} {2_Turns} 回合",
}
-- Yield + count glue
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "由 {1_City} 管轄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "已管轄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} 百分比防禦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "在敵方控制區內"
-- Cursor help-overlay key labels
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Q, W, E, A, S, D, Z, X, C 組合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] = "按格移動游標 (Q 西北, E 東北, A 西, D 東, Z 西南, C 東南)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] = "數字鍵盤 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] = "以相同修飾鍵反映 Q, W, E, A, S, D, Z, X, C (數字鍵盤 5 對應 S, 須開啟 Num Lock)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "讀取當前格上的單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Shift 加 S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "游標相對於原始首都的坐標, 採用修正偏移表示法 (每向東一步 x 加一, 每向東北一步 x 加 0.5 及 y 加一, 每向東南一步 x 加 0.5 及 y 減一)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Control 加 S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "將游標跳至您的首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "當前格的經濟詳情"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "當前格的戰鬥詳情"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "城市身分與戰鬥"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "城市生產與成長"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "城市宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] = "城市外交備注"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "選取單位, 或開啟城市畫面 (傀儡城市顯示吞併彈出視窗, 已接觸的主要文明顯示外交視窗)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Control 加 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "開啟游標所在格上所有項目的百科全書 (單位, 世界奇蹟, 改良設施, 資源, 地貌, 河流, 湖泊, 地形, 丘陵, 山脈, 道路)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "此格文章"
-- City-info speech tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "未接觸"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "可攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "此處無城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "文化城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "尚武城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "沿海城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "商業城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "宗教城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "中立"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "友善"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "同盟"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "戰爭"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "永久戰爭"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    other = "焚毀中 {1_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    other = "抵抗 {1_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "已佔領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "已封鎖"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} 人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} 防禦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur}/{2_Max} 生命值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "駐紮 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    other = "生產中 {1_Name} {2_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "生產中 {1_Name}"
-- City development tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "未生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur}/{2_Needed} 生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} 每回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    other = "{1_Turns} 回合後成長",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "飢餓中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "停止成長"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur}/{2_Threshold} 食物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} 每回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "每回合減少 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] =
    "生產資訊隱藏, 請查閱間諜總覽"
-- City religion tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    other = "透過 {1_N} 條貿易路線",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "無宗教"
-- City diplomatic notes
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "原屬 {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "好戰預覽: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "解放預覽: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "間諜 {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "外交官 {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "無外交備注"

-- Batch 04 (lines 862-1024): 100 keys
-- Map mode, search, help overlay, BaseTable, settings, widget-generic, screen names, ranking, diplomacy, great work

-- ===== Map mode =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "地圖模式"

-- ===== Type-ahead search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "{1_Buffer} 無符合項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "搜尋已清除"

-- ===== Help overlay =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "幫助"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "字母"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Up 或 Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home 或 End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter 或 Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Left 或 Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift 加 Left 或 Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Control 加 Up 或 Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt 加 Left 或 Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift 加 Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control 加 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "問號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "輸入以搜尋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "瀏覽項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "跳至第一或最後"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "啟動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "調整數值或展開"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "以較大步幅調整數值"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "跳至上一或下一組"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "下一分頁"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "上一分頁"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "讀取畫面標題"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "開啟當前項目的文明百科條目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "取消"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "關閉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "取消編輯"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "確認編輯"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Control 加 Shift 加 F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "開啟設定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "關閉設定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "暫停或恢復模組"

-- ===== BaseTable =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, 降序"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, 升序"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, 排序已清除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "排序按鈕"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "在列之間移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "在欄之間移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "第一或最後一列"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "啟動儲存格或按欄排序"

-- ===== Settings overlay =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "設定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "地形音效提示"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "僅語音"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "語音和音效提示"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "詳細語音說明"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "僅音效提示"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "地形音效音量"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "地形音效音量, {1_Num} 百分比"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "信標可聽距離"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] = "信標可聽距離, {1_Num} 格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "掃描器自動移動游標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "游標跟隨已選取單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "移動時顯示游標座標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "關"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "在移動播報前朗讀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "在移動播報後朗讀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] = "在格資訊中始終播報領土"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "掃描器顯示座標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "朗讀字幕"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "移動時播報可見度變化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "播報 AI 戰鬥結果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] = "在回合開始時播報可見度變化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] = "播報視野內其他文明佔領的營地和遺址"

-- ===== Widget-generic strings =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "已選取"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "已選取, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "開"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "關"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_STATE"] = "{1_Label}, {2_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_VALUE"] = "{1_Label} {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABELED_LIST"] = "{1_Label} {2_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT"] = "{1_Label}, {2_Amount}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE"] = "{1_Label}, {2_Amount}, {3_TurnsLine}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_VALUE_UNIT"] = "{1_Value} {2_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "編輯"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "空白"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "正在編輯 {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} 已還原"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "按鈕"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "切換鈕"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "滑桿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "組合方塊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "子選單"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "表格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "第{1_Num}項, 共{2_Num}項"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "第{1_Num}列, 共{2_Num}列"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "第{1_Num}欄, 共{2_Num}欄"

-- ===== Screen names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "暫停選單"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "彈出視窗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "奇蹟完成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "世界議會"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "遊戲結束"

-- ===== End-game ranking =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, 得分 {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] = "{1_Rank} {2_Leader}, 您的得分 {3_Score}, {4_Quote}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "第 {1_Turn} 回合"

-- ===== Diplomacy screen names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "宣戰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "城邦問候"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "外交"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "譴責"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "合作戰爭目標"

-- ===== Great work popup =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "偉大著作"

-- Batch 05 (lines 1028-1247): 100 keys
-- Choose-screen headers, religion picker, notification log, league project,
-- vote results, who's winning, advisor tutorial, notification tabs, combat log,
-- military overview, advisor counsel, city view hub.

-- Choose-screen headers
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "選擇部落村莊獎勵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WARRIOR"] = "戰士"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_POPULATION"] = "人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_CULTURE"] = "文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PANTHEON_FAITH"] = "信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_PROPHET_FAITH"] = "大預言家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_NEARBY_BARBS"] = "揭示附近野蠻人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_LOW_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HIGH_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_MAP"] = "揭示附近地圖"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_TECH"] = "免費科技"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_REVEAL_RESOURCE"] = "揭示附近資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_UPGRADE_UNIT"] = "升級單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SETTLER"] = "開拓者"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_SCOUT"] = "斥侯"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_WORKER"] = "工人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_EXPERIENCE"] = "經驗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GOODY_LABEL_HEALING"] = "治療單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "選擇免費偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "選擇信仰偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "選擇馬雅加成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "選擇萬神殿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "選擇意識形態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "選擇考古結果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "選擇海軍上將新港口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "選擇貿易單位新駐地"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "建立貿易路線"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "確定"

-- Religion screens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "選擇宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "強化宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "更改宗教名稱"

-- Belief-slot label formats
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, 未選擇"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, 稍後可用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, 僅限拜占庭"

-- Religion-picker row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "宗教, 未選擇"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "宗教, {1_Name}"

-- Name row
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "名稱, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "宗教名稱"

-- Notification Log
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "通知紀錄"

-- League Project popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "議會工程完成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, {3_Score} 生產, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "金級獎勵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "銀級獎勵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "銅級獎勵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "無獎勵"

-- Vote Results popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "投票結果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    other = "{1_Rank}, {2_Name} 投票給 {3_Cast}, 獲得 {4_Votes} 票",
}

-- Who's Winning popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "誰領先"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"

-- Tutorial Advisor
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "教學顧問"

-- Notification Log tabs
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "進行中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "回合紀錄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "已關閉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "無通知."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, 第 {2_Turn} 回合"

-- Combat Log
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "戰鬥紀錄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "本回合無戰鬥."

-- Military Overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: {2_Cur} / {3_Max} 經驗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "補給: {1_Use} / {2_Cap}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "閒置"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "距離"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "剩餘行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "最大行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "戰鬥力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "遠程"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress} / {4_Threshold}, 每回合加 {5_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] = "{1_City}: {2_Progress} / {3_Threshold}, 無進展"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "下回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    other = "{1_N} 回合",
}

-- Advisor Counsel popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "無建議."

-- Function-key help entries
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "開啟文明百科"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "開啟經濟概況"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "開啟軍事概況"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "開啟外交概況"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "開啟社會政策畫面"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "開啟科技樹"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "開啟回合與事件紀錄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "開啟勝利進度畫面"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "開啟人口統計資料畫面"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "開啟顧問建議"

-- CityView hub
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "已連接"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} 位失業市民"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "食物 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "生產 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "金幣 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "科學 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "信仰 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "旅遊 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "文化 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "句號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "下一個城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "逗號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "上一個城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "無下一個城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "無上一個城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "數據"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "奇蹟"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "偉人進度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "工人重點"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "失業: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "尚未建造奇蹟."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "無偉人生成中."

-- Batch 06 (lines 1248-1450): 100 keys
-- City view: great person, focus, unemployed, buildings, specialists, great works,
-- production queue, hex map, ranged strike, gift, rename/raze, spying/foreign.

-- Great person generation entry
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur} / {3_Max}"

-- Focus sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, 已選取"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "避免成長, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "重設格位指派"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} 已選取"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "格位指派已重設"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "無閒置市民"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "已指派"

-- Buildings sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "建築"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "無建築物."

-- Specialists sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "專家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_GP_POINTS"] = {
    other = "+{1_N} 偉人點數",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "無專家席位."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] = "{1_Building} {2_Specialist} 席位 {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "已填入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "已填入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "未填入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] = "已填入, 工人已從格位撤回"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] = "未填入, 工人已指派至格位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "無法新增專家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "手動專家管理, {1_State}"

-- Great works sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "巨作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "藝術"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "文學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "音樂"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} 席位 {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} 席位 {3_N}, 空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} 主題性獎勵加 {2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "無巨作席位."

-- Production queue sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "生產序列"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "生產序列為空."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    other = "序列 1, {1_Name}, {2_Turns} 回合, {3_Percent} 百分比. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "序列 1, {1_Name}, {2_Percent} 百分比. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "序列 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    other = "序列 {1_N}, {2_Name}, {3_Turns} 回合. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "序列 {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "序列 {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "[ICON_PRODUCTION] 剩餘生產力: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "{1_Name} 操作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "向上移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "向下移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "從序列移除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "返回"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "已上移"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "已下移"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "已移除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "序列模式, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "選擇生產項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "以金幣或信仰值購買"

-- Hex map sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "領土管理"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "領土管理"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "已耕作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "已固定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "已阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "未耕作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "可購買, {1_Gold} 金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "可購買, {1_Gold} 金幣, 金幣不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "金幣不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "在城市格位間移動游標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "耕作或購買格位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "返回城市中樞"

-- Ranged strike sub-handler
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "遠程攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "遠程攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "無法攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "已開火"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] =
    "{1_Name}, {2_MyStr} 對 {3_TheirStr}, 對方受到 {4_Dmg} 傷害"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_PREVIEW"] = "讀取目標資訊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_COMMIT"] = "對當前目標開火"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_CANCEL"] = "取消, 不開火"

-- Gift unit / gift improvement target picker
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "贈送單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "贈送改良設施"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "改良設施已贈送"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_PREVIEW"] = "讀取目標資訊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_COMMIT"] = "對當前目標執行贈送"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_CANCEL"] = "取消, 不贈送"

-- Rename / Raze hub items
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "重命名城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "焚毀城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "停止焚毀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "焚毀已停止"

-- Foreign / spy-screen refusals
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "間諜活動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] = "間諜活動期間無法切換城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "您無法為非己方城市發動遠程攻擊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "您無法更改非己方城市的生產項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "您無法為非己方城市耕作格位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] = "您無法為非己方城市購買格位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] = "您無法在非己方城市出售建築物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] = "您無法更改非己方城市的工作重心"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "您無法管理非己方城市的專家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "您無法查看非己方城市的巨作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "您無法在非己方城市指派市民"

-- Batch 07 (lines 1452-1671): 100 keys
-- City view hex, reveal announce, foreign unit watch, turn lifecycle, empire status

-- ===== City view hex =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "可購買"

-- ===== Reveal announce =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_COUNT"] = {
    other = "{1_Num} 格已探索",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "已探索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "敵方: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "單位: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "城市: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "資源: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "已隱藏"

-- ===== Foreign unit watch =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] = "新敵方單位進入視野: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] = "敵方單位已離開視野: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] = "新中立單位進入視野: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] = "中立單位已離開視野: {1_List}"

-- ===== Foreign clear watch =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "其他人已奪取 "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = " 和 "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    other = "{1_Num} 個可見的蠻族營地",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    other = "{1_Num} 個可見的遠古遺跡",
}

-- ===== Gone on revisit =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "已消失"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    other = "{1_Num} 個蠻族營地",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    other = "{1_Num} 個遠古遺跡",
}

-- ===== Turn lifecycle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "回合結束"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "已取消結束回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control 加 Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] = "結束回合, 或通報並開啟第一個阻礙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Control 加 Shift 加 Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "略過單位需要命令提示以強制結束回合, 其他阻礙仍會通報並開啟"

-- ===== Empire status readouts =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "超出單位上限 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    other = "{1_Turns} 回合完成 {2_Tech}, 科學 +{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech} 已完成, 科學 +{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "無研究項目, 科學 +{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "科學已關閉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    other = "+{1_Rate} 金幣, 合計 {2_Total}, {3_Used}/{4_Avail} 條商路",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    other = "-{1_Rate} 金幣, 合計 {2_Total}, {3_Used}/{4_Avail} 條商路",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "缺少 {1_Resource}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"

-- ===== Section labels =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "黃金時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "影響力"

-- ===== Empire status payloads =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "+{1_Excess} 快樂"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "不快樂 -{1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "極度不快樂 -{1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    other = "黃金時代剩餘 {1_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "{1_Cur}/{2_Threshold} 進入黃金時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "快樂已關閉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "+{1_Rate} 信仰, 合計 {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "宗教已關閉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "下一座萬神殿需 {1_Num} 信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "無可用的萬神殿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "下一位大預言家需 {1_Num} 信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "每座城市科技成本 +{1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "每座城市政策成本 +{1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    other = "+{1_Rate} 文化, {2_Turns} 回合完成政策",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "+{1_Rate} 文化, 已無剩餘政策"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] = "無文化產出, {1_Cur}/{2_Cost} 完成下一項政策"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "政策已關閉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "+{1_Rate} 旅遊業績"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    other = "+{1_Rate} 旅遊業績, 對 {2_Count} 個文明具優勢",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    other = "+{1_Rate} 旅遊業績, 對 {3_Total} 個文明中的 {2_Count} 個具優勢",
}

-- ===== Help overlay: empire status keys =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "回合與日期, 超出單位上限時一併顯示, 以及戰略資源短缺狀況"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "當前研究項目及每回合科學產出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "每回合金幣, 合計及商路數量"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "帝國快樂, 提供快樂的奢侈品數量及黃金時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "每回合信仰及合計"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] = "每回合文化及距下一項政策的時間"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] = "每回合旅遊業績及具優勢的文明數量"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Shift 加 R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "各來源科學明細"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Shift 加 G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "各來源金幣收入及支出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Shift 加 H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "快樂來源, 不快樂來源及黃金時代效果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Shift 加 F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "各來源信仰明細及大預言家或萬神殿時機"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Shift 加 P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "各來源文化明細"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Shift 加 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "偉大著作, 空置席位及具優勢的文明數量"

-- ===== Task list readout =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Shift 加 T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "讀取當前情境任務"

-- ===== Game menu =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "操作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "模組"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "未啟用任何模組."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, 版本 {2_Version}"

-- ===== Civilopedia =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "分類"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "內容"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "此條目無可用文章."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "此條目無內容."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "未選取任何條目. 切換至分類標籤以選取."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "簡介"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "已到達歷史記錄起始."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "已到達歷史記錄末端."

-- Batch 08 (lines 1672-1854): 100 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "歷史記錄中的上一篇或下一篇文章"
-- AdvisorInfoPopup (BUTTONPOPUP_ADVISOR_INFO). Concept drill-down reachable
-- from the tutorial advisor question buttons and from any related concept
-- link within the popup itself. The boundary announcements reuse
-- TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY / _NO_NEXT_HISTORY -- same
-- "Start of history." / "End of history." text, no reason to duplicate.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] = "歷史記錄中的上一個或下一個概念"
-- SaveMenu. Two-tab picker/reader over the in-game Save screen. Picker lists
-- existing saves (or cloud slots); reader shows header fields and exposes
-- the Overwrite / Save-to-slot / Delete actions behind pushed Yes/No subs.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "存檔"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "存檔詳情"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "此清單中沒有存檔."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "存檔名稱"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] = "存檔名稱為空或包含無效字元."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "覆寫此存檔"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "儲存至此位置"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "覆寫 {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] = "覆寫 Steam Cloud 位置 {1_Num}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "刪除 {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "存檔已刪除."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Steam Cloud 位置 {1_Num}: 空"
-- Spoken replacements for [ICON_*] markup. Registered into TextFilter by
-- CivVAccess_Icons.lua; the filter substitutes the bracket token inline
-- with the spoken text. Singular / plural wording is deliberately relaxed
-- ("turns", "whales") because screen-reader users tolerate minor grammar
-- over awkward branching, and Civ's text uses these icons in both counts.
-- Mirrored in the FrontEnd strings file (each Context has its own
-- sandboxed CivVAccess_Strings table). Keep the two in sync when adding
-- or renaming icon keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "食物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "科學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "科學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "旅遊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "偉人"
-- Dedup-only alias. Engine source: the singular pairings in base text such
-- as TXT_KEY_RELIGION_GREAT_PERSON_FOCUS ("Great Person Focus") and "a
-- Great Person of your choice" boilerplate. Match the singular form the
-- engine uses next to the icon. See the "_ALT keys" note in the orientation
-- block above for translator guidance.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = ""
-- Per-specialist title aliases. Engine source: TXT_KEY_SPECIALIST_<X>_TITLE
-- in CIV5GameTextInfos_Objects.xml -- ARTIST, ENGINEER, MERCHANT, SCIENTIST.
-- en_US prints "Great <X> Points:"; locales whose phrasings share no common
-- prefix (e.g. fr_FR "Points d'artistes illustres :", "Points de savants
-- illustres :") need one entry per specialist. Match the literal engine
-- phrase in the target locale; do NOT translate the en_US value.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "大藝術家點數"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "大工程師點數"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "大商業家點數"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "大科學家點數"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "偉大著作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "戰鬥力"
-- Dedup-only alias. Engine source: TXT_KEY_PRODUCTION_STRENGTH (en_US
-- "[ICON_STRENGTH] Strength: N", fr_FR "[ICON_STRENGTH] Puissance : N").
-- Match the bare strength word the engine prints in the target locale.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "遠程戰鬥力"
-- Dedup-only alias. Engine source: TXT_KEY_PRODUCTION_RANGED_STRENGTH
-- (en_US "[ICON_RANGE_STRENGTH] Ranged Strength: N"). In some locales the
-- engine's emission already matches the icon's primary spoken form
-- ("ranged combat strength") word-for-word -- e.g. fr_FR "Puissance de
-- combat a distance : N". The alias is dormant in those locales and ""
-- is fine; the matcher skips empty aliases.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "幸福"
-- Dedup-only alias. Engine source: base text pairs the positive-happy glyph
-- with "Happy" as well as "Happiness" (TXT_KEY_LOCAL_CITY_HAPPY_TEXT and
-- the per-yield TXT_KEY_PRODUCTION_BUILDING_HAPPINESS line which uses
-- "Happiness"). Match the shorter form ("happy" / locale equivalent).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "幸福度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "不滿"
-- Dedup-only alias. Same pattern: base text pairs the unhappy glyph with
-- "unhappy" alongside "unhappiness". Match the shorter form.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "不滿度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "左"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "右"
-- ChooseProduction popup. Wrapped BaseMenu with two tabs (Produce, Purchase)
-- and five groups per tab (Units, Buildings, Wonders, Other, Current queue).
-- Append-mode commit speaks post-commit queue length so the player hears the
-- fill state as they chain picks; queue-full closes the popup.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "選擇生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "購買"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "目前佇列"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "已加入, 佇列第 {1_Slot} 位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "佇列已滿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "佇列為空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "佇列有 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    other = "{1_Num} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} 金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} 信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "建造 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "已購買 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    other = "{1_Name}, {2_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"
-- ChooseTech popup. Flat BaseMenu list of researchable techs with the current
-- research pinned on top in free / stealing modes. Activate commits via
-- Network.SendResearch; F6 and the bottom-of-list item both escalate to the
-- full tree through OpenTechTree (defined in TechPopup.lua, same Context).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "選擇研究"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "免費科技, 剩餘 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "從 {1_Civ} 竊取"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "每回合 {1_N} 科學"
-- Plural is driven by {2_Turns}.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    other = "正在研究 {1_Name}, {2_Turns} 回合",
}
-- Per-tech state words on the picker. FREE fires only in free-tech mode
-- (Liberty finisher, Great Scientist bulb, etc.) for techs that count as
-- gainable for free. CURRENT marks the active research line. QUEUED marks
-- a slot in the planned queue; {1_Slot} is the 1-based queue position
-- counted after the current research (slot 1 = first queued, not the
-- active one).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "免費"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "正在研究"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "已排程第 {1_Slot} 位"
-- Plural driven by {1_Num} (turn count).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    other = "{1_Num} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "開啟科技樹"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "正在研究 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "已獲得 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "已竊取 {1_Name}"
-- Tech Tree screen. TabbedShell with a hand-rolled DAG cursor tab and a
-- BaseMenu read-only queue tab. Landing speech on every arrow move
-- composes name, status, queue slot (if queued), turns, and unlocks
-- prose. Mode preamble reuses CHOOSETECH_PREAMBLE_* keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "科技樹"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "全部科技"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "佇列"
-- Per-tech state words. AVAILABLE: pickable now. UNAVAILABLE: prereqs not
-- met by the player's current research state. LOCKED: in the queue but
-- waiting on an earlier-queued tech to finish (a sequential block, not a
-- prerequisite block). RESEARCHED: already complete.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "已研究"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "可用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "先決條件未達成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "已鎖定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "目前沒有研究, 佇列為空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "目前"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "已排程 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "已研究過"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "不可作為免費科技"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "無法竊取此項"
-- Tree-tab arrow help is mode-aware. The screen swaps which of the two
-- DESC strings is shown based on the active mode (grid vs tree). KEY is
-- the same chord set in both modes; the description is what changes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Up/Down/Left/Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Up/Down 在時代欄中移動, Left/Right 跨列移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Right 前往相依科技, Left 前往先決科技, Up/Down 在同層科技間移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] = "切換格狀或樹狀導覽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "格狀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "樹狀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "研究目前焦點科技"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Shift 加 Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "將焦點科技加入佇列"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Control 加 I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "開啟文明百科條目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "字母 / 數字 / 空格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "輸入以按名稱或解鎖內容搜尋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "關閉科技樹"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"

-- Batch 09 (lines 1855-2008): 100 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "關閉科技樹"

-- Social Policies popup
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "社會政策"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "政策"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "意識形態"
-- Branch-level status words (top tier of the policy tree). OPENED: at
-- least one policy in the branch is adopted. FINISHED: every policy in
-- the branch is adopted. ADOPTABLE: branch is closed but the player has
-- the culture to open it. LOCKED_ERA / LOCKED_RELIGION / LOCKED: cannot
-- open yet because of era requirement, missing religion, or unmet
-- prerequisite. BLOCKED: a mutually-exclusive branch was opened first
-- (the policy UI shows this as a red-X, separate from the "needs prereq"
-- lock the tech tree spells "locked").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "已開啟"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "已完成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "可採用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "已鎖定, 需要 {1_Era}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] = "已鎖定, 需要已創立的宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "已鎖定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "已阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{1_Num}/{2_Total} 已採用"
-- Individual-policy status words (one tier down, applies to each policy
-- inside an opened branch). OPENER / FINISHER mark the two automatic
-- bookend policies. ADOPTED: chosen and active. ADOPTABLE: selectable now
-- with the player's current culture. BLOCKED: prerequisite policy in the
-- same branch hasn't been adopted yet (a within-branch sequencing block,
-- distinct from STATUS_BLOCKED above which is a cross-branch ideology
-- conflict). LOCKED: the parent branch isn't opened.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] = "開啟者, 開啟分支時免費獲得"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] = "終結者, 完成分支時獲得獎勵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "已採用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "可採用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "已阻擋"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "已鎖定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "已鎖定, 需要 {1_Prereqs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "開啟 {1_Branch}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] = "{1_Cur}/{2_Cost} 文化值, 每回合 {3_Per}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    other = "{1_Turns} 回合後可獲得下一個政策",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    other = "{1_Num} 個免費政策可用",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    other = "{1_Num} 個免費信條可用",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "尚未採用意識形態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "此遊戲已停用意識形態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "第1級信條"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "第2級信條"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "第3級信條"
-- Ideology tenet-slot rows. {1_Num} is the slot index within its level.
-- _FILLED carries the picked tenet's name and short effect; _NAME_ONLY
-- omits the effect (used in compact contexts). The four EMPTY_* variants
-- describe why the slot can't be picked yet: AVAILABLE means it can be
-- picked now; REQ_SLOT means another slot in the same level must be
-- filled first ({2_Req} is that slot's index); REQ_CROSS means the
-- prerequisite is in a different level ({2_Level} is the ideology tier
-- 1 / 2 / 3, {3_Req} is the slot index within that tier); CULTURE means
-- the player does not have enough culture for any tenet right now.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "欄位 {1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "欄位 {1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "欄位 {1_Num}, 空, 可用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] = "欄位 {1_Num}, 空, 需要欄位 {2_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "欄位 {1_Num}, 空, 需要第 {2_Level} 級欄位 {3_Req}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] = "欄位 {1_Num}, 空, 文化值不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "切換意識形態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "切換意識形態, 不可用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "不滿度 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "選擇信條"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "沒有可用信條"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "採用 {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "開啟分支 {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "採用 {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "切換意識形態?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "已採用 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "已開啟 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "已採用信條 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "已要求切換意識形態"
-- Number-entry primitive (BaseMenuNumberEntry). Digits / Backspace / Enter /
-- Esc bindings with their own help strings because the digit surface isn't
-- covered by the menu's standard A-Z search entry.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "數字鍵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "輸入數字"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "刪除最後一位數字"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "確認數量"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "輸入 {1_Label}, 最多 {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "空"
-- Diplomacy trade screen. Labels for the flat top-level menu (Your / Their
-- Offer), drawer tab names, quantity-bearing Offering lines, and the Other
-- Players group for third-party peace / war actions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "交易"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "與 {1_Name} 交易"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "您方提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "對方提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "提案中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "可用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, 人口 {2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "投票承諾"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "與 {1_Name} 議和"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "對 {1_Name} 宣戰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "議和"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "宣戰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "其他玩家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "無可用項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "桌上無任何提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "您有 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "對方有 {1_Num}"
-- DiploCurrentDeals review labels. Each deal renders as one Text leaf
-- whose label inlines the full contents; these are the side prefixes the
-- builder concatenates around the per-item descriptions. Colon-then-list
-- form, distinct from LABEL_VALUE's space form and DIPLO_GOLD_AMOUNT's
-- comma form; the colon reads as a brief pause before the list of items.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "我方給予: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "對方給予: {1_List}"
-- Past-tense variants for the Historical Deals group, where the deal has
-- already concluded.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "我方已給予: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "對方已給予: {1_List}"
-- DiploCurrentDeals tab title and the Historical Deals group label.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "協議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "歷史協議"
-- Diplomatic Overview (Relations / Global tabs). Per-civ composed lines,
-- trade / third-party fragment prefixes, section group headers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{1_Leader}, {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "得分 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "金幣 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "每回合金幣 {1_N}"
-- Per-resource entry inside strategic / luxury / nearby lists.
-- {1_Name} is the resource's localized name, {2_N} is the count owned.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "戰略: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "奢侈: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "附近: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "額外: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "政策: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "奇蹟: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "主要文明"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "城邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "尚未遇到任何文明."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "無協議."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "對方提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "等待回應"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "隊伍 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "正在研究 {1_Tech}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "{1_N} 影響力"

-- Batch 10 (lines 2009-2196): 77 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "{1_N} 每回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "固定於 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N} 文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N} 快樂"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N} 信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "+{1_N} 食物 (首都)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "+{1_N} 食物 (其他城市)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N} 科學"
-- Plural driven by {1_N} (turns until next gift unit arrives).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    other = "{1_N} 回合後贈予下一支單位",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "輸出 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "開放邊界"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "可被欺壓"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "{1_Civ} 的同盟"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "您的關係"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "外交關係"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "政策"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "奇蹟"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "分數"
-- Minor civ columns. _RELATIONSHIP carries the bonuses currently flowing
-- from a Friends / Allies CS (culture, food, science, faith, happiness,
-- spawn estimate). _TRAIT_PERSONALITY carries trait then personality as a
-- thematic pair. Influence column carries value + per-turn + anchor +
-- threshold-gap to the next state. Allied-with carries the current ally
-- (or "nobody") plus displacement value. Quests and Nearby resources
-- carry their respective lists.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "關係"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "特性與個性"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "影響力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "同盟對象"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "委託"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "附近資源"
-- Empty-cell labels. "none" for absent items in a list-shaped cell;
-- "nobody" for the Allied-with column where the absence is an actor, not
-- an item.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "無"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "無同盟"
-- Gold cell: gold on hand plus per-turn rate. {2_GPT} carries its sign so
-- the same template covers gain and loss.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, 每回合 {2_GPT}"
-- Influence threshold gap fragments, appended after the value / per-turn /
-- anchor block in the Influence cell. _TO_FRIENDS shows when below friends
-- threshold; _TO_ALLIES shows when between thresholds.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "需 {1_N} 成為友邦"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "需 {1_N} 成為同盟"
-- Allied-with cell variants. _ALLY_IS_YOU when we're the ally (no
-- displacement number to compute). _ALLY_AND_DISPLACE when someone else is
-- allied: civ short name plus the influence we'd need to gain over the
-- current ally.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "您"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, 需 {2_N} 取代"
-- Unmet-ally variant: a civ we haven't met holds the alliance. The
-- displacement number is still meaningful (we know our own influence
-- and can read the engine's record of theirs) but we can't name them,
-- so the cell distinguishes from "nobody" (the genuine no-ally case)
-- with a generic civ word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] = "未曾謀面的文明, 需 {1_N} 取代"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "產出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "商路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "無詳細資料"
-- Storage / threshold tail appended to the food and culture yield rows.
-- Bare numerator-of-denominator since the row's headline already names
-- the resource ("food 5, 12 of 22, grows in 4 turns").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{1_Cur}/{2_Threshold}"
-- Culture's next-tile countdown. Borrowed by both the culture yield's
-- extras tail (CityStats) and the hex-cursor culture readout
-- (CitySpeech.borderGrowthToken); shared so the wording stays
-- consistent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    other = "{1_Num} 回合後獲得下一格",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "領土擴張停滯"
-- Happiness one-liner: local-only contribution from buildings here, plus
-- the per-city slice of the empire's unhappiness pool (population /
-- occupied / specialists already folded in by the engine).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] =
    "本地快樂 {1_Local}, 不快樂 {2_Unhappiness}"
-- Religion group: one row per religion present, holy-city flag inlined
-- when applicable so the user hears it together with that religion's
-- numbers rather than as a separate line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    other = "{1_Religion}, {2_Followers} 位信徒, {3_Pressure} 宗教壓力",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    other = "{1_Religion}, 聖城, {2_Followers} 位信徒, {3_Pressure} 宗教壓力",
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
    other = "{1_Num} 格",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "您獲得 {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "對方獲得 {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} 獲得 {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{1_Num} {2_Religion} 宗教壓力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "無可用目的地."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "無可用駐紮城市."
-- Trade Route Overview (TRO) screen. Distinct from the per-pick
-- ChooseInternationalTradeRoutePopup above: TRO is the standalone Ctrl+T
-- screen that surveys every trade route currently active in the game.
-- Three tabs: Yours (your active routes), Available (routes you could
-- start but haven't), and With You (routes other civs run to your
-- cities). Domain words distinguish caravan (land) from cargo ship (sea).
-- ROUTE_HEADER carries five placeholders: domain word, source city, source
-- civ, destination city, destination civ.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Control 加 T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "開啟貿易總覽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "您的商路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "可用商路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "與您建立的商路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "商隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "貨船"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} 往 {3_To}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "城邦 {1_City}"
-- Plural driven by {1_Num} (turns until the route arrives at its
-- destination and resolves).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    other = "剩餘 {1_Num} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "無商路."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "無來源詳細資料."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "排序: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "排序"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "收到金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "收到科學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "收到食物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "收到生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "往目的地的宗教壓力"
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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "描述領袖"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "此領袖暫無描述."

-- ===== Leader-portrait prose (translated separately) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] = "喬治·華盛頓, 美利堅合眾國首任總統, 立於一間鑲板室內, 兩側各有厚重紅色窗簾向外拉開, 雙手自然垂放於髖部. 他身穿十八世紀末美國紳士的黑色平民禮服: 一件長及大腿的深色雙排扣長禮服, 前胸兩排銅扣, 內着配套背心, 領口飾以白色褶皺胸巾 (jabot), 手腕處露出白色袖口. 他的頭髮以白粉梳飾, 從高額向後梳起, 兩耳上方向內鬈曲, 腦後收為以黑色絲帶繫紮的辮子. 他左側, 一個大型地球儀安放在旋木台座之上; 台座旁的小桌上, 一本精裝書籍翻開陳放, 藍色絲帶書籤從書頁間垂出. 他右側, 一座淡色石制壁爐架上擺放着一座高大的黃銅燭台, 蠟燭尚未點燃, 其上懸掛着一幅鑲於鍍金畫框內的風景畫. 他身後分開的窗簾之間, 一根凹槽柱聳立於日光天空前, 隱約可見一片起伏的翠綠原野. 這一構圖取法吉爾伯特·斯圖爾特1796年的蘭斯當肖像 (Lansdowne portrait), 原作中的禮儀劍和公文在此以地球儀和書本取而代之."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] = "哈倫·拉希德, 信士的長官, 阿拔斯王朝第五任哈里發, 坐在一座宮廷花園中, 時值上午. 他身後是一個鋪石庭院, 通向由尖頂拱門構成的淡石色廊柱, 遠處薄霧中隱現一座穹頂. 他留著鬍鬚, 黑髮, 坐於一張低矮的雕花木椅上, 椅扶手末端飾有圓形頂飾, 頭上纏著一頂高大的番紅花色纏頭布, 頂部有一頂軟帽突起. 一條同色寬腰帶從右肩斜纏過胸前, 束於左臀, 帶端以金線編織並飾有金流蘇, 腰帶之下是一件垂至腳踝的白色寬鬆長袍, 袍擺繡有同款金色錦緞帶. 右手舉至肩旁, 以拇指和食指夾著一支qalam, 即阿拉伯蘆葦筆; 左手平放於膝上. 腳踩一張圓形地毯, 織有藍色, 米色和鐵鏽色的勳章圖案, 地毯旁的石板地面上放著兩本精裝古籍, 最上面一本是深紅色封面, 以金線壓花裝飾. 椅子兩側各有種在藍色釉面碗中的蘇鐵和蕨類植物, 右側立著一個高大的赤陶甕, 廊柱下深色樹籬封閉了中景."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] = "亞述巴尼拔, 世界之王, 亞述之王, 立於宮殿的列柱廳堂之中, 右手持一塊淡色石板豎於胸前, 手指扣於石板頂緣. 他肩膀寬闊, 雙臂裸露, 皮膚在燈光下透出溫暖色調. 鬍鬚長而方整, 梳成緊密平行的卷曲垂至胸前, 黑髮以同樣的鬈絲落至肩頭. 一頂低矮的金色冠帶環繞眉心, 帶面飾以玫瑰花紋. 他身著亞述宮廷的長及腳踝的王室披肩: 深藍色內袍遍布金色玫瑰花紋, 外披一件厚重的深洋紅色披風, 其流蘇邊緣斜貫胸前, 越過左肩向背後垂落, 下擺以金線和紅色刺繡鑲邊. 寬闊的金色腕帶扣住雙腕, 一條同款臂環圈繞右上臂. 他身後聳起一個拱形壁龕, 以細柱框邊, 柱頭飾以淡色渦卷; 壁龕兩側各置於基台之上的, 是拉馬蘇 (lamassu) 的深色蓄鬍石像 - 即守護亞述宮殿城門的人面翼牛. 後牆上, 淺浮雕以側面橫列呈現馬匹造型, 取法其尼尼微宮殿的狩獵與戰車浮雕板. 地面鋪設淡色磚瓦, 廳堂兩側漸沒於陰影之中."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] = "瑪麗亞·特蕾莎, 承蒙天主恩典的羅馬帝國皇太后, 匈牙利, 波希米亞, 達爾馬提亞, 克羅地亞, 斯拉沃尼亞, 加利西亞, 洛多梅里亞女王, 奧地利大公女(等等諸銜), 站在一座帶拱廊的石砌涼廊上, 這是一條有頂長廊, 其高大圓拱一側朝向積雪山峰的高山景觀, 另一側是鋪著光滑地板的廊柱走道上鋪有一條紅色地毯. 內牆拱門之間掛著紅色錦緞面板, 左側射入的陽光在石面上投下長影. 她以四分之三側面站立, 雙臂輕輕交疊於腰前, 頭略微轉向一旁. 髮色淡金, 向後梳高以宮廷風格別起. 長袍為淡藍灰色絲綢; 胸衣緊繫收腰, 正面有一塊stomacher, 即硬挺的裝飾面板, 以銀色刺繡和小珠寶製成. 寬大的箍裙撐在crinaline架上展開, 同款銀色刺繡沿外裙前開縫垂直延伸. 袖子至肘部以白色蕾絲點綴的短泡袖收束. 一方薄透蕾絲手帕折疊搭肩並塞入領口. 她未戴冠冕, 無可見珠寶. 身後拱廊以淡石色向遠處延伸, 旋制廊柱扶手欄杆延伸至遠方, 阿爾卑斯山明亮, 天空晴朗."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] = "蒙特祖馬·索科約津, 墨西加人的大演說者(Huey Tlatoani), 站在一座巨大火盆前, 火焰在他與觀者之間升騰, 周圍大廳僅靠這火焰照亮. 他袒露上身, 體型壯碩, 在火光中膚色深沉, 臉半隱於陰影中. 頭冠為quetzalapanecayotl, 由長而閃耀的綠蜥鳥尾羽組成的冠飾, 呈綠藍二色, 以金製額帶紮束. 金製耳軸穿耳而過, 頸上環繞一圈翡翠金項圈, 腕上扣著寬大的翡翠金護腕, 每條上臂各有金帶環繞. 身後紅色磚石牆上嵌著一塊巨大的圓形雕刻石盤, 同心帶狀象形文字環繞中央面孔, 仿照阿茲特克太陽石. 兩側牆壁雕刻著排排程式化骷髏, 即tzompantli, 阿茲特克神廟展示的骷髏架; 每組骷髏架上方聳立著大型阿茲特克神明面具浮雕, 每面牆頂的石甕中燃著高高的火焰. 整座大廳在火光的紅金色中通體發亮."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] = "尼布甲尼撒二世, 巴比倫國王, 坐在一間綠光映照的石砌大廳中一把巨大的石制王座上, 身後的牆壁漸漸隱沒在陰影之中. 他頭戴 agu (巴比倫王冠), 新巴比倫王朝國王所戴的高圓帽, 帽緣繫以金帶. 他的鬍鬚修長, 深色, 梳理成層疊排列的緊密管狀捲曲. 他的長袍深紅色, 短袖, 遍布均勻排列的金色玫瑰花結紋樣, 腰間繫著一條寬大的刺繡腰帶; 袍裙垂直落至赤裸的雙腳, 衣擺鑲有淡色流蘇帶. 兩腕各套著沉重的金制袖箍. 他的雙手掌心向下放在王座寬大的扶手上, 扶手前端雕成獅頭托座, 齜牙的獅口朝外, 與他的膝蓋齊平; 王座底部他腳邊另有一對較小的對應獅頭向外突出. 王座兩側各立著一根高大的石柱, 雕有盤繞的蛇形紋, 柱頂各承托一個寬而淺的缽, 缽中升起一道蒼綠色火焰, 這是廳中唯一的光源, 將病態的綠色投射在石牆, 他的面孔和長袍之上."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] = "佩德羅二世, 巴西皇帝, 坐在一間深色護牆板書房裡一張寬大的木制書桌前, 畫面的構圖如同觀者站在書桌對面望向他. 他是一位年長的男性, 寬肩厚實, 蓄著一把白色大鬍鬚, 垂落至衣領以下甚遠, 頭頂稀疏的白髮從高闊的前額向後梳理. 他身穿深色長禮服外套, 裡面是深色背心和高領白色襯衫, 喉間繫著深色領巾. 左胸別著南十字星帝國勳章的寶石勛星, 他是該勳章的大團長. 雙手平放在書桌上; 他面前散落著文件和一個小墨水瓶, 一根羽毛筆直立在右手邊的圓形筆座中. 書桌左側放著一盞點亮的油燈, 配有高聳的透明玻璃燈罩和拋光黃銅底座, 燈焰是畫中最亮的點, 也是照亮他臉部和雙手的主要光源. 他身後和兩側, 牆壁從地板到天花板排列著深陷在陰影中的書架. 左肩處一扇高窗透過斜置的木制百葉窗映出一片深藍色夜空, 棕櫚葉在窗外剪影而立. 畫面最左側, 一扇較小的菱形鑲嵌玻璃窗捕捉著暮色天空的暖色調, 窗下一個架子上放著一個小型壁爐架鐘. 地板覆蓋著帶有低調紅色和金色圖案的地毯."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] = "狄奧多拉, 羅馬人的奧古斯塔 (Augusta), 斜倚在開放式柱廊露台上一張低矮的金色錦緞長榻上, 一臂搭在長枕上, 另一臂放在膝上. 她的冠冕是一頂寶石 stemma (拜占庭皇冠), 拜占庭帝國頭飾的圓頂帽, 帽帶上鑲嵌著一排素面寶石. 前額正中突顯著一顆綠色寶石, 其上的冠頂向上升起, 以金工夾持著第二顆綠色寶石. 她的頭髮在冠後收攏, 長長垂落在右肩. Pendilia (寶冠垂飾), 即 stemma 的珍珠垂墜, 懸在她臉頰兩側; 一圈 maniakis (帝國項飾) 環繞她的頸部, 這是東方帝國鑲寶石的項圈. 她的長袍層疊穿著: 一件收身的深紅色胸衣, 正中以金色圓形勛章扣合; 膝上鋪著一條金綠色絲綢裙, 繡有渦卷紋; 其下是一條深藍綠色長底裙, 衣擺以窄金帶收邊. 金色袖箍環繞她的手腕. 她身後右側垂下一幅厚重的紅色幔帳, 向一側拉開, 露出帳後的景象. 露台地面鋪著暖色調石板, 邊緣圍著雕刻欄桿, 欄桿上擺放著插滿紅色花朵的花缸, 兩根蒼白的大理石柱框出遠景. 穿越一片寬闊的山谷, 聖索菲亞大教堂巍然矗立, 寬大的中央穹頂兩側伴著較低的半圓形穹頂, 陽光下牆面呈現出黃褐色, 晴空下低矮的山丘在其後漸漸消融為藍色."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] = "狄多, 迦太基的創建女王, 在夜間立於宮殿露台之上. 她身後, 天空深藍並點綴繁星, 遠處海岬在矮欄上方的天際線隱約可見. 一張弧形石凳立於她背後, 凳端雕有卷草飾帶, 淡色石柱在其後方聳立. 露台兩側, 兩株種植於淡色石盆中的大灌木生有深色葉片與細小紅色花朵: 石榴, 其拉丁文名 punicum 標誌着這是迦太基之樹. 她膚色白皙, 深色秀髮中分垂落過肩, 眉心戴有細金冠帶. 她的長袍是近乎白色的淡色希頓 (chiton), 即以別針固定於肩頭並束腰的希臘式束袍, 及地裙擺遍布細緻織紋. 短開衩袖以小胸針間隔固定於上臂, 一條寬闊的深藍腰帶環繞腰間, 向下長長垂掛於裙前. 她頸間橫陳一塊以金框鑲嵌深色寶石的寬胸飾, 一個纖細金手鐲圈繞手腕. 她雙手垂放於身側, 四周石材在夜色燈光下透出冷意."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] = "布狄卡, 愛西尼族女王, 立於山頂要塞的草坡之上. 左側是一道石牆, 牆頂架有削尖木樁組成的木柵欄, 圓形茅屋的錐形茅草屋頂隱約可見; 右側, 一列綠色山丘在沉重灰色天空下延伸而去. 她的頭髮短而鮮艷, 呈銅紅色, 一條淡色布條系於腦後, 向下垂落於肩後. 一側顴骨下方有一個深藍色小印記, 是古代不列顛人用作身體彩繪的菘藍. 一枚凱爾特扭繩金項圈 (torc), 金質扭製而成, 硬挺地環繞其頸. 她身穿無袖及膝的藍綠格紋粗布束腰短袍, 以帶圓形扣環的皮帶束腰. 皮製護腕以帶子繫於手腕上, 一個配套護甲束於上臂, 小腿在低矮皮靴上方裸露. 左手持一把直刃雙鋒的拉泰訥式短劍 (La Tene), 刀身向尖端逐漸收窄, 劍柄小而素樸; 右手握住一把豎立的長矛柄, 矛尾插入草地. 她左側停著一輛輕型雙輪戰車, 單輪輻車輪鑲有鐵圈, 車床中斜插着一束長矛."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] = "武則天, 唐朝皇帝, 立於昏暗廳堂正中, 兩側各有厚重的紅色簾幕向外拉開. 她身後, 一排溫暖的金色燈籠懸於黑暗之中, 其後的深色牆面嵌有鏤刻格扇板. 她的烏黑秀髮高高盤聚於頭頂, 前方以步搖 (buyao) 固定, 步搖為金珠飾件. 她身着儒裙 (ruqun), 多層疊穿. 淡金色絲質內衫交叉於胸前, 上方是一塊繡有圓形徽章的硬挺金色胸板; 一條鮮艷的紅色腰帶高束胸下, 向下垂落至地的長裙. 外披一件深紅色金色圓形圖案絲質外袍, 寬闊衣袖垂過雙手, 曳地的裙擺在腳周鋪展開來. 她雙手捧持一個小型金制器皿置於腰前, 微微上舉如呈獻之姿. 她膚色瑩白, 神情沉靜, 目光平和. 紅色簾幕, 紅色袍服與金色燈籠在廳堂的幽暗中將畫面染得溫暖."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] = "哈拉爾一世, 綽號'藍牙'的貢姆松, 丹麥與挪威之王, 站在一艘長船的露天甲板中部. 他體型寬大壯碩, 鬍鬚呈紅金色, 分叉成兩條編成辮子的尾巴垂至衣領以下, 八字鬍長而下垂. 頭部裸露, 頭髮盤成髮髻. 肩上披著一件長毛棕紅色皮草斗篷. 斗篷下穿一件灰綠色束腰外衣, 育克部分顏色更深, 衣擺和袖口飾有北歐交錯紋的皮革壓花帶. 一條寬厚的皮革腰帶橫跨腰間, 以沉重的方形扣環固定, 另有一條皮帶斜跨胸前; 雙手均放在腹前的腰帶上. 頭盔置於腳旁甲板上, 為深鐵色圓頂, 有加固的眉帶和鼻橋, 兩側外展為厚棕紅色毛皮的圓形護耳. 左側船首柱高高彎曲向內呈螺旋形木雕, 刻成龍頭模樣. 右肩後方索具從桅杆垂下, 其上一面風帆掛著紅白相間的寬條紋. 沿船舷固定著一面圓形木盾正面朝外, 中央有鐵製臍盾. 頭頂天空開闊湛藍, 點綴著高層雲帶."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] = "拉美西斯二世, 兩地法老, 端坐於數級矮台階頂端的寶座上, 兩側各是一座高大藍色彩繪廊柱廳堂. 他面容年輕, 面部剃淨, 皮膚深銅色, 眼眶以深色眼線粉描繪. 頭飾為nemes, 即金藍條紋頭巾, 緊貼太陽穴收攏, 再以褶疊長耳垂落胸前. 額頭升起uraeus, 即標示王權的人立眼鏡蛇. 肩部和胸前橫覆wesekh, 即以金色和青金石藍珠串層疊排成的寬領圈. 身穿shendyt, 即以長條白亞麻布製成的法老式褶裥短裙, 腰間以一條金藍寬腰帶束緊, 正面垂落一塊硬挺的圖案飾板. 雙腳穿涼鞋踏在台階頂級. 左手持高杖靠在肩上, 右手擱在寶座扶手上. 兩側廊柱以藍, 金, 紅色分排彩繪, 柱頭形如紙莎草束, 刻有成排象形文字和立像人物. 寶座前方兩側各立著兩尊大型金像, 分別為保護神伊西斯與奈芙蒂絲, 她們翅膀展開向前伸展, 羽毛呈現為長條鍍金葉片. 兩側棕櫚葉斜伸入畫, 腳下黃色石階刻著一排排小三角紋飾. 整座廳堂沐浴在暖金色光輝中, 廊柱與項圈的藍色是其中唯一的冷色調."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] = "伊莉莎白一世, 承蒙上帝恩典的英格蘭, 法蘭西及愛爾蘭女王, 信仰的守護者, 端坐於一張高大的雕刻王座之上, 兩側各有一座石基燭台, 蠟燭尚未點燃. 她身後升起御用頂篷, 厚重的紅色天鵝絨被金色流蘇繩向兩側拉起層層皺褶, 寢殿深處的幽暗僅隱約可見. 她的頭髮高高盤起, 呈紅金色緊密鬈曲, 以一頂嵌有寶石的小王冠固定; 衣領是都鐸晚期宮廷特有的硬挺開放式拉夫領. 她的長袍以黑線繡於金色錦緞之上, 胸衣裁剪貼身並綴滿寶石, 袖子於肩部膨起並向下收窄至蕾絲袖口, 裙擺在撐裙架 (farthingale) 上寬闊展開. 長串珍珠項鍊橫越胸前並垂掛腰間, 是她那個時代象徵貞潔的飾物. 她蒼白的雙手靜置於王座扶手之上."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] = "海爾·塞拉西一世, 衣索比亞皇帝, 上帝的選民, 猶大支派征服之獅, 站在宮殿的一間長形接見廳中, 頭頂是淡色方格藻井天花板, 右側是高大的窗戶, 窗間懸掛著水晶吊燈. 他身形清瘦挺拔, 蓄著深色鬍鬚, 頭髮剪得很短. 他身穿深色軍式束腰外衣, 釦子扣至喉間, 配素色深色長褲, 腰間繫著寬大的黑色皮腰帶. 從右肩斜跨至左臀, 繫著一條寬闊的翠綠色波紋綢綬帶, 即所羅門印章勳章的綬帶. 左胸高處密集排列著四排小型綬帶, 是他在位期間累積的戰役與榮譽勛飾. 其下垂掛著兩枚大型高級帝國勳章的胸星, 八角形, 以金與琺瑯精工製成. 他的左手垂放在身側, 右手持著一副手套. 他左側立著帝國王座: 一把高背椅, 以淡奶油色和藍色軟墊包覆, 椅背頂端雕成弧形冠狀並覆以刺繡布幔, 置於一塊鋪滿大廳的紅色花紋地毯之上. 他身後牆壁沿線排列著淡色軟墊椅, 向廳內深處延伸."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] = "拿破崙, 法蘭西皇帝, 騎跨於一匹淡灰色馬上, 置身暮色中一片枯草原野, 身後是紅褐色天空與光禿樹木. 他身穿深藍色外套配厚重金色肩章, 白色背心, 白色馬褲, 和高筒黑色騎靴. 雙角帽橫向佩戴, 兩個帽角朝向肩膀, 這是他刻意與麾下軍官有所區別的慣常佩戴方式. 馬的轡頭為紅色皮革鑲金鉚釘, 其下馬鞍布飾以紅金色邊. 整體構圖令人聯想到雅克-路易·大衛的《拿破崙越過阿爾卑斯山》, 然而靜止無動: 沒有人立的戰馬, 沒有指向遠方的手, 只有一個人在暮色山野中獨自佇立."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] = "俾斯麥, 普魯士首相兼德意志帝國第一任宰相, 站立於一座高大的國事廳中, 身後鉛框窗格透入白日光, 每塊窗格由細長窗欞分割成小方格. 各窗戶旁懸垂深緋紅帷幔, 束紮成厚重褶層, 內裡為更深的紅色. 地板拋光如鏡, 映出窗光長條淡帶. 其左側一張小邊几上放著一盞白色球形燈. 他身形高大寬肩, 頭頂禿亮, 兩側及後方留有一圈銀灰色短髮, 蓄著濃密的白色八字鬚, 鬚梢向外捲展. 外套為深石板色深色雙排扣軍禮服, 胸前兩行平行金鈕扣緊扣, 立領鑲金邊, 肩部壓著厚重的金色流蘇肩章, 流蘇垂至上臂. 領口正下方掛著深色綬帶上一枚小型淡色十字勳章, 即Pour le Merite, 普魯士最高軍事功勳勳章. 他以四分之三角度面對觀者, 挺立靜止, 目光越過觀者肩頭遠望."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] = "亞歷山大大帝, 馬其頓國王, 希臘人的霸主, 騎在他健壯的黑色種馬布西發拉斯 (Bucephalus) 背上, 在一片綠色高原草地上勒住韁繩, 兩側是灰色山脈, 右側聳立著一座白雪覆頂的山峰. 他年輕, 面部光滑無鬚, 棕色頭髮從中間分開, 前額的髮絲向上梳起形成 anastole (額前髮浪), 這是他肖像畫的標誌性特徵. 他身穿 linothorax (亞麻護甲), 一種由多層亞麻布與皮革製成的希臘式鎧甲, 外覆鎏金甲片, 肩部軛帶以短繩繫在胸前. 胸甲正中有一塊方形鎏金飾板, 上面浮雕著 gorgoneion (戈耳工頭像) - 梅杜莎的頭部. 雙肩和腰帶以下懸垂著 pteruges (護翼皮條), 一排排硬化皮革條保護上臂與大腿, 每條皮革飾以紅邊, 末端嵌著金色鉚釘. 他雙臂裸露, 右腕戴著寬大的金臂環; 他未戴頭盔, 也未攜帶任何可見武器. 馬具是以紅色裝飾的深色皮革, 額帶和頰片鑲嵌著鉚釘, 他以左手橫握過馬頸的單根韁繩. 馬鞍之下, 一張帶有斑紋的豹皮鋪蓋在馬的側腹, 爪子仍完整附著."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] = "阿提拉, 匈人之王, 坐在高台上一把高背木制王座之上, 四周大廳籠罩在深紅與金色的光芒中. 他輕鬆地向後倚靠, 一腿交疊於另一腿之上, 一把出鞘的長劍橫放在膝上; 一隻手按在劍刃上, 另一隻手持著酒杯. 他身穿紅色長袖束腰外衣, 鑲有金邊, 外衣之下是深藍色長褲, 紮入高筒軟皮靴中, 靴口飾有皮草. 頭上戴著一頂深色毛皮圓錐帽, 帽上繫有金帶. 他蓄著鬍鬚和長長的鬍鬚, 臉部在右側光線的半照之下. 王座的扶手末端雕有獅頭, 椅背上搭著厚重的毛皮. 他身後, 一面紅色幔帳牆壁兩側掛著大小漸次排列的圓形青銅圓盤, 火光在其間閃動. 高台右側, 一個高大的鐵制燭台燃著一根細蠟燭. 再往裡, 地板上一個大銅碗中插滿了直立的有鞘長劍的劍柄. 更遠處, 一個打開的木箱在花紋地毯上灑滿了金幣."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] = "帕查庫提印加·尤潘基 (Pachacuti Inca Yupanqui), 塔萬廷蘇尤 (Tahuantinsuyu) 的薩帕印加 (Sapa Inca), 端坐於馬丘比丘 (Machu Picchu) 上方露台的高大石制王座之上, 王座雕刻着以金紅兩色點綴的連鎖幾何紋飾. 他右上方固定於石柱的, 是一枚巨大的金色太陽圓盤, 中央呈現一張程式化的人面, 外圍放射狀光芒向外擴散. 左側裸露的山峰陡然聳立, 下方階梯式農業台地上排布着低矮的茅草建築. 他頭戴馬斯卡帕伊查 (mascapaycha), 即橫垂額前以象徵印加王權的紅色羊毛流蘇, 以亞烏托 (llauto) 多彩頭帶束固, 頂部插有一束挺立的紅色和深色羽毛. 他的頭髮烏黑, 垂及肩頭. 頸間掛有一枚厚重的金色圓盤胸飾. 他的束腰短袍是無袖及膝的服裝, 以醒目的黑白棋盤格圖案為主, 胸前飾有紅金色過肩橫帶. 膝蓋以下, 雙腿以紅色流蘇繩纏繞束紮. 右手持一根高大權杖, 頂端為金色鳥形飾件, 杖身懸掛層層疊疊的紅色流蘇."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] = "莫罕達斯·卡拉姆昌德·甘地, 聖雄, 印度獨立運動的領袖, 站在印度海岸邊, 四周是枯黃的草地, 岩石嶙峋的海岬, 以及蒼白的海面. 他身形消瘦, 頭頂禿光, 戴著眼鏡, 蓄著修剪整齊的灰色短鬍鬚. 他穿著晚年的慣常裝束: 一件圍繫腰間的白色 dhoti (圍腰布), 一條披肩搭在一側肩膀上並繞過另一側手臂下方, 胸部裸露. 布料未經染色且為手工紡織, 這是對英國布料的蓄意拒絕, 後來成為他的運動的象徵. 這一場景令人聯想到他在爭取獨立的鬥爭期間向海邊長途跋涉, 在次大陸的邊緣孑然而立的形象."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] = "加查·馬達, 爪哇滿者伯夷帝國的瑪哈帕蒂 (首相), 站在一片水田的邊緣, 水面在低矮的綠色田埂之間如鏡般明亮. 他身後, 茂密的熱帶雨林攀爬上籠罩在淡薄霧氣中的山坡, 從霧中升起一座細長階梯形輪廓的 candi (印度神廟塔), 紅磚砌成, 層疊的屋頂消融入雲端. 他寬肩裸胸, 深色頭髮束成髮髻, 下巴蓄著一小撮鬍鬚. 兩臂的二頭肌和手腕各以金箍環扣. 一條寬腰帶高繫腰間, 以一塊大型扇貝形鎏金飾板扣合, 紋樣為滿者伯夷花卉風格. 腰帶以下, 一條紅色紗籠纏繞並在前方打結, 褶疊厚重地垂落在黃色內襯布上, 內襯布在衣擺處露出. 他右臀處, 以一根穿過腰帶的繩索懸掛著一把有鞘的 kris (馬來短劍), 深色木質劍鞘漸漸收窄至一個尖端, 劍柄以傾斜的角度向前突出."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] = "海華沙, 易洛魁聯盟的創立者, 站在陽光照耀的林中空地上, 一塊大型灰色岩石在他肩旁聳立, 身後是細細的山毛櫸與白樺樹幹, 漸漸沒入綠色灌叢之中. 他袒露上身, 體型精瘦, 在斑駁光影中皮膚呈現溫暖的棕色. 髮型為scalplock式, 頭兩側剃短, 頭頂從前至後留有一條狹窄的深色髮脊, 後方固定兩根直立羽毛. 深色顏料帶環繞每條上臂. 喉間佩戴一條緊貼的白色貝珠項圈, 即wampum, 一條單肩帶從右肩斜至左臀, 支撐著一個箭囊, 羽尾端高出肩膀. 腰間掛著一塊淡棕色鹿皮遮羞布, 前片長垂至大腿中部. 有流蘇的鹿皮護腿套從腳踝包至膝蓋, 膝下紮緊, 大腿處敞開由遮羞布覆蓋. 他赤腳站在空地的夯實土地上, 雙臂垂於兩側, 林中光線從右側灑落."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] = "織田信長, 織田氏大名, 三位偉大統一者中的第一位, 站立於一片起伏綠野之中, 四周高草叢生, 白石散落, 蔚藍山脈在積雲明天下向地平線退遠. 他以月代風格剃去頭頂, 前額與頭頂俱剃以使頭盔戴得涼爽穩固, 餘下髮絲束於腦後. 他蓄著短鬚和下巴短髭. 鎧甲為當世具足, 即戰國時代現代型胸甲: 漆塗鐵板以絲繩橫向排列縛結, 胸甲與裙甲以深藍與朱紅交替色帶束紮. 肩甲以同樣縛結鐵板懸垂於兩臂之上. 外披無袖棕褐色陣羽織, 前幅敞開露出其下縛結的胸甲. 寬幅紅色腰帶打結繫腰, 一把刀刃朝上插入其中, 右側另懸一把刀, 右手握著刀柄. 兩者合稱大小刀, 即每位武士所佩的長短雙刀. 從右肩後方升起, 橫跨背部的是一桿種子島銃的長形深色槍托與細長槍管, 那是信長以大規模採用而留名史冊的火繩槍. 他獨立於曠野之中, 四周只有草地, 白石與遠山."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] = "李祹, 朝鮮王朝第四代君王, 端坐於寶座大殿中一座高起的木製台座中央, 雙手捧著一本攤開的書置於膝上. 他身穿袞龍袍(gonryongpo), 即朝鮮君王所著的紅色絲綢龍袍, 胸口和肩部繡有金色四爪龍紋圓章, 鑲有金色卷草紋邊飾. 腰間繫著一條寬大的嵌玉腰帶. 頭戴翼善冠(ikseongwan), 一種硬挺的黑色紗帽, 後部有兩片小小的上翹翼狀裝飾如折疊葉片. 他面目清秀, 僅留整齊的深色八字鬚和下巴短鬚. 身後豎立著日月五峰圖(Irworobongdo), 一面設於每位朝鮮君王寶座後方的折屏, 象徵君王為太陽, 王后為月亮: 左上方白色月輪, 右上方紅色日輪, 深綠色鋸齒山峰, 以及沿下部延伸的深紅色松樹. 寶座本身漆成紅色, 側板雕有老虎紋章. 兩側紅漆欄杆和柱子框住台座; 紙燈籠懸掛於大殿邊緣, 散發黃光; 一段短小的石階向觀者方向延伸而下."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] = "巴加爾二世, B'aakal的K'uhul Ajaw, 帕倫克聖主, 正午時分站立於首都上方一座石灰岩宮殿的露台, 叢林之中逐級聳立的金字塔神廟超越其後, 屋頂梳飾因雕刻與風化而呈淡玫瑰色. 背後肩頭展開一架巨大背架, 木框上展開長長的quetzal尾羽, 以綠色, 藍色和深紅色帶狀排列, 架設於一塊刻有彩繪象形文字的長方形石板之上. 頭飾高大多層, 頂端更冠以quetzal羽毛. 長髮深黑垂落至肩. 胸前橫覆一排寬幅雕刻玉牌項圈, 中央懸掛一塊方形玉胸飾, 耳垂貫穿玉製大耳環. 串珠腰帶束攏腰部一條以打結布料和羽毛製成的腰裙, 兩側垂掛及膝的長羽流蘇, 腳踝上高繫涼鞋帶. 左手握著K'awiil的人偶權杖, 是一根頂部刻有閃電神小雕頭的高杖, 馬雅統治者以此神像作為王權象徵. 左側露台邊緣立著一個寬大石製火盆, 盆沿環繞著燒盡的祭品殘存. 城市遠景沒入薄霧, 座座金字塔逐級降向遠處的河流平原."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] = "成吉思汗, 蒙古大汗, 騎乘黑馬立於遼闊草原之上, 畫面呈現腰部以上, 四分之三側身面向觀者. 他的頭盔高聳呈錐形, 頂部以尖飾收束, 深色眉帶與護頰板框托着細薄的髭鬚與頦下一小撮鬍鬚. 他的盔甲是鉚釘固定的蒙古騎兵甲冑, 胸前以一枚大型圓形青銅飾件為主, 上面壓印盤旋圖案; 寬闊護肩蓋於雙肩, 釘飾臂帶纏繞上臂. 一件深色披風自肩頭垂落, 垂掛馬鞍後方處的內裡呈低調紫色. 馬匹的鞍具是素面皮革, 簡單的轡頭僅有眉帶與向前匯聚的韁繩. 他身後, 低矮的翠綠山丘在蒼白陰雲天空下起伏延展; 山坡中段矗立着一片蒙古包 (gers) 的營地, 即蒙古人的圓形白色氈帳, 周圍草地上點綴着淡色的散養牲口."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] = "艾哈邁德·曼蘇爾, 摩洛哥薩阿德王朝蘇丹, 站在撒哈拉營地的邊緣, 頭頂是深藍色的天空. 細細的新月與散落的星辰懸掛在地平線上低矮的黑色山脈之上. 他蓄著鬍鬚, 在燈光映照下膚色溫暖, 目光平靜地朝向觀者. 他身著馬格里布的層疊服飾: 一件長及腳踝的白色 djellaba (北非連帽長袍). 外面披著一件 selham (王侯貴族穿著的精細羊毛披風), 風帽垂落於肩胛骨之間. 頭上纏繞著白色頭巾. 胸前掛著一塊乳白與金色相間的矩形刺繡飾板, 以伊斯蘭幾何交錯紋樣裝飾. 一條寬大的紅白豎條紋腰帶繞腰兩圈, 在前方打結, 末端掖入腰間. 他身後左側, 一頂深色條紋布料製成的大圓形商隊帳篷由內透出光芒, 掀起的帳簾將溫暖的橙色光線灑在沙地上; 兩頭駱駝臥在旁邊的沙地上. 更遠處燃著一盞小燈, 一叢棗椰樹映襯著遠山升起."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] = "威廉一世, 奧蘭治親王, 荷蘭獨立之父, 立於一間鋪磚廳室之中, 左側一扇高大的鑲鉛玻璃窗透入光線, 菱形小玻璃格由向側拉開的厚重紅色垂幔框托. 地面鋪設黑白大理石方格. 他身後遠牆掛有一幅鑲鍍金畫框的低地風景油畫, 描繪沉重天空下一條河流蜿蜒穿越平坦綠野通向遠處城鎮. 他右側, 一張木凳上放置一個地球儀, 黃銅子午儀圈接住窗光閃爍. 他左側, 一張鋪有紅色桌布的書桌上擺放着一本翻開的皮裝書和散頁紙張, 書桌後方立有一張包覆藍色布料的高背椅. 整個室內令人聯想起維梅爾筆下地理學家與天文學家的書房, 儘管威廉所處的年代略早於那一風格. 他是一位中年蓄鬚男子, 深色頭髮在小扁帽下剪得極短, 髭鬚和分叉鬍鬚修剪整齊, 一道寬闊的白色打褶拉夫領突出於頸間. 肩上垂有一件長黑色披風, 右側向後撥開以解放雙臂. 他的緊身上衣 (doublet) 是暗金色提花絲織, 貼身裁剪, 前胸以單排鈕扣扣合. 他的馬褲是分布式燈籠褲 (paned trunk hose), 由長條垂直的紅白布條交替排列縫製於較豐厚的襯裡之上, 至大腿中段收束. 素色深色長統襪包覆小腿以下, 與棋盤格地面上的低矮皮鞋相接. 右手持一根官職指揮棒, 舉至胸口高度; 左手靠近髖部, 披風垂落之下隱約可見劍柄."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] = "蘇萊曼一世, 人稱'宏偉者', 又號Kanuni'立法者', 鄂圖曼蘇丹, 站在托普卡匹宮一座有肋拱頂的大廳中, 四周是藍白伊茲尼克磁磚貼面的尖頂拱門. 日光從看不見的窗戶射入, 灑落在他身後蒼白石柱上. 他留著鬍鬚, 眼色深沉, 八字鬚和鬍鬚整齊修剪, 映出薄薄的嘴唇. 頭上戴著他聞名遐邇的高大圓形kavuk纏頭布, 以大量白布纏繞於錐形骨架上, 高出眉線甚遠. 頂端聳立著sorguç, 一支標誌蘇丹地位的綠色羽毛. 內袍之上穿著一件黃色絲綢長卡夫坦袍, 織有淡色藤蔓和玫瑰花紋, 前襟開至腰部. 袍子全長飾有一寬帶柔軟灰色毛皮, 此乃kapanice的標誌, 即最高榮譽袍服. 一條深色腰帶在腰間橫跨卡夫坦. 右手直立貼胸握著一本深色皮裝訂的書冊. 另一隻手垂於身側. 身後大廳在磁磚拱門之間漸漸沒入陰影."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] = "大流士一世, 偉大的阿契美尼德帝國萬王之王, 站立於一座大廳頂端的數級矮台階上, 一道光柱從上方投落其身. 他寬肩濃鬚, 鬍鬚修長方切且緊密捲曲. 頭上戴著kidaris, 即波斯諸王的高聳雉堞形冠冕, 是環繞方形雉堞的金色圓筒形冠. 長袍為藏紅花黃色長衫, 垂落至腳, 胸口, 袖口及下擺均飾以紅金色刺繡寬邊. 紅色腰帶束腰. 沉重的金臂環箍住雙臂上臂. 兩側台座各立著一尊巨大的lamassu有翼牛, 牛身及折疊翅膀皆覆蓋金色, 是波斯波利斯萬國之門的守護神像, 此處呈現人首版本簡化為純牛形. 後壁浮雕刻著一列身著長袍, 頭戴軟帽的人物行列, 取材自Apadana台階的納貢者浮雕. 台座和台階的石材呈淡藍綠色, 角落處點綴金色凸飾."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] = "卡齊米日三世, 偉大的波蘭國王, 皮亞斯特王朝最後一位君主, 站立於一座石砌城門樓口, 鐵製壁式燭台火焰將紅金色暖光投落在石砌牆面. 他寬肩濃鬚, 鬍鬚深色修剪整齊, 目光平視. 冠冕是鑲嵌紅石的金色拱形頭環, 諸拱在頂端匯合成寶石頂飾. 肩上披著寬幅白色貂皮披肩, 毛皮綴有黑色尾斑點綴. 其下是一件深緋紅長袍外套, 胸前一列小金釦扣緊, 腰間束著寬幅鎏金腰帶. 一手持金色權杖豎立胸前, 腰側懸掛Szczerbiec, 即皮亞斯特王室之劍. 他兩側各有粗重鐵鏈從上方黑暗中沿城門樓內壁垂下. 身後, 廳室後方拱門之中一塊紅色板面繪著加冕的波蘭白鷹展翅. 老鷹以深色剪影呈現於紅底之上而非慣常的銀色. 石塊厚重密合, 光線聚落在國王身上, 兩側陰暗穹頂急遽沒入黑暗."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] = "卡美哈梅哈一世, 夏威夷群島的統一者, 王國首任Mo'i, 赤腳站在白沙灘上, 身後是一處靜謐海灣的藍綠色淺水, 遠處聳立著深色的叢林山脊. 他身形高大壯碩, 袒露上身, 在熱帶陽光下皮膚深棕. 一肩掛著ahu'ula, 夏威夷ali'i貴族的羽毛斗篷, 深紅色, 幾乎垂至腳踝. 一條同色寬腰帶從左肩橫跨胸前, 黃色邊緣鑲嵌著小紅色幾何方塊. 他的malo(一種繞腰纏布)前方掛著一塊同款紅黃面板. 頭上戴著mahiole, 一種低矮有飾脊的頭盔, 從眉心到後頸有一條窄脊, 以紅色製成, 飾有黃色條紋, 底部有黃色帶. 右手握著一根高大的木矛, 矛頭帶倒鉤; 左臂垂於側旁. 右側沙灘上擱置著兩艘wa'a kaulua, 即玻里尼西亞雙體航海獨木舟, 兩個船體以綁紮橫樑連接. 帆呈三角形, 尖端在桅桿底部, 上沿向外彎成長U形; 帆布色淡且有補丁. 更遠處海灣中還有第三艘獨木舟在錨地漂浮. 左肩後方海岸上立著一棟茅草hale, 即夏威夷的木骨幹草屋頂房屋, 半隱於椰子樹葉蔭之中. 山脊上方天空湛藍, 飄著高層白雲."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] = "瑪麗亞一世, 葡萄牙及阿爾加維女王, 海外葡萄牙領地之君, 站立於辛特拉佩納宮露台上, 是一座重型仿羅馬式拱廊下的淡色石廊. 大西洋在廊柱之外展開. 她的裙裝為深藍色絲綢. 緊身胸衣貼身收腰, 及肘袖口以白色袖邊收尾, 裙身蓬鬆撐於裙撐之上, 大幅褶層垂落石面. 短紅色披風固定於肩部並拖曳其後. 胸前橫披一條寬幅白色紅邊飾帶, 即葡萄牙基督騎士團的綬帶, 由葡萄牙君主以大團長身份佩戴. 飾帶正面縫有一排珠寶裝飾. 深色頭髮盤高, 堆疊於額頭上方, 以一枚aigrette固定, 即插著直立羽毛的黑色小頭飾. 右手垂於身側, 搭在一根細長節杖的柄上, 深色杖身斜倚其藍色裙裝. 右側越過欄杆, 一條狹窄海灣在紅色峭壁之間延伸. 兩艘收起帆布的橫帆Naus帆船錨泊於水道中. 左側聳立著一座黃色圍牆高塔, 頂部冠以鍍金與彩磁帶狀球形圓頂. 黃色雉堞城垛逐級降向她所站立的露台. 天空晴朗, 光線是明亮的大西洋午後, 拱廊將她框於一側海水與另一側皇家建築之間."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] = "奧古斯都·凱撒, 羅馬第一位皇帝, 端坐於兩個青銅獅身人面像頭之間的執政官式座椅上, 那兩個光滑的臉孔朝外. 他面部剃淨, 深色短髮向前梳覆額頭, 是Prima Porta肖像傳統的額前流海. 他身上裹著toga picta, 即羅馬凱旋儀式所穿的紫色禮袍, 覆蓋白色束腰長袍之上, 拉過膝蓋並披上左肩. 束腰長袍的領口鑲金邊. 右手張開擱在其中一個獅身人面像頭上, 左手鬆散地搭在膝蓋上. 身後是一片幽暗的深紅色牆廳, 廳內立著凹槽圓柱, 懸掛紅金色直幅橫額. 後壁上一枚圓形青銅獎章浮雕著獅頭. 淡白的日光從左側射落其臉龐和胸口, 讓大廳遠側沒入陰影; 寶座兩側各有一個鐵架小火盆, 火焰低燃."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] = "凱薩琳二世, 全俄羅斯女皇兼專制君主, 站在沙皇村葉卡捷琳娜宮大廳 - 光明廳之中. 她的身體以四分之三角度朝向觀者, 目光平靜. 她的深色頭髮高高梳起, 梳成十八世紀末歐洲宮廷流行的髮式. 頭頂以一頂小型寶石王冠束緊, 冠尖的形狀如同俄羅斯大帝國皇冠的高聳花形拱頂的縮影. 她的禮服是象牙色絲綢宮廷裝: 收身胸衣正面有一塊金線繡制的中央飾板, 深藍色泡泡半袖, 肩部以白色貂皮帶裝飾. 寬大的裙擺向下展開, 以金線繡著俄羅斯皇家紋章的雙頭鷹, 作為重複紋飾散布其上. 從右肩斜跨至左臀, 繫著一條寬闊的淡藍色波紋綢綬帶, 即聖安德魯第一召使勳章的綬帶. 右側牆面一排高聳的拱形窗戶掛著淡藍色窗帘, 帘子以弧形向兩側收起, 白晝的光線以清晰的光柱斜射在拋光如鏡的黑白大理石地板上. 左側牆面一排鎏金洛可可雕刻, 渦卷紋與葉形紋交織, 裝飾著鑲嵌鏡面的壁板."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] = "波卡特洛, 西北肖肖尼族酋長, 坐於山間盆地邊緣一堆風化紅色巨石之上, 身後是一片平坦的鼠尾草平原, 延伸至地平線上以玫瑰色和淡紫色黃昏天色為背景的低矮台地剪影. 他肩膀寬闊, 烏黑長髮中分垂至胸前, 腦後固定一根挺立的鷹羽. 第二根深色羽毛從背後箭袋中升起, 探出肩後. 一把短木弓與箭袋並排斜挎, 弓的上肢突出於右肩之上. 右手持一根長矛豎立於岩石上, 矛柄以獸皮纏繞, 靠近矛頭處垂有一束深色毛簇. 上身穿一件毛皮背心, 一條以鞣皮製成的寬帶斜橫其上, 帶面以排列整齊的串珠工藝裝飾, 從右肩延伸至左髖, 下端懸掛一個短刀鞘. 上臂以層疊的銀色臂環纏繞. 腰部以下穿着深色流蘇皮革護腿垂至腳踝, 中間束有纏腰布. 左手手掌朝上擱在大腿上; 姿態靜止, 重心穩落於岩石之上. 光線低斜而溫暖, 照亮岩石的紅色和矛刃的邊緣, 而他身後的遠方是大盆地的鼠尾草地帶, 即落基山脈與內華達山脈之間的肖肖尼族故土."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] = "蘭甘亨大帝, 素可泰王國之王, 立於陽光普照的宮廷花園之中. 熱帶森林的翠綠霧靄, 以及遠處泰國佛教塔式建築 - 棄地 (chedis) 的淡色輪廓, 在他身後的薄霧中升起. 他身形清瘦, 袒露上身, 膚色褐暖, 臉龐微微轉向左側, 嘴角帶着淡淡的笑意. 他的王冠高聳, 分層而尖銳, 頂端收為細長尖塔: 即泰國國王的錐形冠飾差達 (chada). 一條寬闊的金色胸頸飾橫陳肩胸之間, 以捶打浮雕的卷草紋飾製成, 中央嵌有一顆紅寶石; 較細的金帶扣夾雙側上臂. 一條白色絲質腰帶纏繞打結於腰間, 扭轉的兩端垂落大腿. 腰帶之下, 他身着深紅色金紋纏腰布, 下擺可見較深的內層布料. 他右側, 在一方散落粉紅蓮花和寬闊荷葉的靜謐水池邊緣, 立着一尊小型石雕: 神態安詳的佛陀頭像, 眼簾低垂, 安置於蓮苞形台座之上. 一條淡色沙徑從他左側蜿蜒而去, 穿過紅花灌木叢的兩側堤岸, 通向薄霧籠罩中的都城塔樓."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] = "穆罕默德一世, 桑海的阿斯基亞大帝, 站在日落時分的岩石峭壁上, 長刀架於肩頭, 身後是一座燃燒中的城市. 他膚色深沉, 留著短鬚, 雙眼直視觀者. 頭上纏著tagelmust, 一種淡米色的薩赫勒式纏頭布, 高高盤繞並束於一側. 肩上垂著一件深紅色長袍boubou, 寬袖, 是西非貴族的袍服, 前襟與胸口繡有金線與深色線交織的密集圖案帶. 袍下一條淡色腰帶繞腰紮結, 兩端鬆垂於臀側, 下方是與袍同色的深紅色長褲. 他右手握劍柄, 讓刀身斜靠於肩上; 刀身修長, 刀背平直, 刀尖微微彎曲. 右側地勢向下延伸為平原, 紅橙色天空下有一座黑色山丘剪影映於低日之前. 左側一座城市正在燃燒: 土磚城牆, 一座高聳的方形宣禮塔上密密排列著突出的木製toron, 棕櫚木樑從牆灰中斜伸而出. 火焰攀上塔身, 蔓延至塔下街道; 更小的火點散布於城市與他所站峭壁之間的平原上."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] = "伊莎貝拉一世, 卡斯提爾與萊昂女王, 阿拉貢王后, 站立於格拉納達阿爾罕布拉宮一座廊柱式廊廡中, 拱廊開向一座修剪整齊的綠籬與盆栽造型樹花園, 遠處山巒消融於霧靄. 身後一對對纖細廊柱頂著雕刻柱頭, 升入葉瓣形與扇貝形拱門, 拱門內填滿鏤空花格, 其上的拱肩刻著濃密的幾何與植物石膏雕飾, 色調為淡金與沙色. 她身形纖小, 膚色蒼白, 雙手在腰間交疊. 頭部以宮廷卡斯提爾風格遮蓋: 白色頭巾貼緊收攏於下頜和頸部, 白色面紗覆於頭頂, 再上方是一頂鑲有紅色與綠色寶石的小型封閉式金冠. 肩上披著一件長紅色外套, 以金色作內裡和邊飾, 前方敞開. 其下裙裝為奶白色錦緞, 織有深色重複圖案, 合身緊束腰部, 裙身中央有一塊金邊飾帶. 胸口外套分開處別著一顆紅色寶石. 光線是午後黃昏的低角度暖光, 映照廊廡石膏面與廊廡地面淡色石材."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] = "古斯塔夫二世·阿道夫, 瑞典人, 哥特人與文德人的國王, 北方雄獅, 站在一間鎏金宮殿廳室之中. 他身旁一個深闊的壁爐以劈開的木柴燃燒著, 火焰低沉而明亮. 他身形高大魁梧, 蓄著一把垂至胸口的濃密紅棕色鬍鬚和一撮粗厚上翹的鬍鬚, 頭髮從高聳的前額向後梳理. 他穿著一件燻黑的鋼制胸甲 (cuirass), 邊緣和中央脊線以鎏金帶裝飾, 裡面套著一件由厚實蒼白油皮牛皮製成的 buff coat (牛皮外衣). 甲冑向下延伸為可活動的鋼制腿甲 (tassets), 在黃色內裙上方展開至大腿中部. 一條寬闊的青綠色絲綢腰帶從右肩斜跨至左臀, 在胸甲前方打結後寬鬆地垂落. 手腕處露出精小的蕾絲袖口, 靴子上方的馬褲邊緣也鑲著淡色蕾絲飾邊. 他以重心後傾的姿勢站立, 兩隻戴著手套的手各持一根指揮棒, 棒端點地立於面前的地板上. 他身後壁爐的圍框雕刻並鎏金, 壁爐架以巴洛克式莨苕葉渦卷紋飾帶環繞. 左側, 兩幅鎏金框畫掛在綠色與金色錦緞牆壁上. 近處那幅畫著一名身穿深色鎧甲的鬍鬚男子, 是瑞典早期國王埃里克十四世. 遠處那幅畫著一名身著淡色宮廷禮服的蒼白女子, 是古斯塔夫之妻, 布蘭登堡的瑪麗亞·埃萊奧諾拉. 畫作下方, 一張拋光深色木桌上放著一個盛滿水果的淺口錫制碗, 桌子近端升起一個高大的銅制多枝燭台, 蠟燭尚未點燃. 房間幾乎完全由壁爐照明. 溫暖的橙色光芒落在胸甲, 鎏金灰泥裝飾和他臉部右側, 遠處牆壁則隱沒在陰影之中."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] = "恩里科·丹多洛, 最寧靜威尼斯共和國的總督, 夜間站立於一座運河石橋上, 一隻戴手套的手收攏於胸前. 他年歲已老: 長長的灰白鬍鬚垂落胸口, 鬢角露出灰髮, 臉龐深刻皺紋縱橫. 頭上戴著corno ducale, 即硬挺的總督角形帽, 以鐵鏽紅錦緞製成, 後方如弗里吉亞帽般升起成鈍尖, 此處套在一頂貼合頭型的白色麻布camauro之上, 額頭處露出camauro的邊緣. 肩上披著一件飾有淡色毛皮邊的厚重灰色外套, 前方敞開, 內裡與帽子同為鐵鏽紅色. 其下身穿深紅色錦緞長袍, 腰間束著一條打結的金色絲繩. 橋欄為鍛鐵製成, 欄板填以威尼斯哥德式細長尖拱圖案. 身後運河沒入黑暗, 兩側宮殿建築的窗戶在藍色夜色中透出橙黃暖光. 左側碼頭停泊著一艘狹長的貢多拉, 星空從屋頂上方的雲隙中透出."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] = "沙卡·卡桑贊加科納, 祖魯王, 站在一處王家聚居地的開闊空地上, 雙腳踩穩, 左手持盾, 右手握短矛. 他袒露上身, 膚色深沉, 肌肉發達, 胸背間有細繩串著小珠子交叉橫跨. 頭上纏著umqhele, 一種以豹皮製成的厚圓形頭帶, 象徵王室和高級地位. 頭帶前額處固定著一支直立的白色羽毛束, 羽尖染紅. 腰間掛著豹皮圍裙垂過臀部, 下方長長的淡色毛流蘇在大腿旁搖擺. 同款豹斑皮毛帶纏繞腳踝. 左手持isihlangu, 一面以牛皮製成的高大尖橢圓形戰盾; 盾面呈棕白雜色, 中央一根直木杆從頂到底, 以皮革環固定. 右手低持, 蓄勢待發的是iklwa, 一種短柄刺殺長矛, 矛頭寬大如葉片. 身後弧形排列著一排iqukwane, 即祖魯umuzi聚落的圓頂草編蜂巢形茅舍, 其編織表面在陽光下發亮. 空地兩側立著木柱, 頂端放置長角牛的頭骨, 巨大的弧形牛角仍完好附著, 財富與犧牲就此展示於門前. 地面是乾燥的淡色土地, 遠處隱約可見一座平頂台地, 頭頂天空清澈淡藍, 有細薄雲絲劃過."

-- Batch 11 (lines 2285-2497): 100 keys
-- Economic Overview (EO_*), Victory Progress (VP_*), Demographics (DEMO_*), Culture Overview (CO_*) tabs/headers/rows.

-- group / row text consumed by CivVAccess_EconomicOverviewAccess.lua.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "幸福度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "戰鬥力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "食物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "科學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "金幣"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "信仰"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "被佔領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "被佔領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "無項目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "無生產"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    other = "{1_Turns} 回合: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "每回合 {1_PerTurn}, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "金幣總計, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "收入, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "支出, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "每回合淨值, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "因金幣赤字損失的科學, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "城市, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "外交, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "宗教, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "城市連線, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "單位, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "建築, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "改善, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "外交, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "幸福度總計, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "幸福度來源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "奢侈品, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "奢侈品種類, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "奢侈品加成, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "其他奢侈品加成, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "城市幸福度, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "建築, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "每座城市内建築, 駐軍, 宗教及政策协同效應帶來的幸福度. "
    .. "上限為城市人口."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "奇蹟加成, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "具特殊效果的奇蹟帶來的幸福度: 建築系列协同效應, "
    .. "未調整幸福度或按政策數量給予的加成. 大多數幸福度建築的数值"
    .. "歸屬於上方的建築(每城市), 而非此列."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "全帝國加成, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "商路, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "城邦, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "政策, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "宗教, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "自然奇觀, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "每城市加成, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "來自每座您擁有的城市給予固定幸福度的建築或政策. "
    .. "乘以城市數量."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "世界議會, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "難度等級, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "不滿度總計, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "不滿度來源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    other = "{1_Count} 座城市, {2_Value} 不滿度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    other = "{1_Count} 座被佔領城市, {2_Value} 不滿度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    other = "{1_Count} 名市民, {2_Value} 不滿度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    other = "{1_Count} 名被佔領市民, {2_Value} 不滿度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "公衆意見, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "按城市細分"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "可用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "已使用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "本地"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "進口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "出口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "n/a"
-- Victory Progress (VP_*)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "分數"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "勝利"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "總計"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, 首都已失守"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "統治"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "科技"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "外交"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "隊伍 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    other = "{1_Num} 個推進器",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "駕駛艙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "冬眠艙"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "引擎"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, 阿波羅計畫未建造"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, 阿波羅計畫已建造"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "阿波羅計畫已建造, 無零件"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, 阿波羅計畫已建造, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "阿波羅計畫已建造, {1_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    other = "已研究 {2_Total} 項先決條件中的 {1_Have} 項",
}
-- Demographics (DEMO_*)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, 排名 {2_Rank}, {3_Value}, 最佳 {4_BestCiv} {5_BestVal}, 平均 {6_AvgVal}, 最差 {7_WorstCiv} {8_WorstVal}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "國民生產總值"
-- Culture Overview (CO_*)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "您的文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "交換偉大著作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "文化勝利"

-- Batch 12 (lines 2498-2691): 100 keys
-- Culture Overview (CO_*) and League Overview (LEAGUE_*) sections.

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "玩家影響力"

-- Tab 1 (Your Culture).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] = "歷史古蹟: {1_Visible} 可見, {2_Hidden} 隱藏"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    other = "{1_Name}, 文化 {2_Cul}, 旅遊業績 {3_Tou}, 巨作 {4_Filled}/{5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    other = "{1_Name}, 文化 {2_Cul}, 旅遊業績 {3_Tou}, 巨作 {4_Filled}/{5_Total}, 損毀 {6_Pct} 百分比",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "佔領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "尚無巨作建築"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "沒有城市"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "文學席位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "藝術或文物席位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "音樂席位"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled}/{4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled}/{4_Total}, 主題性獎勵加 {5_Bonus}"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, 空"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, 空"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "文學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "藝術"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "文物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "音樂"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class}, 作者 {2_Artist}, {3_OriginCiv}, {4_Era}, 加 {5_Cul} 文化, 加 {6_Tou} 旅遊業績"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "作者 {1_Artist}, {2_OriginCiv}, {3_Era}, 加 {4_Cul} 文化, 加 {5_Tou} 旅遊業績"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, 加 {4_Cul} 文化, 加 {5_Tou} 旅遊業績"

-- GW move flow feedback.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "已標記為移動來源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "已移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "已清除移動來源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] = "席位類型與來源不符"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "無法從空席位移動"

-- Tab 2 (Swap Great Works).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "您的提供品"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "文學"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "藝術"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "文物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "未指定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "清除指定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "其他文明可提供"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "沒有文明提供可交換的巨作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "無可交換巨作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] = "請從其他文明中選擇一件巨作進行交換"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "尚未指定 {1_Type} 以換取 {3_TheirCiv} 的 {2_TheirName}, 請在提供品中指定一件"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "以您的 {1_YourName} 換取 {3_TheirCiv} 的 {2_TheirName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "交換已送出"

-- Tab 3 (Culture Victory).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{1_N}/{2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "無意識形態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "無民意"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "影響中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "旅遊業績"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "意識形態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "民意"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] = "民意不滿"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "超額快樂"

-- Tab 4 (Player Influence).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    other = "預計 {1_N} 回合達到優勢",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "切換視角"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "影響等級"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "影響百分比"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "旅遊業績加成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "對其旅遊業績率"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "趨勢"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "每回合產出 {1_N} 旅遊業績, 按 Enter 切換至此視角"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] = "目前從 {1_Civ} 角度查看"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N} 百分比"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "您的 {1_Yours} 旅遊業績對其 {2_Theirs} 累積文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N} 百分比"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "下降中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "持平"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "上升中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "緩慢上升中"

-- Hotkey help (BaselineHandler / map-mode help list).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control 加 C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "開啟文化總覽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] = "本遊戲已停用文化總覽"

-- League Overview (World Congress / United Nations).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "世界議會"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control 加 L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "開啟世界議會總覽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "狀態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "決議案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "效果"

-- Tab 1 rows.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "重新命名"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(您)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "創建人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    other = "{1_N} 位代表",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "可提出決議案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "外交官駐於其首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "尚未建立世界議會"

-- Tab 2 actions line.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "本會期無可用行動."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    other = "可提出 {1_N} 項決議案.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    other = "剩餘 {1_N} 位代表.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "本會期無決議案."

-- Proposal row composition.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "制定: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "廢除: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "由 {1_Civ} 提出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "由您提出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "擱置中"

-- Vote-state suffix appended to proposal row in Vote mode.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "您的投票: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "棄權"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    other = "{1_N} 贊成",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    other = "{1_N} 反對",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{1_N} 票支持 {2_Civ}"

-- Batch 13 (lines 2696-2865): 79 keys

-- Slot picker (Propose mode).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "空提案欄位 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "欄位 {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "提案欄位 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "待廢除的生效決議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "可提出的決議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "其他決議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] = "我方對此提案的估計票數如下:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] = "支持此案的文明: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] = "反對此案的文明: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control 加 R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "開啟宗教總覽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "您是 {1_Religion} 的創立者"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "{1_Type} 信條"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    other = "{1_Religion}, 聖城 {2_HolyCity}, 由 {3_Founder} 創立, {4_NumCities} 座城市",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Control 加 E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "開啟間諜總覽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "間諜"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "城市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "密謀"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "本局遊戲已停用諜報"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    other = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} 回合",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} 陣亡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", 外交官"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "{1_Rank} {2_Name} 的行動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "文明 {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "城市 {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "人口 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "潛力 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "基礎潛力 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "細項: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "潛力未知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] = "城邦, 可操縱選舉"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] = "城邦, 操縱選舉中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "間諜 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "外交官 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "第 {1_N} 回合"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "來自您的間諜 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "由 {1_Leader} 分享"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "未知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "移動 {1_Rank} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "書籤已新增"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "無書籤"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Control 加數字鍵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] = "在對應位置儲存游標書籤"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Shift 加數字鍵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "跳轉游標至該位置的書籤, 退格鍵返回"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt 加數字鍵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "游標至該位置書籤的距離與方向"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "已啟動標示點 {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "已停用標示點 {1_Slot}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] = "請先在此位置設置書籤"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] = "Control 加 Shift 加數字鍵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "切換該位置書籤的空間音訊標示點"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "所有訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "探索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "戰鬥"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "聊天"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "無訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "左括號與右括號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "記錄中的上一則與下一則訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] = "Control 加左括號與右括號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] = "記錄中最舊與最新的訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] = "Shift 加左括號與右括號"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "切換記錄篩選類別, 跳過空類別"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "反斜線"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] = "開啟多人聊天面板, 單人模式無效"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "聊天僅限多人模式"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "聊天"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "撰寫"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "尚無聊天訊息"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} 傳給隊伍: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} 傳給 {2_To}: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "反斜線或 Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "關閉聊天面板"


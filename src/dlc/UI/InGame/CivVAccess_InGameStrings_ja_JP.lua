-- Mod-authored strings, ja_JP overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- Batch 01: 101 keys

-- Boot and mute state.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_INGAME"] = "Civilization Vアクセシビリティがゲーム内で読み込まれた."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_PAUSED"] = "mod一時停止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MUTE_RESUMED"] = "mod再開"

-- Recommendation.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RECOMMENDATION_PREFIX"] = "推薦: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"] = "都市建設地"

-- Unit status tail tokens and fractions.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_EMBARKED_NAMED"] = "出航中 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION"] = "{1_Cur}/{2_Max} 生命力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION"] = "{1_Cur}/{2_Max} 行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT"] = "{1_Cur}/{2_Max} 航空機"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE"] = "昇進可能"

-- Unit build/queue status.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING"] = {
    other = "{1_What} {2_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED"] = "予約済みの移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO"] = {
    other = "予約済みの移動 {1_Dir}, {2_Turns} ターン",
}

-- Combat strength labels.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH"] = "{1_Num} 近接戦闘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH"] = "{1_Num} 遠距離, 射程 {2_Range}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY"] = "{1_Num} 遠距離"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE"] = "射程 {1_Strike}, 帰還射程 {2_Rebase}"

-- Out-of-resource tail tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS"] = "攻撃回数切れ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES"] = "行動力切れ"

-- HP color tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_COLOR"] = "生命力 {1_Color}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"] = "緑"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"] = "黄"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_RED"] = "赤"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HP_FULL"] = "満タン"

-- Unit level/XP and upgrade.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP"] = "レベル {1_Lvl}, {2_Cur}/{3_Next} 経験値"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_UPGRADE"] = "{1_Name}にアップグレード, {2_Gold} ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL"] = "昇進: {1_List}"

-- Movement result announcements.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MOVED_TO"] = {
    other = "移動済み, 残り {1_Num} 行動力",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT"] = "途中停止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS"] = {
    other = "途中停止, 到着まで {1_Num} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"] = "行動失敗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"] = "次ターンに予約済み"

-- Unit precheck messages.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED"] = "遠距離ユニット, 遠距離攻撃を使用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR"] = "航空ユニット, 遠距離攻撃を使用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK"] = "攻撃不可"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS"] = "攻撃回数切れ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"] = "行動力切れ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"] =
    "航空機はこの方法で移動できない, 帰還を使用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT"] = "隣接していない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY"] = "都市のみ攻撃可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND"] = "海軍ユニットは陸上を攻撃できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET"] = "この目標を攻撃できない"

-- Unit state tail tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"] = "ユニットなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_NO_ACTIONS"] = "行動なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR"] = "宣戦布告する"

-- Menu titles.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_NAME"] = "ユニット行動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_ACTIVATE_MENU_NAME"] = "タイルを起動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_PROMOTIONS"] = "昇進"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_MENU_BUILDS"] = "改善を建設"

-- Target mode tokens.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"] = "目標選択モード"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"] = "予約済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"] = "攻撃を予約できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CANCELED"] = "キャンセル"

-- Combat preview vocabulary.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE"] = "射程外"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, 自分へのダメージ {5_DmgToMe}, 相手へ {6_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE"] = "援護射撃 {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE"] = "捕獲確率 {1_Pct} パーセント"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY"] = "自分のボーナス {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR"] = "相手のボーナス {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS"] = "プラス {1_N} パーセント {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG"] = "マイナス {1_N} パーセント {2_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED"] =
    "{1_Name}, {2_MyStr} vs {3_TheirStr}, {4_Result}, 相手へのダメージ {5_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY"] =
    "都市 {1_Name}, {2_MyStr} vs {3_TheirStr}, 自分へのダメージ {4_DmgToMe}, 相手へ {5_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY"] =
    "都市 {1_Name}, {2_MyStr} vs {3_TheirStr}, 相手へのダメージ {4_DmgToThem}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE"] = "自分へ {1_Dmg}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS"] = {
    other = "{1_N} 迎撃機",
}

-- Move path preview.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_TO"] = "{1_Dir}へ移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN"] = "{1_MP} MP, 残り {2_Left}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN"] = {
    other = "{1_MP} MP, {2_Turns} ターン, 残り {3_Left}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN"] = "このターン, 未探索エリア"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN"] = {
    other = "{1_Turns} ターン, 未探索エリア",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN"] =
    "このターン, {1_Steps}後に未探索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN"] = {
    other = "{1_Turns} ターン, {2_Steps}後に未探索",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN"] = "このターン, {1_Steps}後に攻撃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN"] = {
    other = "{1_Turns} ターン, {2_Steps}後に攻撃",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE"] = "経路なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR"] = "計算不能な距離"

-- Path-blocked messages.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV"] =
    "{1_Civ}の国境に阻止, 最近の到達可能地点 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR"] = "{1_Civ}の国境に阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS"] = "閉じた国境に阻止, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR"] = "閉じた国境に阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR"] = "{1_Adj} {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT"] = "{1_Unit}に阻止, 最近の到達可能地点 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR"] = "{1_Unit}に阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK"] = "ユニットに阻止, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR"] = "ユニットに阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST"] = "経路なし, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH"] = "出航技術なし, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_EMBARK_TECH_NO_DIR"] = "出航技術なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY"] = "天文学が必要, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NEEDS_ASTRONOMY_NO_DIR"] = "天文学が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN"] = "山岳に阻止, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_MOUNTAIN_NO_DIR"] = "山岳に阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER"] = "{1_Wonder}に阻止, 最近の到達可能地点 {2_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_BLOCKED_WONDER_NO_DIR"] = "{1_Wonder}に阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION"] = "水路接続なし, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_NO_WATER_CONNECTION_NO_DIR"] = "水路接続なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND"] =
    "陸上から攻撃できない, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_LAND_NO_DIR"] = "陸上から攻撃できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER"] =
    "水上から攻撃できない, 最近の到達可能地点 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_ATTACK_FROM_WATER_NO_DIR"] = "水上から攻撃できない"

-- Batch 02: 100 keys

-- Travel / path feedback
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND"] = "陸地に移動できない, 最寄りの到達可能な方向 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_CANT_TRAVEL_TO_LAND_NO_DIR"] = "陸地に移動できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK"] = "乗船が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK"] = "上陸が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"] = "ここにターゲットなし"

-- Route preview clauses (plural bundles: other only)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TILES_CLAUSE"] = {
    other = "{1_N} マス",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE"] = {
    other = "{1_N} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE"] = "{1_TilesClause}, {2_TurnsClause}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE"] = {
    other = "{1_Tiles} マス, 作業不要",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD"] = "利用可能なルートなし"

-- Special movement preview: illegal
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL"] = "ここにパラドロップできない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL"] = "ここに空輸できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL"] = "ここに配備変更できない"

-- Rebase
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_DEST"] = {
    other = "{1_Name}, {2_N} マス",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASE_NO_DESTINATIONS"] = "射程内に配備変更先なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_REBASED_TO"] = "{1_Name} に配備変更"

-- Airlift
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_PREAMBLE"] =
    "空輸先の都市を選択. 選択後, ユニットが降りるマスを指定. 都市から1マス以内に限る."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_DEST"] = {
    other = "{1_Name}, {2_N} マス",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_AIRLIFT_NO_DESTINATIONS"] = "空輸先なし"

-- More special movement preview: illegal
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL"] = "ここに乗船できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL"] = "ここに上陸できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL"] = "ここに核攻撃できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_ILLEGAL"] = "ここでユニットを贈れない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_ILLEGAL"] = "ここに改善できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS"] = "迎撃機見当たらず"

-- Special movement preview: legal
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_LEGAL"] = "ここに空輸"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_LEGAL"] = "ここにパラドロップ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_LEGAL"] = "ここに核攻撃, 爆発半径 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_UNIT_LEGAL"] = "{2_Recipient} に {1_Unit} を贈る"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_PREVIEW_GIFT_IMPROVEMENT_LEGAL"] = "{2_Recipient} のために {1_Resource} を改善"

-- Unit help: hotkey labels and descriptions
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE"] = "Period, comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE"] = "次または前のユニットに切り替え"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL"] = "Control + period または comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL"] =
    "行動済みを含む, 次または前のユニットに切り替え"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO"] = "Slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO"] = "選択中ユニットの戦闘情報と昇進情報を読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER"] = "Control + Slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER"] = "選択中ユニットにカーソルを戻す"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB"] = "ユニット行動メニューを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE"] = "Alt + Q, E, A, D, Z, C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE"] =
    "選択中ユニットを1マス移動 (攻撃確認は2回押し)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE_TO"] = "Alt + M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE_TO"] =
    "移動先選択を開く. カーソルキーで狙い, Spaceでプレビュー, Enterで確定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP"] = "Alt + S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP"] = "軍事ユニットを守りを固める, または民間ユニットを休眠"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY"] = "Alt + F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY"] = "警戒, 敵が視界に入るまで休眠"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE"] = "Alt + W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE"] =
    "休眠中または守りを固めているユニットを起こす, または予約済みの移動や自動化をキャンセル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP"] = "Alt + X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP"] = "ユニットのターンをスキップ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL"] = "Alt + H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL"] = "満タンになるまで回復"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED"] = "Alt + R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED"] =
    "遠隔攻撃対象選択を開く. カーソルキーで狙い, Spaceでプレビュー, Enterで確定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE"] = "Alt + P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE"] = "ユニットのいるマスを略奪"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE"] = "Alt + U"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE"] = "ユニットをアップグレード"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME"] = "Alt + N"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME"] = "ユニットの名前を変更"

-- Unit action feedback
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE"] = "{1_Action} 利用不可"

-- Combat announcements
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE"] = "攻撃側 {1_Name} -{2_Dmg} 生命力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE"] = "防御側 {1_Name} -{2_Dmg} 生命力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT"] = "攻撃側 {1_Name} 無傷"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT"] = "防御側 {1_Name} 無傷"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_KILLED"] = "{1_Name} 撃破"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_CAPTURED"] = "{1_Name} 捕獲"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT"] = "不明"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY"] = "{1_Name} に迎撃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION"] = "迎撃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT"] = "空中戦"

-- Air sweep / nuke
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET"] = "迎撃機なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HEADER"] = "{1_Civ} 核攻撃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_TARGET"] = "目標 {1_Target}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_CASUALTIES"] = "被害 {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_UNITS"] = "ユニット {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS"] = "被弾なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY"] = "{1_Name} -{2_Hp} 生命力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_POP_DELTA"] = "-{1_Pop} 人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_KILLED"] = "撃破"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUKE_DESTROYED"] = "破壊"

-- City capture / loss
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US"] = "{1_Name} 占領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LOST"] = "{1_Name} 喪失"

-- Unit status confirmations (tail tokens: no terminal punctuation)
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY"] = "守りを固めている"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP"] = "休眠中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT"] = "警戒中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE"] = "起動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE"] = "自動化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND"] = "解散"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL"] = "回復中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE"] = "略奪済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP"] = "スキップ済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE"] = "アップグレード済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL"] = "キャンセル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START"] = "{1_Build} 開始"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION"] = "{1_Name} に昇進"

-- Misc
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "無効"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_DISABLED"] = "{1_Label}, 無効"

-- Batch 03: 100 keys

-- Direction tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"] = "東"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "北東"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "南東"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "南西"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"] = "西"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "北西"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIRECTION_STEP"] = "{1_Count}{2_Dir}"

-- Map edge / visibility
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_MAP"] = "マップの端"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EDGE_OF_SCOPE"] = "射程の端"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNCLAIMED"] = "未領土"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNEXPLORED"] = "未探索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOG"] = "霧"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TARGET_UNSEEN"] = "見えない"

-- Capital orientation
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AT_CAPITAL"] = "首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CAPITAL"] = "首都なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COORDINATE"] = "{1_X}, {2_Y}"

-- Move cost
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOVES_COST"] = {
    other = "{1_Moves} 行動力",
}

-- River / water / waypoint
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_DIRECTIONS"] = "川 {1_Directions}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RIVER_ALL_SIDES"] = "川 全辺"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FRESH_WATER"] = "淡水"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PLOT_WAYPOINT"] = "経由地点 {1_Index} / {2_Total}"

-- Improvement / terrain features
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PILLAGED_NAMED"] = "{1_Name} 略奪済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HILLS"] = "丘陵"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MOUNTAIN"] = "山岳"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LAKE"] = "湖"

-- HP / build progress
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HP_FORMAT"] = "{1_Num} 生命力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUILD_PROGRESS"] = {
    other = "{1_Build} {2_Turns} ターン",
}

-- Yields / control / defense
CivVAccess_Strings["TXT_KEY_CIVVACCESS_YIELD_COUNT"] = "{1_Count} {2_Yield}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED_BY"] = "{1_City} が支配"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CONTROLLED"] = "支配下"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEFENSE_MOD"] = "{1_Pct} パーセント防御"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL"] = "敵の支配地域内"

-- Cursor help keys and descriptions
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_MOVE"] = "Q, W, E, A, S, D, Z, X, C cluster"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_MOVE"] = "カーソルをマス単位で移動 (Q 北西, E 北東, A 西, D 東, Z 南西, C 南東)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_NUMPAD"] = "テンキー 7, 8, 9, 4, 5, 6, 1, 2, 3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_NUMPAD"] = "Q, W, E, A, S, D, Z, X, C を同じ修飾キーで反映 (テンキーの 5 は S に対応, NumLock オン時)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_UNIT_INFO"] = "S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_UNIT_INFO"] = "現在のマスのユニットを読み上げる"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COORDINATES"] = "Shift + S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COORDINATES"] =
    "カーソルの座標を元の首都基準で読み上げる. 修正オフセット表記 (東に1マス進むとxが+1, 北東に1マス進むとxが+0.5かつyが+1, 南東に1マス進むとxが+0.5かつyが-1)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_JUMP_CAPITAL"] = "Control + S"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_JUMP_CAPITAL"] = "カーソルを自国の首都へジャンプ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ECONOMY"] = "W"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ECONOMY"] = "現在のマスの経済詳細"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_COMBAT"] = "X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_COMBAT"] = "現在のマスの戦闘詳細"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_ID"] = "1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_ID"] = "都市の識別と戦闘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DEV"] = "2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DEV"] = "都市の生産力と成長"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_REL"] = "3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_REL"] = "都市の宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_CITY_DIPLO"] = "4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_CITY_DIPLO"] = "都市の外交メモ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_ACTIVATE"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_ACTIVATE"] =
    "マスのユニットを選択, または都市画面を開く (傀儡は併合ポップアップ, 接触済みの主要文明は外交)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_KEY_PEDIA"] = "Control + I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_HELP_DESC_PEDIA"] =
    "カーソルのマスにある全項目のシビロペディアを開く (ユニット, 世界遺産, 改善, 資源, 地物, 川, 湖, 地形, 丘陵, 山岳, 道路)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"] = "マスの記事"

-- City identity tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_UNMET"] = "未接触"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK"] = "攻撃可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NO_CITY"] = "ここに都市なし"

-- City-state trait tokens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_CULTURED"] = "文化的"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC"] = "軍事的"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MARITIME"] = "海洋的"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE"] = "商業的"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS"] = "宗教的"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"] = "中立"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"] = "友好"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_ALLY"] = "同盟国"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_WAR"] = "戦争"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"] = "恒久戦争"

-- City status
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RAZING"] = {
    other = "焼却中 {1_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RESISTANCE"] = {
    other = "抵抗 {1_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_OCCUPIED"] = "占領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_BLOCKADED"] = "封鎖中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_POPULATION"] = "{1_Num} 人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEFENSE"] = "{1_Num} 防御"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_HP_FRACTION"] = "{1_Cur} / {2_Max} 生命力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GARRISON"] = "守備隊 {1_Name}"

-- City production
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING"] = {
    other = "{1_Name} 生産中 {2_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS"] = "{1_Name} 生産中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING"] = "生産なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS"] = "{1_Cur} / {2_Needed} 生産力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN"] = "{1_Num} 毎ターン"

-- City growth
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_GROWS_IN"] = {
    other = "{1_Turns} ターン後に成長",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STARVING"] = "食料不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING"] = "成長停止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS"] = "{1_Cur} / {2_Threshold} 食料"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN"] = "{1_Num} 毎ターン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING"] = "毎ターン {1_Num} 減少"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_HIDDEN_FOREIGN"] =
    "生産力非公開, スパイ概要を参照"

-- City religion / diplo / spy
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_TRADE_PRESSURE"] = {
    other = "交易路 {1_N} 経由",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_RELIGION_PRESENT"] = "宗教なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_ORIGINALLY_CS"] = "元々 {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW"] = "侵略者プレビュー: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW"] = "解放プレビュー: {1_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_SPY"] = "スパイ {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_DIPLOMAT"] = "外交官 {1_Name}, {2_Rank}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_NO_DIPLO_NOTES"] = "外交メモなし"

-- Screen mode
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_MODE"] = "マップモード"

-- Batch 04: 109 keys

-- Search
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "{1_Buffer} に一致なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "検索クリア"

-- Screen surface labels
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "ヘルプ"

-- Help overlay: entry template and key names
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "文字キー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "上または下"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home または End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter またはスペース"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "左または右"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift + 左または右"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Control + 上または下"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ALT_LEFT_RIGHT"] = "Alt + 左または右"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift + Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I"] = "Control + I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "疑問符"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12"] = "Control + Shift + F12"

-- Help overlay: action descriptions
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "文字入力で検索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "項目を移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "先頭または末尾へジャンプ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "実行"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "値を調整またはドリルイン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "値を大きなステップで調整"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "前または次のグループへジャンプ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "次のタブ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "前のタブ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "画面ヘッダーを読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA"] = "現在の項目のシヴィロペディアを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "キャンセル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "閉じる"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "編集をキャンセル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "編集を確定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "設定を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "設定を閉じる"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE"] = "modを一時停止または再開"

-- Table widget: sort announcements and help
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, 降順"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, 昇順"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, 並び替えクリア"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON"] = "並べ替えボタン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS"] = "行を移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS"] = "列を移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END"] = "先頭または末尾の行"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER"] = "セルを実行または列で並び替え"

-- Settings screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "設定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "地形音声キュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "音声のみ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "音声と音声キュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI"] = "詳細な読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "音声キューのみ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "地形音声キュー音量"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "地形音声キュー音量, {1_Num} パーセント"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE"] = "ビーコン聴取距離"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE"] = "ビーコン聴取距離, {1_Num} マス"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "スキャナー自動カーソル移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "カーソルが選択ユニットを追従"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "移動中のカーソル座標"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "オフ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "移動アナウンス前に読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "移動アナウンス後に読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE"] = "マス読み上げ時に常に領土を通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "スキャナーに座標を表示"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "字幕を読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "移動中の視界変化を通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "AI戦闘結果を通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] =
    "ターン開始時の視界変化を通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE"] =
    "視界内で他文明が制圧した野営地と遺跡を通知"

-- Generic widget vocabulary
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "選択済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED_NAMED"] = "選択済み, {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "オン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "オフ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_STATE"] = "{1_Label}, {2_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABEL_VALUE"] = "{1_Label} {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LABELED_LIST"] = "{1_Label} {2_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT"] = "{1_Label}, {2_Amount}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_PER_TURN_LINE"] = "{1_Label}, {2_Amount}, {3_TurnsLine}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_VALUE_UNIT"] = "{1_Value} {2_Unit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "編集"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "空白"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "{1_Label} 編集中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} 復元"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_BUTTON"] = "ボタン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_CHECKBOX"] = "チェックボックス"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_SLIDER"] = "スライダー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_PULLDOWN"] = "コンボボックス"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_GROUP"] = "サブメニュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_KIND_TABLE"] = "テーブル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_POSITION"] = "{2_Num}件中{1_Num}番目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF"] = "{2_Num}行中{1_Num}行目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF"] = "{2_Num}列中{1_Num}列目"

-- Screen names: menus and popups
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_MENU"] = "ポーズメニュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GENERIC_POPUP"] = "ポップアップ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"] = "通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"] = "遺産完成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_SPLASH"] = "世界議会"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_END_GAME"] = "ゲーム終了"

-- End-game screen rows
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_ROW"] = "{1_Rank} {2_Leader}, スコア {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW"] = "{1_Rank} {2_Leader}, あなたのスコア {3_Score}, {4_Quote}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_TURN_GROUP"] = "ターン {1_Turn}"

-- Diplomacy screens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DECLARE_WAR"] = "宣戦布告"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"] = "都市国家の挨拶"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_DIPLO"] = "都市国家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"] = "外交"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_DENOUNCE"] = "非難"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DISCUSS_COOP_WAR"] = "共同戦争の目標"

-- Choice popups
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"] = "傑作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_GOODY_HUT_REWARD"] = "集落報酬の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"] = "無償の偉人の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"] = "信仰力による偉人の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"] = "マヤボーナスの選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PANTHEON"] = "万神殿の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"] = "イデオロギーの選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ARCHAEOLOGY"] = "考古学結果の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"] = "提督の新しい母港の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"] = "交易ユニットの新しい拠点の選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"] = "交易路の開設"

-- Batch 05: 100 keys

-- Religion screens
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_CONFIRM"] = "確認"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_RELIGION"] = "宗教を選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ENHANCE_RELIGION"] = "宗教を強化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHANGE_RELIGION_NAME"] = "宗教名を変更"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_UNCHOSEN"] = "{1_Slot}, 未選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_CHOSEN"] = "{1_Slot}, {2_Belief}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_LATER"] = "{1_Slot}, 後で利用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_SLOT_BYZANTINES_ONLY"] = "{1_Slot}, ビザンティン専用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_UNSELECTED"] = "宗教, 未選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_PICKER_SELECTED"] = "宗教, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_ROW"] = "名前, {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_NAME_FIELD"] = "宗教名"

-- Notification log
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_NOTIFICATION_LOG"] = "通知ログ"

-- League project
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_PROJECT"] = "世界議会プロジェクト完了"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_ENTRY"] = "{1_Rank}, {2_Name}, 生産力 {3_Score}, {4_Tier}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_GOLD"] = "金賞報酬"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_SILVER"] = "銀賞報酬"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_BRONZE"] = "銅賞報酬"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROJECT_TIER_NONE"] = "報酬なし"

-- Vote results
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"] = "投票結果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY"] = {
    other = "{1_Rank}, {2_Name} が {3_Cast} に投票, {4_Votes} 票獲得",
}

-- Who's winning
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WHOS_WINNING"] = "勝利状況"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY"] = "{1_Rank}. {2_Name}, {3_Score}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_WHOS_WINNING_ENTRY_CITY"] = "{1_Rank}. {2_City}, {3_Owner}, {4_Score}"

-- Tutorial advisor
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVISOR_TUTORIAL"] = "チュートリアルアドバイザー"

-- Notification tabs
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_ACTIVE"] = "アクティブ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_TURN_LOG"] = "ターンログ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_TAB_DISMISSED"] = "却下済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_EMPTY"] = "通知なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NOTIFICATION_ITEM"] = "{1_Text}, ターン {2_Turn}"

-- Combat log
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_GROUP"] = "戦闘ログ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_COMBAT_LOG_EMPTY"] = "このターンの戦闘なし."

-- Military overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_PROGRESS"] = "{1_Label}: 経験値 {2_Cur}/{3_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SUPPLY_BRIEF"] = "供給: {1_Use}/{2_Cap}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_STATUS_IDLE"] = "待機中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_UNITS"] = "ユニット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_TAB_GREAT_PEOPLE"] = "偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_COL_DISTANCE"] = "距離"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MOVEMENT"] = "残り行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_MAX_MOVES"] = "最大行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_STRENGTH"] = "戦闘力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_SORT_MODE_RANGED"] = "遠隔"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_ROW"] =
    "{1_City}: {2_Turns}, {3_Progress}/{4_Threshold}, ターンあたり +{5_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_CITY_NO_PROGRESS"] = "{1_City}: {2_Progress}/{3_Threshold}, 進捗なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_NEXT"] = "次のターン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MO_GP_TURNS_N"] = {
    other = "{1_N} ターン",
}

-- Advisor
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_EMPTY"] = "助言なし."

-- F-key help
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F1"] = "シビロペディアを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F2"] = "経済アドバイザーを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F3"] = "F3"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F3"] = "軍事アドバイザーを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F4"] = "F4"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F4"] = "外交アドバイザーを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F5"] = "F5"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F5"] = "社会制度画面を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F6"] = "テクノロジーツリーを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F7"] = "F7"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F7"] = "ターンとイベントログを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F8"] = "F8"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F8"] = "勝利進捗画面を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_KEY_F9"] = "F9"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FKEY_HELP_DESC_F9"] = "統計画面を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_KEY"] = "F10"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_COUNSEL_HELP_DESC"] = "アドバイザーの助言を開く"

-- City view
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CITY_VIEW"] = "都市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_CONNECTED"] = "接続済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNEMPLOYED"] = "{1_Num} 人無職"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD"] = "食料 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION"] = "生産力 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD"] = "ゴールド {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE"] = "科学力 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH"] = "信仰力 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM"] = "観光力 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE"] = "文化力 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_NEXT"] = "Period"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_NEXT"] = "次の都市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_KEY_PREV"] = "Comma"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HELP_DESC_PREV"] = "前の都市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_NEXT_CITY"] = "次の都市なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_PREV_CITY"] = "前の都市なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_STATS"] = "統計"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WONDERS"] = "遺産"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_PEOPLE"] = "偉人進捗"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_WORKER_FOCUS"] = "市民配置"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNEMPLOYED_ACTION"] = "無職: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_WONDERS_EMPTY"] = "建造済みの遺産なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_EMPTY"] = "偉人生成なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GP_ENTRY"] = "{1_Name}, {2_Cur}/{3_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_SELECTED"] = "{1_Label}, 選択済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_AVOID_GROWTH"] = "成長回避, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET"] = "マス配置をリセット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_CHANGED"] = "{1_Label} 選択済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOCUS_RESET_DONE"] = "マス配置リセット済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_UNEMPLOYED"] = "無職なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SLACKER_ASSIGNED"] = "配置済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_BUILDINGS"] = "建造物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_BUILDINGS_EMPTY"] = "建造物なし."

-- Batch 06: 102 keys

-- Specialists
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_SPECIALISTS"] = "専門家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_GP_POINTS"] = {
    other = "+{1_N} 偉人ポイント",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALISTS_EMPTY"] = "専門家スロットなし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_SLOT"] = "{1_Building} {2_Specialist} スロット {3_N}, {4_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_EMPTY"] = "空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_STATE"] = "装着済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED"] = "装着済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED"] = "未装着"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_FILLED_FROM_TILE"] = "装着済み, ワーカーのマス割り当て解除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_UNFILLED_TO_TILE"] = "未装着, ワーカーをマスに割り当て"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPECIALIST_CANNOT_ADD"] = "専門家を追加できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_MANUAL_SPECIALIST"] = "専門家手動管理, {1_State}"
-- Great works
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_GREAT_WORKS"] = "傑作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_ART"] = "美術"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_WRITING"] = "文学"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_MUSIC"] = "音楽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_FILLED"] = "{1_Building} {2_Slot} スロット {3_N}, {4_Work}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_SLOT_EMPTY"] = "{1_Building} {2_Slot} スロット {3_N}, 空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_THEMING_BONUS"] =
    "{1_Building} テーマボーナス +{2_Amount}. {3_Tip}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_GW_EMPTY_LIST"] = "傑作スロットなし."
-- Production queue
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_PRODUCTION"] = "生産キュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_EMPTY"] = "キュー空."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN"] = {
    other = "スロット 1, {1_Name}, {2_Turns} ターン, {3_Percent} パーセント. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_TRAIN_INFINITE"] =
    "スロット 1, {1_Name}, {2_Percent} パーセント. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT1_PROCESS"] = "スロット 1, {1_Name}. {2_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN"] = {
    other = "スロット {1_N}, {2_Name}, {3_Turns} ターン. {4_Help}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_TRAIN_INFINITE"] = "スロット {1_N}, {2_Name}. {3_Help}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_SLOT_PROCESS"] = "スロット {1_N}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "[ICON_PRODUCTION] 残り生産力: {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_ACTIONS"] = "{1_Name} アクション"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_UP"] = "上に移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVE_DOWN"] = "下に移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVE"] = "キューから削除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_BACK"] = "戻る"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_UP"] = "上に移動済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_MOVED_DOWN"] = "下に移動済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMOVED"] = "削除済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_QUEUE_MODE"] = "キューモード, {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_CHOOSE"] = "生産を選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_PURCHASE"] = "ゴールドまたは信仰力で購入"
-- Manage territory
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_HEX"] = "領土管理"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_MODE"] = "領土管理"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_WORKED"] = "開拓済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_PINNED"] = "ピン留め"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_BLOCKED"] = "阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_TILE_NOT_WORKED"] = "未開拓"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_COST"] = "購入可能, {1_Gold} ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_BUY_UNAFFORDABLE"] = "購入可能, {1_Gold} ゴールド, 資金不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_CANNOT_AFFORD"] = "資金不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_MOVE"] = "Q A Z E D C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_MOVE"] = "都市マス間でカーソル移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_ENTER"] = "マスを開拓または購入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_KEY_BACK"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_HELP_DESC_BACK"] = "都市ハブに戻る"
-- Ranged strike
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RANGED_STRIKE"] = "遠隔攻撃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_MODE"] = "遠隔攻撃"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_CANNOT_STRIKE"] = "攻撃不可"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_FIRED"] = "発射済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW"] =
    "{1_Name}, {2_MyStr} 対 {3_TheirStr}, 相手に {4_Dmg} ダメージ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_PREVIEW"] = "ターゲット情報を読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_COMMIT"] = "現在のターゲットに発射"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITY_RANGED_HELP_DESC_CANCEL"] = "発射せずにキャンセル"
-- Gift
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_UNIT_MODE"] = "ユニット贈与"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_MODE"] = "改善贈与"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_IMPROVEMENT_GIVEN"] = "改善贈与済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_PREVIEW"] = "ターゲット情報を読み上げ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_COMMIT"] = "現在のターゲットに贈与実行"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GIFT_HELP_DESC_CANCEL"] = "贈与せずにキャンセル"
-- City actions
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RENAME"] = "都市名変更"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_RAZE"] = "都市を焼却"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HUB_UNRAZE"] = "焼却を中止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_UNRAZE_DONE"] = "焼却中止済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_SPYING_PREFIX"] = "スパイ中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_NO_CYCLE_SPYING"] = "スパイ中は都市サイクル利用不可"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_RANGED"] =
    "自分の都市でない場合, 遠隔攻撃を実行できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_PRODUCTION"] =
    "自分の都市でない場合, 生産力を変更できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_WORK_TILE"] =
    "自分の都市でない場合, マスを開拓できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_BUY_PLOT"] = "自分の都市でない場合, マスを購入できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SELL"] = "自分の都市でない場合, 建造物を売却できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_FOCUS"] = "自分の都市でない場合, フォーカスを変更できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SPECIALIST"] =
    "自分の都市でない場合, 専門家を管理できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_GREAT_WORK_OPEN"] =
    "自分の都市でない場合, 傑作を確認できない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_FOREIGN_NO_SLACKER"] =
    "自分の都市でない場合, 市民を割り当てできない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_HEX_PURCHASABLE_FOREIGN"] = "購入可能"
-- Reveal
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_COUNT"] = {
    other = "{1_Num} マス発見",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_HEADER"] = "発見済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_ENEMY"] = "敵: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_UNITS"] = "ユニット: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_CITIES"] = "都市: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REVEAL_RESOURCES"] = "資源: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HIDDEN_HEADER"] = "非表示"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_ENTERED"] = "視野内に新たな敵対ユニット: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_HOSTILE_LEFT"] = "敵対ユニットが視野外に: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_ENTERED"] = "視野内に新たな中立ユニット: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_NEUTRAL_LEFT"] = "中立ユニットが視野外に: {1_List}"

-- Batch 07: 102 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_PREFIX"] = "占領済み: "
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"] = "と"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_SUFFIX"] = "."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_CAMP_PART"] = {
    other = "{1_Num}つの蛮族の野営地が見える",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FOREIGN_RUIN_PART"] = {
    other = "{1_Num}つの古代遺跡が見える",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_HEADER"] = "消滅"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_CAMP_PART"] = {
    other = "{1_Num}つの蛮族の野営地",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GONE_RUIN_PART"] = {
    other = "{1_Num}つの古代遺跡",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_START"] = "{1_Turn}, {2_Date}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_ENDED"] = "ターン終了"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_END_TURN_CANCELED"] = "ターン終了キャンセル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END"] = "Control + Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END"] = "ターン終了, またはブロッカーを通知して最初のブロッカーを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE"] = "Control + Shift + Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE"] =
    "行動命令待ちのユニットプロンプトを無視してターン終了. その他のブロッカーは引き続き通知して開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER"] = "ユニット上限を{1_Num}超過"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE"] = {
    other = "{2_Tech}まで{1_Turns}ターン, 科学力+{3_Rate}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE"] = "{1_Tech}完了, 科学力+{2_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE"] = "研究なし, 科学力+{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF"] = "科学力オフ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE"] = {
    other = "ゴールド+{1_Rate}, 合計{2_Total}, 交易路{3_Used}/{4_Avail}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE"] = {
    other = "ゴールド-{1_Rate}, 合計{2_Total}, 交易路{3_Used}/{4_Avail}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM"] = "{1_Resource}不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM"] = "{1_Name} {2_Count}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"] = "黄金時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"] = "宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"] = "偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"] = "影響力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPY"] = "幸福度+{1_Excess}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_UNHAPPY"] = "不満 -{1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY"] = "非常に不満 -{1_Deficit}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE"] = {
    other = "黄金時代 残り{1_Turns}ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS"] = "黄金時代まで{1_Cur}/{2_Threshold}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF"] = "幸福度オフ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH"] = "信仰力+{1_Rate}, 合計{2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF"] = "宗教オフ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON"] = "次の万神殿まで信仰力{1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"] = "利用可能な万神殿なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET"] = "次の大預言者まで信仰力{1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST"] = "都市ごとに研究コスト+{1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST"] = "都市ごとに社会制度コスト+{1_Pct}%"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY"] = {
    other = "文化力+{1_Rate}, 社会制度まで{2_Turns}ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT"] = "文化力+{1_Rate}, 残り社会制度なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED"] = "文化力なし, 次の社会制度まで{1_Cur}/{2_Cost}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF"] = "社会制度オフ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM"] = "観光力+{1_Rate}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL"] = {
    other = "観光力+{1_Rate}, {2_Count}文明に影響力あり",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH"] = {
    other = "観光力+{1_Rate}, {3_Total}文明中{2_Count}文明に影響力あり",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN"] = "T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN"] =
    "ターンと日付. 上限超過時はユニット供給量, 戦略資源の不足も通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH"] = "R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH"] = "現在の研究とターンごとの科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD"] = "G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD"] = "ターンごとのゴールド, 合計, 交易路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS"] = "H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS"] =
    "帝国の幸福度, 幸福度を提供している嗜好品の数, 黄金時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH"] = "F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH"] = "ターンごとの信仰力と合計"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY"] = "P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY"] = "ターンごとの文化力と次の社会制度までの時間"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM"] = "I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM"] = "ターンごとの観光力と影響力を持つ文明数"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH_DETAIL"] = "Shift + R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH_DETAIL"] = "供給源別の科学力内訳"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD_DETAIL"] = "Shift + G"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD_DETAIL"] = "供給源別のゴールド収入と支出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS_DETAIL"] = "Shift + H"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS_DETAIL"] =
    "幸福源, 不満源, 黄金時代の効果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH_DETAIL"] = "Shift + F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH_DETAIL"] =
    "供給源別の信仰力内訳と大預言者または万神殿のタイミング"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY_DETAIL"] = "Shift + P"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY_DETAIL"] = "供給源別の文化力内訳"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM_DETAIL"] = "Shift + I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM_DETAIL"] =
    "傑作, 空きスロット, 影響力を持つ文明数"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_KEY"] = "Shift + T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TASKLIST_HELP_DESC"] = "アクティブなシナリオのタスクを読み上げる"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_ACTIONS_TAB"] = "アクション"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MODS_TAB"] = "Mod"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_NO_MODS"] = "有効なModなし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GAMEMENU_MOD_ENTRY"] = "{1_Title}, バージョン{2_Version}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB"] = "カテゴリ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB"] = "コンテンツ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_ARTICLE"] = "記事テキストなし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "このエントリのコンテンツなし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "エントリ未選択. カテゴリタブに切り替えて選択してください."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_INTRO"] = "イントロ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_PREV_HISTORY"] = "履歴の先頭."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PEDIA_NO_NEXT_HISTORY"] = "履歴の末尾."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PEDIA_HISTORY"] = "履歴内の前または次の記事"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADVISOR_INFO_HISTORY"] = "履歴内の前または次のコンセプト"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB"] = "セーブ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB"] = "セーブ詳細"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NO_SAVES"] = "このリストにセーブなし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_NAME_LABEL"] = "セーブ名"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_INVALID_NAME"] = "セーブ名が空か無効な文字が含まれている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_ACTION"] = "このセーブを上書き"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_TO_SLOT_ACTION"] = "このスロットにセーブ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CONFIRM"] = "{1_Name}を上書きしますか?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_OVERWRITE_CLOUD_CONFIRM"] = "Steam Cloudスロット{1_Num}を上書きしますか?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETE_CONFIRM"] = "{1_Name}を削除しますか?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_DELETED"] = "セーブ削除済み."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SAVE_CLOUD_SLOT_EMPTY"] = "Steam Cloudスロット{1_Num}: 空"

-- Batch 08: 115 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "食料"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "生産力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "文化力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "信仰力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "観光力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "偉人"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ARTIST"] = "大芸術家ポイント:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_ENGINEER"] = "大技術者ポイント:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_MERCHANT"] = "大商人ポイント:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT_SCIENTIST"] = "大科学者ポイント:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_WORK"] = "傑作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "戦闘力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "遠隔戦闘力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH_ALT"] = ""
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "行動力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "幸福度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "幸福"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "不満度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "不満"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "左"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "右"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_PRODUCTION"] = "生産を選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PRODUCE"] = "生産"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TAB_PURCHASE"] = "購入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GROUP_QUEUE"] = "現在のキュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "追加済み, キューの {1_Slot} 番目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "キュー満タン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "キューが空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PREAMBLE_QUEUE_COUNT"] = "キューに {1_N} 件"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = {
    other = "{1_Num} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} 信仰力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_BUILDING"] = "{1_Name} を生産中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_PURCHASED"] = "{1_Name} を購入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT"] = {
    other = "{1_Name}, {2_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_SLOT_PROCESS"] = "{1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TECH"] = "研究を選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_FREE"] = "無償テク, 残り {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_STEALING"] = "{1_Civ} から盗取中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_PREAMBLE_SCIENCE"] = "ターン毎 {1_N} 科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_CURRENT_PIN"] = {
    other = "現在 {1_Name} を研究中, {2_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_FREE"] = "無償"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_CURRENT"] = "現在研究中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_STATUS_QUEUED"] = "キューの {1_Slot} 番目"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_TURNS"] = {
    other = "{1_Num} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_OPEN_TREE"] = "技術ツリーを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT"] = "{1_Name} 研究開始"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE"] = "{1_Name} を習得"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN"] = "{1_Name} を入手"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"] = "技術ツリー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE"] = "全技術"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"] = "キュー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_RESEARCHED"] = "研究済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_AVAILABLE"] = "利用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_UNAVAILABLE"] = "前提条件未達"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_STATUS_LOCKED"] = "ロック中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY"] = "研究なし, キューが空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_CURRENT_TOKEN"] = "現在"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT"] = "{1_Name} を予約"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_RESEARCHED"] = "研究済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_FREE_INELIGIBLE"] = "無償テクの対象外"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_REJECT_STEAL_INELIGIBLE"] = "盗取不可"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV"] = "Up/Down/Left/Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"] =
    "Up/Down で時代の列を移動, Left/Right で横移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE"] =
    "Right で後続テク, Left で前提テク, Up/Down で同列技術"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"] = "グリッドまたはツリーナビに切り替え"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID"] = "グリッド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"] = "ツリー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"] = "フォーカスした技術を研究"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER"] = "Shift + Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"] = "フォーカスした技術を予約"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA"] = "Control + I"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"] = "シビロペディアを開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH"] = "文字 / 数字 / スペース"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH"] = "名前またはアンロック内容で検索"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6"] = "F6"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"] = "技術ツリーを閉じる"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"] = "技術ツリーを閉じる"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SOCIAL_POLICY"] = "社会制度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_POLICIES"] = "社会制度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TAB_IDEOLOGY"] = "イデオロギー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_OPENED"] = "開放済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_FINISHED"] = "完了"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_ADOPTABLE"] = "採用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_ERA"] = "ロック中, {1_Era} が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED_RELIGION"] = "ロック中, 宗教の建国が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_LOCKED"] = "ロック中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_STATUS_BLOCKED"] = "阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_BRANCH_COUNT"] = "{2_Total} 中 {1_Num} 採用済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_OPENER"] = "オープナー, ブランチ開放時に無償で獲得"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_FINISHER"] = "フィニッシャー, ブランチ完了時に授与"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTED"] = "採用済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_ADOPTABLE"] = "採用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_BLOCKED"] = "阻止"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED"] = "ロック中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_POLICY_LOCKED_REQUIRES"] = "ロック中, {1_Prereqs} が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPEN_BRANCH_ITEM"] = "{1_Branch} を開放"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_CULTURE"] = "{2_Cost} 中 {1_Cur} 文化力, ターン毎 {3_Per}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_TURNS"] = {
    other = "次の社会制度まで {1_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_POLICIES"] = {
    other = "無償社会制度 {1_Num} 件利用可能",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_PREAMBLE_FREE_TENETS"] = {
    other = "無償教義 {1_Num} 件利用可能",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_NOT_STARTED"] = "イデオロギー未選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_DISABLED"] = "このゲームではイデオロギー無効"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_1"] = "レベル1の教義"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_2"] = "レベル2の教義"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_IDEOLOGY_LEVEL_3"] = "レベル3の教義"

-- Batch 09: 100 keys

-- Social policy slots
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED"] = "スロット{1_Num}, {2_Name}, {3_Effect}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_FILLED_NAME_ONLY"] = "スロット{1_Num}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_AVAILABLE"] = "スロット{1_Num}, 空, 利用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_SLOT"] =
    "スロット{1_Num}, 空, スロット{2_Req}が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_REQ_CROSS"] =
    "スロット{1_Num}, 空, 階層{2_Level}のスロット{3_Req}が必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SLOT_EMPTY_CULTURE"] = "スロット{1_Num}, 空, 文化力不足"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY"] = "イデオロギーを変更"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCH_IDEOLOGY_DISABLED"] = "イデオロギーを変更, 利用不可"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPINION_UNHAPPINESS"] = "幸福度 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_TENET_PICKER"] = "教義を選択"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_NO_TENETS"] = "利用可能な教義なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_POLICY"] = "{1_Name}を採用?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_OPEN_BRANCH"] = "ブランチ{1_Name}を開放?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_ADOPT_TENET"] = "{1_Name}を採用?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_CONFIRM_SWITCH_IDEOLOGY"] = "イデオロギーを変更?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED"] = "{1_Name}を採用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_OPENED"] = "{1_Name}を開放"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_ADOPTED_TENET"] = "教義{1_Name}を採用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SOCIALPOLICY_SWITCHED"] = "イデオロギー変更を申請"

-- Number entry
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_DIGITS"] = "Digits"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_BACKSPACE"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_DIGIT"] = "数字を追加"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_BACKSPACE"] = "最後の数字を削除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NUMENTRY_COMMIT"] = "数量を確定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_PROMPT"] = "{1_Label}を入力, 最大{2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_NUMENTRY_EMPTY"] = "空"

-- Trade screen
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE"] = "取引"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH"] = "{1_Name}との取引"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOUR_OFFER"] = "自分の提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEIR_OFFER"] = "相手の提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_OFFERING"] = "提供中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_TAB_AVAILABLE"] = "利用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING"] = "{1_Resource}, {2_Qty}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING"] = "{1_Name}, 人口{2_Pop}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN"] = "投票の約束"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"] = "{1_Name}と和平"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"] = "{1_Name}に宣戦布告"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE"] = "和平を結ぶ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR"] = "宣戦布告"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OTHER_PLAYERS"] = "他のプレイヤー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_NONE_AVAILABLE"] = "利用可能なものなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_OFFERING_EMPTY"] = "交渉テーブルに何もない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_YOU_HAVE"] = "自分は{1_Num}保有"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_THEY_HAVE"] = "相手は{1_Num}保有"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"] = "自分の提供: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"] = "相手の提供: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_WE_GAVE"] = "自分が提供した: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE"] = "相手が提供した: {1_List}"

-- Diplomacy overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"] = "取引"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"] = "過去の取引"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV"] = "{2_Civ}の{1_Leader}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL"] = "スコア{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL"] = "ゴールド{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL"] = "毎ターンのゴールド{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT"] = "{1_Name} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST"] = "戦略資源: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST"] = "高級資源: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST"] = "周辺: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_LIST"] = "ボーナス: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT"] = "{1_Branch} {2_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST"] = "社会制度: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST"] = "遺産: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"] = "主要文明"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"] = "都市国家"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"] = "接触した文明なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"] = "取引なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING"] = "提案受信中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING"] = "返答待ち"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TEAM"] = "チーム{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING"] = "{1_Tech}を研究中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE"] = "影響力{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN"] = "毎ターン{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR"] = "基準値{1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE"] = "+{1_N}文化力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS"] = "+{1_N}幸福度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH"] = "+{1_N}信仰力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL"] = "首都に+{1_N}食料"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER"] = "他の都市に+{1_N}食料"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE"] = "+{1_N}科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY"] = {
    other = "{1_N}ターン後に贈呈ユニット",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST"] = "輸出中: {1_List}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS"] = "国境開放"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE"] = "脅迫可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF"] = "{1_Civ}の同盟国"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP"] = "自分との関係"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS"] = "外交関係"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD"] = "ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES"] = "資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ERA"] = "時代"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES"] = "社会制度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS"] = "遺産"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE"] = "スコア"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP"] = "関係"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY"] = "特性と性格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE"] = "影響力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH"] = "同盟相手"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS"] = "クエスト"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY"] = "周辺資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NONE"] = "なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_NOBODY"] = "なし"

-- Batch 10: 105 keys
-- Diplomacy panel
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL"] = "{1_Gold}, {2_GPT} ゴールド/ターン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS"] = "友好関係まで {1_N} 必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES"] = "同盟関係まで {1_N} 必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU"] = "自分"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE"] = "{1_Civ}, 排除まで {2_N} 必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE"] = "未遭遇の文明, 排除まで {1_N} 必要"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL"] = "{1_Trait}, {2_Personality}"
-- City stats panel
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"] = "収益"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION"] = "宗教"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE"] = "交易路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES"] = "資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"] = "内訳なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION"] = "{2_Threshold} 中 {1_Cur}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_IN"] = {
    other = "{1_Num} ターン後に次のタイル",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_TILE_STALLED"] = "タイル拡張が停滞中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE"] =
    "現地幸福度 {1_Local}, 不満度 {2_Unhappiness}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE"] = {
    other = "{1_Religion}, 信者 {2_Followers} 人, 布教力 {3_Pressure}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE"] = {
    other = "{1_Religion}, 聖都, 信者 {2_Followers} 人, 布教力 {3_Pressure}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYSTATS_RESOURCE_LINE"] = "{1_Name} {2_Num}"
-- Trade route chooser
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL"] = "{1_Civ}, {2_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE"] = {
    other = "{1_Num} ヘックス",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET"] = "自分が得る {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET"] = "相手が得る {1_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS"] = "{1_City} が得る {2_Yields}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE"] = "{2_Religion} 布教力 {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"] = "有効な目的地なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"] = "有効な本拠都市なし."
-- Trade Route Overview
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_KEY"] = "Control + T"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_HOTKEY_HELP_DESC"] = "交易路一覧を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_YOURS"] = "自分の交易路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_AVAILABLE"] = "利用可能な交易路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TAB_WITH_YOU"] = "自分との交易路"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND"] = "キャラバン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA"] = "貨物船"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER"] = "{1_Domain}, {2_From} から {3_To} へ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF"] = "都市国家 {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT"] = {
    other = "残り {1_Num} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_ROUTES"] = "交易路なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_NO_DETAILS"] = "収支内訳なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_LABEL"] = "並び替え: {1_Sort}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PROMPT"] = "並び替え"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_GOLD"] = "受取ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_SCIENCE"] = "受取科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_FOOD"] = "受取食料"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRODUCTION"] = "受取生産力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TRO_SORT_PRESSURE"] = "目的地への宗教布教力"
-- Leader help overlay
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_LEADER_DESC"] = "指導者を解説"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_MISSING"] = "この指導者の説明はありません."
-- Empire Overview tabs
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_CITIES"] = "都市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_GOLD"] = "ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_HAPPINESS"] = "幸福度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_TAB_RESOURCES"] = "資源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_POPULATION"] = "人口"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_STRENGTH"] = "防衛力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FOOD"] = "食料"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"] = "科学力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_GOLD"] = "ゴールド"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_CULTURE"] = "文化力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_FAITH"] = "信仰力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION"] = "生産力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_CAPITAL"] = "首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_ANNOT_OCCUPIED"] = "占領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_OCCUPIED_FLAG"] = "占領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LABEL"] = "{1_Name} ({2_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE"] = "{1_Name}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CITY_LINE_ANNOT"] = "{1_Name}, {2_Value} ({3_Annot})"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_EMPTY"] = "項目なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_NONE"] = "生産なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_CELL"] = {
    other = "{1_Turns} ターン: {2_Name}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_PROD_FULL"] = "ターン毎 {1_PerTurn}, {2_Cell}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_POP_CELL"] = "{1_Pop}, {2_Growth}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_DEF_CELL"] = "{1_Def}, {2_Hp}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_FOOD_CELL"] = "{1_Food}, {2_Progress}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_CULTURE_CELL"] = "{1_Culture}, {2_Border}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_TOTAL"] = "総ゴールド, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TOTAL"] = "収入, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSES_TOTAL"] = "支出, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GOLD_NET"] = "ターン毎の純収支, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_SCIENCE_PENALTY"] = "ゴールド赤字による科学力損失, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_CITIES"] = "都市, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_DIPLO"] = "外交, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_RELIGION"] = "宗教, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_INCOME_TRADE"] = "都市間接続, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_UNITS"] = "ユニット, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_BUILDINGS"] = "建造物, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_IMPROVEMENTS"] = "改善, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_EXPENSE_DIPLO"] = "外交, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TOTAL"] = "総幸福度, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_HAPPY_SOURCES"] = "幸福度の発生源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURIES"] = "高級資源, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_VARIETY"] = "高級資源の種類, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_BONUS"] = "高級資源からのボーナス, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_LUXURY_MISC"] = "その他の高級資源ボーナス, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_GROUP_CITIES"] = "都市幸福度, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY"] = "建造物, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_BUILDINGS_PERCITY_TT"] = "各都市における建造物, 駐屯, 宗教, 社会制度の相乗効果による幸福度. "
    .. "都市人口を上限とする."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES"] = "遺産ボーナス, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_TT"] = "特殊効果を持つ遺産による幸福度: 建造物クラスの相乗効果, "
    .. "未改造の幸福度, または社会制度毎のボーナス. 大半の幸福建造物は"
    .. "この行ではなく上の建造物 (各都市) に計上される."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WONDER_BONUSES_EMPIRE"] = "帝国全体ボーナス, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_TRADE_ROUTES"] = "交易路, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_CITY_STATES"] = "都市国家, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_POLICIES"] = "社会制度, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_RELIGION"] = "宗教, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_NATURAL_WONDERS"] = "自然の驚異, {1_Value}"

-- Batch 11: 113 keys

-- Economic Overview / Happiness tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES"] = "都市ごとのボーナス, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_PERCITY_BONUSES_TT"] = "所有する都市1つにつき一定量の幸福度を与える建造物や社会制度からの幸福度. "
    .. "都市数に乗算される."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_WORLD_CONGRESS"] = "世界議会, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_HAPPY_DIFFICULTY"] = "難易度, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_TOTAL"] = "合計不満度, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_GROUP_UNHAPPY_SOURCES"] = "不満度の発生源"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_NUM_CITIES"] = {
    other = "{1_Count} 都市, {2_Value} 不満度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_CITIES"] = {
    other = "{1_Count} 占領都市, {2_Value} 不満度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_POPULATION"] = {
    other = "{1_Count} 市民, {2_Value} 不満度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_OCCUPIED_POP"] = {
    other = "{1_Count} 占領市民, {2_Value} 不満度",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PUBLIC_OPINION"] = "世論, {1_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_UNHAPPY_PER_CITY"] = "都市別内訳"

-- Resources tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE"] = "利用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_USED"] = "使用中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_LOCAL"] = "地域"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_IMPORTED"] = "輸入"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_EXPORTED"] = "輸出"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_EO_RES_NA"] = "n/a"

-- Victory Progress tabs / columns
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_SCORE"] = "スコア"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TAB_VICTORIES"] = "勝利"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_COL_TOTAL"] = "合計"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_ROW_LOST"] = "{1_Name}, 首都陥落"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DOMINATION"] = "征服"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_SCIENCE"] = "科学"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_DIPLOMATIC"] = "外交"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_BUTTON_CULTURAL"] = "文化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_LABEL_VALUE"] = "{1_Label}, {2_Value}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_TEAM_SUFFIX"] = "チーム {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_BOOSTERS"] = {
    other = "{1_Num} ブースター",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_COCKPIT"] = "コックピット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_CHAMBER"] = "コールドスリープチャンバー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PART_ENGINE"] = "エンジン"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_NO_APOLLO"] = "{1_Name}, アポロ計画未建設"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE"] = "{1_Name}, アポロ計画建設済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_BARE_SELF"] = "アポロ計画建設済み, パーツなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_ROW_APOLLO_PARTS"] = "{1_Name}, アポロ計画建設済み, {2_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_SELF_PARTS"] = "アポロ計画建設済み, {1_Parts}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_VP_SCIENCE_PREREQ_PROGRESS"] = {
    other = "{2_Total} 個中 {1_Have} 個の前提技術を研究済み",
}

-- Demographics
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_ROW"] =
    "{1_Metric}, 順位 {2_Rank}, {3_Value}, 最高 {4_BestCiv} {5_BestVal}, 平均 {6_AvgVal}, 最低 {7_WorstCiv} {8_WorstVal}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_DEMO_LABEL_GOLD"] = "国民総生産"

-- Culture Overview tabs
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_YOUR_CULTURE"] = "自分の文化力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_SWAP_WORKS"] = "傑作の交換"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_VICTORY"] = "文化勝利"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_TAB_INFLUENCE"] = "プレイヤーの影響力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_ANTIQUITY_SITES"] = "遺跡: 表示 {1_Visible}, 非表示 {2_Hidden}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL"] = {
    other = "{1_Name}, 文化力 {2_Cul}, 観光力 {3_Tou}, 傑作 {4_Filled}/{5_Total}",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_LABEL_DAMAGED"] = {
    other = "{1_Name}, 文化力 {2_Cul}, 観光力 {3_Tou}, 傑作 {4_Filled}/{5_Total}, 損傷 {6_Pct} パーセント",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_CAPITAL"] = "首都"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_PUPPET"] = "傀儡"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_PREFIX_OCCUPIED"] = "占領"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_CITY_NO_BUILDINGS"] = "傑作建造物なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_NO_CITIES"] = "都市なし"

-- Great Work slot types
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_WRITING"] = "著作スロット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_ART_ARTIFACT"] = "美術品または遺物スロット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_TYPE_MUSIC"] = "音楽スロット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL"] = "{1_Name}, {2_SlotType}, {3_Filled}/{4_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_LABEL_THEMED"] =
    "{1_Name}, {2_SlotType}, {3_Filled}/{4_Total}, テーマボーナス プラス {5_Bonus}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_FILLED"] = "{1_Name}, {2_SlotType}, {3_WorkName}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_BUILDING_SINGLE_EMPTY"] = "{1_Name}, {2_SlotType}, 空"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_FILLED"] = "{1_Idx}, {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SLOT_EMPTY"] = "{1_Idx}, 空"

-- Great Work classes
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_WRITING"] = "著作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ART"] = "美術品"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_ARTIFACT"] = "遺物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_WORK_CLASS_MUSIC"] = "音楽"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_AUTHORED"] =
    "{1_Class}, {2_Artist} 作, {3_OriginCiv}, {4_Era}, 文化力 プラス {5_Cul}, 観光力 プラス {6_Tou}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_NOCLASS"] =
    "{1_Artist} 作, {2_OriginCiv}, {3_Era}, 文化力 プラス {4_Cul}, 観光力 プラス {5_Tou}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_TOOLTIP_ARTIFACT"] =
    "{1_Class}, {2_OriginCiv}, {3_Era}, 文化力 プラス {4_Cul}, 観光力 プラス {5_Tou}"

-- Great Work move actions
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_MARKED"] = "移動元としてマーク済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_PLACED"] = "移動済み"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_CANCELED"] = "移動元をクリア"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_TYPE_MISMATCH"] = "現在の移動元とスロットタイプが一致しない"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_GW_MOVE_EMPTY_SOURCE"] = "空のスロットからは移動できない"

-- Swap Great Works tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_YOUR_OFFERINGS_LABEL"] = "自分の提供品"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_DESIGNATE_TYPE"] = "{1_Type}: {2_Current}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_WRITING"] = "著作"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ART"] = "美術品"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TYPE_ARTIFACT"] = "遺物"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NONE"] = "未指定"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_CLEAR_ENTRY"] = "指定をクリア"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_LABEL"] = "他文明から利用可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_SLOT_FILLED"] = "{1_Type}: {2_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_NO_OFFERINGS"] = "交換可能な傑作を提供している文明なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_FOREIGN_NO_SLOTS"] = "交換可能な傑作なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NOT_PICKED"] = "交換する他文明の傑作を選択してください"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_NEED_DESIGNATE"] =
    "{3_TheirCiv} の {2_TheirName} と交換する {1_Type} が未指定. 自分の提供品から指定してください"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_TRADE_READY"] =
    "{3_TheirCiv} の {2_TheirName} と自分の {1_YourName} を交換"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_SWAP_SENT"] = "交換を送信済み"

-- Culture Victory tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_INFLUENCED_OF"] = "{2_Total} 中 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_NO_IDEOLOGY"] = "イデオロギーなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_OPINION_NA"] = "世論なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_INFLUENCING"] = "影響中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_TOURISM"] = "観光力"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_IDEOLOGY"] = "イデオロギー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_OPINION"] = "世論"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_UNHAPPY"] = "世論による不満度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_VICTORY_COL_HAPPY"] = "余剰幸福度"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TURNS_TO"] = {
    other = "影響力獲得まで推定 {1_N} ターン",
}

-- Player Influence tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERSPECTIVE"] = "視点の変更"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_LEVEL"] = "影響力レベル"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_PERCENT"] = "影響力パーセント"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_MODIFIER"] = "観光力修正"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_RATE"] = "相手への観光力レート"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_COL_TREND"] = "傾向"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERSPECTIVE_CELL"] =
    "1ターンあたり {1_N} 観光力を生産中. Enterで視点を切り替え"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_NOW_VIEWING"] = "{1_Civ} の視点で表示中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_CELL"] = "{1_N} パーセント"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_PERCENT_TOOLTIP"] =
    "相手の累計文化力 {2_Theirs} に対する自分の観光力 {1_Yours}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_MODIFIER_CELL"] = "{1_N} パーセント"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_FALLING"] = "下降中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_STATIC"] = "横ばい"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING"] = "上昇中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_INFLUENCE_TREND_RISING_SLOWLY"] = "緩やかに上昇中"

-- Batch 12: 109 keys
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_KEY"] = "Control + C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_HOTKEY_HELP_DESC"] = "文化の概要を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CO_DISABLED"] = "このゲームでは文化の概要は無効"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEAGUE_OVERVIEW"] = "世界議会"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_KEY"] = "Control + L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_HOTKEY_HELP_DESC"] = "世界議会の概要を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_STATUS"] = "状態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_PROPOSALS"] = "提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_TAB_EFFECTS"] = "効果"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_RENAME"] = "名前を変更"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU"] = "(自分)"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST"] = "ホスト"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES"] = {
    other = "{1_N} 代表",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE"] = "提案可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING"] = "相手国首都に外交官派遣中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_LEAGUE"] = "世界議会なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_ACTIONS"] = "このセッションでは利用可能なアクションなし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSALS_AVAILABLE"] = {
    other = "{1_N} 件の提案が利用可能.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_DELEGATES_REMAINING"] = {
    other = "代表 {1_N} 名残り.",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_NO_PROPOSALS_THIS_SESSION"] = "このセッションでは提案なし."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX"] = "制定: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX"] = "廃止: {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV"] = "{1_Civ} による提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU"] = "あなたによる提案"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD"] = "保留中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL"] = "あなたの投票: {1_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN"] = "棄権"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA"] = {
    other = "{1_N} 賛成",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY"] = {
    other = "{1_N} 反対",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV"] = "{2_Civ} に {1_N} 票"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY"] = "空の提案スロット {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED"] = "スロット {1_N}: {2_Body}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER"] = "提案スロット {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE"] = "廃止候補の現行決議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE"] = "制定候補の決議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER"] = "その他の決議"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE"] = "この提案の推定票数:"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST"] = "賛成する文明: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST"] = "反対する文明: {1_Civs}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_KEY"] = "Control + R"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_HOTKEY_HELP_DESC"] = "宗教の概要を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_STATUS_FOUNDER"] = "あなたは {1_Religion} の創始者だ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_BELIEF_TYPE"] = "{1_Type} の信条"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_RELIGION_WORLD_ROW"] = {
    other = "{1_Religion}, 聖都 {2_HolyCity}, {3_Founder} が創始, {4_NumCities} 都市",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_KEY"] = "Control + E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_HOTKEY_HELP_DESC"] = "諜報の概要を開く"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_AGENTS"] = "エージェント"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_CITIES"] = "都市"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_TAB_INTRIGUE"] = "諜報情報"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DISABLED"] = "このゲームでは諜報は無効"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE"] = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_LINE_TURNS"] = {
    other = "{1_Rank} {2_Name}, {3_Where}, {4_Activity}, {5_Turns} ターン",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_KIA"] = "{1_Rank} {2_Name} 戦死"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_DIPLOMAT_TAIL"] = ", 外交官"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_AGENT_ACTIONS_DISPLAY"] = "{1_Rank} {2_Name} の行動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CIV_LABEL"] = "文明 {1_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_LABEL"] = "都市 {1_City}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POPULATION"] = "人口 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_VALUE"] = "ポテンシャル {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BASE"] = "基本ポテンシャル {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_BREAKDOWN"] = "内訳: {1_Items}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_POTENTIAL_UNKNOWN"] = "ポテンシャル不明"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_AVAILABLE"] = "都市国家, 選挙操作可能"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_RIG_ELECTION_ACTIVE"] = "都市国家, 選挙操作中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_AGENT_CLAUSE"] = "エージェント {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_CITY_DIPLOMAT_CLAUSE"] = "外交官 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_TURN"] = "ターン {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OWN"] = "スパイ {1_Name} からの情報"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_OTHER"] = "{1_Leader} から共有"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_INTRIGUE_FROM_UNKNOWN"] = "不明"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ESPIONAGE_MOVE_DISPLAY"] = "{1_Rank} {2_Name} を移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_ADDED"] = "ブックマーク追加"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_EMPTY"] = "ブックマークなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_SAVE"] = "Control + 数字キー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_SAVE"] = "カーソル位置のブックマークを対応スロットに保存"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_JUMP"] = "Shift + 数字キー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_JUMP"] =
    "そのスロットのブックマークへカーソルをジャンプ, Backspace で戻る"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_KEY_DIRECTION"] = "Alt + 数字キー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOKMARK_HELP_DESC_DIRECTION"] =
    "カーソルからそのスロットのブックマークまでの距離と方向"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_ACTIVATED"] = "ビーコン {1_Slot} 有効化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_DEACTIVATED"] = "ビーコン {1_Slot} 無効化"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_NO_BOOKMARK"] = "先にこのスロットにブックマークを設定してください"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_KEY"] = "Control + Shift + 数字キー"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BEACON_HELP_DESC"] =
    "そのスロットのブックマークに空間オーディオビーコンを切り替え"

-- Messages tab
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_ALL"] = "全メッセージ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_NOTIFICATION"] = "通知"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_REVEAL"] = "発見"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_COMBAT"] = "戦闘"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_FILTER_CHAT"] = "チャット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_EMPTY"] = "メッセージなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_NAV"] = "左角括弧と右角括弧"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_NAV"] = "バッファ内の前後のメッセージ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_EDGE"] = "Control + 左角括弧と右角括弧"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_EDGE"] = "バッファ内の最古と最新のメッセージ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_KEY_FILTER"] = "Shift + 左角括弧と右角括弧"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MSGBUF_HELP_DESC_FILTER"] =
    "空のカテゴリをスキップしてバッファフィルターを循環"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_KEY"] = "Backslash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_HOTKEY_HELP_DESC"] = "マルチプレイヤーチャットパネルを開く, シングルプレイヤーでは無効"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHAT_SP_NOOP"] = "チャットはマルチプレイヤー専用"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_PANEL"] = "チャット"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MESSAGES_TAB"] = "メッセージ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE_TAB"] = "作成"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_COMPOSE"] = "メッセージ"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_EMPTY"] = "チャットメッセージはまだなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_TEAM"] = "{1_Name} チームへ: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_MSG_WHISPER"] = "{1_Name} から {2_To} へ: {3_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_KEY_CLOSE"] = "Backslash または Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_INGAME_CHAT_HELP_DESC_CLOSE"] = "チャットパネルを閉じる"

-- ===== Leader portrait prose (ja_JP, polished) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WASHINGTON"] =
    "アメリカ合衆国初代大統領, ジョージ・ワシントンは, 板張りの室内に立つ. 左右に厚い赤いカーテンが引かれ, 両手は腰のあたりに自然と垂らされている. 衣装は18世紀末アメリカ紳士の黒い平服だ. 前面に真鍮のボタンを二列並べ, 太腿まで丈を取った暗い折り返し前コート, その下に揃いのウェストコート, 首元には白いフリルのジャボ, 手首には白い袖口が添えられている. 髪は白粉で白く整えられ, 高い額から後ろへ撫でつけ, 耳の上で側面を巻かせ, 後ろで黒い絹のリボンで結んだキューにまとめている. 左手には旋盤細工の木台の上に大きな地球儀が置かれ, その台の脇の小机の上には製本された書物が開かれ, 青いリボンの栞がページから垂れている. 右手には淡い石の炉棚に火の入っていない蝋燭を差した高い真鍮の燭台が立ち, その上方には金縁の額に入った風景画が掛けられている. 背後の開かれたカーテンの間からは, 溝彫りの柱が昼の光を背景に立ち上がり, 緑の起伏する田園が垣間見える. この構図は1796年のギルバート・スチュアートによるランズダウン肖像画を再現したもので, 儀礼用の剣と公式文書をここでは地球儀と書物に替えている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARUN_AL_RASHID"] =
    "信徒の長にしてアッバース朝第五代カリフ, ハールーン・アッ＝ラシードは, 午前遅い時間に宮殿の庭に腰かけている. 背後には石畳の中庭が広がり, 尖頭アーチの淡い石柱廊へと続く. その先の霞の中に遠い丸屋根が見える. 顎鬚を蓄えた黒髪の彼は, 腕置きの先が丸い飾りで終わる低い彫刻入り木製の椅子に座り, 頭には高いサフラン色のターバンを巻き, その頂に柔らかな丸帳が載っている. 同じサフラン布の幅広い帯が右肩から胸を横切り, 左腰にまとめられている. 帯の端には金の綴織と房飾りが施されており, その下には足首まで届くゆったりした白いローブを纏い, 裾には同じ金の綴織の帯が入っている. 右手は肩の近くに上げられ, 親指と人差し指でカラム, アラビアの葦ペンを持つ. 左手は膝の上に平らに置かれている. 足は青, クリーム, 錆色のメダリオン柄の円形の絨毯の上に乗り, その脇の石畳には2冊の装丁された写本が置かれており, 一番上のものは金で装飾された深紅の表紙だ. 椅子の両脇には釉薬をかけた青い鉢にソテツとシダが植えられ, 右手には高いテラコッタの壺が立っている. アーケードの下, 中景は暗い生け垣で閉じられている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASHURBANIPAL"] =
    "世界の王, アッシリア王アッシュルバニパルは, 宮殿の柱廊に立つ. 右手に淡い石板を垂直に胸へ押し当て, 指をその上縁に折りかけている. 肩幅が広く腕は剥き出しで, 光の中で肌が温かみを帯びる. 顎鬚は長く方形に切りそろえられ, 胸まで密な平行巻き毛に整えられ, 黒髪は同じように束ねた巻き毛として肩まで垂れる. 額には低い金のディアデムが巡り, その帯はロゼット文様で打ち出されている. アッシリア宮廷の踝丈の王室ショールを纏う. 金のロゼットをちりばめた濃い青の下着ローブの上に, 房飾りの縁を斜めに胴を横切り左肩を越えて背へと垂らした重いマゼンタのマントが重ねられ, その裾は金と赤の刺繍で縁取られている. 幅広の金の袖口が両手首を留め, 同様の帯が右の二の腕に巻かれている. 背後には細い柱に挟まれたアーチ形の壁龕が立ち上がり, 柱頭は淡い渦巻き形に仕上げられている. 左右の台座の上には, アッシリア宮殿の門を守ったラマッスの暗い有髭の像, すなわち人頭有翼牛の姿が据えられている. 奥の壁面には浅い石浮彫が横一列に馬を横顔で表し, ニネヴェの宮殿に見られる狩猟と戦車の壁板の様式に倣っている. 床は淡い敷き瓦で張られ, 廊下は両脇へ向かって影の中へ消えていく."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA"] =
    "神の恩寵によりローマ皇帝未亡人, ハンガリー, ボヘミア, ダルマチア, クロアチア, スラヴォニア, ガリシア, ロドメリア女王にしてオーストリア大公 (以下略), マリア・テレジアは, アーケード付きの石造りのロッジアに立つ. 高い円アーチが片側には雪をいただく山々のアルプス風景へ, 反対側には柱廊に沿って赤い絨毯が敷かれた磨かれた床へと開いている. 内壁のアーチの間には赤いダマスク織りのパネルが掛かり, 左からの陽光が石面に長い影を投げかけている. 彼女は四分の三の向きで立ち, 両腕は腰の前で軽く組まれ, 頭はわずかに横を向いている. 薄いブロンドの髪は後ろに引いて宮廷風に高くピンで留められている. ドレスは薄い青灰色のシルク製で, ボディスは腰でV字に締め上げられ, 前面には銀の刺繍と小さな宝石で飾られたスタマッカー, 硬い飾り胸当てが付いている. 幅広いパニエの上にフープスカートが広がり, アウタースカートの前面の割れ目に沿って同じ銀の刺繍の流れる帯が入っている. 袖は肘で終わり, 白いレースで縁取られた短いパフになっている. 透け感のあるレースのスカーフが肩に折りたたまれ, 衿元に差し込まれている. 冠はなく, 目立った装飾品もない. 背後では薄い石のアーチが奥へと続き, 轆轤引きの柱の手すりが遠くまで伸び, アルプスは明るく, 空は晴れ渡っている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MONTEZUMA"] =
    "メシカのウェイ・トラトアニ, モクテスマ2世は, 大きな火鉢の前に立つ. 炎は彼と見る者の間で燃え上がり, 広間はその炎だけに照らされている. 上半身は裸で体格は重厚, 火明かりの中で肌は黒く, 顔は半分が影に沈んでいる. 冠はケツァラパネカヨトル, 金の前立てで束ねた長い虹色のケツァル鳥の尾羽のかんざしで, 緑と青に輝く. 耳には金のスプールが貫かれ, 翡翠と金の首輪が首を巡り, 幅広の翡翠と金のカフスが手首を締め, 金の帯が両上腕を巻いている. 背後の赤い石造りの壁にはめ込まれた大きな彫刻円盤には, アステカの太陽の石を模し, 中央の顔の周りに同心円帯を成して象形文字が並んでいる. 両側の壁には定型化された頭蓋骨の列が刻まれており, これはアステカ神殿に陳列されたツォンパントリ, 頭蓋骨の架台だ. 各架台の上には大きく彫られたアステカの神の仮面が立ち, 各壁頂の石の壺からは高い炎が燃え上がっている. 広間全体が火明かりの赤と金に照らし出されている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NEBUCHADNEZZAR"] =
    "バビロンの王, ネブカドネザル2世は, 緑の光に照らされた石造りの広間の中, 巨大な石の玉座に座る. 背後の壁は影の中に遠ざかっている. 頭にはアグ, 新バビロニア王が用いた背の高い丸みを帯びた冠を戴き, その縁に金の帯が巻かれている. 顎鬚は長く黒く, 細かい管状の巻き毛が整然と段を成して結われている. ローブは深紅で半袖, 等間隔に金のロゼット文様が全体に散らされ, 腰は幅広の刺繍帯で締められている. スカートは裸足の足元まで真直ぐに落ち, 裾には淡いフリンジが帯状に縁取っている. 重い金の腕輪が両手首を留める. 両手は手のひらを下にして玉座の広い肘掛けに置かれており, 肘掛けの前端はライオンの頭の持ち送りの彫刻で終わり, 唸りを上げる口が膝の高さで外に向けられている. それよりも小さな一対のライオンの頭が, 足元の玉座の台座から突き出ている. 玉座の両脇には, 渦巻く蛇の胴体が刻まれた2本の背の高い石の台座が立ち, それぞれの頂上に幅広い浅い器が載り, そこから淡い緑の炎が立ち上っている. 広間の唯一の光源で, その病的な緑色が石の壁と彼の顔とローブを青白く染めている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PEDRO"] =
    "ブラジル皇帝, ペドロ2世は, 板張りの暗い書斎の幅広い木製の書き物机に座っている. 見る者が机の向こうから対峙するように場面が切り取られている. 年配の男性で, 肩幅が広くがっしりとした体格, 豊かな白い顎鬚が衿元より遥か下まで垂れ, 高い額から白く薄くなった髪が後ろに撫でつけられている. 暗いフロックコートを着て, その下に暗いウエストコート, 高い衿の白いシャツを合わせ, 喉元に暗いクラヴァットを結んでいる. 左胸には南十字星帝国勲章の宝石を散りばめた星章が留められており, 彼自身がその大勲長であった. 両手は机の上に平らに置かれ, 前には散らかった書類と小さなインク壺が置かれている. 右手のそばには丸いペン立てに羽ペンが1本真直ぐに挿さっている. 机の左手には, 透明な背の高いガラスの筒と磨かれた真鍮の台を持つ油灯が燃えており, その炎がこの絵の中で最も明るい点で, 彼の顔と手に落ちる光のほとんどを生み出している. 背後と左右の壁は床から天井まで本棚で埋め尽くされ, 深い影に沈んでいる. 左肩越しの高い窓は, 斜めに組まれた木製のブラインド越しに深い青の夜空の一片を見せ, ヤシの葉がシルエットとなって浮かんでいる. 画面の左端では小さな鉛組みのひし形格子窓が夕暮れの空の温かい色を映し, その下の棚には小さな置き時計が置かれている. 床は赤と金の落ち着いた色合いの文様の絨毯に覆われている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_THEODORA"] =
    "ローマ人の女帝, テオドラは, 開放的な柱廊の回廊テラスで金のブロケード地の低いソファに横たわり, 片腕を長枕の上に掛け, もう一方は膝の上に置いている. 頭には宝石を散りばめたステンマを戴く. ビザンティン帝冠の丸みを帯びたキャップで, その帯にはカボションの宝石が一列に嵌め込まれている. 額の目立つ位置に緑の宝石が据えられ, その上の頂点にはさらに金細工に留められた2つ目の緑石がある. 髪はその下に収められ, 右肩に長く流れている. ペンディリア, すなわちステンマの真珠の垂れ飾りが顔の両脇に揺れる. マニアキスが喉を一周し, 東方の帝国宝飾衿だ. 衣装は重ね着になっている. 体に沿った深紅の胴着は中央で金のメダリオンに留められ, 金と緑のシルクの渦巻き文様のスカートが膝の上に広がり, その下には細い金の縁取りが裾を飾る暗いティールの長い下着が覗く. 金の腕輪が手首を飾る. 背後の右手では重い赤いカーテンが引かれ, その向こうの情景を露わにしている. テラスは温かみのある石の床で, 赤い花を活けた壺を立てた彫刻の手摺り壁が縁を囲み, 2本の白い大理石の柱が眺望を縁取っている. 広い谷の向こうにハギア・ソフィアがそびえ, 幅広い中央ドームの両脇に低い半ドームが寄り添い, 日光の中で壁が黄褐色に輝き, その背後の低い丘が晴れた空の下に青く霞んでいる."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DIDO"] =
    "カルタゴの創建女王ディドーは, 夜の宮殿テラスに立つ. 背後の空は深い青で星が散り, 低い欄干の上の地平線には遠い岬がかすかに浮かぶ. 背後には湾曲した石のベンチが置かれ, その端にはスクロール文様の帯が彫られ, 背後には淡い柱が立ち上がっている. テラスの両脇では, 淡い石の植木鉢に植えられた大きな灌木が暗い葉と小さな赤い花を付けている. ラテン語名 punicum がカルタゴの木として刻むザクロである. 肌は白く, 黒髪は中央で分けて肩を過ぎて落ち, 細い金のディアデムが額に添えられている. 衣服は淡く白に近いキトン, すなわちギリシャ式チュニックで, 肩で留め腰に帯を締め, 床まで届くスカートには薄い織り文様が散っている. 短い割り袖は二の腕に沿って小さなブローチで留められ, 幅広の深青の帯が腰に巻かれてスカートの前に長く垂れ下がる. 喉元には金に嵌め込まれた暗い石の幅広ペクトラルが置かれ, 細い金の腕輪が片方の手首に巻く. 両手は体の脇に垂れ, 夜の光の中で周囲の石は冷たく静まっている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BOUDICCA"] =
    "イケニ族の女王ブーディカは, 丘上の砦の草に覆われた稜線に立つ. 左手には尖った杭の木柵を頂く石壁があり, その上から円形住居の円錐形の藁葺き屋根が顔を覗かせている. 右手には緑の丘陵が重い灰色の空の下へと続いていく. 髪は短く刈り込まれ, 鮮やかな赤銅色で, 頭の後ろで淡い布を結び, 肩の後ろへと垂らしている. 片方の目の下の頬骨に小さな濃い青の印がある, 古代ブリトン人が体彩に用いたウォードの染みだ. ケルトのトルクが, 撚り金細工の硬い輪として首に巡る. 衣服は青と緑の格子織りの袖なし膝丈チュニックで, 丸いバックル付きの革帯を腰に締めている. 革のヴァンブレイスが両手首に紐で結ばれ, 揃いの当て具が二の腕に巻かれ, ふくらはぎは低い革靴の上まで剥き出しだ. 左手にはラ・テーヌ様式の直刃両刃ショートソードを持ち, 刃は先へ向かって細く, 柄は小さく飾り気がない. 右手は芝に石突きを突き立てた槍の柄を直立に握る. 左隣には軽い二輪戦車が立ち, スポーク付きの一輪は鉄縁で, 荷台からは長槍の束が斜め上に突き出ている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WU_ZETIAN"] =
    "唐の皇帝, 武則天は, 薄暗い広間の中央に立ち, 両脇に重い赤いカーテンが引かれている. 背後には温かな金の提灯が暗がりに一列に並び, その奥の暗い壁には彫り格子の羽目板が嵌め込まれている. 黒髪は頭上に高く積み上げられ, 前面には金と真珠の飾りである歩揺で留められている. 重ね着した襦裙を纏っている. 内側の淡い金の絹の上着は胸元で重なり, その下に刺繍のメダリオンが入った硬い金のパネルがある. 胸の下に高く結ばれた鮮やかな赤の帯が, そのまま長いスカートとして床まで垂れる. その上には金の円形文様が入った深い赤の絹の外着を重ね, 幅広の袖が手を越えて垂れ, 裾は足元の床に広がっている. 腰の前で両手に小さな金の器を持ち, 捧げるようにわずかに持ち上げている. 肌は白く, 表情は落ち着き, 視線は穏やかだ. 赤いカーテン, 赤い衣, そして金の提灯が, 広間の暗がりに対して画面を温かく染めている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HARALD"] =
    "デンマークおよびノルウェーの王, ハーラル \"青歯王\" ゴームソンは, ロングシップの開かれた甲板の中央付近に立つ. 体躯は広く重厚で, 赤みがかった金色の顎鬚は二股に分かれて編まれ, 衿元より下まで垂れている. 口鬚は長く垂れ下がり, 頭は丸出しで, 髪は上に束ねてまとめられている. 肩には長い赤褐色の毛皮のマントがかかる. その下には暗い色のヨークが付いた緑灰色のチュニックを着ており, 裾と袖口にはノルウェー式の組紐文様を刻んだ飾り帯が入っている. 幅広の加工革のベルトが腰を横切り, 重い四角いバックルで留められている. 二本目の革帯は胸を斜めに走る. 両手はそのベルトの前面に置かれている. 足元の甲板には兜が置かれており, 暗い鉄製のドーム型で, 眉庇と鼻当てがあり, 両脇は厚い赤褐色の毛皮の丸みある耳当てに広がっている. 左手側では船の竜骨材が高い木製の渦巻き状に反り上がり, 竜頭を模した彫刻が施されている. 右肩の後ろではマストからロープが伸び, その上に赤と白の幅広い縦縞の帆が掛かっている. 舷側には丸い木製の盾が外向きに取り付けられ, 中央に鉄のボスがある. 空は広く青く, 高層の雲がたなびいている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMESSES"] =
    "両国の王, ラムセス2世は, 短い階段の頂上に置かれた王座に腰を据えている. 左右には青く塗られた高い柱が立ち並ぶ広間が広がっている. 顔は若く, 髭は剃られており, 肌は深い青銅色, 目の縁には暗いコールが引かれている. 頭飾りはネメスで, 金と青の縞模様の頭布がこめかみに密着して折りたたまれ, 胸まで垂れる折り返し部分を作っている. 額にはウラエウス, 王権の証たる立ち上がるコブラが付いている. 肩と胸には, 金とラピスラズリの青のビーズを何列も重ねた幅広の首飾りであるウセクが広がっている. 下半身にはシェンドゥト, 長い白い亜麻布の王家のひだ付きキルトを纏い, 腰は金と青の幅広のサッシュで締められ, 前に固い模様入りのパネルが垂れている. 足はサンダルを履いて最上段の段に置かれている. 左手には肩に寄り掛けるように高い杖を持ち, 右手は王座の肘掛けに乗せている. 両脇の柱は青, 金, 赤の横段に彩色され, 柱頭はパピルスの束の形に象られ, ヒエログリフや立像の列が刻まれている. 王座の前の両脇には, 保護の女神イシスとネフティスの大きな黄金像が立ち, 翼を広げて前に向けている. 羽根は長い金箔の刃の形で描かれている. 両脇からはナツメヤシの葉が差し込み, 足元の黄色い石の階段には小さな三角形の模様が列をなして刻まれている. 広間全体は暖かな金色の光に包まれ, 柱と首飾りの青だけが唯一の冷たい色調として浮かび上がっている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ELIZABETH"] =
    "神の恩寵によるイングランド, フランス, アイルランド女王, 信仰の守護者エリザベス1世は, 石の台座に蝋燭立てを両脇に従えた高い彫刻玉座に腰を下ろしている. 蝋燭はまだ灯されていない. 背後には国家用の天蓋が立ち上がり, 金の房付き紐が重い赤いビロードを折り重ねて引き留め, 奥の間の暗がりがかろうじて見える. 髪は赤みがかったブロンドの密な巻き毛として高く積み上げられ, 小さな宝石付きコローネットで留められている. 襟はテューダー朝後期の宮廷に見られる硬く開いたラフである. 衣服は黒の刺繍が施された金のブロケードで, ボディスは体に添い宝石で飾られ, 袖は肩で膨らみレース袖口へと細くなり, スカートはファーシンゲールの上に広く張り出している. 長い真珠の連なりが胸を横切り腰から吊られている, 当時の純潔の徴として身に付けられたものだ. 青白い両手は玉座の肘掛けに静かに置かれている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SELASSIE"] =
    "エチオピア皇帝, 神の選びし者にしてユダ族の征服者なる獅子, ハイレ・セラシエ1世は, 宮殿の長い謁見の間に立つ. 頭上には淡い色の格間天井が広がり, 右手には背の高い窓が並び, その間にクリスタルのシャンデリアが吊り下がっている. 細身で背筋が伸び, 黒い顎鬚を生やし, 髪は短く刈り込まれている. 喉元まで釦を留めた暗い軍服のチュニックを着て, 飾り気のない暗いズボンを合わせ, 幅広の黒い革のウエストベルトを締めている. 右肩から左腰にかけて, ソロモンの印章勲章の幅広いエメラルドグリーンのモアレ地の飾り帯が斜めに走る. 左胸の高い位置には4列のミニチュアリボンが集まり, 在位中に積み重ねた戦役勲章と功績章だ. その下には高位の帝国勲章の大型の胸章が2枚下がり, 八角形で金とエナメルによる細工が施されている. 左手は体の脇に垂らし, 右手は手袋を1組持っている. 左手には帝国の玉座が置かれている. 淡いクリームと青の張り地をした高背の椅子で, 頂上にはアーチ型の冠が彫られ, 刺繍の布が掛けられており, 広間の端まで続く赤い文様の絨毯の上に据えられている. 背後の壁に沿って淡い張り地の椅子が並び, 奥へ向かって連なっている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_NAPOLEON"] =
    "フランス皇帝, ナポレオン・ボナパルトは, 薄暮の中, 枯れ草の野原で灰白色の馬に跨っている. 背後には赤褐色の空と葉を落とした木々が広がっている. 彼は重い金のエポーレットの付いた紺色のコートを着て, 白いウェストコート, 白い乗馬用ズボン, 丈の高い黒い乗馬ブーツを履いている. バイコーン帽は横向きに被られ, 両端が肩の方を向いている. これは彼が部下と区別するために好んだ被り方だ. 馬の馬勒は金鋲を打った赤い革で, 下の鞍覆いは赤と金で縁取られている. 構図はジャック・ルイ・ダヴィッドの「アルプスを越えるナポレオン」を想起させるが, 静止している. 立ち上がる軍馬もなく, 指し示す手もなく, ただ黄昏時の風景の中に一つの人影があるだけだ."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_BISMARCK"] =
    "プロイセン首相, ドイツ帝国初代宰相, ビスマルクは, 背後の鉛格子窓から昼の光が差し込む高天井の公式の間に立っている. 窓ガラスはそれぞれ細いサッシで小さな正方形に区切られている. 重いクリムゾンのドレープが各窓に大きく束ねて留められ, 裏地はさらに深い赤だ. 床は鏡のように磨き上げられ, 窓からの光を細長い淡い帯として映している. 彼の左手には小さなサイドテーブルがあり, 白い球形のランプが置かれている. 彼は背が高く肩幅が広く, 頭頂部は禿げており, 側面と後頭部には銀灰色の短い毛が残っている. 口には長く両端を外へ撥ね上げた白い大きな口髭を蓄えている. 軍用フロックコートは濃い石板色の縦縞のダブルブレスト仕立てで, 胸に金ボタンが二列並んで留められ, 立ち襟も金で縁取られている. 肩には重い金のブリオン・エポーレットが付き, その飾り房が上腕まで垂れている. 襟のすぐ下には暗色のリボンに小さな淡い十字章, プロイセン最高の武功勲章プール・ル・メリットが下がっている. 彼は四分の三ほど視者の方を向いて直立し, 視線は視者の肩の向こうに固定されている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ALEXANDER"] =
    "マケドニア王にしてヘレネス同盟の盟主, アレクサンドロス3世は, 愛馬の漆黒の牡馬ブケファロスにまたがり, 左右に灰色の山並みが連なり右手に雪を頂く峰がそびえる緑の高原の草地でその手綱を引いている. まだ若く顎鬚はなく, 褐色の髪は中央で分けられ, 額から上方に立ち上がるアナストレを形作っている. これは彼の肖像画の特徴となった前髪の立ち上げである. 身につけているのはリノトラックス, ヘレニズム時代の亜麻と革を重ねた胴鎧で, 金箔の板で覆われ, 肩のくびきが短い紐で胸に結びとめられている. 胸の中央には四角い金の飾り板にゴルゴネイオン, すなわちメドゥーサの首の浮き彫りが刻まれている. 肩と腰帯から下にはプテルゲスが垂れている. 上腕と腿を守る硬化した革の帯が並び, 各帯の縁は赤く金のスタッドが先端に打たれている. 両腕は素肌で, 右手首には幅広の金の腕輪をはめているが, 兜はかぶらず目に見える武器も持っていない. 馬の馬具は赤い装飾を施した黒革で, 額带と頬飾りには鋲が打たれ, 首に沿って一本の手綱が左手に引かれている. 鞍の下には斑点模様の豹の毛皮が馬の脇腹に掛かり, 前脚がまだついたままになっている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ATTILA"] =
    "フン族の王, アッティラは, 一段高い台の上に置かれた高背の木製王座に座り, 周囲の広間は深い赤と金の光に満ちている. 余裕の様子で背もたれに寄りかかり, 片足を反対の膝に乗せ, 抜き身の剣が膝の上に横たえられている. 片手は刀身の上に置かれ, もう一方の手は杯を持つ. チュニックは赤く長袖で縁は金色, 紺のズボンの上に着てブーツに裾を差し込んでいる. ブーツの折り返しには毛皮の縁取りがある. 頭には金の帯を飾った暗い毛皮の円錐形の帽子をかぶっている. 顎鬚をたくわえ長い口髭を生やし, 顔は右から差す光で半分だけ照らされている. 王座の肘掛けの先端はライオンの頭の彫刻で終わり, 背もたれには重い毛皮が掛けられている. 背後には赤い垂れ幕の壁があり, その両脇には大小様々な丸い銅の円盤を掛けたパネルが並び, 炎の光がその中で輝いている. 台の右手には背の高い鉄製のろうそく立てに1本の蝋燭が燃えている. その先の床には大きな真鍮の器が置かれ, 鞘に納まった剣の柄が林立している. さらにその奥では, 開いた木箱から硬貨が文様のある絨毯の上にこぼれ落ちている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACHACUTI"] =
    "タワンティンスーユのサパ・インカ, パチャクテク・インカ・ユパンキは, マチュ・ピチュを見下ろすテラスの高い石の玉座に腰を下ろしている. 玉座には金と赤で浮かび上がる連続幾何学文様の列が彫り込まれている. 右上方の石柱に固定された大きな金の太陽円盤は, 外へ放射する光線の輪の中央に様式化された人の顔を示している. 左手には岩峰が険しく聳え立ち, 下方の段々農耕台地には低い藁葺き建物が並んでいる. インカの主権の象徴として額に垂らす赤い毛糸の房飾り, マスカパイチャを身に付け, 多色の鉢巻きであるジャウトゥで束ねられ, 直立した赤と暗色の羽根の束を頂く. 髪は黒く肩まで届く. 首には重い金の円盤ペクトラルが掛かる. チュニックは袖なし膝丈の衣で, 大胆な白黒の格子文様に胸に赤と金のヨークが入っている. 膝より下には赤い房付きの紐が脚に巻かれている. 右手には金の鳥の像を頂く高い杖を持ち, その柄には段状の赤い房飾りが吊るされている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GANDHI"] =
    "インド独立運動の指導者, マハトマ・ガンディーは, 乾いた黄色い草と岩の岬, そして淡い海が広がるインドの海岸に立つ. 痩身で頭は禿げ, 眼鏡をかけ, 短く刈り込んだ灰色の口髭を生やしている. 晩年に親しんだ服装を身につけている. 腰に巻いた飾り気のない白いドーティ, 片方の肩から反対の腕の下に掛けられたショール, そして胸は素肌のままだ. 布は無染色の手紡ぎで, 英国製の布を意図的に拒絶した行為であり, 彼の運動の象徴となった. この情景は, 独立闘争の中で彼が海へ向かって歩き続けた長い旅路を想起させる. 亜大陸の果てに立つ, 孤独な人影だ."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GAJAH_MADA"] =
    "ジャワのマジャパヒト帝国の宰相, ガジャ・マダは, 緑の低い畦の間で鏡のように輝く水を湛えた田んぼの縁に立つ. 背後では鬱蒼とした熱帯雨林が淡い霧に包まれた丘を這い上り, その霧の中からチャンディの細い階段状のシルエットが浮かぶ. 赤煉瓦の寺院塔で, 重なる屋根は雲の中に溶け込んでいる. 肩幅が広く, 上半身は裸で, 黒い髪を束ねてまげに結い, 顎に小さな鬚の房がある. 両腕と両手首には金の腕輪が巻かれている. 腰には幅広の帯が高めに締められ, マジャパヒット様式の花の文様が施された大きな扇形の金の飾り板で留められている. 帯の下には赤いサロンが前で結ばれて巻かれ, その折り目が重い布の帯状に垂れ, 裾からは黄色い下着が覗く. 右腰には帯を通した紐に吊り下げられた鞘入りのクリスが下がり, 黒い木製の鞘は細く尖り, 柄が斜めに前に突き出ている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_HIAWATHA"] =
    "ハウデノサウニー連盟の創設者, ハイアワサは, 陽の差す空き地に立つ. 肩の高さに大きな灰色の岩が迫り, 細いブナとシラカバの幹が背後の緑の下草の中へと続いている. 上半身は裸で引き締まっており, まだら模様の光の中で肌は温かみのある褐色に見える. 髪型はスカルプロックで, 頭の両側は短く剃られ, 頂上には黒い髪の細い尾根が前から後ろへ走り, 後部に2本の羽根が垂直に挿されている. 両上腕には濃い色の絵具の帯が巻かれている. 喉元には白い貝殻ビーズを密に通したチョーカー, ワンパムが付けられている. 右肩から左腰へ一本の帯が胸を斜めに横切り, 矢羽根の端が肩の上に突き出た矢筒を支えている. 腰には薄い褐色の鹿革のブリーチクロスが長い前垂れとして太もも中ほどまで下がっている. 房付きの鹿革のレギンスが足首から膝まで脛を包み, 膝下で結ばれ, 大腿部はブリーチクロスが覆う形で開いたままだ. 素足で空き地の踏み固められた地面に立ち, 両腕は体の脇に垂らし, 森の光が右側に降り注いでいる."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ODA_NOBUNAGA"] =
    "織田氏の大名, 天下統一の先駆者, 織田信長は, 丈の高い草と白い石が点在する起伏ある緑の野に立っている. 積み重なる雲の広がる明るい空の下, 青い山並みが地平へ遠ざかっている. 頭は月代の形に剃られており, 兜が安定して被れるよう額と頭頂部が剃られ, 残った髪は後ろに束ねられている. 口には短い口髭と顎鬚を蓄えている. 甲冑は当世具足で, 戦国時代の新式の鎧だ. 漆塗りの鉄板が絹の威毛で横一列に綴じられ, 胴と草摺は紺と朱の交互の段で結われている. 肩の大袖も同じ威毛で綴じた板が腕に覆い被さっている. その上に袖無しの薄茶色の陣羽織を羽織り, 前の合わせ目は開いて下の胴の威毛が見えている. 腰には幅広の赤い帯が結ばれ, 刃を上にした刀が差してある. 右腰にはもう一振りの刀が下がり, 右手はその柄に添えられている. 合わせて大小, 全ての武士が携えた長短二本の刀だ. 右肩の後ろから背にかけて, 長く黒い台木と細い銃身の種子島が担がれている. 信長が大量普及させたことで知られる火縄銃だ. 草と石と遠山だけを周りに, 彼は広野に一人立っている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SEJONG"] =
    "朝鮮王朝第4代王, 世宗大王は, 玉座の間の高い木製の台座の中央に座り, 両手で開いた書物を膝の上に持っている. 着ているのは袞竜袍, 朝鮮の王が纏う赤い絹の龍袍で, 胸と肩には四爪の龍の金丸紋が施され, 金の唐草文様で縁取られている. 腰には幅広い翡翠帯が締められている. 頭に載るのは翼善冠, 後ろから折り畳んだ葉のように小さく折り返した2枚の翼が立つ, 硬い黒い薄絹の帽子だ. 顎鬚はきれいに整えられた細い口鬚と顎先の短い鬚を除いて剃られている. 背後には日月五峰図, 朝鮮の玉座すべての後ろに置かれる日月五峰の折り畳み屏風が立つ. 王は女王の月に対する太陽とされた. 左上に白い月の円盤, 右上に赤い日の円盤, 深緑の険しい峰々, そして下部には暗紅色の松が広がる. 玉座そのものは赤く漆塗りで, 側面の板には虎のメダリオンが彫られている. 赤漆塗りの手すりと柱が台座の両脇を縁取り, 広間の端には紙製の行灯が黄色く光りながら下がっている. 短い石段が見る者に向かって降りている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_PACAL"] =
    "バアカルの聖なる王, パレンケの神聖な支配者, キニチ・ハナーブ・パカルは, 真昼, 石灰岩の宮殿のテラスに立っている. 首都の背後にはジャングルから階段状のピラミッド型神殿が幾つも聳え, 屋根冠の彫刻は風雨に晒されて淡い薔薇色に変わっている. 背後の肩の広がりには大きなバックラックがある. 緑, 青, 深紅の帯状に並ぶケツァールの尾羽を扇状に広げた木枠で, 彫刻と彩色のグリフが入った長方形のプレートの上に取り付けられている. 頭飾りは高く重なった段形で, さらにケツァールの羽根で冠されている. 長く黒い髪が肩まで垂れている. 胸には彫刻を施したヒスイの板を並べた幅広の首飾りが置かれ, 中央には四角いヒスイのペクトラルが下がり, 耳朶にはヒスイのイヤーフレアが通されている. ビーズのベルトが結んだ布と羽根のキルトを腰で束ね, 膝丈の長い羽根のフリンジが両脇に垂れ, サンダルはふくらはぎの高いところまで紐で縛り付けられている. 左手には, 小さな彫刻された雷神の頭を頂く高い杖, カウィールのマニキン・セプターを握っている. マヤの支配者が王権の証として掲げた神像だ. 彼の左手, テラスの端には幅広の石の火鉢が立っており, 縁には焼けた供物の残滓が並んでいる. 都市は霞の中に遠ざかり, 幾段にも積み重なるピラミッドが川の平原へと降りていく."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GENGHIS_KHAN"] =
    "モンゴルの大ハーン, チンギス・ハーンは黒い馬に跨り, 広大な草原に腰上だけを見せて, 見る者に対して四分の三ほど向いた姿で座っている. 兜は高い円錐形で鋭い頂飾りへと伸び, 暗い前当てと頬当てが細い口髭と顎の小さな髭を縁取る. 鎧は鋲留めのモンゴル騎兵具で, 胸には渦巻き文様を打ち出した大きな円形の青銅盾飾りが目を引き, 幅広の肩当てが肩を覆い, 鋲打ちの帯が二の腕に巻かれている. 暗いクロークが肩から落ち, 鞍の後ろへ垂れる部分の裏地が落ち着いた紫色を見せている. 馬具は素朴な革製で, 額当てと前で束ねた手綱だけの単純な轡である. 背後には低い緑の丘が淡い曇り空の下に連なり, 中腹にはゲルの野営地, すなわちモンゴルの円形白色フェルトテントが立ち並び, 周囲の草地には白っぽい家畜の点が散らばっている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AHMAD_ALMANSUR"] =
    "モロッコのサアード朝スルタン, アフマド・アル＝マンスールは, 深い青空のもとサハラの野営地の端に立つ. 地平線の低い暗い山並みの上に, 細い三日月と散らばる星が浮かぶ. 顎鬚をたくわえ, ランプの光に肌が暖かく照らされ, 視線は真直ぐ見る者に向けられている. マグレブの重ね着を身につけている. 足首まで届くフード付きの長い白いジェラバ, 北アフリカの長衣. その上にセルハムを羽織っている. 王侯貴族の上質なウールのマントで, フードは肩甲骨の間に垂れている. 頭には白いターバンが巻かれている. 胸元にはクリームと金の長方形の刺繍パネルが下がり, イスラム装飾の幾何学的な組紐模様が施されている. 赤とクリームの縦縞が交互に並ぶ幅広の帯が腰に二重に巻かれ, 前で結ばれ, 端は折り込まれている. 背後の左手には, 暗い縞模様の布でできた大きな丸みを帯びたキャラバンテントが内側から光を放ち, 開いた入口の布が温かいオレンジ色の光を砂の上に零している. 2頭のラクダがその傍らで砂の上に伏せている. さらに遠くに小さな灯りが燃え, ナツメヤシの木立が丘を背にそびえている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_WILLIAM"] =
    "オランダ独立の父, オラニエ公ウィレム1世は, 左側に高い鉛組みガラス窓が光を入れる石畳の室内に立つ. 小菱形のガラス格子は重い赤い垂れ布を脇へ引いた縁に囲まれている. 床は黒白の大理石方形が敷き詰められている. 背後の奥壁には金縁の風景画が掛かり, 重い空の下の低地の国を描き, 川が平坦な緑の野を蛇行して遠くの町へ向かっている. 右手には木製の腰掛けに地球儀が置かれ, 真鍮の子午線環が窓の光を受けている. 左手には赤い布を掛けた書き物机に革張りの開いた書物と散らばった紙が乗り, 背後には青い布張りの背の高い椅子が立っている. 室内全体はフェルメールの「地理学者」と「天文学者」の学者部屋を思わせるが, ウィレムはその様式より一世代前の人物だ. 中年の髭の男で, 小さな平らな帽子の下で暗い髪は短く刈られ, 口髭と二又に分けた顎鬚は整えて短い. 喉元では幅広の白いひだ飾りのラフが広がっている. 長い黒いクロークが肩から掛かり, 腕を自由にするため右側で押し退けられている. ダブレットは落ち着いた金の文様絹で胴に沿い, 前面は一列のボタンで留められている. ズボンはパンド・トランク・ホーズで, 赤と白の布の長い縦縞が交互に並んだ豊かな裏地付きの構造で, 太腿の中ほどで終わっている. 素朴な暗い靴下が下腿を覆い, 市松模様の床の上で低い革靴と続いている. 右手には胸の高さに職権の指揮棒を持ち, 左手は腰の脇に置かれ, クロークの垂れの下から剣の柄がかろうじて見えている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SULEIMAN"] =
    "壮麗王にしてカヌーニー, 立法者, オスマン帝国スルタン, スレイマン1世は, トプカプ宮殿のリブ付きドームの下に立つ. 青と白のイズニック・タイルで覆われた尖頭アーチの広間だ. 見えない窓からの陽の柱が背後の淡い石柱に降り注いでいる. 顎鬚を持ち目は黒く, 細い口の周りで口鬚と顎鬚は短く整えられている. ターバンはカヴーク, 彼の象徴として知られた高い丸い型で, 円錐形の骨組みに白い布を幾重にも巻き付け, 眉の遥か上まで積み上がっている. その頂にはソルグッチ, スルタンの位を示す緑の羽根飾りが立つ. 内側のローブの上には蔓と薔薇の薄い文様を織り出した黄色の絹のカフタンを羽織り, 前面は腰まで開いている. 柔らかな灰色の毛皮の幅広の帯が全長を飾り, これがカパニチェ, 最上位の礼服であることを示す. 濃い色の帯がカフタンの腰を横切る. 右手は胸の前に立てて持ち, 暗い革で装丁された一冊の書物を握っている. もう一方の手は体の脇に垂らしている. 背後の広間はタイル張りのアーチの間の影へと消えていく."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_DARIUS"] =
    "アケメネス朝ペルシャの王の中の王, ダレイオス1世は, 大広間の先, 低い階段の頂上に立っている. 上方から一筋の光が彼に降り注ぐ. 彼は肩幅が広く, 長くて四角く切り揃えられた顎鬚をびっしりと巻き込むように整えている. 頭には, ペルシャ王の高い角張った王冠であるキダリス, すなわち正方形の垛列で縁取られた金の円筒形の冠を戴いている. 衣は足元まで届く長いサフランイエローのガウンで, 胸, 袖口, 裾には赤と金の刺繍が帯状に入っている. 腰は赤いサッシュで束ねられている. 上腕にはそれぞれ重い金のアームレットが嵌められている. 彼の両脇の台座には, 巨大なラマッスー, つまり翼を持つ牡牛が一体ずつ聳え立ち, 胴体と折り畳まれた翼は金で覆われている. ペルセポリスの万国門を守る番人像だが, ここでは人間の頭部を持つ版の代わりに牡牛の姿だけが表わされている. 奥の壁には, アパダナ大階段の朝貢者浮き彫りを模した行列の浮き彫りが施されており, 人物たちは長いローブと柔らかな帽子を身に着けている. 台と階段の石は淡い青緑色で, 四隅には金のボスが嵌め込まれている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CASIMIR"] =
    "ポーランド王, ピャスト朝最後の王, カジミェシュ3世は, 石造りの城門の入口に立っている. 壁に取り付けられた鉄のスコンスの炎が, 石積みの壁に暖かい赤金色の光を投げかけている. 彼は肩幅が広く, 濃い色の顎鬚を短く整えており, 視線は真っすぐ前を向いている. 王冠は赤い宝石をちりばめた金のアーチ型の輪で, そのアーチが上部で宝飾の飾り先端に収まっている. 肩には幅広い白いアーミンのティペットが掛けられ, 毛皮には小さな黒い尾の斑点が入れられている. その下に纏うマントは, 胸に小さな金のスタッドが一列に並んで留められた長い深紅色のローブで, 腰には幅広の金箔のベルトが締められている. 片手には黄金の笏を胸の前に垂直に持ち, 腰には国家の儀礼用剣シュチェルビェツが下がっている. 彼の左右では重い鉄の鎖が城門内側の壁面に沿って上の暗闇から垂れている. 背後の奥, アーチの中に設けられた赤いパネルには, ポーランドの白鷲, 翼を広げた戴冠した鷲が描かれている. 鷲は本来の銀ではなく, 赤地に暗いシルエットで描かれている. 石はどっしりと組まれ, 光は王の上に集まり, 両脇の暗い丸天井へと急に落ちて消えていく."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_KAMEHAMEHA"] =
    "ハワイ諸島の統一者にして王国初代モイ, カメハメハ大王は, 白砂のビーチに素足で立つ. 背後には入り江の青緑色の浅瀬が広がり, さらに奥には緑深い山の尾根がそびえる. 長身で体格はがっしりとしており, 上半身は裸で, 熱帯の陽光に照らされた肌は深い褐色だ. 片肩にはアフウラ, ハワイのアリイの羽根マントが掛かり, 深紅色で足首近くまで垂れている. 同じ赤色の幅広い帯が左肩から胸を横切り, 黄色の縁には小さな赤の幾何学模様のブロックが入っている. 腰に巻いたマロ, 腰布の前面には赤と黄色の対になったパネルが垂れている. 頭にはマヒオレ, 低いとさか付きの兜が載り, 前頭部から後頭部へ向かって細い前後方向の尾根が走り, 赤地に黄色の縞と黄色の縁帯が施されている. 右手には高い木製の槍を持ち, 槍先には返しが付いている. 左腕は体の脇に垂らされている. 右手側の砂浜には2艘のワアカウルア, ポリネシアの双胴航海カヌーが引き上げられており, 二つの船体は縛り付けた横梁で繋がれている. 帆は三角形で, マスト根元に頂点があり, 上端は長いU字型に外へ弧を描く. 帆布は薄く継ぎ当てが施されている. もう1艘は湾の沖合に錨泊している. 左肩後方の岸辺にはハレ, 柱骨組みと干し草葺きの屋根のハワイ式家屋が立ち, ヤシの葉陰に半分隠れている. 尾根の上の空は高い白雲を浮かべた青空だ."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_MARIA_I"] =
    "ポルトガル, アルガルヴェ, および海外のポルトガル領土の女王, マリア1世は, シントラのペナ宮殿のテラス, 重いロマネスク式のアーチが並ぶ列の下の淡い石造りの回廊に立っている. 列柱の向こうに大西洋が広がっている. 彼女のガウンは深い青のシルクだ. ボディスは先のとがったウェストラインで体に沿い, 肘丈の袖の先は白いカフスで仕上げられ, スカートはパニエで膨らんで石の床まで広い褶曲をなして落ちている. 短い赤いケープが肩に留められ, 後ろに引いている. 胸には幅広い白いサッシュが赤い縁取りと共に斜めに走っており, ポルトガル君主が総長として纏うキリスト騎士団のサッシュだ. その前面には宝石飾りの帯が縦に入っている. 黒い髪は高く結い上げ, 額の上に積み上げてエグレット, 小さな黒の飾りと一本の直立した羽根で留めている. 右手はスカートの青に沿って垂れる細い笏の柄頭に添えられている. 彼女の右手側, バルストレードの向こうには, 赤い断崖の間を細い入り江が走っている. 帆を畳んだ横帆のナウが2隻, 水路に碇を下ろしている. 左手には, 金と彩釉タイルの帯で飾られた丸みを帯びたドームを頂いた黄色い壁の主塔が聳えている. 角垛の付いた黄色い城壁が彼女の立つテラスへ向かって段々に降りてくる. 空は晴れており, 明るい大西洋の午後の光の中で, アーチが彼女を一方は水, 他方は王家の建築と共に縁取っている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_AUGUSTUS"] =
    "ローマ初代皇帝, アウグストゥスは, 二つの青銅製スフィンクスの頭像の間に置かれたクルレス式の席に腰かけている. スフィンクスの滑らかな面は外側を向いている. 彼は髭を剃り, 短い黒髪を額の上に梳きつけている. プリマ・ポルタ像の伝統に倣った前髪の形だ. 白いトゥニカの上には, ローマの凱旋式で纏う儀礼用の紫のトガ・ピクタが巻かれ, 膝を覆って左肩の上まで引き上げられている. トゥニカの襟ぐりは金縁で縁取られている. 右手はスフィンクスの頭の一方に開いたまま置かれ, 左手は膝の上にゆるく添えられている. 背後には暗紅色の壁が続く薄暗い広間があり, 縦溝付きの柱が並び, 赤と金の縦長の旗が下げられている. 奥の壁には円形の青銅の飾り板が掲げられ, ライオンの頭が浮き彫りにされている. 左から差し込む淡い日の光が顔と胸を照らし, 広間の反対側は影に沈んでいる. 玉座の両脇には鉄の脚台に載った小さな火鉢が二つ, 低く燃えている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_CATHERINE"] =
    "全ロシアの皇帝にして専制君主, エカチェリーナ2世は, ツァールスコエ・セローにあるエカチェリーナ宮殿の大広間, 光の間に立つ. 体は見る者に対して四分の三の角度で向けられ, 視線は水平だ. 黒髪は上に高く結い上げられ, 18世紀後半のヨーロッパ宮廷の流行に倣っている. 頂上には小さな宝石飾りの冠が留め, その尖端はロシア大帝冠の花飾りアーチを小型で模したかのように見える. 衣装は象牙色のシルク製の宮廷服で, 前面の中央に金の刺繍を施した胴着は体に沿い, 深い青の膨らんだ半袖の肩口は白いアーミン(ホワイトウィーゼル)の帯で縁取られている. 下に広がるスカートにはロシア皇室の双頭の鷲が金の刺繍で繰り返し散らされている. 右肩から左腰にかけて, 聖アンドレイ一等勲章の淡い青のモアレ地の幅広飾り帯が斜めに走る. 右手の壁に沿って背の高いアーチ窓が並び, 淡い青いカーテンがスワッグ状に引き上げられ, 鏡のように磨かれた白黒の大理石の床に日光の筋がくっきりと差し込んでいる. 左の壁には金を施した渦巻きと葉飾りのロカイユ彫刻が続き, 鏡のパネルを縁取っている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_POCATELLO"] =
    "北西ショショーニ族の首長ポカテロは, 山間盆地の縁に積まれた風化した赤い岩塊の上に腰を下ろしている. 背後にはセージブラシの平坦な平原が伸び, 薔薇色と淡い紫の夕暮れ空の下, 低いメサがシルエットとなって地平線に並ぶ. 肩幅が広く, 長い黒髪は中央で分けて胸まで落ち, 後頭部に一本の鷲の羽根が直立して固定されている. もう一本の暗い羽根が背中に括り付けたクイバーの上から肩の後ろへ立ち上がっている. 短い木弓がクイバーに並べて肩から斜め掛けされ, 上端が右肩の上に突き出ている. 右手には岩に石突きを当てた長い槍を持ち, 柄は皮で巻かれ穂先近くに暗い房が垂れている. 胴には毛皮のベストを纏い, なめし皮の幅広の帯が右肩から左腰へとビーズ細工の列を刻みながら斜めに走り, その下端には短いナイフの鞘が吊るされている. 二の腕には銀の輪が積み重なって巻かれている. 腰より下は踝まで届く暗い房付き皮革のレギンスを穿き, その間にブリーチクロスを挟む. 左手は太腿の上に開いたまま置かれ, 体は静止し, 重みは石の上に落ち着いている. 光は低く温かく, 岩の赤と槍の縁を照らし, 彼の向こうに広がるのはグレートベースンのセージブラシ地帯, ロッキー山脈とシエラの間に広がるショショーニの故郷だ."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_RAMKHAMHAENG"] =
    "スコータイ王, ラームカムヘーン大王は, 陽光の射す宮殿の庭に立つ. 背後には熱帯林の緑の霞と, タイの仏教ストゥーパである釣り鐘形のチェディの淡いシルエットが低い霧の中から立ち上がっている. 体は細身で上半身は裸, 肌は温かみのある褐色で, 顔はわずかに左へ向き, かすかな微笑みを浮かべている. 冠は高く, 段を重ねて尖り, 細い尖塔へと伸びる, タイ王の円錐形冠チャダーである. 幅広の金のペクトラル・カラーが肩と胸にかかり, スクロール文様の打ち出し細工が施され, 中央に一つの赤い石が嵌め込まれている. より細い金の帯が各二の腕を留めている. 白い絹の帯が腰に巻かれて結ばれ, 捻れた端が太腿まで垂れる. その下には金の文様が入った深い赤の巻き布を纏い, 裾には暗い下着が見えている. 右手には, ピンクの蓮の花と広い平らな葉が散る静かな池の縁に, 小さな石像が立つ. 目を伏せた穏やかな仏頭が蓮のつぼみの台座に乗せられたものだ. 左手へは赤い花を咲かせた灌木の間を淡い砂の小道が弧を描いて遠ざかり, 霞む首都の塔へと続いていく."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ASKIA"] =
    "ソンガイのアスキア・モハメッド1世, 偉大なるアスキアは, 夕暮れ時の岩がちな崖上に立つ. 長い剣を肩に担ぎ, 背後には炎上する都市がある. 肌は黒く, 顎鬚は短く刈られ, 視線は正面に向けられている. 頭にはタゲルムスト, サヘル地方の薄いクリーム色のターバンを高く巻き, 片側に寄せてまとめている. 肩からはブブー, 西アフリカ貴族の広袖のローブが深紅色に垂れ落ちる. その前面と胸元には金糸と濃い色の糸による緻密な文様の刺繍帯が施されている. その下では薄い帯が腰に巻かれ, 結び目から端が腰の脇にゆるく垂れている. 袴はローブと同じ深紅色だ. 右手は柄を握り, 刃は肩に沿わせて後方へ傾けている. 刀身は長くほぼ直線で, 切っ先に向かってわずかに反っている. 右手側では大地が広がって赤橙色の空の下の平原へと落ち込み, 低い太陽を背に黒い山が浮かぶ. 左手側では都市が燃えている. 日干しレンガの壁, 横木のトロンが列をなして突き出た高い四角いミナレット, 漆喰から突き出したままのヤシの梁. 炎は塔を這い上がり, 眼下の通りに広がる. 小さな火も彼の立つ崖と都市の間の平原に点在している."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ISABELLA"] =
    "カスティーリャおよびレオンの女王, アラゴンの王妃, イサベル1世は, グラナダのアルハンブラ宮殿の柱廊の一角に立っている. 列柱のアーケードは, 刈り込まれた生垣と鉢植えの庭木が並ぶ庭園へと開き, その先の丘は霞の中に消えている. 彫刻された柱頭を持つ細い対の柱が背後に立ち, 透かし彫りで埋められた葉形と扇形のアーチへと伸び上がっている. アーチの上のスパンドレルには, 淡い金と砂色の幾何学模様と植物模様の濃密な漆喰彫刻が刻まれている. 彼女は細身で色白く, 両手は腹の前で重ねられている. 頭は宮廷のカスティーリャ風に覆われている. 顎の下から喉にかけて白いウィンプルが被せられ, その上に白いヴェールが頭頂部を覆い, さらにその上に赤と緑の宝石をはめた小ぶりな閉じた金の冠が載っている. 肩には金の裏地と縁取りの長い赤いマントが掛かり, 前は開いている. 下に纏うガウンはクリーム色のブロケードで, 暗い繰り返し模様が織り出され, ボディスは体に沿い, スカートの中央には金縁のパネルが縦に走っている. マントの合わせ目の胸元に赤い宝石が留め飾られている. 光は午後遅い低い暖かな光で, アーケードの漆喰と回廊の淡い石の床を照らしている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_GUSTAVUS_ADOLPHUS"] =
    "スウェーデン, ゴート, ヴェンドの王にして「北方の獅子」, グスタフ・アドルフは, 金箔を施した宮殿の一室に立つ. 傍らの深い暖炉では割り薪が低くも明るく燃えている. 長身で体格がよく, 赤みがかった豊かな顎鬚を胸まで垂らし, 上方に跳ね上がった濃い口髭を生やし, 高い額から髪を後ろに撫でつけている. 黒ずんだ鋼鉄の胸甲を身につけており, 縁と中央の稜線に沿って金の帯が追込み彫りで施され, 厚みのある淡色の鞣し牛革のバフコートの上に合わせている. 鎧は下方へ続き, 蝶番でつながれた鋼鉄のタッセットが黄色い下着の裾の上で腿の中ほどまで広がっている. ターコイズブルーのシルクの幅広帯が右肩から左腰へと斜めに渡り, 結ばれて胸甲の前にゆったりとたわんでいる. 手首には小さなレースのカフスが覗き, ブーツの上のブリーチズの縁は淡いレースで縁取られている. 体重を後ろ足にかけて立ち, 革手袋をはめた両手は先端を床に立てた野戦指揮棒の上に乗せている. 背後の暖炉の囲いは彫刻と金箔で飾られ, マントルピースにはバロック様式のアカンサスの渦巻き文様が帯状に施されている. 左手の壁には緑と金のダマスク地に金縁の絵画が2枚掛かっている. 手前はスウェーデンの先代の王エリック14世, 暗い甲冑を着た顎鬚の男の肖像だ. 奥はブランデンブルクのマリア・エレオノーラ, グスタフの妃が淡い宮廷衣装をまとって描かれている. 絵の下には磨き上げられた黒い木のテーブルがあり, 果物を盛った浅いピューター皿と, 蝋燭に火が入っていない高い真鍮の燭台が置かれている. 部屋の光はほぼ炎だけで賄われ, 温かいオレンジの光が胸甲と金箔の漆喰細工と彼の顔の右半分を照らし, 奥の壁は影に沈んでいる."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_ENRICO_DANDOLO"] =
    "最も穏やかなヴェネツィア共和国の総督, エンリコ・ダンドロは, 夜の運河に架かる石橋の上に立ち, 手袋をした片手を胸元へ引き寄せている. 老齢の姿だ. 長い灰色の鬚が胸まで垂れ, こめかみには白髪が見え, 顔には深い皺が刻まれている. 頭には, フリュギア帽に似た後ろがなだらかな尖りになる, 錆色のブロケード製の硬いコルノ・ドゥカーレが乗り, その下には白いリネンのカマウロが顔を縁取るように覗いている. 肩には淡い毛皮で縁取られた重い灰色のマントが掛かり, 前は開いてコルノと同じ錆色の裏地が見えている. その下には, 腰を金の組み紐で結んだ深紅色ブロケードの長いローブを纏っている. 橋の欄干は鍛鉄製で, ヴェネツィア・ゴシック様式の細い尖頭アーチがパネルを埋めている. 背後では運河が暗闇の奥へと消えていき, 両脇のパラッツォの窓が青い夜の中に暖かいオレンジ色の光を灯している. 左手の岸壁には細いゴンドラが一艘係留されており, 屋根の上には雲の切れ間から星を散らした空が広がっている."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADER_DESC_LEADER_SHAKA"] =
    "ズールーの王, シャカ・カセンザンガコーナは, 王家の集落の広場に足を踏ん張って立つ. 左手に盾を横に張り出し, 右手には短い槍を持つ. 上半身は裸で肌は黒く, 筋肉は重厚だ. 胴体には小さなビーズを通した細い紐が交差している. 頭にはウムクヘレ, 王族と上位者の証である豹の斑点毛皮の厚い円形の頭帯が巻かれている. 眉の上にはその帯に固定された白い羽根の直立した房飾りがあり, 先端は赤い. 腰には豹の皮のエプロンが下がり, その下には長い薄い毛皮の房飾りが腿に揺れている. 同じ豹の斑点毛皮の帯が足首に巻かれている. 左手に持つのはイシラング, 牛の皮製の高く先が尖った楕円形の戦の盾だ. 表面は茶色と白のまだら模様で, 中央を真っ直ぐな木製の柄が縦に走り, 革のループで留められている. 右手には低く構えてイクルワ, 短い柄の刺突槍が握られ, 幅広の長い葉形の刃が付いている. 背後にはイククワネ, ズールーのウムジの丸天井型草葺きビーハイブ小屋の列が弧を描き, その織られた表面に陽光が当たっている. 空き地の両脇には木の柱が立ち, 長い角を持つ牛の頭蓋骨が頂に飾られている. 大きく弧を描く角はそのまま残されており, 富と生贄が門に示されている. 地面は乾いた淡い土で, 遠くに平頂のメサが見え, 空は薄い雲が筋を引く澄んだ青空だ."

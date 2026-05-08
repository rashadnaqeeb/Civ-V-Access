-- Mod-authored strings, ja_JP overlay. Baseline in CivVAccess_SurveyorStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Radius announcements =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS"] = "半径 {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MIN"] = "半径 {1_N} 最小"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MAX"] = "半径 {1_N} 最大"

-- ===== Per-scope empty-range fallbacks =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_YIELDS"] = "範囲内に産出なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_RESOURCES"] = "範囲内に資源なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_TERRAIN"] = "範囲内に地形なし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_OWN_UNITS"] = "範囲内に自軍ユニットなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_ENEMY_UNITS"] = "範囲内に敵ユニットなし"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_CITIES"] = "範囲内に都市なし"

-- ===== Unexplored suffix =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_UNEXPLORED_SUFFIX"] = {
    other = "{1_N} 地形未探索",
}

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RADIUS"] = "Shift + W または X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RADIUS"] = "測量半径を拡大または縮小する"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_YIELDS"] = "Shift + Q"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_YIELDS"] = "範囲内の産出を合算する"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RESOURCES"] = "Shift + A"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RESOURCES"] = "範囲内の資源を集計する"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_TERRAIN"] = "Shift + Z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_TERRAIN"] = "範囲内の地形と地物を集計する"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_OWN_UNITS"] = "Shift + E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_OWN_UNITS"] = "範囲内の自軍ユニットを一覧表示する"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_ENEMY_UNITS"] = "Shift + D"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_ENEMY_UNITS"] = "範囲内の敵ユニットを一覧表示する"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_CITIES"] = "Shift + C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_CITIES"] = "範囲内の都市を一覧表示する, 最近順"

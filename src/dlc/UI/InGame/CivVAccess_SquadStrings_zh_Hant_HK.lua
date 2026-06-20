-- Mod-authored strings, zh_Hant_HK overlay. Baseline in CivVAccess_SquadStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DEFAULT_NAME"] = "小隊 {1_N}"

-- ===== Movement status =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVING"] = { other = "移動中, 剩餘 {1_N} 回合" }
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_STATUS_IDLE"] = "閒置"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DESTINATION"] = "目的地 {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_PREVIEW_TURNS"] = { other = "{1_N} 回合" }
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNREACHABLE"] = "無路徑"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNIT_COUNT"] = { other = "{1_N} 個單位" }

-- ===== Wake modes =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_SENTRY"] = "抵達時哨戒"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_EACH"] = "抵達時喚醒"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_ALL"] = "全員抵達時喚醒"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL"] = "喚醒模式, {1_Mode}"

-- ===== Escort =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT"] = "護送平民"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT_ON"] = "護送平民中"

-- ===== Per-unit status tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED_BY"] = "由 {1_Name} 護送"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED"] = "受護送"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HOLDING"] = "等待 {1_Name}"

-- ===== Map-mode feedback =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NONE"] = "無小隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"] = "無單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNIT_SELECTED"] = "未選擇單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_REMOVED"] = "已從 {1_Name} 移除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO"] = "已加入 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO"] = "已移至 {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_ORDERED"] = "{1_Name} 移動中"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_CANCELED"] = "{1_Name} 移動已取消"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_MODE"] = "{1_Name}, 選擇目的地"

-- ===== Menu =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME"] = "小隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW"] = "新增小隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CREATED"] = "{1_Name} 已建立"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETE"] = "刪除小隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETED"] = "{1_Name} 已刪除"

-- ===== Help overlay (map-mode squad section) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_SQUAD"] = "Up 或 Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_SQUAD"] = "循環小隊, 讀出名稱與移動狀態"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_UNIT"] = "Left 或 Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_UNIT"] = "循環當前小隊內的單位"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_REMOVE"] = "Alt 加 Left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_REMOVE"] = "將當前單位從小隊移除"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_ADD"] = "Alt 加 Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_ADD"] = "將所選單位加入當前小隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MOVE"] = "Alt 加 Up"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MOVE"] = "移動當前小隊"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_STATUS"] = "Alt 加 Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_STATUS"] = "小隊狀態, 按兩次取消移動"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU"] = "F11"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU"] = "開啟小隊選單"

-- ===== Help overlay (move sub-mode) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_PREVIEW"] = "預覽移動至游標格所需回合數"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_COMMIT"] = "將小隊移至游標格"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_CANCEL"] = "取消移動"

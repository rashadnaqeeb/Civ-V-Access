-- Mod-authored strings, ru_RU overlay. Baseline in CivVAccess_SurveyorStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Radius announcements =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS"] = "радиус {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MIN"] = "радиус {1_N} мин."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MAX"] = "радиус {1_N} макс."

-- ===== Per-scope empty-range fallbacks =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_YIELDS"] = "нет показателей в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_RESOURCES"] = "нет ресурсов в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_TERRAIN"] = "нет ландшафта в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_OWN_UNITS"] = "нет своих юнитов в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_ENEMY_UNITS"] =
    "нет вражеских юнитов в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_CITIES"] = "нет городов в радиусе"

-- ===== Unexplored suffix =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_UNEXPLORED_SUFFIX"] = {
    one = "{1_N} клетка не исследована",
    few = "{1_N} клетки не исследованы",
    many = "{1_N} клеток не исследовано",
}

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RADIUS"] = "Shift плюс W или X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RADIUS"] =
    "Увеличить или уменьшить радиус обзора"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_YIELDS"] = "Shift плюс Q"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_YIELDS"] =
    "Суммировать показатели в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RESOURCES"] = "Shift плюс A"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RESOURCES"] =
    "Подсчитать ресурсы в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_TERRAIN"] = "Shift плюс Z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_TERRAIN"] =
    "Подсчитать ландшафт и особенности в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_OWN_UNITS"] = "Shift плюс E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_OWN_UNITS"] =
    "Список своих юнитов в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_ENEMY_UNITS"] = "Shift плюс D"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_ENEMY_UNITS"] =
    "Список вражеских юнитов в радиусе"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_CITIES"] = "Shift плюс C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_CITIES"] =
    "Список городов в радиусе, ближайшие первыми"

-- Mod-authored strings, cs_CZ overlay. Baseline in CivVAccess_SurveyorStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Radius announcements =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS"] = "poloměr {1_N}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MIN"] = "poloměr {1_N}, minimum"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MAX"] = "poloměr {1_N}, maximum"

-- ===== Per-scope empty-range fallbacks =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_YIELDS"] = "žádné výnosy v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_RESOURCES"] = "žádné suroviny v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_TERRAIN"] = "žádný terén v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_OWN_UNITS"] = "žádné vlastní jednotky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_ENEMY_UNITS"] = "žádné nepřátelské jednotky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_CITIES"] = "žádná města v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_IMPROVEMENTS"] = "žádná vylepšení v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_NEUTRAL_UNITS"] = "žádné neutrální jednotky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_BORDERS"] = "žádná políčka v dosahu"

-- ===== Terrain bucket labels =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_RIVER"] = "políčka s řekou"

-- ===== Border ownership labels =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_BORDERS_YOURS"] = "tvoje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_BORDERS_UNCLAIMED"] = "bez vlastníka"

-- ===== Unexplored suffix =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_UNEXPLORED_SUFFIX"] = {
    one = "{1_N} políčko neprozkoumané",
    few = "{1_N} políčka neprozkoumaná",
    other = "{1_N} políček neprozkoumaných",
}

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RADIUS"] = "Shift plus W nebo X"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RADIUS"] = "Zvětšit nebo zmenšit poloměr zeměměřiče"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_YIELDS"] = "Shift plus Q"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_YIELDS"] = "Sečíst výnosy v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RESOURCES"] = "Shift plus A"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RESOURCES"] = "Spočítat suroviny v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_TERRAIN"] = "Shift plus Z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_TERRAIN"] = "Spočítat terén a krajinné prvky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_OWN_UNITS"] = "Shift plus E"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_OWN_UNITS"] = "Vypsat vlastní jednotky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_ENEMY_UNITS"] = "Shift plus D"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_ENEMY_UNITS"] = "Vypsat nepřátelské jednotky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_CITIES"] = "Shift plus C"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_CITIES"] = "Vypsat města v dosahu, nejbližší první"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_IMPROVEMENTS"] = "Control plus Shift plus A"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_IMPROVEMENTS"] = "Spočítat vylepšení v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_NEUTRAL_UNITS"] = "Control plus Shift plus D"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_NEUTRAL_UNITS"] = "Vypsat neutrální jednotky v dosahu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_BORDERS"] = "Control plus Shift plus Z"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_BORDERS"] = "Spočítat vlastnictví políček v dosahu"

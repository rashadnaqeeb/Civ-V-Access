-- Mod-authored strings, cs_CZ overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "Moje města"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_TEAMMATE"] = "Města spoluhráčů"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_CITY_STATES"] = "Městské státy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Neutrální města"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Nepřátelská města"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Barbarská ležení"
-- The four unit categories are top-level category labels (not subs).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "Moje jednotky"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_TEAMMATE"] = "Jednotky spoluhráčů"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Neutrální jednotky"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Nepřátelské jednotky"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Vylepšení"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_PILLAGED"] = "Vydrancovaná vylepšení"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "Obdělávaná políčka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_YIELDS"] = "Výnosy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Zvláštní"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Doporučení"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Body trasy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_GEOGRAPHY"] = "Geografie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_TARGETS"] = "Cíle"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "Vše"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Jednotky boje zblízka"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Jízdní jednotky"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Civilní jednotky"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Barbaři"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "Moje"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TEAMMATE"] = "Spoluhráč"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutrální"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Nepřátelské"
-- Terrain subs.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Základní terén"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Nadmořská výška"
-- Geography subs.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_LANDMASSES"] = "Pevniny"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_OCEANS"] = "Oceány"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CITY_BARBARIAN_HELD"] = "{1_Name}, obsazené barbary"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"] = "neprozkoumáno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"] = "{1_Count} neprozkoumaných políček"

CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_LANDMASS"] = "Pevnina {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_OCEAN"] = "Oceán {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_HEXES"] = {
    one = "{1_Name}, {2_Count} políčko",
    few = "{1_Name}, {2_Count} políčka",
    other = "{1_Name}, {2_Count} políček",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_FULLY_REVEALED"] = "{1_Body}, zcela odkryto"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} z {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "zde"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "prázdné"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "žádný skok, ze kterého by se šlo vrátit"

-- ===== Directional scope =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_SET"] = "skenování směru: {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_CLEARED"] = "směr zrušen"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "hledat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "výsledky hledání"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "žádná shoda pro: {1_Buffer}"

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Page Up nebo Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "Procházet položky v podkategorii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Shift plus Page Up nebo Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "Procházet podkategorie v kategorii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control plus Page Up nebo Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "Procházet kategorie, znovu sestaví přehled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt plus Page Up nebo Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "Procházet výskyty v položce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CUSTOM_FLAT"] = "J, K nebo L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CUSTOM_FLAT"] =
    "Procházet první, druhou nebo třetí vlastní kategorii, všechny záznamy od nejbližšího; Shift prochází zpět"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Home nebo M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "Přesunout kurzor na aktuální záznam"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "Vzdálenost a směr od kurzoru k záznamu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Hledat záznamy skeneru"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Vrátit kurzor na políčko před skokem"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DIRECTION"] = "Control plus šipky"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DIRECTION"] =
    "Omezit skener na jednu světovou stranu; dalším stiskem zrušit"

-- ===== Custom categories (F12 settings + scanner cycle) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_GROUP"] = "Vlastní kategorie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_ADD"] = "Přidat kategorii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_DELETE"] = "Odstranit kategorii"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL"] = "Vlastní {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM"] = "žádná vlastní kategorie {1_Num}"

-- Keywords drillable inside a custom category's editor.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORDS_GROUP"] = "Klíčová slova"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADD"] = "Přidat klíčové slovo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADDED"] = "Klíčové slovo přidáno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_REMOVED"] = "Klíčové slovo odebráno"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_DUPLICATE"] = "Klíčové slovo už bylo přidáno"

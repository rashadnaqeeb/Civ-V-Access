-- Mod-authored strings, it_IT overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "Le mie città"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_TEAMMATE"] = "Città dei compagni"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_CITY_STATES"] = "Città-stato"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Città neutrali"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Città nemiche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Accampamenti barbari"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "Le mie unità"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_TEAMMATE"] = "Unità dei compagni"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Unità neutrali"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Unità nemiche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Miglioramenti"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "Caselle lavorate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_YIELDS"] = "Rese"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Speciale"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Raccomandazioni"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Punti di riferimento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_GEOGRAPHY"] = "Geografia"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "Tutti"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Unità da mischia"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Unità montate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Unità civili"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Barbari"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "Miei"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY_PILLAGED"] = "Miei saccheggiati"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TEAMMATE"] = "Compagni"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutrali"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Nemici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Terreno di base"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Elevazione"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_LANDMASSES"] = "Masse terrestri"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_OCEANS"] = "Oceani"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"] = "inesplorato"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"] = "{1_Count} inesplorati"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_LANDMASS"] = "Massa terrestre {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_OCEAN"] = "Oceano {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_HEXES"] = {
    one = "{1_Name}, {2_Count} esagono",
    other = "{1_Name}, {2_Count} esagoni",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_FULLY_REVEALED"] = "{1_Body}, completamente esplorato"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} di {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "qui"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "vuoto"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "nessun salto da cui tornare"

-- ===== Directional scope =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_SET"] = "scansione {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_CLEARED"] = "direzione annullata"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "cerca"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "risultati della ricerca"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "nessuna corrispondenza per {1_Buffer}"

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Pagina su o pagina giù"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "Scorri gli elementi nella sottocategoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Shift più pagina su o pagina giù"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "Scorri le sottocategorie nella categoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control più pagina su o pagina giù"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "Scorri le categorie, ricostruisce lo snapshot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt più pagina su o pagina giù"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "Scorri le istanze dell'elemento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CUSTOM_FLAT"] = "J, K o L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CUSTOM_FLAT"] =
    "Scorri la prima, seconda o terza categoria personalizzata, partendo dalla voce più vicina; Shift scorre all'indietro"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Home o M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "Salta il cursore alla voce corrente"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "Fine"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "Distanza e direzione dal cursore alla voce"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control più F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Cerca nelle voci dello scanner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Riporta il cursore alla casella prima del salto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DIRECTION"] = "Control più tasti cursore"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DIRECTION"] =
    "Limita lo scanner a una direzione bussola; premi di nuovo per annullare"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_GROUP"] = "Categorie personalizzate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_ADD"] = "Aggiungi categoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_DELETE"] = "Elimina categoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL"] = "Personalizzata {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM"] = "nessuna categoria personalizzata {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORDS_GROUP"] = "Parole chiave"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADD"] = "Aggiungi parola chiave"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADDED"] = "Parola chiave aggiunta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_DUPLICATE"] = "Parola chiave già aggiunta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_REMOVED"] = "Parola chiave rimossa"

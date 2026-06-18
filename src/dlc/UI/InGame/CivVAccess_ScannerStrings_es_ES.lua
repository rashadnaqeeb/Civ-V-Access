-- Mod-authored strings, es_ES overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "Mis ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_TEAMMATE"] = "Ciudades del aliado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_CITY_STATES"] = "Ciudades-estado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Ciudades neutrales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Ciudades enemigas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Campamentos bárbaros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "Mis unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_TEAMMATE"] = "Unidades del aliado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Unidades neutrales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Unidades enemigas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Mejoras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "Casillas trabajadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_YIELDS"] = "Rendimientos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Especial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Recomendaciones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Puntos de paso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_GEOGRAPHY"] = "Geografía"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "Todo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Unidades cuerpo a cuerpo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Unidades montadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Unidades civiles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Bárbaros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "Propias"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY_PILLAGED"] = "Propias saqueadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TEAMMATE"] = "Aliado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Enemigo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Terreno base"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Elevación"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_LANDMASSES"] = "Masas de tierra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_OCEANS"] = "Océanos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"] = "inexplorada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"] = "{1_Count} inexploradas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_LANDMASS"] = "Masa de tierra {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_OCEAN"] = "Océano {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_HEXES"] = {
    one = "{1_Name}, {2_Count} casilla",
    other = "{1_Name}, {2_Count} casillas",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_FULLY_REVEALED"] = "{1_Body}, totalmente revelada"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} de {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "vacío"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "no hay salto al que volver"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_SET"] = "escaneando {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_CLEARED"] = "dirección borrada"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "buscar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "resultados de la búsqueda"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "sin coincidencias para {1_Buffer}"

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Avanzar página o retroceder página"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "Cambiar elemento dentro de la subcategoría"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Mayúsculas más avanzar página o retroceder página"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "Cambiar subcategoría dentro de la categoría"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control más avanzar página o retroceder página"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "Cambiar categoría, reconstruye la captura"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt más avanzar página o retroceder página"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "Cambiar instancia dentro del elemento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Inicio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "Saltar el cursor a la entrada actual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "Fin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "Distancia y dirección del cursor a la entrada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control más F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Buscar entradas del escáner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Retroceso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Volver el cursor a la casilla anterior al salto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DIRECTION"] = "Control más teclas de flecha"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DIRECTION"] =
    "Limitar escáner a una dirección cardinal; presionar de nuevo para borrar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_GROUP"] = "Categorías personalizadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_ADD"] = "Añadir categoría"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_DELETE"] = "Eliminar categoría"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL"] = "Personalizado {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORDS_GROUP"] = "Palabras clave"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADD"] = "Añadir palabra clave"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADDED"] = "palabra clave añadida"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_REMOVED"] = "palabra clave eliminada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_DUPLICATE"] = "palabra clave ya añadida"

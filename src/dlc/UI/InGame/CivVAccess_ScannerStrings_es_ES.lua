-- Mod-authored strings, es_ES overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "Mis ciudades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Ciudades neutrales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Ciudades enemigas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Campamentos bárbaros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "Mis unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Unidades neutrales"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Unidades enemigas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Mejoras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "Casillas trabajadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Especial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Recomendaciones"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Puntos de paso"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "Todo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Unidades cuerpo a cuerpo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Unidades montadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Unidades civiles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Bárbaros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "Propias"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY_PILLAGED"] = "Propias saqueadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutral"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Enemigo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Terreno base"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Elevación"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} de {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "aquí"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "vacío"

-- ===== Auto-move toggle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_ON"] = "movimiento automático activado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_OFF"] = "movimiento automático desactivado"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "no hay salto al que volver"

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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_AUTO_MOVE"] = "Mayúsculas más fin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_AUTO_MOVE"] = "Activar o desactivar el movimiento automático al cambiar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control más F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Buscar entradas del escáner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Retroceso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Volver el cursor a la casilla anterior al salto"

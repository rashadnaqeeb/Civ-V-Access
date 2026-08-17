-- Mod-authored strings, pt_BR overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "Minhas Cidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_TEAMMATE"] = "Cidades Aliadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_CITY_STATES"] = "Cidades-Estado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Cidades Neutras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Cidades Inimigas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Acampamentos Bárbaros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "Minhas Unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_TEAMMATE"] = "Unidades Aliadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Unidades Neutras"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Unidades Inimigas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Melhoramentos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WORKED_TILES"] = "Hexágonos trabalhados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_YIELDS"] = "Rendimentos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Especial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Recomendações"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Pontos de passagem"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_GEOGRAPHY"] = "Geografia"

-- ===== Subcategory labels without a clean game key =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "Todos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Unidades Corpo a Corpo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Unidades Montadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Unidades Civis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Bárbaros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "Meus"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY_PILLAGED"] = "Meus Saqueados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TEAMMATE"] = "Aliados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutros"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Inimigos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Terreno Base"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Elevação"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_LANDMASSES"] = "Massas de terra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_OCEANS"] = "Oceanos"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"] = "inexplorado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"] = "{1_Count} inexplorados"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_LANDMASS"] = "Massa de terra {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_OCEAN"] = "Oceano {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_HEXES"] = {
    one = "{1_Name}, {2_Count} hexágono",
    other = "{1_Name}, {2_Count} hexágonos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_MASS_FULLY_REVEALED"] = "{1_Body}, totalmente revelado"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} de {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "aqui"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "vazio"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "sem salto para retornar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_SET"] = "escaneando {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_DIRECTION_CLEARED"] = "direção limpa"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "busca"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "resultados da busca"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "sem resultado para {1_Buffer}"

-- ===== Help overlay entries =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Page Up ou Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "Percorrer item dentro da subcategoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Shift mais Page Up ou Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "Percorrer subcategoria dentro da categoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Control mais Page Up ou Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "Percorrer categoria, reconstrói lista"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt mais Page Up ou Page Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "Percorrer instância dentro do item"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CUSTOM_FLAT"] = "J, K ou L"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CUSTOM_FLAT"] =
    "Percorrer a primeira, segunda ou terceira categoria personalizada, cada entrada mais próxima primeiro; Shift percorre no sentido inverso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Home ou M"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "Saltar cursor para entrada atual"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "End"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "Distância e direção do cursor à entrada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Control mais F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Procurar entradas do scanner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Backspace"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Retornar cursor à célula antes do salto"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DIRECTION"] = "Control mais teclas de seta"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DIRECTION"] =
    "Limitar scanner a uma direção de bússola; pressionar novamente para limpar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_GROUP"] = "Categorias personalizadas"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_ADD"] = "Adicionar categoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_DELETE"] = "Excluir categoria"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CUSTOM_LABEL"] = "Personalizada {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_NO_CUSTOM"] = "sem categoria personalizada {1_Num}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORDS_GROUP"] = "Palavras-chave"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADD"] = "Adicionar palavra-chave"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_ADDED"] = "Palavra-chave adicionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_DUPLICATE"] = "Palavra-chave já adicionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_KEYWORD_REMOVED"] = "Palavra-chave removida"

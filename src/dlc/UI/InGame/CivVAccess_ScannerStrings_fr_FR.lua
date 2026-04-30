-- Mod-authored strings, fr_FR overlay. Baseline in CivVAccess_ScannerStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Category labels (where no clean game key exists) =====
-- Cities category uses the game's TXT_KEY_CITIES_HEADING1_TITLE ("Cities")
-- at the category level; these are its four subcategory labels.
-- Category and subcategory labels are title-cased to match the engine's
-- own headings (TXT_KEY_CITIES_HEADING1_TITLE et al). Inline status tokens
-- like "here" / "empty" further down stay lowercase because they tail
-- another phrase rather than head a section.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_MY"] = "Mes villes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_NEUTRAL"] = "Villes neutres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_ENEMY"] = "Villes ennemies"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_CITIES_BARB_CAMPS"] = "Campements barbares"
-- The three unit categories are top-level category labels (not subs).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_MY"] = "Mes unités"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_NEUTRAL"] = "Unités neutres"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_UNITS_ENEMY"] = "Unités ennemies"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_IMPROVEMENTS"] = "Améliorations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_SPECIAL"] = "Spécial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_RECOMMENDATIONS"] = "Recommandations"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_CATEGORY_WAYPOINTS"] = "Points de passage"

-- ===== Subcategory labels without a clean game key =====
-- Ranged / Siege / Naval / Air / Great People / Strategic / Luxury /
-- Bonus / Natural Wonders / Ancient Ruins reuse game keys directly;
-- only these subs are mod-authored.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"] = "Tous"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MELEE"] = "Unités de mêlée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MOUNTED"] = "Unités montées"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_CIVILIAN"] = "Unités civiles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_BARBARIANS"] = "Barbares"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_MY"] = "Mes"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_NEUTRAL"] = "Neutre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ENEMY"] = "Ennemi"
-- Terrain subs. Features reuses the game's TXT_KEY_TERRAIN_FEATURES_HEADING2_TITLE;
-- these two have no clean game equivalent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_TERRAIN_BASE"] = "Terrain de base"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SUB_ELEVATION"] = "Élévation"

-- ===== Announcement fragments =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} sur {2_Total}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"] = "ici"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "vide"

-- ===== Auto-move toggle =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_ON"] = "déplacement auto activé"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_OFF"] = "déplacement auto désactivé"

-- ===== Pre-jump return =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "aucun saut à annuler"

-- ===== Search =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_PROMPT"] = "recherche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS"] = "résultats de recherche"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_SEARCH_NO_MATCH"] = "aucune correspondance pour {1_Buffer}"

-- ===== Help overlay entries =====
-- Merged chord labels following the existing cursor help convention so
-- HandlerStack.collectHelpEntries can dedupe by keyLabel string across
-- stacked handlers.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_ITEM"] = "Page précédente ou page suivante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_ITEM"] = "Faire défiler les éléments dans la sous-catégorie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SUB"] = "Maj plus page précédente ou page suivante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SUB"] = "Faire défiler les sous-catégories dans la catégorie"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_CATEGORY"] = "Contrôle plus page précédente ou page suivante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_CATEGORY"] = "Faire défiler les catégories, reconstruit le snapshot"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_INSTANCE"] = "Alt plus page précédente ou page suivante"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_INSTANCE"] = "Faire défiler les instances dans l'élément"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_JUMP"] = "Début"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_JUMP"] = "Déplacer le curseur vers l'entrée actuelle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_DISTANCE"] = "Fin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_DISTANCE"] = "Distance et direction du curseur vers l'entrée"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_AUTO_MOVE"] = "Maj plus fin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_AUTO_MOVE"] = "Activer ou désactiver le déplacement auto du curseur lors du cycle"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_SEARCH"] = "Contrôle plus F"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_SEARCH"] = "Rechercher dans les entrées du scanner"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_KEY_RETURN"] = "Retour arrière"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HELP_DESC_RETURN"] = "Retourner le curseur à la case d'avant le saut"

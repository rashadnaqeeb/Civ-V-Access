-- Mod-authored strings, de_DE overlay. Baseline in CivVAccess_SquadStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DEFAULT_NAME"] = "Trupp {1_N}"

-- ===== Movement status =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVING"] =
    { one = "bewegt, {1_N} Runde verbleibend", other = "bewegt, {1_N} Runden verbleibend" }
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_STATUS_IDLE"] = "untätig"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DESTINATION"] = "Ziel {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_PREVIEW_TURNS"] = { one = "{1_N} Runde", other = "{1_N} Runden" }
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNREACHABLE"] = "kein Pfad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNIT_COUNT"] = { one = "{1_N} Einheit", other = "{1_N} Einheiten" }

-- ===== Wake modes =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_SENTRY"] = "Wachposten bei Ankunft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_EACH"] = "aufwecken bei Ankunft"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_ALL"] = "aufwecken wenn alle angekommen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL"] = "Aufweckmodus, {1_Mode}"

-- ===== Escort =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT"] = "zivile Einheiten begleiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT_ON"] = "begleitet zivile Einheiten"

-- ===== Per-unit status tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED_BY"] = "begleitet von {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED"] = "begleitet"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HOLDING"] = "wartet auf Trupp"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MEMBER"] = "in {1_Name}"

-- ===== Map-mode feedback =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NONE"] = "keine Trupps"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"] = "keine Einheiten"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNIT_SELECTED"] = "keine Einheit ausgewählt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_REMOVED"] = "aus {1_Name} entfernt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO"] = "zu {1_Name} hinzugefügt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ALREADY_IN"] = "bereits in {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO"] = "zu {1_Name} verschoben"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_ORDERED"] = "{1_Name} bewegt sich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_CANCELED"] = "{1_Name} Bewegung abgebrochen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_MODE"] = "{1_Name}, Ziel wählen"

-- ===== Menu =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME"] = "Trupps"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW"] = "neuen Trupp hinzufügen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CREATED"] = "{1_Name} erstellt"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_BUTTON"] = "Trupp bewegen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CANCEL_MOVE"] = "Bewegung abbrechen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETE"] = "Trupp löschen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETED"] = "{1_Name} gelöscht"

-- ===== Help overlay (map-mode squad section) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_SQUAD"] = "Auf/Ab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_SQUAD"] =
    "Trupps durchblättern, liest Name und Bewegungsstatus vor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_UNIT"] = "Links/Rechts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_UNIT"] = "Einheiten im fokussierten Trupp durchblättern"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT"] = "Alt plus Schrägstrich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_AZERTY"] = "Alt plus Ausrufezeichen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_QWERTZ"] = "Alt plus Bindestrich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_ITALIAN"] = "Alt plus Bindestrich"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_SELECT"] = "Fokussierte Einheit auswählen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_REMOVE"] = "Alt+Links"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_REMOVE"] = "Fokussierte Einheit aus ihrem Trupp entfernen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_ADD"] = "Alt+Rechts"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_ADD"] = "Ausgewählte Einheit zum fokussierten Trupp hinzufügen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MOVE"] = "Alt+Auf"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MOVE"] =
    "Fokussierten Trupp bewegen, oder eine laufende Bewegung vorlesen und erneut drücken, um sie neu zu erteilen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_EDITOR"] = "Alt+Ab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_EDITOR"] = "Einstellungen des fokussierten Trupps öffnen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU"] = "F11"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU"] = "Trupp-Menu öffnen"

-- ===== Help overlay (move sub-mode) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_PREVIEW"] = "Leertaste"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_PREVIEW"] = "Runden bis zum Cursor-Geländefeld voranzeigen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_COMMIT"] = "Eingabe"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_COMMIT"] = "Trupp zum Cursor-Geländefeld schicken"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_CANCEL"] = "Bewegung abbrechen"

-- Mod-authored strings, it_IT overlay. Baseline in CivVAccess_SquadStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DEFAULT_NAME"] = "Squadra {1_N}"

-- ===== Movement status =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVING"] = {
    one = "in movimento, {1_N} turno rimasto",
    other = "in movimento, {1_N} turni rimasti",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_STATUS_IDLE"] = "inattiva"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DESTINATION"] = "destinazione {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_PREVIEW_TURNS"] = {
    one = "{1_N} turno",
    other = "{1_N} turni",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNREACHABLE"] = "nessun percorso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNIT_COUNT"] = {
    one = "{1_N} unità",
    other = "{1_N} unità",
}

-- ===== Wake modes =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_SENTRY"] = "in allerta all'arrivo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_EACH"] = "sveglia all'arrivo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_ALL"] = "sveglia quando arrivano tutti"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL"] = "modalità di sveglia, {1_Mode}"

-- ===== Escort =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT"] = "scorta civili"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT_ON"] = "scortando civili"

-- ===== Per-unit status tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED_BY"] = "scortato da {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED"] = "scortato"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HOLDING"] = "in attesa della squadra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MEMBER"] = "in {1_Name}"

-- ===== Map-mode feedback =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NONE"] = "nessuna squadra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"] = "nessuna unità"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNIT_SELECTED"] = "nessuna unità selezionata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_REMOVED"] = "rimossa da {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO"] = "aggiunta a {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ALREADY_IN"] = "già in {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO"] = "spostata a {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_ORDERED"] = "{1_Name} in movimento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_CANCELED"] = "{1_Name} movimento annullato"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_MODE"] = "{1_Name}, scegli destinazione"

-- ===== Menu =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME"] = "Squadre"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW"] = "aggiungi nuova squadra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CREATED"] = "{1_Name} creata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_BUTTON"] = "sposta squadra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CANCEL_MOVE"] = "annulla spostamento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETE"] = "elimina squadra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETED"] = "{1_Name} eliminata"

-- ===== Help overlay (map-mode squad section) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_SQUAD"] = "Su/Giù"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_SQUAD"] =
    "Scorre le squadre, legge nome e stato di movimento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_UNIT"] = "Sinistra/Destra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_UNIT"] = "Scorre le unità nella squadra selezionata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT"] = "Alt più slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_AZERTY"] = "Alt più punto esclamativo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_QWERTZ"] = "Alt più trattino"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_ITALIAN"] = "Alt più trattino"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_SELECT"] = "Seleziona l'unità selezionata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_REMOVE"] = "Alt+Sinistra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_REMOVE"] = "Rimuove l'unità selezionata dalla sua squadra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_ADD"] = "Alt+Destra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_ADD"] = "Aggiunge l'unità attiva alla squadra selezionata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MOVE"] = "Alt+Su"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MOVE"] =
    "Sposta la squadra selezionata, o leggi uno spostamento in corso e premi di nuovo per riemetterlo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_EDITOR"] = "Alt+Giù"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_EDITOR"] = "Apri le impostazioni della squadra selezionata"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU"] = "F11"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU"] = "Apri il menu delle squadre"

-- ===== Help overlay (move sub-mode) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_PREVIEW"] = "Spazio"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_PREVIEW"] =
    "Anteprima dei turni fino alla casella del cursore"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_COMMIT"] = "Invia la squadra alla casella del cursore"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_CANCEL"] = "Annulla lo spostamento"

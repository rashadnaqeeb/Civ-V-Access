-- Mod-authored strings, pt_BR overlay. Baseline in CivVAccess_SquadStrings_en_US.lua.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Names =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DEFAULT_NAME"] = "Esquadrão {1_N}"

-- ===== Movement status =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVING"] = {
    one = "em movimento, {1_N} turno restante",
    other = "em movimento, {1_N} turnos restantes",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_STATUS_IDLE"] = "ocioso"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DESTINATION"] = "destino {1_Dir}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_PREVIEW_TURNS"] = {
    one = "{1_N} turno",
    other = "{1_N} turnos",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNREACHABLE"] = "sem caminho"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNIT_COUNT"] = {
    one = "{1_N} unidade",
    other = "{1_N} unidades",
}

-- ===== Wake modes =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_SENTRY"] = "sentinela ao chegar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_EACH"] = "acordar ao chegar"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_ALL"] = "acordar quando todos chegarem"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL"] = "modo de despertar, {1_Mode}"

-- ===== Escort =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT"] = "escolta de civis"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT_ON"] = "escoltando civis"

-- ===== Per-unit status tokens =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED_BY"] = "escoltado por {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED"] = "escoltado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HOLDING"] = "aguardando o esquadrão"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MEMBER"] = "em {1_Name}"

-- ===== Map-mode feedback =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NONE"] = "sem esquadrões"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"] = "sem unidades"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNIT_SELECTED"] = "nenhuma unidade selecionada"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_REMOVED"] = "removido de {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO"] = "adicionado a {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ALREADY_IN"] = "já em {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO"] = "movido para {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_ORDERED"] = "{1_Name} em movimento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_CANCELED"] = "movimento de {1_Name} cancelado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_MODE"] = "{1_Name}, escolha o destino"

-- ===== Menu =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME"] = "Esquadrões"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW"] = "adicionar novo esquadrão"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CREATED"] = "{1_Name} criado"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_BUTTON"] = "mover esquadrão"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CANCEL_MOVE"] = "cancelar movimento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETE"] = "excluir esquadrão"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETED"] = "{1_Name} excluído"

-- ===== Help overlay (map-mode squad section) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_SQUAD"] = "Up/Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_SQUAD"] =
    "Percorrer esquadrões, fala nome e status de movimento"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_UNIT"] = "Left/Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_UNIT"] = "Percorrer unidades no esquadrão em foco"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT"] = "Alt mais barra"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_AZERTY"] = "Alt mais ponto de exclamação"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_QWERTZ"] = "Alt mais traço"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_ITALIAN"] = "Alt mais traço"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_SELECT"] = "Selecionar a unidade em foco"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_REMOVE"] = "Alt mais esquerda"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_REMOVE"] = "Remover a unidade em foco do seu esquadrão"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_ADD"] = "Alt mais direita"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_ADD"] = "Adicionar a unidade selecionada ao esquadrão em foco"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MOVE"] = "Alt mais cima"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MOVE"] =
    "Mover o esquadrão em foco, ou ler um movimento em andamento e pressionar novamente para reemiti-lo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_EDITOR"] = "Alt mais baixo"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_EDITOR"] = "Abrir as configurações do esquadrão em foco"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU"] = "F11"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU"] = "Abrir o menu de esquadrões"

-- ===== Help overlay (move sub-mode) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_PREVIEW"] =
    "Pré-visualizar turnos até o hexágono do cursor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_COMMIT"] = "Enviar o esquadrão para o hexágono do cursor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_CANCEL"] = "Cancelar o movimento"

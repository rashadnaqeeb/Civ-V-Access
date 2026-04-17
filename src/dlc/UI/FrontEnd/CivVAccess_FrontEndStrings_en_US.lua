-- Mod-authored localized strings, front-end Context.
-- The FrontEnd and InGame skin directories are separate VFS Contexts, so each
-- needs its own strings file with the keys relevant to that Context.
CivVAccess_Strings = CivVAccess_Strings or {}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_FRONTEND"]             = "Accessibility mod ready."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"]           = "disabled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAIN_MENU"]          = "Main menu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_OTHER_MENU"]         = "Other"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SINGLE_PLAYER"]      = "Single player"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MULTIPLAYER_SELECT"] = "Multiplayer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_EXIT_CONFIRM"]       = "Exit game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEGAL"]              = "Legal notices"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_EULA"]               = "End user license agreement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_ERROR"]         = "Mod error"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_FRONT_END_POPUP"]    = "Notice"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_MENU"]          = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_SINGLE_PLAYER"] = "Mods single player"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_MULTIPLAYER"]   = "Mods multiplayer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CONTENT_SWITCH"]     = "Updating game data"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WAITING_PLAYERS"]    = "Waiting for players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_JOINING_ROOM"]       = "Joining room"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_OPTIONS"]            = "Options"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVANCED_SETUP"]     = "Game setup"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"]      = "Multiplayer game setup"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"]                  = "on"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"]                 = "off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"]            = "edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"]           = "blank"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"]         = "editing {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"]        = "{1_Label} restored"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LOAD_MENU"]          = "Load game"
-- Disambiguating labels: the game's UI reuses a single label for two visually-
-- separated controls (grid header or fullscreen/windowed toggle distinguishes
-- sighted users). Without that visual context the two items announce
-- identically, so the mod relabels the second half of each pair.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPSCREEN_SMTP_FROM_EMAIL"]   = "Sender email address"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPSCREEN_RESOLUTION_FS"]     = "Fullscreen resolution"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPSCREEN_RESOLUTION_W"]      = "Windowed resolution"
-- Checkbox-gated numeric fields: the checkbox labels the feature, the edit
-- field sets the count. Distinct labels so back-to-back announcements
-- ("Max Turns, on" -> "Max Turns, edit, 500") do not start with the same word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS"]            = "Turn count"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FIELD_TURN_TIMER"]           = "Timer seconds"
-- Options-screen countdown popup. Shown 20s after resolution / language
-- change; auto-reverts if the user takes no action.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPTIONS_COUNTDOWN_INTRO"]     = "{1_Message}. Reverting in 20 seconds."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPTIONS_COUNTDOWN_EXPIRED"]   = "Time expired, reverted."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MP_RECONNECTING"]             = "Reconnecting"

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
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CREDITS"]            = "Credits"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_SETUP"]         = "Set up game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_TYPE"]           = "Map type"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_SIZE"]           = "Map size"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIFFICULTY"]         = "Difficulty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_SPEED"]         = "Game speed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CIVILIZATION"]       = "Civilization"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SET_CIV_NAMES"]      = "Name civilization"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SCENARIOS"]          = "Scenarios"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CUSTOM_MOD_GAME"]    = "Custom mod game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TUTORIAL"]           = "Tutorial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_BROWSER"]       = "Browse mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WORLD_PICKER"]       = "World size"
-- Appended to a tutorial entry when the mod-tracked completion flag for
-- that slot is set. LoadTutorial reads from g_TutorialEntries[i].
-- CompletedIcon:IsHidden().
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TUTORIAL_COMPLETED"]        = "completed"
-- Prepended to a Choice item's label when its selectedFn returns truthy.
-- Used on browse-then-commit screens (ScenariosMenu, CustomMod,
-- LoadTutorial) so the user knows which row Start / Enter will launch.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"]           = "selected"
-- Civ-picker entry prefixes: colons are read by screen readers as a brief
-- pause, so "Unique ability: Glory of Rome, +25% Wonder production" parses
-- as prefix then value without needing extra connective words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_ABILITY"]            = "Unique ability"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_UNIT"]               = "Unique unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_BUILDING"]           = "Unique building"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_IMPROVEMENT"]        = "Unique improvement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_READY"]                = "Enter to begin"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"]                  = "on"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"]                 = "off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"]            = "edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"]           = "blank"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"]         = "editing {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"]        = "{1_Label} restored"
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
-- Advanced Setup + MP Setup (nested menus).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVANCED_SETUP"]       = "Advanced setup"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"]        = "Multiplayer game setup"
-- {1} 1-based slot number, {2} civ description from the slot's pulldown,
-- {3} team text from the slot's team pulldown (already includes "Team N").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AI_SLOT"]                     = "AI {1_Num}, {2_Civ}, {3_Team}"
-- Human slot label: {1} civ text (from CivPulldown button or, when custom
-- name is set, from CivName), {2} team text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HUMAN_SLOT"]                  = "You, {1_Civ}, {2_Team}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_PLAYERS"]               = "Players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_AI_PLAYERS"]            = "AI players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_VICTORY_CONDITIONS"]    = "Victory conditions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_GAME_OPTIONS"]          = "Game options"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_DLC_ALLOWED"]           = "DLC allowed"
-- Preamble for Advanced Setup when random world size is on. Engine hides
-- every slot Root in that state, so the Players group collapses and Add
-- AI is disabled. Tell the user why and point at the remedy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNKNOWN_PLAYERS_STATUS"]      = "AI players cannot be customized while random map size is selected. Pick a specific map size to edit the player list."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FIELD_GAME_NAME"]             = "Game name"
-- Map-type entry suffix announced after the map's name/description when
-- the map's Map_Sizes rows constrain the available world sizes. {1} is a
-- single size label or a comma-separated list.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MAP_SIZE_ONLY"]               = "{1_Size} only"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MAP_SIZE_LIMITED"]            = "sizes: {1_Sizes}"
-- Type-ahead search feedback. NO_MATCH is spoken when a buffer narrows to
-- zero results; CLEARED fires on backspace-to-empty or Esc while search is
-- active. Buffer is echoed raw so the user can hear what they typed.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"]             = "no match for {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"]              = "search cleared"
-- Help overlay (Shift+?). keyLabels use "or" (not slash) so screen readers
-- speak them cleanly; descriptions stay purpose-centric ("Navigate items"
-- not "Previous item" / "Next item"). Pairs must match across handlers or
-- the keyLabel dedupe in HandlerStack.collectHelpEntries won't collapse
-- equivalent entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"]                 = "Help"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"]                  = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"]               = "Letters"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"]            = "Up or down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"]           = "Home or end"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"]        = "Enter or space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"]         = "Left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"]   = "Shift plus left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"]       = "Control plus up or down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"]                = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"]          = "Shift plus tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"]                 = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"]                = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"]              = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"]           = "Question mark"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"]            = "Type to search"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"]         = "Navigate items"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"]   = "Jump to first or last"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"]          = "Activate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"]            = "Adjust value or drill in"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"]        = "Adjust value in larger steps"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"]        = "Jump to previous or next group"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"]          = "Next tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"]          = "Previous tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"]       = "Read screen header"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"]            = "Cancel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"]             = "Close"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"]       = "Cancel edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"]       = "Commit edit"

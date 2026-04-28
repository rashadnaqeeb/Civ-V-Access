-- Mod-authored localized strings, front-end Context.
-- The FrontEnd and InGame skin directories are separate VFS Contexts, so each
-- needs its own strings file with the keys relevant to that Context.
CivVAccess_Strings = CivVAccess_Strings or {}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BOOT_FRONTEND"] = "Accessibility mod ready."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADERBOARD_PREV_PAGE"] = "Previous page"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LEADERBOARD_NEXT_PAGE"] = "Next page"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAIN_MENU"] = "Main menu"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_OTHER_MENU"] = "Other"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SINGLE_PLAYER"] = "Single player"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MULTIPLAYER_SELECT"] = "Multiplayer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_EXIT_CONFIRM"] = "Exit game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LEGAL"] = "Legal notices"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_EULA"] = "End user license agreement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_ERROR"] = "Mod error"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_FRONT_END_POPUP"] = "Notice"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_MENU"] = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_SINGLE_PLAYER"] = "Mods single player"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_MULTIPLAYER"] = "Mods multiplayer"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CONTENT_SWITCH"] = "Updating game data"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WAITING_PLAYERS"] = "Waiting for players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_JOINING_ROOM"] = "Joining room"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LOBBY"] = "Lobby"
-- StagingRoom. Two tabs (Players / Game Options). SLOT_TYPE relabels the
-- per-slot SlotTypePulldown, whose label in the base UI is purely visual
-- positioning. Delta keys are spoken as remote players change state; each
-- leads with the player name so the distinguishing word comes first. HOST
-- is a tail tag appended to the host's slot summary; READY ditto.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_STAGING_ROOM"] = "Multiplayer staging room"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_PLAYERS_TAB"] = "Players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_OPTIONS_TAB"] = "Game options"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SLOT_TYPE"] = "Slot type"
-- No engine-side sibling to TXT_KEY_AD_SETUP_CIVILIZATION / HANDICAP for team;
-- base's TeamLabel holds the value ("Team 1") but there's no standalone "Team"
-- label key in CIV5GameTextInfos_FrontEndScreens.xml. Mod-owned.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEAM"] = "Team"
-- TXT_KEY_AD_SETUP_CIVILIZATION is a format string ("Civilizations: {1_count}")
-- whose Locale expansion with no count comes back empty, which then trips
-- BaseMenu.create's required-displayName assertion when the user activates
-- the pulldown. Mod-owned plain label instead.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CIVILIZATION"] = "Civilization"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_READY"] = "ready"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_HOST"] = "host"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DELTA_STATUS"] = "{1_Name}, {2_Status}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DELTA_CIV"] = "{1_Name}, {2_Civ}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DELTA_TEAM"] = "{1_Name}, {2_Team}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DELTA_HANDICAP"] = "{1_Name}, {2_Handicap}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DELTA_READY"] = "{1_Name} ready"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DELTA_UNREADY"] = "{1_Name} not ready"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_MSG"] = "{1_Name}: {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_HOST_MIGRATION"] = "{1_Name} is now the host"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_DISCONNECT"] = "{1_Name} disconnected"
-- Launch countdown. Base runs a 10-second auto-launch timer with a "Game
-- Starts In: N" banner; we speak the intro once, then integer seconds
-- 5 down to 1, then let LaunchGame fire. Cancel text plays if the timer
-- is stopped mid-countdown (e.g., someone un-readies).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_COUNTDOWN_START"] = "Launching in 10 seconds"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_COUNTDOWN_CANCEL"] = "Countdown cancelled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_COUNTDOWN_TICK"] = "{1_Seconds}"
-- F2 chat panel: title, tab labels, compose field label, empty-history
-- placeholder, and the help-overlay line for F2 itself. The F2 key-label
-- (TXT_KEY_CIVVACCESS_HELP_KEY_F2) lives next to HELP_KEY_F1 further down.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_PANEL"] = "Chat"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_MESSAGES_TAB"] = "Messages"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_COMPOSE_TAB"] = "Compose"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_COMPOSE"] = "Message"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_EMPTY"] = "No messages yet."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_STAGING_CHAT_HELP_OPEN"] = "Open chat"
-- Lobby (PickerReader over the server listing). Row format reads as
-- "<server>, <members>, <map>" so the distinguishing server name comes
-- first; Members format speaks "X of Y" instead of the engine's "X/Y"
-- caption that screen readers mangle as "slash".
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_SERVERS_TAB"] = "Servers"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_DETAILS_TAB"] = "Server details"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_NO_SERVERS"] = "No servers found."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_MEMBERS"] = "{1_Num} of {2_Max}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_PICKER_ROW"] = "{1_Server}, {2_Members}, {3_Map}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_SORT_ASC"] = "ascending"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_SORT_DESC"] = "descending"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOBBY_NO_SELECTION"] =
    "No server selected. Switch to the servers tab to pick one."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_OPTIONS"] = "Options"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CREDITS"] = "Credits"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_SETUP"] = "Set up game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_TYPE"] = "Map type"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MAP_SIZE"] = "Map size"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_DIFFICULTY"] = "Difficulty"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_GAME_SPEED"] = "Game speed"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CIVILIZATION"] = "Civilization"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SET_CIV_NAMES"] = "Name civilization"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SCENARIOS"] = "Scenarios"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_CUSTOM_MOD_GAME"] = "Custom mod game"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_TUTORIAL"] = "Tutorial"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MODS_BROWSER"] = "Browse mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_PREMIUM_CONTENT"] = "DLC"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_WORLD_PICKER"] = "World size"
-- Appended to a tutorial entry when the mod-tracked completion flag for
-- that slot is set. LoadTutorial reads from g_TutorialEntries[i].
-- CompletedIcon:IsHidden().
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TUTORIAL_COMPLETED"] = "completed"
-- Prepended to a Choice item's label when its selectedFn returns truthy.
-- Used on browse-then-commit screens (ScenariosMenu, CustomMod,
-- LoadTutorial) so the user knows which row Start / Enter will launch.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "selected"
-- Civ-picker entry prefixes: colons are read by screen readers as a brief
-- pause, so "Unique ability: Glory of Rome, +25% Wonder production" parses
-- as prefix then value without needing extra connective words.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_ABILITY"] = "Unique ability"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_UNIT"] = "Unique unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_BUILDING"] = "Unique building"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNIQUE_IMPROVEMENT"] = "Unique improvement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LOADING"] = "Loading game"
-- Appended to the load-screen unique-unit / unique-building label so the
-- user hears what the unique stands in for ("Jaguar, unique unit, replaces
-- Warrior"). Matches the Replaces: row sighted players see on hover after
-- loading completes.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLACES"] = "replaces {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "on"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "blank"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "editing {1_Label}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"
-- Disambiguating labels: the game's UI reuses a single label for two visually-
-- separated controls (grid header or fullscreen/windowed toggle distinguishes
-- sighted users). Without that visual context the two items announce
-- identically, so the mod relabels the second half of each pair.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPSCREEN_SMTP_FROM_EMAIL"] = "Sender email address"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPSCREEN_RESOLUTION_FS"] = "Fullscreen resolution"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPSCREEN_RESOLUTION_W"] = "Windowed resolution"
-- Checkbox-gated numeric fields: the checkbox labels the feature, the edit
-- field sets the count. Distinct labels so back-to-back announcements
-- ("Max Turns, on" -> "Max Turns, edit, 500") do not start with the same word.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS"] = "Turn count"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FIELD_TURN_TIMER"] = "Timer seconds"
-- Options-screen countdown popup. Shown 20s after resolution / language
-- change; auto-reverts if the user takes no action.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPTIONS_COUNTDOWN_INTRO"] = "{1_Message}. Reverting in 20 seconds."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_OPTIONS_COUNTDOWN_EXPIRED"] = "Time expired, reverted."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MP_RECONNECTING"] = "Reconnecting"
-- Advanced Setup + MP Setup (nested menus).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_ADVANCED_SETUP"] = "Advanced setup"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"] = "Multiplayer game setup"
-- {1} 1-based slot number, {2} civ description from the slot's pulldown,
-- {3} team text from the slot's team pulldown (already includes "Team N").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_AI_SLOT"] = "AI {1_Num}, {2_Civ}, {3_Team}"
-- Human slot label: {1} civ text (from CivPulldown button or, when custom
-- name is set, from CivName), {2} team text.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HUMAN_SLOT"] = "You, {1_Civ}, {2_Team}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_PLAYERS"] = "Players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_AI_PLAYERS"] = "AI players"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_VICTORY_CONDITIONS"] = "Victory conditions"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_GAME_OPTIONS"] = "Game options"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_GROUP_DLC_ALLOWED"] = "DLC allowed"
-- Preamble for Advanced Setup when random world size is on. Engine hides
-- every slot Root in that state, so the Players group collapses and Add
-- AI is disabled. Tell the user why and point at the remedy.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_UNKNOWN_PLAYERS_STATUS"] =
    "AI players cannot be customized while random map size is selected. Pick a specific map size to edit the player list."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_FIELD_GAME_NAME"] = "Game name"
-- Map-type entry suffix announced after the map's name/description when
-- the map's Map_Sizes rows constrain the available world sizes. {1} is a
-- single size label or a comma-separated list.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MAP_SIZE_ONLY"] = "{1_Size} only"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MAP_SIZE_LIMITED"] = "sizes: {1_Sizes}"
-- Type-ahead search feedback. NO_MATCH is spoken when a buffer narrows to
-- zero results; CLEARED fires on backspace-to-empty or Esc while search is
-- active. Buffer is echoed raw so the user can hear what they typed.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
-- Help overlay (Shift+?). keyLabels use "or" (not slash) so screen readers
-- speak them cleanly; descriptions stay purpose-centric ("Navigate items"
-- not "Previous item" / "Next item"). Pairs must match across handlers or
-- the keyLabel dedupe in HandlerStack.collectHelpEntries won't collapse
-- equivalent entries.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_HELP"] = "Help"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_ENTRY"] = "{1_Key}, {2_Description}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_AZ09"] = "Letters"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN"] = "Up or down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END"] = "Home or end"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER_SPACE"] = "Enter or space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT"] = "Left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_LEFT_RIGHT"] = "Shift plus left or right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_UP_DOWN"] = "Control plus up or down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_TAB"] = "Tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB"] = "Shift plus tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F1"] = "F1"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F2"] = "F2"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ESC"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_ENTER"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_QUESTION"] = "Question mark"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH"] = "Type to search"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NAV_ITEMS"] = "Navigate items"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_FIRST_LAST"] = "Jump to first or last"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ACTIVATE"] = "Activate"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST"] = "Adjust value or drill in"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_ADJUST_BIG"] = "Adjust value in larger steps"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_JUMP_GROUP"] = "Jump to previous or next group"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB"] = "Next tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB"] = "Previous tab"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER"] = "Read screen header"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL"] = "Cancel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE"] = "Close"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CANCEL_EDIT"] = "Cancel edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_COMMIT_EDIT"] = "Commit edit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_KEY_F12"] = "F12"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS"] = "Open settings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS"] = "Close settings"
-- Settings overlay strings. Reachable from every Context that routes
-- through InputRouter, so duplicated in the InGame copy as well.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"] = "Settings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE"] = "Audio cue mode"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"] = "Speech only"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"] = "Speech and audio cues"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"] = "Audio cues only"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME"] = "Master volume"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"] = "Master volume, {1_Num} percent"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE"] = "Scanner auto-move cursor"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION"] = "Cursor follows selected unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE"] = "Cursor coordinates while moving"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"] = "Off"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"] = "Speak before move announcement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"] = "Speak after move announcement"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS"] = "Scanner shows coordinates"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES"] = "Read subtitles"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE"] = "Announce visibility changes while moving"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE"] = "Announce AI combat resolution"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE"] = "Announce visibility changes at turn start"
-- LoadMenu (PickerReader over the save picker). Saves-tab label, details-tab
-- label, empty-list placeholder, delete confirmation (format key takes the
-- save's display name), post-delete acknowledgement. The two PICKER_READER_
-- keys are duplicated from InGame/CivVAccess_InGameStrings_en_US.lua so the
-- Shared PickerReader resolves them from the front-end sandbox too (each
-- Context has its own CivVAccess_Strings table).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_SORT_BY"] = "Sort by"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_SAVES_TAB"] = "Saves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_DETAILS_TAB"] = "Save details"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_NO_SAVES"] = "No saves in this list."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_DELETE_CONFIRM"] = "Delete {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_DELETED"] = "Save deleted."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_LOAD_MOD_VERSION"] = "{1_Name} version {2_Version}"
-- LoadReplayMenu (PickerReader over the replay picker). Engine's
-- TXT_KEY_NO_REPLAYS serves as the empty-list placeholder; delete confirm
-- reuses TXT_KEY_CIVVACCESS_LOAD_DELETE_CONFIRM. Replay-specific tab names
-- and post-delete acknowledgement below.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_LOAD_REPLAY"] = "Load replay"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_LIST_TAB"] = "Replays"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_DETAILS_TAB"] = "Replay details"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_DELETED"] = "Replay deleted."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_NO_SELECTION"] =
    "No replay selected. Switch to the replays tab to pick one."
-- ReplayViewer (the per-turn event log viewer that opens after picking a
-- replay file). Same {Turn, Text} message shape end-game uses, populated
-- from g_ReplayInfo.Messages here. Panel label is the screen-reader name
-- of the engine's ReplayInfoPulldown (Messages / Graphs / Map selector).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_REPLAY_VIEWER"] = "Replay"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_PANEL_LABEL"] = "panel"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_REPLAY_MESSAGE_ROW"] = "Turn {1_Turn}, {2_Text}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_EMPTY"] = "No content for this entry."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_PICKER_READER_NO_SELECTION"] =
    "No save selected. Switch to the saves tab to pick one."
-- InstalledPanel (PickerReader over the installed mods list, child of
-- ModsBrowser). Picker-row label templates carry the mod name then state;
-- confirmation formats take the display name and embed it in a question.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCREEN_INSTALLED_PANEL"] = "Installed mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_LIST_TAB"] = "Mods"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_DETAILS_TAB"] = "Details"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_NO_MODS"] = "No mods installed."
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_SORT_BY"] = "Sort by"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_APPLY_OPTIONS"] = "Apply"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_STATE"] = "State"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_STATE_ENABLED"] = "enabled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_STATE_DISABLED"] = "disabled"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_ENABLE_BLOCKED"] = "Cannot enable: {1_Reason}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_PICKER_ROW"] = "{1_Name}, {2_State}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_PICKER_NEEDS_UPDATE"] = "{1_Name}, {2_State}, needs update"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_VERSION_RANGE"] = "{1_Name} version {2_MinVersion} to {3_MaxVersion}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_VERSION_SUFFIX"] = "{1_Name} version {2_Version}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_DISABLE_CONFIRM"] = "Disable {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_DELETE_CONFIRM"] = "Delete {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_UNSUBSCRIBE_CONFIRM"] = "Unsubscribe from {1_Name}?"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_DELETE_WITH_USER_DATA"] = "Delete with user data"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_MODS_DELETED"] = "Mod removed."
-- Spoken replacements for [ICON_*] markup. Registered into TextFilter by
-- CivVAccess_Icons.lua; the filter substitutes the bracket token inline
-- with the spoken text. Duplicated into the in-game strings file because
-- each Context has its own CivVAccess_Strings table (per-Context sandbox).
-- Keep the two in sync when adding / renaming icon keys.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GOLD"] = "gold"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FOOD"] = "food"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_PRODUCTION"] = "production"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_CULTURE"] = "culture"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_SCIENCE"] = "science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RESEARCH"] = "science"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_FAITH"] = "faith"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_TOURISM"] = "tourism"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE"] = "great people"
-- Dedup-only alias for the singular pairing in base text ("Great Person Focus").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_GREAT_PEOPLE_ALT"] = "great person"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_STRENGTH"] = "combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_RANGE_STRENGTH"] = "ranged combat strength"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_MOVEMENT"] = "moves"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY"] = "happiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_HAPPY_ALT"] = "happy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY"] = "unhappiness"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_UNHAPPY_ALT"] = "unhappy"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_LEFT"] = "left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_ICON_ARROW_RIGHT"] = "right"

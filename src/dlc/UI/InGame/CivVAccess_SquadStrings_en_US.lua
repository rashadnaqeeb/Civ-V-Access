-- Mod-authored strings for the squad layer (Community Patch / Vox Populi
-- only), in-game Context. Extends the CivVAccess_Strings table that
-- CivVAccess_InGameStrings_en_US.lua sets up; Boot loads the base InGame
-- strings first so this file appends. See the translator orientation block
-- at the top of CivVAccess_InGameStrings_en_US.lua for the conventions that
-- apply across all in-game string files. Mod-authored strings do not fire
-- the engine's gender/plural selectors, so plural is handled by the mod's
-- own { one = ..., other = ... } bundles via Text.formatPlural.
CivVAccess_Strings = CivVAccess_Strings or {}

-- ===== Names =====
-- Default name for a squad the player has not renamed. {1_N} is the engine
-- squad number; gaps from deletes are fine, the player navigates a named
-- list, not a contiguous range.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DEFAULT_NAME"] = "Squad {1_N}"

-- ===== Movement status =====
-- Up/Down speaks this only while the squad is moving; idle squads are silent.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVING"] = {
    one = "moving, {1_N} turn left",
    other = "moving, {1_N} turns left",
}
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_STATUS_IDLE"] = "idle"
-- Appended to the movement line: the cursor-relative bearing to the squad's
-- destination ({1_Dir} is the hex-decomposition bearing, e.g. "1ne, 1nw", or
-- "here").
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DESTINATION"] = "destination {1_Dir}"
-- Move-preview turn count (Space in the move sub-mode).
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_PREVIEW_TURNS"] = {
    one = "{1_N} turn",
    other = "{1_N} turns",
}
-- No member can reach the chosen destination.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNREACHABLE"] = "no path"
-- Member count in the full status.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_UNIT_COUNT"] = {
    one = "{1_N} unit",
    other = "{1_N} units",
}

-- ===== Wake modes =====
-- End-of-move behavior: 0 sentry on arrival, 1 wake on arrival, 2 wake when
-- the whole squad has arrived.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_SENTRY"] = "sentry on arrival"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_EACH"] = "wake on arrival"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_ALL"] = "wake when all arrive"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_WAKE_LABEL"] = "wake mode, {1_Mode}"

-- ===== Escort =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT"] = "escort civilians"
-- Spoken in the full status only when escort is on.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORT_ON"] = "escorting civilians"

-- ===== Per-unit status tokens =====
-- Spoken wherever a unit's status is read (selection, info, cursor plot,
-- squad row), not just in the squad screens.
-- A non-combat unit currently shielded by a combat unit in an escort move;
-- {1_Name} is the escorting unit.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED_BY"] = "escorted by {1_Name}"
-- Same state when the escorting unit can't be identified.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ESCORTED"] = "escorted"
-- A "wake when all arrive" member that has reached its spot and is waiting for
-- the rest of its squad to arrive before waking; {1_Name} is the squad.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HOLDING"] = "holding for {1_Name}"

-- ===== Map-mode feedback =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NONE"] = "no squads"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"] = "no units"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_NO_UNIT_SELECTED"] = "no unit selected"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_REMOVED"] = "removed from {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO"] = "added to {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ALREADY_IN"] = "already in {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO"] = "moved to {1_Name}"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_ORDERED"] = "{1_Name} moving"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_CANCELED"] = "{1_Name} move canceled"
-- Spoken on entering the move sub-mode (Alt+Up), where the action keys carry
-- the squad-name confirmation the silent Up/Down scan omits.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_MODE"] = "{1_Name}, choose destination"

-- ===== Menu =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MENU_NAME"] = "Squads"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW"] = "add new squad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CREATED"] = "{1_Name} created"
-- Editor action buttons. Cancel move only appears while the squad is moving.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_BUTTON"] = "move squad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_CANCEL_MOVE"] = "cancel move"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETE"] = "delete squad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_DELETED"] = "{1_Name} deleted"

-- ===== Help overlay (map-mode squad section) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_SQUAD"] = "Up/Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_SQUAD"] = "Cycle squads, speaks name and movement status"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_UNIT"] = "Left/Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_UNIT"] = "Cycle units in the focused squad"
-- The "/" key keycap moves on national layouts, the same as the unit-info key
-- it shares; KeyLayout.resolveKeyLabel picks the per-profile variant.
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT"] = "Alt plus slash"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_AZERTY"] = "Alt plus exclamation mark"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_QWERTZ"] = "Alt plus hyphen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT_ITALIAN"] = "Alt plus hyphen"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_SELECT"] = "Select the focused unit"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_REMOVE"] = "Alt+Left"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_REMOVE"] = "Remove the focused unit from its squad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_ADD"] = "Alt+Right"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_ADD"] = "Add the selected unit to the focused squad"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MOVE"] = "Alt+Up"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MOVE"] =
    "Move the focused squad, or read a move in progress and press again to reissue it"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_EDITOR"] = "Alt+Down"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_EDITOR"] = "Open the focused squad's settings"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU"] = "F11"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU"] = "Open the squad menu"

-- ===== Help overlay (move sub-mode) =====
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_PREVIEW"] = "Space"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_PREVIEW"] = "Preview turns to the cursor tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_COMMIT"] = "Enter"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_COMMIT"] = "Send the squad to the cursor tile"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_KEY_CANCEL"] = "Escape"
CivVAccess_Strings["TXT_KEY_CIVVACCESS_SQUAD_MOVE_HELP_DESC_CANCEL"] = "Cancel the move"

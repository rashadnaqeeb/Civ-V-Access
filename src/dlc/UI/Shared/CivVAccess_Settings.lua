-- Settings overlay. Opens via the F12 pre-walk hook in InputRouter and
-- gives the user a single place to flip mod-wide preferences. Built as a
-- BaseMenu handler with three items today (audio cue mode, master volume,
-- scanner auto-move); new settings drop in by appending to the items list.
--
-- The handler is reachable from every Context that routes through
-- InputRouter (front-end and in-game both), so its items must not assume
-- in-game state is available. Persistence goes through the canonical pref
-- key + civvaccess_shared cache field for each setting; the in-game
-- consumer module (ScannerNav, AudioCueMode, VolumeControl) reads the
-- same cache so the menu and its consumers stay in sync without a
-- registration system.

Settings = {}

-- Shared persistence helpers for the scanner auto-move toggle. Mirrors the
-- key + cache field that ScannerNav.toggleAutoMove writes; both paths land
-- on civvaccess_shared.scannerAutoMove so a Shift+End from the binding and
-- a flip from this menu produce the same observable state.
local function getScannerAutoMove()
    return civvaccess_shared.scannerAutoMove == true
end

local function setScannerAutoMove(v)
    local b = v and true or false
    civvaccess_shared.scannerAutoMove = b
    Prefs.setBool("ScannerAutoMove", b)
end

-- Read-subtitles toggle. Off by default: several screens (LoadScreen
-- DawnOfMan, leader dialogue, tech-award quote, advisor intros) declare
-- silentFirstOpen so their preamble doesn't talk over the engine's own
-- narration audio. Flipping this on bypasses that suppression so the user
-- hears the screen reader's preamble layered on top. Lives on
-- civvaccess_shared so BaseMenuCore reads it live at the gate site and
-- toggling takes effect on the next screen open.
if civvaccess_shared.readSubtitles == nil then
    civvaccess_shared.readSubtitles = Prefs.getBool("ReadSubtitles", false)
end

local function getReadSubtitles()
    return civvaccess_shared.readSubtitles == true
end

local function setReadSubtitles(v)
    local b = v and true or false
    civvaccess_shared.readSubtitles = b
    Prefs.setBool("ReadSubtitles", b)
end

-- Cursor-follows-selected-unit toggle. On by default: the hex cursor
-- jumps to the unit's tile both when the unit becomes selected and when
-- it finishes a move. Flipping it off keeps the cursor put in both
-- cases; the selection announcement still includes the direction from
-- cursor to unit, and the explicit "speak current unit" hotkey
-- recenters on demand. UnitControl reads
-- civvaccess_shared.cursorFollowsSelection live on every event so
-- toggling takes effect immediately.
if civvaccess_shared.cursorFollowsSelection == nil then
    civvaccess_shared.cursorFollowsSelection = Prefs.getBool("CursorFollowsSelection", true)
end

local function getCursorFollowsSelection()
    return civvaccess_shared.cursorFollowsSelection == true
end

local function setCursorFollowsSelection(v)
    local b = v and true or false
    civvaccess_shared.cursorFollowsSelection = b
    Prefs.setBool("CursorFollowsSelection", b)
end

-- Cursor-relative coordinate mode. Off by default: most users orient by
-- the directional reads (cardinal-distance from cursor / capital), and
-- speaking the coordinate on every step adds noise. Prepend / append put
-- the capital-relative (x, y) at the start or end of every cursor-move
-- announcement; Cursor.coordinates (Shift+S) ignores the mode and always
-- speaks the coord. Stored as a string on civvaccess_shared so CursorCore
-- reads it as "off" / "prepend" / "append" directly; Prefs persists an
-- int (0/1/2) since the prefs file has no string type.
local CURSOR_COORD_BY_INT = { [0] = "off", [1] = "prepend", [2] = "append" }
local CURSOR_COORD_BY_NAME = { off = 0, prepend = 1, append = 2 }
if civvaccess_shared.cursorCoordMode == nil then
    local stored = Prefs.getInt("CursorCoordMode", 0)
    civvaccess_shared.cursorCoordMode = CURSOR_COORD_BY_INT[stored] or "off"
end

local function getCursorCoordMode()
    return civvaccess_shared.cursorCoordMode or "off"
end

local function setCursorCoordMode(name)
    if CURSOR_COORD_BY_NAME[name] == nil then
        Log.warn("Settings.setCursorCoordMode: invalid mode " .. tostring(name))
        return
    end
    civvaccess_shared.cursorCoordMode = name
    Prefs.setInt("CursorCoordMode", CURSOR_COORD_BY_NAME[name])
end

-- Scanner coordinate-append toggle. Off by default. When on, scanner
-- announcements (each cycle's "<name>. <dir>. <N> of <M>.") gain an
-- "<x>, <y>" segment between dir and the count. ScannerNav reads
-- civvaccess_shared.scannerCoords live in formatInstance.
if civvaccess_shared.scannerCoords == nil then
    civvaccess_shared.scannerCoords = Prefs.getBool("ScannerCoords", false)
end

local function getScannerCoords()
    return civvaccess_shared.scannerCoords == true
end

local function setScannerCoords(v)
    local b = v and true or false
    civvaccess_shared.scannerCoords = b
    Prefs.setBool("ScannerCoords", b)
end

-- Reveal-announcement toggle. On by default: tells the user what just
-- appeared on the map after a unit move (or any reveal source). Reads
-- live from civvaccess_shared.revealAnnounce inside the listeners in
-- RevealAnnounce, so toggling takes effect on the next tick.
if civvaccess_shared.revealAnnounce == nil then
    civvaccess_shared.revealAnnounce = Prefs.getBool("RevealAnnounce", true)
end

local function getRevealAnnounce()
    return civvaccess_shared.revealAnnounce == true
end

local function setRevealAnnounce(v)
    local b = v and true or false
    civvaccess_shared.revealAnnounce = b
    Prefs.setBool("RevealAnnounce", b)
end

-- AI-combat speech toggle. On by default: combats the active player
-- didn't initiate (AI attacking the player, or AI vs AI on a visible
-- plot) speak through onCombatResolved. When off, those combats still
-- land in the F7 Combat Log -- only the live speech is gated. Player-
-- initiated combats are unaffected (the gate sits on the speech path
-- only when attackerPlayer != activePlayer). UnitControl reads the
-- shared field live, so toggling takes effect on the next combat.
if civvaccess_shared.aiCombatAnnounce == nil then
    civvaccess_shared.aiCombatAnnounce = Prefs.getBool("AiCombatAnnounce", true)
end

local function getAiCombatAnnounce()
    return civvaccess_shared.aiCombatAnnounce == true
end

local function setAiCombatAnnounce(v)
    local b = v and true or false
    civvaccess_shared.aiCombatAnnounce = b
    Prefs.setBool("AiCombatAnnounce", b)
end

-- Foreign-unit-watch speech toggle. On by default: the four-line turn-
-- start summary of foreign units that entered or left view during the AI
-- turn speaks at player-turn start. When off, the lines land silently in
-- the F7 Turn Log instead. The civvaccess_shared.foreignUnitDelta write
-- happens regardless so F7 always shows what the diff produced.
if civvaccess_shared.foreignUnitWatchAnnounce == nil then
    civvaccess_shared.foreignUnitWatchAnnounce = Prefs.getBool("ForeignUnitWatchAnnounce", true)
end

local function getForeignUnitWatchAnnounce()
    return civvaccess_shared.foreignUnitWatchAnnounce == true
end

local function setForeignUnitWatchAnnounce(v)
    local b = v and true or false
    civvaccess_shared.foreignUnitWatchAnnounce = b
    Prefs.setBool("ForeignUnitWatchAnnounce", b)
end

-- Foreign-clear-watch speech toggle. On by default: the one-line turn-
-- start summary of camps and ruins others claimed in the active team's
-- view during the AI turn. When off, the line lands silently in the F7
-- Turn Log instead. The civvaccess_shared.foreignClearDelta write
-- happens regardless so F7 always shows what the watcher produced.
if civvaccess_shared.foreignClearWatchAnnounce == nil then
    civvaccess_shared.foreignClearWatchAnnounce = Prefs.getBool("ForeignClearWatchAnnounce", true)
end

local function getForeignClearWatchAnnounce()
    return civvaccess_shared.foreignClearWatchAnnounce == true
end

local function setForeignClearWatchAnnounce(v)
    local b = v and true or false
    civvaccess_shared.foreignClearWatchAnnounce = b
    Prefs.setBool("ForeignClearWatchAnnounce", b)
end

local function audioCueModeChoice(modeConst, textKey)
    return BaseMenuItems.Choice({
        textKey = textKey,
        selectedFn = function()
            return AudioCueMode.getMode() == modeConst
        end,
        activate = function()
            AudioCueMode.setMode(modeConst)
        end,
    })
end

local function cursorCoordModeChoice(name, textKey)
    return BaseMenuItems.Choice({
        textKey = textKey,
        selectedFn = function()
            return getCursorCoordMode() == name
        end,
        activate = function()
            setCursorCoordMode(name)
        end,
    })
end

local function buildItems()
    local masterVolumeFormat = "TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"
    return {
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE",
            items = {
                audioCueModeChoice(AudioCueMode.MODE_SPEECH, "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"),
                audioCueModeChoice(
                    AudioCueMode.MODE_SPEECH_PLUS_CUE,
                    "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"
                ),
                audioCueModeChoice(AudioCueMode.MODE_CUE_ONLY, "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"),
            },
        }),
        BaseMenuItems.VirtualSlider({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME",
            getValue = VolumeControl.get,
            setValue = VolumeControl.set,
            labelFn = function(value)
                local percent = math.floor(value * 100 + 0.5)
                return Text.format(masterVolumeFormat, percent)
            end,
            step = 0.05,
            bigStep = 0.20,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE",
            getValue = getScannerAutoMove,
            setValue = setScannerAutoMove,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION",
            getValue = getCursorFollowsSelection,
            setValue = setCursorFollowsSelection,
        }),
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE",
            items = {
                cursorCoordModeChoice("off", "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"),
                cursorCoordModeChoice("prepend", "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"),
                cursorCoordModeChoice("append", "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"),
            },
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS",
            getValue = getScannerCoords,
            setValue = setScannerCoords,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES",
            getValue = getReadSubtitles,
            setValue = setReadSubtitles,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_REVEAL_ANNOUNCE",
            getValue = getRevealAnnounce,
            setValue = setRevealAnnounce,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_AI_COMBAT_ANNOUNCE",
            getValue = getAiCombatAnnounce,
            setValue = setAiCombatAnnounce,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_UNIT_WATCH_ANNOUNCE",
            getValue = getForeignUnitWatchAnnounce,
            setValue = setForeignUnitWatchAnnounce,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_FOREIGN_CLEAR_ANNOUNCE",
            getValue = getForeignClearWatchAnnounce,
            setValue = setForeignClearWatchAnnounce,
        }),
    }
end

-- F12 binding spec. Help-list entry uses the curated label so the help
-- overlay reads "F12: Close settings" rather than the auto-derived name.
local SETTINGS_HELP_EXTRAS = {
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F12",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_CLOSE_SETTINGS",
    },
}

function Settings.open()
    local handler = BaseMenu.create({
        name = "Settings",
        displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SETTINGS"),
        items = buildItems(),
        capturesAllInput = true,
        escapePops = true,
        helpExtras = SETTINGS_HELP_EXTRAS,
    })

    -- F12 while Settings is on top closes it. InputRouter's pre-walk hook
    -- bails when top.name == "Settings" so this binding gets a chance to
    -- fire. Mirrors the ?-close binding inside Help.
    handler.bindings[#handler.bindings + 1] = {
        key = Keys.VK_F12,
        mods = 0,
        description = "Close settings",
        fn = function()
            HandlerStack.removeByName("Settings", true)
        end,
    }

    HandlerStack.push(handler)
end

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

-- Standard bool-pref helper. Initializes civvaccess_shared[field] from
-- Prefs once (idempotent if a sibling module already seeded it), then
-- returns get/set closures that read the live cache and persist writes
-- back to Prefs. The shared cache survives the load-from-game env wipe
-- so toggling here takes effect immediately for any consumer reading
-- civvaccess_shared[field] live.
local function defineBoolPref(field, prefKey, default)
    if civvaccess_shared[field] == nil then
        civvaccess_shared[field] = Prefs.getBool(prefKey, default)
    end
    local function get()
        return civvaccess_shared[field] == true
    end
    local function set(v)
        local b = v and true or false
        civvaccess_shared[field] = b
        Prefs.setBool(prefKey, b)
    end
    return get, set
end

-- Scanner auto-move toggle. Initialization lives in ScannerNav (which
-- reads the field at every cycle); calling defineBoolPref here is a
-- no-op when ScannerNav already seeded the cache, and a safe init
-- otherwise.
local getScannerAutoMove, setScannerAutoMove = defineBoolPref("scannerAutoMove", "ScannerAutoMove", false)

-- Read-subtitles toggle. Off by default: several screens (LoadScreen
-- DawnOfMan, leader dialogue, tech-award quote, advisor intros) declare
-- silentFirstOpen so their preamble doesn't talk over the engine's own
-- narration audio. Flipping this on bypasses that suppression so the user
-- hears the screen reader's preamble layered on top.
local getReadSubtitles, setReadSubtitles = defineBoolPref("readSubtitles", "ReadSubtitles", false)

-- Cursor-follows-selected-unit toggle. On by default: the hex cursor
-- jumps to the unit's tile both when the unit becomes selected and when
-- it finishes a move. Flipping it off keeps the cursor put in both
-- cases; the selection announcement still includes the direction from
-- cursor to unit, and the explicit "speak current unit" hotkey
-- recenters on demand. UnitControl reads the cache live on every event.
local getCursorFollowsSelection, setCursorFollowsSelection =
    defineBoolPref("cursorFollowsSelection", "CursorFollowsSelection", true)

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

-- Always-announce-territory toggle. Off by default: the cursor's owner
-- prefix only fires on civ-border crossings (the diff in CursorCore against
-- _lastOwnerIdentity). When on, every cursor move into a civ-owned tile
-- prepends the civ name; unclaimed tiles get no prefix at all. CursorCore
-- reads the cache live in announceForMove. The PlotSections city banner
-- also reads the same flag and drops the civ adjective when on, since
-- the prefix already says it -- "Arabia. Rome." instead of "Arabia.
-- Arabian Rome." on every step within Arabia.
local getBorderAlwaysAnnounce, setBorderAlwaysAnnounce =
    defineBoolPref("borderAlwaysAnnounce", "BorderAlwaysAnnounce", false)

-- Scanner coordinate-append toggle. Off by default. When on, scanner
-- announcements (each cycle's "<name>. <dir>. <N> of <M>.") gain an
-- "<x>, <y>" segment between dir and the count. ScannerNav reads the
-- cache live in formatInstance.
local getScannerCoords, setScannerCoords = defineBoolPref("scannerCoords", "ScannerCoords", false)

-- Reveal-announcement toggle. On by default: tells the user what just
-- appeared on the map after a unit move (or any reveal source). Reads
-- live from the cache inside the listeners in RevealAnnounce, so
-- toggling takes effect on the next tick.
local getRevealAnnounce, setRevealAnnounce = defineBoolPref("revealAnnounce", "RevealAnnounce", true)

-- AI-combat speech toggle. On by default: combats the active player
-- didn't initiate (AI attacking the player, or AI vs AI on a visible
-- plot) speak through onCombatResolved. When off, those combats still
-- land in the F7 Combat Log -- only the live speech is gated. Player-
-- initiated combats are unaffected (the gate sits on the speech path
-- only when attackerPlayer != activePlayer). UnitControl reads the
-- shared field live, so toggling takes effect on the next combat.
local getAiCombatAnnounce, setAiCombatAnnounce = defineBoolPref("aiCombatAnnounce", "AiCombatAnnounce", true)

-- Foreign-unit-watch speech toggle. On by default: the four-line turn-
-- start summary of foreign units that entered or left view during the AI
-- turn speaks at player-turn start. When off, the lines land silently in
-- the F7 Turn Log instead. The civvaccess_shared.foreignUnitDelta write
-- happens regardless so F7 always shows what the diff produced.
local getForeignUnitWatchAnnounce, setForeignUnitWatchAnnounce =
    defineBoolPref("foreignUnitWatchAnnounce", "ForeignUnitWatchAnnounce", true)

-- Foreign-clear-watch speech toggle. On by default: the one-line turn-
-- start summary of camps and ruins others claimed in the active team's
-- view during the AI turn. When off, the line lands silently in the F7
-- Turn Log instead. The civvaccess_shared.foreignClearDelta write
-- happens regardless so F7 always shows what the watcher produced.
local getForeignClearWatchAnnounce, setForeignClearWatchAnnounce =
    defineBoolPref("foreignClearWatchAnnounce", "ForeignClearWatchAnnounce", true)

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
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE",
            getValue = getBorderAlwaysAnnounce,
            setValue = setBorderAlwaysAnnounce,
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

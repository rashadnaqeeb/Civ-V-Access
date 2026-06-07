-- Settings overlay. Opens via the F12 pre-walk hook in InputRouter and
-- gives the user a single place to flip mod-wide preferences. Built as a
-- BaseMenu handler with five top-level drillable groups: General, Cursor,
-- Audio, Scanner, Notifications. New settings drop into the group whose
-- feature they belong to.
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

-- Read-subtitles toggle. On by default: several screens (LoadScreen
-- DawnOfMan, leader dialogue, tech-award quote, advisor intros) declare
-- silentFirstOpen so their preamble doesn't talk over the engine's own
-- narration audio. With this flag on, the suppression is bypassed and the
-- screen reader speaks the preamble over the engine narration; flipping
-- it off restores the deferred-preamble behavior.
local getReadSubtitles, setReadSubtitles = defineBoolPref("readSubtitles", "ReadSubtitles", true)

-- On-screen tile highlights toggle. On by default: the rings are a visual aid
-- for a sighted companion and produce no speech, so they cost the blind
-- player nothing. The setter persists the pref, then asks MapHighlight to
-- redraw or clear the rings immediately -- MapHighlight is nil in the
-- front-end Settings Context, where only the pref write matters.
local getMapHighlight, setMapHighlightPref = defineBoolPref("mapHighlightEnabled", "MapHighlight", true)
local function setMapHighlight(v)
    setMapHighlightPref(v)
    if MapHighlight ~= nil then
        MapHighlight.applyEnabled()
    end
end

-- Long-form direction toggle. Off by default: the short tokens (ne, se) are
-- the established default and existing users orient by them. When on, every
-- spoken direction across the mod (cursor, scanner, surveyor, river edges,
-- path previews) swaps to the spelled form ("northeast") -- HexGeom.dirText
-- reads this cache live, so toggling takes effect on the next readout.
local getDirectionLongForm, setDirectionLongForm = defineBoolPref("directionLongForm", "DirectionLongForm", false)

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
-- announcement; they also switch Cursor.coordinates (Shift+S) from the
-- bearing-from-capital readout to that raw coordinate. Stored as a
-- string on civvaccess_shared so CursorCore
-- reads it as "off" / "prepend" / "append" directly; Prefs persists an
-- int (0/1/2) since the prefs file has no string type.
local CURSOR_COORD_BY_INT = { [0] = "off", [1] = "prepend", [2] = "append" }
local CURSOR_COORD_BY_NAME = { off = 0, prepend = 1, append = 2 }
if civvaccess_shared.cursorCoordMode == nil then
    local stored = Prefs.getInt("CursorCoordMode", 0)
    civvaccess_shared.cursorCoordMode = CURSOR_COORD_BY_INT[stored] or "off"
end

-- Keyboard-layout override. "auto" (default) defers to the proxy-detected
-- profile; the other three force a specific cluster remap. Stored as a
-- string on civvaccess_shared so KeyLayout reads it directly; Prefs persists
-- an int since the prefs file has no string type. KeyLayout reads the cache
-- live, so a change takes effect on the next keypress.
local KB_PROFILE_BY_INT = { [0] = "auto", [1] = "qwerty", [2] = "azerty", [3] = "qwertz", [4] = "italian" }
local KB_PROFILE_BY_NAME = { auto = 0, qwerty = 1, azerty = 2, qwertz = 3, italian = 4 }
if civvaccess_shared.keyboardProfileOverride == nil then
    local stored = Prefs.getInt("KeyboardProfileOverride", 0)
    civvaccess_shared.keyboardProfileOverride = KB_PROFILE_BY_INT[stored] or "auto"
end

local function getKeyboardProfileOverride()
    return civvaccess_shared.keyboardProfileOverride or "auto"
end

local function setKeyboardProfileOverride(name)
    if KB_PROFILE_BY_NAME[name] == nil then
        Log.warn("Settings.setKeyboardProfileOverride: invalid profile " .. tostring(name))
        return
    end
    civvaccess_shared.keyboardProfileOverride = name
    Prefs.setInt("KeyboardProfileOverride", KB_PROFILE_BY_NAME[name])
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

-- Adjacent-enemy warning toggle. Off by default: prepends a short "enemy
-- near" tag to every cursor-move announcement on any revealed tile with
-- at least one visible enemy unit (combat or not) on a visible neighbor.
-- Cursor-tile visibility doesn't gate -- a fogged cursor with a visible
-- enemy on a visible neighbor still warns; only the neighbor's visibility
-- gates the read. Distinct from the X-key ZoC line, which is combat-only
-- because ZoC is a combat mechanic; CursorCore reads this cache live on
-- every move.
local getEnemyAdjacentWarn, setEnemyAdjacentWarn = defineBoolPref("enemyAdjacentWarn", "EnemyAdjacentWarn", false)

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

-- Scanner compass-direction toggle. Off by default. When on, the scanner's
-- direction segment switches from the two-axis hex decomposition ("1ne, 2e")
-- to a single 8-point compass bearing paired with cube distance ("3e", or
-- "2n" for a target whose hex decomposition would have been the symmetric
-- "1ne, 1nw"). ScannerNav reads the cache live in formatInstance and
-- distanceFromCursor. Scoped to the scanner -- the cursor selection
-- readout, surveyor, bookmarks, military overview, path diagnostic, and
-- unit-finished-move announcements stay on the hex decomposition.
local getScannerCompassDirection, setScannerCompassDirection =
    defineBoolPref("scannerCompassDirection", "ScannerCompassDirection", false)

-- Scanner directional-beep toggle. Off by default. When on, every scanner
-- cycle (item, instance, subcategory, category, search land, End-key
-- distance probe) fires a short beep whose pan / pitch / volume encode
-- the displacement from the readout origin to the cycled-to entry's
-- plot, using the same per-axis math as the audio beacons. ScannerBeep
-- reads the cache live in its play function, and the beep shares the
-- BeaconVolume / BeaconRange sliders -- the F12 Audio group is the
-- single point of volume / range control for this entire family of
-- spatial audio cues. Initialization mirrors scannerAutoMove: ScannerBeep
-- seeds the cache from Prefs at module load; calling defineBoolPref here
-- is a no-op when the cache is already populated.
local getScannerDirectionBeep, setScannerDirectionBeep =
    defineBoolPref("scannerDirectionBeep", "ScannerDirectionBeep", false)

-- Selected-unit-only waypoint scope, one toggle per surface. Both on by
-- default: the shipped behavior shows only the selected unit's queued
-- path. Turning a toggle off opens that surface up to every owned unit --
-- the scanner lists each unit's stops as its own item, and the cursor
-- glance names other units whose path crosses the tile. ScannerBackend-
-- Waypoints / PlotSections.waypoint read these caches live; the value is
-- treated as "selected only" unless explicitly false, so a surface stays
-- restricted even before this seed runs.
local getScannerWaypointsSelectedOnly, setScannerWaypointsSelectedOnly =
    defineBoolPref("scannerSelectedWaypointsOnly", "ScannerSelectedWaypointsOnly", true)
local getCursorWaypointsSelectedOnly, setCursorWaypointsSelectedOnly =
    defineBoolPref("cursorSelectedWaypointsOnly", "CursorSelectedWaypointsOnly", true)

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

-- Single-player turn-start cue. Off by default. When on, plays the
-- engine's "It's your turn" sound (AS2D_EVENT_ACTIVE_PLAYER_TURN_START)
-- at every ActivePlayerTurnStart in single player; useful when the
-- player alt-tabs during the AI turn. MP / hotseat are unaffected:
-- base MPTurnPanel.lua already plays the same cue unconditionally
-- there, and Turn.lua's listener gates itself off in MP so we don't
-- double-play.
local getTurnStartSound, setTurnStartSound = defineBoolPref("turnStartSound", "TurnStartSound", false)

-- Per-owner unit-movement announcements. Each owner bucket has its own toggle,
-- all off by default: a move speaks only when its bucket's toggle is on, while
-- the F7 Unit Moves log populates regardless. UnitMoveLog reads these
-- civvaccess_shared fields live, so a toggle takes effect on the next move.
-- Defined here (not in UnitMoveLog, which is in-game only) because the Settings
-- screen renders in the front-end Context too.
local getUnitMoveOwn, setUnitMoveOwn = defineBoolPref("unitMoveOwn", "UnitMoveOwn", false)
local getUnitMoveHostile, setUnitMoveHostile = defineBoolPref("unitMoveHostile", "UnitMoveHostile", false)
local getUnitMoveNeutral, setUnitMoveNeutral = defineBoolPref("unitMoveNeutral", "UnitMoveNeutral", false)
local getUnitMoveCityState, setUnitMoveCityState = defineBoolPref("unitMoveCityState", "UnitMoveCityState", false)
local getUnitMoveBarbarian, setUnitMoveBarbarian = defineBoolPref("unitMoveBarbarian", "UnitMoveBarbarian", false)
local getUnitMoveTeammate, setUnitMoveTeammate = defineBoolPref("unitMoveTeammate", "UnitMoveTeammate", false)

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

local function keyboardProfileChoice(name, textKey)
    return BaseMenuItems.Choice({
        textKey = textKey,
        selectedFn = function()
            return getKeyboardProfileOverride() == name
        end,
        activate = function()
            setKeyboardProfileOverride(name)
        end,
    })
end

local function buildItems()
    local masterVolumeFormat = "TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"
    local beaconVolumeFormat = "TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME_VALUE"
    local generalGroup = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_GROUP_GENERAL",
        items = {
            -- Verbose UI: appends screen-reader-style metadata (control type
            -- tags, position-within-list, table row/column counts, "table"
            -- suffix on tab names) to BaseMenu and BaseTable announcements.
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_VERBOSE_UI",
                getValue = Verbosity.isOn,
                setValue = Verbosity.setOn,
            }),
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES",
                getValue = getReadSubtitles,
                setValue = setReadSubtitles,
            }),
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_MAP_HIGHLIGHT",
                getValue = getMapHighlight,
                setValue = setMapHighlight,
            }),
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_DIRECTION_LONG_FORM",
                getValue = getDirectionLongForm,
                setValue = setDirectionLongForm,
            }),
            -- Keyboard-layout remap. Auto follows the proxy's detection;
            -- the explicit choices let a player whose keyboard and locale
            -- disagree (e.g. a French player on a QWERTY laptop) pick the
            -- layout their fingers actually use.
            BaseMenuItems.Group({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_KEYBOARD_LAYOUT",
                items = {
                    keyboardProfileChoice("auto", "TXT_KEY_CIVVACCESS_SETTINGS_KEYBOARD_AUTO"),
                    keyboardProfileChoice("qwerty", "TXT_KEY_CIVVACCESS_SETTINGS_KEYBOARD_QWERTY"),
                    keyboardProfileChoice("azerty", "TXT_KEY_CIVVACCESS_SETTINGS_KEYBOARD_AZERTY"),
                    keyboardProfileChoice("qwertz", "TXT_KEY_CIVVACCESS_SETTINGS_KEYBOARD_QWERTZ"),
                    keyboardProfileChoice("italian", "TXT_KEY_CIVVACCESS_SETTINGS_KEYBOARD_ITALIAN"),
                },
            }),
        },
    })
    local cursorGroup = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_GROUP_CURSOR",
        items = {
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_FOLLOWS_SELECTION",
                getValue = getCursorFollowsSelection,
                setValue = setCursorFollowsSelection,
            }),
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_BORDER_ALWAYS_ANNOUNCE",
                getValue = getBorderAlwaysAnnounce,
                setValue = setBorderAlwaysAnnounce,
            }),
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_ENEMY_ADJACENT_WARN",
                getValue = getEnemyAdjacentWarn,
                setValue = setEnemyAdjacentWarn,
            }),
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_WAYPOINTS_SELECTED_ONLY",
                getValue = getCursorWaypointsSelectedOnly,
                setValue = setCursorWaypointsSelectedOnly,
            }),
            BaseMenuItems.Group({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_MODE",
                items = {
                    cursorCoordModeChoice("off", "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_OFF"),
                    cursorCoordModeChoice("prepend", "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_PREPEND"),
                    cursorCoordModeChoice("append", "TXT_KEY_CIVVACCESS_SETTINGS_CURSOR_COORD_APPEND"),
                },
            }),
        },
    })
    -- Audio group gathers every volume / range / cue-mode control for the
    -- mod's proxy-mixed sound layer: the per-hex cue master and its
    -- speech / cue mode, plus the bookmark-beacon volume and range (which
    -- the scanner directional beep also rides). Keeping them together is
    -- why the scanner beep's controlling sliders live here, not in Scanner.
    local audioGroup = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_GROUP_AUDIO",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_MASTER_VOLUME",
                getValue = VolumeControl.get,
                setValue = VolumeControl.set,
                labelFn = function(value)
                    local percent = math.floor(value * 100 + 0.5)
                    return Text.format(masterVolumeFormat, percent)
                end,
                step = 0.01,
                bigStep = 0.10,
            }),
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
            -- Beacon master volume. Drives the proxy's dedicated beacon
            -- sound group in parallel with the main "Master volume"
            -- slider above; the two faders are independent (raising one
            -- does not attenuate the other). Slider position t in [0, 1]
            -- maps to group volume t * BeaconVolume.MAX (= t, since MAX
            -- is 1.0); kept as a multiplication so a future rebound can
            -- change MAX without touching the slider plumbing.
            BaseMenuItems.VirtualSlider({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_BEACON_VOLUME",
                getValue = function()
                    return BeaconVolume.get() / BeaconVolume.MAX
                end,
                setValue = function(t)
                    BeaconVolume.set(t * BeaconVolume.MAX)
                end,
                labelFn = function(t)
                    local percent = math.floor(t * 100 + 0.5)
                    return Text.format(beaconVolumeFormat, percent)
                end,
                step = 0.01,
                bigStep = 0.10,
            }),
            -- Beacon audible-range slider. Adjusts the linear-falloff distance
            -- where a bookmark beacon goes silent; default 30 hexes, range
            -- 5..100 stepped at 5. The slider operates in [0,1]; BeaconRange.
            -- toUnit / fromUnit map between the normalized handle and the
            -- integer hex value so each tick lands on a STEP-multiple.
            -- Beacons.updateBeaconParams reads BeaconRange.get() live, so a
            -- tweak takes effect on the next cursor move with no explicit
            -- notification.
            BaseMenuItems.VirtualSlider({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE",
                getValue = function()
                    return BeaconRange.toUnit(BeaconRange.get())
                end,
                setValue = function(t)
                    BeaconRange.set(BeaconRange.fromUnit(t))
                end,
                labelFn = function(t)
                    return Text.format("TXT_KEY_CIVVACCESS_SETTINGS_BEACON_RANGE_VALUE", BeaconRange.fromUnit(t))
                end,
                step = BeaconRange.STEP_UNIT,
                bigStep = BeaconRange.BIG_STEP_UNIT,
            }),
        },
    })
    local scannerItems = {
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_AUTO_MOVE",
            getValue = getScannerAutoMove,
            setValue = setScannerAutoMove,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COORDS",
            getValue = getScannerCoords,
            setValue = setScannerCoords,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_COMPASS_DIRECTION",
            getValue = getScannerCompassDirection,
            setValue = setScannerCompassDirection,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_DIRECTION_BEEP",
            getValue = getScannerDirectionBeep,
            setValue = setScannerDirectionBeep,
        }),
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_SCANNER_WAYPOINTS_SELECTED_ONLY",
            getValue = getScannerWaypointsSelectedOnly,
            setValue = setScannerWaypointsSelectedOnly,
        }),
    }
    -- Custom scanner categories live only in-game (the scanner exists only
    -- there). ScannerFavorites is absent in the front-end Settings Context,
    -- so the drillable simply doesn't appear there.
    if ScannerFavorites ~= nil then
        scannerItems[#scannerItems + 1] = ScannerFavorites.settingsGroup()
    end
    local scannerGroup = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_GROUP_SCANNER",
        items = scannerItems,
    })
    local notificationsGroup = BaseMenuItems.Group({
        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_GROUP_NOTIFICATIONS",
        items = {
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
            BaseMenuItems.VirtualToggle({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_TURN_START_SOUND",
                getValue = getTurnStartSound,
                setValue = setTurnStartSound,
            }),
            BaseMenuItems.Group({
                textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES",
                items = {
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES_OWN",
                        getValue = getUnitMoveOwn,
                        setValue = setUnitMoveOwn,
                    }),
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES_HOSTILE",
                        getValue = getUnitMoveHostile,
                        setValue = setUnitMoveHostile,
                    }),
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES_NEUTRAL",
                        getValue = getUnitMoveNeutral,
                        setValue = setUnitMoveNeutral,
                    }),
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES_CITY_STATE",
                        getValue = getUnitMoveCityState,
                        setValue = setUnitMoveCityState,
                    }),
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES_BARBARIAN",
                        getValue = getUnitMoveBarbarian,
                        setValue = setUnitMoveBarbarian,
                    }),
                    BaseMenuItems.VirtualToggle({
                        textKey = "TXT_KEY_CIVVACCESS_SETTINGS_UNIT_MOVES_TEAMMATE",
                        getValue = getUnitMoveTeammate,
                        setValue = setUnitMoveTeammate,
                    }),
                },
            }),
        },
    })
    return { generalGroup, cursorGroup, audioGroup, scannerGroup, notificationsGroup }
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

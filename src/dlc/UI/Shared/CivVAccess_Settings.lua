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

-- Cursor-follows-selection toggle. On by default: when a unit is
-- selected, the hex cursor jumps to its tile. Flipping it off keeps the
-- cursor put; the selection announcement still includes the direction
-- from cursor to unit so the player can tell where the new selection
-- sits. UnitControl reads civvaccess_shared.cursorFollowsSelection live
-- on every UnitSelectionChanged so toggling takes effect immediately.
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

local function buildItems()
    local masterVolumeFormat = "TXT_KEY_CIVVACCESS_SETTINGS_VOLUME_VALUE"
    return {
        BaseMenuItems.Group({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUE_MODE",
            items = {
                audioCueModeChoice(
                    AudioCueMode.MODE_SPEECH,
                    "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_ONLY"
                ),
                audioCueModeChoice(
                    AudioCueMode.MODE_SPEECH_PLUS_CUE,
                    "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_SPEECH_PLUS_CUES"
                ),
                audioCueModeChoice(
                    AudioCueMode.MODE_CUE_ONLY,
                    "TXT_KEY_CIVVACCESS_SETTINGS_AUDIO_CUES_ONLY"
                ),
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
        BaseMenuItems.VirtualToggle({
            textKey = "TXT_KEY_CIVVACCESS_SETTINGS_READ_SUBTITLES",
            getValue = getReadSubtitles,
            setValue = setReadSubtitles,
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

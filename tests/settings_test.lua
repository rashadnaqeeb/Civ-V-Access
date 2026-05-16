-- Settings overlay tests. Exercises Settings.open end-to-end, the F12
-- pre-walk hook in InputRouter, and the per-setting wiring through to
-- AudioCueMode, VolumeControl, and the bool-pref cache/Prefs pair.

local T = require("support")
local M = {}

local WM_KEYDOWN = 256
local VK_F12 = 123

local speaks
local prefsStore

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function()
        return false
    end
    UI.CtrlKeyDown = function()
        return false
    end
    UI.AltKeyDown = function()
        return false
    end

    Events.AudioPlay2DSound = function() end

    civvaccess_shared = {}
    -- Match run.lua's verbosity-off default so BaseMenu speech tests don't
    -- pick up the production-default ON via Verbosity's lazy Prefs read.
    civvaccess_shared.verbosity = false
    audio._reset()

    -- Capturing Prefs pair: every roundtrip lives in a table so reads see
    -- prior writes, regardless of which getter / setter pair the production
    -- code happens to call.
    prefsStore = {}
    Prefs.getBool = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setBool = function(key, v)
        prefsStore[key] = v
    end
    Prefs.getInt = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setInt = function(key, v)
        prefsStore[key] = v
    end
    Prefs.getFloat = function(key, default)
        local v = prefsStore[key]
        if v == nil then
            return default
        end
        return v
    end
    Prefs.setFloat = function(key, v)
        prefsStore[key] = v
    end

    speaks = {}
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_AudioCueMode.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_VolumeControl.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BeaconRange.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BeaconVolume.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Settings.lua")
    HandlerStack._reset()
    TickPump._reset()
end

-- Top-level group indices in the order buildItems returns them.
local UI_GROUP = 1
local CURSOR_GROUP = 2
local BEACON_GROUP = 3
local SCANNER_GROUP = 4
local NOTIFICATIONS_GROUP = 5

-- Helpers ---------------------------------------------------------------

local function topItems()
    return HandlerStack.active()._items
end

local function groupChildren(idx)
    return topItems()[idx]:children()
end

-- Wiring ----------------------------------------------------------------

function M.test_open_pushes_handler_named_Settings()
    setup()
    Settings.open()
    T.eq(HandlerStack.active().name, "Settings")
end

function M.test_open_announces_screen_name()
    setup()
    speaks = {}
    Settings.open()
    T.eq(speaks[1].text, "Settings", "first speech is the screen name")
end

function M.test_top_level_has_five_drillable_groups()
    setup()
    Settings.open()
    local items = topItems()
    T.eq(#items, 5, "five top-level groups: UI / cursor / beacon / scanner / notifications")
    for i = 1, 5 do
        T.eq(items[i].kind, "group", "top-level item " .. i .. " is a drillable group")
    end
end

-- F12 hook --------------------------------------------------------------

function M.test_f12_pre_walk_opens_settings_when_not_on_top()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    local consumed = InputRouter.dispatch(VK_F12, 0, WM_KEYDOWN)
    T.truthy(consumed)
    T.eq(HandlerStack.active().name, "Settings")
end

function M.test_f12_while_settings_on_top_closes_via_in_menu_binding()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    Settings.open()
    T.eq(HandlerStack.active().name, "Settings")
    -- Pre-walk hook bails when top is Settings, so the menu's own F12
    -- binding fires and pops.
    local consumed = InputRouter.dispatch(VK_F12, 0, WM_KEYDOWN)
    T.truthy(consumed)
    T.eq(HandlerStack.active().name, "base")
end

function M.test_escape_pops_settings()
    setup()
    HandlerStack.push({ name = "base", helpEntries = {} })
    Settings.open()
    local consumed = InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.truthy(consumed)
    T.eq(HandlerStack.active().name, "base")
end

-- UI group --------------------------------------------------------------

function M.test_ui_group_has_verbose_ui_then_read_subtitles()
    setup()
    Settings.open()
    local children = groupChildren(UI_GROUP)
    T.eq(#children, 2, "verbose UI + read subtitles")
    T.eq(children[1].kind, "checkbox")
    T.eq(children[2].kind, "checkbox")
end

function M.test_read_subtitles_toggle_flip_writes_shared_and_prefs()
    setup()
    civvaccess_shared.readSubtitles = false
    Settings.open()
    -- Second child of the UI group is the read-subtitles toggle.
    groupChildren(UI_GROUP)[2]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.readSubtitles, true)
    T.eq(prefsStore["ReadSubtitles"], true)
end

-- Cursor group ----------------------------------------------------------
--
-- Layout: follows-selection, border-always, coord-mode (group),
-- audio-cue-mode (group), master-volume (slider).

function M.test_cursor_group_layout()
    setup()
    Settings.open()
    local children = groupChildren(CURSOR_GROUP)
    T.eq(#children, 5, "five cursor-area settings")
    T.eq(children[1].kind, "checkbox", "cursor follows selection")
    T.eq(children[2].kind, "checkbox", "border always announce")
    T.eq(children[3].kind, "group", "cursor coord mode group")
    T.eq(children[4].kind, "group", "audio cue mode group")
    T.eq(children[5].kind, "slider", "master volume slider")
end

function M.test_cursor_follows_selection_default_on_and_flip()
    setup()
    Settings.open()
    T.eq(civvaccess_shared.cursorFollowsSelection, true, "lazy-init defaults to on")
    local handler = HandlerStack.active()
    groupChildren(CURSOR_GROUP)[1]:activate(handler)
    T.eq(civvaccess_shared.cursorFollowsSelection, false)
    T.eq(prefsStore["CursorFollowsSelection"], false)
end

function M.test_border_always_announce_default_off_and_flip()
    setup()
    Settings.open()
    T.eq(civvaccess_shared.borderAlwaysAnnounce, false, "lazy-init defaults to off")
    groupChildren(CURSOR_GROUP)[2]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.borderAlwaysAnnounce, true)
    T.eq(prefsStore["BorderAlwaysAnnounce"], true)
end

function M.test_cursor_coord_mode_default_off_and_append_choice_writes()
    setup()
    Settings.open()
    local coordGroup = groupChildren(CURSOR_GROUP)[3]
    local coordChildren = coordGroup:children()
    T.eq(#coordChildren, 3, "off / prepend / append")
    T.truthy(coordChildren[1]._selectedFn(), "off is the lazy-init default")
    T.falsy(coordChildren[2]._selectedFn())
    T.falsy(coordChildren[3]._selectedFn())
    coordChildren[3]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.cursorCoordMode, "append")
    T.eq(prefsStore["CursorCoordMode"], 2)
end

function M.test_audio_cue_mode_choices_call_setMode_and_mark_current()
    setup()
    AudioCueMode.setMode(AudioCueMode.MODE_SPEECH_PLUS_CUE)
    Settings.open()
    local cueGroup = groupChildren(CURSOR_GROUP)[4]
    local cueChildren = cueGroup:children()
    T.eq(#cueChildren, 3, "speech / both / cue only")
    T.falsy(cueChildren[1]._selectedFn(), "speech only is not selected")
    T.truthy(cueChildren[2]._selectedFn(), "speech plus cue is the active mode")
    T.falsy(cueChildren[3]._selectedFn(), "cue only is not selected")
    cueChildren[3]:activate(HandlerStack.active())
    T.eq(AudioCueMode.getMode(), AudioCueMode.MODE_CUE_ONLY)
end

function M.test_master_volume_slider_adjust_drives_VolumeControl_set()
    setup()
    Settings.open()
    local volumeSlider = groupChildren(CURSOR_GROUP)[5]
    T.eq(volumeSlider.kind, "slider")
    audio._reset()
    volumeSlider:adjust(HandlerStack.active(), 1, false)
    local last = audio._calls[#audio._calls]
    T.eq(last.op, "set_master_volume")
    T.eq(prefsStore["MasterVolume"], VolumeControl.get())
end

-- Beacon group ----------------------------------------------------------

function M.test_beacon_group_has_volume_then_range()
    setup()
    Settings.open()
    local children = groupChildren(BEACON_GROUP)
    T.eq(#children, 2, "beacon volume + beacon range")
    T.eq(children[1].kind, "slider", "beacon volume")
    T.eq(children[2].kind, "slider", "beacon range")
end

function M.test_beacon_volume_adjust_drives_BeaconVolume_set()
    setup()
    Settings.open()
    local before = BeaconVolume.get()
    groupChildren(BEACON_GROUP)[1]:adjust(HandlerStack.active(), 1, false)
    local after = BeaconVolume.get()
    T.truthy(after > before, "beacon volume increased on Right")
end

function M.test_beacon_range_adjust_drives_BeaconRange_set()
    setup()
    Settings.open()
    local before = BeaconRange.get()
    groupChildren(BEACON_GROUP)[2]:adjust(HandlerStack.active(), 1, false)
    local after = BeaconRange.get()
    T.truthy(after > before, "beacon range increased on Right")
end

-- Scanner group ---------------------------------------------------------

function M.test_scanner_group_layout()
    setup()
    Settings.open()
    local children = groupChildren(SCANNER_GROUP)
    T.eq(#children, 4, "auto-move + coords + compass direction + direction beep")
    T.eq(children[1].kind, "checkbox", "auto-move")
    T.eq(children[2].kind, "checkbox", "coords")
    T.eq(children[3].kind, "checkbox", "compass direction")
    T.eq(children[4].kind, "checkbox", "direction beep")
end

function M.test_scanner_auto_move_flip_writes_shared_and_prefs()
    setup()
    civvaccess_shared.scannerAutoMove = false
    Settings.open()
    groupChildren(SCANNER_GROUP)[1]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.scannerAutoMove, true)
    T.eq(prefsStore["ScannerAutoMove"], true)
end

function M.test_scanner_coords_flip_writes_shared_and_prefs()
    setup()
    civvaccess_shared.scannerCoords = false
    Settings.open()
    groupChildren(SCANNER_GROUP)[2]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.scannerCoords, true)
    T.eq(prefsStore["ScannerCoords"], true)
end

function M.test_scanner_compass_direction_default_off_and_flip()
    setup()
    Settings.open()
    T.eq(civvaccess_shared.scannerCompassDirection, false, "opt-in: defaults off")
    groupChildren(SCANNER_GROUP)[3]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.scannerCompassDirection, true)
    T.eq(prefsStore["ScannerCompassDirection"], true)
end

function M.test_scanner_direction_beep_default_off_and_flip()
    setup()
    Settings.open()
    T.eq(civvaccess_shared.scannerDirectionBeep, false, "opt-in: defaults off")
    groupChildren(SCANNER_GROUP)[4]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.scannerDirectionBeep, true)
    T.eq(prefsStore["ScannerDirectionBeep"], true)
end

-- Notifications group ---------------------------------------------------

function M.test_notifications_group_layout()
    setup()
    Settings.open()
    local children = groupChildren(NOTIFICATIONS_GROUP)
    T.eq(#children, 5, "reveal + ai-combat + foreign-unit + foreign-clear + turn-start-sound")
    for i = 1, 5 do
        T.eq(children[i].kind, "checkbox", "notification toggle " .. i)
    end
end

function M.test_ai_combat_announce_default_on_and_flip()
    setup()
    Settings.open()
    T.eq(civvaccess_shared.aiCombatAnnounce, true, "lazy-init defaults to on")
    -- Second notification (after reveal-announce).
    groupChildren(NOTIFICATIONS_GROUP)[2]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.aiCombatAnnounce, false)
    T.eq(prefsStore["AiCombatAnnounce"], false)
end

function M.test_foreign_unit_watch_default_on_and_flip()
    setup()
    Settings.open()
    T.eq(civvaccess_shared.foreignUnitWatchAnnounce, true, "lazy-init defaults to on")
    groupChildren(NOTIFICATIONS_GROUP)[3]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.foreignUnitWatchAnnounce, false)
    T.eq(prefsStore["ForeignUnitWatchAnnounce"], false)
end

function M.test_turn_start_sound_default_off_and_flip()
    -- Opt-in (default off): no audio cue at SP turn start until enabled.
    -- The Turn listener reads civvaccess_shared.turnStartSound live.
    setup()
    Settings.open()
    T.eq(civvaccess_shared.turnStartSound, false, "opt-in: defaults off")
    groupChildren(NOTIFICATIONS_GROUP)[5]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.turnStartSound, true)
    T.eq(prefsStore["TurnStartSound"], true)
end

return M

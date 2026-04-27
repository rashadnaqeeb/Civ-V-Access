-- Settings overlay tests. Exercises Settings.open end-to-end, the F12
-- pre-walk hook in InputRouter, and the three items' wiring through to
-- their respective setters (AudioCueMode, VolumeControl, scanner pref).

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
    dofile("src/dlc/UI/Shared/CivVAccess_Settings.lua")
    HandlerStack._reset()
    TickPump._reset()
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

function M.test_open_builds_seven_items()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(
        #h._items,
        7,
        "audio cue group + volume slider + scanner-auto-move toggle + cursor-follows-selection toggle + "
            .. "cursor-coord-mode group + scanner-coords toggle + read-subtitles toggle"
    )
end

function M.test_first_item_is_audio_cue_mode_group()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[1].kind, "group")
    T.eq(#h._items[1]:children(), 3, "three modes: speech / both / cue only")
end

function M.test_second_item_is_volume_slider()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[2].kind, "slider")
end

function M.test_third_item_is_scanner_toggle()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[3].kind, "checkbox")
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

-- Audio cue mode --------------------------------------------------------

function M.test_audio_cue_mode_choices_call_setMode()
    setup()
    AudioCueMode.setMode(AudioCueMode.MODE_SPEECH)
    Settings.open()
    local group = HandlerStack.active()._items[1]
    -- Activate the third choice (cue only).
    group:children()[3]:activate(HandlerStack.active())
    T.eq(AudioCueMode.getMode(), AudioCueMode.MODE_CUE_ONLY)
end

function M.test_audio_cue_mode_marks_current_as_selected()
    setup()
    AudioCueMode.setMode(AudioCueMode.MODE_SPEECH_PLUS_CUE)
    Settings.open()
    local group = HandlerStack.active()._items[1]
    local children = group:children()
    -- selectedFn is invoked through the Choice item's announce path. Easier
    -- check: each Choice carries a _selectedFn closure that returns true
    -- only for the active mode.
    T.falsy(children[1]._selectedFn(), "speech only is not selected")
    T.truthy(children[2]._selectedFn(), "speech plus cue is the active mode")
    T.falsy(children[3]._selectedFn(), "cue only is not selected")
end

-- Volume slider ---------------------------------------------------------

function M.test_volume_slider_adjust_drives_VolumeControl_set()
    setup()
    Settings.open()
    local handler = HandlerStack.active()
    -- Cursor lands on the first item (audio cue group). Move down twice to
    -- the volume slider; arrow-key dispatch through InputRouter mutates
    -- _indices and fires the slider's adjust on Right.
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(handler._items[handler._indices[1]].kind, "slider")
    audio._reset()
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    -- VolumeControl.set pushes through audio.set_master_volume and
    -- persists to Prefs.setFloat. Both should fire.
    local last = audio._calls[#audio._calls]
    T.eq(last.op, "set_master_volume")
    T.eq(prefsStore["MasterVolume"], VolumeControl.get())
end

-- Scanner auto-move toggle ----------------------------------------------

function M.test_scanner_toggle_flip_writes_shared_and_prefs()
    setup()
    civvaccess_shared.scannerAutoMove = false
    Settings.open()
    local handler = HandlerStack.active()
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(handler._items[handler._indices[1]].kind, "checkbox")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(civvaccess_shared.scannerAutoMove, true)
    T.eq(prefsStore["ScannerAutoMove"], true)
end

-- Cursor-follows-selection toggle ---------------------------------------

function M.test_fourth_item_is_cursor_follows_selection_toggle()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[4].kind, "checkbox")
end

function M.test_cursor_follows_selection_toggle_flip_writes_shared_and_prefs()
    setup()
    -- Defaults true: lazy-init in Settings.lua reads Prefs.getBool with
    -- default true, and prefsStore is empty after setup(). Flip turns it
    -- off, which is the realistic user-initiated transition.
    Settings.open()
    T.eq(civvaccess_shared.cursorFollowsSelection, true, "lazy-init defaults to on")
    local handler = HandlerStack.active()
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(handler._items[handler._indices[1]].kind, "checkbox")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(civvaccess_shared.cursorFollowsSelection, false)
    T.eq(prefsStore["CursorFollowsSelection"], false)
end

-- Cursor coord mode group -----------------------------------------------

function M.test_fifth_item_is_cursor_coord_mode_group()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[5].kind, "group")
    T.eq(#h._items[5]:children(), 3, "three modes: off / prepend / append")
end

function M.test_cursor_coord_mode_off_is_default()
    setup()
    Settings.open()
    local children = HandlerStack.active()._items[5]:children()
    T.truthy(children[1]._selectedFn(), "off is the lazy-init default")
    T.falsy(children[2]._selectedFn())
    T.falsy(children[3]._selectedFn())
end

function M.test_cursor_coord_mode_choice_writes_shared_and_prefs()
    setup()
    Settings.open()
    -- Activate "append" (third choice).
    HandlerStack.active()._items[5]:children()[3]:activate(HandlerStack.active())
    T.eq(civvaccess_shared.cursorCoordMode, "append")
    T.eq(prefsStore["CursorCoordMode"], 2)
end

-- Scanner coords toggle -------------------------------------------------

function M.test_sixth_item_is_scanner_coords_toggle()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[6].kind, "checkbox")
end

function M.test_scanner_coords_toggle_flip_writes_shared_and_prefs()
    setup()
    civvaccess_shared.scannerCoords = false
    Settings.open()
    local handler = HandlerStack.active()
    -- Down 5 times: from item 1 (group) past slider, scanner toggle,
    -- cursor-follows toggle, cursor-coord group, into scanner-coords toggle.
    for _ = 1, 5 do
        InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    end
    T.eq(handler._items[handler._indices[1]].kind, "checkbox")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(civvaccess_shared.scannerCoords, true)
    T.eq(prefsStore["ScannerCoords"], true)
end

-- Read-subtitles toggle -------------------------------------------------

function M.test_seventh_item_is_read_subtitles_toggle()
    setup()
    Settings.open()
    local h = HandlerStack.active()
    T.eq(h._items[7].kind, "checkbox")
end

function M.test_read_subtitles_toggle_flip_writes_shared_and_prefs()
    setup()
    civvaccess_shared.readSubtitles = false
    Settings.open()
    local handler = HandlerStack.active()
    -- Down 6 times to reach the read-subtitles toggle (item 7).
    for _ = 1, 6 do
        InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    end
    T.eq(handler._items[handler._indices[1]].kind, "checkbox")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(civvaccess_shared.readSubtitles, true)
    T.eq(prefsStore["ReadSubtitles"], true)
end

return M

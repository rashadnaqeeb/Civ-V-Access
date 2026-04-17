-- FormHandler tests. HandlerStack, InputRouter, and SimpleListHandler are
-- loaded for real. Widget controls come from the Polyfill widget factories
-- which mirror real engine semantics (SetValue clamps, SetCheck flips, etc.).
-- SpeechPipeline._speakAction is redirected so we can assert announcement
-- text + interrupt flag in order.

local T = require("support")
local M = {}

local warns, errors
local speaks
local sounds

-- Module-local metatable reset each setup(); shared across PullDowns in the
-- same test but NOT across tests, so one test's probe patch does not chain
-- into the next (which would record every entry twice, etc.).
local _test_pd_mt = nil

local function resetPDMetatable()
    local proto = Polyfill.makePullDown()
    _test_pd_mt = { __index = {
        GetButton                  = proto.GetButton,
        ClearEntries               = proto.ClearEntries,
        BuildEntry                 = proto.BuildEntry,
        CalculateInternals         = proto.CalculateInternals,
        RegisterSelectionCallback  = proto.RegisterSelectionCallback,
        IsHidden                   = proto.IsHidden,
        IsDisabled                 = proto.IsDisabled,
        SetHide                    = proto.SetHide,
        SetDisabled                = proto.SetDisabled,
    }}
end

local function setup()
    warns, errors = {}, {}
    Log.warn  = function(m) warns[#warns + 1]  = m end
    Log.error = function(m) errors[#errors + 1] = m end
    Log.info  = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function() return false end
    UI.CtrlKeyDown  = function() return false end
    UI.AltKeyDown   = function() return false end

    sounds = {}
    Events.AudioPlay2DSound = function(id) sounds[#sounds + 1] = id end

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
    dofile("src/dlc/UI/Shared/CivVAccess_FormHandler.lua")
    HandlerStack._reset()

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks      = {}
    civvaccess_shared.pullDownEntries        = {}
    civvaccess_shared.sliderProbeInstalled   = false
    civvaccess_shared.sliderCallbacks        = {}
    civvaccess_shared.checkBoxProbeInstalled = false
    civvaccess_shared.checkBoxCallbacks      = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"]    = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"]           = "on"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"]          = "off"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"]     = "edit"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"]    = "blank"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"]  = "editing {1_Label}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"

    resetPDMetatable()
end

local WM_KEYDOWN = 256

-- Helpers ------------------------------------------------------------

local function populateControls(map)
    Controls = {}
    for name, c in pairs(map) do Controls[name] = c end
end

local function patchProbeFromPullDown(pd)
    -- Install the probe using a PullDown with a real metatable. The polyfill
    -- uses plain tables, so wrap with a metatable-backed userdata-ish stub.
    PullDownProbe.ensureInstalled(pd)
end

local function makePullDownWithMetatable()
    if _test_pd_mt == nil then resetPDMetatable() end
    return Polyfill.makePullDownWithMetatable(_test_pd_mt)
end

-- Factory -----------------------------------------------------------

function M.test_create_requires_items_or_tabs()
    setup()
    Controls = {}
    local ok = pcall(FormHandler.create, { name = "X", displayName = "x" })
    T.falsy(ok, "no items/tabs should fail")
end

function M.test_create_resolves_item_controls()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C1 = cb })
    local h = FormHandler.create({
        name = "T", displayName = "Test",
        items = {
            { kind = "checkbox", controlName = "C1", textKey = "LBL_C1" },
        },
    })
    T.eq(h.capturesAllInput, true)
    T.eq(type(h.bindings), "table")
end

function M.test_missing_control_logs_warn_and_keeps_item()
    setup()
    populateControls({})
    FormHandler.create({
        name = "T", displayName = "Test",
        items = {
            { kind = "checkbox", controlName = "Missing", textKey = "LBL" },
        },
    })
    T.truthy(#warns >= 1, "missing-control warn logged")
end

-- Checkbox ---------------------------------------------------------

function M.test_checkbox_enter_toggles_and_announces_on()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "Foo", textKey = "LBL_FOO" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(cb:IsChecked(), true)
    T.eq(speaks[#speaks].text, "LBL_FOO, on")
end

function M.test_checkbox_space_toggles_back_and_announces_off()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = true })
    populateControls({ Foo = cb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "Foo", textKey = "LBL_FOO" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_SPACE, 0, WM_KEYDOWN)
    T.eq(cb:IsChecked(), false)
    T.eq(speaks[#speaks].text, "LBL_FOO, off")
end

function M.test_checkbox_focus_announces_current_state()
    setup()
    local a = Polyfill.makeCheckBox({ checked = true })
    local b = Polyfill.makeCheckBox({ checked = false })
    populateControls({ A = a, B = b })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "A", textKey = "LBL_A" },
            { kind = "checkbox", controlName = "B", textKey = "LBL_B" },
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[1].text, "Screen")
    T.eq(speaks[2].text, "LBL_A, on")
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "LBL_B, off")
end

-- Slider -----------------------------------------------------------

-- Simulate what PullDownProbe does in-game: record the callback in
-- civvaccess_shared so FormHandler's fireSliderCallback can find it. The
-- probe-integration path itself is covered by pulldown_probe_test.
local function registerSliderCallback(slider, fn)
    slider:RegisterSliderCallback(fn)
    civvaccess_shared.sliderCallbacks[slider] = fn
end

local function registerCheckHandler(cb, fn)
    cb:RegisterCheckHandler(fn)
    civvaccess_shared.checkBoxCallbacks = civvaccess_shared.checkBoxCallbacks or {}
    civvaccess_shared.checkBoxCallbacks[cb] = fn
end

function M.test_slider_right_increments_by_small_step()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50%")
    populateControls({ Sld = slider, Lbl = label })
    registerSliderCallback(slider, function(v)
        label:SetText(string.format("%d%%", math.floor(v * 100 + 0.5)))
    end)
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL_SLD" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.51)
    -- Composite slider: label control text replaces the whole announcement.
    T.eq(speaks[1].text, "51%")
end

function M.test_slider_fires_captured_callback_on_adjust()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    local received = {}
    registerSliderCallback(slider, function(v, void1)
        received[#received + 1] = { v = v, void1 = void1 }
        label:SetText(string.format("%d", math.floor(v * 100 + 0.5)))
    end)
    slider:SetVoid1(42)
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL_SLD" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(#received, 1, "callback fired once on adjust")
    T.truthy(math.abs(received[1].v - 0.51) < 1e-6)
    T.eq(received[1].void1, 42, "void1 forwarded")
end

function M.test_slider_callback_missing_logs_warn()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("0")
    populateControls({ Sld = slider, Lbl = label })
    -- No registerSliderCallback -> probe has no entry for this slider.
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL_SLD" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.51, "value still changes")
    T.truthy(#warns >= 1, "callback-missing warn logged")
end

function M.test_checkbox_fires_captured_handler_on_toggle()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    local received = {}
    registerCheckHandler(cb, function(v) received[#received + 1] = v end)
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "Foo", textKey = "LBL_FOO" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#received, 1)
    T.eq(received[1], true)
    InputRouter.dispatch(Keys.VK_SPACE, 0, WM_KEYDOWN)
    T.eq(#received, 2)
    T.eq(received[2], false)
end

function M.test_slider_left_decrements()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.50 })
    local label  = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    slider:RegisterSliderCallback(function(v) label:SetText(tostring(math.floor(v * 100 + 0.5))) end)
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.49)
end

function M.test_slider_shift_left_decrements_by_big_step()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    UI.ShiftKeyDown = function() return true end
    InputRouter.dispatch(Keys.VK_LEFT, 1, WM_KEYDOWN)
    -- floating-point friendly: 0.5 - 0.1 may round to 0.4
    T.truthy(math.abs(slider:GetValue() - 0.4) < 1e-6)
end

function M.test_slider_home_clamps_to_zero()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("0")
    populateControls({ Sld = slider, Lbl = label })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0)
end

function M.test_slider_end_clamps_to_one()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("0")
    populateControls({ Sld = slider, Lbl = label })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_END, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 1)
end

function M.test_slider_right_at_max_stays_clamped()
    setup()
    local slider = Polyfill.makeSlider({ value = 1.0 })
    local label  = Polyfill.makeLabel("100")
    populateControls({ Sld = slider, Lbl = label })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 1.0)
end

-- PullDown ---------------------------------------------------------

function M.test_pulldown_enter_pushes_subhandler_from_probe()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    -- Simulate the screen's own calls after the probe is in place.
    pd:ClearEntries()
    local invoked = {}
    pd:RegisterSelectionCallback(function(v1, v2)
        invoked[#invoked + 1] = { v1 = v1, v2 = v2 }
    end)
    local inst1 = {}
    pd:BuildEntry("InstanceOne", inst1)
    inst1.Button:SetText("Easy")
    inst1.Button:SetVoid1(1)
    local inst2 = {}
    pd:BuildEntry("InstanceOne", inst2)
    inst2.Button:SetText("Hard")
    inst2.Button:SetVoid1(2)

    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "pulldown", controlName = "PD", textKey = "LBL_PD" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2, "sub pushed on top")
    T.eq(HandlerStack.active().name, "T/PD_PullDown")
    T.eq(sounds[1], "AS2D_IF_SELECT", "click sound on dropdown open")
    -- First-entry text should be spoken
    local heard = false
    for _, s in ipairs(speaks) do if s.text == "Easy" then heard = true end end
    T.truthy(heard, "first entry text announced")

    -- Walk to second and select
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#invoked, 1)
    T.eq(invoked[1].v1, 2, "void1 forwarded")
    T.eq(HandlerStack.count(), 1, "sub popped after select")
end

function M.test_pulldown_enter_without_probe_logs_warn_and_announces_current()
    setup()
    -- No probe install -> callback and entries missing.
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    -- Still call GetButton:SetText so we have a spoken value.
    pd:GetButton():SetText("Current")
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "pulldown", controlName = "PD", textKey = "LBL_PD" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(#warns >= 1, "missing probe state warns")
    T.truthy(#speaks >= 1, "announced despite missing probe state")
    T.eq(speaks[#speaks].text, "LBL_PD, Current")
end

-- Tooltip appending -----------------------------------------------

function M.test_tooltip_appended_after_label_value()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SHOW_MAP"]    = "Show map"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SHOW_MAP_TT"] = "Toggles the map overlay"
    local cb = Polyfill.makeCheckBox({ checked = true })
    populateControls({ Foo = cb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "Foo",
              textKey    = "TXT_KEY_CIVVACCESS_TEST_SHOW_MAP",
              tooltipKey = "TXT_KEY_CIVVACCESS_TEST_SHOW_MAP_TT" },
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Show map, on, Toggles the map overlay")
end

function M.test_tooltip_dedupes_against_label()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FS"]    = "Fullscreen"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FS_TT"] = "Fullscreen. Some extra detail"
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ X = cb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "X",
              textKey    = "TXT_KEY_CIVVACCESS_TEST_FS",
              tooltipKey = "TXT_KEY_CIVVACCESS_TEST_FS_TT" },
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Fullscreen, off, Some extra detail",
        "duplicate 'Fullscreen' sentence dropped from tooltip")
end

function M.test_tooltip_absent_gives_plain_announce()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_VOL"] = "Volume"
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50%")
    populateControls({ S = slider, L = label })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "S", labelControlName = "L",
              textKey = "TXT_KEY_CIVVACCESS_TEST_VOL" },  -- no tooltipKey
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "50%", "composite slider uses label control text alone")
end

function M.test_slider_empty_label_falls_back_to_textKey()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SLD"] = "Delay"
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("")  -- label control not yet populated
    populateControls({ Sld = slider, Lbl = label })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "Sld", labelControlName = "Lbl",
              textKey = "TXT_KEY_CIVVACCESS_TEST_SLD" },
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Delay", "empty label control -> textKey label alone")
end

function M.test_tooltip_appears_after_adjust_too()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_VOL"]    = "Volume"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_VOL_TT"] = "Adjust music volume"
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50%")
    populateControls({ S = slider, L = label })
    registerSliderCallback(slider, function(v)
        label:SetText(string.format("%d%%", math.floor(v * 100 + 0.5)))
    end)
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "slider", controlName = "S", labelControlName = "L",
              textKey    = "TXT_KEY_CIVVACCESS_TEST_VOL",
              tooltipKey = "TXT_KEY_CIVVACCESS_TEST_VOL_TT" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "51%, Adjust music volume")
end

-- Tabs -------------------------------------------------------------

function M.test_tabs_tab_key_cycles_and_resets_cursor()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    local shown = 1
    populateControls({ CA = cbA, CB = cbB })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        tabs = {
            {
                name      = "TAB_A", showPanel = function() shown = 1 end,
                items     = {
                    { kind = "checkbox", controlName = "CA", textKey = "LBL_A" },
                },
            },
            {
                name      = "TAB_B", showPanel = function() shown = 2 end,
                items     = {
                    { kind = "checkbox", controlName = "CB", textKey = "LBL_B" },
                },
            },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(shown, 2, "showPanel fired on tab switch")
    T.eq(h._tabIndex, 2)
    T.eq(h._index, 1, "cursor reset to first valid item of new tab")
    T.eq(speaks[1].text, "TAB_B", "new tab name announced")
end

function M.test_tabs_shift_tab_cycles_backward_wraps()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    local cbC = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB, CC = cbC })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        tabs = {
            { name = "A", items = { { kind = "checkbox", controlName = "CA", textKey = "L" } } },
            { name = "B", items = { { kind = "checkbox", controlName = "CB", textKey = "L" } } },
            { name = "C", items = { { kind = "checkbox", controlName = "CC", textKey = "L" } } },
        },
    })
    HandlerStack.push(h)  -- starts on tab 1
    UI.ShiftKeyDown = function() return true end
    InputRouter.dispatch(Keys.VK_TAB, 1, WM_KEYDOWN)
    T.eq(h._tabIndex, 3, "wrapped from 1 backward to 3")
end

function M.test_left_right_do_not_cycle_tabs()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        tabs = {
            { name = "A", items = { { kind = "checkbox", controlName = "CA", textKey = "L" } } },
            { name = "B", items = { { kind = "checkbox", controlName = "CB", textKey = "L" } } },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 1, "Right on a non-slider is a no-op; tab unchanged")
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 1, "Left on a non-slider is a no-op; tab unchanged")
end

-- Navigation -------------------------------------------------------

function M.test_down_wraps_within_tab()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    populateControls({ A = a, B = b })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "A", textKey = "LBL_A" },
            { kind = "checkbox", controlName = "B", textKey = "LBL_B" },
        },
    })
    HandlerStack.push(h)
    h._index = 2
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 1, "wrapped to first")
end

function M.test_hidden_items_are_skipped()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    b:SetHide(true)
    local c = Polyfill.makeCheckBox()
    populateControls({ A = a, B = b, C = c })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "A", textKey = "LBL_A" },
            { kind = "checkbox", controlName = "B", textKey = "LBL_B" },
            { kind = "checkbox", controlName = "C", textKey = "LBL_C" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 3, "hidden B skipped")
end

-- Install / Esc --------------------------------------------------------

local function makeContextPtr()
    return {
        SetShowHideHandler = function(self, fn) self._sh = fn end,
        SetInputHandler    = function(self, fn) self._in = fn end,
        _hidden            = false,
        IsHidden           = function(self) return self._hidden end,
        SetUpdate          = function(self, fn) self._update = fn end,
    }
end

function M.test_install_push_on_show_pop_on_hide()
    setup()
    local a = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local ctx = makeContextPtr()
    FormHandler.install(ctx, {
        name = "T", displayName = "Screen",
        items = { { kind = "checkbox", controlName = "A", textKey = "LBL" } },
    })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
    ctx._sh(true, false)
    T.eq(HandlerStack.count(), 0)
end

function M.test_install_show_parks_focus_on_named_control()
    setup()
    local a    = Polyfill.makeCheckBox()
    local eb   = Polyfill.makeEditBox({ text = "" })
    local park = Polyfill.makeButton()
    populateControls({ A = a, E = eb, Cancel = park })
    local ctx = makeContextPtr()
    FormHandler.install(ctx, {
        name = "T", displayName = "Screen",
        focusParkControl = "Cancel",
        -- Base-screen ShowHide focuses the EditBox, then our wrapper
        -- should park focus on Cancel so arrow keys reach the form.
        priorShowHide = function(bIsHide) if not bIsHide then eb:TakeFocus() end end,
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
            { kind = "checkbox",  controlName = "A", textKey = "LBL_A" },
        },
    })
    ctx._sh(false, false)
    T.eq(park._hasFocus, true, "focus parked on Cancel after base's TakeFocus")
end

function M.test_install_esc_bypasses_to_prior_input()
    setup()
    local a = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local ctx = makeContextPtr()
    local priorFired = 0
    FormHandler.install(ctx, {
        name = "T", displayName = "Screen",
        items = { { kind = "checkbox", controlName = "A", textKey = "LBL" } },
        priorInput = function(msg, wp, lp)
            if wp == Keys.VK_ESCAPE then priorFired = priorFired + 1 end
            return true
        end,
    })
    ctx._sh(false, false)
    local consumed = ctx._in(WM_KEYDOWN, Keys.VK_ESCAPE, 0)
    T.truthy(consumed, "prior returned true")
    T.eq(priorFired, 1)
end

function M.test_pulldown_sub_pop_preserves_cursor_position()
    setup()
    local pd = makePullDownWithMetatable()
    local cb = Polyfill.makeCheckBox()
    populateControls({ PD = pd, CB = cb })
    patchProbeFromPullDown(pd)
    pd:RegisterSelectionCallback(function() end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Entry")

    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "CB",  textKey = "LBL_CB" },
            { kind = "pulldown", controlName = "PD",  textKey = "LBL_PD" },
        },
    })
    HandlerStack.push(h)
    -- Move cursor to the pulldown (item 2).
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 2)
    -- Open the sub.
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2)
    -- Select the only entry, which pops the sub and re-activates the form.
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1)
    T.eq(h._index, 2, "cursor stayed on the pulldown after sub pop")
end

function M.test_sub_pop_advances_cursor_off_hidden_item()
    setup()
    local pd = makePullDownWithMetatable()
    local cbAfter = Polyfill.makeCheckBox()
    populateControls({ PD = pd, After = cbAfter })
    patchProbeFromPullDown(pd)
    -- The pulldown's selection callback hides the pulldown itself (as a
    -- proxy for the "Scenario check toggles visibility" pattern), forcing
    -- re-activation to land on a different valid item.
    pd:RegisterSelectionCallback(function()
        pd:SetHide(true)
    end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Entry")

    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "pulldown", controlName = "PD",    textKey = "LBL_PD" },
            { kind = "checkbox", controlName = "After", textKey = "LBL_AFTER" },
        },
    })
    HandlerStack.push(h)
    T.eq(h._index, 1, "starts on pulldown")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- open sub
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- select; pulldown hides
    T.eq(h._index, 2, "cursor advanced off the now-hidden pulldown")
    T.truthy(#speaks >= 1, "re-activation announced the new current item")
end

function M.test_tab_position_preserved_across_pulldown_sub()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:RegisterSelectionCallback(function() end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Entry")

    local cbFiller = Polyfill.makeCheckBox()
    Controls.Filler = cbFiller
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        tabs = {
            { name = "TAB_A",
              items = {
                  { kind = "checkbox", controlName = "Filler", textKey = "L" },
              } },
            { name = "TAB_B",
              items = {
                  { kind = "pulldown", controlName = "PD", textKey = "LBL_PD" },
              } },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2)
    T.eq(h._index, 1, "on pulldown in tab B")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- open sub
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- select entry
    T.eq(h._tabIndex, 2, "tab preserved")
    T.eq(h._index, 1, "item index preserved")
end

function M.test_close_reopen_resets_cursor()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ A = cbA, B = cbB })
    local ctx = makeContextPtr()
    FormHandler.install(ctx, {
        name = "T", displayName = "Screen",
        items = {
            { kind = "checkbox", controlName = "A", textKey = "LBL_A" },
            { kind = "checkbox", controlName = "B", textKey = "LBL_B" },
        },
    })
    ctx._sh(false, false)
    local h = HandlerStack.active()
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 2)
    ctx._sh(true, false)   -- hide
    ctx._sh(false, false)  -- reopen
    T.eq(HandlerStack.active()._index, 1, "cursor reset on reopen")
end

function M.test_install_esc_on_subhandler_closes_sub_not_screen()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:RegisterSelectionCallback(function() end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Entry")

    local ctx = makeContextPtr()
    local priorFired = 0
    FormHandler.install(ctx, {
        name = "T", displayName = "Screen",
        items = { { kind = "pulldown", controlName = "PD", textKey = "LBL" } },
        priorInput = function(msg, wp, lp)
            if wp == Keys.VK_ESCAPE then priorFired = priorFired + 1 end
            return true
        end,
    })
    ctx._sh(false, false)
    -- Push the sub by Enter on the pulldown
    ctx._in(WM_KEYDOWN, Keys.VK_RETURN, 0)
    T.eq(HandlerStack.count(), 2)
    -- Esc should close the sub, not the screen
    local consumed = ctx._in(WM_KEYDOWN, Keys.VK_ESCAPE, 0)
    T.truthy(consumed)
    T.eq(priorFired, 0, "priorInput NOT called")
    T.eq(HandlerStack.count(), 1, "sub popped")
end

function M.test_install_prior_showhide_chained()
    setup()
    local a = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local ctx = makeContextPtr()
    local priorArg = nil
    FormHandler.install(ctx, {
        name = "T", displayName = "Screen",
        items = { { kind = "checkbox", controlName = "A", textKey = "LBL" } },
        priorShowHide = function(bIsHide) priorArg = bIsHide end,
    })
    ctx._sh(false, false)
    T.eq(priorArg, false)
    T.eq(HandlerStack.count(), 1)
end

-- Textfield edit mode --------------------------------------------------

function M.test_enter_on_textfield_enters_edit_mode()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._editing, true, "form flipped to edit mode")
    T.eq(h._editingOriginal, "Athens", "original text snapshotted")
    T.eq(eb:GetText(), "", "editbox cleared")
    -- TakeFocus is deferred to next tick so the engine's Enter-release
    -- handling doesn't revoke it. Drain the queue to assert focus landed.
    TickPump.tick()
    T.eq(eb._hasFocus, true, "engine focus taken for typing")
    T.eq(h.capturesAllInput, false,
        "capturesAllInput off so unbound keys fall through to the EditBox")
    T.eq(h.bindings, h._editBindings, "bindings swapped to edit set")
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "editing LBL" then found = true end
    end
    T.truthy(found, "editing announcement fired")
end

function M.test_escape_during_edit_restores_and_exits()
    setup()
    local eb   = Polyfill.makeEditBox({ text = "Athens" })
    local park = Polyfill.makeButton()
    populateControls({ E = eb, Park = park })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        focusParkControl = "Park",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit
    eb:SetText("partial")
    park._hasFocus = nil
    speaks = {}
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)  -- cancel
    T.eq(h._editing, false, "edit mode exited")
    T.eq(eb:GetText(), "Athens", "original text restored")
    T.eq(h.bindings, h._navBindings, "nav bindings restored")
    T.eq(h.capturesAllInput, true, "capturesAllInput restored")
    T.eq(park._hasFocus, true, "focus parked off the EditBox")
    local foundRestored = false
    for _, s in ipairs(speaks) do
        if s.text == "LBL restored" then foundRestored = true end
    end
    T.truthy(foundRestored, "restored announcement fired")
end

function M.test_enter_during_edit_commits_without_restoring()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit
    eb:SetText("new name")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- commit
    T.eq(h._editing, false, "edit mode exited")
    T.eq(eb:GetText(), "new name", "typed text preserved, no restore on commit")
    T.eq(h.bindings, h._navBindings, "nav bindings restored")
end

-- Non-CallOnChar EditBoxes only fire their callback on Enter, and our edit
-- binding intercepts that Enter before the engine forwards it. So the commit
-- path has to call priorCallback manually; without it, OptionsMenu's email
-- / autosave fields and the MP screens' MaxTurns / TurnTimer fields would
-- accept typing into the widget but never persist to OptionsManager / PreGame.
function M.test_commit_fires_priorCallback_with_final_text()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local received = {}
    local function prior(text, control, bIsEnter)
        received[#received + 1] = { text = text, control = control, bIsEnter = bIsEnter }
    end
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL",
              priorCallback = prior },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit
    eb:SetText("committed")
    received = {}  -- ignore anything fired during editing
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- commit
    T.eq(#received, 1, "priorCallback fired exactly once on commit")
    T.eq(received[1].text, "committed", "final text passed")
    T.eq(received[1].control, eb, "editbox passed as control")
    T.eq(received[1].bIsEnter, true,
        "bIsEnter=true so priorCallback mimics native Enter-triggered call")
end

function M.test_commit_announces_committed_value()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit
    eb:SetText("new value")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- commit
    T.eq(speaks[#speaks].text, "new value",
        "commit should speak the just-saved value so the user hears confirmation")
end

function M.test_commit_on_empty_announces_blank()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit (clears to "")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- commit empty
    T.eq(speaks[#speaks].text, "blank",
        "empty commit should speak the blank sentinel so silence is never the signal")
end

function M.test_commit_without_priorCallback_is_safe()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },  -- no priorCallback
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit
    eb:SetText("committed")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- commit
    T.eq(h._editing, false, "commit succeeded with no callback")
    T.eq(#errors, 0, "no error logged")
end

function M.test_restore_does_not_fire_priorCallback()
    setup()
    local eb = Polyfill.makeEditBox({ text = "original" })
    populateControls({ E = eb })
    local fired = 0
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL",
              priorCallback = function() fired = fired + 1 end },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- enter edit
    eb:SetText("partial")
    fired = 0
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)  -- cancel
    T.eq(fired, 0,
        "restore path must NOT fire priorCallback; the game never committed this text")
    T.eq(eb:GetText(), "original")
end

function M.test_edit_mode_has_no_arrow_bindings()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    -- The edit bindings array should not contain Up/Down/Left/Right.
    for _, b in ipairs(h._editBindings) do
        T.truthy(b.key ~= Keys.VK_UP and b.key ~= Keys.VK_DOWN
                 and b.key ~= Keys.VK_LEFT and b.key ~= Keys.VK_RIGHT,
            "edit bindings must not intercept arrow keys")
    end
end

function M.test_reenter_edit_installs_fresh_wrapping_callback()
    setup()
    local eb = Polyfill.makeEditBox({ text = "first" })
    populateControls({ E = eb })
    local priorCalls = 0
    local function prior() priorCalls = priorCalls + 1 end
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL",
              priorCallback = prior },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)   -- enter
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)   -- commit (fires prior)
    T.eq(eb._cb, prior, "prior reinstated on exit")
    priorCalls = 0
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)   -- re-enter
    T.truthy(eb._cb ~= prior, "new wrapping callback installed")
    eb._cb("x", eb, false)
    T.eq(priorCalls, 1, "re-entered wrapper still chains to prior")
end

function M.test_tab_switch_reparks_focus_on_configured_control()
    setup()
    local cbA  = Polyfill.makeCheckBox()
    local ebB  = Polyfill.makeEditBox({ text = "" })
    local park = Polyfill.makeButton()
    populateControls({ CA = cbA, EB = ebB, Park = park })
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        focusParkControl = "Park",
        tabs = {
            { name = "TAB_A",
              items = { { kind = "checkbox", controlName = "CA", textKey = "L" } } },
            { name = "TAB_B",
              showPanel = function()
                  -- Simulates the engine auto-focusing an EditBox in the
                  -- newly shown panel.
                  ebB:TakeFocus()
              end,
              items = { { kind = "textfield", controlName = "EB", textKey = "L" } } },
        },
    })
    HandlerStack.push(h)
    park._hasFocus = nil
    ebB._hasFocus  = nil
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2)
    T.eq(park._hasFocus, true,
        "park control focused after tab switch so arrow keys reach the form")
end

return M

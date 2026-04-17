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
    dofile("src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_FormHandler.lua")
    HandlerStack._reset()

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks      = {}
    civvaccess_shared.pullDownEntries        = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"]        = "on"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"]       = "off"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TAB_STRIP"]       = "tabs"

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
    local pd = Polyfill.makePullDown()
    -- Strip instance methods so __index lookup applies.
    pd.GetButton, pd.ClearEntries, pd.BuildEntry, pd.CalculateInternals = nil, nil, nil, nil
    pd.RegisterSelectionCallback, pd.IsHidden, pd.IsDisabled = nil, nil, nil
    pd.SetHide, pd.SetDisabled = nil, nil
    return setmetatable(pd, _test_pd_mt)
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
    T.eq(speaks[#speaks].text, "LBL_FOO on")
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
    T.eq(speaks[#speaks].text, "LBL_FOO off")
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
    T.eq(speaks[2].text, "LBL_A on")
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "LBL_B off")
end

-- Slider -----------------------------------------------------------

function M.test_slider_right_increments_by_small_step()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50%")
    populateControls({ Sld = slider, Lbl = label })
    slider:RegisterSliderCallback(function(v)
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
    T.eq(speaks[1].text, "LBL_SLD 51%")
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
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2, "sub pushed on top")
    T.eq(HandlerStack.active().name, "T/PD_PullDown")
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
    T.eq(speaks[#speaks].text, "LBL_PD Current")
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
                    { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" },
                    { kind = "checkbox", controlName = "CA", textKey = "LBL_A" },
                },
            },
            {
                name      = "TAB_B", showPanel = function() shown = 2 end,
                items     = {
                    { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" },
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
    populateControls({})
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        tabs = {
            { name = "A", items = { { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" } } },
            { name = "B", items = { { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" } } },
            { name = "C", items = { { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" } } },
        },
    })
    HandlerStack.push(h)  -- starts on tab 1
    UI.ShiftKeyDown = function() return true end
    InputRouter.dispatch(Keys.VK_TAB, 1, WM_KEYDOWN)
    T.eq(h._tabIndex, 3, "wrapped from 1 backward to 3")
end

function M.test_tabstrip_left_right_cycles_tabs_too()
    setup()
    populateControls({})
    local h = FormHandler.create({
        name = "T", displayName = "Screen",
        tabs = {
            { name = "A", items = { { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" } } },
            { name = "B", items = { { kind = "tabstrip", textKey = "TXT_KEY_CIVVACCESS_TAB_STRIP" } } },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2, "Right on tabstrip cycles forward")
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 1, "Left cycles back")
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

return M

-- Menu + MenuItems tests. HandlerStack, InputRouter, Nav, TickPump,
-- PullDownProbe, Menu, and MenuItems are loaded for real. Widget controls
-- come from the Polyfill factories which mirror engine semantics (SetValue
-- clamps, SetCheck flips, etc.). SpeechPipeline._speakAction is redirected
-- so suites can assert announcement text + interrupt flag in order.

local T = require("support")
local M = {}

local warns, errors
local speaks
local sounds
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
    dofile("src/dlc/UI/Shared/CivVAccess_MenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Menu.lua")
    HandlerStack._reset()
    TickPump._reset()

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

-- Helpers --------------------------------------------------------------

local function populateControls(map)
    Controls = {}
    for name, c in pairs(map) do Controls[name] = c end
end

local function patchProbeFromPullDown(pd)
    PullDownProbe.ensureInstalled(pd)
end

local function makePullDownWithMetatable()
    if _test_pd_mt == nil then resetPDMetatable() end
    return Polyfill.makePullDownWithMetatable(_test_pd_mt)
end

local function registerSliderCallback(slider, fn)
    slider:RegisterSliderCallback(fn)
    civvaccess_shared.sliderCallbacks[slider] = fn
end

local function registerCheckHandler(cb, fn)
    cb:RegisterCheckHandler(fn)
    civvaccess_shared.checkBoxCallbacks = civvaccess_shared.checkBoxCallbacks or {}
    civvaccess_shared.checkBoxCallbacks[cb] = fn
end

-- Stub Controls matching the shape button-list tests expect.
local ctrlState
local function makeCtrl(name)
    return setmetatable({ _name = name }, { __index = {
        IsHidden   = function(self) return ctrlState[self._name].hidden   end,
        IsDisabled = function(self) return ctrlState[self._name].disabled end,
    }})
end
local function setCtrls(names)
    Controls = {}
    ctrlState = {}
    for _, name in ipairs(names) do
        ctrlState[name] = { hidden = false, disabled = false }
        Controls[name] = makeCtrl(name)
    end
end

-- Factory ----------------------------------------------------------------

function M.test_create_requires_name_and_displayName()
    setup()
    populateControls({})
    local ok = pcall(Menu.create, { items = {} })
    T.falsy(ok, "missing name/displayName should fail")
end

function M.test_create_requires_items_or_tabs()
    setup()
    populateControls({})
    local ok = pcall(Menu.create, { name = "X", displayName = "x" })
    T.falsy(ok, "no items/tabs should fail")
end

function M.test_create_shape_matches_handler_contract()
    setup()
    setCtrls({"A", "B"})
    local h = Menu.create({
        name = "T", displayName = "Test",
        items = {
            MenuItems.Button({ controlName = "A", textKey = "LBL_A",
                activate = function() end }),
            MenuItems.Button({ controlName = "B", textKey = "LBL_B",
                activate = function() end }),
        },
    })
    T.eq(h.capturesAllInput, true)
    T.eq(type(h.bindings), "table")
    T.eq(type(h.onActivate), "function")
    T.eq(type(h.onDeactivate), "function")
    T.eq(type(h.setItems), "function")
    T.eq(type(h.refresh), "function")
end

function M.test_missing_control_logs_warn_and_keeps_item()
    setup()
    populateControls({})
    local h = Menu.create({
        name = "T", displayName = "Test",
        items = {
            MenuItems.Checkbox({ controlName = "Missing", textKey = "LBL" }),
        },
    })
    T.truthy(#warns >= 1, "missing-control warn logged")
end

-- Button navigation (formerly SimpleListHandler) ------------------------

local function buttonSpec(names)
    local items = {}
    for _, name in ipairs(names) do
        items[#items + 1] = MenuItems.Button({
            controlName = name, textKey = "LABEL_" .. name,
            activate = function() end,
        })
    end
    return items
end

function M.test_down_moves_to_next_item()
    setup()
    setCtrls({"A", "B", "C"})
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 2)
end

function M.test_up_wraps_from_top_to_bottom()
    setup()
    setCtrls({"A", "B", "C"})
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_UP, 0, WM_KEYDOWN)
    T.eq(h._index, 3)
end

function M.test_down_wraps_from_bottom_to_top()
    setup()
    setCtrls({"A", "B", "C"})
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    h._index = 3
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 1)
end

function M.test_hidden_items_are_skipped()
    setup()
    setCtrls({"A", "B", "C"})
    ctrlState.B.hidden = true
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 3, "hidden B skipped")
end

function M.test_all_hidden_navigation_is_noop()
    setup()
    setCtrls({"A", "B", "C"})
    ctrlState.A.hidden = true
    ctrlState.B.hidden = true
    ctrlState.C.hidden = true
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    local before = h._index
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_UP, 0, WM_KEYDOWN)
    T.eq(h._index, before, "no movement, no infinite loop")
end

function M.test_home_jumps_to_first_navigable()
    setup()
    setCtrls({"A", "B", "C"})
    ctrlState.A.hidden = true
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    h._index = 3
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(h._index, 2, "A hidden, first navigable is B")
end

function M.test_end_jumps_to_last_navigable()
    setup()
    setCtrls({"A", "B", "C"})
    ctrlState.C.hidden = true
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_END, 0, WM_KEYDOWN)
    T.eq(h._index, 2, "C hidden, last navigable is B")
end

function M.test_enter_fires_activate()
    setup()
    setCtrls({"A", "B", "C"})
    local fired = 0
    local items = {
        MenuItems.Button({ controlName = "A", textKey = "LA",
            activate = function() fired = fired + 1 end }),
        MenuItems.Button({ controlName = "B", textKey = "LB",
            activate = function() end }),
    }
    local h = Menu.create({ name = "T", displayName = "Test", items = items })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 1)
end

function M.test_space_also_fires_activate()
    setup()
    setCtrls({"A"})
    local fired = 0
    local h = Menu.create({ name = "T", displayName = "Test",
        items = { MenuItems.Button({ controlName = "A", textKey = "L",
            activate = function() fired = fired + 1 end }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_SPACE, 0, WM_KEYDOWN)
    T.eq(fired, 1)
end

function M.test_enter_activate_error_caught_and_logged()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Test",
        items = { MenuItems.Button({ controlName = "A", textKey = "L",
            activate = function() error("kaboom") end }) } })
    HandlerStack.push(h)
    local consumed = InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(consumed, "binding still consumed after error")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_enter_plays_click_sound()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Test",
        items = { MenuItems.Button({ controlName = "A", textKey = "L",
            activate = function() end }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 1)
    T.eq(sounds[1], "AS2D_IF_SELECT")
end

function M.test_enter_on_hidden_current_logs_warn_no_crash()
    setup()
    setCtrls({"A", "B"})
    local fired = 0
    local h = Menu.create({ name = "T", displayName = "Test",
        items = {
            MenuItems.Button({ controlName = "A", textKey = "L",
                activate = function() fired = fired + 1 end }),
            MenuItems.Button({ controlName = "B", textKey = "L",
                activate = function() end }),
        } })
    HandlerStack.push(h)
    ctrlState.A.hidden = true
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 0, "activate not fired on invalid item")
    T.truthy(#warns >= 1)
end

function M.test_post_activate_revalidation_advances_on_hidden_flip()
    setup()
    setCtrls({"A", "B"})
    local h = Menu.create({ name = "T", displayName = "Test",
        items = {
            MenuItems.Button({ controlName = "A", textKey = "LABEL_A",
                activate = function() ctrlState.A.hidden = true end }),
            MenuItems.Button({ controlName = "B", textKey = "LABEL_B",
                activate = function() end }),
        } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._index, 2, "cursor advanced to next valid")
    T.truthy(#speaks >= 1)
    T.eq(speaks[#speaks].text, "LABEL_B")
    T.falsy(speaks[#speaks].interrupt, "next-valid speak is queued")
end

-- Disabled-but-visible walking ------------------------------------------

function M.test_navigation_walks_disabled_items()
    setup()
    setCtrls({"A", "B", "C"})
    ctrlState.B.disabled = true
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B","C"}) })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 2, "disabled B is still navigable")
    T.eq(speaks[1].text, "LABEL_B, disabled", "disabled suffix appended")
end

function M.test_enter_on_disabled_is_noop_no_activate_no_sound()
    setup()
    setCtrls({"A"})
    local fired = 0
    local h = Menu.create({ name = "T", displayName = "Test",
        items = { MenuItems.Button({ controlName = "A", textKey = "LABEL_A",
            activate = function() fired = fired + 1 end }) } })
    ctrlState.A.disabled = true
    HandlerStack.push(h)
    sounds = {}
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 0, "activate not fired on disabled item")
    T.eq(#sounds, 0, "no click sound on disabled Enter")
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "LABEL_A, disabled", "disabled label re-spoken")
end

function M.test_onActivate_first_item_disabled_announces_with_suffix()
    setup()
    setCtrls({"A", "B"})
    ctrlState.A.disabled = true
    local h = Menu.create({ name = "T", displayName = "Test",
        items = buttonSpec({"A","B"}) })
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A, disabled")
end

-- Checkbox -------------------------------------------------------------

function M.test_checkbox_enter_toggles_and_announces_on()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "Foo", textKey = "LBL_FOO" }) } })
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "Foo", textKey = "LBL_FOO" }) } })
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = {
            MenuItems.Checkbox({ controlName = "A", textKey = "LBL_A" }),
            MenuItems.Checkbox({ controlName = "B", textKey = "LBL_B" }),
        } })
    HandlerStack.push(h)
    T.eq(speaks[1].text, "Screen")
    T.eq(speaks[2].text, "LBL_A, on")
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "LBL_B, off")
end

function M.test_checkbox_fires_captured_handler_on_toggle()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    local received = {}
    registerCheckHandler(cb, function(v) received[#received + 1] = v end)
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "Foo", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#received, 1)
    T.eq(received[1], true)
    InputRouter.dispatch(Keys.VK_SPACE, 0, WM_KEYDOWN)
    T.eq(#received, 2)
    T.eq(received[2], false)
end

-- Slider ---------------------------------------------------------------

function M.test_slider_right_increments_by_small_step()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50%")
    populateControls({ Sld = slider, Lbl = label })
    registerSliderCallback(slider, function(v)
        label:SetText(string.format("%d%%", math.floor(v * 100 + 0.5)))
    end)
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "LBL_SLD" }) } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.51)
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "LBL" }) } })
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.51, "value still changes")
    T.truthy(#warns >= 1, "callback-missing warn logged")
end

function M.test_slider_left_decrements()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.50 })
    local label  = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    slider:RegisterSliderCallback(function(v)
        label:SetText(tostring(math.floor(v * 100 + 0.5)))
    end)
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.49)
end

function M.test_slider_shift_left_decrements_by_big_step()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "LBL" }) } })
    HandlerStack.push(h)
    UI.ShiftKeyDown = function() return true end
    InputRouter.dispatch(Keys.VK_LEFT, 1, WM_KEYDOWN)
    T.truthy(math.abs(slider:GetValue() - 0.4) < 1e-6)
end

function M.test_slider_right_at_max_stays_clamped()
    setup()
    local slider = Polyfill.makeSlider({ value = 1.0 })
    local label  = Polyfill.makeLabel("100")
    populateControls({ Sld = slider, Lbl = label })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 1.0)
end

-- Home/End belong to list nav even with sliders on the screen.
function M.test_home_with_slider_at_position_one_goes_to_first_item()
    setup()
    local cb     = Polyfill.makeCheckBox()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("50")
    populateControls({ CB = cb, Sld = slider, Lbl = label })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = {
            MenuItems.Checkbox({ controlName = "CB", textKey = "LBL_CB" }),
            MenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl",
                textKey = "LBL_SLD" }),
        } })
    HandlerStack.push(h)
    h._index = 2  -- on slider
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(h._index, 1, "Home navigated to first item, did not snap slider")
    T.eq(slider:GetValue(), 0.5, "slider unchanged")
end

-- PullDown -------------------------------------------------------------

function M.test_pulldown_enter_pushes_subhandler_from_probe()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
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

    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) } })
    HandlerStack.push(h)
    speaks = {}
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2, "sub pushed on top")
    T.eq(HandlerStack.active().name, "T/PD_PullDown")
    T.eq(sounds[1], "AS2D_IF_SELECT", "click sound on dropdown open")
    local heard = false
    for _, s in ipairs(speaks) do if s.text == "Easy" then heard = true end end
    T.truthy(heard, "first entry text announced")

    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#invoked, 1)
    T.eq(invoked[1].v1, 2, "void1 forwarded")
    T.eq(HandlerStack.count(), 1, "sub popped after select")
end

function M.test_pulldown_enter_without_probe_logs_warn_and_announces_current()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    pd:GetButton():SetText("Current")
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(#warns >= 1, "missing probe state warns")
    T.eq(speaks[#speaks].text, "LBL_PD, Current")
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = {
            MenuItems.Checkbox({ controlName = "CB", textKey = "LBL_CB" }),
            MenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }),
        } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 2)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2)
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
    pd:RegisterSelectionCallback(function() pd:SetHide(true) end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Entry")
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = {
            MenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }),
            MenuItems.Checkbox({ controlName = "After", textKey = "LBL_AFTER" }),
        } })
    HandlerStack.push(h)
    T.eq(h._index, 1, "starts on pulldown")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._index, 2, "cursor advanced off the now-hidden pulldown")
    T.truthy(#speaks >= 1, "re-activation announced the new current item")
end

-- Tooltip composition --------------------------------------------------

function M.test_tooltip_appended_after_label_value()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SHOW_MAP"]    = "Show map"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SHOW_MAP_TT"] = "Toggles the map overlay"
    local cb = Polyfill.makeCheckBox({ checked = true })
    populateControls({ Foo = cb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "Foo",
            textKey    = "TXT_KEY_CIVVACCESS_TEST_SHOW_MAP",
            tooltipKey = "TXT_KEY_CIVVACCESS_TEST_SHOW_MAP_TT" }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Show map, on, Toggles the map overlay")
end

function M.test_tooltip_dedupes_against_label()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FS"]    = "Fullscreen"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FS_TT"] = "Fullscreen. Some extra detail"
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ X = cb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "X",
            textKey    = "TXT_KEY_CIVVACCESS_TEST_FS",
            tooltipKey = "TXT_KEY_CIVVACCESS_TEST_FS_TT" }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Fullscreen, off, Some extra detail",
        "duplicate 'Fullscreen' sentence dropped from tooltip")
end

function M.test_tooltipFn_appends_dynamic_tooltip()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local calls = 0
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "C", textKey = "LBL",
            tooltipFn = function() calls = calls + 1; return "live tip" end }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "LBL, off, live tip")
    T.truthy(calls >= 1)
end

function M.test_tooltipFn_error_is_logged_and_swallowed()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "C", textKey = "LBL",
            tooltipFn = function() error("boom") end }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "LBL, off")
    T.truthy(#errors >= 1)
end

function M.test_tooltipFn_nil_result_does_not_add_comma()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Button({ controlName = "A", textKey = "LABEL_A",
            tooltipFn = function() return nil end,
            activate  = function() end }) } })
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A",
        "nil tooltipFn leaves announcement clean")
end

function M.test_slider_empty_label_falls_back_to_textKey()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SLD"] = "Delay"
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label  = Polyfill.makeLabel("")
    populateControls({ Sld = slider, Lbl = label })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Slider({ controlName = "Sld",
            labelControlName = "Lbl", textKey = "TXT_KEY_CIVVACCESS_TEST_SLD" }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Delay", "empty label control -> textKey label alone")
end

-- Tabs ------------------------------------------------------------------

function M.test_tabs_tab_key_cycles_and_resets_cursor()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    local shown = 1
    populateControls({ CA = cbA, CB = cbB })
    local h = Menu.create({ name = "T", displayName = "Screen",
        tabs = {
            { name = "TAB_A", showPanel = function() shown = 1 end,
              items = { MenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) } },
            { name = "TAB_B", showPanel = function() shown = 2 end,
              items = { MenuItems.Checkbox({ controlName = "CB", textKey = "LB" }) } },
        } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(shown, 2)
    T.eq(h._tabIndex, 2)
    T.eq(h._index, 1)
    T.eq(speaks[1].text, "TAB_B")
end

function M.test_tabs_shift_tab_cycles_backward_wraps()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    local cbC = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB, CC = cbC })
    local h = Menu.create({ name = "T", displayName = "Screen",
        tabs = {
            { name = "A", items = { MenuItems.Checkbox({ controlName = "CA", textKey = "L" }) } },
            { name = "B", items = { MenuItems.Checkbox({ controlName = "CB", textKey = "L" }) } },
            { name = "C", items = { MenuItems.Checkbox({ controlName = "CC", textKey = "L" }) } },
        } })
    HandlerStack.push(h)
    UI.ShiftKeyDown = function() return true end
    InputRouter.dispatch(Keys.VK_TAB, 1, WM_KEYDOWN)
    T.eq(h._tabIndex, 3, "wrapped from 1 backward to 3")
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        tabs = {
            { name = "TAB_A", items = { MenuItems.Checkbox({ controlName = "Filler", textKey = "L" }) } },
            { name = "TAB_B", items = { MenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) } },
        } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2)
    T.eq(h._index, 1)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2, "tab preserved")
    T.eq(h._index, 1, "item index preserved")
end

-- Install --------------------------------------------------------------

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
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "A", textKey = "L" }) } })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
    ctx._sh(true, false)
    T.eq(HandlerStack.count(), 0)
end

function M.test_install_double_show_keeps_stack_depth_at_one()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "S", displayName = "Screen",
        items = buttonSpec({"A"}) })
    ctx._sh(false, false)
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1, "idempotent push via removeByName+push")
end

function M.test_install_prior_showhide_chained()
    setup()
    local a = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local ctx = makeContextPtr()
    local priorArg = nil
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "A", textKey = "L" }) },
        priorShowHide = function(bIsHide) priorArg = bIsHide end })
    ctx._sh(false, false)
    T.eq(priorArg, false)
    T.eq(HandlerStack.count(), 1)
end

function M.test_install_prior_showhide_error_caught_push_still_happens()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "S", displayName = "Screen",
        items = buttonSpec({"A"}),
        priorShowHide = function() error("prior boom") end })
    ctx._sh(false, false)
    T.truthy(#errors >= 1, "prior error logged")
    T.eq(HandlerStack.count(), 1, "push not blocked by prior error")
end

function M.test_install_show_parks_focus_on_named_control()
    setup()
    local a    = Polyfill.makeCheckBox()
    local eb   = Polyfill.makeEditBox({ text = "" })
    local park = Polyfill.makeButton()
    populateControls({ A = a, E = eb, Cancel = park })
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "T", displayName = "Screen",
        focusParkControl = "Cancel",
        priorShowHide = function(bIsHide) if not bIsHide then eb:TakeFocus() end end,
        items = {
            MenuItems.Textfield({ controlName = "E", textKey = "L" }),
            MenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
        } })
    ctx._sh(false, false)
    T.eq(park._hasFocus, true, "focus parked on Cancel after base's TakeFocus")
end

function M.test_install_esc_bypasses_to_prior_input()
    setup()
    local a = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local ctx = makeContextPtr()
    local priorFired = 0
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "A", textKey = "L" }) },
        priorInput = function(msg, wp, lp)
            if wp == Keys.VK_ESCAPE then priorFired = priorFired + 1 end
            return true
        end })
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
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = { MenuItems.Pulldown({ controlName = "PD", textKey = "L" }) },
        priorInput = function(msg, wp, lp)
            if wp == Keys.VK_ESCAPE then priorFired = priorFired + 1 end
            return true
        end })
    ctx._sh(false, false)
    ctx._in(WM_KEYDOWN, Keys.VK_RETURN, 0)
    T.eq(HandlerStack.count(), 2)
    local consumed = ctx._in(WM_KEYDOWN, Keys.VK_ESCAPE, 0)
    T.truthy(consumed)
    T.eq(priorFired, 0, "priorInput NOT called")
    T.eq(HandlerStack.count(), 1, "sub popped")
end

function M.test_install_input_falls_back_to_prior_on_unbound_key()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    local priorFired = 0
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = buttonSpec({"A"}),
        priorInput = function() priorFired = priorFired + 1; return true end })
    ctx._sh(false, false)
    -- Unbound key that is not in any binding: e.g. letter 'Z'. Since the
    -- menu has capturesAllInput = true, InputRouter consumes it; fallback
    -- to priorInput only happens for Esc (bypass) or when unhandled.
    -- Here we verify that priorInput does NOT fire for bound arrow keys.
    ctx._in(WM_KEYDOWN, Keys.VK_DOWN, 0)
    T.eq(priorFired, 0)
end

function M.test_close_reopen_resets_cursor()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ A = cbA, B = cbB })
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = {
            MenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
            MenuItems.Checkbox({ controlName = "B", textKey = "LB" }),
        } })
    ctx._sh(false, false)
    local h = HandlerStack.active()
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._index, 2)
    ctx._sh(true, false)
    ctx._sh(false, false)
    T.eq(HandlerStack.active()._index, 1, "cursor reset on reopen")
end

function M.test_tab_switch_reparks_focus_on_configured_control()
    setup()
    local cbA  = Polyfill.makeCheckBox()
    local ebB  = Polyfill.makeEditBox({ text = "" })
    local park = Polyfill.makeButton()
    populateControls({ CA = cbA, EB = ebB, Park = park })
    local h = Menu.create({ name = "T", displayName = "Screen",
        focusParkControl = "Park",
        tabs = {
            { name = "TAB_A",
              items = { MenuItems.Checkbox({ controlName = "CA", textKey = "L" }) } },
            { name = "TAB_B",
              showPanel = function() ebB:TakeFocus() end,
              items = { MenuItems.Textfield({ controlName = "EB", textKey = "L" }) } },
        } })
    HandlerStack.push(h)
    park._hasFocus = nil
    ebB._hasFocus  = nil
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2)
    T.eq(park._hasFocus, true,
        "park control focused after tab switch so arrow keys reach the form")
end

-- Preamble --------------------------------------------------------------

function M.test_preamble_string_queued_after_displayName()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = "Are you sure?", items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    T.eq(#speaks, 3)
    T.eq(speaks[1].text, "Screen")
    T.truthy(speaks[1].interrupt)
    T.eq(speaks[2].text, "Are you sure?")
    T.falsy(speaks[2].interrupt)
    T.eq(speaks[3].text, "LABEL_A")
    T.falsy(speaks[3].interrupt)
end

function M.test_preamble_function_called_at_onActivate_not_at_create()
    setup()
    setCtrls({"A"})
    local calls = 0
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = function() calls = calls + 1; return "dynamic body" end,
        items = buttonSpec({"A"}) })
    T.eq(calls, 0, "preamble fn not called at create time")
    HandlerStack.push(h)
    T.eq(calls, 1, "preamble fn called once at onActivate")
    T.eq(speaks[2].text, "dynamic body")
end

function M.test_preamble_function_returning_empty_is_skipped()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = function() return "" end, items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    T.eq(#speaks, 2, "empty preamble not spoken")
end

function M.test_refresh_respeaks_when_function_preamble_changes()
    setup()
    setCtrls({"A"})
    local body = "first"
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = function() return body end, items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    speaks = {}
    body = "second"
    h.refresh()
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "second")
    T.truthy(speaks[1].interrupt, "refresh interrupts")
end

function M.test_refresh_noop_when_unchanged()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = function() return "same" end, items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0)
end

function M.test_refresh_noop_when_preamble_is_string()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = "static body", items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0, "string preamble never re-speaks")
end

function M.test_refresh_fn_error_logged_no_crash()
    setup()
    setCtrls({"A"})
    local h = Menu.create({ name = "T", displayName = "Screen",
        preamble = function() error("boom") end, items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.truthy(#errors >= 1, "preamble fn error logged")
    T.eq(#speaks, 0)
end

-- Empty items -----------------------------------------------------------

function M.test_empty_items_onActivate_speaks_displayName_only()
    setup()
    populateControls({})
    local h = Menu.create({ name = "S", displayName = "Splash", items = {} })
    HandlerStack.push(h)
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "Splash")
end

function M.test_empty_items_onEnter_is_safe_noop()
    setup()
    populateControls({})
    local h = Menu.create({ name = "S", displayName = "Splash", items = {} })
    HandlerStack.push(h)
    sounds, speaks, warns = {}, {}, {}
    local consumed = InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(consumed, "Enter still consumed by barrier")
    T.eq(#sounds, 0)
    T.eq(#speaks, 0)
    T.eq(#warns, 0, "empty Enter is silent")
end

-- shouldActivate --------------------------------------------------------

function M.test_shouldActivate_false_skips_push()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = buttonSpec({"A"}),
        shouldActivate = function() return false end })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 0, "push skipped")
    T.eq(#speaks, 0, "no speech")
end

function M.test_shouldActivate_true_pushes()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = buttonSpec({"A"}),
        shouldActivate = function() return true end })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
end

-- deferActivate ---------------------------------------------------------

function M.test_deferActivate_delays_push_to_update_tick()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "D", displayName = "Screen",
        items = buttonSpec({"A"}), deferActivate = true })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 0, "push not synchronous with show")
    T.eq(#speaks, 0)
    T.eq(ctx._update, TickPump.tick, "TickPump owns Update")
    TickPump.tick()
    T.eq(HandlerStack.count(), 1, "push runs on deferred tick")
    T.eq(speaks[1].text, "Screen")
end

function M.test_deferActivate_hide_before_tick_cancels_push()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "D", displayName = "Screen",
        items = buttonSpec({"A"}), deferActivate = true })
    ctx._sh(false, false)
    ctx._sh(true, false)
    TickPump.tick()
    T.eq(HandlerStack.count(), 0, "no push after cancel")
    T.eq(#speaks, 0)
end

function M.test_deferActivate_hidden_at_tick_skips_push()
    setup()
    setCtrls({"A"})
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "D", displayName = "Screen",
        items = buttonSpec({"A"}), deferActivate = true })
    ctx._sh(false, false)
    ctx._hidden = true
    TickPump.tick()
    T.eq(HandlerStack.count(), 0, "IsHidden check blocks push")
end

-- setItems --------------------------------------------------------------

function M.test_setItems_replaces_items_single_tab()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "A", textKey = "FIRST" }) } })
    HandlerStack.push(h)
    speaks = {}
    h.setItems({
        MenuItems.Checkbox({ control = a, labelText = "A2" }),
        MenuItems.Checkbox({ control = b, labelText = "B2" }),
    })
    T.eq(#h._items, 2)
    T.eq(h._items[2].labelText, "B2")
    T.eq(#speaks, 0, "setItems does not announce on swap")
end

function M.test_setItems_replaces_tab_items_by_index()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    populateControls({ A = a, B = b })
    local h = Menu.create({ name = "T", displayName = "Screen",
        tabs = {
            { name = "TAB_A", items = { MenuItems.Checkbox({ controlName = "A", textKey = "LA" }) } },
            { name = "TAB_B", items = { MenuItems.Checkbox({ controlName = "B", textKey = "LB" }) } },
        } })
    HandlerStack.push(h)
    h.setItems({
        MenuItems.Checkbox({ control = b, labelText = "B-NEW-1" }),
        MenuItems.Checkbox({ control = b, labelText = "B-NEW-2" }),
    }, 2)
    T.eq(#h.tabs[2]._items, 2)
    T.eq(h.tabs[2]._items[1].labelText, "B-NEW-1")
    T.eq(#h.tabs[1]._items, 1, "tab 1 items untouched")
end

function M.test_setItems_clamps_cursor_when_out_of_range()
    setup()
    local a = Polyfill.makeCheckBox()
    local b = Polyfill.makeCheckBox()
    local c = Polyfill.makeCheckBox()
    populateControls({ A = a, B = b, C = c })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = {
            MenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
            MenuItems.Checkbox({ controlName = "B", textKey = "LB" }),
            MenuItems.Checkbox({ controlName = "C", textKey = "LC" }),
        } })
    HandlerStack.push(h)
    h._index = 3
    h.setItems({ MenuItems.Checkbox({ control = a, labelText = "A" }) })
    T.eq(h._index, 1, "cursor clamped to first valid item after shrink")
end

-- Dynamic-item features --------------------------------------------------

function M.test_labelText_overrides_textKey_lookup()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ controlName = "C",
            labelText = "PreLocalized Option" }) } })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "PreLocalized Option, off",
        "labelText used verbatim")
end

function M.test_control_ref_bypasses_controlName_lookup()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = true })
    Controls = {}
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Checkbox({ control = cb, textKey = "DIRECT" }) } })
    HandlerStack.push(h)
    T.eq(#warns, 0, "no missing-control warnings")
    T.eq(speaks[2].text, "DIRECT, on")
end

-- capturesAllInput barrier ----------------------------------------------

function M.test_capturesAllInput_blocks_lower_handlers()
    setup()
    setCtrls({"A"})
    local lowerFired = 0
    HandlerStack.push({
        name = "lower", capturesAllInput = false,
        bindings = {{ key = 65, mods = 0,
            fn = function() lowerFired = lowerFired + 1 end }},
    })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = buttonSpec({"A"}) })
    HandlerStack.push(h)
    local consumed = InputRouter.dispatch(65, 0, WM_KEYDOWN)
    T.truthy(consumed, "barrier swallows unbound key")
    T.eq(lowerFired, 0)
end

-- Edit mode -------------------------------------------------------------

function M.test_enter_on_textfield_pushes_edit_submenu()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local top = HandlerStack.active()
    T.truthy(top._editMode, "edit-mode sub is on top of stack")
    T.eq(top.name, "T/E_Edit")
    T.eq(top.capturesAllInput, false,
        "capturesAllInput off so unbound keys fall through to EditBox")
    T.eq(eb:GetText(), "", "editbox cleared")
    TickPump.tick()
    T.eq(eb._hasFocus, true, "engine focus taken for typing on next tick")
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "editing LBL" then found = true end
    end
    T.truthy(found, "editing announcement fired")
end

function M.test_escape_during_edit_restores_and_pops()
    setup()
    local eb   = Polyfill.makeEditBox({ text = "Athens" })
    local park = Polyfill.makeButton()
    populateControls({ E = eb, Park = park })
    local h = Menu.create({ name = "T", displayName = "Screen",
        focusParkControl = "Park",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("partial")
    park._hasFocus = nil
    speaks = {}
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(HandlerStack.active(), h, "edit sub popped; menu is top")
    T.eq(HandlerStack.count(), 1)
    T.eq(eb:GetText(), "Athens", "original text restored")
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
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("new name")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.active(), h, "edit sub popped; menu is top")
    T.eq(eb:GetText(), "new name", "typed text preserved, no restore on commit")
end

function M.test_commit_fires_priorCallback_with_final_text()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local received = {}
    local function prior(text, control, bIsEnter)
        received[#received + 1] = { text = text, control = control, bIsEnter = bIsEnter }
    end
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL",
            priorCallback = prior }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("committed")
    received = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#received, 1, "priorCallback fired exactly once on commit")
    T.eq(received[1].text, "committed")
    T.eq(received[1].control, eb)
    T.eq(received[1].bIsEnter, true,
        "bIsEnter=true so priorCallback mimics native Enter-triggered call")
end

function M.test_commit_announces_committed_value()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("new value")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "new value",
        "commit speaks the just-saved value")
end

function M.test_commit_on_empty_announces_blank()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "blank",
        "empty commit speaks the blank sentinel")
end

function M.test_commit_without_priorCallback_is_safe()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("committed")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.active(), h, "edit exited cleanly")
    T.eq(#errors, 0, "no error logged")
end

function M.test_restore_does_not_fire_priorCallback()
    setup()
    local eb = Polyfill.makeEditBox({ text = "original" })
    populateControls({ E = eb })
    local fired = 0
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL",
            priorCallback = function() fired = fired + 1 end }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("partial")
    fired = 0
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(fired, 0,
        "restore path must NOT fire priorCallback; never committed this text")
    T.eq(eb:GetText(), "original")
end

function M.test_edit_submenu_has_no_arrow_bindings()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local editSub = HandlerStack.active()
    for _, b in ipairs(editSub.bindings) do
        T.truthy(b.key ~= Keys.VK_UP and b.key ~= Keys.VK_DOWN
              and b.key ~= Keys.VK_LEFT and b.key ~= Keys.VK_RIGHT,
            "edit-mode bindings must not intercept arrow keys")
    end
end

function M.test_reenter_edit_installs_fresh_wrapping_callback()
    setup()
    local eb = Polyfill.makeEditBox({ text = "first" })
    populateControls({ E = eb })
    local priorCalls = 0
    local function prior() priorCalls = priorCalls + 1 end
    local h = Menu.create({ name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL",
            priorCallback = prior }) } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)   -- enter edit
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)   -- commit (reinstates prior)
    T.eq(eb._cb, prior, "prior reinstated on exit")
    priorCalls = 0
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)   -- re-enter edit
    T.truthy(eb._cb ~= prior, "new wrapping callback installed")
    eb._cb("x", eb, false)
    T.eq(priorCalls, 1, "re-entered wrapper still chains to prior")
end

function M.test_edit_mode_enter_keyup_is_claimed()
    setup()
    local eb = Polyfill.makeEditBox({ text = "x" })
    populateControls({ E = eb })
    local ctx = makeContextPtr()
    Menu.install(ctx, { name = "T", displayName = "Screen",
        items = { MenuItems.Textfield({ controlName = "E", textKey = "LBL" }) } })
    ctx._sh(false, false)
    ctx._in(WM_KEYDOWN, Keys.VK_RETURN, 0)  -- enter edit
    -- Enter KEYUP (msg 257) while in edit mode should be claimed so the
    -- engine's Enter-release doesn't revoke focus.
    local consumed = ctx._in(257, Keys.VK_RETURN, 0)
    T.truthy(consumed, "KEYUP claimed during edit mode")
end

return M

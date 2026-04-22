-- BaseMenu + BaseMenuItems tests. HandlerStack, InputRouter, Nav, TickPump,
-- PullDownProbe, BaseMenu, and BaseMenuItems are loaded for real. Widget controls
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
    _test_pd_mt = {
        __index = {
            GetButton = proto.GetButton,
            ClearEntries = proto.ClearEntries,
            BuildEntry = proto.BuildEntry,
            CalculateInternals = proto.CalculateInternals,
            RegisterSelectionCallback = proto.RegisterSelectionCallback,
            IsHidden = proto.IsHidden,
            IsDisabled = proto.IsDisabled,
            SetHide = proto.SetHide,
            SetDisabled = proto.SetDisabled,
        },
    }
end

local function setup()
    warns, errors = {}, {}
    Log.warn = function(m)
        warns[#warns + 1] = m
    end
    Log.error = function(m)
        errors[#errors + 1] = m
    end
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

    sounds = {}
    Events.AudioPlay2DSound = function(id)
        sounds[#sounds + 1] = id
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
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuEditMode.lua")
    HandlerStack._reset()
    TickPump._reset()

    civvaccess_shared.pullDownProbeInstalled = false
    civvaccess_shared.pullDownCallbacks = {}
    civvaccess_shared.pullDownEntries = {}
    civvaccess_shared.sliderProbeInstalled = false
    civvaccess_shared.sliderCallbacks = {}
    civvaccess_shared.checkBoxProbeInstalled = false
    civvaccess_shared.checkBoxCallbacks = {}
    civvaccess_shared.buttonProbeInstalled = false
    civvaccess_shared.buttonCallbacks = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_ON"] = "on"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHECK_OFF"] = "off"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"] = "edit"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"] = "blank"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"] = "editing {1_Label}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOICE_SELECTED"] = "selected"

    resetPDMetatable()
end

local WM_KEYDOWN = 256

-- Helpers --------------------------------------------------------------

local function populateControls(map)
    Controls = {}
    for name, c in pairs(map) do
        Controls[name] = c
    end
end

local function patchProbeFromPullDown(pd)
    PullDownProbe.ensureInstalled(pd)
end

local function makePullDownWithMetatable()
    if _test_pd_mt == nil then
        resetPDMetatable()
    end
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
    return setmetatable({ _name = name }, {
        __index = {
            IsHidden = function(self)
                return ctrlState[self._name].hidden
            end,
            IsDisabled = function(self)
                return ctrlState[self._name].disabled
            end,
        },
    })
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
    local ok = pcall(BaseMenu.create, { items = {} })
    T.falsy(ok, "missing name/displayName should fail")
end

function M.test_create_requires_items_or_tabs()
    setup()
    populateControls({})
    local ok = pcall(BaseMenu.create, { name = "X", displayName = "x" })
    T.falsy(ok, "no items/tabs should fail")
end

function M.test_create_shape_matches_handler_contract()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({ controlName = "A", textKey = "LBL_A", activate = function() end }),
            BaseMenuItems.Button({ controlName = "B", textKey = "LBL_B", activate = function() end }),
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
    BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Checkbox({ controlName = "Missing", textKey = "LBL" }),
        },
    })
    T.truthy(#warns >= 1, "missing-control warn logged")
end

-- Button navigation (formerly SimpleListHandler) ------------------------

local function buttonSpec(names)
    local items = {}
    for _, name in ipairs(names) do
        items[#items + 1] = BaseMenuItems.Button({
            controlName = name,
            textKey = "LABEL_" .. name,
            activate = function() end,
        })
    end
    return items
end

function M.test_down_moves_to_next_item()
    setup()
    setCtrls({ "A", "B", "C" })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2)
end

function M.test_up_wraps_from_top_to_bottom()
    setup()
    setCtrls({ "A", "B", "C" })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_UP, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 3)
end

function M.test_down_wraps_from_bottom_to_top()
    setup()
    setCtrls({ "A", "B", "C" })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    h._indices[1] = 3
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1)
end

function M.test_hidden_items_are_skipped()
    setup()
    setCtrls({ "A", "B", "C" })
    ctrlState.B.hidden = true
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "hidden B skipped")
end

function M.test_all_hidden_navigation_is_noop()
    setup()
    setCtrls({ "A", "B", "C" })
    ctrlState.A.hidden = true
    ctrlState.B.hidden = true
    ctrlState.C.hidden = true
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    local before = h._indices[1]
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_UP, 0, WM_KEYDOWN)
    T.eq(h._indices[1], before, "no movement, no infinite loop")
end

function M.test_home_jumps_to_first_navigable()
    setup()
    setCtrls({ "A", "B", "C" })
    ctrlState.A.hidden = true
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    h._indices[1] = 3
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "A hidden, first navigable is B")
end

function M.test_end_jumps_to_last_navigable()
    setup()
    setCtrls({ "A", "B", "C" })
    ctrlState.C.hidden = true
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_END, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "C hidden, last navigable is B")
end

function M.test_enter_fires_activate()
    setup()
    setCtrls({ "A", "B", "C" })
    local fired = 0
    local items = {
        BaseMenuItems.Button({
            controlName = "A",
            textKey = "LA",
            activate = function()
                fired = fired + 1
            end,
        }),
        BaseMenuItems.Button({ controlName = "B", textKey = "LB", activate = function() end }),
    }
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = items })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 1)
end

function M.test_space_also_fires_activate()
    setup()
    setCtrls({ "A" })
    local fired = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "L",
                activate = function()
                    fired = fired + 1
                end,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_SPACE, 0, WM_KEYDOWN)
    T.eq(fired, 1)
end

function M.test_enter_activate_error_caught_and_logged()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "L",
                activate = function()
                    error("kaboom")
                end,
            }),
        },
    })
    HandlerStack.push(h)
    local consumed = InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(consumed, "binding still consumed after error")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_enter_plays_click_sound()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = { BaseMenuItems.Button({ controlName = "A", textKey = "L", activate = function() end }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 1)
    T.eq(sounds[1], "AS2D_IF_SELECT")
end

function M.test_enter_on_hidden_current_logs_warn_no_crash()
    setup()
    setCtrls({ "A", "B" })
    local fired = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "L",
                activate = function()
                    fired = fired + 1
                end,
            }),
            BaseMenuItems.Button({ controlName = "B", textKey = "L", activate = function() end }),
        },
    })
    HandlerStack.push(h)
    ctrlState.A.hidden = true
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 0, "activate not fired on invalid item")
    T.truthy(#warns >= 1)
end

function M.test_post_activate_revalidation_advances_on_hidden_flip()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "LABEL_A",
                activate = function()
                    ctrlState.A.hidden = true
                end,
            }),
            BaseMenuItems.Button({ controlName = "B", textKey = "LABEL_B", activate = function() end }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "cursor advanced to next valid")
    T.truthy(#speaks >= 1)
    T.eq(speaks[#speaks].text, "LABEL_B")
    T.falsy(speaks[#speaks].interrupt, "next-valid speak is queued")
end

-- Disabled-but-visible walking ------------------------------------------

function M.test_navigation_walks_disabled_items()
    setup()
    setCtrls({ "A", "B", "C" })
    ctrlState.B.disabled = true
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B", "C" }) })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "disabled B is still navigable")
    T.eq(speaks[1].text, "LABEL_B, disabled", "disabled suffix appended")
end

function M.test_enter_on_disabled_is_noop_no_activate_no_sound()
    setup()
    setCtrls({ "A" })
    local fired = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Test",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "LABEL_A",
                activate = function()
                    fired = fired + 1
                end,
            }),
        },
    })
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
    setCtrls({ "A", "B" })
    ctrlState.A.disabled = true
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = buttonSpec({ "A", "B" }) })
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A, disabled")
end

-- Checkbox -------------------------------------------------------------

function M.test_checkbox_enter_toggles_and_announces_on()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "Foo", textKey = "LBL_FOO" }) },
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "Foo", textKey = "LBL_FOO" }) },
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({ controlName = "A", textKey = "LBL_A" }),
            BaseMenuItems.Checkbox({ controlName = "B", textKey = "LBL_B" }),
        },
    })
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
    registerCheckHandler(cb, function(v)
        received[#received + 1] = v
    end)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "Foo", textKey = "LBL" }) },
    })
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
    local label = Polyfill.makeLabel("50%")
    populateControls({ Sld = slider, Lbl = label })
    registerSliderCallback(slider, function(v)
        label:SetText(string.format("%d%%", math.floor(v * 100 + 0.5)))
    end)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL_SLD" }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.51)
    T.eq(speaks[1].text, "51%")
end

function M.test_slider_fires_captured_callback_on_adjust()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    local received = {}
    registerSliderCallback(slider, function(v, void1)
        received[#received + 1] = { v = v, void1 = void1 }
        label:SetText(string.format("%d", math.floor(v * 100 + 0.5)))
    end)
    slider:SetVoid1(42)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL" }),
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
    local label = Polyfill.makeLabel("0")
    populateControls({ Sld = slider, Lbl = label })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL" }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.51, "value still changes")
    T.truthy(#warns >= 1, "callback-missing warn logged")
end

function M.test_slider_left_decrements()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.50 })
    local label = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    slider:RegisterSliderCallback(function(v)
        label:SetText(tostring(math.floor(v * 100 + 0.5)))
    end)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL" }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 0.49)
end

function M.test_slider_shift_left_decrements_by_big_step()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL" }),
        },
    })
    HandlerStack.push(h)
    UI.ShiftKeyDown = function()
        return true
    end
    InputRouter.dispatch(Keys.VK_LEFT, 1, WM_KEYDOWN)
    T.truthy(math.abs(slider:GetValue() - 0.4) < 1e-6)
end

function M.test_slider_right_at_max_stays_clamped()
    setup()
    local slider = Polyfill.makeSlider({ value = 1.0 })
    local label = Polyfill.makeLabel("100")
    populateControls({ Sld = slider, Lbl = label })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL" }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(slider:GetValue(), 1.0)
end

-- Home/End belong to list nav even with sliders on the screen.
function M.test_home_with_slider_at_position_one_goes_to_first_item()
    setup()
    local cb = Polyfill.makeCheckBox()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label = Polyfill.makeLabel("50")
    populateControls({ CB = cb, Sld = slider, Lbl = label })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LBL_CB" }),
            BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL_SLD" }),
        },
    })
    HandlerStack.push(h)
    h._indices[1] = 2 -- on slider
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "Home navigated to first item, did not snap slider")
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

    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2, "sub pushed on top")
    T.eq(HandlerStack.active().name, "T/PD_PullDown")
    T.eq(sounds[1], "AS2D_IF_SELECT", "click sound on dropdown open")
    local heard = false
    for _, s in ipairs(speaks) do
        if s.text == "Easy" then
            heard = true
        end
    end
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LBL_CB" }),
            BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1)
    T.eq(h._indices[1], 2, "cursor stayed on the pulldown after sub pop")
end

function M.test_sub_pop_advances_cursor_off_hidden_item()
    setup()
    local pd = makePullDownWithMetatable()
    local cbAfter = Polyfill.makeCheckBox()
    populateControls({ PD = pd, After = cbAfter })
    patchProbeFromPullDown(pd)
    pd:RegisterSelectionCallback(function()
        pd:SetHide(true)
    end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Entry")
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }),
            BaseMenuItems.Checkbox({ controlName = "After", textKey = "LBL_AFTER" }),
        },
    })
    HandlerStack.push(h)
    T.eq(h._indices[1], 1, "starts on pulldown")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "cursor advanced off the now-hidden pulldown")
    T.truthy(#speaks >= 1, "re-activation announced the new current item")
end

-- Tooltip composition --------------------------------------------------

function M.test_tooltip_appended_after_label_value()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SHOW_MAP"] = "Show map"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SHOW_MAP_TT"] = "Toggles the map overlay"
    local cb = Polyfill.makeCheckBox({ checked = true })
    populateControls({ Foo = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({
                controlName = "Foo",
                textKey = "TXT_KEY_CIVVACCESS_TEST_SHOW_MAP",
                tooltipKey = "TXT_KEY_CIVVACCESS_TEST_SHOW_MAP_TT",
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Show map, on, Toggles the map overlay")
end

function M.test_tooltip_dedupes_against_label()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FS"] = "Fullscreen"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FS_TT"] = "Fullscreen. Some extra detail"
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ X = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({
                controlName = "X",
                textKey = "TXT_KEY_CIVVACCESS_TEST_FS",
                tooltipKey = "TXT_KEY_CIVVACCESS_TEST_FS_TT",
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "Fullscreen, off, Some extra detail", "duplicate 'Fullscreen' sentence dropped from tooltip")
end

function M.test_tooltipFn_appends_dynamic_tooltip()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local calls = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({
                controlName = "C",
                textKey = "LBL",
                tooltipFn = function()
                    calls = calls + 1
                    return "live tip"
                end,
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "LBL, off, live tip")
    T.truthy(calls >= 1)
end

function M.test_tooltipFn_error_is_logged_and_swallowed()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({
                controlName = "C",
                textKey = "LBL",
                tooltipFn = function()
                    error("boom")
                end,
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "LBL, off")
    T.truthy(#errors >= 1)
end

function M.test_tooltipFn_nil_result_does_not_add_comma()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "LABEL_A",
                tooltipFn = function()
                    return nil
                end,
                activate = function() end,
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A", "nil tooltipFn leaves announcement clean")
end

function M.test_slider_empty_label_falls_back_to_textKey()
    setup()
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_SLD"] = "Delay"
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label = Polyfill.makeLabel("")
    populateControls({ Sld = slider, Lbl = label })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Slider({
                controlName = "Sld",
                labelControlName = "Lbl",
                textKey = "TXT_KEY_CIVVACCESS_TEST_SLD",
            }),
        },
    })
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                showPanel = function()
                    shown = 1
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
            },
            {
                name = "TAB_B",
                showPanel = function()
                    shown = 2
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LB" }) },
            },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(shown, 2)
    T.eq(h._tabIndex, 2)
    T.eq(h._indices[1], 1)
    T.eq(speaks[1].text, "TAB_B")
end

function M.test_tabs_shift_tab_cycles_backward_wraps()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    local cbC = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB, CC = cbC })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            { name = "A", items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "L" }) } },
            { name = "B", items = { BaseMenuItems.Checkbox({ controlName = "CB", textKey = "L" }) } },
            { name = "C", items = { BaseMenuItems.Checkbox({ controlName = "CC", textKey = "L" }) } },
        },
    })
    HandlerStack.push(h)
    UI.ShiftKeyDown = function()
        return true
    end
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            { name = "TAB_A", items = { BaseMenuItems.Checkbox({ controlName = "Filler", textKey = "L" }) } },
            { name = "TAB_B", items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) } },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2)
    T.eq(h._indices[1], 1)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2, "tab preserved")
    T.eq(h._indices[1], 1, "item index preserved")
end

-- Install --------------------------------------------------------------

local function makeContextPtr()
    return {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
end

function M.test_install_push_on_show_pop_on_hide()
    setup()
    local a = Polyfill.makeCheckBox()
    populateControls({ A = a })
    local ctx = makeContextPtr()
    BaseMenu.install(
        ctx,
        { name = "T", displayName = "Screen", items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "L" }) } }
    )
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
    ctx._sh(true, false)
    T.eq(HandlerStack.count(), 0)
end

function M.test_install_double_show_keeps_stack_depth_at_one()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, { name = "S", displayName = "Screen", items = buttonSpec({ "A" }) })
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
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "L" }) },
        priorShowHide = function(bIsHide)
            priorArg = bIsHide
        end,
    })
    ctx._sh(false, false)
    T.eq(priorArg, false)
    T.eq(HandlerStack.count(), 1)
end

function M.test_install_prior_showhide_error_caught_push_still_happens()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "S",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        priorShowHide = function()
            error("prior boom")
        end,
    })
    ctx._sh(false, false)
    T.truthy(#errors >= 1, "prior error logged")
    T.eq(HandlerStack.count(), 1, "push not blocked by prior error")
end

function M.test_install_show_parks_focus_on_named_control()
    setup()
    local a = Polyfill.makeCheckBox()
    local eb = Polyfill.makeEditBox({ text = "" })
    local park = Polyfill.makeButton()
    populateControls({ A = a, E = eb, Cancel = park })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        focusParkControl = "Cancel",
        priorShowHide = function(bIsHide)
            if not bIsHide then
                eb:TakeFocus()
            end
        end,
        items = {
            BaseMenuItems.Textfield({ controlName = "E", textKey = "L" }),
            BaseMenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
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
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "L" }) },
        priorInput = function(msg, wp, lp)
            if wp == Keys.VK_ESCAPE then
                priorFired = priorFired + 1
            end
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
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "L" }) },
        priorInput = function(msg, wp, lp)
            if wp == Keys.VK_ESCAPE then
                priorFired = priorFired + 1
            end
            return true
        end,
    })
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
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    local priorFired = 0
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        priorInput = function()
            priorFired = priorFired + 1
            return true
        end,
    })
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
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
            BaseMenuItems.Checkbox({ controlName = "B", textKey = "LB" }),
        },
    })
    ctx._sh(false, false)
    local h = HandlerStack.active()
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2)
    ctx._sh(true, false)
    ctx._sh(false, false)
    T.eq(HandlerStack.active()._indices[1], 1, "cursor reset on reopen")
end

function M.test_tab_switch_reparks_focus_on_configured_control()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local ebB = Polyfill.makeEditBox({ text = "" })
    local park = Polyfill.makeButton()
    populateControls({ CA = cbA, EB = ebB, Park = park })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        focusParkControl = "Park",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "L" }) },
            },
            {
                name = "TAB_B",
                showPanel = function()
                    ebB:TakeFocus()
                end,
                items = { BaseMenuItems.Textfield({ controlName = "EB", textKey = "L" }) },
            },
        },
    })
    HandlerStack.push(h)
    park._hasFocus = nil
    ebB._hasFocus = nil
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(h._tabIndex, 2)
    T.eq(park._hasFocus, true, "park control focused after tab switch so arrow keys reach the form")
end

-- Preamble --------------------------------------------------------------

function M.test_preamble_string_queued_after_displayName()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "Are you sure?",
        items = buttonSpec({ "A" }),
    })
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
    setCtrls({ "A" })
    local calls = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            calls = calls + 1
            return "dynamic body"
        end,
        items = buttonSpec({ "A" }),
    })
    T.eq(calls, 0, "preamble fn not called at create time")
    HandlerStack.push(h)
    T.eq(calls, 1, "preamble fn called once at onActivate")
    T.eq(speaks[2].text, "dynamic body")
end

function M.test_preamble_function_returning_empty_is_skipped()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            return ""
        end,
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    T.eq(#speaks, 2, "empty preamble not spoken")
end

-- silentFirstOpen: fresh-show announces only displayName. Preamble and the
-- first item are not spoken; F1 / readHeader remains the opt-in path. For
-- screens that overlap with external narration (tutorial advisor voice
-- clips, civ leader intros on the load screen).
function M.test_silent_first_open_speaks_only_display_name()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A", "B" }),
        silentFirstOpen = true,
    })
    HandlerStack.push(h)
    T.eq(#speaks, 1, "only displayName spoken on fresh show")
    T.eq(speaks[1].text, "Screen")
    T.eq(speaks[1].interrupt, true)
end

function M.test_silent_first_open_still_initializes_cursor()
    setup()
    setCtrls({ "A", "B", "C" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A", "B", "C" }),
        silentFirstOpen = true,
    })
    HandlerStack.push(h)
    T.eq(h._level, 1, "level initialized")
    T.eq(h._indices[1], 1, "cursor on first navigable item")
    T.eq(h._initialized, true, "flagged initialized")
end

function M.test_silent_first_open_readHeader_speaks_preamble()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A" }),
        silentFirstOpen = true,
    })
    HandlerStack.push(h)
    -- Reset pipeline state so the displayName speakInterrupt from the
    -- push doesn't dedupe the one readHeader is about to fire.
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    speaks = {}
    h.readHeader()
    T.eq(#speaks, 2, "readHeader speaks displayName + preamble")
    T.eq(speaks[1].text, "Screen")
    T.eq(speaks[2].text, "body text")
end

function M.test_silent_first_open_rejects_non_boolean()
    setup()
    setCtrls({ "A" })
    local ok, err = pcall(function()
        BaseMenu.create({
            name = "T",
            displayName = "Screen",
            items = buttonSpec({ "A" }),
            silentFirstOpen = "yes",
        })
    end)
    T.truthy(not ok, "non-boolean rejected")
    T.truthy(tostring(err):find("silentFirstOpen"), "error mentions the field")
end

function M.test_refresh_respeaks_when_function_preamble_changes()
    setup()
    setCtrls({ "A" })
    local body = "first"
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            return body
        end,
        items = buttonSpec({ "A" }),
    })
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
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            return "same"
        end,
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0)
end

function M.test_refresh_noop_when_preamble_is_string()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "static body",
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0, "string preamble never re-speaks")
end

function M.test_refresh_fn_error_logged_no_crash()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            error("boom")
        end,
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.truthy(#errors >= 1, "preamble fn error logged")
    T.eq(#speaks, 0)
end

-- F1 / readHeader ------------------------------------------------------

function M.test_f1_speaks_displayName_then_preamble()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "intro body",
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    speaks = {}
    SpeechPipeline._reset()
    InputRouter.dispatch(Keys.VK_F1, 0, WM_KEYDOWN)
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "Screen")
    T.truthy(speaks[1].interrupt)
    T.eq(speaks[2].text, "intro body")
    T.falsy(speaks[2].interrupt)
end

function M.test_f1_with_no_preamble_speaks_displayName_only()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = buttonSpec({ "A" }) })
    HandlerStack.push(h)
    speaks = {}
    SpeechPipeline._reset()
    InputRouter.dispatch(Keys.VK_F1, 0, WM_KEYDOWN)
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "Screen")
end

function M.test_f1_resolves_function_preamble_live()
    setup()
    setCtrls({ "A" })
    local body = "first"
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            return body
        end,
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    body = "second"
    speaks = {}
    SpeechPipeline._reset()
    InputRouter.dispatch(Keys.VK_F1, 0, WM_KEYDOWN)
    T.eq(speaks[2].text, "second", "F1 re-resolves the function preamble")
end

function M.test_f1_syncs_lastPreambleText_so_refresh_is_noop()
    setup()
    setCtrls({ "A" })
    local body = "first"
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = function()
            return body
        end,
        items = buttonSpec({ "A" }),
    })
    HandlerStack.push(h)
    body = "second"
    SpeechPipeline._reset()
    InputRouter.dispatch(Keys.VK_F1, 0, WM_KEYDOWN)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0, "refresh after F1 sees no change vs last spoken value")
end

-- Empty items -----------------------------------------------------------

function M.test_empty_items_onActivate_speaks_displayName_only()
    setup()
    populateControls({})
    local h = BaseMenu.create({ name = "S", displayName = "Splash", items = {} })
    HandlerStack.push(h)
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "Splash")
end

function M.test_empty_items_onEnter_is_safe_noop()
    setup()
    populateControls({})
    local h = BaseMenu.create({ name = "S", displayName = "Splash", items = {} })
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
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        shouldActivate = function()
            return false
        end,
    })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 0, "push skipped")
    T.eq(#speaks, 0, "no speech")
end

function M.test_shouldActivate_true_pushes()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        shouldActivate = function()
            return true
        end,
    })
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
end

-- deferActivate ---------------------------------------------------------

function M.test_deferActivate_delays_push_to_update_tick()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "D",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        deferActivate = true,
    })
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
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "D",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        deferActivate = true,
    })
    ctx._sh(false, false)
    ctx._sh(true, false)
    TickPump.tick()
    T.eq(HandlerStack.count(), 0, "no push after cancel")
    T.eq(#speaks, 0)
end

function M.test_deferActivate_hidden_at_tick_skips_push()
    setup()
    setCtrls({ "A" })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "D",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        deferActivate = true,
    })
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "FIRST" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    h.setItems({
        BaseMenuItems.Checkbox({ control = a, labelText = "A2" }),
        BaseMenuItems.Checkbox({ control = b, labelText = "B2" }),
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            { name = "TAB_A", items = { BaseMenuItems.Checkbox({ controlName = "A", textKey = "LA" }) } },
            { name = "TAB_B", items = { BaseMenuItems.Checkbox({ controlName = "B", textKey = "LB" }) } },
        },
    })
    HandlerStack.push(h)
    h.setItems({
        BaseMenuItems.Checkbox({ control = b, labelText = "B-NEW-1" }),
        BaseMenuItems.Checkbox({ control = b, labelText = "B-NEW-2" }),
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Checkbox({ controlName = "A", textKey = "LA" }),
            BaseMenuItems.Checkbox({ controlName = "B", textKey = "LB" }),
            BaseMenuItems.Checkbox({ controlName = "C", textKey = "LC" }),
        },
    })
    HandlerStack.push(h)
    h._indices[1] = 3
    h.setItems({ BaseMenuItems.Checkbox({ control = a, labelText = "A" }) })
    T.eq(h._indices[1], 1, "cursor clamped to first valid item after shrink")
end

-- Dynamic-item features --------------------------------------------------

function M.test_labelText_overrides_textKey_lookup()
    setup()
    local cb = Polyfill.makeCheckBox()
    populateControls({ C = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "C", labelText = "PreLocalized Option" }) },
    })
    HandlerStack.push(h)
    T.eq(speaks[2].text, "PreLocalized Option, off", "labelText used verbatim")
end

function M.test_control_ref_bypasses_controlName_lookup()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = true })
    Controls = {}
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ control = cb, textKey = "DIRECT" }) },
    })
    HandlerStack.push(h)
    T.eq(#warns, 0, "no missing-control warnings")
    T.eq(speaks[2].text, "DIRECT, on")
end

-- capturesAllInput barrier ----------------------------------------------

function M.test_capturesAllInput_blocks_lower_handlers()
    setup()
    setCtrls({ "A" })
    local lowerFired = 0
    HandlerStack.push({
        name = "lower",
        capturesAllInput = false,
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    lowerFired = lowerFired + 1
                end,
            },
        },
    })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = buttonSpec({ "A" }) })
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local top = HandlerStack.active()
    T.truthy(top._editMode, "edit-mode sub is on top of stack")
    T.eq(top.name, "T/E_Edit")
    T.eq(top.capturesAllInput, false, "capturesAllInput off so unbound keys fall through to EditBox")
    T.eq(eb:GetText(), "", "editbox cleared")
    TickPump.tick()
    T.eq(eb._hasFocus, true, "engine focus taken for typing on next tick")
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "editing LBL" then
            found = true
        end
    end
    T.truthy(found, "editing announcement fired")
end

function M.test_escape_during_edit_restores_and_pops()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    local park = Polyfill.makeButton()
    populateControls({ E = eb, Park = park })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        focusParkControl = "Park",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
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
        if s.text == "LBL restored" then
            foundRestored = true
        end
    end
    T.truthy(foundRestored, "restored announcement fired")
end

function M.test_enter_during_edit_commits_without_restoring()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL", priorCallback = prior }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("committed")
    received = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#received, 1, "priorCallback fired exactly once on commit")
    T.eq(received[1].text, "committed")
    T.eq(received[1].control, eb)
    T.eq(received[1].bIsEnter, true, "bIsEnter=true so priorCallback mimics native Enter-triggered call")
end

function M.test_commit_announces_committed_value()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("new value")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "new value", "commit speaks the just-saved value")
end

function M.test_commit_on_empty_announces_blank()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "blank", "empty commit speaks the blank sentinel")
end

function M.test_commit_without_priorCallback_is_safe()
    setup()
    local eb = Polyfill.makeEditBox({ text = "old" })
    populateControls({ E = eb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
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
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Textfield({
                controlName = "E",
                textKey = "LBL",
                priorCallback = function()
                    fired = fired + 1
                end,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("partial")
    fired = 0
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(fired, 0, "restore path must NOT fire priorCallback; never committed this text")
    T.eq(eb:GetText(), "original")
end

function M.test_edit_submenu_has_no_arrow_bindings()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local editSub = HandlerStack.active()
    for _, b in ipairs(editSub.bindings) do
        T.truthy(
            b.key ~= Keys.VK_UP and b.key ~= Keys.VK_DOWN and b.key ~= Keys.VK_LEFT and b.key ~= Keys.VK_RIGHT,
            "edit-mode bindings must not intercept arrow keys"
        )
    end
end

function M.test_reenter_edit_installs_fresh_wrapping_callback()
    setup()
    local eb = Polyfill.makeEditBox({ text = "first" })
    populateControls({ E = eb })
    local priorCalls = 0
    local function prior()
        priorCalls = priorCalls + 1
    end
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL", priorCallback = prior }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- enter edit
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- commit (reinstates prior)
    T.eq(eb._cb, prior, "prior reinstated on exit")
    priorCalls = 0
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- re-enter edit
    T.truthy(eb._cb ~= prior, "new wrapping callback installed")
    eb._cb("x", eb, false)
    T.eq(priorCalls, 1, "re-entered wrapper still chains to prior")
end

function M.test_edit_mode_enter_keyup_is_claimed()
    setup()
    local eb = Polyfill.makeEditBox({ text = "x" })
    populateControls({ E = eb })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
    ctx._sh(false, false)
    ctx._in(WM_KEYDOWN, Keys.VK_RETURN, 0) -- enter edit
    -- Enter KEYUP (msg 257) while in edit mode should be claimed so the
    -- engine's Enter-release doesn't revoke focus.
    local consumed = ctx._in(257, Keys.VK_RETURN, 0)
    T.truthy(consumed, "KEYUP claimed during edit mode")
end

-- Nested menus ---------------------------------------------------------
--
-- Groups drill via Right / Enter; Left / Esc at level > 1 go back up a level.
-- Up/Down at level > 1 cross into sibling groups on past-end. Ctrl+Up/Down
-- jumps to prev/next group at the current level's parent.

local MOD_CTRL = 2

local function buttonItem(name, label)
    return BaseMenuItems.Button({
        controlName = name,
        textKey = label or ("LBL_" .. name),
        activate = function() end,
    })
end

local function groupItem(label, children)
    return BaseMenuItems.Group({
        labelText = label,
        items = children,
    })
end

function M.test_group_drill_on_enter_enters_first_child()
    setup()
    setCtrls({ "A", "GCHILD1", "GCHILD2" })
    local child1 = buttonItem("GCHILD1", "Child One")
    local child2 = buttonItem("GCHILD2", "Child Two")
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("A", "Leaf A"),
            groupItem("Group One", { child1, child2 }),
        },
    })
    HandlerStack.push(h)
    -- Move to the group and Enter.
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._level, 2, "drilled to level 2")
    T.eq(h._indices[2], 1, "cursor on first child")
    T.eq(speaks[1].text, "Child One")
end

function M.test_group_drill_on_right()
    setup()
    setCtrls({ "GCHILD1" })
    local child = buttonItem("GCHILD1", "Only Child")
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupItem("Group", { child }) } })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(h._level, 2)
    T.eq(speaks[1].text, "Only Child")
end

function M.test_left_at_level_2_goes_back()
    setup()
    setCtrls({ "CHILD" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { groupItem("Parent", { buttonItem("CHILD", "Child") }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    T.eq(h._level, 2)
    speaks = {}
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(h._level, 1, "left at level 2 returns to 1")
    T.eq(speaks[1].text, "Parent", "re-announces the group on back")
end

function M.test_esc_at_level_2_goes_back_via_install_handler()
    setup()
    setCtrls({ "CHILD" })
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
    local handler = BaseMenu.install(
        ctx,
        { name = "T", displayName = "Screen", items = { groupItem("Parent", { buttonItem("CHILD", "Child") }) } }
    )
    ctx._sh(false, false)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(handler._level, 2)
    speaks = {}
    local consumed = ctx._in(256, Keys.VK_ESCAPE, 0)
    T.truthy(consumed, "Esc consumed at level > 1")
    T.eq(handler._level, 1, "Esc went up a level")
end

function M.test_esc_at_level_1_bypasses_to_priorInput()
    setup()
    setCtrls({ "A" })
    local bypassed = false
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        priorInput = function()
            bypassed = true
            return true
        end,
        items = { buttonItem("A", "Leaf") },
    })
    ctx._sh(false, false)
    ctx._in(256, Keys.VK_ESCAPE, 0)
    T.truthy(bypassed, "Esc at level 1 delegated to priorInput")
end

function M.test_down_at_level_2_past_last_wraps_to_next_group_first_child()
    setup()
    setCtrls({ "A", "B", "C", "D" })
    local groupA = groupItem("Group A", { buttonItem("A", "A1"), buttonItem("B", "A2") })
    local groupB = groupItem("Group B", { buttonItem("C", "B1"), buttonItem("D", "B2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into A
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- step within A
    T.eq(h._indices[2], 2)
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- past last -> cross to B
    T.eq(h._indices[1], 2, "parent advanced to Group B")
    T.eq(h._indices[2], 1, "cursor on first child of B")
    T.eq(speaks[1].text, "Group B", "parent context announced")
    T.eq(speaks[2].text, "B1", "first child queued after parent")
end

function M.test_up_at_level_2_past_first_wraps_to_prev_group_last_child()
    setup()
    setCtrls({ "A", "B", "C", "D" })
    local groupA = groupItem("Group A", { buttonItem("A", "A1"), buttonItem("B", "A2") })
    local groupB = groupItem("Group B", { buttonItem("C", "B1"), buttonItem("D", "B2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- on Group B
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into B
    T.eq(h._indices[2], 1)
    speaks = {}
    InputRouter.dispatch(Keys.VK_UP, 0, WM_KEYDOWN) -- past first -> cross to A
    T.eq(h._indices[1], 1, "parent moved back to Group A")
    T.eq(h._indices[2], 2, "cursor on last child of A")
    T.eq(speaks[1].text, "Group A")
    T.eq(speaks[2].text, "A2")
end

function M.test_cross_parent_skips_leaves_at_parent_level()
    setup()
    setCtrls({ "LEAF1", "A1", "A2", "LEAF2", "B1" })
    local groupA = groupItem("A", { buttonItem("A1"), buttonItem("A2") })
    local groupB = groupItem("B", { buttonItem("B1") })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("LEAF1", "Leaf1"),
            groupA,
            buttonItem("LEAF2", "Leaf2"),
            groupB,
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- on Group A
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- A2
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- past end -> skip Leaf2 -> B
    T.eq(h._indices[1], 4, "jumped across Leaf2 to Group B")
    T.eq(h._indices[2], 1)
    T.eq(speaks[1].text, "B")
end

function M.test_home_at_level_2_stays_within_group()
    setup()
    setCtrls({ "A1", "A2", "B1" })
    local groupA = groupItem("A", { buttonItem("A1"), buttonItem("A2") })
    local groupB = groupItem("B", { buttonItem("B1") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill into A
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- A2
    InputRouter.dispatch(Keys.VK_HOME, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "still in group A")
    T.eq(h._indices[2], 1, "on first child of A")
end

function M.test_ctrl_down_at_level_1_jumps_across_leaves_to_next_group()
    setup()
    setCtrls({ "LEAF", "G1C", "G2C" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("LEAF", "Leaf"),
            groupItem("Group 1", { buttonItem("G1C", "C1") }),
            groupItem("Group 2", { buttonItem("G2C", "C2") }),
        },
    })
    HandlerStack.push(h)
    UI.CtrlKeyDown = function()
        return true
    end
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, MOD_CTRL, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "skipped Leaf, landed on Group 1")
    T.eq(speaks[1].text, "Group 1")
    InputRouter.dispatch(Keys.VK_DOWN, MOD_CTRL, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "advanced to Group 2")
end

function M.test_ctrl_up_at_level_2_jumps_to_prev_group_first_child()
    setup()
    setCtrls({ "A1", "B1", "B2" })
    local groupA = groupItem("A", { buttonItem("A1") })
    local groupB = groupItem("B", { buttonItem("B1"), buttonItem("B2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { groupA, groupB } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- on Group B
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill B
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- B2
    UI.CtrlKeyDown = function()
        return true
    end
    speaks = {}
    InputRouter.dispatch(Keys.VK_UP, MOD_CTRL, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "parent moved to Group A")
    T.eq(h._indices[2], 1, "landed on first child of A")
    T.eq(speaks[1].text, "A")
end

function M.test_empty_group_drill_is_noop_and_reannounces_label()
    setup()
    setCtrls({})
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Group({ labelText = "Empty", items = {} }) },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(h._level, 1, "drill into empty group does not change level")
    T.eq(speaks[1].text, "Empty")
end

function M.test_group_itemsFn_is_called_lazily_and_cached()
    setup()
    setCtrls({ "C" })
    local calls = 0
    local group = BaseMenuItems.Group({
        labelText = "Lazy",
        itemsFn = function()
            calls = calls + 1
            return { buttonItem("C", "Child") }
        end,
    })
    T.eq(calls, 0, "not called at spec time")
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { group } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    T.eq(calls, 1)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN) -- back
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill again
    T.eq(calls, 1, "children cached after first drill")
end

function M.test_pulldown_fallback_fires_per_entry_button_callback()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    -- Shared metatable so the button probe's patch covers every entry
    -- button built for this pulldown.
    local btnProto = Polyfill.makeButton()
    local btnMt = {
        __index = {
            SetText = btnProto.SetText,
            GetText = btnProto.GetText,
            SetVoid1 = btnProto.SetVoid1,
            GetVoid1 = btnProto.GetVoid1,
            IsHidden = btnProto.IsHidden,
            IsDisabled = btnProto.IsDisabled,
            SetHide = btnProto.SetHide,
            SetDisabled = btnProto.SetDisabled,
            RegisterCallback = btnProto.RegisterCallback,
        },
    }
    -- Pre-build instances with buttons that share the metatable, then
    -- register the probe from the first of those buttons before any
    -- per-button RegisterCallback calls.
    local inst1 = { Button = Polyfill.makeButtonWithMetatable(btnMt) }
    local inst2 = { Button = Polyfill.makeButtonWithMetatable(btnMt) }
    PullDownProbe.ensureButtonInstalled(inst1.Button)
    pd:ClearEntries()
    pd:BuildEntry("InstanceOne", inst1)
    pd:BuildEntry("InstanceOne", inst2)
    inst1.Button:SetText("Temperate")
    inst2.Button:SetText("Cool")
    -- No top-level RegisterSelectionCallback: per-entry click callbacks
    -- only. Mirrors the map-script option dropdown pattern.
    local fired = {}
    inst1.Button:RegisterCallback(Mouse.eLClick, function()
        fired[#fired + 1] = "t"
    end)
    inst2.Button:RegisterCallback(Mouse.eLClick, function()
        fired[#fired + 1] = "c"
    end)

    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- drill into sub
    T.eq(HandlerStack.count(), 2, "sub pushed via per-entry fallback")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- commit second entry
    T.eq(#fired, 1)
    T.eq(fired[1], "c", "second entry's per-button callback fired")
    T.eq(HandlerStack.count(), 1, "sub popped after commit")
end

function M.test_pulldown_inner_button_disabled_marks_inactivatable()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:RegisterSelectionCallback(function() end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Only Option")
    -- Base code pattern: disable the pulldown's inner button, not the
    -- pulldown userdata itself (e.g., map-size-locked maps).
    pd:GetButton():SetDisabled(true)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    local item = h._items[1]
    T.falsy(item:isActivatable(), "inner button disabled blocks activation")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub not pushed when button disabled")
    -- Announcement should carry the disabled suffix.
    local found = false
    for _, s in ipairs(speaks) do
        if s.text and s.text:find("disabled") then
            found = true
        end
    end
    T.truthy(found, "disabled suffix announced")
end

function M.test_pulldown_entry_announce_fn_replaces_entry_text()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    pd:RegisterSelectionCallback(function() end)
    local i1, i2 = {}, {}
    pd:BuildEntry("InstanceOne", i1)
    pd:BuildEntry("InstanceOne", i2)
    i1.Button:SetText("Plain A")
    i2.Button:SetText("Plain B")
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Pulldown({
                controlName = "PD",
                textKey = "LBL_PD",
                entryAnnounceFn = function(inst, idx)
                    return "rich " .. idx
                end,
            }),
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN) -- drill
    local richHeard = {}
    for _, s in ipairs(speaks) do
        richHeard[s.text] = true
    end
    T.truthy(richHeard["rich 1"], "override used for first entry announce")
    -- Move to second entry and confirm its override announce too.
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[#speaks].text, "rich 2")
end

function M.test_pulldown_no_callback_at_all_logs_warn()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("Lonely")
    -- Neither top-level callback nor per-button click callback registered.
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    warns = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub not pushed with no callback")
    T.truthy(#warns >= 1, "warn logged")
end

function M.test_group_cached_false_rebuilds_on_every_drill()
    setup()
    setCtrls({ "C" })
    local calls = 0
    local group = BaseMenuItems.Group({
        labelText = "Dynamic",
        cached = false,
        itemsFn = function()
            calls = calls + 1
            return { buttonItem("C", "Child") }
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { group } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.truthy(calls >= 2, "itemsFn re-runs on second drill with cached=false")
end

function M.test_hidden_group_is_skipped_in_navigation()
    setup()
    setCtrls({ "HIDE_BOX", "A", "C" })
    ctrlState.HIDE_BOX.hidden = true
    local hiddenGroup = BaseMenuItems.Group({
        labelText = "HiddenGroup",
        visibilityControlName = "HIDE_BOX",
        items = { buttonItem("A") },
    })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            buttonItem("C", "Leaf"),
            hiddenGroup,
        },
    })
    HandlerStack.push(h)
    -- Only one navigable item at top level: Leaf.
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 1, "hidden group skipped in wrap")
end

function M.test_single_sibling_group_wraps_circularly_within_itself()
    setup()
    setCtrls({ "A1", "A2" })
    local only = groupItem("Solo", { buttonItem("A1", "A1"), buttonItem("A2", "A2") })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { only } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- A2
    speaks = {}
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN) -- past end, only 1 group -> wrap self
    T.eq(h._indices[1], 1, "still same parent")
    T.eq(h._indices[2], 1, "wrapped to first child")
    T.eq(speaks[1].text, "A1")
end

function M.test_slider_at_level_2_left_right_adjusts_not_back()
    setup()
    local slider = Polyfill.makeSlider({ value = 0.5 })
    local label = Polyfill.makeLabel("50")
    populateControls({ Sld = slider, Lbl = label })
    slider:RegisterSliderCallback(function(v)
        label:SetText(tostring(math.floor(v * 100 + 0.5)))
    end)
    local group = groupItem("Options", {
        BaseMenuItems.Slider({ controlName = "Sld", labelControlName = "Lbl", textKey = "LBL_S" }),
    })
    local h = BaseMenu.create({ name = "T", displayName = "Screen", items = { group } })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- drill
    T.eq(h._level, 2)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN) -- slider adjust, NOT back
    T.eq(h._level, 2, "still at level 2: right adjusted the slider")
    T.eq(slider:GetValue(), 0.51)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN) -- slider decrement
    T.eq(h._level, 2, "still at level 2: left adjusted the slider")
    T.eq(slider:GetValue(), 0.50)
end

function M.test_level_reset_on_hide_then_reopen()
    setup()
    setCtrls({ "CHILD" })
    local ctx = {
        SetShowHideHandler = function(self, fn)
            self._sh = fn
        end,
        SetInputHandler = function(self, fn)
            self._in = fn
        end,
        _hidden = false,
        IsHidden = function(self)
            return self._hidden
        end,
        SetUpdate = function(self, fn)
            self._update = fn
        end,
    }
    local handler = BaseMenu.install(
        ctx,
        { name = "T", displayName = "Screen", items = { groupItem("P", { buttonItem("CHILD", "C") }) } }
    )
    ctx._sh(false, false)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(handler._level, 2)
    ctx._sh(true, false)
    ctx._sh(false, false)
    T.eq(handler._level, 1, "level reset to 1 on reopen")
end

-- Type-ahead search ------------------------------------------------------

local function installForSearch(labelledItems)
    local ctx = makeContextPtr()
    local names = {}
    for _, it in ipairs(labelledItems) do
        names[#names + 1] = it.name
    end
    setCtrls(names)
    local specItems = {}
    for _, it in ipairs(labelledItems) do
        specItems[#specItems + 1] = BaseMenuItems.Button({
            controlName = it.name,
            labelText = it.label,
            activate = function() end,
        })
    end
    local handler = BaseMenu.install(ctx, { name = "T", displayName = "Screen", items = specItems })
    ctx._sh(false, false)
    return ctx, handler
end

local function keydown(ctx, vk)
    return ctx._in(WM_KEYDOWN, vk, 0)
end
local function vkLetter(c)
    return string.byte(string.upper(c))
end

function M.test_search_letter_moves_to_first_match()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
        { name = "C", label = "Cherry" },
    })
    speaks = {}
    T.truthy(keydown(ctx, vkLetter("b")), "letter consumed by search")
    T.eq(h._indices[1], 2, "cursor moved to Banana")
    T.truthy(h._search:isSearchActive())
end

function M.test_search_no_match_speaks_and_stays_active()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
    })
    speaks = {}
    keydown(ctx, vkLetter("z"))
    T.truthy(h._search:isSearchActive())
    local saw = false
    for _, s in ipairs(speaks) do
        if s.text == "no match for z" then
            saw = true
            break
        end
    end
    T.truthy(saw, "no-match announcement fired")
end

function M.test_search_escape_clears_instead_of_going_back()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Banana" },
    })
    keydown(ctx, vkLetter("a"))
    T.truthy(h._search:isSearchActive())
    speaks = {}
    keydown(ctx, Keys.VK_ESCAPE)
    T.falsy(h._search:isSearchActive(), "Escape cleared search")
    T.eq(h._level, 1, "Escape did not change level")
    T.eq(speaks[1] and speaks[1].text, "search cleared")
end

function M.test_search_down_navigates_results_not_items()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
        { name = "B", label = "Apricot" },
        { name = "C", label = "Banana" },
    })
    keydown(ctx, vkLetter("a"))
    T.eq(h._indices[1], 1, "first result: Apple")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "Down within results: Apricot")
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 3, "Down again: Banana (substring match)")
end

function M.test_search_backspace_to_empty_clears()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
    })
    keydown(ctx, vkLetter("a"))
    T.truthy(h._search:isSearchActive())
    keydown(ctx, Keys.VK_BACK)
    T.falsy(h._search:isSearchActive(), "backspace-to-empty clears search")
end

function M.test_search_enter_activates_current_result()
    setup()
    local ctx = makeContextPtr()
    setCtrls({ "A", "B" })
    local fired = 0
    BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                labelText = "Apple",
                activate = function() end,
            }),
            BaseMenuItems.Button({
                controlName = "B",
                labelText = "Banana",
                activate = function()
                    fired = fired + 1
                end,
            }),
        },
    })
    ctx._sh(false, false)
    keydown(ctx, vkLetter("b"))
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 1, "Enter activates the search-selected item")
end

function M.test_search_clears_on_drill()
    setup()
    setCtrls({ "CHILD" })
    local ctx = makeContextPtr()
    local handler = BaseMenu.install(ctx, {
        name = "T",
        displayName = "Screen",
        items = {
            groupItem("PARENT", {
                BaseMenuItems.Button({
                    controlName = "CHILD",
                    labelText = "Apple",
                    activate = function() end,
                }),
            }),
        },
    })
    ctx._sh(false, false)
    keydown(ctx, vkLetter("p"))
    T.truthy(handler._search:isSearchActive())
    -- Right drills into the group (search was matching parent-level labels).
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(handler._level, 2)
    T.falsy(handler._search:isSearchActive(), "search cleared on drill")
end

function M.test_search_ignored_when_ctrl_held()
    setup()
    local ctx, h = installForSearch({
        { name = "A", label = "Apple" },
    })
    UI.CtrlKeyDown = function()
        return true
    end
    keydown(ctx, vkLetter("a"))
    -- The modal capturesAllInput barrier still absorbs Ctrl+A, but the
    -- critical guarantee is that it did not feed the search buffer.
    T.falsy(h._search:isSearchActive(), "Ctrl+A must not start a type-ahead search")
end

-- Choice.selectedFn: browse-then-commit screens (ScenariosMenu, CustomMod,
-- LoadTutorial) need the announce to include "selected" for the row that
-- the screen's own selection state currently points at, and need activate
-- to re-announce so the user gets audio confirmation when they commit
-- (Enter on a Choice without selectedFn would rely on the screen's close
-- path to speak, which browse screens don't trigger -- they just flip a
-- flag and wait for Start).
function M.test_choice_selectedfn_prepends_selected_and_reannounces()
    setup()
    populateControls({})
    local currentSelection = nil
    local choiceA = BaseMenuItems.Choice({
        labelText = "Apple",
        selectedFn = function()
            return currentSelection == "A"
        end,
        activate = function()
            currentSelection = "A"
        end,
    })
    local choiceB = BaseMenuItems.Choice({
        labelText = "Banana",
        selectedFn = function()
            return currentSelection == "B"
        end,
        activate = function()
            currentSelection = "B"
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choiceA, choiceB } })
    HandlerStack.push(h)

    -- Nothing selected yet: neither announce prepends "selected".
    T.eq(choiceA:announce(h), "Apple")
    T.eq(choiceB:announce(h), "Banana")

    -- Activate A; the activate fires, currentSelection flips, and the
    -- item re-announces through speakInterrupt so the user hears
    -- "selected, Apple" without having to arrow away and back.
    speaks = {}
    choiceA:activate(h)
    T.eq(currentSelection, "A", "activate ran user fn")
    local reannounce = speaks[#speaks]
    T.truthy(reannounce ~= nil, "activate re-announces")
    T.eq(reannounce.text, "selected, Apple")
    T.eq(reannounce.interrupt, true)

    -- B still announces plain (it's not the selection target anymore).
    T.eq(choiceB:announce(h), "Banana")
    -- A now announces with the prefix on subsequent nav too.
    T.eq(choiceA:announce(h), "selected, Apple")
end

function M.test_choice_without_selectedfn_does_not_reannounce()
    setup()
    populateControls({})
    local fired = false
    local choice = BaseMenuItems.Choice({
        labelText = "Apple",
        activate = function()
            fired = true
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choice } })
    HandlerStack.push(h)

    speaks = {}
    choice:activate(h)
    T.eq(fired, true)
    -- Without selectedFn we skip the re-announce entirely (the caller
    -- opted into the browse-then-commit pattern only by supplying one).
    T.eq(#speaks, 0, "no re-announce without selectedFn")
    T.eq(choice:announce(h), "Apple", "no 'selected' prefix without selectedFn")
end

-- Pulldown sub-menus precompute per-entry "this matches the committed
-- value" at activate time and pass it into buildChoice. The entry whose
-- button text equals the pulldown's current value announces with the
-- "selected" prefix so the user can identify the committed pick while
-- browsing the sub. Non-matching entries stay unprefixed.
function M.test_pulldown_sub_entry_announces_selected_for_current_value()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    pd:RegisterSelectionCallback(function() end)
    local inst1 = {}
    pd:BuildEntry("InstanceOne", inst1)
    inst1.Button:SetText("Easy")
    local inst2 = {}
    pd:BuildEntry("InstanceOne", inst2)
    inst2.Button:SetText("Hard")
    -- Parent pulldown's committed value is "Hard".
    pd:GetButton():SetText("Hard")

    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)

    local sub = HandlerStack.active()
    T.eq(sub.name, "T/PD_PullDown")
    T.eq(sub._items[1]:announce(sub), "Easy", "non-matching entry has no 'selected' prefix")
    T.eq(sub._items[2]:announce(sub), "selected, Hard", "matching entry announces with 'selected' prefix")
end

function M.test_choice_selectedfn_skips_reannounce_when_activate_pops_handler()
    setup()
    populateControls({})
    -- Simulates a Select*-style screen: activate commits then closes the
    -- screen (HandlerStack.pop). The parent's own onActivate will speak;
    -- our re-announce would race against that and produce a stutter.
    local choice
    choice = BaseMenuItems.Choice({
        labelText = "Apple",
        selectedFn = function()
            return true
        end,
        activate = function()
            HandlerStack.pop()
        end,
    })
    local parent = BaseMenu.create({
        name = "PARENT",
        displayName = "Parent",
        items = { BaseMenuItems.Button({ controlName = "X", textKey = "X", activate = function() end }) },
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choice } })
    setCtrls({ "X" })
    HandlerStack.push(parent)
    HandlerStack.push(h)

    speaks = {}
    choice:activate(h)
    -- HandlerStack.pop reactivates parent which speaks its own content.
    -- The critical invariant is that no "selected, Apple" entry appears
    -- after that -- the child's re-announce was suppressed.
    for _, s in ipairs(speaks) do
        T.truthy(s.text ~= "selected, Apple", "suppressed re-announce after handler pop")
    end
end

-- Per-tab hook overrides ------------------------------------------------

function M.test_tab_nameFn_overrides_tab_name_on_switch()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB })
    local dynamic = "first call"
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
            },
            {
                name = "TAB_B",
                nameFn = function()
                    return dynamic
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LB" }) },
            },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "first call", "nameFn result replaces tab.name on switch")
    -- Switch away + back; nameFn re-runs and picks up the new value.
    dynamic = "second call"
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "second call", "nameFn re-evaluated on every switch")
end

function M.test_tab_nameFn_empty_result_skips_tab_name_announcement()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
            },
            {
                name = "TAB_B",
                nameFn = function()
                    return ""
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CB", labelText = "item B" }) },
            },
        },
    })
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    -- Empty nameFn means the tab-name announcement is skipped; the item
    -- announcement still fires (as interrupt, since nothing preceded it).
    for _, s in ipairs(speaks) do
        T.truthy(s.text ~= "TAB_B", "TAB_B literal never spoken when nameFn returns empty")
    end
    local sawItem = false
    for _, s in ipairs(speaks) do
        if tostring(s.text):find("item B", 1, true) then
            sawItem = true
            break
        end
    end
    T.truthy(sawItem, "first item still announced after empty nameFn")
end

function M.test_tab_buildSearchable_override_replaces_default_corpus()
    setup()
    local cbA = Polyfill.makeCheckBox()
    populateControls({ CA = cbA })
    -- Picker tab items are simple; we want to verify the search corpus
    -- comes from the tab hook, not from the tab's own items. If the
    -- override is honored, typing "xyzzy" routes through overrideMoveTo
    -- rather than matching any tab item.
    local overrideCalls = 0
    local overrideLabels = { "xyzzy-match" }
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
                buildSearchable = function(handler)
                    return {
                        itemCount = function()
                            return #overrideLabels
                        end,
                        getLabel = function(i)
                            return overrideLabels[i]
                        end,
                        moveTo = function(i)
                            overrideCalls = overrideCalls + 1
                            -- Simulate the multi-level cursor teleport the
                            -- real consumer (Civilopedia) will do.
                            handler._level = 1
                            handler._indices = { 1 }
                        end,
                    }
                end,
            },
        },
    })
    HandlerStack.push(h)
    -- Type 'x' 'y' 'z' 'z' 'y'. Each letter feeds search. Override's moveTo
    -- should fire on every successful match.
    for _, c in ipairs({ 0x58, 0x59, 0x5A, 0x5A, 0x59 }) do
        InputRouter.dispatch(c, 0, WM_KEYDOWN)
    end
    T.truthy(overrideCalls >= 1, "override moveTo fired at least once")
end

function M.test_tab_buildSearchable_override_receives_handler()
    setup()
    populateControls({ CA = Polyfill.makeCheckBox() })
    local seenHandler
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
                buildSearchable = function(handler)
                    seenHandler = handler
                    return {
                        itemCount = function()
                            return 0
                        end,
                        getLabel = function()
                            return nil
                        end,
                        moveTo = function() end,
                    }
                end,
            },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(0x41, 0, WM_KEYDOWN) -- 'a'
    T.eq(seenHandler, h, "override receives the BaseMenu handler as argument")
end

function M.test_tab_buildSearchable_missing_falls_back_to_default_corpus()
    setup()
    populateControls({ C1 = Polyfill.makeCheckBox(), C2 = Polyfill.makeCheckBox() })
    -- No buildSearchable override: typing 'c' should match against the tab's
    -- own items (Cherry) via the default corpus. Default moveTo writes the
    -- single-level index, so after typing the cursor lands on index 2.
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = {
                    BaseMenuItems.Checkbox({ controlName = "C1", textKey = "Apple" }),
                    BaseMenuItems.Checkbox({ controlName = "C2", textKey = "Cherry" }),
                },
            },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(0x43, 0, WM_KEYDOWN) -- 'c'
    T.eq(h._indices[1], 2, "default corpus moved cursor to Cherry")
end

function M.test_tab_buildSearchable_bad_return_falls_back_to_default()
    setup()
    populateControls({ C1 = Polyfill.makeCheckBox() })
    local errorLogged = false
    local priorError = Log.error
    Log.error = function(msg)
        if tostring(msg):find("buildSearchable", 1, true) then
            errorLogged = true
        end
    end
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "C1", textKey = "Apple" }) },
                buildSearchable = function()
                    return "not a table"
                end,
            },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(0x41, 0, WM_KEYDOWN) -- 'a'; fallback default should match "Apple"
    T.truthy(errorLogged, "override returning non-table is logged")
    T.eq(h._indices[1], 1, "fallback default corpus used after bad override")
    Log.error = priorError
end

function M.test_tab_onAltLeft_onAltRight_hooks_fire_on_active_tab()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB })
    local leftCalls = 0
    local rightCalls = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
            },
            {
                name = "TAB_B",
                onAltLeft = function(handler)
                    leftCalls = leftCalls + 1
                end,
                onAltRight = function(handler)
                    rightCalls = rightCalls + 1
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LB" }) },
            },
        },
    })
    HandlerStack.push(h)
    -- Alt on the unhooked tab A: no default behavior, silent no-op.
    InputRouter.dispatch(Keys.VK_LEFT, 4, WM_KEYDOWN) -- mods=MOD_ALT
    InputRouter.dispatch(Keys.VK_RIGHT, 4, WM_KEYDOWN)
    T.eq(leftCalls, 0, "onAltLeft not called on unhooked tab")
    T.eq(rightCalls, 0, "onAltRight not called on unhooked tab")
    -- Switch to hooked tab B and fire both directions.
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_LEFT, 4, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RIGHT, 4, WM_KEYDOWN)
    T.eq(leftCalls, 1, "onAltLeft fired once on hooked tab")
    T.eq(rightCalls, 1, "onAltRight fired once on hooked tab")
end

function M.test_spec_onAltLeft_fires_when_no_tabs()
    setup()
    setCtrls({ "A", "B" })
    local leftCalls = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A", "B" }),
        onAltLeft = function()
            leftCalls = leftCalls + 1
        end,
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_LEFT, 4, WM_KEYDOWN) -- mods=MOD_ALT
    T.eq(leftCalls, 1, "spec onAltLeft fired on Alt+Left")
end

function M.test_spec_onAltRight_fires_when_no_tabs()
    setup()
    setCtrls({ "A", "B" })
    local rightCalls = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A", "B" }),
        onAltRight = function()
            rightCalls = rightCalls + 1
        end,
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 4, WM_KEYDOWN)
    T.eq(rightCalls, 1, "spec onAltRight fired on Alt+Right")
end

function M.test_tab_onAltLeft_overrides_spec_onAltLeft()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB })
    local specCalls, tabCalls = 0, 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        onAltLeft = function()
            specCalls = specCalls + 1
        end,
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
            },
            {
                name = "TAB_B",
                onAltLeft = function()
                    tabCalls = tabCalls + 1
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LB" }) },
            },
        },
    })
    HandlerStack.push(h)
    -- Tab A has no onAltLeft; spec-level fallback fires.
    InputRouter.dispatch(Keys.VK_LEFT, 4, WM_KEYDOWN)
    T.eq(specCalls, 1, "spec onAltLeft fired on unhooked tab")
    T.eq(tabCalls, 0, "tab onAltLeft not fired on unhooked tab")
    -- Switch to tab B and fire Alt+Left: tab hook wins over spec.
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_LEFT, 4, WM_KEYDOWN)
    T.eq(tabCalls, 1, "tab onAltLeft fired")
    T.eq(specCalls, 1, "spec onAltLeft did not also fire when tab hook present")
end

function M.test_spec_onAltLeft_rejects_non_function()
    setup()
    setCtrls({ "A" })
    local ok, err = pcall(function()
        BaseMenu.create({
            name = "T",
            displayName = "Screen",
            items = buttonSpec({ "A" }),
            onAltLeft = "not a function",
        })
    end)
    T.truthy(not ok, "non-function onAltLeft rejected")
    T.truthy(tostring(err):find("onAltLeft"), "error mentions the field")
end

function M.test_spec_onAltRight_rejects_non_function()
    setup()
    setCtrls({ "A" })
    local ok, err = pcall(function()
        BaseMenu.create({
            name = "T",
            displayName = "Screen",
            items = buttonSpec({ "A" }),
            onAltRight = 42,
        })
    end)
    T.truthy(not ok, "non-function onAltRight rejected")
    T.truthy(tostring(err):find("onAltRight"), "error mentions the field")
end

function M.test_tab_onCtrlUp_hook_overrides_sibling_group_jump()
    setup()
    local cbA = Polyfill.makeCheckBox()
    local cbB = Polyfill.makeCheckBox()
    populateControls({ CA = cbA, CB = cbB })
    local hookCalls = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "LA" }) },
            },
            {
                name = "TAB_B",
                onCtrlUp = function(handler)
                    hookCalls = hookCalls + 1
                end,
                onCtrlDown = function(handler)
                    hookCalls = hookCalls + 10
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CB", textKey = "LB" }) },
            },
        },
    })
    HandlerStack.push(h)
    -- Switch to the hooked tab and fire Ctrl+Up then Ctrl+Down.
    InputRouter.dispatch(Keys.VK_TAB, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_UP, 2, WM_KEYDOWN) -- mods=MOD_CTRL
    InputRouter.dispatch(Keys.VK_DOWN, 2, WM_KEYDOWN)
    T.eq(hookCalls, 11, "onCtrlUp+onCtrlDown each fired once on the active hooked tab")
end

function M.test_tab_without_onCtrl_hook_falls_back_to_default()
    setup()
    local g1a = BaseMenuItems.Checkbox({ controlName = "C1a", textKey = "L1a" })
    local g1b = BaseMenuItems.Checkbox({ controlName = "C1b", textKey = "L1b" })
    local g2a = BaseMenuItems.Checkbox({ controlName = "C2a", textKey = "L2a" })
    populateControls({
        C1a = Polyfill.makeCheckBox(),
        C1b = Polyfill.makeCheckBox(),
        C2a = Polyfill.makeCheckBox(),
    })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "UNHOOKED",
                items = {
                    BaseMenuItems.Group({ labelText = "G1", items = { g1a, g1b } }),
                    BaseMenuItems.Group({ labelText = "G2", items = { g2a } }),
                },
            },
        },
    })
    HandlerStack.push(h)
    T.eq(h._indices[1], 1, "starts on G1")
    InputRouter.dispatch(Keys.VK_DOWN, 2, WM_KEYDOWN) -- Ctrl+Down
    T.eq(h._indices[1], 2, "default Ctrl+Down jumped to G2 (no tab hook)")
end

function M.test_tab_first_init_fires_tab_one_onActivate()
    setup()
    local cbA = Polyfill.makeCheckBox()
    populateControls({ CA = cbA })
    local fired, gotHandler = false, nil
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                onActivate = function(handler)
                    fired = true
                    gotHandler = handler
                end,
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "L" }) },
            },
            {
                name = "TAB_B",
                items = { BaseMenuItems.Checkbox({ controlName = "CA", textKey = "L" }) },
            },
        },
    })
    HandlerStack.push(h)
    T.eq(fired, true, "tab 1 onActivate fires on first open")
    T.eq(gotHandler, h, "onActivate receives the handler")
end

function M.test_tab_first_init_applies_tab_one_autoDrillToLevel()
    setup()
    local inner = BaseMenuItems.Text({ labelText = "Inner" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                autoDrillToLevel = 2,
                items = {
                    BaseMenuItems.Group({ labelText = "G", items = { inner } }),
                },
            },
        },
    })
    HandlerStack.push(h)
    T.eq(h._level, 2, "first open drilled into the first group on tab 1")
    T.eq(h._indices[2], 1, "cursor lands on first child after drill")
end

function M.test_tab_first_init_onActivate_can_override_cursor()
    setup()
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        tabs = {
            {
                name = "TAB_A",
                onActivate = function(handler)
                    handler._indices = { 2 }
                end,
                items = {
                    BaseMenuItems.Text({ labelText = "First" }),
                    BaseMenuItems.Text({ labelText = "Second" }),
                },
            },
        },
    })
    HandlerStack.push(h)
    T.eq(h._indices[1], 2, "tab 1 onActivate overrode the default cursor")
    -- Final speech queues the cursor's current item, not the default first.
    local lastSpoken = speaks[#speaks].text
    T.eq(lastSpoken, "Second", "speech announces the overridden cursor item")
end

return M

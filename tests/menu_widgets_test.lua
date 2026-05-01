-- BaseMenuItems widgets and Button-list navigation. Covers Button-list
-- navigation, disabled-but-visible walking, Checkbox / Slider / PullDown
-- widgets, and the VirtualSlider / VirtualToggle settings-menu items.
-- Shared setup / helpers / state live in tests/menu_test_setup.lua;
-- aliased below for terse test bodies.
local T = require("support")
local Setup = require("menu_test_setup")
local M = {}

local warns, errors = Setup.warns, Setup.errors
local speaks, sounds = Setup.speaks, Setup.sounds
local resetPDMetatable = Setup.resetPDMetatable
local makePullDownWithMetatable = Setup.makePullDownWithMetatable
local populateControls = Setup.populateControls
local patchProbeFromPullDown = Setup.patchProbeFromPullDown
local registerSliderCallback = Setup.registerSliderCallback
local registerCheckHandler = Setup.registerCheckHandler
local makeCtrl = Setup.makeCtrl
local setCtrls = Setup.setCtrls
local ctrlState = Setup.ctrlState
local makeContextPtr = Setup.makeContextPtr
local buttonSpec = Setup.buttonSpec
local clearArr = Setup.clearArr

local function setup()
    Setup.fresh()
end

local WM_KEYDOWN = 256

-- Button navigation (formerly SimpleListHandler) ------------------------

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
    clearArr(speaks)
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
    clearArr(speaks)
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
    clearArr(speaks)
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
    clearArr(sounds)
    clearArr(speaks)
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
    clearArr(speaks)
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
    clearArr(speaks)
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
    clearArr(speaks)
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
    clearArr(speaks)
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
    clearArr(speaks)
    clearArr(sounds)
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
    clearArr(speaks)
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
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(h._indices[1], 2, "cursor advanced off the now-hidden pulldown")
    T.truthy(#speaks >= 1, "re-activation announced the new current item")
end

-- VirtualSlider --------------------------------------------------------
--
-- Settings-menu item with no Civ V XML widget. Drives Left / Right adjust
-- through a getter / setter pair the caller supplies (e.g. VolumeControl).

function M.test_virtual_slider_right_increments_by_small_step()
    setup()
    local value = 0.5
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "LBL_VOL",
                getValue = function()
                    return value
                end,
                setValue = function(v)
                    value = v
                end,
                labelFn = function(v)
                    return string.format("Volume %d", math.floor(v * 100 + 0.5))
                end,
                step = 0.05,
                bigStep = 0.20,
            }),
        },
    })
    HandlerStack.push(h)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(value, 0.55)
    T.eq(speaks[1].text, "Volume 55")
end

function M.test_virtual_slider_left_decrements_by_small_step()
    setup()
    local value = 0.5
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "LBL_VOL",
                getValue = function()
                    return value
                end,
                setValue = function(v)
                    value = v
                end,
                labelFn = function(v)
                    return string.format("Volume %d", math.floor(v * 100 + 0.5))
                end,
                step = 0.05,
                bigStep = 0.20,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(value, 0.45)
end

function M.test_virtual_slider_shift_right_uses_big_step()
    setup()
    local value = 0.5
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "LBL_VOL",
                getValue = function()
                    return value
                end,
                setValue = function(v)
                    value = v
                end,
                labelFn = function(v)
                    return string.format("Volume %d", math.floor(v * 100 + 0.5))
                end,
                step = 0.05,
                bigStep = 0.20,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 1, WM_KEYDOWN) -- mod 1 = Shift
    T.eq(value, 0.7)
end

function M.test_virtual_slider_clamps_at_one()
    setup()
    local value = 0.99
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "LBL_VOL",
                getValue = function()
                    return value
                end,
                setValue = function(v)
                    value = v
                end,
                labelFn = function(v)
                    return string.format("Volume %d", math.floor(v * 100 + 0.5))
                end,
                step = 0.05,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(value, 1)
    -- Second press at the cap is a no-op on the setter but still announces
    -- (so the user gets feedback that they're at the boundary).
    InputRouter.dispatch(Keys.VK_RIGHT, 0, WM_KEYDOWN)
    T.eq(value, 1)
end

function M.test_virtual_slider_clamps_at_zero()
    setup()
    local value = 0.02
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "LBL_VOL",
                getValue = function()
                    return value
                end,
                setValue = function(v)
                    value = v
                end,
                labelFn = function(v)
                    return string.format("Volume %d", math.floor(v * 100 + 0.5))
                end,
                step = 0.05,
            }),
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_LEFT, 0, WM_KEYDOWN)
    T.eq(value, 0)
end

function M.test_virtual_slider_focus_announces_current_value()
    setup()
    local v1 = 0.25
    local v2 = 0.75
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualSlider({
                textKey = "A",
                getValue = function()
                    return v1
                end,
                setValue = function() end,
                labelFn = function(v)
                    return string.format("A %d", math.floor(v * 100 + 0.5))
                end,
            }),
            BaseMenuItems.VirtualSlider({
                textKey = "B",
                getValue = function()
                    return v2
                end,
                setValue = function() end,
                labelFn = function(v)
                    return string.format("B %d", math.floor(v * 100 + 0.5))
                end,
            }),
        },
    })
    HandlerStack.push(h)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_DOWN, 0, WM_KEYDOWN)
    T.eq(speaks[1].text, "B 75")
end

-- VirtualToggle --------------------------------------------------------
--
-- Settings-menu bool toggle with no Civ V XML widget. Activate flips the
-- value via setValue and announces the new state.

function M.test_virtual_toggle_enter_flips_to_true_and_announces_on()
    setup()
    local v = false
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualToggle({
                textKey = "LBL_T",
                getValue = function()
                    return v
                end,
                setValue = function(nv)
                    v = nv
                end,
            }),
        },
    })
    HandlerStack.push(h)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(v, true)
    T.eq(speaks[#speaks].text, "LBL_T, on")
end

function M.test_virtual_toggle_space_flips_back_to_false_and_announces_off()
    setup()
    local v = true
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualToggle({
                textKey = "LBL_T",
                getValue = function()
                    return v
                end,
                setValue = function(nv)
                    v = nv
                end,
            }),
        },
    })
    HandlerStack.push(h)
    clearArr(speaks)
    InputRouter.dispatch(Keys.VK_SPACE, 0, WM_KEYDOWN)
    T.eq(v, false)
    T.eq(speaks[#speaks].text, "LBL_T, off")
end

function M.test_virtual_toggle_focus_announces_current_state()
    setup()
    local v = true
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.VirtualToggle({
                textKey = "LBL_T",
                getValue = function()
                    return v
                end,
                setValue = function() end,
            }),
        },
    })
    HandlerStack.push(h)
    -- The first announcement after push is "Screen" then the focused item.
    T.eq(speaks[2].text, "LBL_T, on")
end


return M

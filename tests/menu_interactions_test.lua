-- BaseMenu item-interaction tests. Peeled out of menu_test.lua.
-- Covers click-ack gating (when activation plays the click sound vs
-- when it stays silent), tooltip composition / dedupe / dynamic fn /
-- newline handling, and edit-mode (Textfield enter / escape / restore
-- / commit / re-enter). The shared setup() and helpers are duplicated
-- across the four menu_*_test files so each is self-contained.
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

-- Click-ack gating ------------------------------------------------------
--
-- The activation click plays only when the item actually did something:
-- pcall-successful activate for Button/Choice/Pulldown entry, a captured-
-- and-successful callback for Checkbox, onActivate-successful for Text
-- (no onActivate means the Enter is a read-only ack, label re-spoken and
-- no click). A thrown handler or an uncaptured callback produces silence
-- plus a logged error so the user doesn't hear a misleading confirmation.

function M.test_button_activate_throw_suppresses_click()
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
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 0, "no click on thrown activate")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_text_without_onActivate_reannounces_label_no_click()
    setup()
    populateControls({})
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Text({ labelText = "Read only" }) },
    })
    HandlerStack.push(h)
    sounds = {}
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 0, "no click on informational Text")
    T.eq(#speaks, 1, "label re-spoken as keypress ack")
    T.eq(speaks[1].text, "Read only")
    T.eq(speaks[1].interrupt, true)
end

function M.test_text_with_onActivate_success_plays_click()
    setup()
    populateControls({})
    local fired = 0
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Text({
                labelText = "Hook",
                onActivate = function()
                    fired = fired + 1
                end,
            }),
        },
    })
    HandlerStack.push(h)
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(fired, 1, "onActivate ran")
    T.eq(#sounds, 1, "click plays after successful onActivate")
    T.eq(sounds[1], "AS2D_IF_SELECT")
end

function M.test_text_with_throwing_onActivate_suppresses_click()
    setup()
    populateControls({})
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Text({
                labelText = "Hook",
                onActivate = function()
                    error("bad hook")
                end,
            }),
        },
    })
    HandlerStack.push(h)
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 0, "no click on thrown Text onActivate")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_choice_activate_throw_suppresses_click()
    setup()
    populateControls({})
    local choice = BaseMenuItems.Choice({
        labelText = "Bad",
        activate = function()
            error("nope")
        end,
    })
    local h = BaseMenu.create({ name = "T", displayName = "Test", items = { choice } })
    HandlerStack.push(h)
    sounds = {}
    choice:activate(h)
    T.eq(#sounds, 0, "no click on thrown Choice activate")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_checkbox_no_captured_callback_suppresses_click()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "Foo", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(cb:IsChecked(), true, "local state still flipped")
    T.eq(#sounds, 0, "no click without a captured callback")
    T.truthy(#warns >= 1, "missing-callback warning logged")
end

function M.test_checkbox_throwing_callback_suppresses_click()
    setup()
    local cb = Polyfill.makeCheckBox({ checked = false })
    populateControls({ Foo = cb })
    registerCheckHandler(cb, function()
        error("kaboom")
    end)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Checkbox({ controlName = "Foo", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 0, "no click when callback throws")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_pulldown_no_entries_suppresses_click()
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
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 0, "no click when pulldown has no entries to open")
end

function M.test_pulldown_entry_throwing_callback_suppresses_click_still_pops()
    setup()
    local pd = makePullDownWithMetatable()
    populateControls({ PD = pd })
    patchProbeFromPullDown(pd)
    pd:ClearEntries()
    pd:RegisterSelectionCallback(function()
        error("kaboom")
    end)
    local inst = {}
    pd:BuildEntry("InstanceOne", inst)
    inst.Button:SetText("OnlyEntry")
    inst.Button:SetVoid1(1)
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Pulldown({ controlName = "PD", textKey = "LBL_PD" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2, "sub pushed")
    sounds = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(#sounds, 0, "no click when entry callback throws")
    T.eq(HandlerStack.count(), 1, "sub still popped after thrown callback")
    T.truthy(#errors >= 1, "callback error logged")
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
    T.eq(speaks[2].text, "Show map, on. Toggles the map overlay")
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
    T.eq(speaks[2].text, "Fullscreen, off. Some extra detail", "duplicate 'Fullscreen' sentence dropped from tooltip")
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
    T.eq(speaks[2].text, "LBL, off. live tip")
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

function M.test_tooltip_newlines_become_period_separators()
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
                    return "first line[NEWLINE]second line[NEWLINE]third line"
                end,
                activate = function() end,
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(
        speaks[#speaks].text,
        "LABEL_A. first line. second line. third line",
        "engine [NEWLINE] separators become periods so multi-line tooltips read with pauses"
    )
end

function M.test_tooltip_decimal_in_value_is_preserved()
    setup()
    setCtrls({ "A" })
    -- Trade-route tooltips report fractional values via the engine's
    -- "{1_Num: number #.#}" format, producing strings like "Gold base: 1.06".
    -- The sentence splitter must not treat the decimal point as a sentence
    -- boundary, otherwise the user hears "1. 06" with a spurious break.
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = {
            BaseMenuItems.Button({
                controlName = "A",
                textKey = "LABEL_A",
                tooltipFn = function()
                    return "Gold base: 1.06[NEWLINE]Total: 5 Gold"
                end,
                activate = function() end,
            }),
        },
    })
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A. Gold base: 1.06. Total: 5 Gold")
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
    populateControls({ E = eb })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = { BaseMenuItems.Textfield({ controlName = "E", textKey = "LBL" }) },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("partial")
    speaks = {}
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(HandlerStack.active(), h, "edit sub popped; menu is top")
    T.eq(HandlerStack.count(), 1)
    T.eq(eb:GetText(), "Athens", "original text restored")
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


return M

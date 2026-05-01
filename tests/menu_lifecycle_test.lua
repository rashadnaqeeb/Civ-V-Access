-- BaseMenu lifecycle and tabbing tests. Covers Install (push on show /
-- pop on hide / reactivation / suppressReactivateOnHide / Esc bypass),
-- preamble (silentFirstOpen variants, ReadSubtitles, function preamble),
-- refresh, F1 readHeader, single-handler tabs, and the per-tab nameFn /
-- buildSearchable / onAltLeft-Right / onCtrl hooks. The shared setup()
-- and helpers are duplicated across the four menu_*_test files so each
-- suite is self-contained.
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

function M.test_install_hide_reactivates_underneath_by_default()
    setup()
    setCtrls({ "A" })
    local activated = 0
    HandlerStack.push({
        name = "Underneath",
        onActivate = function()
            activated = activated + 1
        end,
    })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, { name = "S", displayName = "Screen", items = buttonSpec({ "A" }) })
    ctx._sh(false, false)
    -- pushing on top of Underneath fires removeByName(_, false) on its
    -- prior install, then push -- neither reactivates Underneath.
    activated = 0
    ctx._sh(true, false)
    T.eq(activated, 1, "hide reactivates underneath by default")
end

function M.test_install_suppressReactivateOnHide_skips_reactivation()
    setup()
    setCtrls({ "A" })
    local activated = 0
    HandlerStack.push({
        name = "Underneath",
        onActivate = function()
            activated = activated + 1
        end,
    })
    local switching = false
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "S",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        suppressReactivateOnHide = function()
            return switching
        end,
    })
    ctx._sh(false, false)
    activated = 0
    switching = true
    ctx._sh(true, false)
    T.eq(activated, 0, "suppressReactivateOnHide=true skips underneath reactivation")
end

function M.test_install_suppressReactivateOnHide_false_still_reactivates()
    setup()
    setCtrls({ "A" })
    local activated = 0
    HandlerStack.push({
        name = "Underneath",
        onActivate = function()
            activated = activated + 1
        end,
    })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "S",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        suppressReactivateOnHide = function()
            return false
        end,
    })
    ctx._sh(false, false)
    activated = 0
    ctx._sh(true, false)
    T.eq(activated, 1, "suppressReactivateOnHide=false leaves default reactivation intact")
end

function M.test_install_suppressReactivateOnHide_throw_logs_and_reactivates()
    setup()
    setCtrls({ "A" })
    local activated = 0
    HandlerStack.push({
        name = "Underneath",
        onActivate = function()
            activated = activated + 1
        end,
    })
    local ctx = makeContextPtr()
    BaseMenu.install(ctx, {
        name = "S",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        suppressReactivateOnHide = function()
            error("boom")
        end,
    })
    ctx._sh(false, false)
    activated = 0
    ctx._sh(true, false)
    T.truthy(#errors >= 1, "suppress predicate error logged")
    T.eq(activated, 1, "thrown predicate falls back to reactivate=true")
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

-- ReadSubtitles toggle bypasses silentFirstOpen so the preamble and first
-- item speak alongside the engine's narration. The flag is read live at the
-- gate site, so flipping it on civvaccess_shared takes effect immediately.
function M.test_silent_first_open_bypassed_by_read_subtitles()
    setup()
    setCtrls({ "A", "B" })
    civvaccess_shared.readSubtitles = true
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A", "B" }),
        silentFirstOpen = true,
    })
    HandlerStack.push(h)
    civvaccess_shared.readSubtitles = false
    T.eq(#speaks, 3, "displayName, preamble, first item all spoken")
    T.eq(speaks[1].text, "Screen")
    T.eq(speaks[2].text, "body text")
    T.eq(speaks[3].text, "LABEL_A")
end

function M.test_silent_first_open_rejects_non_boolean_or_function()
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
    T.truthy(not ok, "non-boolean / non-function rejected")
    T.truthy(tostring(err):find("silentFirstOpen"), "error mentions the field")
end

-- silentFirstOpen as a function: evaluated at first-open time so per-instance
-- gating can read just-captured state. Used by the great-work popup, which
-- only narrates writings; art / music popups go through the normal speech
-- path even though the same screen / spec is in play.
function M.test_silent_first_open_function_truthy_suppresses()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A", "B" }),
        silentFirstOpen = function()
            return true
        end,
    })
    HandlerStack.push(h)
    T.eq(#speaks, 1, "only displayName spoken when fn returns true")
    T.eq(speaks[1].text, "Screen")
end

function M.test_silent_first_open_function_falsy_speaks()
    setup()
    setCtrls({ "A", "B" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A", "B" }),
        silentFirstOpen = function()
            return false
        end,
    })
    HandlerStack.push(h)
    T.eq(#speaks, 3, "displayName, preamble, first item all spoken when fn returns false")
end

-- A throwing silentFirstOpen function is logged and treated as false, so a
-- broken gate fails open (preamble still speaks) rather than silently
-- swallowing the screen's announce.
function M.test_silent_first_open_function_error_treated_as_false()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A" }),
        silentFirstOpen = function()
            error("boom")
        end,
    })
    HandlerStack.push(h)
    T.eq(#errors, 1, "error logged through Log.error")
    T.truthy(tostring(errors[1]):find("silentFirstOpen"), "log mentions field")
    T.eq(#speaks, 3, "displayName, preamble, first item still spoken (fail-open)")
end

-- silentDisplayName: first-open skips displayName but still announces
-- preamble / first-item. Used by the hex-cursor Enter picker whose first
-- item already carries the distinguishing name.
function M.test_silent_display_name_skips_header()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        items = buttonSpec({ "A" }),
        silentDisplayName = true,
    })
    HandlerStack.push(h)
    T.eq(#speaks, 1, "only first-item spoken; displayName skipped")
    T.truthy(speaks[1].text ~= "Screen", "displayName not in speak stream: " .. tostring(speaks[1].text))
end

function M.test_silent_display_name_still_speaks_preamble_and_first_item()
    setup()
    setCtrls({ "A" })
    local h = BaseMenu.create({
        name = "T",
        displayName = "Screen",
        preamble = "body text",
        items = buttonSpec({ "A" }),
        silentDisplayName = true,
    })
    HandlerStack.push(h)
    T.eq(#speaks, 2, "preamble and first-item both speak; displayName skipped")
    T.eq(speaks[1].text, "body text")
end

function M.test_silent_display_name_rejects_non_boolean()
    setup()
    setCtrls({ "A" })
    local ok, err = pcall(function()
        BaseMenu.create({
            name = "T",
            displayName = "Screen",
            items = buttonSpec({ "A" }),
            silentDisplayName = "yes",
        })
    end)
    T.truthy(not ok, "non-boolean rejected")
    T.truthy(tostring(err):find("silentDisplayName"), "error mentions the field")
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
    populateControls({
        C1a = Polyfill.makeCheckBox(),
        C1b = Polyfill.makeCheckBox(),
        C2a = Polyfill.makeCheckBox(),
    })
    local g1a = BaseMenuItems.Checkbox({ controlName = "C1a", textKey = "L1a" })
    local g1b = BaseMenuItems.Checkbox({ controlName = "C1b", textKey = "L1b" })
    local g2a = BaseMenuItems.Checkbox({ controlName = "C2a", textKey = "L2a" })
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

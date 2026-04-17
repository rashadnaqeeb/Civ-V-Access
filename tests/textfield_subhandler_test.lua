-- Tests for TextFieldSubHandler: snapshot / clear / focus on push, Escape
-- restores snapshot and pops, Enter binding pops and (if provided) fires
-- commitFn, onDeactivate restores the prior callback. The wrapping
-- callback chains to priorCallback unconditionally on every fire so the
-- screen's validator keeps running as the user types.

local T = require("support")
local M = {}

local warns, errors
local speaks

local function setup()
    warns, errors = {}, {}
    Log.warn  = function(m) warns[#warns + 1]  = m end
    Log.error = function(m) errors[#errors + 1] = m end
    Log.info  = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function() return false end
    UI.CtrlKeyDown  = function() return false end
    UI.AltKeyDown   = function() return false end

    Events.AudioPlay2DSound = function() end

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
    dofile("src/dlc/UI/Shared/CivVAccess_TextFieldSubHandler.lua")
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
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDIT"]     = "edit"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_BLANK"]    = "blank"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING"]  = "editing {1_Label}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED"] = "{1_Label} restored"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEXTFIELD_COMMITTED"]= "{1_Label} committed"
end

local WM_KEYDOWN = 256

local function populateControls(map)
    Controls = {}
    for name, c in pairs(map) do Controls[name] = c end
end

local function pushForm(items)
    local h = FormHandler.create({
        name = "Screen", displayName = "Screen", items = items,
    })
    HandlerStack.push(h)
    return h
end

-- Push effects -----------------------------------------------------

function M.test_push_snapshots_and_clears_and_focuses()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2, "sub pushed")
    T.eq(eb:GetText(), "", "editbox cleared on push")
    T.eq(eb._hasFocus, true, "TakeFocus called on push")
end

function M.test_push_announces_editing()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "editing LBL" then found = true end
    end
    T.truthy(found, "editing announcement fired on push")
end

-- Escape restore ---------------------------------------------------

function M.test_escape_restores_snapshot_and_pops()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("partial")
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub popped on Escape")
    T.eq(eb:GetText(), "Athens", "original text restored")
end

function M.test_escape_announces_restored()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "LBL restored" then found = true end
    end
    T.truthy(found, "restored announcement fired on Escape")
end

function M.test_escape_with_empty_snapshot_does_not_crash()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("junk")
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(eb:GetText(), "", "restored blank snapshot")
    T.eq(HandlerStack.count(), 1)
end

-- Enter / commit ---------------------------------------------------

function M.test_enter_without_commitFn_pops_quietly()
    setup()
    local eb = Polyfill.makeEditBox({ text = "Athens" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2)
    eb:SetText("new name")
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub popped on Enter")
    T.eq(eb:GetText(), "new name", "typed text preserved (no restore on Enter)")
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "LBL committed" then found = true end
    end
    T.falsy(found, "no committed announcement when commitFn absent")
end

function M.test_enter_with_commitFn_pops_calls_commit_and_announces()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local commits = 0
    local function commit() commits = commits + 1 end
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL",
          commitFn = commit },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    speaks = {}
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 1, "sub popped")
    T.eq(commits, 1, "commitFn called")
    local found = false
    for _, s in ipairs(speaks) do
        if s.text == "LBL committed" then found = true end
    end
    T.truthy(found, "committed announcement fired")
end

function M.test_enter_commitFn_order_is_pop_then_call()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local observedCount
    local function commit() observedCount = HandlerStack.count() end
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL",
          commitFn = commit },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(observedCount, 1,
        "sub is popped before commitFn runs so a screen-closing commit is safe")
end

-- Prior callback chaining -----------------------------------------

function M.test_wrapper_chains_prior_on_every_char()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local priorCalls = 0
    local function prior() priorCalls = priorCalls + 1 end
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL",
          priorCallback = prior },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb:SetText("a")
    eb._cb("a", eb, false)
    eb:SetText("ab")
    eb._cb("ab", eb, false)
    T.eq(priorCalls, 2)
end

function M.test_wrapper_chains_prior_on_enter_fire_too()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local seen
    local function prior(_, _, bIsEnter) seen = bIsEnter end
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL",
          priorCallback = prior },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    eb._cb("x", eb, true)
    T.eq(seen, true,
        "wrapper forwards bIsEnter so SaveMenu-style OnEditBoxChange(bIsEnter=true) still fires")
end

function M.test_wrapper_does_not_pop_on_enter_fire()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL" },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(HandlerStack.count(), 2)
    eb._cb("x", eb, true)
    T.eq(HandlerStack.count(), 2,
        "sub stays put when only the EditBox callback fires; pop happens via the binding")
end

-- onDeactivate -----------------------------------------------------

function M.test_onDeactivate_restores_prior_callback()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local function prior() end
    eb:RegisterCallback(prior)
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL",
          priorCallback = prior },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.truthy(eb._cb ~= prior, "push replaced callback with wrapper")
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(eb._cb, prior, "prior restored on pop")
end

-- Focus parking --------------------------------------------------

function M.test_sub_pop_parks_focus_on_named_control()
    setup()
    local eb   = Polyfill.makeEditBox({ text = "Athens" })
    local park = Polyfill.makeButton()
    populateControls({ E = eb, CancelButton = park })
    local h = FormHandler.create({
        name = "Screen", displayName = "Screen",
        focusParkControl = "CancelButton",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    T.eq(eb._hasFocus, true, "edit focused during edit")
    park._hasFocus = nil
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(park._hasFocus, true, "park control received TakeFocus on sub pop")
end

function M.test_missing_park_control_logs_warn_but_does_not_crash()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "Screen", displayName = "Screen",
        focusParkControl = "NotAThing",
        items = {
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.truthy(#warns >= 1, "missing-park warn logged")
    T.eq(HandlerStack.count(), 1, "sub still popped cleanly")
end

function M.test_absent_focusParkControl_skips_TakeFocus()
    setup()
    local eb = Polyfill.makeEditBox({ text = "" })
    populateControls({ E = eb })
    local h = FormHandler.create({
        name = "Screen", displayName = "Screen",
        items = {  -- no focusParkControl
            { kind = "textfield", controlName = "E", textKey = "LBL" },
        },
    })
    HandlerStack.push(h)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    local before = #warns
    InputRouter.dispatch(Keys.VK_ESCAPE, 0, WM_KEYDOWN)
    T.eq(#warns, before, "no warn fired when nothing was requested")
end

function M.test_reenter_after_commit_produces_fresh_wrapper()
    setup()
    local eb = Polyfill.makeEditBox({ text = "first" })
    populateControls({ E = eb })
    local priorCalls = 0
    local function prior() priorCalls = priorCalls + 1 end
    pushForm({
        { kind = "textfield", controlName = "E", textKey = "LBL",
          priorCallback = prior },
    })
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- Enter pops (no commitFn)
    T.eq(HandlerStack.count(), 1)
    T.eq(eb._cb, prior, "prior reinstated")
    InputRouter.dispatch(Keys.VK_RETURN, 0, WM_KEYDOWN)  -- re-push
    T.eq(HandlerStack.count(), 2)
    T.truthy(eb._cb ~= prior, "new wrapper installed")
    eb._cb("x", eb, false)
    T.eq(priorCalls, 1, "second push's wrapper also chains to prior")
end

return M

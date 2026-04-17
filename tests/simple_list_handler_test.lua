-- SimpleListHandler tests. HandlerStack and InputRouter are loaded for real
-- so install() is tested against the same stack semantics used in-game.
-- SpeechPipeline is reloaded per-test and its _speakAction redirected to
-- capture interrupt/queued calls in order. Controls stubs emulate the
-- Civ V userdata: each entry exposes IsHidden() via a controllable flag.

local T = require("support")
local M = {}

local warns, errors, infos, debugs
local speaks  -- { {text, interrupt}, ... }
local sounds  -- { scriptID, ... }
local ctrlState  -- map controlName -> { hidden = bool }

-- Stub Controls entry matching the shape SimpleListHandler consumes.
local function makeControl(name)
    return setmetatable({ _name = name }, { __index = {
        IsHidden   = function(self) return ctrlState[self._name].hidden   end,
        IsDisabled = function(self) return ctrlState[self._name].disabled end,
    }})
end

local function setControls(names)
    Controls = {}
    ctrlState = {}
    for _, name in ipairs(names) do
        ctrlState[name] = { hidden = false, disabled = false }
        Controls[name] = makeControl(name)
    end
end

-- Seed TXT_KEY_CIVVACCESS_BUTTON_DISABLED so announceLabel produces the
-- suffix the tests expect. The Text wrapper logs a warn and returns the raw
-- key otherwise, which would still work but muddies the suffix assertions.
local function seedDisabledSuffix()
    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
end

local function setup()
    warns, errors, infos, debugs = {}, {}, {}, {}
    Log.warn  = function(msg) warns[#warns + 1]  = msg end
    Log.error = function(msg) errors[#errors + 1] = msg end
    Log.info  = function(msg) infos[#infos + 1]  = msg end
    Log.debug = function(msg) debugs[#debugs + 1] = msg end
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
    dofile("src/dlc/UI/Shared/CivVAccess_SimpleListHandler.lua")
    HandlerStack._reset()
    TickPump._reset()
    seedDisabledSuffix()
end

local WM_KEYDOWN = 256

local function basicSpec()
    return {
        name        = "Test",
        displayName = "Test Screen",
        items = {
            { controlName = "A", textKey = "LABEL_A", activate = function() end },
            { controlName = "B", textKey = "LABEL_B", activate = function() end },
            { controlName = "C", textKey = "LABEL_C", activate = function() end },
        },
    }
end

-- Factory tests ---------------------------------------------------------

function M.test_create_shape_matches_handler_contract()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    T.eq(h.name, "Test")
    T.eq(h.capturesAllInput, true)
    T.eq(type(h.bindings), "table")
    T.eq(#h.bindings, 5, "Up/Down/Home/End/Enter")
    T.eq(type(h.onActivate), "function")
    T.eq(type(h.onDeactivate), "function")
end

function M.test_down_moves_to_next_item()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    InputRouter.dispatch(40, 0, WM_KEYDOWN)  -- VK_DOWN
    T.eq(h._index, 2)
end

function M.test_up_wraps_from_top_to_bottom()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    InputRouter.dispatch(38, 0, WM_KEYDOWN)  -- VK_UP from index 1
    T.eq(h._index, 3)
end

function M.test_down_wraps_from_bottom_to_top()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)       -- onActivate resets _index to 1
    h._index = 3               -- walk to bottom then press Down
    speaks = {}
    InputRouter.dispatch(40, 0, WM_KEYDOWN)
    T.eq(h._index, 1)
end

function M.test_hidden_items_are_skipped()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.B.hidden = true
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    InputRouter.dispatch(40, 0, WM_KEYDOWN)
    T.eq(h._index, 3, "skipped hidden B")
end

function M.test_all_hidden_navigation_is_noop()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.A.hidden = true
    ctrlState.B.hidden = true
    ctrlState.C.hidden = true
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    local before = h._index
    InputRouter.dispatch(40, 0, WM_KEYDOWN)
    InputRouter.dispatch(38, 0, WM_KEYDOWN)
    T.eq(h._index, before, "no movement, no infinite loop")
end

function M.test_home_jumps_to_first_valid()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.A.hidden = true
    local h = SimpleListHandler.create(basicSpec())
    h._index = 3
    HandlerStack.push(h)
    InputRouter.dispatch(36, 0, WM_KEYDOWN)  -- VK_HOME
    T.eq(h._index, 2, "A hidden, first valid is B")
end

function M.test_end_jumps_to_last_valid()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.C.hidden = true
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    InputRouter.dispatch(35, 0, WM_KEYDOWN)  -- VK_END
    T.eq(h._index, 2, "C hidden, last valid is B")
end

function M.test_enter_fires_activate()
    setup()
    setControls({"A", "B", "C"})
    local fired = 0
    local spec = basicSpec()
    spec.items[1].activate = function() fired = fired + 1 end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    InputRouter.dispatch(13, 0, WM_KEYDOWN)  -- VK_RETURN
    T.eq(fired, 1)
end

function M.test_enter_activate_error_caught_and_logged()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.items[1].activate = function() error("kaboom") end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    local consumed = InputRouter.dispatch(13, 0, WM_KEYDOWN)
    T.truthy(consumed, "binding still consumed after error")
    T.truthy(#errors >= 1, "error logged")
end

function M.test_enter_plays_click_sound_only_when_item_valid()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    InputRouter.dispatch(13, 0, WM_KEYDOWN)  -- valid item
    T.eq(#sounds, 1)
    T.eq(sounds[1], "AS2D_IF_SELECT")
    ctrlState.A.hidden = true
    sounds = {}
    InputRouter.dispatch(13, 0, WM_KEYDOWN)  -- now invalid
    T.eq(#sounds, 0, "no click on invalid Enter")
end

function M.test_enter_on_hidden_current_logs_warn_no_crash()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    local fired = 0
    spec.items[1].activate = function() fired = fired + 1 end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    ctrlState.A.hidden = true  -- current item becomes invalid after activate
    InputRouter.dispatch(13, 0, WM_KEYDOWN)
    T.eq(fired, 0, "activate not fired on invalid item")
    T.truthy(#warns >= 1)
end

function M.test_missing_control_logs_warn_and_marks_invalid()
    setup()
    setControls({"A", "C"})  -- B absent
    local h = SimpleListHandler.create(basicSpec())
    T.truthy(#warns >= 1, "missing-control warn logged")
    HandlerStack.push(h)
    InputRouter.dispatch(40, 0, WM_KEYDOWN)
    T.eq(h._index, 3, "missing B skipped just like a hidden item")
end

function M.test_onActivate_speaks_displayName_then_first_item()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)  -- invokes onActivate
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "Test Screen")
    T.truthy(speaks[1].interrupt, "displayName interrupts")
    T.eq(speaks[2].text, "LABEL_A")
    T.falsy(speaks[2].interrupt, "first item queued")
end

function M.test_onActivate_preamble_queued_between_displayName_and_first_item()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.preamble = "Are you sure?"
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    T.eq(#speaks, 3)
    T.eq(speaks[1].text, "Test Screen")
    T.truthy(speaks[1].interrupt)
    T.eq(speaks[2].text, "Are you sure?")
    T.falsy(speaks[2].interrupt, "preamble queued")
    T.eq(speaks[3].text, "LABEL_A")
    T.falsy(speaks[3].interrupt, "first item queued")
end

function M.test_onActivate_all_hidden_speaks_only_displayName()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.A.hidden = true
    ctrlState.B.hidden = true
    ctrlState.C.hidden = true
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "Test Screen")
end

function M.test_post_activate_revalidation_advances_on_hidden_flip()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.items[1].activate = function()
        ctrlState.A.hidden = true  -- the MultiplayerSelect toggle case
    end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(13, 0, WM_KEYDOWN)
    T.eq(h._index, 2, "cursor advanced to next valid")
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "LABEL_B")
    T.falsy(speaks[1].interrupt, "next-valid speak is queued")
end

function M.test_capturesAllInput_blocks_lower_handlers()
    setup()
    setControls({"A", "B", "C"})
    local lowerFired = 0
    HandlerStack.push({
        name = "lower", capturesAllInput = false,
        bindings = {{ key = 65, mods = 0, fn = function() lowerFired = lowerFired + 1 end }},
    })
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    local consumed = InputRouter.dispatch(65, 0, WM_KEYDOWN)  -- unhandled A-key
    T.truthy(consumed, "barrier swallows unbound key")
    T.eq(lowerFired, 0)
end

-- Install tests ---------------------------------------------------------

local function makeContextPtr()
    return {
        SetShowHideHandler = function(self, fn) self._sh = fn end,
        SetInputHandler    = function(self, fn) self._in = fn end,
        -- deferActivate path installs the TickPump on this Context via
        -- ContextPtr:SetUpdate, then queues a one-shot via TickPump.runOnce.
        -- Tests trigger the deferred push by calling TickPump.tick() (which
        -- is what self._update points to once TickPump.install runs).
        _hidden   = false,
        _update   = nil,
        SetUpdate = function(self, fn) self._update = fn end,
        IsHidden  = function(self) return self._hidden end,
    }
end

function M.test_install_push_on_show_pop_on_hide()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Screen"
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1)
    T.eq(HandlerStack.active().name, "Screen")
    ctx._sh(true, false)
    T.eq(HandlerStack.count(), 0)
end

function M.test_install_double_show_keeps_stack_depth_at_one()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Screen"
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 1, "idempotent push via removeByName+push")
end

function M.test_install_prior_showhide_called_before_push()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local order = {}
    local prior = function(bIsHide) order[#order + 1] = "prior:" .. tostring(bIsHide) end
    local spec = basicSpec()
    spec.name = "Screen"
    spec.priorShowHide = prior
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    T.eq(order[1], "prior:false")
    T.eq(HandlerStack.count(), 1, "push followed prior")
end

function M.test_install_prior_showhide_nil_tolerated()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    SimpleListHandler.install(ctx, basicSpec())
    ctx._sh(false, false)  -- no prior, no crash
    T.eq(HandlerStack.count(), 1)
end

function M.test_install_prior_showhide_error_caught_push_still_happens()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Screen"
    spec.priorShowHide = function() error("prior boom") end
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    T.truthy(#errors >= 1, "prior error logged")
    T.eq(HandlerStack.count(), 1, "push not blocked by prior error")
end

function M.test_install_input_routes_to_bindings()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    SimpleListHandler.install(ctx, basicSpec())
    ctx._sh(false, false)
    local h = HandlerStack.active()
    local consumed = ctx._in(WM_KEYDOWN, 40, 0)  -- VK_DOWN
    T.truthy(consumed)
    T.eq(h._index, 2)
end

function M.test_install_falls_back_to_prior_input_on_unbound_key()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local priorFired = 0
    local spec = basicSpec()
    spec.priorInput = function(msg, wp, lp)
        priorFired = priorFired + 1
        return true
    end
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    local consumed = ctx._in(WM_KEYDOWN, 27, 0)  -- VK_ESCAPE, unbound
    T.truthy(consumed, "prior consumed it")
    T.eq(priorFired, 1)
end

function M.test_install_prior_input_nil_returns_false_on_unbound()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    SimpleListHandler.install(ctx, basicSpec())
    ctx._sh(false, false)
    local consumed = ctx._in(WM_KEYDOWN, 27, 0)  -- VK_ESCAPE, unbound, no prior
    T.falsy(consumed)
end

-- Preamble function + refresh -----------------------------------------

function M.test_preamble_function_called_at_onActivate_not_at_create()
    setup()
    setControls({"A", "B", "C"})
    local calls = 0
    local spec = basicSpec()
    spec.preamble = function()
        calls = calls + 1
        return "dynamic body"
    end
    local h = SimpleListHandler.create(spec)
    T.eq(calls, 0, "preamble fn not called at create time")
    HandlerStack.push(h)
    T.eq(calls, 1, "preamble fn called once at onActivate")
    T.eq(speaks[1].text, "Test Screen")
    T.eq(speaks[2].text, "dynamic body")
    T.falsy(speaks[2].interrupt, "preamble queued after displayName")
end

function M.test_preamble_function_returning_empty_is_skipped()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.preamble = function() return "" end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    -- displayName + first item, no empty preamble between them
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "Test Screen")
    T.eq(speaks[2].text, "LABEL_A")
end

function M.test_preamble_nil_unchanged_behavior()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())  -- no preamble
    HandlerStack.push(h)
    T.eq(#speaks, 2, "displayName + first item only")
end

function M.test_refresh_respeaks_when_function_preamble_changes()
    setup()
    setControls({"A", "B", "C"})
    local body = "first"
    local spec = basicSpec()
    spec.preamble = function() return body end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    speaks = {}
    body = "second"
    h.refresh()
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "second")
    T.truthy(speaks[1].interrupt, "refresh interrupts")
end

function M.test_refresh_is_noop_when_function_preamble_unchanged()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.preamble = function() return "same" end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0)
end

function M.test_refresh_is_noop_when_preamble_is_string()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.preamble = "static body"
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0, "string preamble never re-speaks")
end

function M.test_refresh_is_noop_when_no_preamble()
    setup()
    setControls({"A", "B", "C"})
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    speaks = {}
    h.refresh()
    T.eq(#speaks, 0)
end

function M.test_refresh_fn_error_logged_no_crash()
    setup()
    setControls({"A", "B", "C"})
    local spec = basicSpec()
    spec.preamble = function() error("boom") end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    speaks = {}
    h.refresh()  -- must not crash
    T.truthy(#errors >= 1, "preamble fn error logged")
    T.eq(#speaks, 0)
end

-- Disabled-but-visible walking -----------------------------------------

function M.test_navigation_walks_disabled_items()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.B.disabled = true
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    speaks = {}
    InputRouter.dispatch(40, 0, WM_KEYDOWN)  -- VK_DOWN
    T.eq(h._index, 2, "disabled B is still navigable")
    T.eq(speaks[1].text, "LABEL_B, disabled", "disabled suffix appended")
end

function M.test_home_end_see_disabled_items()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.A.disabled = true
    ctrlState.C.disabled = true
    local h = SimpleListHandler.create(basicSpec())
    h._index = 2
    HandlerStack.push(h)
    InputRouter.dispatch(36, 0, WM_KEYDOWN)  -- VK_HOME
    T.eq(h._index, 1, "A is disabled but navigable")
    InputRouter.dispatch(35, 0, WM_KEYDOWN)  -- VK_END
    T.eq(h._index, 3, "C is disabled but navigable")
end

function M.test_enter_on_disabled_is_noop_no_activate_no_sound()
    setup()
    setControls({"A", "B", "C"})
    local fired = 0
    local spec = basicSpec()
    spec.items[1].activate = function() fired = fired + 1 end
    ctrlState.A.disabled = true
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    sounds = {}
    speaks = {}
    InputRouter.dispatch(13, 0, WM_KEYDOWN)  -- VK_RETURN
    T.eq(fired, 0, "activate not fired on disabled item")
    T.eq(#sounds, 0, "no click sound on disabled Enter")
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "LABEL_A, disabled", "disabled label re-spoken")
end

function M.test_onActivate_first_item_disabled_announces_with_suffix()
    setup()
    setControls({"A", "B", "C"})
    ctrlState.A.disabled = true
    local h = SimpleListHandler.create(basicSpec())
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A, disabled")
end

-- Empty items list -----------------------------------------------------

local function emptySpec()
    return {
        name        = "Splash",
        displayName = "Splash Screen",
        items       = {},
    }
end

function M.test_empty_items_create_succeeds()
    setup()
    setControls({})
    local h = SimpleListHandler.create(emptySpec())
    T.eq(#h.items, 0)
end

function M.test_empty_items_onActivate_speaks_displayName_only()
    setup()
    setControls({})
    local h = SimpleListHandler.create(emptySpec())
    HandlerStack.push(h)
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "Splash Screen")
end

function M.test_empty_items_onActivate_speaks_displayName_then_preamble()
    setup()
    setControls({})
    local spec = emptySpec()
    spec.preamble = "please wait"
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    T.eq(#speaks, 2)
    T.eq(speaks[1].text, "Splash Screen")
    T.eq(speaks[2].text, "please wait")
end

function M.test_empty_items_onEnter_is_safe_noop()
    setup()
    setControls({})
    local h = SimpleListHandler.create(emptySpec())
    HandlerStack.push(h)
    sounds = {}
    speaks = {}
    local consumed = InputRouter.dispatch(13, 0, WM_KEYDOWN)
    T.truthy(consumed, "Enter still consumed by barrier")
    T.eq(#sounds, 0)
    T.eq(#speaks, 0)
    T.eq(#warns, 0, "empty Enter is silent, not warn-worthy")
end

function M.test_empty_items_refresh_works()
    setup()
    setControls({})
    local body = "initial"
    local spec = emptySpec()
    spec.preamble = function() return body end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    speaks = {}
    body = "updated"
    h.refresh()
    T.eq(#speaks, 1)
    T.eq(speaks[1].text, "updated")
end

function M.test_install_prior_input_not_called_when_router_consumes()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local priorFired = 0
    local spec = basicSpec()
    spec.priorInput = function() priorFired = priorFired + 1; return true end
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    ctx._in(WM_KEYDOWN, 40, 0)  -- VK_DOWN (bound)
    T.eq(priorFired, 0)
end

-- deferActivate --------------------------------------------------------

function M.test_deferActivate_delays_push_to_update_tick()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Deferred"
    spec.deferActivate = true
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    T.eq(HandlerStack.count(), 0, "push not synchronous with show")
    T.eq(#speaks, 0, "no speech yet")
    T.eq(ctx._update, TickPump.tick, "TickPump owns Update")
    TickPump.tick()
    T.eq(HandlerStack.count(), 1, "push runs on deferred tick")
    T.eq(speaks[1].text, "Test Screen")
end

function M.test_deferActivate_hide_before_tick_cancels_push()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Deferred"
    spec.deferActivate = true
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)  -- show, schedule push
    ctx._sh(true, false)   -- same-frame hide cancels pending
    TickPump.tick()        -- tick drains one-shot
    T.eq(HandlerStack.count(), 0, "no push after cancel")
    T.eq(#speaks, 0, "no speech")
end

function M.test_deferActivate_hidden_at_tick_skips_push()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Deferred"
    spec.deferActivate = true
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    ctx._hidden = true  -- simulate engine flipping Hidden after ShowHide(false)
    TickPump.tick()
    T.eq(HandlerStack.count(), 0, "IsHidden check blocks push")
    T.eq(#speaks, 0)
end

function M.test_deferActivate_second_tick_is_noop()
    setup()
    setControls({"A", "B", "C"})
    local ctx = makeContextPtr()
    local spec = basicSpec()
    spec.name = "Deferred"
    spec.deferActivate = true
    SimpleListHandler.install(ctx, spec)
    ctx._sh(false, false)
    TickPump.tick()  -- first tick: deferred push runs, speaks
    local speaksAfterFirst = #speaks
    TickPump.tick()  -- second tick: one-shot queue empty, no re-speak
    T.eq(#speaks, speaksAfterFirst, "one-shot does not re-run on subsequent ticks")
end

-- tooltipFn -----------------------------------------------------------

function M.test_tooltipFn_appends_to_announcement()
    setup()
    setControls({"A"})
    local calls = 0
    local spec = basicSpec()
    spec.items[1].tooltipFn = function() calls = calls + 1; return "dynamic hint" end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A, dynamic hint",
        "tooltip appended after label")
    T.truthy(calls >= 1, "tooltipFn invoked at announce time")
end

function M.test_tooltipFn_error_is_logged_and_swallowed()
    setup()
    setControls({"A"})
    local spec = basicSpec()
    spec.items[1].tooltipFn = function() error("bad tooltip") end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A",
        "label still announces when tooltipFn throws")
    T.truthy(#errors >= 1, "tooltipFn error logged")
end

function M.test_tooltipFn_nil_result_does_not_add_comma()
    setup()
    setControls({"A"})
    local spec = basicSpec()
    spec.items[1].tooltipFn = function() return nil end
    local h = SimpleListHandler.create(spec)
    HandlerStack.push(h)
    T.eq(speaks[#speaks].text, "LABEL_A",
        "nil tooltipFn output leaves announcement clean")
end

return M

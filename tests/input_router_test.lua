-- InputRouter tests. HandlerStack loaded for real; UI queried via polyfill
-- stubs which we override per-test for modifier state.

local T = require("support")
local M = {}

local errors

local function setup()
    errors = {}
    Log.error = function(msg) errors[#errors + 1] = msg end
    Log.warn  = function() end
    Log.debug = function() end
    UI.ShiftKeyDown = function() return false end
    UI.CtrlKeyDown  = function() return false end
    UI.AltKeyDown   = function() return false end
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    HandlerStack._reset()
end

local WM_KEYDOWN    = 256
local WM_SYSKEYDOWN = 260

function M.test_dispatch_invokes_matching_binding()
    setup()
    local fired = 0
    HandlerStack.push({
        name = "a",
        bindings = { { key = 65, mods = 0, fn = function() fired = fired + 1 end } },
    })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(fired, 1)
end

function M.test_dispatch_top_wins_when_both_bind_same_key()
    setup()
    local lower, upper = 0, 0
    HandlerStack.push({ name = "a", bindings = {
        { key = 65, mods = 0, fn = function() lower = lower + 1 end } } })
    HandlerStack.push({ name = "b", bindings = {
        { key = 65, mods = 0, fn = function() upper = upper + 1 end } } })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(lower, 0)
    T.eq(upper, 1)
end

function M.test_capturesAllInput_stops_walk_even_on_no_match()
    setup()
    local lowerFired = 0
    HandlerStack.push({ name = "a", bindings = {
        { key = 65, mods = 0, fn = function() lowerFired = lowerFired + 1 end } } })
    HandlerStack.push({ name = "modal", capturesAllInput = true, bindings = {} })
    local consumed = InputRouter.dispatch(65, 0, WM_KEYDOWN)
    T.truthy(consumed, "barrier swallows the key")
    T.eq(lowerFired, 0)
end

function M.test_non_matching_mod_mask_does_not_fire()
    setup()
    local fired = 0
    HandlerStack.push({ name = "a", bindings = {
        { key = 65, mods = 2, fn = function() fired = fired + 1 end } } })
    T.falsy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(fired, 0)
end

function M.test_non_key_message_returns_false()
    setup()
    local fired = 0
    HandlerStack.push({ name = "a", bindings = {
        { key = 65, mods = 0, fn = function() fired = fired + 1 end } } })
    T.falsy(InputRouter.dispatch(65, 0, 257))  -- WM_KEYUP
    T.eq(fired, 0)
end

function M.test_wm_syskeydown_routed_like_wm_keydown()
    setup()
    local fired = 0
    HandlerStack.push({ name = "a", bindings = {
        { key = 37, mods = 4, fn = function() fired = fired + 1 end } } })
    T.truthy(InputRouter.dispatch(37, 4, WM_SYSKEYDOWN))
    T.eq(fired, 1)
end

function M.test_binding_fn_error_caught_still_consumed()
    setup()
    HandlerStack.push({ name = "a", bindings = {
        { key = 65, mods = 0, description = "boomer", fn = function() error("boom") end } } })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.truthy(#errors >= 1)
end

function M.test_currentModifierMask_combines_bits()
    setup()
    UI.ShiftKeyDown = function() return true end
    UI.AltKeyDown   = function() return true end
    T.eq(InputRouter.currentModifierMask(), 1 + 4)
end

function M.test_dispatch_no_handlers_returns_false()
    setup()
    T.falsy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
end

return M

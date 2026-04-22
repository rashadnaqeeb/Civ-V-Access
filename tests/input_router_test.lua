-- InputRouter tests. HandlerStack loaded for real; UI queried via polyfill
-- stubs which we override per-test for modifier state.

local T = require("support")
local M = {}

local errors

local function setup()
    errors = {}
    Log.error = function(msg)
        errors[#errors + 1] = msg
    end
    Log.warn = function() end
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
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    HandlerStack._reset()
end

local WM_KEYDOWN = 256
local WM_SYSKEYDOWN = 260

function M.test_dispatch_invokes_matching_binding()
    setup()
    local fired = 0
    HandlerStack.push({
        name = "a",
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    fired = fired + 1
                end,
            },
        },
    })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(fired, 1)
end

function M.test_dispatch_top_wins_when_both_bind_same_key()
    setup()
    local lower, upper = 0, 0
    HandlerStack.push({
        name = "a",
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    lower = lower + 1
                end,
            },
        },
    })
    HandlerStack.push({
        name = "b",
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    upper = upper + 1
                end,
            },
        },
    })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(lower, 0)
    T.eq(upper, 1)
end

function M.test_capturesAllInput_stops_walk_even_on_no_match()
    setup()
    local lowerFired = 0
    HandlerStack.push({
        name = "a",
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
    HandlerStack.push({ name = "modal", capturesAllInput = true, bindings = {} })
    local consumed = InputRouter.dispatch(65, 0, WM_KEYDOWN)
    T.truthy(consumed, "barrier swallows the key")
    T.eq(lowerFired, 0)
end

function M.test_passthrough_keys_fall_through_from_barrier()
    -- A capturesAllInput handler with a passthroughKeys set returns false
    -- for those keys so the caller (InGame / WorldView wrapper) falls
    -- through to the engine's InputHandler.
    setup()
    HandlerStack.push({
        name = "Baseline",
        capturesAllInput = true,
        bindings = {},
        passthroughKeys = { [112] = true }, -- VK_F1
    })
    T.falsy(InputRouter.dispatch(112, 0, WM_KEYDOWN), "F1 passes through")
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN), "A still swallowed")
end

function M.test_passthrough_matches_on_keycode_regardless_of_modifier()
    -- F-row passthrough intentionally ignores modifiers so Ctrl+F10
    -- (select capital) and Ctrl+F11 (quick load) pass through alongside
    -- plain F10 / F11 without a second entry per chord.
    setup()
    HandlerStack.push({
        name = "Baseline",
        capturesAllInput = true,
        bindings = {},
        passthroughKeys = { [121] = true }, -- VK_F10
    })
    T.falsy(InputRouter.dispatch(121, 0, WM_KEYDOWN), "F10 passes")
    T.falsy(InputRouter.dispatch(121, 2, WM_KEYDOWN), "Ctrl+F10 passes")
end

function M.test_binding_on_barrier_beats_passthrough()
    -- A binding on the same key as a passthrough entry wins: the handler
    -- opted in to the key explicitly, so the engine doesn't see it.
    setup()
    local fired = 0
    HandlerStack.push({
        name = "Baseline",
        capturesAllInput = true,
        bindings = {
            {
                key = 27,
                mods = 0,
                fn = function()
                    fired = fired + 1
                end,
            },
        },
        passthroughKeys = { [27] = true }, -- VK_ESCAPE
    })
    T.truthy(InputRouter.dispatch(27, 0, WM_KEYDOWN), "binding wins over passthrough")
    T.eq(fired, 1)
end

function M.test_non_matching_mod_mask_does_not_fire()
    setup()
    local fired = 0
    HandlerStack.push({
        name = "a",
        bindings = {
            {
                key = 65,
                mods = 2,
                fn = function()
                    fired = fired + 1
                end,
            },
        },
    })
    T.falsy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(fired, 0)
end

function M.test_non_key_message_returns_false()
    setup()
    local fired = 0
    HandlerStack.push({
        name = "a",
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    fired = fired + 1
                end,
            },
        },
    })
    T.falsy(InputRouter.dispatch(65, 0, 257)) -- WM_KEYUP
    T.eq(fired, 0)
end

function M.test_wm_syskeydown_routed_like_wm_keydown()
    setup()
    local fired = 0
    HandlerStack.push({
        name = "a",
        bindings = {
            {
                key = 37,
                mods = 4,
                fn = function()
                    fired = fired + 1
                end,
            },
        },
    })
    T.truthy(InputRouter.dispatch(37, 4, WM_SYSKEYDOWN))
    T.eq(fired, 1)
end

function M.test_binding_fn_error_caught_still_consumed()
    setup()
    HandlerStack.push({
        name = "a",
        bindings = {
            {
                key = 65,
                mods = 0,
                description = "boomer",
                fn = function()
                    error("boom")
                end,
            },
        },
    })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.truthy(#errors >= 1)
end

function M.test_currentModifierMask_combines_bits()
    setup()
    UI.ShiftKeyDown = function()
        return true
    end
    UI.AltKeyDown = function()
        return true
    end
    T.eq(InputRouter.currentModifierMask(), 1 + 4)
end

function M.test_dispatch_no_handlers_returns_false()
    setup()
    T.falsy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
end

-- ? help overlay ------------------------------------------------------------

local VK_OEM_2 = 191
local MOD_SHIFT = 1

function M.test_shift_question_opens_help()
    setup()
    local opened = 0
    Help = {
        open = function()
            opened = opened + 1
        end,
    }
    HandlerStack.push({ name = "base", helpEntries = {} })
    T.truthy(InputRouter.dispatch(VK_OEM_2, MOD_SHIFT, WM_KEYDOWN))
    T.eq(opened, 1)
    Help = nil
end

function M.test_shift_question_skipped_when_help_on_top()
    setup()
    local opened = 0
    Help = {
        open = function()
            opened = opened + 1
        end,
    }
    HandlerStack.push({ name = "base", helpEntries = {} })
    HandlerStack.push({ name = "Help", capturesAllInput = true, helpEntries = {} })
    -- No binding on Help for VK_OEM_2 in this test, but the barrier swallows
    -- it; the key point is Help.open isn't re-entered.
    InputRouter.dispatch(VK_OEM_2, MOD_SHIFT, WM_KEYDOWN)
    T.eq(opened, 0, "Help.open not called when Help is already on top")
    Help = nil
end

function M.test_question_without_shift_not_intercepted()
    setup()
    local opened = 0
    Help = {
        open = function()
            opened = opened + 1
        end,
    }
    HandlerStack.push({ name = "base", helpEntries = {} })
    InputRouter.dispatch(VK_OEM_2, 0, WM_KEYDOWN)
    T.eq(opened, 0, "bare / (no shift) is not the help hotkey")
    Help = nil
end

function M.test_shift_question_without_Help_module_warns()
    setup()
    local warns = {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    Help = nil
    HandlerStack.push({ name = "base", helpEntries = {} })
    T.truthy(InputRouter.dispatch(VK_OEM_2, MOD_SHIFT, WM_KEYDOWN), "key still consumed even without Help module")
    T.truthy(#warns >= 1)
end

-- Type-ahead search hook ----------------------------------------------------

function M.test_search_hook_consumes_when_handler_consumes()
    setup()
    local seen = {}
    HandlerStack.push({
        name = "menu",
        capturesAllInput = true,
        helpEntries = {},
        bindings = {},
        handleSearchInput = function(self, vk, mods)
            seen[#seen + 1] = { vk = vk, mods = mods }
            return true
        end,
    })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(#seen, 1)
    T.eq(seen[1].vk, 65)
end

function M.test_search_hook_falls_through_when_not_consumed()
    setup()
    local bindingFired = 0
    HandlerStack.push({
        name = "menu",
        capturesAllInput = true,
        helpEntries = {},
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    bindingFired = bindingFired + 1
                end,
            },
        },
        handleSearchInput = function()
            return false
        end,
    })
    T.truthy(InputRouter.dispatch(65, 0, WM_KEYDOWN))
    T.eq(bindingFired, 1, "binding still fires when search declines")
end

function M.test_search_hook_only_on_top_handler()
    setup()
    local bottomSearch = 0
    HandlerStack.push({
        name = "bottom",
        helpEntries = {},
        bindings = {},
        handleSearchInput = function()
            bottomSearch = bottomSearch + 1
            return true
        end,
    })
    HandlerStack.push({
        name = "top",
        capturesAllInput = true,
        helpEntries = {},
        bindings = {},
    })
    InputRouter.dispatch(65, 0, WM_KEYDOWN)
    T.eq(bottomSearch, 0, "search hook only fires on the top handler")
end

function M.test_search_hook_not_called_on_syskeydown()
    setup()
    local called = 0
    HandlerStack.push({
        name = "menu",
        capturesAllInput = true,
        helpEntries = {},
        bindings = {},
        handleSearchInput = function()
            called = called + 1
            return true
        end,
    })
    -- Alt-chorded keys arrive as WM_SYSKEYDOWN and must not feed type-ahead.
    InputRouter.dispatch(65, 4, WM_SYSKEYDOWN)
    T.eq(called, 0)
end

function M.test_search_hook_error_logged_and_falls_through()
    setup()
    local bindingFired = 0
    HandlerStack.push({
        name = "menu",
        capturesAllInput = true,
        helpEntries = {},
        bindings = {
            {
                key = 65,
                mods = 0,
                fn = function()
                    bindingFired = bindingFired + 1
                end,
            },
        },
        handleSearchInput = function()
            error("boom")
        end,
    })
    InputRouter.dispatch(65, 0, WM_KEYDOWN)
    T.truthy(#errors >= 1)
    T.eq(bindingFired, 1, "binding still fires after search hook error")
end

return M

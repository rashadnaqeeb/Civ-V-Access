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
    civvaccess_shared.muted = false
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

-- Hotseat-mute toggle (Ctrl+Shift+F12) -----------------------------------
-- Order invariant: pause announcement speaks BEFORE the flag flips,
-- resume announcement speaks AFTER the flag clears. Either way, the
-- speak must happen on the unmuted side of the transition so
-- SpeechPipeline's own gate doesn't swallow it.

local VK_F12 = 123
local MOD_CTRL_SHIFT = 1 + 2

local function setupMute()
    setup()
    UI.CtrlKeyDown = function()
        return true
    end
    UI.ShiftKeyDown = function()
        return true
    end
    civvaccess_shared.muted = false
    local clock = 0
    InputRouter._timeSource = function()
        return clock
    end
    local spoken = {}
    SpeechPipeline = {
        speakInterrupt = function(text)
            spoken[#spoken + 1] = { text = text, mutedAtSpeak = civvaccess_shared.muted }
        end,
    }
    Text = {
        key = function(k)
            return k
        end,
    }
    local function advance(dt)
        clock = clock + dt
    end
    return spoken, advance
end

function M.test_mute_toggle_enters_mute_and_speaks_paused_before_flip()
    local spoken, advance = setupMute()
    advance(1)
    T.truthy(InputRouter.dispatch(VK_F12, MOD_CTRL_SHIFT, WM_KEYDOWN))
    T.truthy(civvaccess_shared.muted, "muted flag set on enter")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "TXT_KEY_CIVVACCESS_MUTE_PAUSED")
    T.falsy(
        spoken[1].mutedAtSpeak,
        "flag must be unset at speak time so SpeechPipeline's own gate doesn't swallow the announcement"
    )
end

function M.test_mute_toggle_exits_mute_and_speaks_resumed_after_flip()
    local spoken, advance = setupMute()
    civvaccess_shared.muted = true
    advance(1)
    T.truthy(InputRouter.dispatch(VK_F12, MOD_CTRL_SHIFT, WM_KEYDOWN))
    T.falsy(civvaccess_shared.muted, "muted flag cleared on exit")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "TXT_KEY_CIVVACCESS_MUTE_RESUMED")
    T.falsy(
        spoken[1].mutedAtSpeak,
        "flag must be cleared before speak so SpeechPipeline's own gate doesn't swallow the announcement"
    )
end

function M.test_mute_toggle_debounces_key_repeat()
    local _, advance = setupMute()
    InputRouter.dispatch(VK_F12, MOD_CTRL_SHIFT, WM_KEYDOWN)
    T.truthy(civvaccess_shared.muted, "first press enters mute")
    advance(0.05)
    InputRouter.dispatch(VK_F12, MOD_CTRL_SHIFT, WM_KEYDOWN)
    T.truthy(civvaccess_shared.muted, "repeat within debounce window does not flip")
    advance(0.5)
    InputRouter.dispatch(VK_F12, MOD_CTRL_SHIFT, WM_KEYDOWN)
    T.falsy(civvaccess_shared.muted, "press past debounce window does flip")
end

function M.test_dispatch_is_short_circuited_while_muted()
    setupMute()
    civvaccess_shared.muted = true
    UI.CtrlKeyDown = function()
        return false
    end
    UI.ShiftKeyDown = function()
        return false
    end
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
    T.falsy(InputRouter.dispatch(65, 0, WM_KEYDOWN), "muted dispatch returns false to fall through to engine")
    T.eq(fired, 0, "no binding fires while muted")
end

-- Numpad mirror -------------------------------------------------------------
-- VK_NUMPAD7..3 mirror the QWE/ASD/ZXC cluster (S=5 anchors the center).
-- Implemented as a second-pass binding walk in dispatch -- so a numpad
-- press fires whatever the equivalent letter binding does, with whatever
-- modifier the user is holding. Direct VK_NUMPAD bindings (NumberEntry)
-- still win because they fire on the first pass.

local function pushLetterBinding(name, key, mods, fired)
    HandlerStack.push({
        name = name,
        bindings = {
            {
                key = key,
                mods = mods,
                fn = function()
                    fired.count = fired.count + 1
                end,
            },
        },
    })
end

function M.test_numpad7_mirrors_Q_when_no_VK_NUMPAD7_binding()
    setup()
    local fired = { count = 0 }
    pushLetterBinding("Baseline", 81, 0, fired) -- Keys.Q
    T.truthy(InputRouter.dispatch(103, 0, WM_KEYDOWN), "VK_NUMPAD7 fires Q binding")
    T.eq(fired.count, 1)
end

function M.test_numpad5_mirrors_S()
    setup()
    local fired = { count = 0 }
    pushLetterBinding("Baseline", 83, 0, fired) -- Keys.S
    T.truthy(InputRouter.dispatch(101, 0, WM_KEYDOWN), "VK_NUMPAD5 fires S binding")
    T.eq(fired.count, 1)
end

function M.test_numpad_mirror_carries_shift_modifier()
    setup()
    local fired = { count = 0 }
    pushLetterBinding("Surveyor", 81, 1, fired) -- Shift+Q
    T.truthy(InputRouter.dispatch(103, 1, WM_KEYDOWN), "Shift+VK_NUMPAD7 fires Shift+Q")
    T.eq(fired.count, 1)
end

function M.test_numpad_mirror_carries_alt_modifier()
    setup()
    local fired = { count = 0 }
    pushLetterBinding("UnitControl", 81, 4, fired) -- Alt+Q
    T.truthy(InputRouter.dispatch(103, 4, WM_SYSKEYDOWN), "Alt+VK_NUMPAD7 fires Alt+Q on WM_SYSKEYDOWN")
    T.eq(fired.count, 1)
end

function M.test_numpad_mirror_carries_ctrl_modifier()
    setup()
    local fired = { count = 0 }
    pushLetterBinding("Bookmarks", 83, 2, fired) -- Ctrl+S
    T.truthy(InputRouter.dispatch(101, 2, WM_KEYDOWN), "Ctrl+VK_NUMPAD5 fires Ctrl+S")
    T.eq(fired.count, 1)
end

function M.test_direct_numpad_binding_wins_over_letter_mirror()
    -- NumberEntry binds VK_NUMPAD0..9 directly. The first-pass binding walk
    -- must fire that binding, NOT remap to the letter equivalent.
    setup()
    local numpadFired = { count = 0 }
    local letterFired = { count = 0 }
    HandlerStack.push({
        name = "Baseline",
        capturesAllInput = true,
        bindings = {
            {
                key = 83, -- Keys.S
                mods = 0,
                fn = function()
                    letterFired.count = letterFired.count + 1
                end,
            },
        },
    })
    HandlerStack.push({
        name = "NumberEntry",
        capturesAllInput = true,
        bindings = {
            {
                key = 101, -- VK_NUMPAD5
                mods = 0,
                fn = function()
                    numpadFired.count = numpadFired.count + 1
                end,
            },
        },
    })
    T.truthy(InputRouter.dispatch(101, 0, WM_KEYDOWN))
    T.eq(numpadFired.count, 1, "direct numpad binding fires")
    T.eq(letterFired.count, 0, "letter mirror does not fire underneath")
end

function M.test_numpad_mirror_only_when_first_pass_misses_with_modifier()
    -- A direct numpad binding for plain Numpad5 must NOT short-circuit a
    -- Ctrl+Numpad5 press: first pass with mods=2 misses the plain-mods=0
    -- binding, then the mirror runs against Ctrl+S.
    setup()
    local plainNumpadFired = { count = 0 }
    local ctrlLetterFired = { count = 0 }
    HandlerStack.push({
        name = "Baseline",
        bindings = {
            {
                key = 101, -- VK_NUMPAD5 plain
                mods = 0,
                fn = function()
                    plainNumpadFired.count = plainNumpadFired.count + 1
                end,
            },
            {
                key = 83, -- Keys.S, Ctrl
                mods = 2,
                fn = function()
                    ctrlLetterFired.count = ctrlLetterFired.count + 1
                end,
            },
        },
    })
    T.truthy(InputRouter.dispatch(101, 2, WM_KEYDOWN))
    T.eq(plainNumpadFired.count, 0, "plain-Numpad binding does not fire under Ctrl")
    T.eq(ctrlLetterFired.count, 1, "Ctrl+Numpad5 routes to Ctrl+S")
end

function M.test_unmapped_numpad_with_no_binding_returns_consumed_through_barrier()
    -- VK_NUMPAD0 is not in the mirror table (only 1-9 mirror the cluster).
    -- A bare Numpad0 with no binding should still be swallowed by the
    -- barrier so it doesn't leak to the engine.
    setup()
    HandlerStack.push({
        name = "Baseline",
        capturesAllInput = true,
        bindings = {},
    })
    T.truthy(InputRouter.dispatch(96, 0, WM_KEYDOWN), "Numpad0 swallowed by barrier")
end

function M.test_numpad_mirror_falls_through_when_letter_also_unbound()
    -- No handler binds either VK_NUMPAD7 or Keys.Q. Without a barrier the
    -- press should fall through (return false) so the engine can see it.
    setup()
    HandlerStack.push({
        name = "Empty",
        bindings = {},
    })
    T.falsy(InputRouter.dispatch(103, 0, WM_KEYDOWN), "unbound Numpad7 falls through")
end

function M.test_numpad_mirror_respects_capturesAllInput_when_letter_also_unbound()
    -- Numpad7 with no Q binding behind a capturesAllInput handler still
    -- swallows. The mirror retry doesn't change the consumed return.
    setup()
    HandlerStack.push({
        name = "Baseline",
        capturesAllInput = true,
        bindings = {},
    })
    T.truthy(InputRouter.dispatch(103, 0, WM_KEYDOWN), "barrier swallow survives mirror retry")
end

return M

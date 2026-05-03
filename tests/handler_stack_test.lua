-- HandlerStack tests. Callback counts observed via closures on the
-- handler tables; Log.* captured via monkey-patch.

local T = require("support")
local M = {}

local warns, errors

local function setup()
    warns, errors = {}, {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    Log.error = function(msg)
        errors[#errors + 1] = msg
    end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    HandlerStack._reset()
    -- Tests in this suite assert per-handler help-entry counts. The
    -- production module ships with a non-empty commonHelpEntries (F12 →
    -- Settings); reset to empty here so each test sees only what it
    -- explicitly pushes. Tests that exercise commonHelpEntries set it
    -- themselves and reset to {} on the way out.
    HandlerStack.commonHelpEntries = {}
end

local function makeHandler(name, opts)
    opts = opts or {}
    local h = { name = name, activate = 0, deactivate = 0 }
    h.capturesAllInput = opts.capturesAllInput or false
    h.bindings = opts.bindings
    h.helpEntries = opts.helpEntries
    h.onActivate = function(self)
        self.activate = self.activate + 1
    end
    h.onDeactivate = function(self)
        self.deactivate = self.deactivate + 1
    end
    if opts.activateError then
        h.onActivate = function()
            error("boom")
        end
    end
    return h
end

-- Basic push/pop --------------------------------------------------------

function M.test_push_appends_and_activates()
    setup()
    local a = makeHandler("a")
    T.truthy(HandlerStack.push(a))
    T.eq(HandlerStack.count(), 1)
    T.eq(HandlerStack.active(), a)
    T.eq(a.activate, 1)
end

function M.test_pop_removes_and_deactivates_top()
    setup()
    local a = makeHandler("a")
    local b = makeHandler("b")
    HandlerStack.push(a)
    HandlerStack.push(b)
    HandlerStack.pop()
    T.eq(HandlerStack.count(), 1)
    T.eq(b.deactivate, 1)
    T.eq(a.activate, 2, "newly exposed top reactivates")
end

function M.test_pop_empty_warns_does_not_error()
    setup()
    local got = HandlerStack.pop()
    T.eq(got, nil)
    T.truthy(#warns >= 1)
end

function M.test_push_nil_warns()
    setup()
    T.falsy(HandlerStack.push(nil))
    T.truthy(#warns >= 1)
end

function M.test_push_onactivate_failure_does_not_add()
    setup()
    local a = makeHandler("a", { activateError = true })
    local pushed = HandlerStack.push(a)
    T.falsy(pushed)
    T.eq(HandlerStack.count(), 0)
    T.truthy(#errors >= 1)
end

-- insertAt --------------------------------------------------------------

function M.test_insertAt_into_empty_stack_activates()
    setup()
    local a = makeHandler("a")
    T.truthy(HandlerStack.insertAt(a, 1))
    T.eq(HandlerStack.count(), 1)
    T.eq(HandlerStack.active(), a)
    T.eq(a.activate, 1, "becoming top fires onActivate")
end

function M.test_insertAt_below_top_does_not_activate()
    setup()
    local existing = makeHandler("existing")
    HandlerStack.push(existing)
    local floor = makeHandler("floor")
    T.truthy(HandlerStack.insertAt(floor, 1))
    T.eq(HandlerStack.count(), 2)
    T.eq(HandlerStack.active(), existing, "top unchanged")
    T.eq(floor.activate, 0, "below-top insert does not fire onActivate")
    T.eq(existing.activate, 1, "previous top not re-fired")
    T.eq(HandlerStack.at(1), floor)
    T.eq(HandlerStack.at(2), existing)
end

function M.test_insertAt_middle_position_does_not_activate()
    setup()
    local a, c = makeHandler("a"), makeHandler("c")
    HandlerStack.push(a)
    HandlerStack.push(c)
    local b = makeHandler("b")
    T.truthy(HandlerStack.insertAt(b, 2))
    T.eq(HandlerStack.count(), 3)
    T.eq(HandlerStack.at(1), a)
    T.eq(HandlerStack.at(2), b)
    T.eq(HandlerStack.at(3), c)
    T.eq(b.activate, 0, "middle insert does not activate")
    T.eq(c.activate, 1, "previous top not re-fired")
end

function M.test_insertAt_count_plus_one_acts_like_push()
    setup()
    local a = makeHandler("a")
    HandlerStack.push(a)
    local b = makeHandler("b")
    T.truthy(HandlerStack.insertAt(b, 2))
    T.eq(HandlerStack.active(), b)
    T.eq(b.activate, 1, "top-equivalent insert fires onActivate")
end

function M.test_insertAt_idx_out_of_range_warns_and_refuses()
    setup()
    local a = makeHandler("a")
    T.falsy(HandlerStack.insertAt(a, 0), "idx 0 rejected")
    T.falsy(HandlerStack.insertAt(a, 2), "idx beyond count+1 rejected")
    T.eq(HandlerStack.count(), 0)
    T.truthy(#warns >= 2)
end

function M.test_insertAt_nil_handler_warns()
    setup()
    T.falsy(HandlerStack.insertAt(nil, 1))
    T.truthy(#warns >= 1)
end

function M.test_insertAt_onactivate_failure_does_not_add()
    setup()
    local a = makeHandler("a", { activateError = true })
    T.falsy(HandlerStack.insertAt(a, 1))
    T.eq(HandlerStack.count(), 0)
    T.truthy(#errors >= 1)
end

function M.test_insertAt_below_existing_popup_preserves_popup_active()
    -- Mirrors the hotseat-boot scenario: a popup (PlayerChange) is on the
    -- stack when Boot runs; inserting Baseline/Scanner at the bottom must
    -- leave the popup as the active handler with no spurious activations.
    setup()
    local popup = makeHandler("popup")
    HandlerStack.push(popup)
    T.eq(popup.activate, 1)
    local baseline = makeHandler("baseline")
    local scanner = makeHandler("scanner")
    T.truthy(HandlerStack.insertAt(baseline, 1))
    T.truthy(HandlerStack.insertAt(scanner, 2))
    T.eq(HandlerStack.count(), 3)
    T.eq(HandlerStack.at(1), baseline)
    T.eq(HandlerStack.at(2), scanner)
    T.eq(HandlerStack.at(3), popup)
    T.eq(HandlerStack.active(), popup, "popup still active")
    T.eq(baseline.activate, 0)
    T.eq(scanner.activate, 0)
    T.eq(popup.activate, 1, "popup not re-fired by inserts beneath it")
end

-- replace ---------------------------------------------------------------

function M.test_replace_deactivates_then_activates()
    setup()
    local a = makeHandler("a")
    local b = makeHandler("b")
    HandlerStack.push(a)
    HandlerStack.replace(b)
    T.eq(HandlerStack.count(), 1)
    T.eq(a.deactivate, 1)
    T.eq(b.activate, 1)
    T.eq(a.activate, 1, "no intermediate reactivation")
end

-- popAbove --------------------------------------------------------------

function M.test_popAbove_removes_only_above_target()
    setup()
    local a, b, c = makeHandler("a"), makeHandler("b"), makeHandler("c")
    HandlerStack.push(a)
    HandlerStack.push(b)
    HandlerStack.push(c)
    T.truthy(HandlerStack.popAbove(a))
    T.eq(HandlerStack.count(), 1)
    T.eq(HandlerStack.active(), a)
    T.eq(b.deactivate, 1)
    T.eq(c.deactivate, 1)
    T.eq(a.activate, 2, "target reactivated on re-exposure")
end

function M.test_popAbove_missing_target_returns_false()
    setup()
    local a = makeHandler("a")
    local b = makeHandler("b")
    HandlerStack.push(a)
    T.falsy(HandlerStack.popAbove(b))
    T.eq(HandlerStack.count(), 1)
end

-- removeByName ----------------------------------------------------------

function M.test_removeByName_top_reactivates_new_top()
    setup()
    local a, b = makeHandler("a"), makeHandler("b")
    HandlerStack.push(a)
    HandlerStack.push(b)
    T.truthy(HandlerStack.removeByName("b"))
    T.eq(b.deactivate, 1)
    T.eq(a.activate, 2)
end

function M.test_removeByName_middle_does_not_reactivate()
    setup()
    local a, b, c = makeHandler("a"), makeHandler("b"), makeHandler("c")
    HandlerStack.push(a)
    HandlerStack.push(b)
    HandlerStack.push(c)
    T.truthy(HandlerStack.removeByName("b"))
    T.eq(b.deactivate, 1)
    T.eq(c.activate, 1, "top unchanged, no reactivation")
    T.eq(a.activate, 1)
end

function M.test_removeByName_absent_returns_false()
    setup()
    T.falsy(HandlerStack.removeByName("ghost"))
end

-- drainAndRemove --------------------------------------------------------

local function makeEscSub(name, escFn)
    return {
        name = name,
        bindings = {
            { key = Keys.VK_ESCAPE, mods = 0, fn = escFn, description = "Esc" },
        },
    }
end

function M.test_drainAndRemove_finds_and_removes_named()
    setup()
    local a = makeHandler("a")
    local target = makeHandler("target")
    HandlerStack.push(a)
    HandlerStack.push(target)
    T.truthy(HandlerStack.drainAndRemove("target"))
    T.eq(HandlerStack.count(), 1)
    T.eq(a.activate, 2, "underneath reactivates after target removed")
end

function M.test_drainAndRemove_drains_subs_via_their_esc()
    setup()
    local target = makeHandler("target")
    local subEscCalls = 0
    -- Sub Esc pops itself, mirroring how BaseMenuEditMode's exit binding
    -- actually behaves: it removes the sub from the stack, leaving the
    -- host as the new top.
    local sub = makeEscSub("sub", function()
        subEscCalls = subEscCalls + 1
        HandlerStack.pop()
    end)
    HandlerStack.push(target)
    HandlerStack.push(sub)
    T.truthy(HandlerStack.drainAndRemove("target"))
    T.eq(subEscCalls, 1, "sub's Esc binding ran once")
    T.eq(HandlerStack.count(), 0)
end

function M.test_drainAndRemove_hard_pops_when_sub_has_no_esc()
    setup()
    local target = makeHandler("target")
    local sub = makeHandler("sub") -- no bindings table
    HandlerStack.push(target)
    HandlerStack.push(sub)
    T.truthy(HandlerStack.drainAndRemove("target"))
    T.eq(sub.deactivate, 1, "sub deactivated via hard pop fallback")
    T.eq(HandlerStack.count(), 0)
end

function M.test_drainAndRemove_hard_pops_when_sub_esc_throws()
    setup()
    local target = makeHandler("target")
    local sub = makeEscSub("sub", function()
        error("boom")
    end)
    HandlerStack.push(target)
    HandlerStack.push(sub)
    T.truthy(HandlerStack.drainAndRemove("target"))
    T.eq(HandlerStack.count(), 0)
    T.truthy(#errors >= 1, "throw logged via Log.error")
end

function M.test_drainAndRemove_absent_returns_false()
    setup()
    local a = makeHandler("a")
    HandlerStack.push(a)
    T.falsy(HandlerStack.drainAndRemove("ghost"))
    T.eq(HandlerStack.count(), 1, "stack untouched on miss")
end

function M.test_drainAndRemove_no_reactivate()
    setup()
    local a = makeHandler("a")
    local target = makeHandler("target")
    HandlerStack.push(a)
    HandlerStack.push(target)
    T.truthy(HandlerStack.drainAndRemove("target", false))
    T.eq(a.activate, 1, "underneath does not reactivate when reactivate=false")
end

-- deactivateAll ---------------------------------------------------------

function M.test_deactivateAll_clears_and_deactivates_each()
    setup()
    local a, b = makeHandler("a"), makeHandler("b")
    HandlerStack.push(a)
    HandlerStack.push(b)
    HandlerStack.deactivateAll()
    T.eq(HandlerStack.count(), 0)
    T.eq(a.deactivate, 1)
    T.eq(b.deactivate, 1)
end

-- collectHelpEntries ----------------------------------------------------

function M.test_collectHelpEntries_reads_helpEntries_only()
    setup()
    local a = makeHandler("a", {
        helpEntries = {
            { keyLabel = "Up/Down", description = "Navigate" },
            { keyLabel = "Enter", description = "Activate" },
        },
    })
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
    T.eq(entries[1].keyLabel, "Up/Down")
end

function M.test_collectHelpEntries_ignores_bindings_without_helpEntries()
    setup()
    local a = makeHandler("a", { bindings = {
        { key = 1, mods = 0, description = "one" },
    } })
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 0, "bindings are not a help source")
end

function M.test_push_warns_when_bindings_lack_helpEntries()
    setup()
    local a = makeHandler("a", { bindings = {
        { key = 1, mods = 0, description = "one" },
    } })
    HandlerStack.push(a)
    T.truthy(#warns >= 1, "bindings without helpEntries logs a warning")
end

function M.test_push_does_not_warn_when_empty_helpEntries_declared()
    setup()
    local a = makeHandler("a", {
        bindings = { { key = 1, mods = 0, description = "one" } },
        helpEntries = {},
    })
    HandlerStack.push(a)
    T.eq(#warns, 0, "explicit empty helpEntries opts out cleanly")
end

function M.test_collectHelpEntries_dedups_by_keyLabel_top_wins()
    setup()
    local a = makeHandler(
        "a",
        { helpEntries = {
            { keyLabel = "Escape", description = "Back to previous screen" },
        } }
    )
    local b = makeHandler("b", {
        helpEntries = {
            { keyLabel = "Escape", description = "Close" },
            { keyLabel = "Enter", description = "Activate" },
        },
    })
    HandlerStack.push(a)
    HandlerStack.push(b)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
    T.eq(entries[1].description, "Close", "topmost keyLabel wins")
end

function M.test_collectHelpEntries_stops_after_capture_barrier()
    setup()
    local a = makeHandler("a", { helpEntries = {
        { keyLabel = "A", description = "a" },
    } })
    local b = makeHandler("b", {
        capturesAllInput = true,
        helpEntries = { { keyLabel = "B", description = "b" } },
    })
    local c = makeHandler("c", { helpEntries = {
        { keyLabel = "C", description = "c" },
    } })
    HandlerStack.push(a)
    HandlerStack.push(b)
    HandlerStack.push(c)
    local entries = HandlerStack.collectHelpEntries()
    -- c (top) and b (barrier, inclusive) contribute; a is masked.
    T.eq(#entries, 2)
end

function M.test_collectHelpEntries_appends_commonHelpEntries()
    setup()
    HandlerStack.commonHelpEntries = {
        { keyLabel = "F12", description = "global toggle" },
    }
    local a = makeHandler("a", { helpEntries = {
        { keyLabel = "Up/Down", description = "nav" },
    } })
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
    T.eq(entries[2].keyLabel, "F12", "common entries append at tail")
    HandlerStack.commonHelpEntries = {}
end

function M.test_collectHelpEntries_common_does_not_duplicate_handler_label()
    setup()
    HandlerStack.commonHelpEntries = {
        { keyLabel = "Escape", description = "global esc" },
    }
    local a = makeHandler("a", { helpEntries = {
        { keyLabel = "Escape", description = "handler esc" },
    } })
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 1)
    T.eq(entries[1].description, "handler esc", "handler wins over common")
    HandlerStack.commonHelpEntries = {}
end

-- purgeDeadEnv ----------------------------------------------------------
--
-- Reproduces the FrontEnd-to-InGame skin transition that wipes the
-- WaitingForPlayers Context env: the handler's _envProbe closure was
-- captured in that env, so once the env's globals go nil the probe
-- returns nil/false and the handler is dead.

function M.test_purgeDeadEnv_removes_dead_top()
    setup()
    local alive = makeHandler("alive")
    alive._envProbe = function() return true end
    local dead = makeHandler("dead")
    dead._envProbe = function() return nil end
    HandlerStack.push(alive)
    HandlerStack.push(dead)
    local removed = HandlerStack.purgeDeadEnv()
    T.eq(removed, 1)
    T.eq(HandlerStack.count(), 1)
    T.eq(HandlerStack.active(), alive)
end

function M.test_purgeDeadEnv_removes_buried_dead_entry()
    setup()
    local dead = makeHandler("dead")
    dead._envProbe = function() return false end
    local alive = makeHandler("alive")
    alive._envProbe = function() return true end
    HandlerStack.push(dead)
    HandlerStack.push(alive)
    local removed = HandlerStack.purgeDeadEnv()
    T.eq(removed, 1)
    T.eq(HandlerStack.count(), 1)
    T.eq(HandlerStack.active(), alive)
end

function M.test_purgeDeadEnv_no_probe_treated_as_alive()
    setup()
    local h = makeHandler("noprobe")
    HandlerStack.push(h)
    T.eq(HandlerStack.purgeDeadEnv(), 0)
    T.eq(HandlerStack.count(), 1)
end

function M.test_purgeDeadEnv_probe_throws_treated_as_dead()
    setup()
    local h = makeHandler("throws")
    h._envProbe = function() error("dead env") end
    HandlerStack.push(h)
    T.eq(HandlerStack.purgeDeadEnv(), 1)
    T.eq(HandlerStack.count(), 0)
end

function M.test_purgeDeadEnv_skips_onDeactivate_on_dead()
    -- onDeactivate is itself a closure in the dead env; invoking it would
    -- throw on its first global access. purgeDeadEnv must NOT call it.
    setup()
    local h = makeHandler("dead")
    h._envProbe = function() return false end
    h.onDeactivate = function() error("would crash in dead env") end
    HandlerStack.push(h)
    HandlerStack.purgeDeadEnv()
    T.eq(HandlerStack.count(), 0)
    T.eq(#errors, 0, "onDeactivate must not run on dead-env handlers")
end

function M.test_purgeDeadEnv_logs_warning_per_eviction()
    setup()
    local d1 = makeHandler("d1")
    d1._envProbe = function() return false end
    local d2 = makeHandler("d2")
    d2._envProbe = function() return false end
    HandlerStack.push(d1)
    HandlerStack.push(d2)
    HandlerStack.purgeDeadEnv()
    T.eq(#warns, 2)
end

return M

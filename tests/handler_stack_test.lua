-- HandlerStack tests. Callback counts observed via closures on the
-- handler tables; Log.* captured via monkey-patch.

local T = require("support")
local M = {}

local warns, errors

local function setup()
    warns, errors = {}, {}
    Log.warn  = function(msg) warns[#warns + 1] = msg end
    Log.error = function(msg) errors[#errors + 1] = msg end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    HandlerStack._reset()
end

local function makeHandler(name, opts)
    opts = opts or {}
    local h = { name = name, activate = 0, deactivate = 0 }
    h.capturesAllInput = opts.capturesAllInput or false
    h.bindings = opts.bindings
    h.helpEntries = opts.helpEntries
    h.onActivate = function(self) self.activate = self.activate + 1 end
    h.onDeactivate = function(self) self.deactivate = self.deactivate + 1 end
    if opts.activateError then
        h.onActivate = function() error("boom") end
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
    HandlerStack.push(a); HandlerStack.push(b); HandlerStack.push(c)
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
    HandlerStack.push(a); HandlerStack.push(b)
    T.truthy(HandlerStack.removeByName("b"))
    T.eq(b.deactivate, 1)
    T.eq(a.activate, 2)
end

function M.test_removeByName_middle_does_not_reactivate()
    setup()
    local a, b, c = makeHandler("a"), makeHandler("b"), makeHandler("c")
    HandlerStack.push(a); HandlerStack.push(b); HandlerStack.push(c)
    T.truthy(HandlerStack.removeByName("b"))
    T.eq(b.deactivate, 1)
    T.eq(c.activate, 1, "top unchanged, no reactivation")
    T.eq(a.activate, 1)
end

function M.test_removeByName_absent_returns_false()
    setup()
    T.falsy(HandlerStack.removeByName("ghost"))
end

-- deactivateAll ---------------------------------------------------------

function M.test_deactivateAll_clears_and_deactivates_each()
    setup()
    local a, b = makeHandler("a"), makeHandler("b")
    HandlerStack.push(a); HandlerStack.push(b)
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
            { keyLabel = "Enter",   description = "Activate" },
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
    }})
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 0, "bindings are not a help source")
end

function M.test_push_warns_when_bindings_lack_helpEntries()
    setup()
    local a = makeHandler("a", { bindings = {
        { key = 1, mods = 0, description = "one" },
    }})
    HandlerStack.push(a)
    T.truthy(#warns >= 1, "bindings without helpEntries logs a warning")
end

function M.test_push_does_not_warn_when_empty_helpEntries_declared()
    setup()
    local a = makeHandler("a", {
        bindings    = { { key = 1, mods = 0, description = "one" } },
        helpEntries = {},
    })
    HandlerStack.push(a)
    T.eq(#warns, 0, "explicit empty helpEntries opts out cleanly")
end

function M.test_collectHelpEntries_dedups_by_keyLabel_top_wins()
    setup()
    local a = makeHandler("a", { helpEntries = {
        { keyLabel = "Escape", description = "Back to previous screen" },
    }})
    local b = makeHandler("b", { helpEntries = {
        { keyLabel = "Escape", description = "Close" },
        { keyLabel = "Enter",  description = "Activate" },
    }})
    HandlerStack.push(a); HandlerStack.push(b)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
    T.eq(entries[1].description, "Close", "topmost keyLabel wins")
end

function M.test_collectHelpEntries_stops_after_capture_barrier()
    setup()
    local a = makeHandler("a", { helpEntries = {
        { keyLabel = "A", description = "a" },
    }})
    local b = makeHandler("b", {
        capturesAllInput = true,
        helpEntries = { { keyLabel = "B", description = "b" } },
    })
    local c = makeHandler("c", { helpEntries = {
        { keyLabel = "C", description = "c" },
    }})
    HandlerStack.push(a); HandlerStack.push(b); HandlerStack.push(c)
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
    }})
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
    }})
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 1)
    T.eq(entries[1].description, "handler esc", "handler wins over common")
    HandlerStack.commonHelpEntries = {}
end

return M

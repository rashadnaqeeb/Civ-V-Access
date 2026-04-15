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
    dofile("src/mod/UI/CivVAccess_HandlerStack.lua")
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

function M.test_collectHelpEntries_derives_from_bindings()
    setup()
    local a = makeHandler("a", { bindings = {
        { key = 1, mods = 0, description = "one" },
        { key = 2, mods = 0, description = "two" },
    }})
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
end

function M.test_collectHelpEntries_dedups_by_key_and_mods()
    setup()
    local a = makeHandler("a", { bindings = {
        { key = 1, mods = 0, description = "lower" },
    }})
    local b = makeHandler("b", { bindings = {
        { key = 1, mods = 0, description = "upper" },
        { key = 2, mods = 0, description = "distinct" },
    }})
    HandlerStack.push(a); HandlerStack.push(b)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
    T.eq(entries[1].description, "upper", "top wins")
end

function M.test_collectHelpEntries_stops_after_capture_barrier()
    setup()
    local a = makeHandler("a", { bindings = { { key = 1, mods = 0 } } })
    local b = makeHandler("b", {
        capturesAllInput = true,
        bindings = { { key = 2, mods = 0 } },
    })
    local c = makeHandler("c", { bindings = { { key = 3, mods = 0 } } })
    HandlerStack.push(a); HandlerStack.push(b); HandlerStack.push(c)
    local entries = HandlerStack.collectHelpEntries()
    -- c (top) and b (barrier, inclusive) contribute; a is masked.
    T.eq(#entries, 2)
end

function M.test_collectHelpEntries_prefers_helpEntries_override()
    setup()
    local a = makeHandler("a", {
        bindings = { { key = 1, mods = 0 } },
        helpEntries = { { key = 99, mods = 0 }, { key = 100, mods = 0 } },
    })
    HandlerStack.push(a)
    local entries = HandlerStack.collectHelpEntries()
    T.eq(#entries, 2)
    T.eq(entries[1].key, 99)
end

return M

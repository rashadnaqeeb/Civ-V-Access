-- CursorActivate enumeration tests. Exercises _buildEntries against fake
-- plots + units to confirm the entry list honors the documented rules:
-- city first, then active-player military units, then active-player
-- civilian units, with invisible / cargo / foreign-owner units filtered
-- out and air units included. The BaseMenu install path (run's modal
-- push) is not covered offline -- HandlerStack push semantics are
-- covered by handler_stack_test; this suite is just about what goes
-- into the picker.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/InGame/CivVAccess_CursorActivate.lua")

    -- Deterministic label stubs. The real CitySpeech.identity /
    -- UnitSpeech.info compose long strings that depend on dozens of
    -- game-data tables; this suite only asserts on entry kind / order,
    -- so a tag-style label keeps fixtures minimal.
    CitySpeech = {
        identity = function(city)
            return "city:" .. city:GetName()
        end,
    }
    UnitSpeech = {
        info = function(unit)
            return "unit:" .. unit:GetNameKey()
        end,
    }

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end
end

function M.test_empty_plot_produces_no_entries()
    setup()
    local p = T.fakePlot()
    T.eq(#CursorActivate._buildEntries(p), 0)
end

function M.test_city_only_produces_single_city_entry()
    setup()
    local city = T.fakeCity({ name = "Rome" })
    local p = T.fakePlot({ isCity = true, city = city })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 1)
    T.eq(entries[1].kind, "city")
    T.eq(entries[1].label, "city:Rome")
end

function M.test_own_military_only()
    setup()
    local warrior = T.fakeUnit({ nameKey = "Warrior", combat = true })
    local p = T.fakePlot({ units = { warrior } })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 1)
    T.eq(entries[1].kind, "unit")
    T.eq(entries[1].label, "unit:Warrior")
end

function M.test_own_civilian_only()
    setup()
    local worker = T.fakeUnit({ nameKey = "Worker", combat = false })
    local p = T.fakePlot({ units = { worker } })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 1)
    T.eq(entries[1].kind, "unit")
    T.eq(entries[1].label, "unit:Worker")
end

function M.test_city_then_military_then_civilian_ordering()
    -- Plot order here intentionally shuffles the units: civilian before
    -- military in the underlying plot's unit list. buildEntries must
    -- reorder so military precedes civilian regardless of plot order,
    -- and city always leads.
    setup()
    local city = T.fakeCity({ name = "Rome" })
    local settler = T.fakeUnit({ nameKey = "Settler", combat = false })
    local warrior = T.fakeUnit({ nameKey = "Warrior", combat = true })
    local p = T.fakePlot({ isCity = true, city = city, units = { settler, warrior } })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 3)
    T.eq(entries[1].kind, "city")
    T.eq(entries[1].label, "city:Rome")
    T.eq(entries[2].kind, "unit")
    T.eq(entries[2].label, "unit:Warrior")
    T.eq(entries[3].kind, "unit")
    T.eq(entries[3].label, "unit:Settler")
end

function M.test_multiple_military_units_listed_individually()
    -- Two own military units on a plot (pre-move stack) must both
    -- appear as distinct entries rather than collapsing.
    setup()
    local scout = T.fakeUnit({ nameKey = "Scout", combat = true })
    local warrior = T.fakeUnit({ nameKey = "Warrior", combat = true })
    local p = T.fakePlot({ units = { scout, warrior } })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 2)
    T.eq(entries[1].label, "unit:Scout")
    T.eq(entries[2].label, "unit:Warrior")
end

function M.test_air_unit_included_under_military()
    -- Cursor.topUnitAt excludes air (it's a one-shot "what's here" read
    -- and air-over-land noise would distract), but the Enter picker is
    -- the one surface where the user is choosing a unit to command and
    -- air units are legitimate targets. Verify they're listed.
    setup()
    local bomber = T.fakeUnit({ nameKey = "Bomber", combat = true, domain = DomainTypes.DOMAIN_AIR })
    local p = T.fakePlot({ units = { bomber } })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 1)
    T.eq(entries[1].kind, "unit")
    T.eq(entries[1].label, "unit:Bomber")
end

function M.test_invisible_unit_filtered()
    setup()
    local spy = T.fakeUnit({ nameKey = "Spy", combat = false, invisible = true })
    local p = T.fakePlot({ units = { spy } })
    T.eq(#CursorActivate._buildEntries(p), 0)
end

function M.test_cargo_unit_filtered()
    -- Embarked units in transport (cargo = true) are addressable via
    -- the carrier's unit panel, not directly; keep them out of the
    -- picker so the user can't "select" something that isn't a first-
    -- class unit on the plot.
    setup()
    local passenger = T.fakeUnit({ nameKey = "Warrior", combat = true, cargo = true })
    local p = T.fakePlot({ units = { passenger } })
    T.eq(#CursorActivate._buildEntries(p), 0)
end

function M.test_foreign_unit_not_listed_even_when_visible()
    -- You can't select someone else's unit. Filtering happens at the
    -- picker-build level so the one-entry short-circuit in run() lands
    -- on the city (or nothing) rather than a pickable-looking foreign
    -- unit.
    setup()
    local enemyWarrior = T.fakeUnit({ nameKey = "Warrior", combat = true, owner = 1 })
    local p = T.fakePlot({ units = { enemyWarrior } })
    T.eq(#CursorActivate._buildEntries(p), 0)
end

function M.test_foreign_city_with_own_garrison_lists_both()
    -- Hypothetical but worth nailing down: a captured / recaptured
    -- tile where the plot's city owner is still the foreign player
    -- for this engine tick but we already have units stacked. The
    -- city entry still comes first; own units still list.
    setup()
    local city = T.fakeCity({ name = "Berlin", owner = 1 })
    local warrior = T.fakeUnit({ nameKey = "Warrior", combat = true, owner = 0 })
    local p = T.fakePlot({ isCity = true, city = city, owner = 1, units = { warrior } })
    local entries = CursorActivate._buildEntries(p)
    T.eq(#entries, 2)
    T.eq(entries[1].kind, "city")
    T.eq(entries[1].label, "city:Berlin")
    T.eq(entries[2].kind, "unit")
    T.eq(entries[2].label, "unit:Warrior")
end

return M

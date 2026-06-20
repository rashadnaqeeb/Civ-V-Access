-- SquadRoster: the owner-local store of squad numbers, names, escort flag,
-- and wake mode, persisted through Modding.OpenUserData scoped by map seed
-- plus active player. Each test exercises a path the others don't: allocate
-- picks the lowest free number and reuses gaps, delete forgets an entry
-- without renumbering, rename trims and resets-on-blank, get/set round-trip
-- through a serialize + hydrate cycle (including a name carrying the row /
-- field delimiters), a malformed store row is skipped, and reconcile ensures
-- entries for engine squad numbers the store lost.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    -- The default-name key lives in the squad strings overlay; load it on top
    -- of the InGame baseline run.lua already populated.
    dofile("src/dlc/UI/InGame/CivVAccess_SquadStrings_en_US.lua")

    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.squadRoster = nil

    -- Fresh in-memory user-data store per setup; tests that exercise the
    -- failure path overwrite Modding.OpenUserData, so this restores the
    -- working stub. Pin seed + active player so the storage key is fixed.
    local bucket = {}
    Modding = Modding or {}
    Modding.OpenUserData = function()
        return {
            GetValue = function(key)
                return bucket[key]
            end,
            SetValue = function(key, value)
                bucket[key] = value
            end,
        }
    end
    Network = Network or {}
    Network.GetMapRandSeed = function()
        return 100
    end
    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end

    dofile("src/dlc/UI/InGame/CivVAccess_SquadRoster.lua")
    SquadRoster.hydrateForCurrentGame()
end

-- ===== allocate =====

function M.test_allocate_starts_at_one_and_increments()
    setup()
    T.eq(SquadRoster.allocate(), 1)
    T.eq(SquadRoster.allocate(), 2)
    T.eq(SquadRoster.allocate(), 3)
end

function M.test_allocate_reuses_lowest_free_gap()
    -- Numbers are not renumbered on delete, but a freed number is the lowest
    -- free slot, so the next allocate reuses it rather than always climbing.
    setup()
    SquadRoster.allocate() -- 1
    SquadRoster.allocate() -- 2
    SquadRoster.allocate() -- 3
    SquadRoster.delete(2)
    T.eq(SquadRoster.allocate(), 2, "freed gap must be reused")
    T.eq(SquadRoster.allocate(), 4, "then climb past the existing max")
end

function M.test_allocate_creates_default_entry()
    setup()
    local n = SquadRoster.allocate()
    T.eq(SquadRoster.getEscort(n), false)
    T.eq(SquadRoster.getWakeMode(n), SquadRoster.WAKE_SENTRY)
end

-- ===== delete: no renumber =====

function M.test_delete_drops_entry_without_renumbering()
    setup()
    SquadRoster.allocate() -- 1
    SquadRoster.allocate() -- 2
    SquadRoster.allocate() -- 3
    SquadRoster.delete(2)
    T.eq(SquadRoster.exists(2), false)
    -- 3 stays 3 -- deleting 2 must not slide it down to 2.
    T.eq(SquadRoster.exists(3), true, "surviving squads keep their numbers")
    T.eq(table.concat(SquadRoster.getList(), ","), "1,3")
end

-- ===== rename =====

function M.test_rename_sets_custom_name()
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.rename(n, "Strike Force")
    T.eq(SquadRoster.getName(n), "Strike Force")
end

function M.test_rename_trims_surrounding_whitespace()
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.rename(n, "  Vanguard  ")
    T.eq(SquadRoster.getName(n), "Vanguard")
end

function M.test_rename_blank_resets_to_default()
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.rename(n, "Temp")
    SquadRoster.rename(n, "   ")
    T.eq(SquadRoster.getName(n), "Squad 1", "blank rename must restore the default name")
end

function M.test_getName_default_for_unnamed_squad()
    setup()
    local n = SquadRoster.allocate()
    T.eq(SquadRoster.getName(n), "Squad 1")
end

-- ===== escort / wake settings =====

function M.test_escort_get_set()
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.setEscort(n, true)
    T.eq(SquadRoster.getEscort(n), true)
    SquadRoster.setEscort(n, false)
    T.eq(SquadRoster.getEscort(n), false)
end

function M.test_wakeMode_get_set()
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.setWakeMode(n, SquadRoster.WAKE_ALL)
    T.eq(SquadRoster.getWakeMode(n), SquadRoster.WAKE_ALL)
end

-- ===== persistence round-trip =====

function M.test_settings_round_trip_through_hydrate()
    -- allocate / rename / setEscort / setWakeMode all write through; hydrating
    -- after a wipe of the in-memory table must restore every field.
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.rename(n, "Alpha")
    SquadRoster.setEscort(n, true)
    SquadRoster.setWakeMode(n, SquadRoster.WAKE_EACH)
    SquadRoster.allocate() -- 2, left at defaults
    civvaccess_shared.squadRoster = {}
    SquadRoster.hydrateForCurrentGame()
    T.eq(SquadRoster.getName(1), "Alpha")
    T.eq(SquadRoster.getEscort(1), true)
    T.eq(SquadRoster.getWakeMode(1), SquadRoster.WAKE_EACH)
    T.eq(SquadRoster.exists(2), true)
    T.eq(SquadRoster.getEscort(2), false, "second squad keeps its defaults")
end

function M.test_name_with_delimiters_round_trips()
    -- A name containing the serializer's row / field delimiters must survive
    -- the round trip: the name is percent-encoded so it can't split a row.
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.rename(n, "A,B;C%D")
    civvaccess_shared.squadRoster = {}
    SquadRoster.hydrateForCurrentGame()
    T.eq(SquadRoster.getName(n), "A,B;C%D", "delimiter-bearing name must round-trip intact")
end

function M.test_different_seed_isolates_roster()
    setup()
    SquadRoster.allocate()
    Network.GetMapRandSeed = function()
        return 999
    end
    SquadRoster.hydrateForCurrentGame()
    T.eq(next(civvaccess_shared.squadRoster), nil, "a different map seed must hydrate empty")
end

function M.test_hydrate_empty_table_when_no_prior_save()
    setup()
    SquadRoster.hydrateForCurrentGame()
    T.eq(type(civvaccess_shared.squadRoster), "table")
    T.eq(next(civvaccess_shared.squadRoster), nil)
end

function M.test_hydrate_leaves_empty_table_when_store_unavailable()
    setup()
    Modding.OpenUserData = function()
        error("simulated open failure")
    end
    Log.error = function() end
    civvaccess_shared.squadRoster = nil
    SquadRoster.hydrateForCurrentGame()
    T.eq(type(civvaccess_shared.squadRoster), "table")
    T.eq(next(civvaccess_shared.squadRoster), nil)
end

-- ===== malformed store row =====

function M.test_deserialize_skips_malformed_entries()
    -- A corrupt row (non-numeric number / flag) must be dropped rather than
    -- yielding a half-populated entry that crashes the menu downstream.
    setup()
    Modding.OpenUserData = function()
        return {
            GetValue = function()
                -- num,escort,wake,name -- second row is well-formed, the
                -- first has a non-numeric number, the third a bad wake field.
                return "x,0,0,Bad;2,1,1,Good;3,0,zz,Worse"
            end,
            SetValue = function() end,
        }
    end
    local warned
    Log.warn = function(msg)
        warned = msg
    end
    SquadRoster.hydrateForCurrentGame()
    T.eq(SquadRoster.exists(2), true, "well-formed row must survive")
    T.eq(SquadRoster.getName(2), "Good")
    T.eq(SquadRoster.getEscort(2), true)
    T.eq(next(civvaccess_shared.squadRoster) ~= nil, true)
    T.eq(SquadRoster.exists(3), false, "bad wake field must drop the row")
    T.truthy(warned, "Log.warn must fire on a malformed row")
end

function M.test_deserialize_warns_on_unparseable_entry()
    -- A row that doesn't even split into four fields (an empty field from a
    -- truncated write) must warn, not vanish silently -- a lost squad has to
    -- leave a Lua.log trace.
    setup()
    Modding.OpenUserData = function()
        return {
            GetValue = function()
                return "1,,0,Name;2,1,1,Good"
            end,
            SetValue = function() end,
        }
    end
    local warned
    Log.warn = function(msg)
        warned = msg
    end
    SquadRoster.hydrateForCurrentGame()
    T.eq(SquadRoster.exists(1), false, "empty-field row must be dropped")
    T.eq(SquadRoster.exists(2), true, "well-formed row survives")
    T.truthy(warned, "Log.warn must fire on an unparseable entry")
end

-- ===== reconcile =====

function M.test_reconcile_ensures_entries_for_engine_squads()
    -- A save whose membership survived but whose store was lost: the roster
    -- hydrates empty, but reconcile against the live engine squad numbers
    -- recreates the missing entries.
    setup()
    SquadRoster.reconcile({ 2, 5 })
    T.eq(SquadRoster.exists(2), true)
    T.eq(SquadRoster.exists(5), true)
    -- And it persists, so a re-hydrate keeps them.
    civvaccess_shared.squadRoster = {}
    SquadRoster.hydrateForCurrentGame()
    T.eq(SquadRoster.exists(5), true, "reconcile must write through")
end

function M.test_reconcile_keeps_existing_settings()
    -- reconcile must not clobber a squad the roster already knows: ensure is
    -- a no-op for an existing number.
    setup()
    local n = SquadRoster.allocate()
    SquadRoster.rename(n, "Keep")
    SquadRoster.reconcile({ n })
    T.eq(SquadRoster.getName(n), "Keep", "reconcile must not reset an existing squad")
end

return M

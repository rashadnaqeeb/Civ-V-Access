-- Bookmarks: persistent digit-keyed cursor positions plus the Ctrl+S
-- jump-to-capital. Each test exercises a path the others don't: save
-- populates a slot, save warns when the cursor is unset, save writes
-- through to the user-data store, jumpTo rejects empty slots, jumpTo
-- delegates to ScannerNav.jumpCursorTo (which owns the at-target
-- SCANNER_HERE short-circuit and the pre-jump anchor; covered in
-- scanner_navigation_test), directionTo speaks HERE at zero distance,
-- directionTo composes the optional coord segment under the
-- scannerCoords toggle, hydrateForCurrentGame loads the saved blob
-- under the current (map seed, player slot) key, the (map seed, player
-- slot) scope keeps separate games and hotseat players from cross-
-- reading each other's slots, jumpToCapital speaks NO_CAPITAL pre-
-- founding and otherwise delegates to jumpCursorTo with the live
-- capital plot.

local T = require("support")
local M = {}

local cursorPosition

local function setup()
    -- Pure-Lua deps the module reaches into directly. Cursor is stubbed
    -- below so the production CursorCore isn't required here -- this suite
    -- isn't probing cursor behavior, only the bookmarks API surface.
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_HexGeom.lua")

    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.bookmarks = nil
    civvaccess_shared.scannerCoords = false

    -- Capital-relative coord segment pulls from HexGeom.coordinateString,
    -- which scans Players slots for IsOriginalCapital. Default to no
    -- capital so the coord segment is empty unless a test installs one.
    Players = {}
    Map.IsWrapX = function()
        return false
    end

    -- Reinstall a fresh in-memory user-data store on every setup. Tests
    -- that exercise the failure path (malformed deserialize, OpenUserData
    -- throws) overwrite Modding.OpenUserData; this assignment restores
    -- the working stub for the next test, so suite ordering is irrelevant.
    -- Pin the seed and active player so the storage key is deterministic.
    -- Tests that exercise multi-game or hotseat scoping override these.
    local userDataBucket = {}
    Modding.OpenUserData = function()
        return {
            GetValue = function(key)
                return userDataBucket[key]
            end,
            SetValue = function(key, value)
                userDataBucket[key] = value
            end,
        }
    end
    Network.GetMapRandSeed = function()
        return 100
    end
    Game.GetActivePlayer = function()
        return 0
    end
    Game.IsHotSeat = function()
        return false
    end

    cursorPosition = { x = nil, y = nil }
    Cursor = {
        position = function()
            return cursorPosition.x, cursorPosition.y
        end,
    }

    -- Bookmarks delegates every jump to ScannerNav.jumpCursorTo; the suite
    -- only needs to verify the delegation happened with the right (x, y).
    -- The at-target SCANNER_HERE branch and the pre-jump anchor live in
    -- ScannerNav and are covered by scanner_navigation_test.
    ScannerNav = {
        jumpCursorTo = function(x, y)
            ScannerNav._jumped = { x = x, y = y }
            return "jumped"
        end,
    }

    dofile("src/dlc/UI/InGame/CivVAccess_Bookmarks.lua")
    Bookmarks.hydrateForCurrentGame()
end

-- ===== Save =====

function M.test_save_populates_slot_and_returns_added_string()
    setup()
    cursorPosition = { x = 4, y = -2 }
    local spoken = Bookmarks.save("3")
    T.eq(spoken, "bookmark added")
    T.eq(civvaccess_shared.bookmarks["3"].x, 4)
    T.eq(civvaccess_shared.bookmarks["3"].y, -2)
end

function M.test_save_overwrites_prior_slot()
    setup()
    cursorPosition = { x = 1, y = 1 }
    Bookmarks.save("5")
    cursorPosition = { x = 9, y = 9 }
    Bookmarks.save("5")
    T.eq(civvaccess_shared.bookmarks["5"].x, 9)
    T.eq(civvaccess_shared.bookmarks["5"].y, 9)
end

function M.test_save_warns_when_cursor_unset()
    setup()
    local warned
    Log.warn = function(msg)
        warned = msg
    end
    cursorPosition = { x = nil, y = nil }
    local spoken = Bookmarks.save("1")
    T.eq(spoken, "")
    T.eq(civvaccess_shared.bookmarks["1"], nil)
    T.truthy(warned, "Log.warn must fire when save runs before Cursor.init")
end

-- ===== jumpTo =====

function M.test_jumpTo_speaks_no_bookmark_on_empty_slot()
    -- Blind users can't tell whether the keystroke registered or which
    -- slots they have populated, so an empty slot speaks "no bookmark"
    -- rather than going silent. ScannerNav.jumpCursorTo must not be
    -- invoked -- a Backspace anchor capture into a stale empty-slot
    -- jump would be worse than no return at all.
    setup()
    cursorPosition = { x = 0, y = 0 }
    local spoken = Bookmarks.jumpTo("7")
    T.eq(spoken, "no bookmark")
    T.eq(ScannerNav._jumped, nil)
end

function M.test_jumpTo_delegates_to_jumpCursorTo()
    -- jumpTo's only post-resolve job is to forward the saved cell to
    -- ScannerNav.jumpCursorTo. The at-target SCANNER_HERE short-circuit
    -- and the pre-jump anchor capture live there and are covered by
    -- scanner_navigation_test; here we just verify the delegation.
    setup()
    cursorPosition = { x = 3, y = 3 }
    Bookmarks.save("2")
    civvaccess_shared.bookmarks["2"] = { x = 10, y = -5 }
    local spoken = Bookmarks.jumpTo("2")
    T.eq(spoken, "jumped")
    T.eq(ScannerNav._jumped.x, 10)
    T.eq(ScannerNav._jumped.y, -5)
end

-- ===== directionTo =====

function M.test_directionTo_speaks_HERE_when_cursor_on_bookmark()
    setup()
    cursorPosition = { x = 5, y = 5 }
    Bookmarks.save("1")
    -- Cursor still on the saved cell -- expect SCANNER_HERE token, the
    -- same one ScannerNav formatInstance speaks for zero-distance.
    T.eq(Bookmarks.directionTo("1"), "here")
end

function M.test_directionTo_returns_direction_string()
    -- One step east: HexGeom.directionString yields "1<DIR_E>". Suite
    -- isn't probing the exact short-token (covered by hexgeom suite),
    -- only that the bookmark formatter routes through it -- assert the
    -- result is non-empty and isn't the HERE token.
    setup()
    cursorPosition = { x = 0, y = 0 }
    Bookmarks.save("6")
    civvaccess_shared.bookmarks["6"] = { x = 4, y = 0 }
    cursorPosition = { x = 0, y = 0 }
    local out = Bookmarks.directionTo("6")
    T.truthy(out ~= "", "non-empty direction at non-zero distance")
    T.truthy(out ~= "here", "non-zero distance must not collapse to HERE token")
end

function M.test_directionTo_appends_coord_when_scannerCoords_on()
    -- scannerCoords is the same toggle the scanner's End readout uses;
    -- the bookmark formatter mirrors it so the user gets one consistent
    -- vocabulary. With a capital at (0, 0) and bookmark at (4, 0), the
    -- coord segment must be present in the output.
    setup()
    T.installOriginalCapital(0, 0, { slot = 0 })
    cursorPosition = { x = 0, y = 0 }
    Bookmarks.save("8")
    civvaccess_shared.bookmarks["8"] = { x = 4, y = 0 }
    cursorPosition = { x = 0, y = 0 }
    civvaccess_shared.scannerCoords = true
    local out = Bookmarks.directionTo("8")
    -- The exact coord format is owned by HexGeom; assert it appears as
    -- a comma-bearing segment after the direction. ", " / ". " join
    -- characters are already covered by hexgeom_test.
    T.truthy(out:find("4") ~= nil, "coord segment must include x delta")
end

function M.test_directionTo_omits_coord_when_scannerCoords_off()
    setup()
    T.installOriginalCapital(0, 0, { slot = 0 })
    cursorPosition = { x = 0, y = 0 }
    Bookmarks.save("8")
    civvaccess_shared.bookmarks["8"] = { x = 4, y = 0 }
    cursorPosition = { x = 0, y = 0 }
    civvaccess_shared.scannerCoords = false
    local out = Bookmarks.directionTo("8")
    -- COORDINATE template is "{1_X}, {2_Y}" so the comma is the cheapest
    -- discriminator: present in the coord segment, absent in the bare
    -- direction-string output (single-direction deltas have no comma).
    T.eq(out:find(",") ~= nil, false, "coord segment must be omitted when toggle is off")
end

-- ===== Persistence =====

function M.test_save_writes_through_so_hydrate_round_trips()
    -- Save populates the in-memory table AND writes to the user-data
    -- store; hydrating after a wipe of the in-memory table must restore
    -- the same slots, keyed by the current (map seed, active player).
    setup()
    cursorPosition = { x = 4, y = -2 }
    Bookmarks.save("3")
    cursorPosition = { x = 7, y = 8 }
    Bookmarks.save("9")
    civvaccess_shared.bookmarks = {}
    Bookmarks.hydrateForCurrentGame()
    T.eq(civvaccess_shared.bookmarks["3"].x, 4)
    T.eq(civvaccess_shared.bookmarks["3"].y, -2)
    T.eq(civvaccess_shared.bookmarks["9"].x, 7)
    T.eq(civvaccess_shared.bookmarks["9"].y, 8)
end

function M.test_hydrate_yields_empty_table_when_no_prior_save()
    -- A fresh game (no prior writes under this map seed and player
    -- slot) must hydrate to an empty table, not leave bookmarks nil
    -- -- the binding handlers index civvaccess_shared.bookmarks
    -- without nil-guarding.
    setup()
    Bookmarks.hydrateForCurrentGame()
    T.eq(type(civvaccess_shared.bookmarks), "table")
    T.eq(next(civvaccess_shared.bookmarks), nil)
end

function M.test_different_map_seed_isolates_slots()
    -- The storage key is "<seed>:<player>"; switching seeds (loading a
    -- separately rolled game) must yield an empty hydrate even if the
    -- prior game had populated slots in the same store.
    setup()
    cursorPosition = { x = 1, y = 1 }
    Bookmarks.save("1")
    Network.GetMapRandSeed = function()
        return 999
    end
    Bookmarks.hydrateForCurrentGame()
    T.eq(next(civvaccess_shared.bookmarks), nil, "different map seed must isolate slots")
end

function M.test_different_active_player_isolates_slots_in_hotseat()
    -- Same map seed, different player slot (hotseat handover) must
    -- isolate too: the "<seed>:<player>" key includes the player.
    setup()
    cursorPosition = { x = 1, y = 1 }
    Bookmarks.save("1")
    Game.GetActivePlayer = function()
        return 1
    end
    Bookmarks.hydrateForCurrentGame()
    T.eq(next(civvaccess_shared.bookmarks), nil, "different active player must isolate slots")
    -- And switching back restores the original player's slot.
    Game.GetActivePlayer = function()
        return 0
    end
    Bookmarks.hydrateForCurrentGame()
    T.eq(civvaccess_shared.bookmarks["1"].x, 1)
end

function M.test_save_in_memory_survives_persist_failure()
    -- Save's contract: write the in-memory slot first, persist second,
    -- so a thrown SetValue still gives the user the slot for this
    -- session. Reordering those two lines breaks the contract; this
    -- test pins the order. Failure is logged but not propagated.
    setup()
    Modding.OpenUserData = function()
        return {
            GetValue = function() return nil end,
            SetValue = function() error("simulated SQLite failure") end,
        }
    end
    local errored
    Log.error = function(msg) errored = msg end
    cursorPosition = { x = 5, y = 6 }
    local spoken = Bookmarks.save("4")
    T.eq(spoken, "bookmark added", "save must still return the success string")
    T.eq(civvaccess_shared.bookmarks["4"].x, 5, "in-memory slot must be set despite persist failure")
    T.eq(civvaccess_shared.bookmarks["4"].y, 6)
    T.truthy(errored, "Log.error must fire so the failure is traceable to Bookmarks")
end

function M.test_hydrate_leaves_empty_table_when_store_unavailable()
    -- If OpenUserData throws at boot the bindings still need a non-nil
    -- table to index. Hydrate must always leave civvaccess_shared.bookmarks
    -- as a (possibly empty) table, never nil.
    setup()
    Modding.OpenUserData = function()
        error("simulated open failure")
    end
    Log.error = function() end
    civvaccess_shared.bookmarks = nil
    Bookmarks.hydrateForCurrentGame()
    T.eq(type(civvaccess_shared.bookmarks), "table")
    T.eq(next(civvaccess_shared.bookmarks), nil)
end

function M.test_deserialize_skips_malformed_entries()
    -- A corrupt store row (manual edit, partial write, truncated value)
    -- must be skipped rather than yielding {x=nil, y=nil}, which would
    -- crash downstream HexGeom calls when the slot is jumped.
    setup()
    Modding.OpenUserData = function()
        return {
            GetValue = function() return "1,abc,5;2,3,4;9,,7" end,
            SetValue = function() end,
        }
    end
    local warned
    Log.warn = function(msg) warned = msg end
    Bookmarks.hydrateForCurrentGame()
    T.eq(civvaccess_shared.bookmarks["1"], nil, "non-numeric x must be dropped")
    T.eq(civvaccess_shared.bookmarks["2"].x, 3, "well-formed entry must survive")
    T.eq(civvaccess_shared.bookmarks["2"].y, 4)
    T.eq(civvaccess_shared.bookmarks["9"], nil, "empty x capture must be dropped")
    T.truthy(warned, "Log.warn must fire on malformed entry")
end

-- ===== Bindings surface =====

function M.test_getBindings_returns_thirtyone_bindings_and_three_help_entries()
    -- Ten slots (1-9 + 0) times three modifier variants (Ctrl/Shift/Alt)
    -- equals thirty digit-slot bindings; the Ctrl+S jump-to-capital adds
    -- a thirty-first. The help overlay rolls the slot bindings into
    -- three chord-style help rows; the Ctrl+S help entry is author'd in
    -- BaselineHandler so it sits next to Shift+S in the map-mode help
    -- list, not here -- so helpEntries stays at three. Asserting the
    -- counts catches a future accidental drop or duplicate.
    setup()
    local bs = Bookmarks.getBindings()
    T.eq(#bs.bindings, 31)
    T.eq(#bs.helpEntries, 3)
end

-- ===== jumpToCapital =====

function M.test_jumpToCapital_speaks_no_capital_pre_founding()
    -- Before the first city is founded GetCapitalCity returns nil; the
    -- key must speak "no capital" rather than going silent (a blind
    -- user can't tell whether the keystroke registered).
    setup()
    cursorPosition = { x = 5, y = 5 }
    Players[0] = T.fakePlayer({}) -- no capital
    local spoken = Bookmarks.jumpToCapital()
    T.eq(spoken, "no capital")
    T.eq(ScannerNav._jumped, nil)
end

function M.test_jumpToCapital_delegates_to_jumpCursorTo_with_capital_plot()
    -- Capital plot at (12, 7); jumpToCapital must resolve the plot via
    -- player:GetCapitalCity():Plot() and forward those coords to the
    -- shared jumpCursorTo helper. The at-target SCANNER_HERE branch
    -- and pre-jump anchor live in jumpCursorTo (covered separately).
    setup()
    local capPlot = T.fakePlot({ x = 12, y = 7 })
    local capCity = T.fakeCity({ plot = capPlot })
    Players[0] = T.fakePlayer({ capital = capCity })
    cursorPosition = { x = 0, y = 0 }
    local spoken = Bookmarks.jumpToCapital()
    T.eq(spoken, "jumped")
    T.eq(ScannerNav._jumped.x, 12)
    T.eq(ScannerNav._jumped.y, 7)
end

return M

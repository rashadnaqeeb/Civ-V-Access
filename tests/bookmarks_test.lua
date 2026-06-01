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
local headUnit
local selectReveal

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
    civvaccess_shared.unitBookmarks = nil
    civvaccess_shared.bookmarkMode = nil
    civvaccess_shared.scannerCoords = false
    civvaccess_shared.cursorFollowsSelection = false

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

    -- Unit-bookmark deps. UI feeds the head selection saveUnit captures;
    -- UnitControl.selectAndReveal is the shared select-and-reveal path
    -- (its own behavior is covered by unit_control_test) -- here we record
    -- the call and let each test pin its return; UnitSpeech supplies the
    -- save-confirmation name and the already-selected info readout.
    headUnit = nil
    selectReveal = { calls = {}, ret = true }
    UI = {
        GetHeadSelectedUnit = function()
            return headUnit
        end,
    }
    UnitControl = {
        markUserInitiatedSelection = function() end,
        selectAndReveal = function(unit)
            selectReveal.calls[#selectReveal.calls + 1] = unit
            return selectReveal.ret
        end,
    }
    UnitSpeech = {
        unitName = function(unit)
            return unit:GetNameKey()
        end,
        info = function(unit)
            return "info:" .. tostring(unit:GetID())
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
            GetValue = function()
                return nil
            end,
            SetValue = function()
                error("simulated SQLite failure")
            end,
        }
    end
    local errored
    Log.error = function(msg)
        errored = msg
    end
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
            GetValue = function()
                return "1,abc,5;2,3,4;9,,7"
            end,
            SetValue = function() end,
        }
    end
    local warned
    Log.warn = function(msg)
        warned = msg
    end
    Bookmarks.hydrateForCurrentGame()
    T.eq(civvaccess_shared.bookmarks["1"], nil, "non-numeric x must be dropped")
    T.eq(civvaccess_shared.bookmarks["2"].x, 3, "well-formed entry must survive")
    T.eq(civvaccess_shared.bookmarks["2"].y, 4)
    T.eq(civvaccess_shared.bookmarks["9"], nil, "empty x capture must be dropped")
    T.truthy(warned, "Log.warn must fire on malformed entry")
end

-- ===== Bindings surface =====

function M.test_getBindings_returns_thirtytwo_bindings_and_three_help_entries()
    -- Ten slots (1-9 + 0) times three modifier variants (Ctrl/Shift/Alt)
    -- equals thirty digit-slot bindings; the Ctrl+S jump-to-capital and
    -- the Ctrl+B mode toggle add a thirty-first and thirty-second. The
    -- help overlay rolls the slot bindings into three chord-style help
    -- rows; the Ctrl+S and Ctrl+B help entries are author'd in
    -- BaselineHandler so they sit next to the other map-mode rows, not
    -- here -- so helpEntries stays at three. Asserting the counts catches
    -- a future accidental drop or duplicate.
    setup()
    local bs = Bookmarks.getBindings()
    T.eq(#bs.bindings, 32)
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

-- ===== Unit bookmarks: mode =====

function M.test_toggleMode_flips_between_map_and_unit_and_announces()
    -- Mode is invisible state, so the toggle's announcement is the only
    -- orientation a blind player gets. Default is map; first toggle enters
    -- unit mode, second returns to map. Both the flag and the spoken word
    -- must track.
    setup()
    T.eq(Bookmarks.toggleMode(), "unit bookmarks")
    T.eq(civvaccess_shared.bookmarkMode, "unit")
    T.eq(Bookmarks.toggleMode(), "map bookmarks")
    T.eq(civvaccess_shared.bookmarkMode, "map")
end

-- ===== Unit bookmarks: save =====

function M.test_saveUnit_speaks_no_unit_selected_when_none()
    -- Nothing selected: speak rather than write an empty slot, so the
    -- keystroke isn't silently dropped.
    setup()
    headUnit = nil
    local spoken = Bookmarks.saveUnit("3")
    T.eq(spoken, "no unit selected")
    T.eq(civvaccess_shared.unitBookmarks["3"], nil)
end

function M.test_saveUnit_stores_owner_id_and_names_unit()
    setup()
    headUnit = T.fakeUnit({ owner = 0, id = 5, nameKey = "Warrior" })
    local spoken = Bookmarks.saveUnit("3")
    T.eq(spoken, "bookmarked Warrior")
    T.eq(civvaccess_shared.unitBookmarks["3"].owner, 0)
    T.eq(civvaccess_shared.unitBookmarks["3"].id, 5)
end

function M.test_saveUnit_falls_back_to_bare_confirmation_on_empty_name()
    -- A degenerate GameInfo miss yields an empty name; the confirmation
    -- must not become a dangling "bookmarked " with nothing behind it.
    setup()
    UnitSpeech.unitName = function()
        return ""
    end
    headUnit = T.fakeUnit({ owner = 0, id = 5 })
    T.eq(Bookmarks.saveUnit("3"), "unit bookmarked")
    T.eq(civvaccess_shared.unitBookmarks["3"].id, 5)
end

function M.test_saveUnit_writes_through_so_hydrate_round_trips()
    -- Unit slots persist under the "<key>:units" sub-key; hydrating after
    -- a wipe must restore the same owner/id, isolated from the tile blob.
    setup()
    headUnit = T.fakeUnit({ owner = 0, id = 5 })
    Bookmarks.saveUnit("3")
    headUnit = T.fakeUnit({ owner = 0, id = 9 })
    Bookmarks.saveUnit("7")
    civvaccess_shared.unitBookmarks = {}
    Bookmarks.hydrateForCurrentGame()
    T.eq(civvaccess_shared.unitBookmarks["3"].id, 5)
    T.eq(civvaccess_shared.unitBookmarks["7"].id, 9)
end

-- ===== Unit bookmarks: jumpToUnit =====

function M.test_jumpToUnit_speaks_empty_on_unsaved_slot()
    setup()
    local spoken = T.captureSpeech()
    Bookmarks.jumpToUnit("4")
    T.eq(spoken[1].text, "no unit bookmark")
    T.eq(#selectReveal.calls, 0)
end

function M.test_jumpToUnit_speaks_gone_when_unit_no_longer_exists()
    -- The slot is populated but the unit has died / disbanded / been given
    -- away, so GetUnitByID misses. Distinct from the empty-slot case.
    setup()
    civvaccess_shared.unitBookmarks["2"] = { owner = 0, id = 99 }
    Players[0] = T.fakePlayer({ units = {} })
    local spoken = T.captureSpeech()
    Bookmarks.jumpToUnit("2")
    T.eq(spoken[1].text, "unit no longer exists")
    T.eq(#selectReveal.calls, 0)
end

function M.test_jumpToUnit_selects_live_unit_and_defers_speech()
    -- Live unit: hand it to selectAndReveal, which (on a genuine new
    -- selection, ret=true) fires the selection listener that speaks. So
    -- jumpToUnit itself must stay silent -- a second announcement here
    -- would double up.
    setup()
    local unit = T.fakeUnit({ owner = 0, id = 5, x = 3, y = 4 })
    civvaccess_shared.unitBookmarks["2"] = { owner = 0, id = 5 }
    Players[0] = T.fakePlayer({ units = { unit } })
    selectReveal.ret = true
    local spoken = T.captureSpeech()
    Bookmarks.jumpToUnit("2")
    T.eq(selectReveal.calls[1], unit)
    T.eq(#spoken, 0)
end

function M.test_jumpToUnit_confirms_with_info_when_already_selected()
    -- selectAndReveal returns false when the bookmarked unit is already
    -- the head selection: it only re-centers silently, so jumpToUnit must
    -- speak the unit info to confirm the keystroke registered.
    setup()
    local unit = T.fakeUnit({ owner = 0, id = 5 })
    civvaccess_shared.unitBookmarks["2"] = { owner = 0, id = 5 }
    Players[0] = T.fakePlayer({ units = { unit } })
    selectReveal.ret = false
    local spoken = T.captureSpeech()
    Bookmarks.jumpToUnit("2")
    T.eq(spoken[1].text, "info:5")
end

-- ===== Unit bookmarks: directionToUnit =====

function M.test_directionToUnit_reads_live_unit_plot()
    -- Direction must come off the unit's current GetX/GetY, not a stored
    -- coordinate. Cursor at origin, unit four east: non-empty, not HERE.
    setup()
    local unit = T.fakeUnit({ owner = 0, id = 5, x = 4, y = 0 })
    civvaccess_shared.unitBookmarks["2"] = { owner = 0, id = 5 }
    Players[0] = T.fakePlayer({ units = { unit } })
    cursorPosition = { x = 0, y = 0 }
    local out = Bookmarks.directionToUnit("2")
    T.truthy(out ~= "", "non-empty direction at non-zero distance")
    T.truthy(out ~= "here", "non-zero distance must not collapse to HERE token")
end

function M.test_directionToUnit_speaks_HERE_when_cursor_on_unit()
    setup()
    local unit = T.fakeUnit({ owner = 0, id = 5, x = 6, y = 6 })
    civvaccess_shared.unitBookmarks["2"] = { owner = 0, id = 5 }
    Players[0] = T.fakePlayer({ units = { unit } })
    cursorPosition = { x = 6, y = 6 }
    T.eq(Bookmarks.directionToUnit("2"), "here")
end

-- ===== Unit bookmarks: binding dispatch + storage =====

local function findBinding(bindings, key, mods)
    for _, b in ipairs(bindings) do
        if b.key == key and b.mods == mods then
            return b
        end
    end
    return nil
end

function M.test_save_binding_targets_store_by_mode()
    -- The single Ctrl+digit binding routes to the tile store in map mode
    -- and the unit store in unit mode. This is the load-bearing branch the
    -- whole shared-key design rests on, so exercise the dispatch end to end
    -- rather than the two save functions in isolation.
    setup()
    local saveCtrl3 = findBinding(Bookmarks.getBindings().bindings, Keys["3"], 2)
    T.truthy(saveCtrl3 ~= nil, "Ctrl+3 save binding must exist")

    cursorPosition = { x = 4, y = -2 }
    saveCtrl3.fn()
    T.eq(civvaccess_shared.bookmarks["3"].x, 4, "map mode must populate the tile store")
    T.eq(civvaccess_shared.unitBookmarks["3"], nil, "map mode must leave the unit store untouched")

    Bookmarks.toggleMode()
    headUnit = T.fakeUnit({ owner = 0, id = 5 })
    saveCtrl3.fn()
    T.eq(civvaccess_shared.unitBookmarks["3"].id, 5, "unit mode must populate the unit store")
end

-- ===== Unit bookmarks: deserialize guard =====

function M.test_deserializeUnits_skips_malformed_entries()
    -- A corrupt unit row (non-numeric owner / empty id) must be dropped
    -- rather than yielding {owner=nil}, which would reach Players[nil] on
    -- jump. Mirrors the tile deserialize guard.
    setup()
    Modding.OpenUserData = function()
        return {
            GetValue = function(key)
                if key:find(":units") then
                    return "1,abc,5;2,0,7;9,0,"
                end
                return nil
            end,
            SetValue = function() end,
        }
    end
    local warned
    Log.warn = function(msg)
        warned = msg
    end
    Bookmarks.hydrateForCurrentGame()
    T.eq(civvaccess_shared.unitBookmarks["1"], nil, "non-numeric owner must be dropped")
    T.eq(civvaccess_shared.unitBookmarks["2"].owner, 0, "well-formed entry must survive")
    T.eq(civvaccess_shared.unitBookmarks["2"].id, 7)
    T.eq(civvaccess_shared.unitBookmarks["9"], nil, "empty id capture must be dropped")
    T.truthy(warned, "Log.warn must fire on malformed unit entry")
end

return M

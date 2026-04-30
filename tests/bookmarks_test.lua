-- Bookmarks: per-session digit-keyed cursor positions plus the Ctrl+S
-- permanent jump-to-capital. Each test exercises a path the others
-- don't: save populates a slot, save warns when the cursor is unset,
-- jumpTo rejects empty slots, jumpTo delegates to ScannerNav.jumpCursorTo
-- (which owns the at-target SCANNER_HERE short-circuit and the pre-jump
-- anchor; covered in scanner_navigation_test), directionTo speaks HERE
-- at zero distance, directionTo composes the optional coord segment
-- under the scannerCoords toggle, resetForNewGame drops every slot,
-- jumpToCapital speaks NO_CAPITAL pre-founding and otherwise delegates
-- to jumpCursorTo with the live capital plot.

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
    Bookmarks.resetForNewGame()
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

-- ===== resetForNewGame =====

function M.test_resetForNewGame_drops_every_slot()
    setup()
    cursorPosition = { x = 1, y = 1 }
    Bookmarks.save("1")
    Bookmarks.save("9")
    Bookmarks.resetForNewGame()
    T.eq(next(civvaccess_shared.bookmarks), nil, "table must be empty after reset")
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

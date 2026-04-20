-- Scanner announcement formatting. Verifies the documented shape
-- "<name>. <distance/direction>. <N> of <M>." and the two short-circuit
-- tokens (here, empty) produced by the nav module's format path. Goes
-- through ScannerNav.cycleItem / cycleInstance because the formatter is
-- a module-private function; exercising it through the public seam is
-- both more realistic and keeps the surface small.

local T = require("support")
local M = {}

local function installMap(plots)
    Map.GetNumPlots    = function() return #plots end
    Map.GetPlotByIndex = function(i) return plots[i + 1] end
    Map.PlotDistance   = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    Map.GetPlot = function(x, y)
        for _, p in ipairs(plots) do
            if p:GetX() == x and p:GetY() == y then return p end
        end
        return nil
    end
end

local _turnStartHandlers
local function setup()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSnap.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerSearch.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_HexGeom.lua")
    civvaccess_shared = {}
    _turnStartHandlers = {}
    Events.ActivePlayerTurnStart = {
        Add = function(fn) _turnStartHandlers[#_turnStartHandlers + 1] = fn end,
    }
    Cursor = {
        _x = 0, _y = 0,
        position = function() return 0, 0 end,
        jumpTo   = function() return "" end,
    }
    HandlerStack = { push = function() end, removeByName = function() end }
    ScannerInput = { create = function() return {} end }
    Game.GetActivePlayer = function() return 0 end
    Game.GetActiveTeam   = function() return 0 end

    dofile("src/dlc/UI/InGame/CivVAccess_ScannerNav.lua")

    -- Overwrite the cached Strings table so Text.format resolves the
    -- INSTANCE_COUNT template predictably to "<idx> of <total>".
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_INSTANCE_COUNT"] = "{1_Index} of {2_Total}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_HERE"]  = "here"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_EMPTY"] = "empty"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_ON"]  = "auto move on"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_AUTO_MOVE_OFF"] = "auto move off"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN"] = "no jump to return from"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_E"]  = "e"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NE"] = "ne"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SE"] = "se"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_W"]  = "w"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_NW"] = "nw"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_DIR_SW"] = "sw"
    -- Auto-move off: keep the cursor anchored so formatInstance sees the
    -- distance against (0, 0) rather than the current instance's plot.
    civvaccess_shared.scannerAutoMove = false

    Log.warn  = function() end
    Log.error = function() end
    Log.info  = function() end

    ScannerNav._reset()
    ScannerCore.BACKENDS = {}
end

local function installStubBackend(entries)
    ScannerCore.registerBackend({
        name          = "stub",
        Scan          = function() return entries end,
        ValidateEntry = function() return true end,
        FormatName    = function(e) return e.itemName end,
    })
end

local function mkPlot(x, y, idx)
    return T.fakePlot({ x = x, y = y, plotIndex = idx })
end

local function mkEntry(cat, sub, name, plotIndex)
    return {
        plotIndex   = plotIndex,
        backend     = ScannerCore.BACKENDS[1],
        data        = {},
        category    = cat,
        subcategory = sub,
        itemName    = name,
        sortKey     = 0,
    }
end

function M.test_cycle_item_announces_name_distance_and_count()
    setup()
    local p1 = mkPlot(3, 0, 0)
    local p2 = mkPlot(5, 0, 1)
    installMap({ p1, p2 })
    local entries = {
        mkEntry("cities", "my", "Rome",   0),
        mkEntry("cities", "my", "Athens", 1),
    }
    installStubBackend(entries)
    ScannerNav.cycleCategory(0)   -- land on cities, `all` sub
    ScannerNav.cycleSubcategory(1)  -- into "my"
    local out = ScannerNav.cycleItem(1)  -- advance to 2nd item (was at 1)
    -- After advance: item=Athens (at distance 5 from (0,0)), 1 instance.
    T.truthy(out:find("Athens", 1, true), "announcement must include item name: " .. out)
    T.truthy(out:find("5e", 1, true), "announcement must include distance/direction: " .. out)
    T.truthy(out:find("1 of 1", 1, true), "announcement must include N of M: " .. out)
end

function M.test_instance_count_reflects_total_in_item()
    setup()
    local p1 = mkPlot(1, 0, 0)
    local p2 = mkPlot(2, 0, 1)
    local p3 = mkPlot(3, 0, 2)
    installMap({ p1, p2, p3 })
    installStubBackend({
        mkEntry("cities", "my", "Rome", 0),
        mkEntry("cities", "my", "Rome", 1),
        mkEntry("cities", "my", "Rome", 2),
    })
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local out = ScannerNav.cycleInstance(1)
    T.truthy(out:find("2 of 3", 1, true),
        "instance cycle must report 1-based position + total: " .. out)
end

function M.test_zero_distance_speaks_here_token()
    setup()
    local p = mkPlot(0, 0, 0)  -- same coords as cursor (0,0)
    installMap({ p })
    installStubBackend({ mkEntry("cities", "my", "Rome", 0) })
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local out = ScannerNav.cycleItem(0)
    T.truthy(out:find("here", 1, true),
        "at-entry-plot must speak 'here' in the distance slot: " .. out)
end

function M.test_empty_item_falls_through_to_empty_token()
    setup()
    installMap({})
    installStubBackend({})
    local out = ScannerNav.cycleItem(1)
    T.truthy(out:find("empty", 1, true),
        "empty snapshot must speak the EMPTY token: " .. out)
end

function M.test_distance_from_cursor_separately_produces_bare_direction()
    -- The End key reports only the distance/direction string (no name, no
    -- N-of-M tail). That's what scanners users press End for.
    setup()
    installMap({ mkPlot(4, 0, 0) })
    installStubBackend({ mkEntry("cities", "my", "Rome", 0) })
    ScannerNav.cycleCategory(0)
    ScannerNav.cycleSubcategory(1)
    local out = ScannerNav.distanceFromCursor()
    T.truthy(out:find("4e", 1, true),
        "distanceFromCursor must produce HexGeom direction string: " .. out)
    T.truthy(not out:find("Rome", 1, true),
        "distanceFromCursor must not include the item name: " .. out)
    T.truthy(not out:find(" of ", 1, false),
        "distanceFromCursor must not include the N of M tail: " .. out)
end

function M.test_auto_move_toggle_announces_on_off()
    setup()
    civvaccess_shared.scannerAutoMove = true
    local out1 = ScannerNav.toggleAutoMove()
    T.truthy(out1:find("off", 1, true), "first toggle from on must say 'off': " .. out1)
    T.eq(civvaccess_shared.scannerAutoMove, false)
    local out2 = ScannerNav.toggleAutoMove()
    T.truthy(out2:find("on", 1, true), "second toggle must say 'on': " .. out2)
    T.eq(civvaccess_shared.scannerAutoMove, true)
end

function M.test_return_to_pre_jump_speaks_when_no_prior_jump()
    setup()
    local out = ScannerNav.returnToPreJump()
    T.truthy(out:find("no jump", 1, true) or out:find("no_return", 1, true)
            or out == "TXT_KEY_CIVVACCESS_SCANNER_JUMP_NO_RETURN",
        "Backspace with no prior jump must speak JUMP_NO_RETURN: " .. tostring(out))
end

return M

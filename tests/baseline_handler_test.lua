-- BaselineHandler now owns the in-game cursor key map and concats the
-- surveyor's Shift-letter bindings. The integration of cursor bindings
-- (cursor movement, owner-prefix diff, etc.) is covered by cursor_test;
-- the surveyor's scope logic by surveyor_test. This suite asserts only
-- handler shape and dispatch wiring so a future refactor that breaks
-- the bindings tables is caught here.

local T = require("support")
local M = {}

local function setup()
    -- Stub the cursor and surveyor with capturing fakes BEFORE
    -- BaselineHandler loads, so its closures bind to these. Production
    -- loads Cursor first and SurveyorCore second via Boot's include
    -- order; the test mimics that explicitly.
    Cursor = {
        _calls = {},
        move = function(d)
            table.insert(Cursor._calls, "move:" .. tostring(d))
            return ""
        end,
        orient = function()
            table.insert(Cursor._calls, "orient")
            return ""
        end,
        economy = function()
            table.insert(Cursor._calls, "economy")
            return ""
        end,
        combat = function()
            table.insert(Cursor._calls, "combat")
            return ""
        end,
        unitAtTile = function()
            table.insert(Cursor._calls, "unitAtTile")
            return ""
        end,
        cityIdentity = function()
            table.insert(Cursor._calls, "cityIdentity")
            return ""
        end,
        cityDevelopment = function()
            table.insert(Cursor._calls, "cityDevelopment")
            return ""
        end,
        cityPolitics = function()
            table.insert(Cursor._calls, "cityPolitics")
            return ""
        end,
        activate = function()
            table.insert(Cursor._calls, "activate")
        end,
    }
    SurveyorCore = {
        _calls = {},
    }
    local function mark(name)
        return function()
            table.insert(SurveyorCore._calls, name)
            return ""
        end
    end
    SurveyorCore.grow = mark("grow")
    SurveyorCore.shrink = mark("shrink")
    SurveyorCore.yields = mark("yields")
    SurveyorCore.resources = mark("resources")
    SurveyorCore.terrain = mark("terrain")
    SurveyorCore.ownUnits = mark("ownUnits")
    SurveyorCore.enemyUnits = mark("enemyUnits")
    SurveyorCore.cities = mark("cities")
    function SurveyorCore.getBindings()
        local SHIFT = 1
        local function b(key, fn)
            return { key = key, mods = SHIFT, fn = fn, description = "" }
        end
        return {
            bindings = {
                b(Keys.W, function()
                    SurveyorCore.grow()
                end),
                b(Keys.X, function()
                    SurveyorCore.shrink()
                end),
                b(Keys.Q, function()
                    SurveyorCore.yields()
                end),
                b(Keys.A, function()
                    SurveyorCore.resources()
                end),
                b(Keys.Z, function()
                    SurveyorCore.terrain()
                end),
                b(Keys.E, function()
                    SurveyorCore.ownUnits()
                end),
                b(Keys.D, function()
                    SurveyorCore.enemyUnits()
                end),
                b(Keys.C, function()
                    SurveyorCore.cities()
                end),
            },
            helpEntries = {
                { keyLabel = "SURV_KEY_1", description = "SURV_DESC_1" },
            },
        }
    end
    SpeechPipeline = SpeechPipeline or {}
    SpeechPipeline.speakInterrupt = function(_) end
    -- UnitControl and Turn stubbed with empty-bindings getBindings so
    -- BaselineHandler's concat step doesn't need the real modules. Their
    -- own behavior is covered in their own test suites (live listener
    -- wiring is in-game verification).
    UnitControl = {
        getBindings = function()
            return { bindings = {}, helpEntries = {} }
        end,
    }
    Turn = {
        getBindings = function()
            return { bindings = {}, helpEntries = {} }
        end,
    }
    -- EmpireStatus's bare-letter readouts (T/R/G/H/F/P/I) are concatenated
    -- into Baseline's bindings the same way Turn / UnitControl are. The
    -- module's own readout composition is covered by empire_status_test;
    -- here we just need a non-nil getBindings so BaselineHandler.create
    -- doesn't index nil.
    EmpireStatus = {
        getBindings = function()
            return { bindings = {}, helpEntries = {} }
        end,
    }
    -- TaskList contributes Shift+T to the empire-status cluster. Its own
    -- readout is covered by tasklist_test; the stub here is just a
    -- non-nil getBindings so BaselineHandler.create doesn't index nil.
    TaskList = {
        getBindings = function()
            return { bindings = {}, helpEntries = {} }
        end,
    }
    -- BaselineHandler surfaces the scanner keys from ScannerHandler's
    -- module-level HELP_ENTRIES (its own handler.helpEntries is {} so the
    -- four-section map-mode help list can place scanner keys between the
    -- surveyor and function-row sections). The test doesn't exercise the
    -- entries themselves, so a single sentinel entry is enough to keep
    -- the count assertions simple.
    ScannerHandler = {
        HELP_ENTRIES = {
            { keyLabel = "SCAN_KEY_1", description = "SCAN_DESC_1" },
        },
    }
    dofile("src/dlc/UI/InGame/CivVAccess_BaselineHandler.lua")
end

function M.test_create_returns_named_handler_with_help_entries()
    setup()
    local h = BaselineHandler.create()
    T.eq(h.name, "Baseline")
    T.eq(h.capturesAllInput, true)
    -- 6 move + S + Shift+S + W + X + 1/2/3 cursor = 13, plus 8 surveyor.
    T.truthy(#h.bindings >= 21, "expected cursor + surveyor bindings, got " .. #h.bindings)
    T.truthy(#h.helpEntries >= 8, "expected cursor + surveyor help entries")
end

function M.test_passthrough_covers_f_row_and_escape()
    -- Baseline captures every unbound key so the engine's mission / build /
    -- automate vocabulary doesn't leak through, but carves out F1-F12 and
    -- Escape so advisor screens, quick save/load, and the pause menu
    -- remain reachable from the map.
    setup()
    local h = BaselineHandler.create()
    T.truthy(h.passthroughKeys, "passthroughKeys table present")
    T.truthy(h.passthroughKeys[Keys.VK_F1], "F1 passes through")
    T.truthy(h.passthroughKeys[Keys.VK_F10], "F10 passes through")
    T.truthy(h.passthroughKeys[Keys.VK_F11], "F11 passes through")
    T.truthy(h.passthroughKeys[Keys.VK_F12], "F12 passes through")
    T.truthy(h.passthroughKeys[Keys.VK_ESCAPE], "Escape passes through")
    T.falsy(h.passthroughKeys[Keys.A], "letters do not pass through")
end

local function findBinding(h, key, mods)
    for _, b in ipairs(h.bindings) do
        if b.key == key and (b.mods or 0) == mods then
            return b
        end
    end
end

function M.test_movement_bindings_dispatch_to_cursor_with_correct_direction()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.Q, 0).fn()
    findBinding(h, Keys.E, 0).fn()
    T.eq(Cursor._calls[1], "move:" .. tostring(DirectionTypes.DIRECTION_NORTHWEST))
    T.eq(Cursor._calls[2], "move:" .. tostring(DirectionTypes.DIRECTION_NORTHEAST))
end

function M.test_plain_s_reads_unit_at_tile()
    -- Plain S reads the top unit on the cursor tile (military first, civilian fallback).
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.S, 0).fn()
    T.eq(Cursor._calls[1], "unitAtTile")
end

function M.test_shift_s_orients()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.S, 1).fn()
    T.eq(Cursor._calls[1], "orient")
end

function M.test_number_keys_dispatch_to_city_info()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys["1"], 0).fn()
    findBinding(h, Keys["2"], 0).fn()
    findBinding(h, Keys["3"], 0).fn()
    T.eq(Cursor._calls[1], "cityIdentity")
    T.eq(Cursor._calls[2], "cityDevelopment")
    T.eq(Cursor._calls[3], "cityPolitics")
end

function M.test_enter_dispatches_to_cursor_activate()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.VK_RETURN, 0).fn()
    T.eq(Cursor._calls[1], "activate")
end

function M.test_f10_fires_advisor_counsel_popup()
    -- F10 is bound to the advisor counsel popup; the engine's native V
    -- hotkey is swallowed by Baseline's letter-capturing wall, and F10
    -- stays in passthroughKeys so Ctrl+F10 (select capital) still reaches
    -- the engine via InputRouter's keycode-only passthrough match.
    setup()
    -- Stub ButtonPopupTypes and SerialEventGameMessagePopup here rather than
    -- in setup because this is the only test that exercises popup dispatch;
    -- the other tests shouldn't carry the capture.
    ButtonPopupTypes = { BUTTONPOPUP_ADVISOR_COUNSEL = 2 }
    local captured
    Events.SerialEventGameMessagePopup = function(info)
        captured = info
    end

    local h = BaselineHandler.create()
    local binding = findBinding(h, Keys.VK_F10, 0)
    T.truthy(binding, "F10 binding present")
    binding.fn()
    T.truthy(captured, "popup event fired")
    T.eq(captured.Type, ButtonPopupTypes.BUTTONPOPUP_ADVISOR_COUNSEL)
    T.eq(captured.Data1, 1)
end

function M.test_shift_letter_cluster_dispatches_to_surveyor()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.W, 1).fn()
    findBinding(h, Keys.X, 1).fn()
    findBinding(h, Keys.Q, 1).fn()
    findBinding(h, Keys.A, 1).fn()
    findBinding(h, Keys.Z, 1).fn()
    findBinding(h, Keys.E, 1).fn()
    findBinding(h, Keys.D, 1).fn()
    findBinding(h, Keys.C, 1).fn()
    T.eq(SurveyorCore._calls[1], "grow")
    T.eq(SurveyorCore._calls[2], "shrink")
    T.eq(SurveyorCore._calls[3], "yields")
    T.eq(SurveyorCore._calls[4], "resources")
    T.eq(SurveyorCore._calls[5], "terrain")
    T.eq(SurveyorCore._calls[6], "ownUnits")
    T.eq(SurveyorCore._calls[7], "enemyUnits")
    T.eq(SurveyorCore._calls[8], "cities")
end

return M

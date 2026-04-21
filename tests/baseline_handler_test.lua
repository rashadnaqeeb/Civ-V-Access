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
    SurveyorCore.hills = mark("hills")
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
                    SurveyorCore.hills()
                end),
                b(Keys.S, function()
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
    -- UnitControl stubbed with an empty-bindings getBindings so BaselineHandler's
    -- concat step doesn't need the real module. Its own behavior is covered
    -- in its own test suite (live listener wiring is in-game verification).
    UnitControl = {
        getBindings = function()
            return { bindings = {}, helpEntries = {} }
        end,
    }
    dofile("src/dlc/UI/InGame/CivVAccess_BaselineHandler.lua")
end

function M.test_create_returns_named_handler_with_help_entries()
    setup()
    local h = BaselineHandler.create()
    T.eq(h.name, "Baseline")
    T.eq(h.capturesAllInput, false)
    -- 9 cursor + 9 surveyor bindings.
    T.truthy(#h.bindings >= 18, "expected cursor + surveyor bindings, got " .. #h.bindings)
    T.truthy(#h.helpEntries >= 5, "expected cursor + surveyor help entries")
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

function M.test_plain_s_orients()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.S, 0).fn()
    T.eq(Cursor._calls[1], "orient")
end

function M.test_shift_s_routes_to_surveyor_cities_not_cursor_recenter()
    -- Shift+S was Cursor.recenter in an earlier iteration; it's now the
    -- surveyor's cities scope. Regression guard so a stale reintroduction
    -- of recenter gets caught.
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.S, 1).fn()
    T.eq(SurveyorCore._calls[1], "cities")
    T.eq(#Cursor._calls, 0, "Shift+S must not fall through to Cursor")
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
    T.eq(SurveyorCore._calls[8], "hills")
end

return M

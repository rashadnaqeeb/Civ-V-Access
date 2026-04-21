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
    -- 6 move + S + Shift+S + W + X + 1/2/3 cursor = 13, plus 8 surveyor.
    T.truthy(#h.bindings >= 21, "expected cursor + surveyor bindings, got " .. #h.bindings)
    T.truthy(#h.helpEntries >= 8, "expected cursor + surveyor help entries")
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
    -- Plain S now reads the top unit on the cursor tile (military first,
    -- civilian fallback). Orient moved to Shift+S.
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.S, 0).fn()
    T.eq(Cursor._calls[1], "unitAtTile")
end

function M.test_shift_s_orients()
    -- Shift+S carries the orient-from-capital announcement that plain S
    -- used to own. Keeps the vocabulary intact; just moves the modifier.
    setup()
    local h = BaselineHandler.create()
    findBinding(h, Keys.S, 1).fn()
    T.eq(Cursor._calls[1], "orient")
end

function M.test_number_keys_dispatch_to_city_info()
    setup()
    local h = BaselineHandler.create()
    findBinding(h, 49, 0).fn() -- VK_1
    findBinding(h, 50, 0).fn() -- VK_2
    findBinding(h, 51, 0).fn() -- VK_3
    T.eq(Cursor._calls[1], "cityIdentity")
    T.eq(Cursor._calls[2], "cityDevelopment")
    T.eq(Cursor._calls[3], "cityPolitics")
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

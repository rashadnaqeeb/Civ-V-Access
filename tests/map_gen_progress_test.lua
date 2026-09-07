-- MapGenProgress tests. Drives the reporter the way the patched Lekmap
-- script does (attempt events at the top of each regeneration pass, one
-- done event after the loop) and checks the speech policy: silent on a
-- first-pass accept, an explanation on the first regeneration, a tick
-- every TICK_SECONDS of script time, and an outcome line at the end.

local T = require("support")
local M = {}

local spoken

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    civvaccess_shared = {}
    dofile("src/dlc/UI/FrontEnd/CivVAccess_FrontEndStrings_en_US.lua")
    dofile("src/dlc/UI/FrontEnd/CivVAccess_MapGenProgress.lua")
    SpeechPipeline._reset()
    spoken = T.captureSpeech()
    MapGenProgress._reset()
end

local function lastText()
    return spoken[#spoken] and spoken[#spoken].text or nil
end

local function run(events)
    for _, e in ipairs(events) do
        MapGenProgress.report(unpack(e))
    end
end

function M.test_first_pass_accept_is_silent()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "done", true, 1, 300, 4.2 },
    })
    T.eq(#spoken, 0, "no speech when the first map is accepted")
end

function M.test_first_regeneration_explains_once()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 2.1 },
        { "attempt", 3, 300, 4.0 },
    })
    T.eq(#spoken, 1, "one announcement across the first two regenerations")
    T.truthy(lastText():find("Lekmap rejected the map", 1, true), "explanation text")
    T.truthy(lastText():find("up to 300 tries", 1, true), "cap substituted")
    T.eq(spoken[1].interrupt, true, "interrupts")
end

function M.test_ticks_every_ten_seconds_of_script_time()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 2.0 }, -- explanation, lastSpokenAt = 2
        { "attempt", 3, 300, 8.0 }, -- 6s since: silent
        { "attempt", 4, 300, 11.9 }, -- 9.9s since: silent
        { "attempt", 5, 300, 12.4 }, -- 10.4s since: tick, lastSpokenAt = 12.4
        { "attempt", 6, 300, 20.0 }, -- silent
        { "attempt", 7, 300, 22.6 }, -- tick
    })
    T.eq(#spoken, 3, "explanation plus two ticks")
    T.eq(spoken[2].text, "Map attempt 5, 12 seconds.")
    T.eq(spoken[3].text, "Map attempt 7, 23 seconds.")
end

function M.test_accepted_after_regenerations()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 2.0 },
        { "done", true, 14, 300, 35.5 },
    })
    T.eq(lastText(), "Map accepted on attempt 14 after 36 seconds. Loading continues.")
end

function M.test_gave_up_at_cap()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 2.0 },
        { "done", false, 300, 300, 600.0 },
    })
    T.truthy(lastText():find("gave up after 300 maps in 600 seconds", 1, true), "cap outcome")
end

function M.test_singular_second()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 0.2 },
        { "done", true, 2, 300, 1.0 },
    })
    T.eq(lastText(), "Map accepted on attempt 2 after 1 second. Loading continues.")
end

function M.test_new_launch_resets_after_done()
    setup()
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 2.0 },
        { "done", true, 2, 300, 3.0 },
        -- A second launch in the same session starts its own clock.
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 1.0 },
    })
    T.eq(#spoken, 3, "explanation, outcome, explanation again")
    T.truthy(spoken[3].text:find("Lekmap rejected the map", 1, true), "second launch explains again")
end

function M.test_unknown_event_and_bad_args_are_ignored()
    setup()
    run({
        { "bogus", 1, 2, 3 },
        { "attempt", nil, nil, nil },
        { "attempt", "2", "300", "5" },
        { "done", true, "2", "300", "7" },
    })
    T.eq(#spoken, 2, "string numerals are accepted; nils and unknown events are not")
end

function M.test_install_publishes_reporter_on_shared_table()
    setup()
    civvaccess_shared = nil
    MapGenProgress.install()
    T.eq(civvaccess_shared.mapGenProgress, MapGenProgress.report, "reporter published")
end

function M.test_silent_while_mod_muted()
    setup()
    civvaccess_shared.muted = true
    run({
        { "attempt", 1, 300, 0.0 },
        { "attempt", 2, 300, 2.0 },
        { "done", true, 2, 300, 3.0 },
    })
    T.eq(#spoken, 0, "hotseat mute applies")
end

return M

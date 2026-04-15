-- SpeechPipeline tests. Seams substituted: _timeSource (controllable
-- clock), _speakAction (capturing sink), SpeechEngine (stubbed so stop()
-- is observable). TextFilter is loaded for real — the pipeline's contract
-- is that it filters before speaking.

local T = require("support")
local M = {}

local spoken, now, engineStopCount

local function setup()
    spoken = {}
    now = 0
    engineStopCount = 0
    SpeechEngine.stop = function() engineStopCount = engineStopCount + 1 end
    dofile("src/dlc/UI/InGame/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._timeSource = function() return now end
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end
    SpeechPipeline._reset()
end

-- Enabled / disabled gate -------------------------------------------------

function M.test_disabled_interrupt_is_noop()
    setup()
    SpeechPipeline.setEnabled(false)
    SpeechPipeline.speakInterrupt("hello")
    T.eq(#spoken, 0)
end

function M.test_disabled_queued_is_noop()
    setup()
    SpeechPipeline.setEnabled(false)
    SpeechPipeline.speakQueued("hello")
    T.eq(#spoken, 0)
end

function M.test_set_enabled_coerces_truthy()
    setup()
    SpeechPipeline.setEnabled("yes")
    T.truthy(SpeechPipeline.isActive())
end

function M.test_set_enabled_coerces_nil_to_false()
    setup()
    SpeechPipeline.setEnabled(nil)
    T.falsy(SpeechPipeline.isActive())
end

-- Happy path --------------------------------------------------------------

function M.test_interrupt_speaks_with_interrupt_true()
    setup()
    SpeechPipeline.speakInterrupt("hello")
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "hello")
    T.eq(spoken[1].interrupt, true)
end

function M.test_queued_speaks_with_interrupt_false()
    setup()
    SpeechPipeline.speakQueued("hello")
    T.eq(#spoken, 1)
    T.eq(spoken[1].interrupt, false)
end

-- Filtering ---------------------------------------------------------------

function M.test_interrupt_filters_markup_before_speaking()
    setup()
    SpeechPipeline.speakInterrupt("[COLOR_X]hi[ENDCOLOR]")
    T.eq(spoken[1].text, "hi")
end

function M.test_queued_filters_markup_before_speaking()
    setup()
    SpeechPipeline.speakQueued("  hi\tthere  ")
    T.eq(spoken[1].text, "hi there")
end

-- Empty / nil after filter -----------------------------------------------

function M.test_nil_input_does_not_speak()
    setup()
    SpeechPipeline.speakInterrupt(nil)
    SpeechPipeline.speakQueued(nil)
    T.eq(#spoken, 0)
end

function M.test_empty_string_does_not_speak()
    setup()
    SpeechPipeline.speakInterrupt("")
    SpeechPipeline.speakQueued("")
    T.eq(#spoken, 0)
end

function M.test_markup_filtering_to_empty_does_not_speak()
    setup()
    SpeechPipeline.speakInterrupt("[COLOR_X][ENDCOLOR]")
    T.eq(#spoken, 0)
end

-- Interrupt dedup ---------------------------------------------------------

function M.test_same_interrupt_within_window_suppressed()
    setup()
    SpeechPipeline.speakInterrupt("hi")
    now = 0.04
    SpeechPipeline.speakInterrupt("hi")
    T.eq(#spoken, 1)
end

function M.test_same_interrupt_after_window_speaks_again()
    setup()
    SpeechPipeline.speakInterrupt("hi")
    now = 0.06
    SpeechPipeline.speakInterrupt("hi")
    T.eq(#spoken, 2)
end

function M.test_different_interrupt_within_window_speaks()
    setup()
    SpeechPipeline.speakInterrupt("hi")
    SpeechPipeline.speakInterrupt("bye")
    T.eq(#spoken, 2)
end

function M.test_dedup_compares_filtered_form()
    setup()
    SpeechPipeline.speakInterrupt("  hi  ")
    SpeechPipeline.speakInterrupt("[COLOR_X]hi[ENDCOLOR]")
    T.eq(#spoken, 1)
end

function M.test_dedup_window_at_boundary_speaks()
    -- Strict <, so now=0.05 is outside the window.
    setup()
    SpeechPipeline.speakInterrupt("hi")
    now = 0.05
    SpeechPipeline.speakInterrupt("hi")
    T.eq(#spoken, 2)
end

-- Queued does not dedup ---------------------------------------------------

function M.test_queued_duplicates_not_suppressed()
    setup()
    SpeechPipeline.speakQueued("hi")
    SpeechPipeline.speakQueued("hi")
    T.eq(#spoken, 2)
end

function M.test_queued_does_not_populate_interrupt_window()
    setup()
    SpeechPipeline.speakQueued("hi")
    SpeechPipeline.speakInterrupt("hi")
    T.eq(#spoken, 2)
    T.eq(spoken[2].interrupt, true)
end

function M.test_interrupt_dedup_does_not_block_queued()
    setup()
    SpeechPipeline.speakInterrupt("hi")
    SpeechPipeline.speakQueued("hi")
    T.eq(#spoken, 2)
    T.eq(spoken[2].interrupt, false)
end

-- stop() ------------------------------------------------------------------

function M.test_stop_delegates_to_engine()
    setup()
    SpeechPipeline.stop()
    T.eq(engineStopCount, 1)
end

-- _reset ------------------------------------------------------------------

function M.test_reset_clears_dedup_state()
    setup()
    SpeechPipeline.speakInterrupt("hi")
    SpeechPipeline._reset()
    SpeechPipeline.speakInterrupt("hi")
    T.eq(#spoken, 2)
end

function M.test_reset_reenables_disabled_pipeline()
    setup()
    SpeechPipeline.setEnabled(false)
    SpeechPipeline._reset()
    T.truthy(SpeechPipeline.isActive())
end

return M

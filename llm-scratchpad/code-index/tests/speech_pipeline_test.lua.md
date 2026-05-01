# `tests/speech_pipeline_test.lua`

229 lines · Tests for `CivVAccess_SpeechPipeline` covering the enabled/disabled gate, the hotseat shared-muted path, interrupt vs queued dispatch, markup filtering, empty/nil suppression, interrupt deduplication window, and `_reset` semantics.

## Header comment

```
-- SpeechPipeline tests. Seams substituted: _timeSource (controllable
-- clock), _speakAction (capturing sink), SpeechEngine (stubbed so stop()
-- is observable). TextFilter is loaded for real — the pipeline's contract
-- is that it filters before speaking.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local spoken, now, engineStopCount`
- L11: `local function setup()`
- L31: `function M.test_disabled_interrupt_is_noop()`
- L38: `function M.test_disabled_queued_is_noop()`
- L44: `function M.test_set_enabled_coerces_truthy()`
- L50: `function M.test_set_enabled_coerces_nil_to_false()`
- L61: `function M.test_shared_muted_blocks_speech()`
- L67: `function M.test_shared_unmuted_resumes_speech()`
- L77: `function M.test_reset_clears_shared_muted()`
- L87: `function M.test_interrupt_speaks_with_interrupt_true()`
- L95: `function M.test_queued_speaks_with_interrupt_false()`
- L104: `function M.test_interrupt_filters_markup_before_speaking()`
- L110: `function M.test_queued_filters_markup_before_speaking()`
- L118: `function M.test_nil_input_does_not_speak()`
- L125: `function M.test_empty_string_does_not_speak()`
- L131: `function M.test_markup_filtering_to_empty_does_not_speak()`
- L140: `function M.test_same_interrupt_within_window_suppressed()`
- L147: `function M.test_same_interrupt_after_window_speaks_again()`
- L154: `function M.test_different_interrupt_within_window_speaks()`
- L161: `function M.test_dedup_compares_filtered_form()`
- L170: `function M.test_dedup_window_at_boundary_speaks()`
- L181: `function M.test_queued_duplicates_not_suppressed()`
- L188: `function M.test_queued_does_not_populate_interrupt_window()`
- L197: `function M.test_interrupt_dedup_does_not_block_queued()`
- L206: `function M.test_stop_delegates_to_engine()`
- L213: `function M.test_reset_clears_dedup_state()`
- L222: `function M.test_reset_reenables_disabled_pipeline()`
- L229: `return M`

## Notes

- L11 `setup`: Substitutes `_timeSource` with a controllable `now` upvalue so dedup-window boundary tests advance time without sleeping.

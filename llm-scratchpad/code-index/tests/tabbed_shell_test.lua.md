# `tests/tabbed_shell_test.lua`

752 lines · Tests for `CivVAccess_TabbedShell` covering factory validation (name/displayName/tab contract), lifecycle speech (first-open, tab-cycle, re-activation, deactivation), binding/help composition and filtering (Tab/Esc ownership, per-tab swap on cycle), the F1 header readout, `handleSearchInput` delegation, `switchToTab` including no-ops, and the `menuTab` adapter that integrates BaseMenu.

## Header comment

```
-- TabbedShell tests. Loads HandlerStack, InputRouter, BaseMenu, and the
-- shell. Speech is captured via SpeechPipeline._speakAction so suites can
-- assert spoken text + interrupt flag in order.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L8: `local warns, errors`
- L9: `local speaks`
- L11: `local function setup()`
- L66: `local function stubTab(opts)`
- L96: `function M.test_create_requires_name_and_displayName()`
- L101: `function M.test_create_requires_at_least_one_tab()`
- L109: `function M.test_create_validates_tab_contract()`
- L117: `function M.test_create_shape()`
- L138: `function M.test_initial_tab_index_honored()`
- L148: `function M.test_initial_tab_index_out_of_range_rejected()`
- L158: `function M.test_first_open_speaks_screen_then_chains_first_tab_content()`
- L183: `function M.test_tab_cycle_speaks_tabName_interrupt_then_content_queued()`
- L219: `function M.test_shift_tab_cycles_backward_with_wrap()`
- L254: `function M.test_cycle_with_one_tab_is_no_op()`
- L271: `function M.test_reactivation_speaks_tab_name()`
- L289: `function M.test_deactivate_calls_active_tab_deactivate()`
- L305: `function M.test_bindings_compose_shell_first_then_active_tab()`
- L359: `function M.test_active_tab_tab_and_esc_bindings_filtered()`
- L393: `function M.test_help_entries_compose_shell_then_active_tab()`
- L438: `function M.test_rebuildExposed_picks_up_active_tab_help_mutation()`
- L475: `function M.test_f1_reads_displayName_then_active_tab_name()`
- L509: `function M.test_handleSearchInput_delegates_to_active_tab()`
- L552: `function M.test_handleSearchInput_returns_false_when_active_tab_lacks_hook()`
- L566: `function M.test_switchToTab_jumps_to_arbitrary_index()`
- L586: `function M.test_switchToTab_same_index_is_noop()`
- L596: `function M.test_switchToTab_out_of_range_is_silent_noop()`
- L614: `function M.test_menuTab_chains_first_open_speech_after_shell_displayName()`
- L656: `function M.test_menuTab_cycle_speaks_tabName_then_content_queued()`
- L719: `function M.test_menuTab_handleSearchInput_routes_through_basemenu()`
- L752: `return M`

## Notes

- L66 `stubTab`: Records lifecycle calls in a `_calls` table so tests can assert how many times `onTabActivated`/`onTabDeactivated` were called and with what `announce` argument, without coupling to BaseMenu internals.
- L475 `test_f1_reads_displayName_then_active_tab_name`: Calls `SpeechPipeline._reset()` between push and F1-fire to clear the dedup window, preventing the re-speak of `displayName` from being suppressed as a duplicate of the push-time announcement.
- L656 `test_menuTab_cycle_speaks_tabName_then_content_queued`: Cycles A->B->A and asserts re-activation chaining on the return leg, verifying `_chainSpeech` wiring for BaseMenu tabs that have been visited before.

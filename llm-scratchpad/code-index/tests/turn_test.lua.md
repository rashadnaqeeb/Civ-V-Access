# `tests/turn_test.lua`

551 lines · Tests for `CivVAccess_Turn` covering turn-start AD/BC year formatting, turn-end announcement, `_endTurnDispatch` across all blocker types (none, not-active, processing-messages, screen, FREE_ITEMS dynamic summary, unit, promotion, MP submit, hotseat, MP un-ready success/failure), `_forceEndTurn` across the same branch space, and the bindings surface.

## Header comment

```
-- Turn-module tests. Covers the Ctrl+Space / Ctrl+Shift+Space dispatch
-- branches (no-blocker end, per-blocker announce-and-activate, unit-blocker
-- select-and-center, promotion-blocker iterate-for-ready, multiplayer
-- already-submitted un-ready) and the turn-lifecycle listeners
-- (turn-start "Turn: N, year" formatting for both BC and AD, turn-end
-- "Turn ended"). Engine seams that get capturing stubs: DoControl,
-- ActivateNotification, SelectUnit, LookAt, SendTurnUnready, and the
-- Events.ActivePlayerTurn{Start,End} .Add hooks.
```

## Outline

- L10: `local T = require("support")`
- L11: `local M = {}`
- L18: `local GAME_TEXT = { ... }`
- L32: `local spoken`
- L33: `local doControlCalls`
- L34: `local activateNotificationCalls`
- L35: `local selectedUnits`
- L36: `local lookAtPlots`
- L37: `local sendUnreadyCalls`
- L38: `local sendUnreadyResult`
- L39: `local loggedWarnings`
- L40: `local startListeners`
- L41: `local endListeners`
- L42: `local activePlayer`
- L44: `local function setup()`
- L533: `local function findBinding(bindings, key, mods)`
- L181: `function M.test_turn_start_announces_turn_and_ad_year()`
- L199: `function M.test_turn_start_announces_bc_year_with_absolute_value()`
- L215: `function M.test_turn_end_announces_turn_ended()`
- L227: `function M.test_dispatch_no_blocker_calls_do_control_end_turn()`
- L237: `function M.test_dispatch_early_returns_when_turn_not_active()`
- L245: `function M.test_dispatch_early_returns_when_processing_messages()`
- L256: `function M.test_dispatch_screen_blocker_announces_and_activates_notification()`
- L268: `function M.test_dispatch_free_items_blocker_reads_dynamic_notification_summary()`
- L299: `function M.test_dispatch_unit_blocker_selects_first_ready_unit_and_centers()`
- L322: `function M.test_dispatch_promotion_blocker_iterates_for_ready_unit()`
- L360: `function M.test_dispatch_mp_submit_announces_waiting_for_players()`
- L376: `function M.test_dispatch_hotseat_submit_stays_silent()`
- L390: `function M.test_dispatch_mp_already_submitted_unreadies_and_announces_canceled()`
- L409: `function M.test_dispatch_mp_unready_refused_logs_warning_and_stays_silent()`
- L430: `function M.test_force_end_turn_with_no_blocker_calls_do_control_force()`
- L438: `function M.test_force_end_turn_with_units_blocker_calls_do_control_force()`
- L454: `function M.test_force_end_turn_with_screen_blocker_falls_through_to_announce()`
- L468: `function M.test_force_end_turn_with_stacked_units_blocker_selects_unit()`
- L491: `function M.test_force_end_turn_mp_already_submitted_unreadies()`
- L508: `function M.test_force_end_turn_mp_submit_announces_waiting_for_players()`
- L522: `function M.test_force_end_turn_respects_is_processing_messages()`
- L541: `function M.test_bindings_expose_ctrl_space_and_ctrl_shift_space()`
- L551: `return M`

## Notes

- L18 `GAME_TEXT`: Mirrors the exact XML template strings (e.g. `"Turn: {1_Nim}"`, `"{1_Date} AD"`) so `Locale.ConvertTextKey` substitution produces realistic output without the engine; the `setup()` function installs a pattern-substituting stub against this table.
- L44 `setup`: Captures `Events.ActivePlayerTurnStart.Add` and `Events.ActivePlayerTurnEnd.Add` into `startListeners` / `endListeners` arrays so tests can invoke `startListeners[1]()` / `endListeners[1]()` directly to simulate engine turn events.
- L199 `test_turn_start_announces_bc_year_with_absolute_value`: Verifies the listener flips the sign of a negative engine year (`-4000`) before substituting into `TXT_KEY_TIME_BC`, so the user hears `"4000 BC"` not `"-4000 BC"`.
- L268 `test_dispatch_free_items_blocker_reads_dynamic_notification_summary`: `ENDTURN_BLOCKING_FREE_ITEMS` has no fixed TXT_KEY label; the test wires `GetNotificationIndex` and `GetNotificationSummaryStr` to a two-slot list and verifies the listener locates the matching notification by index to get the dynamic label.
- L322 `test_dispatch_promotion_blocker_iterates_for_ready_unit`: Uses `activePlayer.Units` iterator rather than `GetFirstReadyUnit`; provides `notReady` and `ready` units in sequence, asserting `selectedUnits[1]` is the `ready` one.

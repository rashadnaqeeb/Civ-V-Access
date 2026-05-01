# `tests/unit_control_test.lua`

454 lines · Tests for `CivVAccess_UnitControl` covering `_onMissionDispatched` outcomes (reached target with fractional MP, stopped mid-path with turns-to-arrival, stopped mid-path no path, queued for next turn, engine refused outright, unit gone/silent clear, no-pending noop, other-player noop, other-unit noop, SerialEventUnitMove race condition, cursor follow-jump enabled/disabled) and `preflightAttackTarget` drills (engine allows, city-attack-only, naval vs land, naval vs coastal city passthrough, generic fallback, city-attack-only beats naval).

## Header comment

```
-- UnitControl pending-resolution tests. Drives onMissionDispatched
-- (the engine-fork hook listener) through every shape the engine can
-- present after a PUSH_MISSION net message resolves: unit reached its
-- target, unit stopped mid-path with 0 MP, unit accepted but no MP this
-- turn, unit refused outright, unit gone before dispatch landed, plus the
-- non-matching player / unit / no-pending early-return guards.
--
-- The hook is the authoritative MP resolver -- the prior frame-count
-- timeout false-fired "action failed" while the network round-trip was
-- still resolving -- so each branch's text is asserted exactly so a
-- regression that swallows a case shows up as a wrong assertion, not a
-- silent miss.
```

## Outline

- L14: `local T = require("support")`
- L15: `local M = {}`
- L21: `local STRINGS = { ... }`
- L29: `local spoken`
- L30: `local jumpedTo`
- L36: `local function mkUnit(opts)`
- L70: `local function setup()`
- L164: `local function registerPendingFor(opts)`
- L175: `function M.test_dispatched_at_target_speaks_moved()`
- L187: `function M.test_dispatched_mid_path_zero_mp_speaks_stopped_short_with_turns()`
- L208: `function M.test_dispatched_mid_path_no_path_speaks_plain_stopped_short()`
- L230: `function M.test_dispatched_on_start_with_queued_mission_speaks_queued()`
- L248: `function M.test_dispatched_on_start_with_empty_queue_speaks_action_failed()`
- L264: `function M.test_dispatched_unit_destroyed_silently_clears_pending()`
- L282: `function M.test_dispatched_with_no_pending_no_ops()`
- L287: `function M.test_dispatched_for_other_player_no_ops()`
- L299: `function M.test_dispatched_for_different_unit_no_ops()`
- L316: `function M.test_dispatched_after_move_event_already_resolved_no_ops()`
- L334: `function M.test_dispatched_at_target_jumps_cursor_when_follow_enabled()`
- L345: `function M.test_dispatched_at_target_does_not_jump_when_follow_disabled()`
- L361: `local function mkAttacker(opts)`
- L380: `local function mkTargetPlot(opts)`
- L395: `function M.test_preflight_attack_target_returns_nil_when_engine_allows()`
- L402: `function M.test_preflight_attack_target_speaks_city_only_for_battering_ram()`
- L414: `function M.test_preflight_attack_target_speaks_naval_vs_land_for_trireme_vs_warrior()`
- L424: `function M.test_preflight_attack_target_falls_through_for_naval_vs_coastal_city()`
- L434: `function M.test_preflight_attack_target_falls_through_to_generic_for_other_refusals()`
- L444: `function M.test_preflight_attack_target_city_attack_only_beats_naval_drill()`
- L454: `return M`

## Notes

- L21 `STRINGS`: Mirrors the mod-authored string templates used in assertions (e.g. `"moved, {1_Num} moves left"`, `"stopped short, {1_Num} turns to arrival"`) so the test suite can run standalone without depending on the full `CivVAccess_Strings` dofile producing exactly these phrases.
- L36 `mkUnit`: Builds a unit stub with `_generatePath` as an optional function field; if provided it replaces `GeneratePath`; if nil `GeneratePath` returns `false, 0` (unreachable). Also models `_missionQueue` as a table whose length feeds the queued-vs-refused branch.
- L70 `setup`: Stubs `Players[0]._stage(unit)` as a helper that registers a unit in the local `activeUnits` closure so `GetUnitByID` resolves it; "unit gone" tests simply skip staging, leaving `GetUnitByID` returning nil.
- L164 `registerPendingFor`: Calls both `Players[0]._stage(unit)` and `UnitControl.registerPending(unit, targetX, targetY)`, providing the canonical pre-dispatch state expected by most tests.
- L175 `test_dispatched_at_target_speaks_moved`: Verifies `interrupt = false` (queued) — the resolution speech arrives after any combat-announcement speech that fired during the engine's PushMission resolution.
- L264 `test_dispatched_unit_destroyed_silently_clears_pending`: Also fires `_onMissionDispatched` a second time after the first clear and asserts `#spoken` is still 0, verifying the no-pending early-return is safe to re-enter.
- L316 `test_dispatched_after_move_event_already_resolved_no_ops`: Simulates the SP race by calling dispatch twice on the same registration; asserts the first arrival speaks and the second is a noop, confirming the pending is cleared after first resolution.

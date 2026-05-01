# tests/notification_announce_test.lua — 346 lines
Tests NotificationAnnounce: install-time filtering, duplicate dedup, active-player change rebroadcast, debounce, streaming collapse, turn-start hold, empty-summary fallback, and reset.

## Header comment

```
-- NotificationAnnounce tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink), NotificationAnnounce._timeSource (controllable clock),
-- the three Events tables NotificationAdded / GameplaySetActivePlayer /
-- ActivePlayerTurnStart (capture listeners so tests can fire synthetic
-- events), Players[0] (controls existing notifications visible to the
-- install-time snapshot). TickPump and the module itself are loaded for
-- real.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 11  local spoken
 12  local addedListeners
 13  local activePlayerListeners
 14  local turnStartListeners
 15  local existingIds
 16  local clockNow
 18  local function advanceClock(dt)
 23  local function tick()
 28  local function setup(existing)
    local function fireAdd(id, opts)
    local function fireActivePlayerChanged(...)
    local function fireTurnStart()
120  function M.test_existing_ids_filtered_at_install()
131  function M.test_id_above_snapshot_still_processes()
140  function M.test_duplicate_id_speaks_once()
151  function M.test_active_player_change_discards_rebroadcast_wave()
171  function M.test_genuine_add_after_active_player_change_speaks()
184  function M.test_active_player_change_with_nil_player_preserves_seen_ids()
209  function M.test_active_player_change_resets_seen_ids_for_id_collisions()
225  function M.test_single_add_flushes_after_debounce()
238  function M.test_streaming_adds_collapse_into_one_drain()
261  function M.test_separate_adds_outside_debounce_flush_separately()
276  function M.test_turn_start_holds_pending_until_deadline()
290  function M.test_turn_start_with_no_pending_is_inert()
298  function M.test_add_after_turn_start_still_holds()
313  function M.test_empty_summary_falls_back_to_tooltip()
322  function M.test_both_empty_skipped()
332  function M.test_reset_clears_seen_ids()
346  return M
```

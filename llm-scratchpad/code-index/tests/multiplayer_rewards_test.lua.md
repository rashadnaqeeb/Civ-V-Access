# tests/multiplayer_rewards_test.lua — 376 lines
Tests MultiplayerRewards goody hut, barbarian camp, and natural wonder events in MP vs SP, with active-player filtering and missing engine fork hook warnings.

## Header comment

```
-- MultiplayerRewards tests. Real production modules dofiled and reset:
-- SpeechPipeline (with the _speakAction seam capturing sink),
-- TextFilter, Text, MessageBuffer, MultiplayerRewards. Seams substituted:
-- Game.IsNetworkMultiPlayer (controllable), GameEvents.CivVAccessGoody-
-- HutReceived / CivVAccessBarbarianCampCleared and Events.NaturalWonder-
-- Revealed (capture listeners so tests can drive synthetic events),
-- GameInfo / Locale / Map (per-suite stubs to drive the goody / wonder
-- text composition).
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 18  local spoken
 19  local goodyListeners
 20  local barbListeners
 21  local naturalWonderListeners
 22  local isMP
 24  local function fireGoody(playerID, eGoody, iSpecialValue)
 30  local function fireBarb(playerID, x, y, iNumGold)
 36  local function fireWonder(x, y)
 42  local function setup()
228  function M.test_goody_hut_in_mp_speaks_and_appends()
240  function M.test_goody_hut_in_sp_is_silent()
253  function M.test_goody_hut_for_other_player_is_silent()
263  function M.test_goody_hut_unknown_eGoody_logs_and_skips()
276  function M.test_barb_camp_in_mp_speaks_and_appends()
286  function M.test_barb_camp_in_sp_is_silent()
293  function M.test_barb_camp_for_other_player_is_silent()
301  function M.test_natural_wonder_in_mp_full_payload()
318  function M.test_natural_wonder_no_yield_falls_back_to_no_yield_marker()
325  function M.test_natural_wonder_in_sp_is_silent()
332  function M.test_natural_wonder_skips_non_wonder_feature()
338  function M.test_natural_wonder_skips_nil_plot()
346  function M.test_install_warns_when_engine_fork_hooks_missing()
376  return M
```

# tests/reveal_announce_test.lua — 713 lines
Tests RevealAnnounce hide direction (units walking into fog), reveal direction (with civ adjective), snapshot refresh after flush, and gone-on-revisit for camps and ruins.

## Header comment

```
(no block comment; inline setup comments describe each test section)
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
    local function makeUnit(opts)
    local function makePlayer(opts)
    local function visiblePlot()
    local function fogPlot()
    local function setup()
    local function installForeign(id, opts)
    local function fireFOW(plot)
    local function installCampAndRuinRows()
    local function installPlotMap(plots)
    local function fireRevisit(plot)
    local function fireFirstReveal(plot)
243  function M.test_hostile_unit_walks_into_fog()
261  function M.test_neutral_unit_walks_into_fog()
277  function M.test_destroyed_unit_dropped()
293  function M.test_persistent_unit_no_announce()
310  function M.test_enemy_and_neutral_split_into_one_line()
338  function M.test_aggregation_with_count_prefix()
359  function M.test_empty_flush_silent()
370  function M.test_disabled_recorder_does_not_schedule()
384  function M.test_reveal_uses_civ_adjective_and_aggregates()
446  function M.test_snapshot_refreshes_after_flush()
538  function M.test_camp_gone_on_revisit()
556  function M.test_ruin_gone_on_revisit()
574  function M.test_first_reveal_does_not_announce_gone()
598  function M.test_persistent_camp_no_gone()
615  function M.test_two_camps_aggregate_with_plural()
637  function M.test_camp_and_ruin_joined_with_and()
660  function M.test_repeat_revisit_does_not_re_announce()
684  function M.test_first_reveal_writes_snapshot_for_later_diff()
713  return M
```

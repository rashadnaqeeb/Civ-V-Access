# `tests/suite_city_stats.lua`

636 lines · Tests for `CivVAccess_CityStats` covering each pure-data row builder: yieldRows (per-turn values and tooltip breakdown), growthRows, cultureRows, happinessRows, religionRows, tradeRows, resourceRows, defenseRows, and demandRow.

## Header comment

```
-- CityStats data-shaping tests. Covers each pure-data row builder:
-- yieldRows, growthRows, cultureRows, happinessRows, religionRows,
-- tradeRows, resourceRows, defenseRows, demandRow. The wrapper builders
-- that wrap rows into BaseMenuItems.Group entries aren't exercised here
-- (their logic is just BaseMenuItems composition, covered by the menu
-- suite); the speech-shaping behavior lives in the row functions.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L15: `local function mkCity(opts)`
- L142: `local function mkPlayer(opts)`
- L165: `local GAME_KEY_TEMPLATES`
- L170: `local function setup()`
- L261: `function M.test_yields_speak_per_turn_for_seven_yields()`
- L290: `function M.test_yields_drillin_splits_tooltip_on_newline_and_filters_markup()`
- L306: `function M.test_yields_drillin_handles_helper_returning_nil()`
- L323: `function M.test_growth_speaks_progress_perturn_and_turns_to_grow()`
- L333: `function M.test_growth_speaks_starving_when_food_negative()`
- L342: `function M.test_growth_speaks_stopped_growing_when_zero_diff()`
- L350: `function M.test_culture_speaks_progress_perturn_and_turns_to_tile()`
- L362: `function M.test_culture_speaks_stalled_when_no_culture_per_turn()`
- L371: `function M.test_happiness_speaks_local_and_unhappiness()`
- L385: `function M.test_religion_skips_when_no_religions_present()`
- L391: `function M.test_religion_speaks_majority_first_then_others_with_followers()`
- L419: `function M.test_religion_holy_city_inlines_into_majority_row()`
- L437: `function M.test_trade_filters_routes_by_city_id_and_speaks_direction()`
- L475: `function M.test_trade_returns_empty_when_no_routes()`
- L483: `function M.test_resources_skips_bonus_and_lists_strategics_then_luxes()`
- L501: `function M.test_resources_returns_empty_when_no_local_resources()`
- L508: `function M.test_defense_speaks_strength_hp_and_chain_buildings_in_order()`
- L560: `function M.test_defense_omits_garrison_when_unmanned()`
- L580: `function M.test_defense_speaks_garrison_name_when_manned()`
- L609: `function M.test_demand_omits_when_no_cycle_started()`
- L614: `function M.test_demand_speaks_wltkd_counter_when_active()`
- L621: `function M.test_demand_speaks_resource_when_no_active_wltkd()`
- L636: `return M`

## Notes

- L170 `setup`: Wraps `Locale.ConvertTextKey` with a one-time idempotent patch that maps game TXT keys (e.g. `TXT_KEY_CITYVIEW_WLTKD_COUNTER`) to real format-string templates before substitution, so assertions can check the substituted output rather than raw key names. Uses `_G.makeIterableTable` to expose an iterable+indexable table factory for `GameInfo` stubs.
- L508 `test_defense_speaks_strength_hp_and_chain_buildings_in_order`: Builds a `GameInfo.Buildings` metatable with both `__call` (iterator) and `__index` (type/id lookup) inline because the defense row builder uses both access patterns.

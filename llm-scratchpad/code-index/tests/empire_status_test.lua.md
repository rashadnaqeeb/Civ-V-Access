# tests/empire_status_test.lua

Lines: 571
Purpose: Tests `EmpireStatus._*Line` functions — the seven readout functions the bare status key speaks (turn, research, gold, happiness, faith, policy, tourism). Each test scripts the engine surfaces the relevant readout queries and asserts the composed line against the exact spoken string.

## Top comment

```
-- EmpireStatus readout composition tests. Each test scripts the engine
-- surfaces the relevant readout queries (active player, active research,
-- happiness flags, golden age state, etc.) and asserts the composed line
-- against the exact spoken string. The seven readout functions are pure
-- formatters re-exposed via EmpireStatus._<name>Line for test access.
--
-- Game text keys we depend on for the formatted result. Mod-authored
-- TXT_KEY_CIVVACCESS_STATUS_* keys come from the production strings file
-- (loaded by run.lua), so their templates are the ones the player hears
-- in-game. The two engine keys (TP_TURN_COUNTER, TIME_AD/BC) we mirror
-- here so the assertion matches what Locale.ConvertTextKey returns.
```

## Outline

```lua
local T = require("support")                          -- L14
local M = {}                                          -- L15

-- GAME_TEXT table (small subset of engine keys)      -- L16-L23

local function setup()                                -- L43
local function refreshPlayers()                       -- L269

function M.test_turn_basic_ad()                                          -- L285
function M.test_turn_basic_bc()                                          -- L290
function M.test_turn_appends_supply_when_over_cap()                      -- L298
function M.test_turn_appends_strategic_shortages()                       -- L311
function M.test_research_active_speaks_turns_tech_and_rate()             -- L332
function M.test_research_just_finished_speaks_recent_tech()              -- L343
function M.test_research_none_chosen_speaks_no_research()                -- L352
function M.test_research_off_when_option_set()                           -- L359
function M.test_gold_positive_rate_speaks_gpt_first()                    -- L367
function M.test_gold_negative_rate_speaks_minus_prefix()                 -- L373
function M.test_gold_does_not_speak_strategic_shortages()                -- L379
function M.test_happiness_happy_with_ga_progress()                       -- L395
function M.test_happiness_in_golden_age_still_leads_with_happiness()     -- L402
function M.test_happiness_unhappy_speaks_negative_excess()               -- L411
function M.test_happiness_very_unhappy_uses_very_branch()                -- L419
function M.test_happiness_off_when_option_set()                          -- L426
function M.test_happiness_appends_per_luxury_inventory()                 -- L432
function M.test_happiness_skips_inventory_when_no_luxuries()             -- L449
function M.test_faith_speaks_rate_and_total()                            -- L459
function M.test_faith_off_when_option_set()                              -- L465
function M.test_policy_normal_computes_turns_to_next()                   -- L473
function M.test_policy_rounds_up_fractional_turn()                       -- L480
function M.test_policy_speaks_no_policies_left_when_cost_zero()          -- L487
function M.test_policy_speaks_stalled_when_zero_rate()                   -- L494
function M.test_policy_off_when_option_set()                             -- L502
function M.test_tourism_zero_influential_speaks_rate_only()              -- L510
function M.test_tourism_some_influential_speaks_count_only()             -- L521
function M.test_tourism_within_reach_names_denominator()                 -- L536
function M.test_tourism_skips_dead_and_minor_civs()                      -- L550

return M                                              -- L571
```

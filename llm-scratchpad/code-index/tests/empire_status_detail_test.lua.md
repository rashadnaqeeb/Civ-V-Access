# tests/empire_status_detail_test.lua

Lines: 1161
Purpose: Tests `EmpireStatus._*Detail` functions — Shift+letter detail readouts that mirror the engine `*TipHandler` in `TopPanel.lua`, dropping only the segment the bare key already spoke. Scripts enough of the Player / Game surface to exercise source breakdowns. Templates for engine `TXT_KEY_TP_*` keys are mirrored locally so passthrough `Locale.ConvertTextKey` output is readable.

## Top comment

```
-- Detail readout composition tests. Each Shift+letter detail mirrors the
-- engine *TipHandler in TopPanel.lua, dropping only the segment(s) that the
-- bare key already spoke. These tests script enough of the Player / Game
-- surface to exercise the source breakdowns, then assert against the exact
-- composed string. Templates for engine TXT_KEY_TP_* keys are mirrored
-- locally so passthrough Locale.ConvertTextKey output is readable; the
-- production hash of "{1_N} Science from Cities" is what the player hears.
```

## Outline

```lua
local T = require("support")                          -- L9
local M = {}                                          -- L10

-- GAME_TEXT table mirroring TXT_KEY_TP_* templates   -- L17-L112

local function setup()                                -- L132
local function refreshPlayers()                       -- L656
local function contains(haystack, needle)             -- L670

function M.test_research_detail_skips_rate_and_lists_sources()           -- L676
function M.test_research_detail_anarchy_prefix_when_anarchy()            -- L697
function M.test_research_detail_drops_basic_help_when_disabled()         -- L712
function M.test_research_detail_off_when_no_science()                    -- L721
function M.test_gold_detail_skips_treasury_and_total_income()            -- L729
function M.test_gold_detail_warns_about_deficit_eating_science()         -- L747
function M.test_gold_detail_basic_help_trailer_toggle()                  -- L760
function M.test_happiness_detail_skips_total_lines()                     -- L776
function M.test_happiness_detail_very_unhappy_warning_present()          -- L802
function M.test_happiness_detail_super_unhappy_revolt_above_very()       -- L811
function M.test_happiness_detail_folds_in_golden_age_addition_and_effect() -- L827
function M.test_happiness_detail_strips_trailing_engine_punctuation()    -- L849
function M.test_happiness_detail_drops_golden_age_effect_when_basic_help_off() -- L874
function M.test_happiness_detail_carnival_when_active_and_modifier()     -- L884
function M.test_happiness_detail_labels_golden_age_and_help_transitions() -- L897
function M.test_gold_detail_labels_income_and_help_transitions()         -- L908
function M.test_research_detail_labels_help_transition()                 -- L917
function M.test_policy_detail_labels_help_transition()                   -- L925
function M.test_faith_detail_labels_religions_transition()               -- L932
function M.test_faith_detail_labels_great_people_transition_industrial() -- L941
function M.test_tourism_detail_labels_influence_transition()             -- L950
function M.test_faith_detail_skips_accumulated_and_lists_sources()       -- L976
function M.test_faith_detail_industrial_era_great_person_branch()        -- L990
function M.test_faith_detail_off_when_no_religion()                      -- L1016
function M.test_faith_detail_pantheon_uses_short_form()                  -- L1025
function M.test_faith_detail_prophet_uses_short_form()                   -- L1037
function M.test_policy_detail_skips_turn_label_and_lists_sources()       -- L1050
function M.test_policy_detail_anarchy_short_circuits_source_list()       -- L1066
function M.test_policy_detail_off_when_no_policies()                     -- L1086
function M.test_tourism_detail_speaks_great_works_and_slots()            -- L1094
function M.test_tourism_detail_appends_x_of_y_when_bare_did_not()        -- L1103
function M.test_tourism_detail_drops_x_of_y_when_bare_already_spoke_it() -- L1123
function M.test_tourism_detail_drops_x_of_y_when_no_culture_victory()   -- L1144

return M                                              -- L1161
```

## Notes

`setup()` builds a full `activePlayer` stub from scratch (L132-L655). The large `GAME_TEXT` table at L17-L112 mirrors engine `TXT_KEY_TP_*` templates verbatim so `Locale.ConvertTextKey` returns human-readable strings in tests.

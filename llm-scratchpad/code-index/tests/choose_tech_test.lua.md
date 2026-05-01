# tests/choose_tech_test.lua

Lines: 547
Purpose: Tests `ChooseTechLogic` — mode filtering (normal / free / stealing), advisor compositing, label composition, and help-text cleanup against stubbed `Players` / `GameInfo` / `Game` tables, without loading the install-side module (which touches `ContextPtr` / `Events`).

## Top comment

```
-- ChooseTechLogic tests. Exercises mode filtering, advisor compositing,
-- label composition, and help-text cleanup against stubbed Players / GameInfo
-- / Game tables so we don't have to dofile the install-side access module
-- (which touches ContextPtr / Events at load).
```

## Outline

```lua
local T = require("support")                          -- L6
local M = {}                                          -- L7

local function setup()                                -- L9
local function installAdvisorLocale()                 -- L62
local function mkTech(id, typeName, description)      -- L79
local function installTechs(techs)                    -- L83
local function mkPlayer(opts)                         -- L105
local function mkTeam(techs)                          -- L143
local function mkLabelPlayer(science, turnsByTech)    -- L289
local function mkPlayerWithPreambleOpts(opts)         -- L494

function M.test_advisorSuffix_empty_when_no_recommend()                  -- L154
function M.test_advisorSuffix_single_advisor()                           -- L163
function M.test_advisorSuffix_order_economic_military_science_foreign()  -- L172
function M.test_buildEntries_normal_filters_canResearch()                -- L183
function M.test_buildEntries_free_filters_canResearchForFree()           -- L197
function M.test_buildEntries_free_requires_canResearch()                 -- L216
function M.test_buildEntries_stealing_intersects_target_techs()          -- L229
function M.test_buildEntries_free_mode_pins_current_research()           -- L243
function M.test_buildEntries_normal_mode_keeps_current_in_list()         -- L259
function M.test_buildEntries_records_queue_position()                    -- L275
function M.test_buildLabel_name_leads()                                  -- L293
function M.test_buildLabel_includes_turns_when_science_positive()        -- L306
function M.test_buildLabel_omits_turns_when_science_zero()               -- L314
function M.test_buildLabel_omits_turns_in_stealing_mode()                -- L322
function M.test_buildLabel_free_status_shows()                           -- L330
function M.test_buildLabel_queued_status_shows_slot()                    -- L338
function M.test_buildLabel_advisor_suffix_appended()                     -- L351
function M.test_buildLabel_filtered_help_trails()                        -- L362
function M.test_cleanHelpText_strips_leading_name()                      -- L378
function M.test_cleanHelpText_collapses_dash_runs()                      -- L384
function M.test_cleanHelpText_empty_input()                              -- L391
function M.test_cleanHelpText_preserves_thousands_separator()            -- L400
function M.test_cleanHelpText_preserves_multi_group_thousands()          -- L406
function M.test_cleanHelpText_still_spaces_after_text_commas()           -- L412
function M.test_filterHelpText_injects_commas_on_newline_boundaries()    -- L426
function M.test_filterHelpText_collapses_adjacent_comma_runs()           -- L435
function M.test_filterHelpText_handles_empty_input()                     -- L445
function M.test_filterHelpText_strips_researched_marker()                -- L451
function M.test_filterHelpText_strips_localized_researched_marker()      -- L466
function M.test_filterHelpText_preserves_leads_to_color_span()           -- L477
function M.test_preamble_free_mode_includes_count_and_science()          -- L516
function M.test_preamble_stealing_includes_civ_name()                    -- L527
function M.test_preamble_normal_zero_science_is_empty()                  -- L540

return M                                              -- L547
```

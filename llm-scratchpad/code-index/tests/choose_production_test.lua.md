# tests/choose_production_test.lua

Lines: 579
Purpose: Tests `ChooseProductionLogic` — pure builders for entry construction, sort, disabled / cost / label / advisor compositing against a minimal city stub and `GameInfo` table, without loading the install-side access module (which touches `ContextPtr` / `InputHandler`).

## Top comment

```
-- ChooseProductionLogic tests. Exercises pure builders (entry construction,
-- sort, disabled / cost / label / advisor compositing) against a minimal
-- city stub and GameInfo table so we don't have to dofile the install-side
-- access module (which touches ContextPtr / InputHandler at load).
```

## Outline

```lua
local T = require("support")                          -- L5
local M = {}                                          -- L6

local function setup()                                -- L9
local function mkCityStub(opts)                       -- L87
local function mkInfoTable(rows)                      -- L196
local function installGameInfoUnits(rows)             -- L219
local function installGameInfoBuildings(rows)         -- L222
local function installGameInfoProjects(rows)          -- L225
local function installGameInfoProcesses(rows)         -- L228
local function installEras(eras)                      -- L231
local function installTechnologies(techs)             -- L234
local function installBuildingClasses(map)            -- L238
local function installStandardEras()                  -- L246

function M.test_is_wonder_building_flags_world_wonder()                  -- L259
function M.test_unit_sort_key_category_offsets()                         -- L274
function M.test_building_sort_key_via_prereq_tech()                      -- L294
function M.test_sort_entries_puts_enabled_before_disabled()              -- L301
function M.test_sort_entries_prefers_gold_over_faith_on_ties()           -- L321
function M.test_build_unit_entries_produce_tab_collects_trainable()      -- L334
function M.test_build_unit_entries_purchase_tab_splits_on_both_yields()  -- L355
function M.test_build_building_and_wonder_entries_split_by_class()       -- L377
function M.test_build_other_entries_includes_processes_on_produce_only() -- L399
function M.test_disabled_entry_label_includes_reason()                   -- L421
function M.test_label_drops_help_when_identical_to_strategy()            -- L452
function M.test_label_drops_unresolved_strategy_key()                    -- L489
function M.test_advisor_suffix_with_zero_one_and_all_advisors()          -- L528
function M.test_append_slot_and_queue_full_text_templates()              -- L571

return M                                              -- L579
```

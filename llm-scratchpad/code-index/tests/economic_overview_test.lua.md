# tests/economic_overview_test.lua

Lines: 394
Purpose: Tests `EconomicOverviewAccess` — helpers exposed via the module table after dofiling with a stubbed engine surface. `TabbedShell.install` at the bottom is guarded on a real `ContextPtr` so dofile doesn't try to wire up a fake Context.

## Top comment

```
-- F2 Economic Overview wrapper tests. Exercises the helpers exposed via
-- the EconomicOverviewAccess module table after dofiling the wrapper with a
-- stubbed engine surface. The TabbedShell.install at the bottom of the
-- wrapper is guarded on a real ContextPtr so dofile doesn't try to wire up
-- a fake Context.
```

## Outline

```lua
local T = require("support")                          -- L7
local M = {}                                          -- L8

local function setup()                                -- L10
local function stubCity(opts)                         -- L86
local function hasColumn(cols, name)                  -- L248

function M.test_formatSigned_positive_gets_plus()                        -- L154
function M.test_formatSigned_zero_unsigned()                             -- L159
function M.test_formatSigned_negative_unsigned_native_minus()            -- L164
function M.test_cityAnnotation_capital()                                 -- L171
function M.test_cityAnnotation_puppet()                                  -- L177
function M.test_cityAnnotation_occupied_with_unhappiness()               -- L183
function M.test_cityAnnotation_occupied_but_no_unhappiness_unannotated() -- L189
function M.test_cityAnnotation_normal_city_unannotated()                 -- L195
function M.test_cityAnnotation_capital_takes_precedence_over_puppet()    -- L201
function M.test_cityRowLabel_no_annotation_returns_bare_name()           -- L211
function M.test_cityRowLabel_capital_appended()                          -- L217
function M.test_cityRowLabel_occupied_appended()                         -- L223
function M.test_cityProductionPerTurn_no_modifier()                      -- L231
function M.test_cityProductionPerTurn_applies_percent_modifier()         -- L237
function M.test_buildCityColumns_default_includes_science_and_faith()    -- L257
function M.test_buildCityColumns_no_science_drops_science_column()       -- L264
function M.test_buildCityColumns_no_religion_drops_faith_column()        -- L274
function M.test_buildCityColumns_all_have_getCell_and_sortKey()          -- L284
function M.test_buildCityColumns_name_column_has_enterAction()           -- L293
function M.test_buildCityColumns_production_column_has_enterAction()     -- L305
function M.test_food_column_getCell_signs_positive_yield()               -- L319
function M.test_strength_column_getCell_divides_by_100()                 -- L334
function M.test_population_column_getCell_returns_count_string()         -- L349
function M.test_productionColumnCell_with_active_build_includes_turns_and_name() -- L366
function M.test_productionColumnCell_with_no_production_says_none()      -- L383

return M                                              -- L394
```

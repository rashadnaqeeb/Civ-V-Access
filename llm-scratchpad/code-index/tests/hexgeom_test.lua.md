# tests/hexgeom_test.lua

Lines: 327
Purpose: Tests `HexGeom` — `plotsInRange` inclusion and the cube-distance invariant, `directionRank`, `stepListString`, and `coordinateString`. Used by the cursor S key, scanner End key, and surveyor radius sweeps.

## Top comment

```
-- HexGeom is used by the cursor's S key, the scanner's End key, and the
-- surveyor's radius sweeps. directionString is covered by cursor_test's
-- orient cases; this suite focuses on plotsInRange inclusion and the
-- cube-distance invariant that every caller depends on.
```

## Outline

```lua
local T = require("support")                          -- L6
local M = {}                                          -- L7

local function setup()                                -- L9
local function installGrid(halfWidth, unrevealed)     -- L24
local function setupSteps()                           -- L165
local function coordSetup()                           -- L207

function M.test_plotsInRange_r0_contains_only_center()                   -- L50
function M.test_plotsInRange_r1_contains_seven_plots()                   -- L60
function M.test_plotsInRange_r3_contains_thirtyseven_plots()             -- L68
function M.test_plotsInRange_r5_contains_ninetyone_plots()               -- L76
function M.test_every_returned_plot_is_within_cube_distance()            -- L86
function M.test_unrevealed_plots_counted_separately()                    -- L103
function M.test_offmap_plots_do_not_inflate_unexplored()                 -- L111
function M.test_every_plot_lands_in_exactly_one_bucket()                 -- L126
function M.test_cubeDistance_matches_ring_counts()                       -- L138
function M.test_directionRank_e_beats_se()                               -- L153
function M.test_stepListString_empty_input_returns_empty()               -- L170
function M.test_stepListString_single_direction_run()                    -- L176
function M.test_stepListString_groups_consecutive_only()                 -- L186
function M.test_coordinateString_at_capital_is_zero_zero()               -- L220
function M.test_coordinateString_step_east()                             -- L226
function M.test_coordinateString_step_west()                             -- L232
function M.test_coordinateString_step_ne_lands_on_half()                 -- L238
function M.test_coordinateString_step_se_lands_on_half_negative_y()      -- L248
function M.test_coordinateString_capital_on_odd_row_subtracts_half()     -- L256
function M.test_coordinateString_pre_capital_returns_empty()             -- L266
function M.test_coordinateString_finds_captured_capital()                -- L273
function M.test_coordinateString_no_match_when_other_player_capital()    -- L282
function M.test_coordinateString_wrap_folds_far_east_to_negative()       -- L290
function M.test_coordinateString_wrap_within_half_unchanged()            -- L305
function M.test_coordinateString_no_wrap_keeps_far_east_positive()       -- L319

return M                                              -- L327
```

## Notes

Uses `T.installOriginalCapital` to seed the capital reference used by `coordinateString`. `installGrid` builds a synthetic hex map of a given half-width with optional unrevealed plots.

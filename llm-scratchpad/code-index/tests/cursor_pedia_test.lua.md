# tests/cursor_pedia_test.lua

Lines: 373
Purpose: Tests `CursorPedia._buildEntries` — everything with a pedia article at the cursor plot is listed; same-pedia dedup; foreign / cargo units surfaced; invisible / fogged filtered; only world wonders from cities; unrevealed plots produce zero entries; bare revealed plot always has at least terrain.

## Top comment

```
-- CursorPedia enumeration tests. Exercises _buildEntries against fake
-- plots, units, and city contents to confirm: (1) everything with a pedia
-- article at the cursor plot is listed, (2) dedup collapses same-pedia
-- entries (four fighters on a carrier produce a single Fighter row),
-- (3) units foreign / cargo are still surfaced (you can look up an enemy
-- Warrior's stats even though you can't select it), (4) invisible / fogged
-- units and unrevealed resources / improvements / routes are filtered,
-- (5) only world wonders appear from the city on the tile (not national
-- or team wonders), (6) unrevealed plots produce zero entries, and
-- (7) a bare revealed plot always has at least the terrain row (so the
-- single-entry auto-open answers "what terrain is this?" without a
-- picker). BaseMenu push / Events.SearchForPediaEntry are production-side
-- concerns covered by the handler_stack / civilopedia suites; this one
-- is just about the entry list.
```

## Outline

```lua
local T = require("support")                          -- L18
local M = {}                                          -- L19

local function setup()                                -- L19  (two setups; first for CursorActivate section)
local function setup()                                -- L19  (second for CursorPedia section)
local function pediaNames(entries)                    -- L69
local function eqList(actual, expected)               -- L77

function M.test_unrevealed_plot_returns_empty()                          -- L84
function M.test_bare_plot_returns_terrain_only()                         -- L95
function M.test_dedup_four_same_type_units()                             -- L105
function M.test_mixed_unit_types_all_listed()                            -- L120
function M.test_foreign_unit_surfaced()                                  -- L136
function M.test_cargo_unit_surfaced()                                    -- L148
function M.test_invisible_unit_filtered()                                -- L161
function M.test_improvement_listed()                                     -- L173
function M.test_unrevealed_improvement_skipped()                         -- L181
function M.test_resource_listed()                                        -- L192
function M.test_hidden_resource_skipped()                                -- L200
function M.test_feature_listed()                                         -- L211
function M.test_route_listed()                                           -- L219
function M.test_no_route_skipped()                                       -- L227
function M.test_city_world_wonder_listed()                               -- L234
function M.test_city_national_wonder_filtered()                          -- L255
function M.test_city_not_built_wonder_filtered()                         -- L273
function M.test_hills_adds_entry_with_underlying_terrain()               -- L293
function M.test_mountain_collapses_with_terrain_via_dedup()              -- L304
function M.test_river_adds_entry()                                       -- L316
function M.test_lake_adds_entry()                                        -- L324
function M.test_full_tile_composition()                                  -- L332

return M                                              -- L373
```

## Notes

The file contains two independent `setup()` functions for distinct test sections (CursorActivate entries at top, CursorPedia entries below). `pediaNames` and `eqList` are helpers for the CursorPedia section only.

# tests/aircraft_count_test.lua

Lines: 255
Purpose: Tests `UnitSpeech.cargoAircraftToken` and `UnitSpeech.cityAircraftToken`. Mirrors the iteration that UnitFlagManager's `UpdateCargo` / `UpdateCityCargo` do so tests fail if the enumeration filter or threshold drifts from base-game behavior.

## Top comment

```
-- Aircraft count tokens for carriers (X/Y always when capacity > 0)
-- and city plots (X/Y only when at least one aircraft is stationed).
-- Mirrors the iteration UnitFlagManager's UpdateCargo / UpdateCityCargo
-- do, so tests fail if our enumeration filter or threshold drifts from
-- the base game's behavior.
```

## Outline

```lua
local T = require("support")                          -- L7
local M = {}                                          -- L8

local function setup()                                -- L10
local function mkPlot(units, opts)                    -- L29
local function mkCarrier(opts)                        -- L50
local function mkCargo(transportId)                   -- L66
local function mkAirInCity()                          -- L84
local function mkLandUnit()                           -- L98

function M.test_cargo_token_empty_when_no_capacity()              -- L114
function M.test_cargo_token_zero_count_still_speaks()             -- L131
function M.test_cargo_token_counts_only_this_carriers_cargo()     -- L141
function M.test_cargo_token_skips_non_cargo_units()               -- L152
function M.test_city_token_empty_when_not_a_city()                -- L164
function M.test_city_token_empty_when_zero_aircraft()             -- L170
function M.test_city_token_speaks_count_with_base_capacity()      -- L183
function M.test_city_token_skips_non_air_units_in_count()         -- L194
function M.test_city_token_includes_building_modifiers_in_max()   -- L208
function M.test_city_token_ignores_unowned_building_modifiers()   -- L233

return M                                              -- L255
```

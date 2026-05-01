# tests/icons_test.lua

Lines: 178
Purpose: Tests `CivVAccess_Icons` via `TextFilter.filter` — each bracket icon token maps to the expected localized spoken form. Includes base-game typo variants (`ICON_HAPPINES_4`, `ICON_STRENGHT`, `ICON_CULTUR`) and dedup / color-wrapper collapse cases. Loads the production in-game strings file to get real `TXT_KEY_CIVVACCESS_ICON_*` values.

## Top comment

```
-- Icon registration. Loads CivVAccess_Icons against a live TextFilter and
-- the in-game strings module, then asserts that the filter swaps each
-- bracket token for the expected localized spoken form. Includes base-game
-- typo variants (ICON_HAPPINES_4, ICON_STRENGHT, ICON_CULTUR) to guard
-- against accidental drift: if one of these stops mapping to its correct
-- counterpart the screen reader will emit garbage on the next game patch.
```

## Outline

```lua
local T = require("support")                          -- L11
local M = {}                                          -- L12

local function setup()                                -- L11
local function filtered(name)                         -- L26

function M.test_yield_icons_resolve()                                    -- L32
function M.test_icon_peace_speaks_faith()                                -- L46
function M.test_combat_icons_resolve()                                   -- L53
function M.test_happiness_icons_split_positive_and_negative()            -- L62
function M.test_arrow_glyphs_resolve()                                   -- L71
function M.test_typo_happines_4_maps_to_unhappiness()                    -- L81
function M.test_typo_strenght_maps_to_combat_strength()                  -- L87
function M.test_typo_cultur_maps_to_culture()                            -- L93
function M.test_dropped_resource_icon_is_stripped()                      -- L105
function M.test_dropped_religion_icon_is_stripped()                      -- L111
function M.test_dropped_city_status_icon_is_stripped()                   -- L116
function M.test_happiness_1_collapses_against_happy()                    -- L125
function M.test_happiness_4_collapses_against_unhappy()                  -- L134
function M.test_typo_happines_4_collapses_against_unhappy()              -- L143
function M.test_unit_production_cost_speaks_cleanly()                    -- L150
function M.test_tech_cost_speaks_cleanly()                               -- L156
function M.test_unit_faith_cost_speaks_cleanly()                         -- L161
function M.test_icon_dedup_sees_past_color_wrapper()                     -- L173

return M                                              -- L178
```

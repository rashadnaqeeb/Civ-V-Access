# tests/civilopedia_flat_search_test.lua

Lines: 242
Purpose: Tests `Civilopedia.buildFlatSearchable` (in `CivilopediaCore`) — walking a synthetic picker tree into a flat list of `{ label, path, group }` entries and teleporting the handler cursor through `moveTo`. Uses real `BaseMenuItems.Group` / `Entry` factories so `cached=false` Groups behave as in production.

## Top comment

```
-- Civilopedia flat-search corpus tests. Exercises the picker-tab
-- buildSearchable override from CivilopediaCore: walking a synthetic
-- picker tree into a flat list of { label, path, group } entries, then
-- teleporting the handler cursor through the returned searchable's
-- moveTo.
--
-- Uses real BaseMenuItems Group / Entry factories so cached=false Groups
-- behave the same as in the production picker. PickerReader.Entry is
-- simulated via BaseMenuItems.Choice-shaped entries with `kind = "entry"`
-- and an id -- buildFlatCorpus only reads labelOf, kind, id, and
-- Group:children.
```

## Outline

```lua
local T = require("support")                          -- L14
local M = {}                                          -- L15

local speaks                                          -- L17

local function setup()                                -- L18
local function entry(id, labelText)                   -- L48
local function pediaTree()                            -- L64
local function fakeHandler(items)                     -- L102
local function findByLabel(searchable, label)         -- L111

function M.test_flat_corpus_includes_articles_intros_and_categories()   -- L120
function M.test_flat_corpus_articles_are_group_zero()                   -- L131
function M.test_flat_corpus_categories_are_group_one()                  -- L140
function M.test_flat_corpus_intros_are_group_one()                      -- L149
function M.test_flat_corpus_top_level_intro_not_duplicated()            -- L158
function M.test_flat_corpus_multiple_top_level_intros_not_dropped()     -- L175
function M.test_flat_corpus_moveTo_teleports_to_article_path()          -- L200
function M.test_flat_corpus_moveTo_announces_label()                    -- L214
function M.test_flat_corpus_moveTo_teleports_to_top_level_category()    -- L231

return M                                              -- L242
```

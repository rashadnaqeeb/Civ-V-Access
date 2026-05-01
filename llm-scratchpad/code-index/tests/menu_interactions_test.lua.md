# `tests/menu_interactions_test.lua`

803 lines - Tests BaseMenu item-interaction semantics: click-ack gating, tooltip composition / deduplication / dynamic fn / newline handling, and edit-mode (Textfield enter / escape / restore / commit / re-enter).

## Header comment

```
-- BaseMenu item-interaction tests. Peeled out of menu_test.lua.
-- Covers click-ack gating (when activation plays the click sound vs
-- when it stays silent), tooltip composition / dedupe / dynamic fn /
-- newline handling, and edit-mode (Textfield enter / escape / restore
-- / commit / re-enter). The shared setup() and helpers are duplicated
-- across the four menu_*_test files so each is self-contained.
```

## Outline

```lua
local T = require("support")                          -- L7
local M = {}                                          -- L8

local warns, errors                                   -- L10
local speaks                                          -- L11
local sounds                                          -- L12
local _test_pd_mt = nil                               -- L13

local function resetPDMetatable()                     -- L15
local function setup()                                -- L32

local WM_KEYDOWN = 256                                -- L106

local function populateControls(map)                  -- L110
local function patchProbeFromPullDown(pd)             -- L117
local function makePullDownWithMetatable()            -- L121
local function registerSliderCallback(slider, fn)     -- L128
local function registerCheckHandler(cb, fn)           -- L133
local ctrlState                                       -- L140
local function makeCtrl(name)                         -- L141
local function setCtrls(names)                        -- L153
local function makeContextPtr()                       -- L161
local function buttonSpec(names)                      -- L179

function M.test_button_activate_throw_suppresses_click()                     -- L200
function M.test_text_without_onActivate_reannounces_label_no_click()        -- L223
function M.test_text_with_onActivate_success_plays_click()                  -- L241
function M.test_text_with_throwing_onActivate_suppresses_click()            -- L265
function M.test_choice_activate_throw_suppresses_click()                    -- L287
function M.test_checkbox_no_captured_callback_suppresses_click()            -- L304
function M.test_checkbox_throwing_callback_suppresses_click()               -- L321
function M.test_pulldown_no_entries_suppresses_click()                      -- L340
function M.test_pulldown_entry_throwing_callback_suppresses_click_still_pops() -- L356
function M.test_tooltip_appended_after_label_value()                        -- L386
function M.test_tooltip_dedupes_against_label()                             -- L407
function M.test_tooltipFn_appends_dynamic_tooltip()                         -- L428
function M.test_tooltipFn_error_is_logged_and_swallowed()                   -- L452
function M.test_tooltip_newlines_become_period_separators()                 -- L474
function M.test_tooltip_decimal_in_value_is_preserved()                     -- L499
function M.test_tooltipFn_nil_result_does_not_add_comma()                   -- L524
function M.test_slider_empty_label_falls_back_to_textKey()                  -- L545
function M.test_enter_on_textfield_pushes_edit_submenu()                    -- L568
function M.test_escape_during_edit_restores_and_pops()                      -- L596
function M.test_enter_during_edit_commits_without_restoring()               -- L622
function M.test_commit_fires_priorCallback_with_final_text()                -- L639
function M.test_commit_announces_committed_value()                          -- L663
function M.test_commit_on_empty_announces_blank()                           -- L680
function M.test_commit_without_priorCallback_is_safe()                      -- L696
function M.test_restore_does_not_fire_priorCallback()                       -- L713
function M.test_edit_submenu_has_no_arrow_bindings()                        -- L740
function M.test_reenter_edit_installs_fresh_wrapping_callback()             -- L760
function M.test_edit_mode_enter_keyup_is_claimed()                          -- L784

return M                                              -- L803
```

## Notes

- L356 `test_pulldown_entry_throwing_callback_suppresses_click_still_pops`: verifies two independent invariants in one test -- no click sound AND sub still pops even when the selection callback throws.
- L499 `test_tooltip_decimal_in_value_is_preserved`: guards against the sentence splitter treating a decimal point as a sentence boundary, which would produce "1. 06" in trade-route tooltips.
- L784 `test_edit_mode_enter_keyup_is_claimed`: uses `BaseMenu.install` + the raw `ctx._in` path to exercise WM_KEYUP (msg 257) claiming, which `InputRouter.dispatch` does not cover.

# tests/plural_rules_test.lua — 221 lines
Tests CLDR plural rule selection per locale: en/de/es/it one/other, French 0-as-one, Russian and Polish Slavic forms, East Asian all-other, unknown fallback, type guards, negative and fractional counts.

## Header comment

```
-- CLDR plural-rule selection per locale. Each language's rule encodes a
-- slice of CLDR's spec; these cases pin the boundary conditions
-- translators rely on (the 11 / 12-14 exceptions in Slavic languages,
-- the 0-collapses-to-singular in French, the no-distinction East Asian
-- rules).
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  9  local function setup(locale)
 13  local function teardown()
 22  function M.test_en_one_for_one()
 28  function M.test_en_other_for_zero()
 34  function M.test_en_other_for_two()
 40  function M.test_en_other_for_one_hundred()
 50  function M.test_fr_one_for_zero()
 56  function M.test_fr_one_for_one()
 62  function M.test_fr_other_for_two()
 73  function M.test_ru_one_for_one()
 79  function M.test_ru_few_for_two()
 85  function M.test_ru_few_for_three_and_four()
 92  function M.test_ru_many_for_five()
 98  function M.test_ru_many_for_eleven_through_fourteen()
107  function M.test_ru_one_for_twenty_one()
113  function M.test_ru_few_for_twenty_two()
119  function M.test_ru_many_for_twenty_five()
130  function M.test_pl_one_for_one()
136  function M.test_pl_few_for_two_to_four()
144  function M.test_pl_many_for_eleven_through_fourteen()
152  function M.test_pl_one_for_twenty_one_diverges_from_ru()
161  function M.test_ja_other_for_everything()
173  function M.test_unknown_locale_falls_back_to_english()
182  function M.test_non_number_input_returns_other()
189  function M.test_negative_count_uses_absolute_value()
201  function M.test_en_other_for_non_integer()
208  function M.test_fr_other_for_non_integer()
214  function M.test_ru_other_for_non_integer()
221  return M
```

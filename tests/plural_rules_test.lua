-- CLDR plural-rule selection per locale. Each language's rule encodes a
-- slice of CLDR's spec; these cases pin the boundary conditions
-- translators rely on (the 11 / 12-14 exceptions in Slavic languages,
-- the 0-collapses-to-singular in French, the no-distinction East Asian
-- rules).

local T = require("support")
local M = {}

local function setup(locale)
    PluralRules._setLocale(locale)
end

local function teardown()
    PluralRules._setLocale("en_US")
end

-- ===== English / German / Spanish / Italian =====
-- All share the same one/other rule. Test through en_US as the
-- representative.

function M.test_en_one_for_one()
    setup("en_US")
    T.eq(PluralRules.select(1), "one")
    teardown()
end

function M.test_en_other_for_zero()
    setup("en_US")
    T.eq(PluralRules.select(0), "other")
    teardown()
end

function M.test_en_other_for_two()
    setup("en_US")
    T.eq(PluralRules.select(2), "other")
    teardown()
end

function M.test_en_other_for_one_hundred()
    setup("en_US")
    T.eq(PluralRules.select(100), "other")
    teardown()
end

-- ===== French =====
-- 0 collapses to one; 1 stays one; 2+ is other. The 0-quirk is
-- French-specific and the reason French gets its own rule.

function M.test_fr_one_for_zero()
    setup("fr_FR")
    T.eq(PluralRules.select(0), "one")
    teardown()
end

function M.test_fr_one_for_one()
    setup("fr_FR")
    T.eq(PluralRules.select(1), "one")
    teardown()
end

function M.test_fr_other_for_two()
    setup("fr_FR")
    T.eq(PluralRules.select(2), "other")
    teardown()
end

-- ===== Russian =====
-- Three forms with mod-100 exceptions: 11 reads as many (not one),
-- 12-14 read as many (not few). 21 reads as one again because last
-- digit is 1 and the 11-exception only applies to literal 11.

function M.test_ru_one_for_one()
    setup("ru_RU")
    T.eq(PluralRules.select(1), "one")
    teardown()
end

function M.test_ru_few_for_two()
    setup("ru_RU")
    T.eq(PluralRules.select(2), "few")
    teardown()
end

function M.test_ru_few_for_three_and_four()
    setup("ru_RU")
    T.eq(PluralRules.select(3), "few")
    T.eq(PluralRules.select(4), "few")
    teardown()
end

function M.test_ru_many_for_five()
    setup("ru_RU")
    T.eq(PluralRules.select(5), "many")
    teardown()
end

function M.test_ru_many_for_eleven_through_fourteen()
    setup("ru_RU")
    T.eq(PluralRules.select(11), "many")
    T.eq(PluralRules.select(12), "many")
    T.eq(PluralRules.select(13), "many")
    T.eq(PluralRules.select(14), "many")
    teardown()
end

function M.test_ru_one_for_twenty_one()
    setup("ru_RU")
    T.eq(PluralRules.select(21), "one")
    teardown()
end

function M.test_ru_few_for_twenty_two()
    setup("ru_RU")
    T.eq(PluralRules.select(22), "few")
    teardown()
end

function M.test_ru_many_for_twenty_five()
    setup("ru_RU")
    T.eq(PluralRules.select(25), "many")
    teardown()
end

-- ===== Polish =====
-- Same three-form shape as Russian; differs from Russian in that 1
-- is unconditionally one (Polish doesn't apply the mod-100 exception
-- to its singular). Test the divergent boundary explicitly.

function M.test_pl_one_for_one()
    setup("pl_PL")
    T.eq(PluralRules.select(1), "one")
    teardown()
end

function M.test_pl_few_for_two_to_four()
    setup("pl_PL")
    T.eq(PluralRules.select(2), "few")
    T.eq(PluralRules.select(3), "few")
    T.eq(PluralRules.select(4), "few")
    teardown()
end

function M.test_pl_many_for_eleven_through_fourteen()
    setup("pl_PL")
    T.eq(PluralRules.select(11), "many")
    T.eq(PluralRules.select(12), "many")
    T.eq(PluralRules.select(14), "many")
    teardown()
end

function M.test_pl_one_for_twenty_one_diverges_from_ru()
    -- Polish: 21 is many (only 1 is one). Russian: 21 is one.
    setup("pl_PL")
    T.eq(PluralRules.select(21), "many")
    teardown()
end

-- ===== Czech =====
-- Three forms, but few stops at 4: 22-24 take other where Polish and
-- Russian come back round to few, and no integer selects many. Zero and
-- the teens are other.

function M.test_cs_one_for_one()
    setup("cs_CZ")
    T.eq(PluralRules.select(1), "one")
    teardown()
end

function M.test_cs_few_for_two_to_four()
    setup("cs_CZ")
    T.eq(PluralRules.select(2), "few")
    T.eq(PluralRules.select(3), "few")
    T.eq(PluralRules.select(4), "few")
    teardown()
end

function M.test_cs_other_for_zero_and_five_up()
    setup("cs_CZ")
    T.eq(PluralRules.select(0), "other")
    T.eq(PluralRules.select(5), "other")
    T.eq(PluralRules.select(11), "other")
    T.eq(PluralRules.select(12), "other")
    T.eq(PluralRules.select(14), "other")
    T.eq(PluralRules.select(21), "other")
    T.eq(PluralRules.select(100), "other")
    teardown()
end

function M.test_cs_other_for_twenty_two_diverges_from_pl_and_ru()
    -- Czech: "22 tahů". Polish and Russian both return few here.
    setup("cs_CZ")
    T.eq(PluralRules.select(22), "other")
    T.eq(PluralRules.select(23), "other")
    T.eq(PluralRules.select(24), "other")
    teardown()
end

function M.test_cs_other_for_non_integer()
    setup("cs_CZ")
    T.eq(PluralRules.select(1.5), "other")
    T.eq(PluralRules.select(2.5), "other")
    teardown()
end

-- ===== Japanese / Korean / Chinese =====

function M.test_ja_other_for_everything()
    setup("ja_JP")
    T.eq(PluralRules.select(0), "other")
    T.eq(PluralRules.select(1), "other")
    T.eq(PluralRules.select(2), "other")
    T.eq(PluralRules.select(100), "other")
    teardown()
end

-- ===== Fallback =====
-- Unknown locales fall through to en_US's one/other rule.

function M.test_unknown_locale_falls_back_to_english()
    setup("xx_XX")
    T.eq(PluralRules.select(1), "one")
    T.eq(PluralRules.select(2), "other")
    teardown()
end

-- ===== Type guards =====

function M.test_non_number_input_returns_other()
    setup("en_US")
    T.eq(PluralRules.select(nil), "other")
    T.eq(PluralRules.select("five"), "other")
    teardown()
end

function M.test_negative_count_uses_absolute_value()
    setup("en_US")
    T.eq(PluralRules.select(-1), "one")
    T.eq(PluralRules.select(-2), "other")
    teardown()
end

-- Fractional counts should never pick the integer-bound singular forms.
-- 1.5 dogs is plural in English, "1.5 chiens" is plural in French
-- (vs. 1 chien / 0 chien which take the "one" form), and the Slavic
-- "few" / "many" forms are integer-domain in CLDR. Cover the boundary
-- across one-form and three-form locales.
function M.test_en_other_for_non_integer()
    setup("en_US")
    T.eq(PluralRules.select(0.5), "other")
    T.eq(PluralRules.select(1.5), "other")
    teardown()
end

function M.test_fr_other_for_non_integer()
    setup("fr_FR")
    T.eq(PluralRules.select(1.5), "other")
    teardown()
end

function M.test_ru_other_for_non_integer()
    setup("ru_RU")
    T.eq(PluralRules.select(1.5), "other")
    T.eq(PluralRules.select(2.5), "other")
    teardown()
end

return M

-- Per-locale CLDR plural-form selection for mod-authored strings.
-- The engine's plural machinery (CIV5 plural-choice tags) only fires for
-- TXT_KEYs registered through the engine text database. Fake-DLC text
-- ingestion is broken in the engine, so our TXT_KEY_CIVVACCESS_* keys
-- never reach that pipeline -- Text.lua resolves them from CivVAccess_Strings
-- and runs positional substitution itself. This module is the parallel
-- plural pipeline for those mod-authored keys.
--
-- The function for each locale takes a non-negative integer and returns
-- a CLDR keyword: "one" / "few" / "many" / "other". Bundle entries in
-- the strings tables are keyed by these keywords; Text.formatPlural
-- selects the form. The keywords are CLDR's standard set; Civ V doesn't
-- ship languages that need "two" or "zero" so those aren't used.
--
-- Falls back to en_US (one/other) for any locale we don't have a rule
-- for. The aim is "if Locale returns something unexpected, still produce
-- speakable English text" rather than crashing.

PluralRules = {}

-- English / German / Spanish / Italian: 1 -> one, else other.
local function onePlural(n)
    if n == 1 then
        return "one"
    end
    return "other"
end

-- French: 0 and 1 both take the singular form.
local function frenchPlural(n)
    if n == 0 or n == 1 then
        return "one"
    end
    return "other"
end

-- Polish CLDR: one (n=1), few (n%10 in 2..4 and n%100 not in 12..14),
-- many (everything else for integers).
local function polishPlural(n)
    if n == 1 then
        return "one"
    end
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then
        return "few"
    end
    return "many"
end

-- Russian CLDR: one (n%10=1 and n%100~=11), few (n%10 in 2..4 and n%100
-- not in 12..14), many (otherwise). Same shape as Polish but with the
-- "1 -> one only when last digit is 1 and not 11" twist that Polish
-- doesn't apply to its singular.
local function russianPlural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 then
        return "one"
    end
    if mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then
        return "few"
    end
    return "many"
end

-- Japanese / Korean / Chinese: no plural distinction at all.
local function noPlural(_n)
    return "other"
end

local rules = {
    en_US = onePlural,
    de_DE = onePlural,
    es_ES = onePlural,
    it_IT = onePlural,
    pt_BR = onePlural,
    fr_FR = frenchPlural,
    pl_PL = polishPlural,
    ru_RU = russianPlural,
    ja_JP = noPlural,
    ko_KR = noPlural,
    zh_Hant_HK = noPlural,
    zh_Hant = noPlural,
}

local cachedRule

-- Resolve the active locale from the engine on first use and cache. Civ V
-- doesn't change language mid-session, so the cache stays valid for the
-- lifetime of the Lua context.
local function currentRule()
    if cachedRule ~= nil then
        return cachedRule
    end
    local code
    if Locale and Locale.GetCurrentLanguage then
        local lang = Locale.GetCurrentLanguage()
        if lang and lang.Type then
            code = lang.Type
        end
    end
    cachedRule = rules[code or "en_US"] or rules.en_US
    return cachedRule
end

-- Map a count to its CLDR plural keyword for the active locale. Negative
-- counts are folded to absolute value. Non-integer counts (e.g. 1.5
-- moves left) short-circuit to "other": every CLDR cardinal rule we
-- ship treats fractional values as plural -- "1.5 moves" is plural in
-- English, French, Russian, Polish, and the no-plural East Asian locales
-- already collapse to "other" anyway -- so this stays correct without
-- per-locale fraction handling.
function PluralRules.select(count)
    if type(count) ~= "number" then
        return "other"
    end
    if count < 0 then
        count = -count
    end
    if count ~= math.floor(count) then
        return "other"
    end
    return currentRule()(count)
end

-- Test seam: force a specific locale's rule (ignoring the cached engine
-- value). Production code does not call this.
function PluralRules._setLocale(code)
    cachedRule = rules[code] or rules.en_US
end

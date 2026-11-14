-- StringsLoader: branches over the active locale and the supported-locales
-- set to decide whether to include() the overlay file. The actual file
-- existence is the engine's concern; tests stub include() to capture the
-- stem the loader requested.

local T = require("support")
local M = {}

local origGetCurrentLanguage
local origConvertTextKey
local origInclude
local includeCalls

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_StringsLoader.lua")
    origGetCurrentLanguage = Locale.GetCurrentLanguage
    origConvertTextKey = Locale.ConvertTextKey
    origInclude = include
    includeCalls = {}
    include = function(stem)
        includeCalls[#includeCalls + 1] = stem
    end
end

local function teardown()
    Locale.GetCurrentLanguage = origGetCurrentLanguage
    Locale.ConvertTextKey = origConvertTextKey
    include = origInclude
    StringsLoader._setSupportedLocales({})
end

local function setLocale(code)
    Locale.GetCurrentLanguage = function()
        return { Type = code }
    end
end

-- What the engine answers for the "yes" button: the base-game string the
-- loader probes to tell a Czech fan-patch session from an English one.
local function setYesButtonText(text)
    Locale.ConvertTextKey = function(key)
        if key == "TXT_KEY_YES_BUTTON" then
            return text
        end
        return key
    end
end

function M.test_en_US_skips_overlay()
    setup()
    setLocale("en_US")
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0, "en_US is the baseline; no overlay include should fire")
    teardown()
end

function M.test_supported_non_baseline_locale_includes_overlay()
    setup()
    setLocale("fr_FR")
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 1)
    T.eq(includeCalls[1], "CivVAccess_InGameStrings_fr_FR")
    teardown()
end

function M.test_unsupported_locale_skips_overlay()
    setup()
    setLocale("xx_YY")
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0, "no overlay should be requested for an unsupported locale")
    teardown()
end

function M.test_stem_concatenation_uses_locale_suffix()
    -- Each Context has its own stem (InGame / FrontEnd / Scanner / Surveyor);
    -- guard the suffix join shape so a refactor that breaks it gets caught.
    setup()
    setLocale("ru_RU")
    StringsLoader._setSupportedLocales({ ru_RU = true })
    StringsLoader.loadOverlay("CivVAccess_ScannerStrings")
    T.eq(includeCalls[1], "CivVAccess_ScannerStrings_ru_RU")
    teardown()
end

function M.test_missing_GetCurrentLanguage_falls_back_to_en_US()
    -- Engine misbehavior path: if the API ever returns nil or is absent,
    -- the loader treats the locale as en_US and does nothing rather than
    -- crashing on a nil index.
    setup()
    Locale.GetCurrentLanguage = function()
        return nil
    end
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0)
    teardown()
end

function M.test_GetCurrentLanguage_table_without_Type_falls_back()
    setup()
    Locale.GetCurrentLanguage = function()
        return {}
    end
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0)
    teardown()
end

-- ===== Czech =====
-- The only Czech translation of the game overwrites the en_US text in place
-- and registers no language, so the engine reports en_US while answering in
-- Czech. The loader has to tell that session from a real English one.

function M.test_cs_CZ_reported_by_the_engine_includes_overlay()
    -- The config.ini route: Language = cs_CZ edited in by hand.
    setup()
    setLocale("cs_CZ")
    StringsLoader._setSupportedLocales({ cs_CZ = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 1)
    T.eq(includeCalls[1], "CivVAccess_InGameStrings_cs_CZ")
    teardown()
end

function M.test_en_US_answering_in_czech_loads_the_cs_CZ_overlay()
    setup()
    setLocale("en_US")
    setYesButtonText("Ano")
    StringsLoader._setSupportedLocales({ cs_CZ = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 1, "en_US text that is really Czech should load the Czech overlay")
    T.eq(includeCalls[1], "CivVAccess_InGameStrings_cs_CZ")
    teardown()
end

function M.test_en_US_answering_in_english_stays_on_the_baseline()
    setup()
    setLocale("en_US")
    setYesButtonText("Yes")
    StringsLoader._setSupportedLocales({ cs_CZ = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0, "a real English session must not pick up the Czech overlay")
    teardown()
end

function M.test_czech_probe_applies_only_to_en_US()
    -- The patch sits on the en_US slot and nowhere else, so another
    -- language is never reinterpreted whatever its text says.
    setup()
    setLocale("de_DE")
    setYesButtonText("Ano")
    StringsLoader._setSupportedLocales({ cs_CZ = true, de_DE = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 1)
    T.eq(includeCalls[1], "CivVAccess_InGameStrings_de_DE")
    teardown()
end

function M.test_activeLocale_reports_czech_under_the_fan_patch()
    setup()
    setLocale("en_US")
    setYesButtonText("Ano")
    T.eq(StringsLoader.activeLocale(), "cs_CZ")
    setYesButtonText("Yes")
    T.eq(StringsLoader.activeLocale(), "en_US")
    teardown()
end

function M.test_plural_rules_follow_the_loader_under_the_fan_patch()
    -- Czech strings with English plural selection would never reach the
    -- "few" form ("3 tahy"). A freshly loaded PluralRules has no cached
    -- rule, so its first select() resolves the locale through the loader.
    setup()
    setLocale("en_US")
    setYesButtonText("Ano")
    dofile("src/dlc/UI/Shared/CivVAccess_PluralRules.lua")
    T.eq(PluralRules.select(3), "few")
    T.eq(PluralRules.select(5), "other")
    PluralRules._setLocale("en_US")
    teardown()
end

return M

-- StringsLoader: branches over the active locale and the supported-locales
-- set to decide whether to include() the overlay file. The actual file
-- existence is the engine's concern; tests stub include() to capture the
-- stem the loader requested.

local T = require("support")
local M = {}

local origGetCurrentSpokenLanguage
local origInclude
local includeCalls

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_StringsLoader.lua")
    origGetCurrentSpokenLanguage = Locale.GetCurrentSpokenLanguage
    origInclude = include
    includeCalls = {}
    include = function(stem)
        includeCalls[#includeCalls + 1] = stem
    end
end

local function teardown()
    Locale.GetCurrentSpokenLanguage = origGetCurrentSpokenLanguage
    include = origInclude
    StringsLoader._setSupportedLocales({})
end

local function setLocale(code)
    Locale.GetCurrentSpokenLanguage = function()
        return { Type = code }
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

function M.test_missing_GetCurrentSpokenLanguage_falls_back_to_en_US()
    -- Engine misbehavior path: if the API ever returns nil or is absent,
    -- the loader treats the locale as en_US and does nothing rather than
    -- crashing on a nil index.
    setup()
    Locale.GetCurrentSpokenLanguage = function()
        return nil
    end
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0)
    teardown()
end

function M.test_GetCurrentSpokenLanguage_table_without_Type_falls_back()
    setup()
    Locale.GetCurrentSpokenLanguage = function()
        return {}
    end
    StringsLoader._setSupportedLocales({ fr_FR = true })
    StringsLoader.loadOverlay("CivVAccess_InGameStrings")
    T.eq(#includeCalls, 0)
    teardown()
end

return M

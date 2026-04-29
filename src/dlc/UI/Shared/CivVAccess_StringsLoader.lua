-- Locale-specific overlay loader for mod-authored strings.
--
-- The Boot include chain always loads the en_US strings file first, so
-- CivVAccess_Strings starts populated with the source-of-truth English
-- entries. This module overlays a locale-specific file on top: for active
-- locale `<code>` and stem `<base>`, it includes `<base>_<code>` if such
-- a file ships in the VFS, and the locale's reassignments overwrite the
-- en_US entries in CivVAccess_Strings.
--
-- Loading is additive. A translator can ship a partial file: keys absent
-- from the overlay keep their en_US values, so a missing translation
-- reaches the user as English speech rather than a missing-key warning.
-- The same shape applies to plural-form bundles -- forms absent from the
-- overlay fall through Text.formatPlural's bundle-level fallback chain
-- to whatever the en_US bundle had.
--
-- Why an explicit supported-locales set rather than speculative include:
-- Civ V's include() logs a warning to Lua.log when a stem isn't in the
-- VFS index. Every Context boot would emit one of those for every
-- unsupported locale-stem pair otherwise. Keeping the list explicit means
-- silent fall-through to en_US for any locale we don't ship a translation
-- for, which is the common case until translation files arrive.
--
-- The loader runs once per Context include of this file (it just defines
-- the StringsLoader global). The actual overlay include happens at each
-- StringsLoader.loadOverlay call site; Boot calls it once per stem after
-- the en_US baseline include.

StringsLoader = {}

-- Locales that ship a translated strings file alongside en_US. Codes
-- match Civ V's spoken-language Type identifiers (Locale.GetCurrentSpokenLanguage().Type),
-- not generic ISO codes. en_US is omitted because it is the baseline and
-- is always loaded by Boot before this module runs an overlay.
--
-- Adding a new locale: drop CivVAccess_<Stem>_<code>.lua files into the
-- VFS for each Context that needs the overlay (InGame, FrontEnd, Scanner,
-- Surveyor as applicable), then flip the entry below to true. Any locale
-- absent from this set silently falls through to en_US -- no warning, no
-- error -- so users running an unsupported locale hear English.
--
-- Distinct values seen in Civ V's Locale.GetSupportedSpokenLanguages
-- output: en_US, de_DE, es_ES, fr_FR, it_IT, ja_JP, ko_KR, pl_PL, ru_RU,
-- zh_Hant_HK. The keys here are commented out until a corresponding
-- translation file ships.
local supportedLocales = {
    -- de_DE = true,
    -- es_ES = true,
    -- fr_FR = true,
    -- it_IT = true,
    -- ja_JP = true,
    -- ko_KR = true,
    -- pl_PL = true,
    -- ru_RU = true,
    -- zh_Hant_HK = true,
}

local function activeLocale()
    if Locale ~= nil and Locale.GetCurrentSpokenLanguage ~= nil then
        local lang = Locale.GetCurrentSpokenLanguage()
        if lang ~= nil and lang.Type ~= nil then
            return lang.Type
        end
    end
    return "en_US"
end

-- Apply the active locale's overlay for the given strings stem on top of
-- the already-loaded en_US baseline. Stem is the base name without the
-- _<locale> suffix, e.g. "CivVAccess_InGameStrings". No-ops when the
-- active locale is en_US (baseline already loaded) or when the locale
-- has no overlay file shipping in the VFS.
function StringsLoader.loadOverlay(stem)
    local locale = activeLocale()
    if locale == "en_US" then
        return
    end
    if not supportedLocales[locale] then
        return
    end
    include(stem .. "_" .. locale)
end

-- Test seam. Production code does not call this; it lets the loader's
-- offline tests drive arbitrary supported sets without rewriting the
-- module-scope table.
function StringsLoader._setSupportedLocales(set)
    supportedLocales = set or {}
end

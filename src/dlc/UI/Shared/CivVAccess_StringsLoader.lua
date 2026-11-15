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
-- match Civ V's text-language Type identifiers (Locale.GetCurrentLanguage().Type),
-- not generic ISO codes. en_US is omitted because it is the baseline and
-- is always loaded by Boot before this module runs an overlay.
--
-- Adding a new locale: drop CivVAccess_<Stem>_<code>.lua files into the
-- VFS for each Context that needs the overlay (InGame, FrontEnd, Scanner,
-- Surveyor as applicable), then flip the entry below to true. Any locale
-- absent from this set silently falls through to en_US -- no warning, no
-- error -- so users running an unsupported locale hear English.
--
-- Distinct values seen in Civ V's Languages table: en_US, de_DE, es_ES,
-- fr_FR, it_IT, ja_JP, ko_KR, pl_PL, ru_RU, zh_Hant_HK. pt_BR is registered
-- by the Civ5-PTBR community language pack rather than Firaxis. cs_CZ is
-- registered by nothing at all -- see the Czech note below. The keys here
-- are commented out until a corresponding translation file ships.
local supportedLocales = {
    cs_CZ = true,
    de_DE = true,
    es_ES = true,
    fr_FR = true,
    it_IT = true,
    ja_JP = true,
    ko_KR = true,
    pl_PL = true,
    pt_BR = true,
    ru_RU = true,
    zh_Hant_HK = true,
}

-- Read the active text-language code (config.ini's Language= field, exposed
-- through Locale.GetCurrentLanguage). The audio/spoken-language preference
-- is independent in Civ V and governs voice acting only -- using it here
-- would skip the overlay for any player who reads in one locale but keeps
-- English voice acting (the common Asian-locale config).
local function engineLocale()
    if Locale ~= nil and Locale.GetCurrentLanguage ~= nil then
        local lang = Locale.GetCurrentLanguage()
        if lang ~= nil and lang.Type ~= nil then
            return lang.Type
        end
    end
    return "en_US"
end

-- Czech has no language slot of its own. The only Czech translation of the
-- game, the civ5_allinone_cz fan patch, overwrites the en_US text files in
-- place and registers no language, so the engine goes on reporting en_US
-- while every base-game string it hands back is Czech. Left alone, that
-- session would speak the game in Czech and the mod in English. So when the
-- engine says en_US, ask it for one base-game string the patch translates:
-- an answer in Czech means the session is Czech and the cs_CZ overlay is
-- the one to load. A player who instead hand-edits Language = cs_CZ into
-- config.ini reports cs_CZ directly and never reaches the probe.
local CZECH_PROBE_KEY = "TXT_KEY_YES_BUTTON"
local CZECH_PROBE_TEXT = "Ano"

local function engineSpeaksCzech()
    if Locale == nil or Locale.ConvertTextKey == nil then
        return false
    end
    return Locale.ConvertTextKey(CZECH_PROBE_KEY) == CZECH_PROBE_TEXT
end

local function activeLocale()
    local code = engineLocale()
    if code == "en_US" and engineSpeaksCzech() then
        return "cs_CZ"
    end
    return code
end

-- The locale mod-authored text is spoken in: the engine's text language,
-- or cs_CZ under the Czech fan patch. PluralRules resolves its rule through
-- this too, so an overlay and its plural forms can never disagree.
function StringsLoader.activeLocale()
    return activeLocale()
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

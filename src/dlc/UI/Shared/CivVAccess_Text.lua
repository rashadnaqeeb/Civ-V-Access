-- Wrapper around Locale.ConvertTextKey that surfaces missing keys to the log.
-- A missing key in raw Locale silently returns the input string and the user
-- hears "TXT KEY FOO" spelled out. Routing through here turns that into an
-- actionable Log.warn while still returning something speakable.

Text = {}

-- Engine-style {N_Tag} substitution for mod-authored mapped strings. The
-- game's Locale.ConvertTextKey does this for TXT_KEY_*, but we short-circuit
-- Locale for our own keys to keep the mapping table as the source of truth,
-- so we do substitution here. Only the positional {N_...} form is handled;
-- the Tag after the underscore is ignored (same as the engine when args
-- arrive by position).
local function substitute(s, args, argCount)
    if argCount == 0 then
        return s
    end
    return (
        s:gsub("{(%d+)_[^}]*}", function(n)
            local v = args[tonumber(n)]
            if v == nil then
                return ""
            end
            return tostring(v)
        end)
    )
end

local function lookup(key, ...)
    if type(key) == "string" and key:sub(1, 19) == "TXT_KEY_CIVVACCESS_" then
        local mapped = CivVAccess_Strings and CivVAccess_Strings[key]
        if mapped ~= nil then
            local argCount = select("#", ...)
            if argCount == 0 then
                return mapped
            end
            return substitute(mapped, { ... }, argCount)
        end
        -- Fall through to Locale so the missing-key warning still fires via
        -- the engine's passthrough behavior (returns the key unchanged).
    end
    if select("#", ...) > 0 then
        return Locale.ConvertTextKey(key, ...)
    end
    return Locale.ConvertTextKey(key)
end

local function isTxtKey(s)
    return type(s) == "string" and s:sub(1, 8) == "TXT_KEY_"
end

function Text.key(keyName)
    local out = lookup(keyName)
    if out == keyName and isTxtKey(keyName) then
        Log.warn("Text: missing TXT_KEY " .. tostring(keyName))
    end
    return out
end

-- Like Text.key but returns nil instead of the raw key string when the lookup
-- misses. Use this when the caller has somewhere to drop the value (a part
-- list, a tooltip with a fallback) so an unresolved key never reaches Tolk
-- and gets spelled out letter by letter. Base-game data is the main source
-- of misses: a few TXT_KEY_* references point at strings that were never
-- registered (e.g. TXT_KEY_PROCESS_RESEARCH_STRATEGY).
function Text.keyOrNil(keyName)
    local out = lookup(keyName)
    if out == keyName and isTxtKey(keyName) then
        Log.warn("Text: missing TXT_KEY " .. tostring(keyName))
        return nil
    end
    return out
end

function Text.format(keyName, ...)
    local out = lookup(keyName, ...)
    if out == keyName and isTxtKey(keyName) then
        Log.warn("Text: missing TXT_KEY " .. tostring(keyName))
    end
    return out
end

-- Plural-aware lookup for mod-authored keys. Bundles in CivVAccess_Strings
-- look like { one = "1 tile", other = "{1_N} tiles" }; this picks the
-- right form via PluralRules and substitutes positional args. The count
-- argument drives plural selection only -- if the count also appears in
-- the template (as {N_X}), the caller passes it again as a substitution
-- arg in `...`.
--
-- Bundle resolution: requested form -> "other" -> "one" -> first form
-- found. The fallback chain lets a translator who only authored one and
-- other still produce something for Russian's "few" / "many" rather than
-- a missing-key warning, at the cost of awkward agreement that still
-- conveys the information.
--
-- For non-mod keys or scalar entries, falls through to Text.format with
-- the supplied substitution args; the count is dropped (the caller must
-- pass count again in `...` if the engine template needs it).
function Text.formatPlural(keyName, count, ...)
    if type(keyName) == "string" and keyName:sub(1, 19) == "TXT_KEY_CIVVACCESS_" then
        local mapped = CivVAccess_Strings and CivVAccess_Strings[keyName]
        if type(mapped) == "table" then
            local form = PluralRules.select(count)
            local template = mapped[form] or mapped.other or mapped.one
            if template == nil then
                local _k, anyValue = next(mapped)
                template = anyValue
            end
            if template == nil then
                Log.warn("Text.formatPlural: bundle for " .. tostring(keyName) .. " has no forms")
                return tostring(keyName)
            end
            local argCount = select("#", ...)
            if argCount == 0 then
                return template
            end
            return substitute(template, { ... }, argCount)
        end
    end
    return Text.format(keyName, ...)
end

-- Compose "<civ adjective> <unit name>". The base-game format
-- TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV only ships a non-English
-- variant in fr_FR, and that variant invokes a gender-form selector
-- the engine fails to resolve (Localization.log: "Could not deduce
-- form based on gender and plurality") so it returns empty. Other
-- locales fall through the engine to the en_US template, which is
-- plain adjective-then-noun concatenation. Rather than try to coax a
-- usable string out of the broken format, build the phrase ourselves:
-- pick word order from a per-locale table and concatenate the default
-- forms returned by Locale.ConvertTextKey on each row.
--
-- Two known-imperfect outcomes:
-- * The adjective comes through in the row's default (first) form,
--   which is masculine singular for the languages that gender. A
--   feminine UU localized with a feminine adjective form will get the
--   wrong gender ("Trière babylonien" instead of "Trière babylonienne").
--   Selecting the right form would require unit-row gender metadata
--   the Lua API does not expose; wrong-gender-correct-order is
--   intelligible, wrong-order is jarring.
-- * For locales we have not categorized below the order defaults to
--   adj-noun (the engine's en_US fallback). Romance languages need
--   noun-adj and are listed; everything else (Germanic, CJK, Slavic)
--   reads correctly with adj-noun in the common case.
local NOUN_ADJ_LOCALES = {
    es_ES = true,
    fr_FR = true,
    it_IT = true,
}

local function activeLocale()
    if Locale and Locale.GetCurrentSpokenLanguage then
        local lang = Locale.GetCurrentSpokenLanguage()
        if lang and lang.Type then
            return lang.Type
        end
    end
    return "en_US"
end

local function lower(s)
    if Locale and Locale.ToLower then
        return Locale.ToLower(s)
    end
    return s:lower()
end

local function escapePattern(s)
    return (s:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0"))
end

-- Whole-word substring check: true when needle appears inside haystack
-- with a non-letter (or string boundary) on each side. Used to detect
-- when a localized unit name already bakes in the civ adjective (the
-- fr_FR row for TXT_KEY_UNIT_BABYLON_BOWMAN is "Archer Babylonien", so
-- prepending "babylonien" would speak the adjective twice). Lua 5.1's
-- %w is ASCII-only, so accented characters look like word separators
-- and the frontier still anchors correctly around any ASCII-letter
-- adjective form.
local function nameContainsAdj(name, adj)
    if name == "" or adj == "" then
        return false
    end
    local pat = "%f[%w]" .. escapePattern(lower(adj)) .. "%f[%W]"
    return lower(name):find(pat) ~= nil
end

-- Read live text from a Civ V control. Returns nil for nil/missing
-- controls and on engine throws so callers can join the result into a
-- preamble without hitting silent stale-text or crash paths. Some
-- engine builds throw from :GetText() during teardown / first-tick
-- showings; the pcall makes that survivable instead of taking the
-- whole onShow with it. The optional context argument is logged on
-- throws so debugging can locate which call site failed.
function Text.controlText(control, context)
    if control == nil then
        return nil
    end
    local ok, value = pcall(function()
        return control:GetText()
    end)
    if not ok then
        Log.error("Text.controlText" .. (context and (" [" .. context .. "]") or "") .. " threw: " .. tostring(value))
        return nil
    end
    if value == nil or value == "" then
        return nil
    end
    return value
end

-- Concatenate parts with sep (default ", "), dropping nil and empty entries.
-- Speech composers use this all over: a fixed sequence of optional fields
-- (status tokens, civ tradeables, deal entries, etc.) where some entries
-- are nil/empty for the current state and the join must not emit ", ,"
-- holes. Returns "" when every part is nil/empty so callers can branch
-- on emptiness with one comparison.
function Text.joinNonEmpty(parts, sep)
    local out = {}
    for _, p in ipairs(parts) do
        if p ~= nil and p ~= "" then
            out[#out + 1] = tostring(p)
        end
    end
    return table.concat(out, sep or ", ")
end

-- Compose a string from a list of Controls names: look up each by name,
-- skip nil and hidden controls, read text via Text.controlText (pcall +
-- nil-tolerant), drop empty, and concatenate with sep (default ", ").
-- The join target for Choose* preambles where the engine shows a screen
-- with a varying subset of header labels visible and the accessibility
-- preamble joins exactly the visible ones.
function Text.joinVisibleControls(controlNames, sep)
    local parts = {}
    for _, name in ipairs(controlNames) do
        local c = Controls[name]
        if c ~= nil and not c:IsHidden() then
            local text = Text.controlText(c, name)
            if text ~= nil and text ~= "" then
                parts[#parts + 1] = text
            end
        end
    end
    return table.concat(parts, sep or ", ")
end

-- religion is an optional already-resolved string (e.g. "Buddhism" or a
-- player-chosen custom religion name). When present it sits adjacent to
-- the unit-type word so the distinguishing token leads in adjective-first
-- locales ("Roman Buddhism Missionary") and stays close to the noun in
-- noun-adjective locales ("Missionnaire Buddhism romain"). Religion is
-- never run through the nameContainsAdj dedup -- religious unit types
-- (Missionary / Inquisitor / Great Prophet) never embed a civ adjective
-- in their name, so the dedup branch can't fire alongside a religion arg.
function Text.unitWithCiv(adjKey, nameKey, religion)
    local adj = Text.key(adjKey)
    local name = Text.key(nameKey)
    if nameContainsAdj(name, adj) then
        return name
    end
    if NOUN_ADJ_LOCALES[activeLocale()] then
        if religion ~= nil and religion ~= "" then
            return name .. " " .. religion .. " " .. adj
        end
        return name .. " " .. adj
    end
    if religion ~= nil and religion ~= "" then
        return adj .. " " .. religion .. " " .. name
    end
    return adj .. " " .. name
end

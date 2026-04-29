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

-- Compose "<civ adjective> <unit name>" through the base-game format
-- TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV. In some non-English locales
-- (notably French) the localized template uses a gender-form selector
-- on the adjective that requires gender metadata on the unit-name row.
-- When that tag is missing the engine logs "Could not deduce form
-- based on gender and plurality" and the result is unusable for
-- speech: it may contain raw template-syntax residue ({, ^, *, @) or
-- be empty/whitespace-only. Treat any of those as broken and compose
-- the pieces ourselves. Adjective ends up in default form and word
-- order is adjective-then-noun (English-like), which is suboptimal
-- grammar in romance locales but always intelligible -- and only
-- kicks in for entries the format would have mangled anyway.
local function looksBroken(s)
    if s == nil then
        return true
    end
    if s:find("^%s*$") then
        return true
    end
    if s:find("[{}@^*]") then
        return true
    end
    return false
end

local loggedFallbackPairs = {}

function Text.unitWithCiv(adjKey, nameKey)
    local out = Locale.ConvertTextKey("TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", adjKey, nameKey)
    if not looksBroken(out) then
        return out
    end
    local adj = Locale.ConvertTextKey(adjKey)
    local name = Locale.ConvertTextKey(nameKey)
    local fallback = adj .. " " .. name
    local pairKey = tostring(adjKey) .. "|" .. tostring(nameKey)
    if not loggedFallbackPairs[pairKey] then
        loggedFallbackPairs[pairKey] = true
        Log.warn(
            "Text.unitWithCiv fallback: adjKey="
                .. tostring(adjKey)
                .. " nameKey="
                .. tostring(nameKey)
                .. " out="
                .. string.format("%q", tostring(out))
                .. " adj="
                .. string.format("%q", tostring(adj))
                .. " name="
                .. string.format("%q", tostring(name))
                .. " fallback="
                .. string.format("%q", fallback)
        )
    end
    return fallback
end

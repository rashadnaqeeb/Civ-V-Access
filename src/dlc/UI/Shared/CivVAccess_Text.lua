-- Wrapper around Locale.ConvertTextKey that surfaces missing keys to the log.
-- A missing key in raw Locale silently returns the input string and the user
-- hears "TXT KEY FOO" spelled out. Routing through here turns that into an
-- actionable Log.warn while still returning something speakable.

Text = {}

local function lookup(key, ...)
    if type(key) == "string" and key:sub(1, 19) == "TXT_KEY_CIVVACCESS_" then
        local mapped = CivVAccess_Strings and CivVAccess_Strings[key]
        if mapped ~= nil then
            return mapped
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

function Text.format(keyName, ...)
    local out = lookup(keyName, ...)
    if out == keyName and isTxtKey(keyName) then
        Log.warn("Text: missing TXT_KEY " .. tostring(keyName))
    end
    return out
end

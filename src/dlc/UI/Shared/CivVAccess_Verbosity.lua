-- Verbosity setting. When on, BaseMenu and BaseTable announcements append
-- screen-reader-style metadata (control type tag, position-within-list, table
-- row/column counts, "table" suffix on tab names) at the END of each utterance
-- so the leading distinguishing word is unaffected.
--
-- Persisted via Prefs.getInt/setInt. The live value is cached on
-- civvaccess_shared so per-keypress reads don't round-trip through the
-- engine's user-data file.
--
-- No user-facing toggle yet; the future config menu will own that. For now,
-- dev-side changes go through Verbosity.setOn().

Verbosity = Verbosity or {}

local PREF_KEY = "Verbosity"
local DEFAULT_ON = true

function Verbosity.isOn()
    if civvaccess_shared.verbosity == nil then
        -- Some Contexts include BaseMenuItems (which calls isOn) but not
        -- CivVAccess_UserPrefs (popup boots, screen Access wrappers). Fall
        -- back to the default until any Context with Prefs lazy-inits the
        -- cache; the cross-Context cache then carries the read value to
        -- every subsequent caller.
        if Prefs == nil or type(Prefs.getInt) ~= "function" then
            return DEFAULT_ON
        end
        civvaccess_shared.verbosity = Prefs.getInt(PREF_KEY, DEFAULT_ON and 1 or 0) ~= 0
    end
    return civvaccess_shared.verbosity
end

function Verbosity.setOn(on)
    civvaccess_shared.verbosity = on and true or false
    if Prefs ~= nil and type(Prefs.setInt) == "function" then
        Prefs.setInt(PREF_KEY, civvaccess_shared.verbosity and 1 or 0)
    end
end

-- Append a comma-separated suffix from a TXT_KEY when verbosity is on.
-- Returns text unchanged when verbosity is off, kindKey is nil, or the
-- resolved suffix is empty. Centralizes the join so call sites don't repeat
-- the on/off + empty-string + concat dance.
function Verbosity.appendSuffix(text, kindKey)
    if not kindKey or not Verbosity.isOn() then
        return text
    end
    local suffix = Text.key(kindKey)
    if suffix == nil or suffix == "" then
        return text
    end
    if text == nil or text == "" then
        return suffix
    end
    return text .. ", " .. suffix
end

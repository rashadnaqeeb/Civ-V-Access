-- Markup stripping for Civ V text. Strips engine tokens ([NEWLINE], [COLOR_*],
-- [ICON_*], etc.), substitutes registered icons with spoken text, and
-- normalizes whitespace. Never invents or rewords content.

TextFilter = {}

local _iconMap = {}
local _warnedIcons = {}

function TextFilter.registerIcon(name, spoken)
    _iconMap[name] = spoken
end

-- Strip control chars except \n \r \t.
local function stripControl(s)
    return (s:gsub("[%z\1-\8\11\12\14-\31]", ""))
end

local function substituteIcons(s)
    return (s:gsub("%[(ICON_[A-Z0-9_]+)%]", function(name)
        local spoken = _iconMap[name]
        if spoken then return spoken end
        if not _warnedIcons[name] then
            _warnedIcons[name] = true
            if Log and Log.debug then
                Log.debug("TextFilter: stripping unregistered " .. name)
            end
        end
        return ""
    end))
end

function TextFilter.filter(text)
    if text == nil then return "" end
    local s = tostring(text)

    -- Fast path: no brackets, no emdash, no control chars.
    if not s:find("[%[\194-\244%z\1-\8\11\12\14-\31]") and not s:find("\226\128\148") then
        return (s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
    end

    s = stripControl(s)
    s = s:gsub("%[NEWLINE%]", " ")
    s = substituteIcons(s)
    s = s:gsub("%[COLOR_[A-Z0-9_]+%]", "")
    s = s:gsub("%[ENDCOLOR%]", "")
    -- Catch-all for remaining uppercase bracket tokens ([STYLE_*], [TAB], [BULLET], ...).
    s = s:gsub("%[([A-Z_0-9]+)%]", "")
    -- Emdash (U+2014, UTF-8 E2 80 94) -> space; screen readers say "dash".
    s = s:gsub("\226\128\148", " ")
    -- Artifacts left by tag removal.
    s = s:gsub(":%.", ".")
    -- Whitespace collapse + trim.
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

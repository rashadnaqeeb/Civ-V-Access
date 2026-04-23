-- Markup stripping for Civ V text. Strips engine tokens ([NEWLINE], [COLOR_*],
-- [ICON_*], etc.), substitutes registered icons with spoken text, and
-- normalizes whitespace. Never invents or rewords content.

TextFilter = {}

local _iconMap = {}

-- `aliases` is an optional list of extra spoken forms that should collapse
-- the icon when adjacent to the substituted text. The icon is always
-- substituted with `spoken`, never an alias; aliases only participate in
-- the dedup check. This covers cases where the same glyph sits next to
-- grammatical variants of its label (happiness/happy) that plain suffix
-- rules won't bridge.
function TextFilter.registerIcon(name, spoken, aliases)
    _iconMap[name] = { spoken = spoken, aliases = aliases or {} }
end

-- Strip control chars except \n \r \t.
local function stripControl(s)
    return (s:gsub("[%z\1-\8\11\12\14-\31]", ""))
end

-- Escape Lua pattern metacharacters so a spoken form containing e.g. "."
-- or "-" matches literally in the adjacency check below.
local function escapePattern(s)
    return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- Duplicate-speech guards. Base-game text often pairs an icon with its
-- English label (e.g. "has higher [ICON_STRENGTH] Combat Strength") so
-- the glyph visually reinforces the word for sighted readers. When we
-- substitute the icon with its spoken form ("combat strength") the
-- screen reader hears the same phrase twice. These helpers detect the
-- overlap so substituteIcons can drop the token entirely in that case.
-- Match is case-insensitive and whitespace-tolerant, and the adjacent
-- phrase must sit on word boundaries (no false hit on "gold"/"golden").
-- The `s?` before the boundary lets a singular spoken form collapse
-- against an adjacent English plural.
local function _matchesAfter(after, phrase)
    if phrase == "" then
        return false
    end
    local aligned = after:lower() .. "\0"
    return aligned:find("^%s*" .. escapePattern(phrase:lower()) .. "s?[^%w]") ~= nil
end

local function _matchesBefore(before, phrase)
    if phrase == "" then
        return false
    end
    local aligned = "\0" .. before:lower()
    return aligned:find("[^%w]" .. escapePattern(phrase:lower()) .. "s?%s*$") ~= nil
end

local function substituteIcons(s)
    local out = {}
    local cursor = 1
    while true do
        local startIdx, endIdx, name = s:find("%[(ICON_[A-Z0-9_]+)%]", cursor)
        if startIdx == nil then
            out[#out + 1] = s:sub(cursor)
            break
        end
        out[#out + 1] = s:sub(cursor, startIdx - 1)

        local record = _iconMap[name]
        local spoken
        if record == nil then
            spoken = ""
        else
            spoken = record.spoken
            if spoken ~= "" then
                local before = s:sub(1, startIdx - 1)
                local after = s:sub(endIdx + 1)
                local collapsed = _matchesAfter(after, spoken) or _matchesBefore(before, spoken)
                if not collapsed then
                    for _, alias in ipairs(record.aliases) do
                        if _matchesAfter(after, alias) or _matchesBefore(before, alias) then
                            collapsed = true
                            break
                        end
                    end
                end
                if collapsed then
                    spoken = ""
                end
            end
        end

        out[#out + 1] = spoken
        cursor = endIdx + 1
    end
    return table.concat(out)
end

function TextFilter.filter(text)
    if text == nil then
        return ""
    end
    local s = tostring(text)

    -- Fast path: no brackets, no emdash, no control chars.
    if not s:find("[%[\194-\244%z\1-\8\11\12\14-\31]") and not s:find("\226\128\148") then
        return (s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
    end

    s = stripControl(s)
    s = s:gsub("%[NEWLINE%]", " ")
    -- Strip color / closing markup BEFORE icon substitution so the dedup
    -- adjacency check sees clean text. Civ's pedia wraps the label that
    -- sits next to an icon in [COLOR_*]...[ENDCOLOR] (e.g.
    -- "[ICON_GOLD] [COLOR_POSITIVE_TEXT]Gold[ENDCOLOR]"); if the color
    -- tokens are still present when the icon runs, the dedup fails and
    -- the screen reader hears the label twice.
    s = s:gsub("%[COLOR_[A-Z0-9_]+%]", "")
    s = s:gsub("%[ENDCOLOR%]", "")
    -- Closing tags: [/COLOR] and [/RED] appear in tutorial and advisor copy.
    -- The catch-all below excludes the slash, so these would leak through.
    s = s:gsub("%[/[A-Z_0-9]+%]", "")
    -- Civilopedia link markup: [LINK=IMPROVEMENT_FARM]Farm[\LINK] wraps a
    -- label with a clickable jump-target. The opener carries an `=` payload
    -- and the closer uses a backslash, so neither matches the catch-all or
    -- the forward-slash closer rule above. Strip both tags while keeping
    -- the label text between them.
    s = s:gsub("%[LINK=[^%]]+%]", "")
    s = s:gsub("%[\\LINK%]", "")
    s = substituteIcons(s)
    -- Catch-all for remaining uppercase bracket tokens ([STYLE_*], [TAB],
    -- [BULLET], unregistered ICON_*, ...). Unregistered icons fall here
    -- and vanish silently; any icon worth speaking has to be in the
    -- registry.
    s = s:gsub("%[([A-Z_0-9]+)%]", "")
    -- Emdash (U+2014, UTF-8 E2 80 94) -> space; screen readers say "dash".
    s = s:gsub("\226\128\148", " ")
    -- Artifacts left by tag removal.
    s = s:gsub(":%.", ".")
    -- Whitespace collapse + trim.
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

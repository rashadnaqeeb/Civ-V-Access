-- Civilopedia article-body search. Public fns:
--   PediaSearch.match(query) -> matchSet, count
--     matchSet is keyed by article table identity -- the same article
--     tables the pedia's PopulateList functions insert into both
--     sortedList and searchableTextKeyList -- so callers can test
--     membership against the articles they walk out of sortedList
--     without any per-category entryID arithmetic. Each key's value is
--     the sentence of body text containing the match (for the caller to
--     speak after the article name), or true when no sentence could be
--     sliced -- test with truthiness, speak only strings.
--   PediaSearch.sentenceAround(entry, qStart, qEnd) -> sentence or nil
--     the slicer behind those values; public for the offline tests.
--   PediaSearch.createInput(opts) -> handler
--     modal text-capture handler (the ScannerInput pattern) pushed above
--     the pedia menu on Ctrl+F. opts.echoControl mirrors the buffer into
--     the pedia's visible search box; opts.onCommit(query) fires on Enter.
--
-- The engine's own pedia search is title-only, so body search has to
-- source its corpus from the localization layer: for each article we
-- convert the prose TXT_KEYs its SelectArticle renderer would display
-- (per-table column lists below, mirrored from the base pedia's
-- renderers) and store the lowercased concatenation. Matching is a plain
-- substring find over that text; titles are deliberately not part of the
-- corpus -- the picker's type-ahead already covers them.
--
-- Columns alone are not the whole body on every engine. Where an article's
-- effects block is composed at render time rather than stored (Vox Populi
-- blanks Buildings.Help and friends), the column read finds an empty string
-- and the block -- the mechanical effects players actually search for --
-- would be invisible. EngineData.*EffectsText is the seam that returns that
-- composed text, nil on engines whose column already carries it.
--
-- The corpus is built lazily on first search and kept for the session.
-- This does not violate the never-cache rule: article prose is static game
-- data (it cannot change within a session), not game state. The composed
-- effects text is ruleset-general for the same reason -- the seam asks for
-- it with no city and no player context, exactly as the pedia's own
-- renderer does. Load-from-game kills this Context's env, which drops the
-- cache naturally along with everything else.

PediaSearch = {}

local corpus = nil

-- Non-letter typeable keys. Virtual-key codes because the Keys enum only
-- carries VK_ names for non-printable keys; hyphen and apostrophe appear
-- often enough in pedia prose ("city-state") to be worth accepting.
local VK_OEM_MINUS = 0xBD
local VK_OEM_APOSTROPHE = 0xDE

-- One entry per GameInfo table the pedia draws articles from. keyCol is
-- the column PopulateList indexes searchableTextKeyList by (the article's
-- identity); cols are the prose columns that table's SelectArticle
-- renderer localizes into the article body. tagCol marks the civ/leader
-- pattern where prose lives under sequential keys derived from
-- CivilopediaTag rather than in row columns. bodyFn handles one-off
-- shapes (league project rewards). effectsFn names an EngineData seam call
-- that composes the article's effects block for engines that build it at
-- render time instead of storing it in a column (see below). Tables absent
-- from the running ruleset (Corporations outside Vox Populi) are skipped by
-- the GameInfo[name] guard in buildCorpus.
--
-- Every name in cols must be a column the table actually has. A GameInfo row
-- indexed by an unknown column yields the column NAME, so a wrong entry does
-- not error -- it seeds the corpus with that word and makes every row of the
-- table a hit for it (Routes has no Help column: both routes matched "help").
local SOURCES = {
    { table = "Concepts", keyCol = "Description", cols = { "Summary", "Extended", "DesignNotes" } },
    {
        table = "Technologies",
        keyCol = "Description",
        cols = { "Help", "Quote", "Civilopedia" },
        effectsFn = "techEffectsText",
    },
    {
        table = "Units",
        keyCol = "Description",
        cols = { "Help", "Strategy", "Civilopedia" },
        effectsFn = "unitEffectsText",
    },
    { table = "UnitPromotions", keyCol = "Description", cols = { "Help" } },
    {
        table = "Buildings",
        keyCol = "Description",
        cols = { "Help", "Strategy", "Civilopedia", "Quote" },
        effectsFn = "buildingEffectsText",
    },
    {
        table = "Projects",
        keyCol = "Description",
        cols = { "Help", "Strategy", "Civilopedia" },
        effectsFn = "projectEffectsText",
    },
    { table = "Policies", keyCol = "Description", cols = { "Help", "Civilopedia" } },
    { table = "Specialists", keyCol = "Description", cols = { "Help", "Strategy", "Civilopedia" } },
    { table = "Civilizations", keyCol = "ShortDescription", tagCol = "CivilopediaTag" },
    { table = "Leaders", keyCol = "Description", tagCol = "CivilopediaTag" },
    { table = "MinorCivilizations", keyCol = "Description", cols = { "Civilopedia" } },
    { table = "Terrains", keyCol = "Description", cols = { "Civilopedia" } },
    { table = "Features", keyCol = "Description", cols = { "Help", "Civilopedia" } },
    { table = "Resources", keyCol = "Description", cols = { "Help", "Civilopedia" } },
    { table = "Improvements", keyCol = "Description", cols = { "Help", "Civilopedia" } },
    { table = "Routes", keyCol = "Description", cols = { "Civilopedia" } },
    { table = "Religions", keyCol = "Description", cols = { "Civilopedia" } },
    { table = "Beliefs", keyCol = "ShortDescription", cols = { "Description" } },
    { table = "Resolutions", keyCol = "Description", cols = { "Help" } },
    { table = "LeagueProjects", keyCol = "Description", bodyFn = "leagueProject" },
    { table = "Corporations", keyCol = "Description", cols = { "Help" } },
}

-- Civ / leader prose: sequential <tag>_HEADING_i / <tag>_TEXT_i pairs
-- walked until the first missing pair, plus the optional factoid pair --
-- the same repeat-until the base pedia's civilization renderer runs.
local function appendTagLoop(parts, tag)
    if tag == nil or tag == "" then
        return
    end
    local i = 1
    while true do
        local headerTag = tag .. "_HEADING_" .. tostring(i)
        local bodyTag = tag .. "_TEXT_" .. tostring(i)
        if not (Locale.HasTextKey(headerTag) and Locale.HasTextKey(bodyTag)) then
            break
        end
        parts[#parts + 1] = Text.key(headerTag)
        parts[#parts + 1] = Text.key(bodyTag)
        i = i + 1
    end
    local factoidHeader = tag .. "_FACTOID_HEADING"
    local factoidBody = tag .. "_FACTOID_TEXT"
    if Locale.HasTextKey(factoidHeader) and Locale.HasTextKey(factoidBody) then
        parts[#parts + 1] = Text.key(factoidHeader)
        parts[#parts + 1] = Text.key(factoidBody)
    end
end

-- League project articles render their reward tiers' text rather than
-- own-row prose.
local function appendLeagueProjectBody(parts, row)
    for _, col in ipairs({ "RewardTier1", "RewardTier2", "RewardTier3" }) do
        local rewardType = row[col]
        if rewardType ~= nil then
            local reward = GameInfo.LeagueProjectRewards[rewardType]
            if reward ~= nil then
                if reward.Description ~= nil then
                    parts[#parts + 1] = Text.key(reward.Description)
                end
                if reward.Help ~= nil then
                    parts[#parts + 1] = Text.key(reward.Help)
                end
            end
        end
    end
end

local BODY_FNS = {
    leagueProject = appendLeagueProjectBody,
}

local function buildCorpus()
    local entries = {}
    -- How many entries the effects seam contributed to. Zero on vanilla and
    -- LekMod by design; zero on VP means the seam silently returned nothing
    -- and every composed effects block is missing from the corpus.
    local withEffects = 0
    for _, src in ipairs(SOURCES) do
        if GameInfo[src.table] ~= nil then
            local ok, err = pcall(function()
                for row in GameInfo[src.table]() do
                    local keyTag = row[src.keyCol]
                    if keyTag ~= nil and keyTag ~= "" then
                        local parts = {}
                        if src.cols ~= nil then
                            for _, col in ipairs(src.cols) do
                                local tag = row[col]
                                if tag ~= nil and tag ~= "" then
                                    parts[#parts + 1] = Text.key(tag)
                                end
                            end
                        end
                        if src.tagCol ~= nil then
                            appendTagLoop(parts, row[src.tagCol])
                        end
                        if src.bodyFn ~= nil then
                            BODY_FNS[src.bodyFn](parts, row)
                        end
                        if src.effectsFn ~= nil then
                            local effects = EngineData[src.effectsFn](row.ID)
                            if effects ~= nil and effects ~= "" then
                                parts[#parts + 1] = effects
                                withEffects = withEffects + 1
                            end
                        end
                        if #parts > 0 then
                            -- raw keeps the original case so a sentence
                            -- sliced out of it still carries the uppercase
                            -- markup tokens ([NEWLINE], [ICON_*]) TextFilter
                            -- strips at speech time; body is what match()
                            -- scans.
                            local raw = table.concat(parts, " ")
                            entries[#entries + 1] = {
                                keyTag = keyTag,
                                raw = raw,
                                body = Locale.ToLower(raw),
                            }
                        end
                    end
                end
            end)
            if not ok then
                Log.error("PediaSearch: corpus build failed for " .. src.table .. ": " .. tostring(err))
            end
        end
    end
    return entries, withEffects
end

-- Sentence terminators bounding the snippet sliced around a match. Found
-- on the lowered body (where the match offsets live), hence the lowercase
-- newline token; the full-width enders cover Japanese / Chinese prose,
-- which ToLower leaves byte-identical. Colons and decimal points inside a
-- sentence over-split occasionally ("+2.5" loses its "+2"); the cost is a
-- slightly short snippet, never a wrong one.
local BOUNDARY_TOKENS = { ".", "!", "?", "[newline]", "。", "！", "？" }

-- Slice the sentence containing the match at [qStart, qEnd] out of a
-- corpus entry: the text between the boundary token preceding qStart and
-- the one following qEnd, keeping a punctuation terminator (natural
-- speech pause) but not a newline token. Boundary positions come from
-- entry.body but the slice is taken from entry.raw, whose original-case
-- markup TextFilter recognizes at speech time -- valid only while the two
-- agree byte-for-byte in length, which every shipped locale's ToLower
-- preserves; on a mismatch return nil and the caller degrades to a plain
-- title label. Boundary tokens inside the match itself never split it.
function PediaSearch.sentenceAround(entry, qStart, qEnd)
    local body = entry.body
    if #entry.raw ~= #body then
        return nil
    end
    local sStart = 1
    local sEnd = #body
    for _, tok in ipairs(BOUNDARY_TOKENS) do
        local init = 1
        while true do
            local bs, be = string.find(body, tok, init, true)
            if bs == nil then
                break
            end
            if be < qStart then
                if be + 1 > sStart then
                    sStart = be + 1
                end
            elseif bs > qEnd then
                local candidate = (tok == "[newline]") and bs - 1 or be
                if candidate < sEnd then
                    sEnd = candidate
                end
                -- Later occurrences of this token are further right still.
                break
            end
            init = be + 1
        end
    end
    local sentence = string.sub(entry.raw, sStart, sEnd):gsub("^%s+", ""):gsub("%s+$", "")
    if sentence == "" then
        return nil
    end
    return sentence
end

-- Substring-match query against every corpus body and resolve hits
-- through the pedia's searchableTextKeyList (the promoted global keyed
-- by the same keyCol tags SOURCES uses). Corpus rows whose tag misses
-- the list are silently skipped -- that is the pedia telling us the row
-- isn't an article in the running ruleset (minor-civ leaders, concepts
-- without a pedia header, content the active mods removed). Multiple
-- corpus rows can resolve to one article (a leader and its civ), so the
-- set dedupes by article identity -- the first matching row supplies the
-- spoken sentence -- and count tracks distinct articles.
function PediaSearch.match(query)
    if corpus == nil then
        -- Timed and logged: the build runs inside the Enter keypress, and on
        -- an engine that composes effects text it costs seconds rather than
        -- milliseconds (a text-composition call per building, unit, tech and
        -- project). The number is what tells a maintainer whether a re-pin
        -- made that cost worse.
        local startedAt = os.clock()
        local withEffects
        corpus, withEffects = buildCorpus()
        local elapsedMs = math.floor((os.clock() - startedAt) * 1000)
        Log.info(
            "PediaSearch: corpus built, "
                .. tostring(#corpus)
                .. " entries ("
                .. tostring(withEffects)
                .. " with composed effects text) in "
                .. tostring(elapsedMs)
                .. " ms"
        )
    end
    local matchSet = {}
    local count = 0
    local q = Locale.ToLower(query or "")
    if q == "" then
        return matchSet, 0
    end
    for _, entry in ipairs(corpus) do
        local qStart, qEnd = string.find(entry.body, q, 1, true)
        if qStart ~= nil then
            local article = searchableTextKeyList[entry.keyTag]
            if article ~= nil and matchSet[article] == nil then
                matchSet[article] = PediaSearch.sentenceAround(entry, qStart, qEnd) or true
                count = count + 1
            end
        end
    end
    return matchSet, count
end

-- Modal query capture, pushed above the pedia menu on Ctrl+F. Printable
-- keystrokes append to an internal buffer silently (the user's screen
-- reader provides typing echo) and are mirrored into opts.echoControl so
-- a sighted partner watches the query land in the game's own search box.
-- Enter commits through opts.onCommit (which owns all result speech);
-- Enter on an empty buffer and Escape both just cancel. capturesAllInput
-- stops unconsumed keys from falling into the pedia menu's bindings
-- mid-query.
function PediaSearch.createInput(opts)
    local echoControl = opts.echoControl
    local onCommit = opts.onCommit

    local self = {
        name = "PediaSearchInput",
        capturesAllInput = true,
        -- No bindings table: every key routes through handleSearchInput
        -- so the modal capture is all in one place.
        bindings = {},
        helpEntries = {},
        _buffer = "",
    }

    local function pop()
        HandlerStack.removeByName("PediaSearchInput")
    end

    local function setBuffer(me, text)
        me._buffer = text
        if echoControl ~= nil then
            echoControl:SetText(text)
        end
    end

    local function charForVk(vk)
        if vk >= 0x41 and vk <= 0x5A then
            return string.char(vk + 32)
        end
        if vk >= 0x30 and vk <= 0x39 then
            return string.char(vk)
        end
        if vk == VK_OEM_MINUS then
            return "-"
        end
        if vk == VK_OEM_APOSTROPHE then
            return "'"
        end
        return nil
    end

    function self.handleSearchInput(me, vk, mods)
        -- Ctrl / Alt chords are hotkey territory, not typing. Falling
        -- through lands them in the binding walk, where our empty
        -- bindings table plus capturesAllInput swallows them.
        local hasCtrl = math.floor(mods / 2) % 2 == 1
        local hasAlt = math.floor(mods / 4) % 2 == 1
        if hasCtrl or hasAlt then
            return false
        end
        if vk == Keys.VK_RETURN then
            local query = me._buffer
            pop()
            if query ~= "" then
                onCommit(query)
            end
            return true
        end
        if vk == Keys.VK_ESCAPE then
            setBuffer(me, "")
            pop()
            return true
        end
        if vk == Keys.VK_BACK then
            if #me._buffer > 0 then
                setBuffer(me, string.sub(me._buffer, 1, -2))
            end
            return true
        end
        if vk == Keys.VK_SPACE then
            if #me._buffer > 0 then
                setBuffer(me, me._buffer .. " ")
            end
            return true
        end
        local ch = charForVk(vk)
        if ch ~= nil then
            setBuffer(me, me._buffer .. ch)
            return true
        end
        return false
    end

    return self
end

return PediaSearch

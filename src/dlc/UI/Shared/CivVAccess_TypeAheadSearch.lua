-- Type-ahead search helper used by BaseMenu. Ported from oni-access's
-- OniAccess/Handlers/TypeAheadSearch.cs; the matching rules are identical.
--
-- Tiers (lower wins):
--   0  start-of-string whole word ("wood" in "wood club")
--   1  start-of-string prefix     ("wood" in "wooden club")
--   2  mid-string whole word      ("wood" in "pine wood")
--   3  mid-string word prefix     ("wood" in "a wooden thing")
--   4  substring anywhere         ("wood" in "plywood")
--   5  space-delimited word-prefix abbreviation ("ga pi" in "gas pipe")
--
-- Within a tier, results sort by name length ascending (shorter names rank
-- first), with match position as tiebreaker. "Name" is the portion of the
-- label before the first comma: builders concatenate "Name, size, desc..."
-- and matches inside the description rank after matches inside the name.
--
-- Repeat single-letter: typing the same letter as a one-char buffer cycles
-- through start-of-string results only (tiers 0-1), so holding a key does
-- not wrap into substring matches.
--
-- Consumers describe their list with a searchable interface:
--   search:handleChar(c, searchable) -> bool   consume a typed letter
--   search:handleKey(vk, ctrl, alt, searchable) -> bool   Up/Down/Home/End
--                                                / Backspace / Space (when
--                                                the buffer is non-empty)
-- where searchable has:
--   itemCount              number
--   getLabel(i)            string (nil to skip)
--   moveTo(i)              set cursor + announce (search cycles pass the
--                          original index here)
--
-- Unicode / diacritics: unlike the C# implementation, this module does not
-- normalize accented characters. Lua 5.1 has no built-in NFD and the mod's
-- current consumers (menu labels, mostly English TXT_KEY text) do not need
-- it. If that changes, add a preprocess hook here; mirror the ligature
-- expansion (œ -> oe, æ -> ae) the C# version does.

TypeAheadSearch = {}

local TIER_COUNT = 6

-- Match-tier classifier. Returns (tier, position) or (-1, -1) for no match.
-- Lowercase inputs expected.
local function matchTier(lowerName, lowerPrefix)
    local prefixLen = #lowerPrefix
    if prefixLen == 0 or prefixLen > #lowerName then return -1, -1 end

    -- Start of string.
    if string.sub(lowerName, 1, prefixLen) == lowerPrefix then
        local afterByte = string.byte(lowerName, prefixLen + 1)
        local wholeWord = (afterByte == nil) or (afterByte == 32) or (afterByte == 44)
        return (wholeWord and 0 or 1), 0
    end

    -- Word starts after spaces or commas.
    local n = #lowerName
    for i = 2, n do
        local prev = string.byte(lowerName, i - 1)
        if prev == 32 or prev == 44 then
            local here = string.byte(lowerName, i)
            if here ~= 32 and n - i + 1 >= prefixLen then
                if string.sub(lowerName, i, i + prefixLen - 1) == lowerPrefix then
                    local afterByte = string.byte(lowerName, i + prefixLen)
                    local wholeWord = (afterByte == nil) or (afterByte == 32) or (afterByte == 44)
                    return (wholeWord and 2 or 3), i - 1
                end
            end
        end
    end

    -- Substring anywhere.
    local idx = string.find(lowerName, lowerPrefix, 1, true)
    if idx ~= nil then return 4, idx - 1 end

    -- Space-delimited word-prefix abbreviation ("ga pi" in "gas pipe").
    if string.find(lowerPrefix, " ", 1, true) ~= nil then
        local pos = TypeAheadSearch._matchWordPrefixTokens(lowerName, lowerPrefix)
        if pos >= 0 then return 5, pos end
    end

    return -1, -1
end

-- Returns the byte-offset of the first matched word if every space-delimited
-- token in lowerPrefix is a prefix of a distinct word in lowerName, consumed
-- in order and all within a single comma-delimited segment. -1 otherwise.
-- Cross-segment matches are rejected so the returned position meaningfully
-- identifies where in the label (pre-comma or post-comma) the match landed;
-- callers use that position to separate name matches from description ones.
function TypeAheadSearch._matchWordPrefixTokens(lowerName, lowerPrefix)
    local tokens = {}
    for tok in string.gmatch(lowerPrefix, "[^ ]+") do
        tokens[#tokens + 1] = tok
    end
    local tokenCount = #tokens
    if tokenCount == 0 then return -1 end

    local n = #lowerName
    local tokenIdx = 1
    local firstPos = -1
    local i = 1
    while i <= n do
        local c = string.byte(lowerName, i)
        if c == 44 then
            -- Segment boundary: reset and continue in the next segment.
            tokenIdx = 1
            firstPos = -1
            i = i + 1
        elseif c == 32 then
            i = i + 1
        else
            if tokenIdx <= tokenCount then
                local tok = tokens[tokenIdx]
                local toklen = #tok
                if i + toklen - 1 <= n
                        and string.sub(lowerName, i, i + toklen - 1) == tok then
                    if tokenIdx == 1 then firstPos = i - 1 end
                    tokenIdx = tokenIdx + 1
                    if tokenIdx > tokenCount then return firstPos end
                    i = i + toklen
                end
            end
            -- Advance past the rest of this word (to its space / comma).
            while i <= n do
                local b = string.byte(lowerName, i)
                if b == 32 or b == 44 then break end
                i = i + 1
            end
        end
    end
    return -1
end

TypeAheadSearch.matchTier = matchTier

-- Instance ---------------------------------------------------------------

local Instance = {}
Instance.__index = Instance

function TypeAheadSearch.new()
    local self = setmetatable({
        _buffer          = "",
        _isSearchActive  = false,
        _resultIndices   = {},
        _resultNames     = {},
        _resultCursor    = 1,
    }, Instance)
    return self
end

function Instance:buffer()       return self._buffer end
function Instance:hasBuffer()    return #self._buffer > 0 end
function Instance:isSearchActive() return self._isSearchActive end
function Instance:resultCount()  return #self._resultIndices end

-- 1-based original-list index of the currently selected result, or nil.
function Instance:selectedOriginalIndex()
    if not self._isSearchActive then return nil end
    local idx = self._resultCursor
    if idx < 1 or idx > #self._resultIndices then return nil end
    return self._resultIndices[idx]
end

function Instance:addChar(c)
    self._buffer = self._buffer .. c
    return self._buffer
end

function Instance:removeChar()
    if #self._buffer == 0 then return false end
    self._buffer = string.sub(self._buffer, 1, #self._buffer - 1)
    return true
end

function Instance:clear()
    self._buffer = ""
    self._isSearchActive = false
    self._resultIndices = {}
    self._resultNames = {}
    self._resultCursor = 1
end

local function isAllSameChar(s)
    local first = string.byte(s, 1)
    for i = 2, #s do
        if string.byte(s, i) ~= first then return false end
    end
    return true
end

-- In-place stable insertion sort by (sortLength asc, position asc).
local function sortTier(indices, names, positions, sortLengths, inSegment)
    for i = 2, #positions do
        local pos = positions[i]
        local idx = indices[i]
        local name = names[i]
        local len = sortLengths[i]
        local seg = inSegment[i]
        local j = i - 1
        while j >= 1
                and (sortLengths[j] > len
                    or (sortLengths[j] == len and positions[j] > pos)) do
            positions[j + 1]   = positions[j]
            indices[j + 1]     = indices[j]
            names[j + 1]       = names[j]
            sortLengths[j + 1] = sortLengths[j]
            inSegment[j + 1]   = inSegment[j]
            j = j - 1
        end
        positions[j + 1]   = pos
        indices[j + 1]     = idx
        names[j + 1]       = name
        sortLengths[j + 1] = len
        inSegment[j + 1]   = seg
    end
end

-- Run a search against itemCount items. nameByIndex(i) returns the label or
-- nil to skip. moveTo(origIndex) is the callback invoked on every announced
-- result (receives the original 1-based index of the selected item).
function Instance:search(itemCount, nameByIndex, moveTo)
    self._moveTo = moveTo
    local buf = self._buffer

    -- Single-letter repeat: cycle within tiers 0-1 without re-running.
    if self._isSearchActive and #self._resultIndices > 0
            and #buf > 1 and isAllSameChar(buf) then
        self._buffer = string.sub(buf, 1, 1)
        self:_cycleStartsWithResults()
        return
    end

    if #buf == 0 or itemCount == 0 then
        self._resultIndices = {}
        self._resultNames = {}
        self._resultCursor = 1
        self._isSearchActive = true
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH", buf))
        return
    end

    local trimmed = buf:match("^(.-)%s*$") or buf
    if #trimmed == 0 then
        self._resultIndices = {}
        self._resultNames = {}
        self._resultCursor = 1
        self._isSearchActive = true
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH", buf))
        return
    end
    local lowerBuffer = string.lower(trimmed)

    -- Tier buckets.
    local tiers = {}
    for t = 0, TIER_COUNT - 1 do
        tiers[t] = {
            indices = {}, names = {}, positions = {},
            sortLengths = {}, inSegment = {},
        }
    end

    for i = 1, itemCount do
        local name = nameByIndex(i)
        if name ~= nil and #name > 0 then
            local tier, pos = matchTier(string.lower(name), lowerBuffer)
            if tier >= 0 then
                local bucket = tiers[tier]
                bucket.indices[#bucket.indices + 1]   = i
                bucket.names[#bucket.names + 1]       = name
                bucket.positions[#bucket.positions + 1] = pos
                local comma = string.find(name, ",", 1, true)
                local nameLen = comma and (comma - 1) or #name
                bucket.sortLengths[#bucket.sortLengths + 1] = nameLen
                bucket.inSegment[#bucket.inSegment + 1] = (pos < nameLen) and 0 or 1
            end
        end
    end

    for t = 0, TIER_COUNT - 1 do
        local b = tiers[t]
        if #b.indices > 1 then
            sortTier(b.indices, b.names, b.positions, b.sortLengths, b.inSegment)
        end
    end

    -- Merge: pre-comma matches across all tiers come before post-comma.
    local outIdx, outNames = {}, {}
    for inSeg = 0, 1 do
        for t = 0, TIER_COUNT - 1 do
            local b = tiers[t]
            for i = 1, #b.indices do
                if b.inSegment[i] == inSeg then
                    outIdx[#outIdx + 1] = b.indices[i]
                    outNames[#outNames + 1] = b.names[i]
                end
            end
        end
    end

    self._isSearchActive = true
    if #outIdx == 0 then
        self._resultIndices = {}
        self._resultNames = {}
        self._resultCursor = 1
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH", buf))
    else
        self._resultIndices = outIdx
        self._resultNames = outNames
        self._resultCursor = 1
        self:_announceCurrentResult()
    end
end

function Instance:_cycleStartsWithResults()
    if #self._resultIndices == 0 then return end
    local firstChar = string.byte(string.lower(self._buffer), 1)
    local count = 0
    for i = 1, #self._resultNames do
        local head = string.byte(string.lower(self._resultNames[i]), 1)
        if head == firstChar then count = count + 1 else break end
    end
    if count == 0 then return end
    self._resultCursor = (self._resultCursor % count) + 1
    self:_announceCurrentResult()
end

function Instance:navigateResults(direction)
    local n = #self._resultIndices
    if n == 0 then return end
    local cursor = self._resultCursor - 1
    cursor = (cursor + direction) % n
    if cursor < 0 then cursor = cursor + n end
    self._resultCursor = cursor + 1
    self:_announceCurrentResult()
end

function Instance:jumpToFirstResult()
    if #self._resultIndices == 0 then return end
    self._resultCursor = 1
    self:_announceCurrentResult()
end

function Instance:jumpToLastResult()
    local n = #self._resultIndices
    if n == 0 then return end
    self._resultCursor = n
    self:_announceCurrentResult()
end

function Instance:_announceCurrentResult()
    if #self._resultIndices == 0 then return end
    local origIndex = self._resultIndices[self._resultCursor]
    if self._moveTo ~= nil then
        self._moveTo(origIndex)
    else
        SpeechPipeline.speakInterrupt(self._resultNames[self._resultCursor])
    end
end

-- Character input. Returns true when consumed.
function Instance:handleChar(c, searchable)
    if not self._isSearchActive and searchable.itemCount() == 0 then
        return false
    end
    self:addChar(c)
    self:search(searchable.itemCount(), searchable.getLabel, searchable.moveTo)
    return true
end

local KEY_UP    = 38
local KEY_DOWN  = 40
local KEY_HOME  = 36
local KEY_END   = 35
local KEY_BACK  = 8
local KEY_SPACE = 32

-- Non-character keys. Returns true when consumed.
function Instance:handleKey(vk, ctrl, alt, searchable)
    if self._isSearchActive then
        if vk == KEY_UP then
            self:navigateResults(-1); return true
        elseif vk == KEY_DOWN then
            self:navigateResults(1); return true
        elseif vk == KEY_HOME then
            self:jumpToFirstResult(); return true
        elseif vk == KEY_END then
            self:jumpToLastResult(); return true
        elseif vk == KEY_BACK then
            if not self:removeChar() then return true end
            if not self:hasBuffer() then
                self:clear()
                SpeechPipeline.speakInterrupt(
                    Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
                return true
            end
            self:search(searchable.itemCount(), searchable.getLabel, searchable.moveTo)
            return true
        elseif vk == KEY_SPACE and not ctrl and not alt then
            self:addChar(" ")
            self:search(searchable.itemCount(), searchable.getLabel, searchable.moveTo)
            return true
        end
        return false
    end

    -- Inactive with leftover buffer: backspace still rewinds it.
    if vk == KEY_BACK and self:hasBuffer() then
        if not self:removeChar() then return true end
        if not self:hasBuffer() then
            self:clear()
            SpeechPipeline.speakInterrupt(
                Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
            return true
        end
        self:search(searchable.itemCount(), searchable.getLabel, searchable.moveTo)
        return true
    end
    return false
end

return TypeAheadSearch

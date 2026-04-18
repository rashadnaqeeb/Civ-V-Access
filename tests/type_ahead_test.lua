-- TypeAheadSearch tests. Mirrors oni-access's TypeAheadSearch suite
-- (OniAccess.Tests/Program.cs) so the two implementations stay in sync on
-- tier semantics, sort rules, and single-letter cycling.

local T = require("support")
local M = {}

local speaks

local function setup()
    speaks = {}
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
end

-- Fixture items: same labels as the ONI suite's SearchItems so tier
-- numbering and expected indices line up. Note ONI's list is 0-indexed;
-- here we use 1-based indices, so every expected "index N" in the ONI
-- tests becomes "N+1" here.
--   1 Apple          (matches "a" at tier 1)
--   2 Apricot        (matches "a" at tier 1)
--   3 Banana         (matches "a" at tier 4 substring; "b" at tier 1)
--   4 Blue Cheese    (matches "b" at tier 1; "c" at tier 3 mid-prefix)
--   5 Cherry         (matches "c" at tier 1)
local SEARCH_ITEMS = { "Apple", "Apricot", "Banana", "Blue Cheese", "Cherry" }

local function labelAt(i)
    return SEARCH_ITEMS[i]
end

local function searchable(items)
    items = items or SEARCH_ITEMS
    return {
        itemCount = function() return #items end,
        getLabel  = function(i) return items[i] end,
        moveTo    = function() end,
    }
end

-- MatchTier --------------------------------------------------------------

function M.test_match_tier_start_whole_word()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("wood club", "wood")
    T.eq(tier, 0); T.eq(pos, 0)
end

function M.test_match_tier_start_prefix()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("wooden club", "wood")
    T.eq(tier, 1); T.eq(pos, 0)
end

function M.test_match_tier_mid_whole_word()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("pine wood", "wood")
    T.eq(tier, 2); T.eq(pos, 5)
end

function M.test_match_tier_mid_prefix()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("a wooden thing", "wood")
    T.eq(tier, 3); T.eq(pos, 2)
end

function M.test_match_tier_substring()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("plywood", "wood")
    T.eq(tier, 4); T.eq(pos, 3)
end

function M.test_match_tier_no_match()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("banana", "wood")
    T.eq(tier, -1); T.eq(pos, -1)
end

function M.test_match_tier_multi_token_abbreviation()
    setup()
    local tier, pos = TypeAheadSearch.matchTier("gas pipe", "ga pi")
    T.eq(tier, 5); T.eq(pos, 0)
end

function M.test_match_tier_multi_token_order_required()
    setup()
    local tier = TypeAheadSearch.matchTier("gas pipe", "pi ga")
    T.eq(tier, -1, "out-of-order tokens reject")
end

function M.test_match_tier_multi_token_cross_segment_rejected()
    setup()
    -- Tokens must all land in the same segment. Here "ga" only appears in
    -- the name segment and "pi" only in the description; they should not
    -- combine across the comma.
    local label = "gas vent, 1x1, vents gas from pipes into a room"
    local tier, pos = TypeAheadSearch.matchTier(label, "ga pi")
    local comma = string.find(label, ",", 1, true) - 1
    -- Acceptable outcomes: tier 5 match entirely post-comma, OR tier -1.
    -- We accept tier 5 only if pos > firstComma (i.e. post-comma segment).
    T.truthy(tier == -1 or (tier == 5 and pos > comma),
        "cross-segment match must not synthesize a pre-comma hit")
end

-- Search() results -------------------------------------------------------

function M.test_search_word_start_match()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("a")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    -- 'a' matches Apple(1,t1), Apricot(2,t1), Banana(3,t4 substring)
    T.eq(s:resultCount(), 3)
    T.eq(s:selectedOriginalIndex(), 1)
end

function M.test_search_mid_word_match()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("c")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    -- 'c' matches Cherry(5,t1), Blue Cheese(4,t3 mid-prefix), Apricot(2,t4)
    T.eq(s:resultCount(), 3)
    local saw = {}
    for _ = 1, s:resultCount() do
        saw[s:selectedOriginalIndex()] = true
        s:navigateResults(1)
    end
    T.truthy(saw[4], "Blue Cheese in results (mid-word)")
end

function M.test_search_case_insensitive()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("B")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    T.eq(s:resultCount(), 2, "uppercase query still matches Banana + Blue Cheese")
end

function M.test_search_multi_char_narrowing()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("a"); s:search(#SEARCH_ITEMS, labelAt, function() end)
    local afterA = s:resultCount()
    s:addChar("p"); s:search(#SEARCH_ITEMS, labelAt, function() end)
    local afterAp = s:resultCount()
    s:addChar("r"); s:search(#SEARCH_ITEMS, labelAt, function() end)
    local afterApr = s:resultCount()
    T.eq(afterA, 3); T.eq(afterAp, 2); T.eq(afterApr, 1)
    T.eq(s:selectedOriginalIndex(), 2, "'apr' narrows to Apricot")
end

function M.test_repeat_letter_cycles_in_tiers_0_1()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("a")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    local first = s:selectedOriginalIndex()        -- Apple(1)
    s:addChar("a")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    local second = s:selectedOriginalIndex()       -- Apricot(2)
    s:addChar("a")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    local third = s:selectedOriginalIndex()        -- wraps to Apple(1), not Banana
    T.eq(first, 1)
    T.eq(second, 2)
    T.eq(third, 1, "cycle stays in start-of-string results, does not reach Banana substring")
    T.eq(s:buffer(), "a", "buffer shortened to single letter during cycle")
end

function M.test_backspace_widens_results()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("a"); s:addChar("p")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    local afterAp = s:resultCount()
    s:removeChar()
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    local afterBs = s:resultCount()
    T.eq(afterAp, 2)
    T.eq(afterBs, 3, "backspace from 'ap' to 'a' restores Banana substring")
end

function M.test_navigate_wraps()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("a")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    s:navigateResults(1); s:navigateResults(1); s:navigateResults(1)
    T.eq(s:selectedOriginalIndex(), 1, "wrap returns to first result")
end

function M.test_jump_first_last()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("a")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    s:jumpToLastResult()
    local last = s:selectedOriginalIndex()
    s:jumpToFirstResult()
    local first = s:selectedOriginalIndex()
    T.eq(last, 3)
    T.eq(first, 1)
end

function M.test_no_match_keeps_search_active()
    setup()
    local s = TypeAheadSearch.new()
    s:addChar("z")
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    T.eq(s:resultCount(), 0)
    T.truthy(s:isSearchActive(), "search stays active with empty results so further keys still route here")
end

-- Tier ordering (covers the full six-tier merge) ------------------------

function M.test_tier_ordering_full_sweep()
    setup()
    local items = { "Plywood", "A Wooden Thing", "Pine Wood", "Wooden Axe", "Wood Club" }
    local s = TypeAheadSearch.new()
    s:addChar("w"); s:addChar("o"); s:addChar("o"); s:addChar("d")
    s:search(#items, function(i) return items[i] end, function() end)
    -- Expected (1-based original indices): Wood Club(5,t0), Wooden Axe(4,t1),
    -- Pine Wood(3,t2), A Wooden Thing(2,t3), Plywood(1,t4).
    T.eq(s:resultCount(), 5)
    local expected = { 5, 4, 3, 2, 1 }
    for i, exp in ipairs(expected) do
        T.eq(s:selectedOriginalIndex(), exp, "tier-ordered position " .. i)
        if i < #expected then s:navigateResults(1) end
    end
end

function M.test_within_tier_position_sort()
    setup()
    local items = { "Fried Mushroom", "Washroom" }
    local s = TypeAheadSearch.new()
    s:addChar("r"); s:addChar("o"); s:addChar("o"); s:addChar("m")
    s:search(#items, function(i) return items[i] end, function() end)
    T.eq(s:resultCount(), 2)
    T.eq(s:selectedOriginalIndex(), 2, "Washroom (shorter name) ranks first")
end

function M.test_within_tier_name_length_tiebreaker()
    setup()
    local items = { "Wood Club", "Wooden", "Wood" }
    local s = TypeAheadSearch.new()
    s:addChar("w")
    s:search(#items, function(i) return items[i] end, function() end)
    -- All three are tier 1 (start-of-string). Sort by length ascending:
    -- Wood(3, len 4), Wooden(2, len 6), Wood Club(1, len 9).
    T.eq(s:selectedOriginalIndex(), 3)
    s:navigateResults(1); T.eq(s:selectedOriginalIndex(), 2)
    s:navigateResults(1); T.eq(s:selectedOriginalIndex(), 1)
end

function M.test_length_beats_position_within_tier()
    setup()
    local items = { "Oakwood Shelf", "Pinewood" }
    local s = TypeAheadSearch.new()
    s:addChar("w"); s:addChar("o"); s:addChar("o"); s:addChar("d")
    s:search(#items, function(i) return items[i] end, function() end)
    -- Both tier 4. Oakwood Shelf has earlier position (3 vs 4) but is
    -- longer (13 vs 8). Length wins: Pinewood (index 2) ranks first.
    T.eq(s:selectedOriginalIndex(), 2)
end

-- Space / multi-token ---------------------------------------------------

function M.test_space_multi_word()
    setup()
    local s = TypeAheadSearch.new()
    for _, c in ipairs({ "b", "l", "u", "e", " ", "c" }) do s:addChar(c) end
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    T.eq(s:resultCount(), 1)
    T.eq(s:selectedOriginalIndex(), 4, "'blue c' matches Blue Cheese only")
end

function M.test_trailing_space_ignored()
    setup()
    local s = TypeAheadSearch.new()
    for _, c in ipairs({ "b", "l", "u", "e", " " }) do s:addChar(c) end
    s:search(#SEARCH_ITEMS, labelAt, function() end)
    T.eq(s:resultCount(), 1)
    T.eq(s:selectedOriginalIndex(), 4, "trailing space trimmed, still matches Blue Cheese")
end

function M.test_multi_token_abbreviation()
    setup()
    local items = { "Gas Pipe", "Liquid Pipe", "Gas Reservoir" }
    local s = TypeAheadSearch.new()
    for _, c in ipairs({ "g", "a", " ", "p", "i" }) do s:addChar(c) end
    s:search(#items, function(i) return items[i] end, function() end)
    T.eq(s:resultCount(), 1, "each single-token-only candidate excluded")
    T.eq(s:selectedOriginalIndex(), 1)
end

-- Name-vs-description ranking -------------------------------------------

function M.test_name_match_beats_description_match()
    setup()
    local items = {
        "Gas Bridge, 1x1, runs one gas pipe section over another",
        "Liquid Pipe, 1x1, transports liquid",
    }
    local s = TypeAheadSearch.new()
    for _, c in ipairs({ "p", "i", "p", "e" }) do s:addChar(c) end
    s:search(#items, function(i) return items[i] end, function() end)
    T.eq(s:resultCount(), 2)
    T.eq(s:selectedOriginalIndex(), 2,
        "name-segment match beats description-segment match regardless of name length")
end

function M.test_sorts_by_name_length_not_full_label()
    setup()
    local items = {
        "Gas Pipe Element Sensor, 1x1, short desc",
        "Gas Pipe, 1x1, lots of extra padding description text here",
    }
    local s = TypeAheadSearch.new()
    for _, c in ipairs({ "g", "a", " ", "p", "i" }) do s:addChar(c) end
    s:search(#items, function(i) return items[i] end, function() end)
    T.eq(s:resultCount(), 2)
    T.eq(s:selectedOriginalIndex(), 2,
        "name-only length (not full label length) drives sort")
end

-- Interface wrappers -----------------------------------------------------

function M.test_handle_char_delegates_to_search()
    setup()
    local moved = {}
    local sb = {
        itemCount = function() return #SEARCH_ITEMS end,
        getLabel  = function(i) return SEARCH_ITEMS[i] end,
        moveTo    = function(i) moved[#moved + 1] = i end,
    }
    local s = TypeAheadSearch.new()
    T.truthy(s:handleChar("a", sb))
    T.truthy(s:isSearchActive())
    T.eq(moved[1], 1, "moveTo fired on first result (Apple)")
end

function M.test_handle_key_backspace_clears_on_empty_buffer()
    setup()
    local sb = searchable()
    local s = TypeAheadSearch.new()
    s:handleChar("a", sb)
    local cleared = 0
    SpeechPipeline._speakAction = function() cleared = cleared + 1 end
    s:handleKey(8, false, false, sb)
    T.falsy(s:isSearchActive(), "backspace-to-empty clears search")
    T.eq(s:buffer(), "")
end

function M.test_handle_key_up_down_navigate_when_active()
    setup()
    local moved = {}
    local sb = {
        itemCount = function() return #SEARCH_ITEMS end,
        getLabel  = function(i) return SEARCH_ITEMS[i] end,
        moveTo    = function(i) moved[#moved + 1] = i end,
    }
    local s = TypeAheadSearch.new()
    s:handleChar("a", sb)
    local initialMoves = #moved
    T.truthy(s:handleKey(40, false, false, sb), "Down consumed when active")
    T.eq(#moved - initialMoves, 1, "Down fired one more moveTo")
end

function M.test_handle_key_inactive_without_buffer_ignored()
    setup()
    local sb = searchable()
    local s = TypeAheadSearch.new()
    T.falsy(s:handleKey(40, false, false, sb), "Down ignored when inactive")
    T.falsy(s:handleKey(8,  false, false, sb), "Backspace ignored when inactive without buffer")
end

return M

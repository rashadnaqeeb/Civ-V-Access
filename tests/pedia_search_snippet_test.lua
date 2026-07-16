-- PediaSearch.sentenceAround tests: the slicer that turns a body-search
-- match into the sentence spoken after the article name in the Ctrl+F
-- filtered picker. Speech-boundary code -- a wrong slice is spoken as-is.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_PediaSearchCore.lua")
end

-- Build a corpus entry the way buildCorpus does: raw is the source text,
-- body its lowercased form (test bodies are ASCII, so string.lower matches
-- what Locale.ToLower produces byte-for-byte).
local function entryOf(raw)
    return { raw = raw, body = string.lower(raw) }
end

local function sliceFor(raw, query)
    local entry = entryOf(raw)
    local qs, qe = string.find(entry.body, string.lower(query), 1, true)
    T.truthy(qs, "query must occur in the fixture body")
    return PediaSearch.sentenceAround(entry, qs, qe)
end

function M.test_mid_sentence_match_returns_full_sentence()
    setup()
    local raw = "The Granary stores food. Each Granary provides two Food. Build one early."
    T.eq(sliceFor(raw, "provides two"), "Each Granary provides two Food.")
end

function M.test_match_in_first_sentence_starts_at_body_start()
    setup()
    T.eq(sliceFor("The Granary stores food. Build one early.", "stores"), "The Granary stores food.")
end

function M.test_match_in_last_unterminated_sentence_ends_at_body_end()
    setup()
    T.eq(sliceFor("Build one early. It provides Food", "food"), "It provides Food")
end

function M.test_no_boundaries_returns_whole_body()
    setup()
    T.eq(sliceFor("Grants one Delegate", "delegate"), "Grants one Delegate")
end

function M.test_newline_tokens_bound_without_being_spoken()
    setup()
    local raw = "+2 [ICON_GOLD] Gold[NEWLINE]Grants one Delegate[NEWLINE]+1 Happiness"
    T.eq(sliceFor(raw, "delegate"), "Grants one Delegate")
end

function M.test_slice_keeps_original_case_markup()
    setup()
    -- The slice must come from raw, uppercase markup intact, or TextFilter
    -- misses the tokens at speech time.
    local raw = "First part.[NEWLINE]+2 [ICON_GOLD] Gold in the Capital."
    T.eq(sliceFor(raw, "gold in the"), "+2 [ICON_GOLD] Gold in the Capital.")
end

function M.test_exclamation_and_question_terminate()
    setup()
    T.eq(sliceFor("What a wonder! It sings. Truly.", "wonder"), "What a wonder!")
    T.eq(sliceFor("It sings. Does it fly? Truly.", "fly"), "Does it fly?")
end

function M.test_cjk_full_stop_bounds()
    setup()
    T.eq(
        sliceFor("穀倉は食料を貯蔵する。食料を二つ与える。", "貯蔵"),
        "穀倉は食料を貯蔵する。"
    )
end

function M.test_boundary_inside_match_does_not_split()
    setup()
    local raw = "It stores food. Each city benefits."
    T.eq(sliceFor(raw, "food. Each"), "It stores food. Each city benefits.")
end

function M.test_ellipsis_before_match_is_consumed()
    setup()
    T.eq(sliceFor("A dream... The Colossus guards the harbor.", "guards"), "The Colossus guards the harbor.")
end

function M.test_length_mismatch_returns_nil()
    setup()
    -- Simulates a locale whose ToLower changes byte length: offsets no
    -- longer transfer to raw, so the slicer must decline.
    local entry = { raw = "STRASSE extra", body = "strasse" }
    T.eq(PediaSearch.sentenceAround(entry, 1, 3), nil)
end

function M.test_whitespace_only_slice_returns_nil()
    setup()
    local entry = entryOf("a.   [NEWLINE]b")
    -- Match sits on the whitespace between the dot and the newline token,
    -- so nothing speakable remains after both boundaries are honored.
    T.eq(PediaSearch.sentenceAround(entry, 3, 4), nil)
end

return M

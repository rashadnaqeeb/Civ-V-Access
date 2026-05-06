-- TextFilter tests. Each test_* calls setup() first for isolation:
-- the filter module holds _iconMap in a closure, so we re-dofile to reset
-- before each test.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
end

-- nil / empty / type coercion ---------------------------------------------

function M.test_nil_returns_empty_string()
    setup()
    T.eq(TextFilter.filter(nil), "")
end

function M.test_empty_string_returns_empty_string()
    setup()
    T.eq(TextFilter.filter(""), "")
end

function M.test_number_coerced_via_tostring()
    setup()
    T.eq(TextFilter.filter(42), "42")
end

-- Fast-path passthrough ---------------------------------------------------

function M.test_plain_text_passes_through()
    setup()
    T.eq(TextFilter.filter("Next Turn"), "Next Turn")
end

function M.test_fast_path_collapses_internal_whitespace()
    setup()
    T.eq(TextFilter.filter("a   b\tc"), "a b c")
end

function M.test_fast_path_trims_edges()
    setup()
    T.eq(TextFilter.filter("  hello  "), "hello")
end

-- Bracket tokens ----------------------------------------------------------

function M.test_newline_becomes_comma_pause()
    setup()
    -- [NEWLINE] separates list items / display lines. A bare space ran
    -- consecutive items together (e.g. "20 for X from X 5 for Y from Y").
    -- Comma gives the screen reader a pause and reads as a list separator.
    T.eq(TextFilter.filter("line1[NEWLINE]line2"), "line1, line2")
end

function M.test_double_newline_collapses_to_single_separator()
    setup()
    -- Engine paragraph breaks often use [NEWLINE][NEWLINE]. Two commas in
    -- a row would read as "comma comma"; collapse to one.
    T.eq(TextFilter.filter("para1[NEWLINE][NEWLINE]para2"), "para1, para2")
end

function M.test_newline_after_sentence_ender_drops_comma()
    setup()
    -- Common pattern: text ending in a period followed by [NEWLINE] before
    -- a new sentence / list. ". , " reads as "period comma" — keep just
    -- the period's pause.
    T.eq(TextFilter.filter("All done.[NEWLINE]Next thing."), "All done. Next thing.")
end

function M.test_newline_after_question_mark_drops_comma()
    setup()
    T.eq(TextFilter.filter("Why?[NEWLINE]Because"), "Why? Because")
end

function M.test_newline_at_edges_trimmed()
    setup()
    -- Leading / trailing [NEWLINE] should not leave a dangling comma.
    T.eq(TextFilter.filter("[NEWLINE]start"), "start")
    T.eq(TextFilter.filter("end[NEWLINE]"), "end")
end

function M.test_league_vote_tally_reads_as_list()
    setup()
    -- League voting result notifications (TXT_KEY_NOTIFICATION_LEAGUE_
    -- VOTING_RESULT_HOST_DETAILS + GetVotesAsText) embed
    -- "[ICON_BULLET]N for X from Y" entries joined by [NEWLINE]. Without
    -- the comma pause, "20 for Babylon from Babylon 5 for Indonesia from
    -- Indonesia" runs together with no audible separation.
    local input =
        "Host chosen.[NEWLINE][ICON_BULLET]20 for Babylon from Babylon[NEWLINE][ICON_BULLET]5 for Indonesia from Indonesia"
    T.eq(TextFilter.filter(input), "Host chosen. 20 for Babylon from Babylon, 5 for Indonesia from Indonesia")
end

function M.test_dash_separator_stripped_between_newlines()
    setup()
    -- GetHelpTextForBuilding wraps the prose Help section with
    -- "[NEWLINE]----------------[NEWLINE]" as a visual separator. Without
    -- the strip the screen reader would say "dash" sixteen times mid-tooltip.
    T.eq(TextFilter.filter("contribs[NEWLINE]----------------[NEWLINE]help"), "contribs, help")
end

function M.test_short_dash_runs_preserved()
    setup()
    -- Negative numbers and hyphenated tokens use 1-3 dashes; the strip
    -- only fires on 4+ so these survive.
    T.eq(TextFilter.filter("-3 food"), "-3 food")
    T.eq(TextFilter.filter("a -- b"), "a -- b")
    T.eq(TextFilter.filter("a --- b"), "a --- b")
end

function M.test_color_tokens_stripped()
    setup()
    T.eq(TextFilter.filter("[COLOR_POSITIVE_TEXT]+3[ENDCOLOR] food"), "+3 food")
end

function M.test_color_token_with_digits_stripped()
    setup()
    T.eq(TextFilter.filter("[COLOR_PLAYER_GOLD_TEXT_1]gold[ENDCOLOR]"), "gold")
end

-- Slash-closing tags used in tutorial / advisor copy alongside [COLOR_*].
-- The catch-all bracket stripper rejects the slash, so these need their own
-- rule; without it, users hear "[/COLOR]" read verbatim at the end of a
-- highlighted phrase.
function M.test_slash_color_close_stripped()
    setup()
    T.eq(TextFilter.filter("press [COLOR_ADVISOR_HIGHLIGHT_TEXT]Found City[/COLOR] button"), "press Found City button")
end

function M.test_slash_red_close_stripped()
    setup()
    T.eq(TextFilter.filter("[COLOR_WARNING_TEXT]danger[/RED]"), "danger")
end

-- Civilopedia link markup. The opener has an `=` payload (which the
-- uppercase-only catch-all won't match) and the closer uses a backslash
-- (which the forward-slash closer rule above won't match). Both forms
-- need explicit strippers; the inner label text must survive.
function M.test_link_markup_stripped_keeping_label()
    setup()
    T.eq(TextFilter.filter("Construct a [LINK=IMPROVEMENT_FARM]Farm[\\LINK] here"), "Construct a Farm here")
end

function M.test_link_markup_with_multiword_label()
    setup()
    T.eq(TextFilter.filter("Create [LINK=IMPROVEMENT_FISHING_BOATS]Fishing Boats[\\LINK]"), "Create Fishing Boats")
end

function M.test_style_token_stripped_by_catchall()
    setup()
    T.eq(TextFilter.filter("[STYLE_HEADER]Title"), "Title")
end

function M.test_tab_token_stripped()
    setup()
    T.eq(TextFilter.filter("a[TAB]b"), "ab")
end

function M.test_bullet_token_stripped()
    setup()
    T.eq(TextFilter.filter("[BULLET]item"), "item")
end

function M.test_numeric_bracket_token_stripped()
    setup()
    T.eq(TextFilter.filter("[X123]after"), "after")
end

function M.test_lowercase_bracket_content_preserved()
    setup()
    -- Catchall requires uppercase/digits; [foo] is not a recognizable token.
    T.eq(TextFilter.filter("keep [foo] this"), "keep [foo] this")
end

-- Icon substitution -------------------------------------------------------

function M.test_registered_icon_substituted()
    setup()
    TextFilter.registerIcon("ICON_GOLD", "gold")
    T.eq(TextFilter.filter("costs [ICON_GOLD]"), "costs gold")
end

function M.test_unregistered_icon_stripped()
    setup()
    T.eq(TextFilter.filter("costs [ICON_MYSTERY]"), "costs")
end

function M.test_registered_icon_wins_over_catchall()
    setup()
    TextFilter.registerIcon("ICON_FOOD", "food")
    T.eq(TextFilter.filter("[ICON_FOOD][COLOR_X]+2[ENDCOLOR]"), "food+2")
end

-- Adjacent-word dedup. Base-game text frequently pairs an icon with its
-- English label (the glyph reinforces the word for sighted readers). We
-- drop the spoken form when the same phrase already appears next to the
-- icon; otherwise a screen reader says the phrase twice.

function M.test_icon_dropped_when_spoken_form_follows()
    setup()
    TextFilter.registerIcon("ICON_STRENGTH", "combat strength")
    T.eq(TextFilter.filter("higher [ICON_STRENGTH] Combat Strength than"), "higher Combat Strength than")
end

function M.test_icon_dropped_when_spoken_form_precedes()
    setup()
    TextFilter.registerIcon("ICON_STRENGTH", "combat strength")
    T.eq(TextFilter.filter("Combat Strength [ICON_STRENGTH]"), "Combat Strength")
end

function M.test_icon_kept_when_adjacent_word_differs()
    setup()
    TextFilter.registerIcon("ICON_PRODUCTION", "production")
    T.eq(TextFilter.filter("40 [ICON_PRODUCTION]"), "40 production")
end

function M.test_icon_kept_when_adjacent_word_is_longer_prefix_match()
    setup()
    -- "golden" must not trigger the dedup for spoken "gold"; the trailing
    -- "en" fails the word-boundary check, so the icon speaks normally.
    TextFilter.registerIcon("ICON_GOLD", "gold")
    T.eq(TextFilter.filter("[ICON_GOLD] Golden Age bonus"), "gold Golden Age bonus")
end

function M.test_icon_dedup_handles_trailing_punctuation()
    setup()
    TextFilter.registerIcon("ICON_STRENGTH", "combat strength")
    T.eq(TextFilter.filter("the [ICON_STRENGTH] Combat Strength."), "the Combat Strength.")
end

function M.test_icon_dedup_is_case_insensitive()
    setup()
    TextFilter.registerIcon("ICON_FAITH", "faith")
    T.eq(TextFilter.filter("[ICON_FAITH] FAITH costs"), "FAITH costs")
    T.eq(TextFilter.filter("[ICON_FAITH] faith costs"), "faith costs")
end

-- Civ's text uses ICON_CITIZEN next to both "Citizen" (singular) and
-- "Citizens" (plural). A singular spoken form must still collapse the
-- plural, otherwise the Settler disabled reason reads "... at least 2
-- citizen Citizens.".
function M.test_icon_dedup_collapses_trailing_plural_after()
    setup()
    TextFilter.registerIcon("ICON_CITIZEN", "citizen")
    T.eq(TextFilter.filter("at least 2 [ICON_CITIZEN] Citizens."), "at least 2 Citizens.")
end

function M.test_icon_dedup_collapses_trailing_plural_before()
    setup()
    TextFilter.registerIcon("ICON_CITIZEN", "citizen")
    T.eq(TextFilter.filter("Citizens [ICON_CITIZEN]"), "Citizens")
end

function M.test_icon_dedup_still_collapses_singular()
    setup()
    TextFilter.registerIcon("ICON_CITIZEN", "citizen")
    T.eq(TextFilter.filter("a new [ICON_CITIZEN] Citizen is born"), "a new Citizen is born")
end

-- `s?` must not swallow a different word that happens to start with the
-- phrase plus s. "citizenship" shares "citizen" but the word-boundary
-- check still has to fail so the icon speaks normally.
function M.test_icon_dedup_does_not_eat_longer_word_with_s_prefix()
    setup()
    TextFilter.registerIcon("ICON_CITIZEN", "citizen")
    T.eq(TextFilter.filter("[ICON_CITIZEN] Citizenship granted"), "citizen Citizenship granted")
end

-- ICON_GREAT_PEOPLE precedes both the full phrase ("great people"), the
-- singular ("Great Person of your choice"), and per-specialist title
-- lines the engine emits in GetHelpTextForBuilding ("Great Scientist
-- Points:" in en_US, "Points d'artistes illustres :" in fr_FR, etc.).
-- Each phrase is registered as its own alias so the icon collapses
-- against the specific phrase rather than a broad "great" / "grand"
-- prefix that would over-collapse on unrelated adjacent text.
function M.test_icon_dedup_collapses_specific_great_titles()
    setup()
    TextFilter.registerIcon("ICON_GREAT_PEOPLE", "great people", {
        "great person",
        "great artist points",
        "great engineer points",
        "great merchant points",
        "great scientist points",
    })
    T.eq(TextFilter.filter("[ICON_GREAT_PEOPLE] Great Scientist Points 1"), "Great Scientist Points 1")
    T.eq(TextFilter.filter("[ICON_GREAT_PEOPLE] Great Engineer Points 2"), "Great Engineer Points 2")
    T.eq(TextFilter.filter("[ICON_GREAT_PEOPLE] Great Person of your choice"), "Great Person of your choice")
    T.eq(TextFilter.filter("[ICON_GREAT_PEOPLE] great people standalone"), "great people standalone")
end

function M.test_specific_great_aliases_do_not_overmatch_unrelated_great()
    setup()
    -- The specific aliases ("great scientist points") only fire when the
    -- adjacent text starts with that exact phrase. Unrelated "Great X"
    -- noun phrases ("Great Wall", "Great Library") leave the icon in
    -- place because no specific alias matches their prefix.
    TextFilter.registerIcon("ICON_GREAT_PEOPLE", "great people", {
        "great scientist points",
        "great engineer points",
    })
    T.eq(
        TextFilter.filter("[ICON_GREAT_PEOPLE] Great Wall of China stands"),
        "great people Great Wall of China stands"
    )
end

function M.test_french_great_aliases_collapse_locale_specific_titles()
    setup()
    -- The French engine emits "Points d'X illustres :" instead of "Great
    -- X Points:". Per-locale aliases handle this; verify the dedup
    -- matches the French phrasing too.
    TextFilter.registerIcon("ICON_GREAT_PEOPLE", "grands personnages", {
        "points d'artistes illustres",
        "points de savants illustres",
    })
    T.eq(
        TextFilter.filter("[ICON_GREAT_PEOPLE] Points d'artistes illustres : 1"),
        "Points d'artistes illustres : 1"
    )
    T.eq(
        TextFilter.filter("[ICON_GREAT_PEOPLE] Points de savants illustres : 1"),
        "Points de savants illustres : 1"
    )
end

-- TXT_KEY_PRODUCTION_STRENGTH formats as "[ICON_STRENGTH] Strength: N"
-- and TXT_KEY_PRODUCTION_RANGED_STRENGTH as "[ICON_RANGE_STRENGTH] Ranged
-- Strength: N". The icons' spoken forms ("combat strength" / "ranged
-- combat strength") share their tail with the bare phrase that follows;
-- aliases on "strength" / "ranged strength" let the icon collapse so the
-- screen reader doesn't read "combat strength Strength: 50".
function M.test_strength_icon_collapses_against_bare_word()
    setup()
    TextFilter.registerIcon("ICON_STRENGTH", "combat strength", { "strength" })
    T.eq(TextFilter.filter("[ICON_STRENGTH] Strength: 50"), "Strength: 50")
end

function M.test_ranged_strength_icon_collapses_against_two_word_phrase()
    setup()
    TextFilter.registerIcon("ICON_RANGE_STRENGTH", "ranged combat strength", { "ranged strength" })
    T.eq(TextFilter.filter("[ICON_RANGE_STRENGTH] Ranged Strength: 25"), "Ranged Strength: 25")
end

function M.test_alias_word_boundary_check()
    setup()
    -- The `s?` boundary check in the matcher ensures aliases don't fire
    -- against longer words that happen to start with the alias text. The
    -- specific specialist-title aliases match only the exact phrase; a
    -- "great scientist" alias must not collapse against "great scientists"
    -- alone (no "points" suffix), against "greater scientist", etc.
    TextFilter.registerIcon("ICON_GREAT_PEOPLE", "great people", { "great scientist points" })
    T.eq(
        TextFilter.filter("[ICON_GREAT_PEOPLE] great scientists assemble"),
        "great people great scientists assemble"
    )
    T.eq(
        TextFilter.filter("[ICON_GREAT_PEOPLE] greatness in numbers"),
        "great people greatness in numbers"
    )
end

-- Control characters -----------------------------------------------------

function M.test_control_chars_stripped()
    setup()
    T.eq(TextFilter.filter("a\1b\8c\31d"), "abcd")
end

function M.test_newline_and_tab_preserved_as_whitespace()
    setup()
    T.eq(TextFilter.filter("a\nb\tc"), "a b c")
end

function M.test_null_byte_stripped()
    setup()
    T.eq(TextFilter.filter("a\0b"), "ab")
end

-- Emdash ------------------------------------------------------------------

function M.test_emdash_replaced_with_space()
    setup()
    T.eq(TextFilter.filter("Rome\226\128\148a city"), "Rome a city")
end

function M.test_emdash_with_spaces_collapses()
    setup()
    T.eq(TextFilter.filter("Rome \226\128\148 a city"), "Rome a city")
end

-- Artifacts ---------------------------------------------------------------

function M.test_colon_period_artifact_collapses()
    setup()
    T.eq(TextFilter.filter("Yield:[ICON_UNKNOWN]."), "Yield.")
end

-- Composed ---------------------------------------------------------------

function M.test_composed_color_newline_icon_whitespace()
    setup()
    TextFilter.registerIcon("ICON_GOLD", "gold")
    T.eq(TextFilter.filter("[COLOR_X]  [ICON_GOLD]\t+5[ENDCOLOR][NEWLINE]next"), "gold +5, next")
end

function M.test_composed_all_markup_emdash_control()
    setup()
    TextFilter.registerIcon("ICON_PROD", "production")
    -- Trailing [NEWLINE] becomes ", " which is then trimmed at the edge.
    T.eq(TextFilter.filter("\1[STYLE_H][ICON_PROD]\226\128\148city[NEWLINE]"), "production city")
end

return M

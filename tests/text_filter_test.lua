-- TextFilter tests. Each test_* calls setup() first for isolation:
-- the filter module holds _iconMap and _warnedIcons in closures, so we
-- re-dofile to reset, and we reassign Log.debug to capture warnings.

local T = require("support")
local M = {}

local capturedLogs

local function setup()
    capturedLogs = {}
    Log.debug = function(msg) capturedLogs[#capturedLogs + 1] = msg end
    dofile("src/dlc/UI/InGame/CivVAccess_TextFilter.lua")
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

function M.test_newline_becomes_space()
    setup()
    T.eq(TextFilter.filter("line1[NEWLINE]line2"), "line1 line2")
end

function M.test_color_tokens_stripped()
    setup()
    T.eq(TextFilter.filter("[COLOR_POSITIVE_TEXT]+3[ENDCOLOR] food"),
        "+3 food")
end

function M.test_color_token_with_digits_stripped()
    setup()
    T.eq(TextFilter.filter("[COLOR_PLAYER_GOLD_TEXT_1]gold[ENDCOLOR]"), "gold")
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

function M.test_unregistered_icon_warns_only_once()
    setup()
    TextFilter.filter("[ICON_MYSTERY]")
    TextFilter.filter("[ICON_MYSTERY] again")
    local hits = 0
    for _, msg in ipairs(capturedLogs) do
        if msg:find("ICON_MYSTERY") then hits = hits + 1 end
    end
    T.eq(hits, 1, "warning should fire exactly once per icon name")
end

function M.test_different_unregistered_icons_each_warn_once()
    setup()
    TextFilter.filter("[ICON_A][ICON_B]")
    T.eq(#capturedLogs, 2)
end

function M.test_registered_icon_wins_over_catchall()
    setup()
    TextFilter.registerIcon("ICON_FOOD", "food")
    T.eq(TextFilter.filter("[ICON_FOOD][COLOR_X]+2[ENDCOLOR]"), "food+2")
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
    T.eq(
        TextFilter.filter("[COLOR_X]  [ICON_GOLD]\t+5[ENDCOLOR][NEWLINE]next"),
        "gold +5 next")
end

function M.test_composed_all_markup_emdash_control()
    setup()
    TextFilter.registerIcon("ICON_PROD", "production")
    T.eq(
        TextFilter.filter("\1[STYLE_H][ICON_PROD]\226\128\148city[NEWLINE]"),
        "production city")
end

return M

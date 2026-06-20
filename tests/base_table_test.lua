-- BaseTable tests. Loads the production module against a synthetic data
-- model so navigation, sort, search, dedup, and lifecycle behavior can be
-- exercised without engine globals.

local T = require("support")
local M = {}

local warns, errors
local speaks
local pediaCalls
local wrapPlays

local function setup()
    warns, errors = {}, {}
    Log.warn = function(m)
        warns[#warns + 1] = m
    end
    Log.error = function(m)
        errors[#errors + 1] = m
    end
    Log.info = function() end
    Log.debug = function() end

    UI.ShiftKeyDown = function()
        return false
    end
    UI.CtrlKeyDown = function()
        return false
    end
    UI.AltKeyDown = function()
        return false
    end

    speaks = {}
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        speaks[#speaks + 1] = { text = text, interrupt = interrupt }
    end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    -- BaseTable delegates wrap-sound playback to BaseMenu._playWrap. Stub
    -- it here (counter rather than dofiling BaseMenu, which would pull a
    -- much larger transitive include chain) so the column-edge wrap tests
    -- can assert the cue fired.
    wrapPlays = 0
    BaseMenu = {
        _playWrap = function()
            wrapPlays = wrapPlays + 1
        end,
    }
    -- BaseTable's per-cell tooltip path delegates to BaseMenuItems.appendTooltip
    -- to share BaseMenu's dedupe / NEWLINE handling. Tests stub the API surface
    -- with a deterministic concatenator so getTooltip wiring can be exercised
    -- without dofile'ing BaseMenuItems (which would pull a larger chain).
    BaseMenuItems = {
        appendTooltip = function(base, tt)
            if tt == nil or tt == "" then
                return base
            end
            if base == nil or base == "" then
                return tt
            end
            return base .. ". " .. tt
        end,
    }
    dofile("src/dlc/UI/Shared/CivVAccess_BaseTableCore.lua")

    pediaCalls = {}
    Events = Events or {}
    Events.SearchForPediaEntry = function(name)
        pediaCalls[#pediaCalls + 1] = name
    end

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TBL_TAB"] = "TestTab"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TBL_COL_NAME"] = "Name"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TBL_COL_POP"] = "Pop"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TBL_COL_GOLD"] = "Gold"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TBL_COL_FOOD"] = "Food"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC"] = "{1_Col}, descending"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC"] = "{1_Col}, ascending"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED"] = "{1_Col}, sort cleared"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH"] = "no match for {1_Buffer}"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_SEARCH_CLEARED"] = "search cleared"
end

-- Build a small fixed table: 3 cities x 3 columns (Name, Pop, Gold).
local function makeBasicSpec()
    local rows = {
        { name = "Rome", pop = 5, gold = 12 },
        { name = "Athens", pop = 3, gold = 20 },
        { name = "Memphis", pop = 7, gold = 7 },
    }
    return {
        tabName = "TXT_KEY_CIVVACCESS_TBL_TAB",
        columns = {
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_NAME",
                getCell = function(r)
                    return r.name
                end,
                sortKey = function(r)
                    return r.name
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_POP",
                getCell = function(r)
                    return tostring(r.pop)
                end,
                sortKey = function(r)
                    return r.pop
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_GOLD",
                getCell = function(r)
                    return tostring(r.gold)
                end,
                sortKey = function(r)
                    return r.gold
                end,
            },
        },
        rebuildRows = function()
            return rows
        end,
        rowLabel = function(r)
            return r.name
        end,
    }
end

-- Factory --------------------------------------------------------------

function M.test_create_requires_tabName()
    setup()
    local spec = makeBasicSpec()
    spec.tabName = nil
    local ok = pcall(BaseTable.create, spec)
    T.falsy(ok)
end

function M.test_create_requires_columns()
    setup()
    local spec = makeBasicSpec()
    spec.columns = {}
    local ok = pcall(BaseTable.create, spec)
    T.falsy(ok)
end

function M.test_create_requires_rebuildRows_and_rowLabel()
    setup()
    local spec = makeBasicSpec()
    spec.rebuildRows = nil
    local ok = pcall(BaseTable.create, spec)
    T.falsy(ok)

    spec = makeBasicSpec()
    spec.rowLabel = nil
    ok = pcall(BaseTable.create, spec)
    T.falsy(ok)
end

function M.test_create_shape()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    T.eq(h.capturesAllInput, true)
    T.eq(type(h.bindings), "table")
    T.eq(type(h.helpEntries), "table")
    T.eq(type(h.onTabActivated), "function")
    T.eq(type(h.onTabDeactivated), "function")
    T.eq(type(h.handleSearchInput), "function")
    T.eq(type(h.onActivate), "function")
end

-- Activation -----------------------------------------------------------

function M.test_first_open_announce_false_chains_first_cell_queued()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    -- Expect speakQueued("Rome, Name, Rome") (rowLabel + colName + cell).
    T.eq(#speaks, 1)
    T.eq(speaks[1].interrupt, false, "first-open announce=false must chain (queued)")
    T.truthy(speaks[1].text:find("Rome"), "text contains row label")
    T.truthy(speaks[1].text:find("Name"), "text contains column name")
end

function M.test_first_open_announce_true_speaks_tabName_then_cell()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, true)
    T.eq(speaks[1].text, "TestTab")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].interrupt, false, "cell speech chains queued after tabName interrupt")
    T.truthy(speaks[2].text:find("Rome"))
end

function M.test_reactivation_after_deactivate_preserves_cursor()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, true)
    -- Move down twice to row 3, right once to col 2.
    h.bindings[2].fn() -- VK_DOWN
    h.bindings[2].fn()
    h.bindings[4].fn() -- VK_RIGHT
    -- Cursor should now be row 3 (Memphis), col 2 (Pop).
    h.onTabDeactivated()
    speaks = {}
    SpeechPipeline._reset()
    h.onTabActivated(h, true)
    -- Re-activation speaks tabName + full cell. _initialized is still true,
    -- so cursor is preserved at row 3 col 2.
    T.eq(speaks[1].text, "TestTab")
    -- Look for Memphis + Pop + 7 in the second utterance.
    local text = speaks[2].text
    T.truthy(text:find("Memphis"))
    T.truthy(text:find("Pop"))
    T.truthy(text:find("7"))
end

-- Navigation -----------------------------------------------------------

local function findBinding(h, key, mods)
    mods = mods or 0
    for _, b in ipairs(h.bindings) do
        if b.key == key and (b.mods or 0) == mods then
            return b.fn
        end
    end
    return nil
end

function M.test_down_navigates_data_rows_no_wrap()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_DOWN)()
    T.eq(speaks[#speaks].text:match("^[^,]+"), "Athens", "row 2 is Athens")
    findBinding(h, Keys.VK_DOWN)()
    findBinding(h, Keys.VK_DOWN)() -- past end; no-op
    -- Last meaningful speech is row 3 Memphis.
    T.truthy(speaks[#speaks].text:find("Memphis"))
end

function M.test_up_from_first_data_row_moves_to_header()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_UP)()
    -- _row is now 0 (header). Speech is just the column name (verbosity
    -- off in tests; the sort-button affordance and column-of position
    -- only fire when Verbosity.isOn()).
    T.eq(speaks[#speaks].text, "Name")
    findBinding(h, Keys.VK_UP)() -- already at header; no-op
end

function M.test_left_right_wrap_columns()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    wrapPlays = 0
    -- From col 1 (Name), Left wraps to col 3 (Gold).
    findBinding(h, Keys.VK_LEFT)()
    -- Row didn't change so only column name + cell speak (dedup elides row label).
    T.truthy(speaks[#speaks].text:find("Gold"))
    T.eq(wrapPlays, 1, "wrap sound fires when Left wraps from first column")
    -- Right wraps back to col 1 (Name).
    findBinding(h, Keys.VK_RIGHT)()
    T.truthy(speaks[#speaks].text:find("Name"))
    T.eq(wrapPlays, 2, "wrap sound fires when Right wraps from last column")
end

function M.test_non_wrap_left_right_does_not_play_wrap_sound()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    -- From col 1 (Name), Right to col 2 (Pop) is a non-wrap step.
    wrapPlays = 0
    findBinding(h, Keys.VK_RIGHT)()
    T.eq(wrapPlays, 0, "non-wrap Right is silent")
    -- From col 2, Left back to col 1 is also non-wrap.
    findBinding(h, Keys.VK_LEFT)()
    T.eq(wrapPlays, 0, "non-wrap Left is silent")
end

function M.test_home_jumps_to_first_data_row_end_jumps_to_last()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    -- Move to last row.
    findBinding(h, Keys.VK_END)()
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_HOME)()
    T.truthy(speaks[#speaks].text:find("Rome"))
    findBinding(h, Keys.VK_END)()
    T.truthy(speaks[#speaks].text:find("Memphis"))
end

-- Smart speech dedup ---------------------------------------------------

function M.test_dedup_elides_row_label_when_only_column_changes()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RIGHT)()
    -- Same row, different column. Speech should NOT include "Rome" again.
    local text = speaks[#speaks].text
    T.falsy(text:find("Rome"), "row label elided when only column changed")
    T.truthy(text:find("Pop"), "column name spoken")
end

function M.test_dedup_elides_column_name_when_only_row_changes()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_DOWN)()
    -- Different row, same column. Speech should NOT include "Name" again.
    local text = speaks[#speaks].text
    T.truthy(text:find("Athens"), "row label spoken")
    T.falsy(text:find("Name"), "column name elided when only row changed")
end

-- Sort -----------------------------------------------------------------

function M.test_enter_on_header_cycles_sort_descending_first()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    -- Move up to header.
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    SpeechPipeline._reset()
    -- Move to col 2 (Pop) -- sortable numeric column.
    findBinding(h, Keys.VK_RIGHT)()
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RETURN)()
    T.eq(speaks[1].text, "Pop, descending")
    -- Down to first data row -- should now be Memphis (highest pop=7).
    findBinding(h, Keys.VK_DOWN)()
    T.truthy(speaks[#speaks].text:find("Memphis"), "highest pop appears first descending")
end

function M.test_enter_on_header_cycles_through_asc_then_cleared()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    -- Sort col 1 (Name).
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RETURN)() -- desc
    T.eq(speaks[#speaks].text, "Name, descending")
    findBinding(h, Keys.VK_RETURN)() -- asc
    T.eq(speaks[#speaks].text, "Name, ascending")
    findBinding(h, Keys.VK_RETURN)() -- cleared
    T.eq(speaks[#speaks].text, "Name, sort cleared")
    -- Down to first data row -- should be Rome again (original iteration order).
    findBinding(h, Keys.VK_DOWN)()
    T.truthy(speaks[#speaks].text:find("Rome"), "natural order restored after sort cleared")
end

function M.test_enter_on_header_for_unsortable_column_is_silent()
    setup()
    local spec = makeBasicSpec()
    -- Strip sortKey from col 1 (Name).
    spec.columns[1].sortKey = nil
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RETURN)()
    T.eq(#speaks, 0, "non-sortable column is silent on Enter")
end

-- Default sort ---------------------------------------------------------

function M.test_default_sort_opens_with_column_sorted()
    setup()
    local spec = makeBasicSpec()
    -- Open sorted ascending on Pop (col 2): Athens(3), Rome(5), Memphis(7).
    spec.defaultSort = { column = 2, ascending = true }
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    -- First data row is Athens (lowest pop), proving the sort applied on open.
    T.truthy(speaks[#speaks].text:find("Athens"), "lowest pop appears first on open")
    findBinding(h, Keys.VK_DOWN)()
    T.truthy(speaks[#speaks].text:find("Rome"), "ascending pop order")
end

function M.test_default_sort_header_reports_active_sort_and_enter_cycles_onward()
    setup()
    local spec = makeBasicSpec()
    -- Default ascending on Pop; Enter on its header should advance the
    -- cycle to cleared (none -> desc -> asc -> none), not restart at desc.
    spec.defaultSort = { column = 2, ascending = true }
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)() -- to header, col 1
    findBinding(h, Keys.VK_RIGHT)() -- to col 2 (Pop)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RETURN)()
    T.eq(speaks[#speaks].text, "Pop, sort cleared", "Enter advances past the default ascending state")
end

function M.test_default_sort_reapplies_after_reinitialization()
    setup()
    local spec = makeBasicSpec()
    spec.defaultSort = { column = 2, ascending = true }
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    -- Clear the sort, then force a fresh init (mimics a close / reopen).
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_RIGHT)()
    findBinding(h, Keys.VK_RETURN)() -- Pop -> cleared
    T.eq(h._sortColumn, nil, "sort cleared")
    h.resetForNextOpen()
    speaks = {}
    SpeechPipeline._reset()
    h.onTabActivated(h, false)
    T.eq(h._sortColumn, 2, "default sort restored on reinit")
    T.eq(h._sortAscending, true)
    T.truthy(speaks[#speaks].text:find("Athens"), "rows sorted nearest-first again on reopen")
end

function M.test_default_sort_rejects_unsortable_column()
    setup()
    local spec = makeBasicSpec()
    spec.columns[1].sortKey = nil
    spec.defaultSort = { column = 1, ascending = true }
    local ok = pcall(BaseTable.create, spec)
    T.falsy(ok, "defaultSort on a column without sortKey is rejected")
end

function M.test_default_sort_rejects_out_of_range_column()
    setup()
    local spec = makeBasicSpec()
    spec.defaultSort = { column = 99, ascending = true }
    local ok = pcall(BaseTable.create, spec)
    T.falsy(ok, "defaultSort column index out of range is rejected")
end

-- Enter on data row ---------------------------------------------------

function M.test_enter_on_data_row_invokes_column_enterAction()
    setup()
    local actioned = {}
    local spec = makeBasicSpec()
    spec.columns[1].enterAction = function(row)
        actioned[#actioned + 1] = row.name
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_RETURN)()
    T.eq(#actioned, 1)
    T.eq(actioned[1], "Rome")
end

function M.test_enter_on_data_row_without_action_re_speaks_cell()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RETURN)()
    -- No enterAction defined; cell re-spoken (forced).
    T.truthy(#speaks >= 1)
    T.truthy(speaks[#speaks].text:find("Rome"))
end

-- Type-ahead filter ---------------------------------------------------

-- Spec with three rows whose names share an 'M' prefix, so a one-letter
-- filter keeps a multi-row subset to navigate. rebuildRows returns the same
-- captured table on every call, so object identity holds for the keep-place
-- assertions below (mirrors a screen whose rebuild yields stable handles).
local function makeMultiMatchSpec()
    local rows = {
        { name = "Memphis", pop = 7 },
        { name = "Milan", pop = 4 },
        { name = "Moscow", pop = 9 },
    }
    return {
        tabName = "TXT_KEY_CIVVACCESS_TBL_TAB",
        columns = {
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_NAME",
                getCell = function(r)
                    return r.name
                end,
                sortKey = function(r)
                    return r.name
                end,
            },
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_POP",
                getCell = function(r)
                    return tostring(r.pop)
                end,
                sortKey = function(r)
                    return r.pop
                end,
            },
        },
        rebuildRows = function()
            return rows
        end,
        rowLabel = function(r)
            return r.name
        end,
    }
end

function M.test_filter_narrows_to_matching_rows_and_lands_on_first()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    -- Land cursor in column 2 (Pop); the filter must not touch the column.
    findBinding(h, Keys.VK_RIGHT)()
    speaks = {}
    SpeechPipeline._reset()
    -- 'm' matches all three rows; filter preserves rebuildRows order, so the
    -- subset is Memphis, Milan, Moscow and the cursor lands on the first.
    local consumed = h.handleSearchInput(h, 0x4D, 0)
    T.eq(consumed, true)
    T.truthy(speaks[#speaks].text:find("Memphis"), "first matching row spoken")
    T.eq(h._col, 2, "filter must not move the column")
    T.eq(h._row, 1, "cursor lands on the first matching row")
end

function M.test_filter_ignores_ctrl_chord()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    -- Ctrl+M should NOT feed the filter.
    local consumed = h.handleSearchInput(h, 0x4D, 2)
    T.eq(consumed, false)
    T.eq(h._filterQuery, "", "Ctrl chord leaves the filter untouched")
end

function M.test_nav_walks_filtered_subset_without_clearing_filter()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    h.handleSearchInput(h, 0x4D, 0) -- 'm' -> {Memphis, Milan, Moscow}, row 1
    -- Down / Up are NOT consumed by the filter; they fall through to the nav
    -- bindings, which now walk the filtered subset and leave the filter live.
    T.eq(h.handleSearchInput(h, Keys.VK_DOWN, 0), false, "Down falls through to onDown")
    findBinding(h, Keys.VK_DOWN)()
    T.eq(h._row, 2, "Down moves to the next matching row (Milan)")
    findBinding(h, Keys.VK_DOWN)()
    T.eq(h._row, 3, "Down moves to the last matching row (Moscow)")
    findBinding(h, Keys.VK_DOWN)()
    T.eq(h._row, 3, "Down at the end of the subset does not advance past it")
    T.eq(h._filterQuery, "m", "navigation leaves the filter buffer intact")
end

function M.test_typing_more_narrows_the_filter()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    h.handleSearchInput(h, 0x4D, 0) -- 'm' -> {Memphis, Milan, Moscow}
    speaks = {}
    h.handleSearchInput(h, 0x49, 0) -- 'i' -> "mi" narrows to Milan alone
    T.eq(h._filterQuery, "mi", "letters append to the buffer")
    T.truthy(speaks[#speaks].text:find("Milan"), "narrowing lands on the sole remaining match")
    -- Single-match subset: nav can't move off the one row.
    findBinding(h, Keys.VK_DOWN)()
    T.eq(h._row, 1, "Down cannot advance past a single-match subset")
    findBinding(h, Keys.VK_END)()
    T.eq(h._row, 1, "End stays on the single match")
end

function M.test_no_match_speaks_no_match_and_parks_on_header()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    speaks = {}
    local consumed = h.handleSearchInput(h, 0x5A, 0) -- 'z' matches nothing
    T.eq(consumed, true)
    T.truthy(speaks[#speaks].text:find("no match"), "speaks the shared no-match line")
    T.eq(h._row, 0, "parks on the header row so Up / Down stay valid")
end

function M.test_backspace_to_empty_clears_filter_and_restores_full_table()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    h.handleSearchInput(h, 0x4D, 0) -- 'm'
    h.handleSearchInput(h, 0x4F, 0) -- 'o' -> "mo" matches only Moscow
    speaks = {}
    -- Backspace widens to 'm' (all three match again).
    h.handleSearchInput(h, Keys.VK_BACK, 0)
    T.eq(h._filterQuery, "m", "Backspace removes one character")
    -- Backspace again empties the buffer: filter clears, full table returns.
    h.handleSearchInput(h, Keys.VK_BACK, 0)
    T.eq(h._filterQuery, "", "Backspace at one char clears the filter")
    local sawCleared = false
    for _, s in ipairs(speaks) do
        if s.text == "search cleared" and s.interrupt then
            sawCleared = true
        end
    end
    T.truthy(sawCleared, "spoke 'search cleared' on empty")
end

function M.test_backspace_with_no_filter_falls_through()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    local consumed = h.handleSearchInput(h, Keys.VK_BACK, 0)
    T.eq(consumed, false, "Backspace with no active filter is not consumed")
end

function M.test_clearSearchIfActive_clears_filter_and_keeps_place()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    h.handleSearchInput(h, 0x4D, 0) -- 'm'
    h.handleSearchInput(h, 0x4F, 0) -- 'o' -> Moscow (filtered row 1)
    speaks = {}
    local consumed = h.clearSearchIfActive()
    T.eq(consumed, true)
    T.eq(h._filterQuery, "", "filter cleared")
    -- Moscow is row 3 in the full table; the cursor is relocated onto it.
    T.eq(h._row, 3, "cursor kept on the same row after clearing")
    local sawCleared = false
    for _, s in ipairs(speaks) do
        if s.text == "search cleared" and s.interrupt then
            sawCleared = true
        end
    end
    T.truthy(sawCleared, "spoke 'search cleared'")
end

function M.test_arrow_after_clear_announces_full_row()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    -- Read column 2 (Pop), then filter to Milan (full-table row 2). After
    -- clearing, the cursor relocates from filtered row 1 to full row 2; an
    -- Up move then lands on row 1, which equals the stale filtered baseline.
    -- The dedupe baseline must have followed the silent relocation, so the
    -- row label still speaks rather than collapsing to a bare cell value.
    findBinding(h, Keys.VK_RIGHT)()
    h.handleSearchInput(h, 0x4D, 0) -- 'm'
    h.handleSearchInput(h, 0x49, 0) -- 'i' -> Milan (full row 2)
    h.clearSearchIfActive()
    T.eq(h._row, 2, "cursor relocated to Milan's full-table index")
    speaks = {}
    findBinding(h, Keys.VK_UP)()
    T.eq(h._row, 1, "Up moves to Memphis (full row 1)")
    T.truthy(speaks[#speaks].text:find("Memphis"), "row label spoken, not elided against the stale baseline")
end

function M.test_clearSearchIfActive_returns_false_when_no_filter()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    speaks = {}
    local consumed = h.clearSearchIfActive()
    T.eq(consumed, false)
    T.eq(#speaks, 0, "no speech when no filter is active")
end

function M.test_up_down_when_no_filter_falls_through_to_nav_handlers()
    setup()
    local h = BaseTable.create(makeMultiMatchSpec())
    h.onTabActivated(h, false)
    -- No filter active. Down must NOT be consumed by handleSearchInput so
    -- InputRouter falls through to the binding walk that fires onDown.
    local consumed = h.handleSearchInput(h, Keys.VK_DOWN, 0)
    T.eq(consumed, false, "Down with no filter falls through to onDown")
end

-- Pedia ---------------------------------------------------------------

function M.test_ctrl_i_invokes_pedia_when_column_provides_pediaName()
    setup()
    local spec = makeBasicSpec()
    spec.columns[1].pediaName = function(row)
        return "PEDIA_" .. row.name
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    local fn = findBinding(h, Keys.I, 2)
    T.truthy(fn, "Ctrl+I binding present when any column has pediaName")
    fn()
    T.eq(#pediaCalls, 1)
    T.eq(pediaCalls[1], "PEDIA_Rome")
end

function M.test_ctrl_i_binding_absent_when_no_column_has_pediaName()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    local fn = findBinding(h, Keys.I, 2)
    T.falsy(fn, "Ctrl+I binding absent when no column has pediaName")
end

-- Live re-query (no cache) --------------------------------------------

function M.test_rebuildRows_called_fresh_on_each_navigation()
    setup()
    local callCount = 0
    local spec = makeBasicSpec()
    local origRebuild = spec.rebuildRows
    spec.rebuildRows = function()
        callCount = callCount + 1
        return origRebuild()
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    local before = callCount
    findBinding(h, Keys.VK_DOWN)()
    findBinding(h, Keys.VK_DOWN)()
    findBinding(h, Keys.VK_RIGHT)()
    T.truthy(callCount > before, "rebuildRows fires on each navigation")
end

-- Per-cell tooltip ----------------------------------------------------

function M.test_getTooltip_appends_to_data_cell_speech()
    setup()
    local spec = makeBasicSpec()
    spec.columns[2].getTooltip = function(r)
        return "growth in " .. tostring(r.pop) .. " turns"
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    -- Right to col 2 (Pop): speech is "Pop, 5. growth in 5 turns" (row label
    -- elided, col name + cell + tooltip via the appendTooltip stub).
    findBinding(h, Keys.VK_RIGHT)()
    T.truthy(speaks[#speaks].text:find("growth in 5 turns"), "tooltip appended to cell speech")
end

function M.test_getTooltip_returning_nil_omits_tooltip()
    setup()
    local spec = makeBasicSpec()
    spec.columns[2].getTooltip = function(_)
        return nil
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RIGHT)()
    -- No tooltip text in speech beyond cell value "5".
    T.falsy(speaks[#speaks].text:find("nil"), "nil tooltip not stringified into speech")
end

function M.test_getTooltip_not_called_on_header_row()
    setup()
    local called = 0
    local spec = makeBasicSpec()
    spec.columns[1].getTooltip = function(_)
        called = called + 1
        return "tt"
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    -- Activation lands on row 1 (data) and runs getTooltip once. Reset and
    -- step Up to header: the header path skips the tooltip entirely.
    called = 0
    findBinding(h, Keys.VK_UP)()
    T.eq(called, 0, "getTooltip skipped on header row")
end

function M.test_getTooltip_throwing_logs_and_skips()
    setup()
    local spec = makeBasicSpec()
    spec.columns[1].getTooltip = function(_)
        error("boom")
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, false)
    -- Speech still produced (no crash); error logged.
    T.truthy(#speaks >= 1)
    T.truthy(#errors >= 1)
    T.truthy(errors[1]:find("boom"))
end

-- Top item (control row above the headers) ----------------------------

local function makeTopItemSpec(onActivate)
    local spec = makeBasicSpec()
    spec.topItem = {
        labelFn = function()
            return "Select Player, Rome"
        end,
        onActivate = onActivate,
        helpEntry = { keyLabel = "K", description = "D" },
    }
    return spec
end

function M.test_topItem_up_from_header_lands_and_speaks_label()
    setup()
    local h = BaseTable.create(makeTopItemSpec())
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)() -- row 1 -> header
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_UP)() -- header -> top item
    T.eq(h._row, -1)
    T.eq(speaks[#speaks].text, "Select Player, Rome")
    -- Up again at the top is a no-op.
    speaks = {}
    findBinding(h, Keys.VK_UP)()
    T.eq(h._row, -1)
    T.eq(#speaks, 0, "Up at the top item is silent")
end

function M.test_topItem_absent_up_from_header_is_noop()
    setup()
    local h = BaseTable.create(makeBasicSpec())
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    findBinding(h, Keys.VK_UP)()
    T.eq(h._row, 0, "no top item: header stays the top")
    T.eq(#speaks, 0)
end

function M.test_topItem_down_returns_to_header()
    setup()
    local h = BaseTable.create(makeTopItemSpec())
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_DOWN)()
    T.eq(h._row, 0)
    T.eq(speaks[#speaks].text, "Name", "header column name spoken on return")
end

function M.test_topItem_enter_runs_onActivate()
    setup()
    local activated = 0
    local h = BaseTable.create(makeTopItemSpec(function()
        activated = activated + 1
    end))
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_RETURN)()
    T.eq(activated, 1)
end

function M.test_topItem_enter_without_onActivate_respeaks_label()
    setup()
    local h = BaseTable.create(makeTopItemSpec(nil))
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_RETURN)()
    T.eq(speaks[#speaks].text, "Select Player, Rome")
end

function M.test_topItem_onActivate_error_is_logged()
    setup()
    local h = BaseTable.create(makeTopItemSpec(function()
        error("boom")
    end))
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_RETURN)()
    T.truthy(#errors >= 1)
    T.truthy(errors[#errors]:find("boom"))
end

function M.test_topItem_left_right_are_noops()
    setup()
    local h = BaseTable.create(makeTopItemSpec())
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    wrapPlays = 0
    findBinding(h, Keys.VK_LEFT)()
    findBinding(h, Keys.VK_RIGHT)()
    T.eq(h._row, -1, "cursor stays on the top item")
    T.eq(h._col, 1, "column cursor untouched")
    T.eq(#speaks, 0)
    T.eq(wrapPlays, 0)
end

function M.test_topItem_help_entry_prepended()
    setup()
    local h = BaseTable.create(makeTopItemSpec())
    T.eq(h.helpEntries[1].keyLabel, "K")
    T.eq(h.helpEntries[1].description, "D")
end

function M.test_topItem_home_jumps_to_first_data_row()
    setup()
    local h = BaseTable.create(makeTopItemSpec())
    h.onTabActivated(h, false)
    findBinding(h, Keys.VK_UP)()
    findBinding(h, Keys.VK_UP)()
    speaks = {}
    SpeechPipeline._reset()
    findBinding(h, Keys.VK_HOME)()
    T.eq(h._row, 1)
    T.truthy(speaks[#speaks].text:find("Rome"))
end

-- Empty data ----------------------------------------------------------

function M.test_empty_table_lands_on_header_row()
    setup()
    local spec = makeBasicSpec()
    spec.rebuildRows = function()
        return {}
    end
    local h = BaseTable.create(spec)
    h.onTabActivated(h, true)
    T.eq(h._row, 0)
    -- Speech: tabName interrupt, then header column name queued.
    T.eq(speaks[1].text, "TestTab")
    T.eq(speaks[1].interrupt, true)
    T.eq(speaks[2].text, "Name")
    T.eq(speaks[2].interrupt, false)
end

-- Section review (Alt+Up/Down) -----------------------------------------
--
-- The suite stubs BaseMenuItems with only appendTooltip; the section glue
-- needs the real buildSections + SectionReview, so these two cases swap in
-- the production module (setup() restores the stub on the next case).
-- findBinding (defined above) returns the binding's fn.

local function sectionSpec()
    return {
        tabName = "TXT_KEY_CIVVACCESS_TBL_TAB",
        columns = {
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_POP",
                getCell = function(r)
                    return tostring(r.pop)
                end,
                getTooltip = function()
                    return "Grows fast[NEWLINE]Needs food"
                end,
            },
        },
        rebuildRows = function()
            return { { name = "Rome", pop = 5 } }
        end,
        rowLabel = function(r)
            return r.name
        end,
    }
end

function M.test_alt_down_walks_cell_sections_then_clamps()
    setup()
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    local h = BaseTable.create(sectionSpec())
    h.onTabActivated(h, true)
    -- Sections: row label, column name, cell value, then each tooltip line.
    T.eq(h._sections[1], "Rome")
    T.eq(h._sections[2], "Pop")
    T.eq(h._sections[3], "5")
    T.eq(h._sections[4], "Grows fast")
    T.eq(h._sections[5], "Needs food")
    local altDown = findBinding(h, Keys.VK_DOWN, 4)
    T.truthy(altDown ~= nil, "Alt+Down section binding present with real BaseMenuItems")
    altDown()
    T.eq(speaks[#speaks].text, "Rome")
    altDown()
    T.eq(speaks[#speaks].text, "Pop")
    altDown()
    T.eq(speaks[#speaks].text, "5")
    altDown()
    T.eq(speaks[#speaks].text, "Grows fast")
    altDown()
    T.eq(speaks[#speaks].text, "Needs food")
    altDown()
    T.eq(speaks[#speaks].text, "Needs food", "Alt+Down past the last section re-speaks it")
end

function M.test_alt_up_from_fresh_enters_at_first_section()
    setup()
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    local h = BaseTable.create(sectionSpec())
    h.onTabActivated(h, true)
    local altUp = findBinding(h, Keys.VK_UP, 4)
    altUp()
    T.eq(speaks[#speaks].text, "Rome", "Alt+Up from fresh enters at section one")
end

-- A column may expose getCellSections to break a comma-joined cell value
-- (no [NEWLINE] for buildSections to split on) into discrete sections. When
-- present it replaces the single cell value; row label and column name still
-- lead, and the column tooltip still trails.
local function cellSectionsSpec()
    return {
        tabName = "TXT_KEY_CIVVACCESS_TBL_TAB",
        columns = {
            {
                name = "TXT_KEY_CIVVACCESS_TBL_COL_POP",
                getCell = function()
                    return "friendly, their vassal, very pleased by: shared friends"
                end,
                getCellSections = function()
                    return { "friendly", "their vassal", "very pleased by: shared friends" }
                end,
            },
        },
        rebuildRows = function()
            return { { name = "Rome" } }
        end,
        rowLabel = function(r)
            return r.name
        end,
    }
end

function M.test_get_cell_sections_replaces_cell_value()
    setup()
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    local h = BaseTable.create(cellSectionsSpec())
    h.onTabActivated(h, true)
    -- Row label, column name, then each getCellSections fragment as its own
    -- section -- not the joined getCell blob.
    T.eq(h._sections[1], "Rome")
    T.eq(h._sections[2], "Pop")
    T.eq(h._sections[3], "friendly")
    T.eq(h._sections[4], "their vassal")
    T.eq(h._sections[5], "very pleased by: shared friends")
    T.eq(#h._sections, 5)
end

return M

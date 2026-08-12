-- BaseTable produces a tab-shaped handler with a 2D-cursor table viewer.
-- Designed for screens whose content is a sortable table of homogeneous rows
-- with named columns: F2 city table, future F8 demographics, F9 hall of fame,
-- unit lists, etc. Hosted inside a TabbedShell or, in principle, pushed
-- standalone onto HandlerStack -- the contract matches both shapes.
--
-- Tab interface (also satisfies HandlerStack handler shape):
--   tabName        TXT_KEY spoken on Tab cycle (TabbedShell calls with
--                  announce=true after speakInterrupting screen displayName).
--   bindings       array of {key, mods, fn, description}.
--   helpEntries    array of {keyLabel, description} for the ? overlay.
--   onTabActivated(announce)  see TabbedShell contract.
--   onTabDeactivated()        clears the type-ahead filter.
--   handleSearchInput(self, vk, mods)
--                  type-ahead filter (narrows rows to label matches) routed
--                  through InputRouter.
--
-- Cursor model: row 0 is the column-header row (cursor lands there on Up
-- from data row 1; Enter cycles sort on the current column). Rows 1..N are
-- data rows from rebuildRows(), in iteration order or sorted order if a
-- sort column is active. _col is 1-based into the columns array. When the
-- spec carries a topItem, row -1 is a single control above the headers
-- (reached by Up from the header row); it has no columns, so Left / Right
-- are no-ops there and Enter runs its onActivate.
--
-- Speech dedupe: only the row label re-speaks when the row changes; only the
-- column name re-speaks when the column changes. The first announcement on
-- activation forces full context (row label + column name + cell value).
-- _chainSpeech toggles the activation announcement to speakQueued so it
-- chains after the shell's tabName speakInterrupt.
--
-- Sort cycle: Enter on header row cycles none -> descending -> ascending
-- -> none on the current column. Each transition speaks via TXT_KEYs in
-- CivVAccess_InGameStrings. Columns without a sortKey skip the cycle.
--
-- Spec:
--   tabName        (TXT_KEY string, required) -- spoken on cycle.
--   columns        (array, required, non-empty) per-column defs:
--     name         (TXT_KEY string, required) spoken on column change /
--                  sort cycle.
--     getCell      fn(row) -> string (required). Called on every nav so
--                  values stay live (no-cache rule).
--     sortKey      fn(row) -> sortable | nil. Optional. Column is
--                  sortable iff this is provided.
--     enterAction  fn(row) -> nil. Optional. Called when user hits Enter
--                  on a data cell in this column.
--     pediaName    fn(row) -> string | nil. Optional. Ctrl+I looks up
--                  pedia entry for this if defined.
--     getTooltip   fn(row) -> string | nil. Optional. Appended to the
--                  cell announcement on data rows via BaseMenuItems
--                  appendTooltip dedupe (the same routine BaseMenu uses
--                  for tooltipFn). Header row is unaffected.
--   rebuildRows    fn() -> array of opaque row objects (required). Called
--                  fresh on every nav event.
--   rowLabel       fn(row) -> string (required). Row's primary identifier.
--   entrySummaryFn fn() -> string | nil. Optional. Spoken (queued) on tab
--                  entry, after the tab name and before the first cell, so a
--                  screen-level summary line rides the activation announcement
--                  without being a navigable row. Re-read on every entry.
--   capturesAllInput  default true.
--   defaultSort    {column = <1-based index>, ascending = <bool>} | nil.
--                  Optional. When set, the table opens with that column's
--                  sort active (so the header row honestly reports it and
--                  Enter cycles it onward). Seeds the sort once at create
--                  time only; a sort the player changes afterward persists
--                  across closes/reopens for the life of the instance (until
--                  the screen's Context is rebuilt on a game reload), so the
--                  default does NOT re-apply on every open. The referenced
--                  column must carry a sortKey. Omit for natural rebuildRows
--                  order.
--   topItem        optional control row above the column headers:
--     labelFn      fn() -> string (required). Re-read on every landing so
--                  a value embedded in the label stays live.
--     onActivate   fn() -> nil. Optional. Enter / Space on the row. When
--                  absent, Enter re-speaks the label (same feedback rule
--                  as actionless data cells).
--     helpEntry    {keyLabel, description} | nil. Prepended to the tab's
--                  help list so the screen-specific control reads before
--                  the universal nav entries (BaseMenu helpExtras rule).
--                  The wrapper supplies it; landing on the row is what a
--                  user can't otherwise discover.
--
-- Hidden columns: callers filter columns before passing to BaseTable. F2's
-- science / faith columns are dropped at create time when the corresponding
-- game option is set, so the table sees a clean array with no hidden flags.

BaseTable = {}

local MOD_CTRL = 2
local MOD_ALT = 4

-- Reuse BaseMenu's wrap-sound primitive so column-edge wraps share the
-- "menu_wrap" cue that lists already use, and the same audio handle cache
-- on civvaccess_shared.menuSoundHandles. BaseMenu loads alongside BaseTable
-- in every Context that ships either (PopupBoot / FrontendCommon include
-- both); the nil guard keeps unit tests that load BaseTable in isolation
-- silent rather than crashing on a missing global.
local function playWrap()
    if BaseMenu ~= nil and type(BaseMenu._playWrap) == "function" then
        BaseMenu._playWrap()
    end
end

-- Build the live row list: rebuildRows, then the active type-ahead filter,
-- then sort if a column is active. Called on every nav event so both the
-- values and the filter membership reflect current game state (no-cache
-- rule). The filter is a live predicate re-run here every time, never a
-- stored set of row indices: a row that disappears between keystrokes simply
-- stops matching, and identities never go stale.
local function buildRows(self)
    local ok, rows = pcall(self.rebuildRows)
    if not ok then
        Log.error("BaseTable '" .. tostring(self.tabName) .. "' rebuildRows: " .. tostring(rows))
        return {}
    end
    if type(rows) ~= "table" then
        return {}
    end
    if self._filterQuery ~= "" then
        local q = string.lower(self._filterQuery:match("^(.-)%s*$") or self._filterQuery)
        if q ~= "" then
            local filtered = {}
            for i = 1, #rows do
                local label = TextFilter.filter(self.rowLabel(rows[i]))
                if label ~= nil and label ~= "" and TypeAheadSearch.matchTier(string.lower(label), q) >= 0 then
                    filtered[#filtered + 1] = rows[i]
                end
            end
            rows = filtered
        end
    end
    if self._sortColumn ~= nil then
        local col = self.columns[self._sortColumn]
        if col ~= nil and type(col.sortKey) == "function" then
            local asc = self._sortAscending
            table.sort(rows, function(a, b)
                local ka = col.sortKey(a)
                local kb = col.sortKey(b)
                if ka == kb then
                    return false
                end
                if asc then
                    return ka < kb
                end
                return ka > kb
            end)
        end
    end
    return rows
end

-- Compose the "row label, column name, cell value" announcement, eliding
-- redundant parts when only the row or only the column changed since the
-- last speech. force=true rebuilds the full announcement (used on
-- activation, sort, and search jump).
local function buildCellSpeech(self, rows, force)
    if self._row == -1 then
        local item = self._topItem
        if item == nil then
            return nil
        end
        local ok, text = pcall(item.labelFn)
        if not ok then
            Log.error("BaseTable '" .. tostring(self.tabName) .. "' topItem labelFn: " .. tostring(text))
            return nil
        end
        return text
    end
    if self._row == 0 then
        local col = self.columns[self._col]
        if col == nil then
            return nil
        end
        local result = Text.key(col.name)
        if Verbosity.isOn() then
            -- Sort affordance: tells the user the header cell is a button
            -- that cycles sort on Enter. Only sortable columns get the
            -- suffix; columns without a sortKey skip the cycle and the
            -- suffix would mislead. Then the column-of position suffix.
            -- Both gated behind Verbosity per the no-type-suffixes rule.
            if type(col.sortKey) == "function" then
                result = result .. ", " .. Text.key("TXT_KEY_CIVVACCESS_BASETABLE_SORT_BUTTON")
            end
            result = result .. ", " .. Text.format("TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF", self._col, #self.columns)
        end
        return result
    end
    local row = rows[self._row]
    if row == nil then
        return nil
    end
    local col = self.columns[self._col]
    local parts = {}
    if force or self._row ~= self._lastSpokenRow then
        local label = self.rowLabel(row)
        if label ~= nil and label ~= "" then
            parts[#parts + 1] = label
        end
    end
    if col ~= nil then
        if force or self._col ~= self._lastSpokenCol then
            local cname = Text.key(col.name)
            if cname ~= nil and cname ~= "" then
                parts[#parts + 1] = cname
            end
        end
        if type(col.getCell) == "function" then
            local ok, cell = pcall(col.getCell, row)
            if not ok then
                Log.error("BaseTable getCell '" .. tostring(col.name) .. "': " .. tostring(cell))
            elseif cell ~= nil and cell ~= "" then
                parts[#parts + 1] = cell
            end
        end
    end
    if #parts == 0 then
        return nil
    end
    local result = table.concat(parts, ", ")
    if
        col ~= nil
        and type(col.getTooltip) == "function"
        and BaseMenuItems ~= nil
        and type(BaseMenuItems.appendTooltip) == "function"
    then
        local ok, tt = pcall(col.getTooltip, row)
        if not ok then
            Log.error("BaseTable getTooltip '" .. tostring(col.name) .. "': " .. tostring(tt))
        elseif tt ~= nil and tt ~= "" then
            result = BaseMenuItems.appendTooltip(result, tt)
        end
    end
    -- Verbose row/column suffix on data rows. Bypasses the row-only /
    -- column-only dedupe above (full counts re-speak on every move) --
    -- verbose users have opted into the longer announce.
    if Verbosity.isOn() then
        result = result
            .. ", "
            .. Text.format("TXT_KEY_CIVVACCESS_VERBOSE_ROW_OF", self._row, #rows)
            .. ", "
            .. Text.format("TXT_KEY_CIVVACCESS_VERBOSE_COLUMN_OF", self._col, #self.columns)
    end
    return result
end

-- Full content sections for Alt+Up/Down review of the focused cell. Unlike
-- buildCellSpeech (which elides an unchanged row/column and appends the
-- verbose row/column counts), this always carries row label, column name,
-- and cell value, then the column tooltip split into sentences -- the same
-- section shape BaseMenuItems builds for a menu item. Header / top rows and
-- contexts without BaseMenuItems return nil; speakCell then falls back to a
-- single section from the spoken text.
local function buildCellSections(self, rows)
    if BaseMenuItems == nil or type(BaseMenuItems.buildSections) ~= "function" then
        return nil
    end
    if self._row < 1 then
        return nil
    end
    local row = rows[self._row]
    if row == nil then
        return nil
    end
    local parts = {}
    local label = self.rowLabel(row)
    if label ~= nil and label ~= "" then
        parts[#parts + 1] = label
    end
    local tooltip = nil
    local col = self.columns[self._col]
    if col ~= nil then
        local cname = Text.key(col.name)
        if cname ~= nil and cname ~= "" then
            parts[#parts + 1] = cname
        end
        -- A column may expose getCellSections to hand the reviewer the
        -- discrete fragments it joined into the cell value (e.g. the
        -- diplomacy relationship breakdown's valence buckets), since the
        -- joined getCell string has no [NEWLINE] for buildSections to split
        -- on. When present it replaces the single cell value; each fragment
        -- becomes its own section. Falls back to getCell otherwise.
        local usedSections = false
        if type(col.getCellSections) == "function" then
            local ok, frags = pcall(col.getCellSections, row)
            if ok and type(frags) == "table" then
                for _, frag in ipairs(frags) do
                    if frag ~= nil and frag ~= "" then
                        parts[#parts + 1] = frag
                    end
                end
                usedSections = true
            elseif not ok then
                Log.error("BaseTable getCellSections failed: " .. tostring(frags))
            end
        end
        if not usedSections and type(col.getCell) == "function" then
            local ok, cell = pcall(col.getCell, row)
            if ok and cell ~= nil and cell ~= "" then
                parts[#parts + 1] = cell
            end
        end
        if type(col.getTooltip) == "function" then
            local ok, tt = pcall(col.getTooltip, row)
            if ok and tt ~= nil and tt ~= "" then
                tooltip = tt
            end
        end
    end
    return BaseMenuItems.buildSections(parts, false, tooltip)
end

local function speakCell(self, force)
    local rows = buildRows(self)
    -- Clamp _row in case rebuildRows now yields fewer entries than last time.
    local maxRow = #rows
    if self._row > maxRow then
        self._row = maxRow > 0 and maxRow or 0
    end
    local text = buildCellSpeech(self, rows, force)
    self._lastSpokenRow = self._row
    self._lastSpokenCol = self._col
    if text == nil then
        return
    end
    local speak = self._chainSpeech and SpeechPipeline.speakQueued or SpeechPipeline.speakInterrupt
    speak(text)
    -- Refresh Alt+Up/Down review sections for the focused cell.
    if BaseMenuItems ~= nil and BaseMenuItems.SectionReview ~= nil then
        local sections = buildCellSections(self, rows)
        if sections == nil or #sections == 0 then
            local f = TextFilter.filter(text)
            sections = (f ~= nil and f ~= "") and { f } or {}
        end
        BaseMenuItems.SectionReview.set(self, sections)
    end
end

-- Navigation -----------------------------------------------------------
--
-- Arrows / Home / End move within whatever set buildRows currently yields --
-- the full table, or the filtered subset when a type-ahead filter is active.
-- They deliberately leave the filter alone: navigating the matches is the
-- point of the filter, and typing more narrows it further (see the filter
-- section below).

local function onUp(self)
    if self._row == -1 then
        return
    end
    if self._row == 0 then
        if self._topItem ~= nil then
            self._row = -1
            speakCell(self, true)
        end
        return
    end
    self._row = self._row - 1
    speakCell(self, false)
end

local function onDown(self)
    local rows = buildRows(self)
    if self._row >= #rows then
        return
    end
    self._row = self._row + 1
    speakCell(self, false)
end

local function onLeft(self)
    -- The top control spans the table; there is no column to move to.
    if self._row == -1 then
        return
    end
    local n = #self.columns
    if n == 0 then
        return
    end
    if self._col > 1 then
        self._col = self._col - 1
    else
        self._col = n
        playWrap()
    end
    speakCell(self, false)
end

local function onRight(self)
    if self._row == -1 then
        return
    end
    local n = #self.columns
    if n == 0 then
        return
    end
    if self._col < n then
        self._col = self._col + 1
    else
        self._col = 1
        playWrap()
    end
    speakCell(self, false)
end

local function onHome(self)
    -- First data row, current column. From the header row the user can
    -- press Down to enter data; Home is for jumping among data rows, so
    -- it always lands on row 1.
    local rows = buildRows(self)
    if #rows == 0 then
        return
    end
    self._row = 1
    speakCell(self, false)
end

local function onEnd(self)
    local rows = buildRows(self)
    if #rows == 0 then
        return
    end
    self._row = #rows
    speakCell(self, false)
end

-- Sort cycle: none -> descending -> ascending -> none. Each transition
-- announces "<column>, <direction>" so the user hears the new state.
local function cycleSort(self)
    local col = self.columns[self._col]
    if col == nil or type(col.sortKey) ~= "function" then
        -- Not sortable; no feedback (matches BaseMenu's silent no-op for
        -- non-activatable rows). Future: speak "not sortable" if needed.
        return
    end
    local cname = Text.key(col.name)
    if self._sortColumn ~= self._col then
        self._sortColumn = self._col
        self._sortAscending = false
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_BASETABLE_SORT_DESC", cname))
    elseif not self._sortAscending then
        self._sortAscending = true
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_BASETABLE_SORT_ASC", cname))
    else
        self._sortColumn = nil
        self._sortAscending = false
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_BASETABLE_SORT_CLEARED", cname))
    end
end

local function onEnter(self)
    if self._row == -1 then
        local item = self._topItem
        if item ~= nil and type(item.onActivate) == "function" then
            local ok, err = pcall(item.onActivate)
            if not ok then
                Log.error("BaseTable '" .. tostring(self.tabName) .. "' topItem onActivate: " .. tostring(err))
            end
        else
            speakCell(self, true)
        end
        return
    end
    if self._row == 0 then
        cycleSort(self)
        return
    end
    local rows = buildRows(self)
    local row = rows[self._row]
    if row == nil then
        return
    end
    local col = self.columns[self._col]
    if col == nil or type(col.enterAction) ~= "function" then
        -- No action defined for this cell: re-speak as feedback.
        speakCell(self, true)
        return
    end
    local ok, err = pcall(col.enterAction, row)
    if not ok then
        Log.error("BaseTable enterAction '" .. tostring(col.name) .. "': " .. tostring(err))
    end
end

local function onPedia(self)
    if self._row <= 0 then
        return
    end
    local rows = buildRows(self)
    local row = rows[self._row]
    if row == nil then
        return
    end
    local col = self.columns[self._col]
    if col == nil or type(col.pediaName) ~= "function" then
        return
    end
    local ok, name = pcall(col.pediaName, row)
    if not ok or name == nil or name == "" then
        return
    end
    if Events ~= nil and Events.SearchForPediaEntry ~= nil then
        -- Arm pedia-transit flag so the underlying screen's hide handler
        -- preserves cursor state (see CivVAccess_BaseMenuCore.lua's Ctrl+I
        -- binding for the matching rationale).
        civvaccess_shared.pediaTransitArmed = true
        Events.SearchForPediaEntry(name)
    end
end

-- Type-ahead filter ----------------------------------------------------
--
-- Typing narrows the table to the rows whose label matches the buffer
-- (matchTier against rowLabel, the same matcher BaseMenu type-ahead uses);
-- arrows / Home / End / Enter then operate on that subset exactly as on the
-- full table, since buildRows applies the filter and every nav handler reads
-- through buildRows. From the user's side this is indistinguishable from
-- BaseMenu type-ahead: type to find, navigate the matches, backspace or
-- Escape to clear. Typing more appends to the buffer and narrows further;
-- there is no result-count speech, which would re-fire on every keystroke.

-- Re-land after the filter buffer changed: top of the (filtered) set, full
-- context. An empty result speaks the shared no-match line and parks on the
-- header row so Up / Down stay valid and Backspace can recover.
local function applyFilter(self)
    local rows = buildRows(self)
    if #rows == 0 then
        self._row = 0
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_SEARCH_NO_MATCH", self._filterQuery))
        return
    end
    self._row = 1
    speakCell(self, true)
end

-- Clear the filter, keeping the cursor on the same row where it can: the
-- focused row object is relocated in the now-full list, falling back to its
-- clamped numeric index when identity can't be matched. Speaks the shared
-- "search cleared" line and does not re-announce the row -- matching
-- BaseMenu's clear, which leaves the cursor where it sits.
local function clearFilter(self)
    local focused = nil
    if self._row >= 1 then
        focused = buildRows(self)[self._row]
    end
    self._filterQuery = ""
    if focused ~= nil then
        local rows = buildRows(self)
        for i = 1, #rows do
            if rows[i] == focused then
                self._row = i
                break
            end
        end
        if self._row > #rows then
            self._row = #rows > 0 and #rows or 0
        end
    end
    -- The cursor moved silently (filtered index to full-table index), so the
    -- speech-dedupe baseline must follow it. Otherwise it still points at the
    -- filtered position and the next arrow move can elide the row label or
    -- column name when the new position happens to match the stale baseline.
    self._lastSpokenRow = self._row
    self._lastSpokenCol = self._col
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
end

local function handleSearchInput(self, vk, mods)
    local hasCtrl = math.floor(mods / 2) % 2 == 1
    local hasAlt = math.floor(mods / 4) % 2 == 1
    if hasCtrl or hasAlt then
        return false
    end
    -- Letters / digits narrow the filter; Space extends a multi-word query;
    -- Backspace widens it (and clears at empty). Arrows / Home / End / Enter
    -- are NOT consumed -- they fall through to the normal nav bindings, which
    -- now walk the filtered subset.
    if vk >= 0x41 and vk <= 0x5A then
        self._filterQuery = self._filterQuery .. string.char(vk + 32)
        applyFilter(self)
        return true
    end
    if vk >= 0x30 and vk <= 0x39 then
        self._filterQuery = self._filterQuery .. string.char(vk)
        applyFilter(self)
        return true
    end
    if vk == Keys.VK_SPACE and self._filterQuery ~= "" then
        self._filterQuery = self._filterQuery .. " "
        applyFilter(self)
        return true
    end
    if vk == Keys.VK_BACK then
        if self._filterQuery == "" then
            return false
        end
        self._filterQuery = string.sub(self._filterQuery, 1, #self._filterQuery - 1)
        if self._filterQuery == "" then
            clearFilter(self)
        else
            applyFilter(self)
        end
        return true
    end
    return false
end

-- Help entries (authored TXT_KEYs in CivVAccess_InGameStrings) ----------

local function buildHelpEntries(spec)
    local entries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_UP_DOWN",
            description = "TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_ROWS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_LEFT_RIGHT",
            description = "TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_NAV_COLS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ALT_UP_DOWN",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_REVIEW_SECTIONS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ALT_HOME_END",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_REVIEW_FIRST_LAST",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_HOME_END",
            description = "TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_HOME_END",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ENTER",
            description = "TXT_KEY_CIVVACCESS_BASETABLE_HELP_DESC_ENTER",
        },
        { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_AZ09", description = "TXT_KEY_CIVVACCESS_HELP_DESC_SEARCH" },
    }
    if spec._anyPedia and Events ~= nil and Events.SearchForPediaEntry ~= nil then
        entries[#entries + 1] = {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_I",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_CIVILOPEDIA",
        }
    end
    return entries
end

-- Factory ---------------------------------------------------------------

function BaseTable.create(spec)
    Log.check(type(spec) == "table", "BaseTable.create requires a spec table")
    Log.check(type(spec.tabName) == "string" and spec.tabName ~= "", "spec.tabName required")
    Log.check(type(spec.columns) == "table" and #spec.columns >= 1, "spec.columns must be a non-empty array")
    for i, c in ipairs(spec.columns) do
        Log.check(type(c) == "table", "columns[" .. i .. "] must be a table")
        Log.check(type(c.name) == "string" and c.name ~= "", "columns[" .. i .. "].name required")
        Log.check(type(c.getCell) == "function", "columns[" .. i .. "].getCell required")
        Log.check(
            c.sortKey == nil or type(c.sortKey) == "function",
            "columns[" .. i .. "].sortKey must be a function if provided"
        )
        Log.check(
            c.enterAction == nil or type(c.enterAction) == "function",
            "columns[" .. i .. "].enterAction must be a function if provided"
        )
        Log.check(
            c.pediaName == nil or type(c.pediaName) == "function",
            "columns[" .. i .. "].pediaName must be a function if provided"
        )
        Log.check(
            c.getTooltip == nil or type(c.getTooltip) == "function",
            "columns[" .. i .. "].getTooltip must be a function if provided"
        )
    end
    Log.check(type(spec.rebuildRows) == "function", "spec.rebuildRows required")
    Log.check(type(spec.rowLabel) == "function", "spec.rowLabel required")
    Log.check(
        spec.entrySummaryFn == nil or type(spec.entrySummaryFn) == "function",
        "spec.entrySummaryFn must be a function if provided"
    )
    if spec.topItem ~= nil then
        Log.check(type(spec.topItem) == "table", "spec.topItem must be a table")
        Log.check(type(spec.topItem.labelFn) == "function", "spec.topItem.labelFn required")
        Log.check(
            spec.topItem.onActivate == nil or type(spec.topItem.onActivate) == "function",
            "spec.topItem.onActivate must be a function if provided"
        )
        Log.check(
            spec.topItem.helpEntry == nil or type(spec.topItem.helpEntry) == "table",
            "spec.topItem.helpEntry must be a table if provided"
        )
    end

    local defaultSortColumn = nil
    local defaultSortAscending = false
    if spec.defaultSort ~= nil then
        Log.check(type(spec.defaultSort) == "table", "spec.defaultSort must be a table")
        local ds = spec.defaultSort
        Log.check(
            type(ds.column) == "number" and ds.column >= 1 and ds.column <= #spec.columns,
            "spec.defaultSort.column must be a valid column index"
        )
        Log.check(
            type(spec.columns[ds.column].sortKey) == "function",
            "spec.defaultSort.column must reference a sortable column"
        )
        defaultSortColumn = ds.column
        defaultSortAscending = ds.ascending == true
    end

    local self = {
        tabName = spec.tabName,
        -- Verbosity-gated suffix appended to the spoken tab name on every
        -- activation. TabbedShell.resolveTabName consults this for first-
        -- open speech, and our own onTabActivated does the same for cycle
        -- and standalone push, so all three paths agree on "<tabName>,
        -- table" when the setting is on.
        tabNameVerboseSuffixKey = "TXT_KEY_CIVVACCESS_KIND_TABLE",
        columns = spec.columns,
        rebuildRows = spec.rebuildRows,
        rowLabel = spec.rowLabel,
        _entrySummaryFn = spec.entrySummaryFn,
        _topItem = spec.topItem,
        capturesAllInput = spec.capturesAllInput ~= false,
        _row = 1,
        _col = 1,
        _lastSpokenRow = nil,
        _lastSpokenCol = nil,
        _sortColumn = defaultSortColumn,
        _sortAscending = defaultSortAscending,
        _initialized = false,
        _filterQuery = "",
    }

    -- Detect any pediaName columns to gate the Ctrl+I help entry.
    local anyPedia = false
    for _, c in ipairs(spec.columns) do
        if type(c.pediaName) == "function" then
            anyPedia = true
            break
        end
    end

    self.bindings = {
        {
            key = Keys.VK_UP,
            mods = 0,
            description = "Previous row",
            fn = function()
                onUp(self)
            end,
        },
        {
            key = Keys.VK_DOWN,
            mods = 0,
            description = "Next row",
            fn = function()
                onDown(self)
            end,
        },
        {
            key = Keys.VK_LEFT,
            mods = 0,
            description = "Previous column",
            fn = function()
                onLeft(self)
            end,
        },
        {
            key = Keys.VK_RIGHT,
            mods = 0,
            description = "Next column",
            fn = function()
                onRight(self)
            end,
        },
        {
            key = Keys.VK_HOME,
            mods = 0,
            description = "First data row",
            fn = function()
                onHome(self)
            end,
        },
        {
            key = Keys.VK_END,
            mods = 0,
            description = "Last data row",
            fn = function()
                onEnd(self)
            end,
        },
        {
            key = Keys.VK_RETURN,
            mods = 0,
            description = "Activate / sort",
            fn = function()
                onEnter(self)
            end,
        },
        {
            key = Keys.VK_SPACE,
            mods = 0,
            description = "Activate / sort",
            fn = function()
                onEnter(self)
            end,
        },
    }
    if BaseMenuItems ~= nil and BaseMenuItems.SectionReview ~= nil then
        self.bindings[#self.bindings + 1] = {
            key = Keys.VK_DOWN,
            mods = MOD_ALT,
            description = "Next section of current cell",
            fn = function()
                BaseMenuItems.SectionReview.next(self)
            end,
        }
        self.bindings[#self.bindings + 1] = {
            key = Keys.VK_UP,
            mods = MOD_ALT,
            description = "Previous section of current cell",
            fn = function()
                BaseMenuItems.SectionReview.prev(self)
            end,
        }
        self.bindings[#self.bindings + 1] = {
            key = Keys.VK_HOME,
            mods = MOD_ALT,
            description = "First section of current cell",
            fn = function()
                BaseMenuItems.SectionReview.first(self)
            end,
        }
        self.bindings[#self.bindings + 1] = {
            key = Keys.VK_END,
            mods = MOD_ALT,
            description = "Last section of current cell",
            fn = function()
                BaseMenuItems.SectionReview.last(self)
            end,
        }
    end
    if anyPedia and Events ~= nil and Events.SearchForPediaEntry ~= nil then
        self.bindings[#self.bindings + 1] = {
            key = Keys.I,
            mods = MOD_CTRL,
            description = "Civilopedia",
            fn = function()
                onPedia(self)
            end,
        }
    end

    self.helpEntries = buildHelpEntries({ _anyPedia = anyPedia })
    if spec.topItem ~= nil and spec.topItem.helpEntry ~= nil then
        table.insert(self.helpEntries, 1, spec.topItem.helpEntry)
    end

    -- Tab-interface methods: TabbedShell calls these on cycle and shell
    -- lifecycle. Function form (not method) so signature matches the
    -- TabbedShell contract (self passed as first arg explicitly).
    function self.onTabActivated(_self, announce)
        if not self._initialized then
            self._initialized = true
            self._row = 1
            self._col = 1
            self._lastSpokenRow = nil
            self._lastSpokenCol = nil
            self._filterQuery = ""
            -- Sort (_sortColumn / _sortAscending) is deliberately NOT reset
            -- here: the instance is long-lived across opens within a session,
            -- so a sort the player set on a prior open survives until the
            -- screen's Context is rebuilt (a game reload). The default sort is
            -- seeded once at create time and only re-seeds on that rebuild.
            -- If rebuildRows yields zero rows on first open, land on row 0
            -- (header) so the user hears something speakable.
            local rows = buildRows(self)
            if #rows == 0 then
                self._row = 0
            end
        end
        if announce then
            SpeechPipeline.speakInterrupt(Verbosity.appendSuffix(Text.key(self.tabName), self.tabNameVerboseSuffixKey))
            if self._entrySummaryFn ~= nil then
                local ok, summary = pcall(self._entrySummaryFn)
                if not ok then
                    Log.error("BaseTable '" .. tostring(self.tabName) .. "' entrySummaryFn: " .. tostring(summary))
                elseif summary ~= nil and summary ~= "" then
                    SpeechPipeline.speakQueued(summary)
                end
            end
        end
        self._chainSpeech = true
        speakCell(self, true)
        self._chainSpeech = nil
    end

    function self.onTabDeactivated()
        self._filterQuery = ""
    end

    -- Replace the column set on the fly. For a column whose presence depends
    -- on live game state (e.g. the host-only kick column, which must track a
    -- mid-game host migration), the caller rebuilds columns on each screen
    -- open and hands them here. Clamps the focused column so dropping a
    -- trailing column can't strand _col past the end; existing-column indices
    -- are assumed stable, so the active sort column survives.
    function self.refreshColumns(newColumns)
        self.columns = newColumns
        if self._col > #newColumns then
            self._col = #newColumns
        end
    end

    function self.handleSearchInput(_me, vk, mods)
        return handleSearchInput(self, vk, mods)
    end

    function self.clearSearchIfActive()
        if self._filterQuery ~= "" then
            clearFilter(self)
            return true
        end
        return false
    end

    function self.resetForNextOpen()
        self._initialized = false
    end

    -- Standalone-handler lifecycle: when pushed onto HandlerStack directly
    -- (not as a tab), HandlerStack calls onActivate / onDeactivate. Mirror
    -- to onTabActivated(true) / onTabDeactivated so a screen that wants a
    -- single-table view without a TabbedShell can use BaseTable as-is.
    function self.onActivate()
        self.onTabActivated(self, true)
    end

    function self.onDeactivate()
        self.onTabDeactivated()
    end

    return self
end

return BaseTable

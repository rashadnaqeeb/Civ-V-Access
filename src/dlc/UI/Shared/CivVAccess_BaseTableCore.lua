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
--   onTabDeactivated()        clears type-ahead buffer.
--   handleSearchInput(self, vk, mods)
--                  type-ahead column search routed through InputRouter.
--
-- Cursor model: row 0 is the column-header row (cursor lands there on Up
-- from data row 1; Enter cycles sort on the current column). Rows 1..N are
-- data rows from rebuildRows(), in iteration order or sorted order if a
-- sort column is active. _col is 1-based into the columns array.
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
--   rebuildRows    fn() -> array of opaque row objects (required). Called
--                  fresh on every nav event.
--   rowLabel       fn(row) -> string (required). Row's primary identifier.
--   capturesAllInput  default true.
--
-- Hidden columns: callers filter columns before passing to BaseTable. F2's
-- science / faith columns are dropped at create time when the corresponding
-- game option is set, so the table sees a clean array with no hidden flags.

BaseTable = {}

local MOD_CTRL = 2

-- Build the live row list, applying sort if a column is active. Called on
-- every nav event so values reflect current game state (no-cache rule).
local function buildRows(self)
    local ok, rows = pcall(self.rebuildRows)
    if not ok then
        Log.error("BaseTable '" .. tostring(self.tabName) .. "' rebuildRows: " .. tostring(rows))
        return {}
    end
    if type(rows) ~= "table" then
        return {}
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
    if self._row == 0 then
        local col = self.columns[self._col]
        if col == nil then
            return nil
        end
        return Text.key(col.name)
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
    return table.concat(parts, ", ")
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
end

-- Navigation -----------------------------------------------------------

local function onUp(self)
    if self._row == 0 then
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
    local n = #self.columns
    if n == 0 then
        return
    end
    if self._col > 1 then
        self._col = self._col - 1
    else
        self._col = n
    end
    speakCell(self, false)
end

local function onRight(self)
    local n = #self.columns
    if n == 0 then
        return
    end
    if self._col < n then
        self._col = self._col + 1
    else
        self._col = 1
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
    if self._row == 0 then
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
        Events.SearchForPediaEntry(name)
    end
end

-- Type-ahead column search ----------------------------------------------

local function buildSearchable(self)
    return {
        itemCount = function()
            return #self.columns
        end,
        getLabel = function(i)
            local c = self.columns[i]
            if c == nil then
                return nil
            end
            return TextFilter.filter(Text.key(c.name))
        end,
        moveTo = function(i)
            self._col = i
            speakCell(self, false)
        end,
    }
end

local function handleSearchInput(self, vk, mods)
    local hasCtrl = math.floor(mods / 2) % 2 == 1
    local hasAlt = math.floor(mods / 4) % 2 == 1
    if hasCtrl or hasAlt then
        return false
    end
    local search = self._search
    if vk >= 0x41 and vk <= 0x5A then
        return search:handleChar(string.char(vk + 32), buildSearchable(self))
    end
    if vk >= 0x30 and vk <= 0x39 then
        return search:handleChar(string.char(vk), buildSearchable(self))
    end
    if vk == Keys.VK_SPACE and search:isSearchActive() then
        return search:handleKey(Keys.VK_SPACE, false, false, buildSearchable(self))
    end
    if vk == Keys.VK_BACK then
        return search:handleKey(Keys.VK_BACK, false, false, buildSearchable(self))
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
    end
    Log.check(type(spec.rebuildRows) == "function", "spec.rebuildRows required")
    Log.check(type(spec.rowLabel) == "function", "spec.rowLabel required")

    local self = {
        tabName = spec.tabName,
        columns = spec.columns,
        rebuildRows = spec.rebuildRows,
        rowLabel = spec.rowLabel,
        capturesAllInput = spec.capturesAllInput ~= false,
        _row = 1,
        _col = 1,
        _lastSpokenRow = nil,
        _lastSpokenCol = nil,
        _sortColumn = nil,
        _sortAscending = false,
        _initialized = false,
        _search = TypeAheadSearch.new(),
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
            self._sortColumn = nil
            self._sortAscending = false
            self._search:clear()
            -- If rebuildRows yields zero rows on first open, land on row 0
            -- (header) so the user hears something speakable.
            local rows = buildRows(self)
            if #rows == 0 then
                self._row = 0
            end
        end
        if announce then
            SpeechPipeline.speakInterrupt(Text.key(self.tabName))
        end
        self._chainSpeech = true
        speakCell(self, true)
        self._chainSpeech = nil
    end

    function self.onTabDeactivated()
        self._search:clear()
    end

    function self.handleSearchInput(_me, vk, mods)
        return handleSearchInput(self, vk, mods)
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

-- Tech Tree screen accessibility. Wraps the in-game TechTree Context
-- (BUTTONPOPUP_TECH_TREE) as a TabbedShell with two tabs:
--
--   Tree    hand-rolled tab object; two arrow-key navigation modes that
--           the user toggles with Space.
--             grid (default) walks the visual layout: Up/Down through the
--             era column at the cursor's GridX (skipping rows with no tech
--             at that GridX, silent at edges); Left/Right step exactly one
--             column at a time, snapping to whichever tech in the adjacent
--             column is nearest a sticky "intended row" the user committed
--             to with their last Up/Down move (silent when no tech at all
--             exists in the adjacent column). Spatial nav is path-
--             independent so the user can cut across to a peer tech they
--             remember without retracing prereq edges; the intended-row
--             stickiness keeps a horizontal run anchored to the chosen
--             row instead of drifting away through ragged columns.
--             tree walks the prereq DAG: Right to a child (dependent
--             tech), Left to a parent (prerequisite), Up/Down across
--             siblings (children of the parent we descended from, or the
--             parents of the child we ascended to). NavigableGraph owns
--             the pure DAG cursor; tech-specific adjacency lambdas,
--             label composition, and commit eligibility live in
--             CivVAccess_TechTreeLogic so offline tests can exercise them
--             without dofiling this wrapper.
--           Mode toggle preserves the cursor; siblings are reseeded so
--           tree mode's Up/Down has a fresh sibling list around wherever
--           the cursor is. Help entries swap on toggle: only the active
--           mode's arrow descriptions are listed under ?.
--           Enter / Shift+Enter commits via Network.SendResearch in
--           either mode. Type-ahead search across tech name + unlocks
--           prose works in either mode.
--           Era boundary announcement: when an arrow move lands on a
--           tech in a different era than the previous cursor position,
--           the era display name prefixes the landing speech ("Classical
--           Era. Banking, available, ..."). Same-era moves don't repeat
--           it. Skipped on search-driven jumps (the search target is
--           usually far from the prior cursor; the era word adds noise),
--           but _prevEraID is updated silently so the next arrow move
--           compares against the searched-to era.
--   Queue   TabbedShell.menuTab over a BaseMenu list. Items are rebuilt
--           on every onTabActivated so the queue reflects post-commit
--           state when the user Tabs over after queuing a tech. Era
--           announcement is tree-tab-only -- the queue is a flat list
--           ordered by queue slot, not era.
--
-- Commit: Network.SendResearch(techID, numFreeTechs, stealingTargetID,
-- shift). Normal / free modes pass GetNumFreeTechs; stealing passes 0
-- with the target ID. Shift+Enter in normal mode queue-appends; the
-- confirmation speech just says "queued <name>" because SendResearch
-- is network-dispatched and GetQueuePosition on the next line reads
-- pre-commit state. The user can Tab to the queue tab to hear the
-- actual slot ordering. Free / stealing modes ignore Shift -- they
-- commit once and the engine chains subsequent popups as needed.
--
-- Stealing target: stock TechTree.lua captures popupInfo.Data2 into a
-- chunk-local (unreachable from our appended include). We register our
-- own SerialEventGameMessagePopup listener that mirrors the capture into
-- a module upvalue. UIManager:QueuePopup defers ContextPtr show to the
-- next frame, so both listeners run in the same frame before ShowHide
-- fires and the upvalue is current by the time onTabActivated reads it.
--
-- Load-from-game: the TechTree Context re-initializes like other popup
-- Contexts, so our listener registers fresh on every include. No
-- install-once guards; dead prior-game listeners are tolerated because
-- the engine catches per-listener throws and the current live one still
-- fires.
--
-- Search: letters / digits / Space / Backspace feed a TypeAheadSearch
-- instance whose corpus is "name, unlocks prose" per tech. Each keystroke
-- moves the DAG cursor to the top match via TechTreeLogic.seedCursorSiblings
-- (same seed the initial landing uses) and speaks the normal landing
-- speech. Arrow keys clear the buffer silently before tree nav so typing
-- never contaminates a subsequent arrow move. Esc with a buffer clears
-- and speaks "search cleared"; Esc with no buffer falls through to the
-- base TechTree.lua InputHandler which closes the popup.
--
-- F1: TabbedShell owns F1 and reads "Tech Tree" + active tab name. The
-- mode preamble (free-tech / stealing) is reachable via Tab cycle into
-- the tree tab, whose onTabActivated re-speaks it.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_TabbedShell")
include("CivVAccess_Help")
include("CivVAccess_NavigableGraph")
include("CivVAccess_ChooseTechLogic")
include("CivVAccess_TechTreeLogic")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_CTRL = 2

-- Populated on BUTTONPOPUP_TECH_TREE fires; stable across Show/Hide for a
-- given open and re-written on the next open.
local _stealingTargetID = -1

-- Screen state. Reset on every hide.
local _graph = nil
local _cursor = nil
local _corpus = nil
local _search = nil
local _grid = nil
-- "grid" or "tree". Default grid; toggled by Space within the tree tab.
-- Reset to "grid" on hide so each open starts in the spatial mode.
local _navMode = "grid"
-- Era ID of the cursor's current tech, used to detect era boundaries on
-- the next move. nil after setupForShow so the very first speech of an
-- open announces the era as orientation. Updated by every speech path
-- (arrow, search, mode toggle, tab re-entry) so future comparisons are
-- consistent regardless of how the cursor moved.
local _prevEraID = nil
-- Spreadsheet-style intended row for grid-mode horizontal nav. Up / Down
-- update it to the new tech's GridY (the user explicitly chose that row);
-- Left / Right read it as the snap target but leave it untouched, so a
-- run of horizontal moves through columns that don't all have a tech at
-- the intended row snaps each time without permanently drifting away.
-- Reseeded on initial cursor placement, search-driven landings, and
-- mode-toggle reseats so the grid axis is always anchored to the cursor's
-- current row at the moment vertical context was last meaningful.
local _intendedGridY = nil
-- Captured in onShow. Used by the Space toggle to call rebuildExposed()
-- after swapping the tab's helpEntries so ? help shows the active mode's
-- arrow description.
local _shellHandler = nil
-- Mode-specific help entry lists, populated in buildTreeTab and assigned
-- to the live tab.helpEntries on each toggle. Same shell-level entries
-- (Tab cycling, F1) compose around either set.
local _gridHelpEntries = nil
local _treeHelpEntries = nil
-- Reference to the tree tab table so setMode can mutate its helpEntries
-- in place. Assigned in buildTreeTab.
local _treeTab = nil

local function currentPlayer()
    return Players[Game.GetActivePlayer()]
end

local function currentMode()
    local p = currentPlayer()
    if p == nil then
        return "normal"
    end
    return TechTreeLogic.currentMode(p, _stealingTargetID)
end

-- ===== Speech helpers =====

-- Speak the landing speech with an era prefix when the new tech's era
-- differs from the previous cursor's era. Updates _prevEraID as a side
-- effect so the next call compares against the just-spoken tech.
local function speakLanding(techID)
    local p = currentPlayer()
    if p == nil then
        return
    end
    local prefix
    prefix, _prevEraID = TechTreeLogic.eraPrefix(_prevEraID, techID)
    SpeechPipeline.speakInterrupt(prefix .. TechTreeLogic.buildLandingSpeech(techID, p))
end

-- Same as speakLanding but suppresses the era prefix. Used by search-
-- driven landings (per design: search jumps don't announce era boundaries
-- because every search is a jump). _prevEraID still updates to the new
-- tech's era so a subsequent arrow move compares from there rather than
-- falsely announcing a boundary against the pre-search position.
local function speakLandingNoEra(techID)
    local p = currentPlayer()
    if p == nil then
        return
    end
    _prevEraID = TechTreeLogic.eraID(techID) or _prevEraID
    SpeechPipeline.speakInterrupt(TechTreeLogic.buildLandingSpeech(techID, p))
end

-- ===== Tree commit =====

local function commit(shift)
    local cur = _cursor and _cursor.current()
    if cur == nil then
        return
    end
    local p = currentPlayer()
    if p == nil then
        Log.error("TechTreeAccess: commit with no active player")
        return
    end
    local techID = cur.ID
    local mode = currentMode()
    local ok, rejectKey = TechTreeLogic.commitEligibility(p, techID, mode, _stealingTargetID)
    if not ok then
        SpeechPipeline.speakInterrupt(Text.key(rejectKey))
        return
    end
    local techName = Text.key(GameInfo.Technologies[techID].Description)
    -- Free and stealing modes treat Shift as Enter: both commit once and
    -- the engine chains subsequent popups for remaining picks. Queue-append
    -- is normal-mode-only.
    if mode == "stealing" then
        Network.SendResearch(techID, 0, _stealingTargetID, false)
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN", techName))
        return
    end
    if mode == "free" then
        Network.SendResearch(techID, p:GetNumFreeTechs(), -1, false)
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE", techName))
        return
    end
    -- Normal mode. The queued-commit announcement does not report slot
    -- number because SendResearch is dispatched through the engine's
    -- network layer; GetQueuePosition on the very next line returns pre-
    -- commit state (unreliably). The user can Tab to the queue tab to
    -- verify placement.
    Network.SendResearch(techID, p:GetNumFreeTechs(), -1, shift)
    if shift then
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT", techName))
    else
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT", techName))
    end
end

-- ===== Search =====

local function clearSearch()
    if _search ~= nil then
        _search:clear()
    end
end

local function buildSearchable()
    return {
        itemCount = function()
            return _corpus and #_corpus or 0
        end,
        getLabel = function(i)
            local entry = _corpus and _corpus[i]
            if entry == nil then
                return nil
            end
            return entry.label
        end,
        moveTo = function(origIndex)
            local entry = _corpus and _corpus[origIndex]
            if entry == nil then
                return
            end
            TechTreeLogic.seedCursorSiblings(_cursor, entry.tech, _graph)
            _intendedGridY = entry.tech.GridY
            speakLandingNoEra(entry.tech.ID)
        end,
    }
end

-- ===== Tree nav =====
--
-- Each arrow's outer handler clears the search buffer and dispatches to
-- the per-mode implementation. Mode-specific implementations both end at
-- speakLanding, which applies the era prefix uniformly.

-- Move along one grid axis. Vertical moves reseed _intendedGridY so a
-- subsequent horizontal run snaps relative to the just-chosen row;
-- horizontal moves consult _intendedGridY without changing it. Reseeds
-- siblings on every move so a subsequent toggle into tree mode starts
-- with a fresh sibling list around the new position.
local function gridMove(axis, dir)
    local cur = _cursor and _cursor.current()
    if cur == nil then
        return
    end
    local n = TechTreeLogic.gridNeighbor(_grid, cur, axis, dir, _intendedGridY)
    if n == nil then
        return
    end
    if axis == "column" then
        _intendedGridY = n.GridY
    end
    TechTreeLogic.seedCursorSiblings(_cursor, n, _graph)
    speakLanding(n.ID)
end

-- Tree mode uses the DAG cursor with axes rotated to match the visual
-- left-to-right tech progression: Right descends to a child, Left ascends
-- to a parent, Up/Down cycle the sibling set the last vertical move
-- produced.

local function treeRight()
    local n = _cursor.navigateDown()
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function treeLeft()
    local n = _cursor.navigateUp()
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function treeUp()
    local n = _cursor.cycleSibling(1)
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function treeDown()
    local n = _cursor.cycleSibling(-1)
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function onUp()
    clearSearch()
    if _navMode == "grid" then
        gridMove("column", -1)
    else
        treeUp()
    end
end

local function onDown()
    clearSearch()
    if _navMode == "grid" then
        gridMove("column", 1)
    else
        treeDown()
    end
end

local function onLeft()
    clearSearch()
    if _navMode == "grid" then
        gridMove("row", -1)
    else
        treeLeft()
    end
end

local function onRight()
    clearSearch()
    if _navMode == "grid" then
        gridMove("row", 1)
    else
        treeRight()
    end
end

-- Toggle between grid and tree navigation. Speaks just "grid" or "tree";
-- the cursor stays put. After the swap we reseed siblings so tree mode's
-- Up/Down has a sibling list centered on the current tech (rather than
-- whichever set the cursor was carrying from the prior mode's last
-- vertical move). Help entries are swapped via tab.helpEntries mutation
-- + shell rebuildExposed so ? lists the active mode's arrow description.
local function onToggleMode()
    if _treeTab == nil then
        return
    end
    local newMode = (_navMode == "grid") and "tree" or "grid"
    _navMode = newMode
    local cur = _cursor and _cursor.current()
    if cur ~= nil then
        TechTreeLogic.seedCursorSiblings(_cursor, cur, _graph)
        _intendedGridY = cur.GridY
    end
    if newMode == "grid" then
        _treeTab.helpEntries = _gridHelpEntries
    else
        _treeTab.helpEntries = _treeHelpEntries
    end
    if _shellHandler ~= nil and type(_shellHandler.rebuildExposed) == "function" then
        _shellHandler.rebuildExposed()
    end
    SpeechPipeline.speakInterrupt(
        Text.key(
            newMode == "grid" and "TXT_KEY_CIVVACCESS_TECHTREE_MODE_GRID" or "TXT_KEY_CIVVACCESS_TECHTREE_MODE_TREE"
        )
    )
end

local function openPediaForCurrent()
    if Events == nil or Events.SearchForPediaEntry == nil then
        return
    end
    local cur = _cursor and _cursor.current()
    if cur == nil then
        return
    end
    Events.SearchForPediaEntry(Text.key(cur.Description))
end

local function closer()
    OnCloseButtonClicked()
end

local function treeHandleSearchInput(_handler, vk, mods)
    if _search == nil or _corpus == nil then
        return false
    end
    local hasCtrl = math.floor(mods / 2) % 2 == 1
    local hasAlt = math.floor(mods / 4) % 2 == 1
    if hasCtrl or hasAlt then
        return false
    end
    local s = buildSearchable()
    if vk >= 0x41 and vk <= 0x5A then
        return _search:handleChar(string.char(vk + 32), s)
    end
    if vk >= 0x30 and vk <= 0x39 then
        return _search:handleChar(string.char(vk), s)
    end
    if vk == Keys.VK_SPACE and _search:isSearchActive() then
        return _search:handleKey(Keys.VK_SPACE, false, false, s)
    end
    if vk == Keys.VK_BACK then
        return _search:handleKey(Keys.VK_BACK, false, false, s)
    end
    return false
end

-- ===== Tree tab =====

local bind = HandlerStack.bind

-- Static help entries shared by both modes (everything except the arrow
-- description). withModeNav prepends the mode-specific arrow entry to
-- this list.
local function buildBaseHelpEntries()
    return {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TOGGLE_MODE",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_PEDIA",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SEARCH",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SEARCH",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_CLOSE",
            description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE",
        },
    }
end

local function withModeNav(modeDescKey)
    local out = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV",
            description = modeDescKey,
        },
    }
    for _, e in ipairs(buildBaseHelpEntries()) do
        out[#out + 1] = e
    end
    return out
end

local function buildTreeTab()
    _gridHelpEntries = withModeNav("TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID")
    _treeHelpEntries = withModeNav("TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_TREE")
    local tab = {
        tabName = "TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE",
        bindings = {
            -- The arrow descriptions on the binding entries are
            -- informational metadata only; the ? help overlay reads
            -- helpEntries (which we swap on mode toggle) for what the
            -- user actually sees. Both descriptions point at the grid
            -- variant so a stray binding-list reader sees the default.
            bind(Keys.VK_UP, MOD_NONE, onUp, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"),
            bind(Keys.VK_DOWN, MOD_NONE, onDown, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"),
            bind(Keys.VK_LEFT, MOD_NONE, onLeft, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"),
            bind(Keys.VK_RIGHT, MOD_NONE, onRight, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV_GRID"),
            -- Space toggle. Search-active Space is consumed by
            -- handleSearchInput first (InputRouter walks search before
            -- bindings), so this only fires when the search buffer is
            -- empty -- exactly the moment a mode swap is unambiguous.
            bind(Keys.VK_SPACE, MOD_NONE, onToggleMode, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TOGGLE_MODE"),
            bind(Keys.VK_RETURN, MOD_NONE, function()
                commit(false)
            end, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"),
            bind(Keys.VK_RETURN, MOD_SHIFT, function()
                commit(true)
            end, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"),
            bind(Keys.VK_F6, MOD_NONE, closer, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"),
            bind(Keys.I, MOD_CTRL, openPediaForCurrent, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"),
        },
        helpEntries = _gridHelpEntries,
        handleSearchInput = treeHandleSearchInput,
        -- announce=false on first-open: shell already spoke displayName,
        -- queue preamble + landing under it. announce=true on Tab cycle:
        -- speakInterrupt the tab name, then queue preamble + landing so
        -- the user gets a fresh mode reminder on every cycle in.
        onTabActivated = function(self, announce)
            if announce then
                SpeechPipeline.speakInterrupt(Text.key(self.tabName))
            end
            local p = currentPlayer()
            if p == nil then
                return
            end
            local preamble = ChooseTechLogic.buildPreamble(p, currentMode(), _stealingTargetID)
            if preamble ~= "" then
                SpeechPipeline.speakQueued(preamble)
            end
            local cur = _cursor and _cursor.current()
            if cur ~= nil then
                local prefix
                prefix, _prevEraID = TechTreeLogic.eraPrefix(_prevEraID, cur.ID)
                SpeechPipeline.speakQueued(prefix .. TechTreeLogic.buildLandingSpeech(cur.ID, p))
            end
        end,
        onTabDeactivated = function()
            clearSearch()
        end,
        -- Esc with a search buffer clears it; otherwise return false so the
        -- shell falls through to the base TechTree.lua InputHandler which
        -- closes the popup.
        onEscape = function()
            if _search ~= nil and (_search:isSearchActive() or _search:hasBuffer()) then
                _search:clear()
                SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
                return true
            end
            return false
        end,
    }
    _treeTab = tab
    return tab
end

-- ===== Queue tab =====

local function buildQueueItems()
    local p = currentPlayer()
    if p == nil then
        return {
            BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY") }),
        }
    end
    local rows = TechTreeLogic.buildQueueRows(p)
    if #rows == 0 then
        return {
            BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY") }),
        }
    end
    local items = {}
    -- Row list (position values) is captured at build time, but every
    -- label re-reads the live queue position on announcement so speech
    -- reflects the current state even if the queue shifts between open
    -- and the user's first arrow move (no-cache rule).
    for _, row in ipairs(rows) do
        local r = row
        items[#items + 1] = BaseMenuItems.Text({
            labelFn = function()
                local liveP = currentPlayer()
                if liveP == nil then
                    return Text.key(r.info.Description)
                end
                local livePos = liveP:GetQueuePosition(r.techID)
                if livePos == -1 then
                    return Text.key(r.info.Description)
                end
                return TechTreeLogic.buildQueueRowSpeech(
                    { techID = r.techID, info = r.info, position = livePos },
                    liveP
                )
            end,
            pediaName = Text.key(r.info.Description),
        })
    end
    return items
end

local function buildQueueTab()
    local tab = TabbedShell.menuTab({
        tabName = "TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE",
        menuSpec = {
            displayName = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"),
            items = {
                BaseMenuItems.Text({ labelText = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_QUEUE_EMPTY") }),
            },
        },
    })
    tab.bindings[#tab.bindings + 1] = bind(Keys.VK_F6, MOD_NONE, closer, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6")
    BaseMenuHelp.addScreenKey(tab, {
        keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F6",
        description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6",
    })
    -- Rebuild items on every activate so Tab cycling into Queue reflects a
    -- post-commit Network.SendResearch that fired from the Tree tab. Wraps
    -- TabbedShell.menuTab's existing onTabActivated which handles the
    -- speakInterrupt + chained menu speech.
    local innerActivate = tab.onTabActivated
    function tab.onTabActivated(self, announce)
        tab.menu().setItems(buildQueueItems())
        innerActivate(self, announce)
    end
    return tab
end

-- ===== Lifecycle =====

local function setupForShow()
    local p = currentPlayer()
    if p == nil then
        Log.warn("TechTreeAccess: onShow without active player")
        return
    end
    _graph = TechTreeLogic.buildGraph()
    _grid = TechTreeLogic.buildGrid()
    _cursor = NavigableGraph.new({
        getParents = _graph.getParents,
        getChildren = _graph.getChildren,
        getRoots = _graph.getRoots,
    })
    _corpus = TechTreeLogic.buildSearchCorpus()
    _search = TypeAheadSearch.new()
    local landing = TechTreeLogic.pickInitialCursor(p, _graph)
    if landing == nil then
        Log.error("TechTreeAccess: pickInitialCursor returned nil")
        return
    end
    TechTreeLogic.seedCursorSiblings(_cursor, landing, _graph)
    _intendedGridY = landing.GridY
end

-- Wraps the engine's prior ShowHide so we can tear down the cursor / search
-- state on hide. install pcalls the wrapper, so any throw is logged and
-- doesn't interrupt the shell's own hide bookkeeping (handler removal,
-- tab reset).
local function wrappedPriorShowHide(bIsHide, bIsInit)
    if priorShowHide ~= nil then
        priorShowHide(bIsHide, bIsInit)
    end
    if bIsInit then
        return
    end
    if bIsHide then
        _graph = nil
        _grid = nil
        _cursor = nil
        _corpus = nil
        _search = nil
        _navMode = "grid"
        _prevEraID = nil
        _intendedGridY = nil
        _shellHandler = nil
        -- Restore the tree tab's help to the grid-mode set so the
        -- subsequent resetTabsForNextOpen-time rebuildExposed (which
        -- runs after this hook) composes shell.helpEntries with the
        -- right entries for the next open. We run before TabbedShell's
        -- own hide bookkeeping per install's priorShowHide ordering.
        if _treeTab ~= nil and _gridHelpEntries ~= nil then
            _treeTab.helpEntries = _gridHelpEntries
        end
    end
end

TabbedShell.install(ContextPtr, {
    name = "TechTreeScreen",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"),
    tabs = {
        buildTreeTab(),
        buildQueueTab(),
    },
    initialTabIndex = 1,
    priorInput = priorInput,
    priorShowHide = wrappedPriorShowHide,
    onShow = function(handler)
        _shellHandler = handler
        setupForShow()
    end,
    onEscape = function(handler)
        local tab = handler.activeTab()
        if type(tab.onEscape) ~= "function" then
            return false
        end
        local ok, consumed = pcall(tab.onEscape, tab)
        if not ok then
            Log.error("TechTreeAccess tab onEscape: " .. tostring(consumed))
            return false
        end
        return consumed == true
    end,
})

-- Mirror the stock OnDisplay's stealing-target capture into our own
-- upvalue since its local is unreachable from here. Non-TECH_TREE popups
-- do not reset the target because a chain of free-tech popups can fire
-- between tree opens; the target is meaningless outside stealing mode
-- anyway (every mode check re-reads it through TechTreeLogic.currentMode,
-- which treats >=0 as stealing only when a stealing popup or tree-with-
-- steal-data is the live context).
Log.installEvent(Events, "SerialEventGameMessagePopup", function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TECH_TREE then
        return
    end
    _stealingTargetID = popupInfo.Data2 or -1
end, "TechTreeAccess")

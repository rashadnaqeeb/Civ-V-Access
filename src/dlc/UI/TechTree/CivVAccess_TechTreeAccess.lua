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
--           it. When the search overlay seats the cursor on a match (on
--           dismiss), _prevEraID is updated silently with no era prefix,
--           so the next arrow move compares against the seated era rather
--           than announcing a boundary against the pre-search position.
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
-- Search: letters / digits / Space / Backspace on either nav mode feed a
-- TypeAheadSearch whose corpus is "name, unlocks prose" per tech. The first
-- matching keystroke pushes a results overlay (a BaseMenu, capturesAllInput)
-- listing every match in ranked order with the cursor on the top match;
-- each further keystroke refilters the list in place and relands on the new
-- top match. Up/Down/Home/End walk the results, Enter researches the focused
-- match and Shift+Enter queues it (the same commit path the tree tabs use),
-- Ctrl+I opens its pedia entry. Backspace past the last character, or Esc,
-- dismisses the overlay: the tree cursor is seated on the focused match (so
-- the user is left where they were browsing) and "search cleared" is spoken.
-- Each result row speaks the same landing speech an arrow move produces,
-- minus the era prefix, so browsing the overlay sounds like browsing the
-- tree. Arrow keys on the tree tab clear any leftover no-match buffer before
-- tree nav so a non-matching prefix never contaminates a later arrow move.
--
-- F1: TabbedShell owns F1 and reads "Tech Tree" + active tab name. The
-- mode preamble (free-tech / stealing) is reachable via Tab cycle into
-- the tree tab, whose onTabActivated re-speaks it.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
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
include("CivVAccess_Verbosity")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_TabbedShell")
include("CivVAccess_Help")
include("CivVAccess_VolumeControl")
include("CivVAccess_BeaconRange")
include("CivVAccess_BeaconVolume")
include("CivVAccess_Settings")
include("CivVAccess_NavigableGraph")
include("CivVAccess_ChooseTechLogic")
include("CivVAccess_TechTreeLogic")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_ALT = 4

local bind = HandlerStack.bind

-- Stack name of the type-ahead results overlay pushed over the tree tab.
local SEARCH_MENU_NAME = "TechSearchResults"

-- Populated on BUTTONPOPUP_TECH_TREE fires; stable across Show/Hide for a
-- given open and re-written on the next open.
local _stealingTargetID = -1

-- Espionage diplomat read-only view (VP-only). The diplomat panel fires
-- BUTTONPOPUP_TECH_TREE with Data4>0 and Data5=the rival player, repointing the
-- tree to that civ's research state (the sighted view does the same, then
-- disables clicking). Captured by the popup listener; while set, reads use the
-- rival and commit is suppressed. Reset on every TECH_TREE open.
local _espionageView = false
local _viewPlayerID = -1

-- Alt+Up/Down section-review holder for the tree/grid tab. speakLanding
-- refreshes _sections on every cursor move; the chord bindings walk them
-- through the shared navigator. A plain table (not reset on hide) since
-- every landing overwrites it.
local _review = {}

-- Screen state. Reset on every hide.
local _graph = nil
local _cursor = nil
local _corpus = nil
local _search = nil
-- Live results-overlay handler while type-ahead is open; nil otherwise.
-- Cleared by the overlay's own onDeactivate and on screen hide.
local _searchMenu = nil
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
    if _espionageView and _viewPlayerID >= 0 then
        return Players[_viewPlayerID]
    end
    return Players[Game.GetActivePlayer()]
end

local function currentMode()
    -- The spy view is read-only; force normal so the preamble never claims the
    -- rival's free-tech / stealing state (which would read off currentPlayer).
    if _espionageView then
        return "normal"
    end
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
    -- Refresh the Alt+Up/Down review sections for the tech just landed on.
    BaseMenuItems.SectionReview.set(_review, TechTreeLogic.buildLandingSections(techID, p))
end

-- ===== Tree commit =====

local function commit(shift)
    if _espionageView then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_FOREIGN_VIEW_READONLY"))
        return
    end
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
--
-- Typing on either nav mode opens a results overlay (a pushed BaseMenu)
-- rather than moving the tree cursor directly; the overlay owns browsing
-- and commit, and seats the cursor on the focused match when it closes.
-- The menu-building helpers live further down (after `closer`) because
-- they push HandlerStack bindings; this is just the buffer-clear primitive
-- the tree-tab arrow handlers call.

local function clearSearch()
    if _search ~= nil then
        _search:clear()
    end
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
    -- Community Patch's TechTree names the close handler Close; vanilla
    -- names it OnCloseButtonClicked.
    local close = OnCloseButtonClicked or Close
    close()
end

-- Seat the tree cursor on `tech` without speaking. Matches the bookkeeping
-- an arrow landing does (sibling reseed + grid anchor) plus a silent
-- _prevEraID update, so the next arrow move measures era boundaries from
-- here instead of announcing one against the pre-search position.
local function seatCursorSilent(tech)
    TechTreeLogic.seedCursorSiblings(_cursor, tech, _graph)
    _intendedGridY = tech.GridY
    _prevEraID = TechTreeLogic.eraID(tech.ID) or _prevEraID
end

-- Searchable view of the corpus with a no-op moveTo: the search ranks the
-- matches but never moves the cursor or speaks (the overlay owns
-- presentation). buildSearchResultItems reads the result order back.
local function buildMenuSearchable()
    return {
        itemCount = function()
            return _corpus and #_corpus or 0
        end,
        getLabel = function(i)
            local entry = _corpus and _corpus[i]
            return entry and entry.label or nil
        end,
        moveTo = function() end,
    }
end

-- Feed one key to the shared search. Returns (consumed, handled); handled
-- is false when vk is not a search key, so the caller leaves it for the
-- binding walk. Shared by the tree-tab opener and the overlay refiner.
local function feedSearchKey(vk)
    local s = buildMenuSearchable()
    if vk >= 0x41 and vk <= 0x5A then
        return _search:handleChar(string.char(vk + 32), s), true
    elseif vk >= 0x30 and vk <= 0x39 then
        return _search:handleChar(string.char(vk), s), true
    elseif vk == Keys.VK_SPACE and _search:isSearchActive() then
        return _search:handleKey(Keys.VK_SPACE, false, false, s), true
    elseif vk == Keys.VK_BACK then
        return _search:handleKey(Keys.VK_BACK, false, false, s), true
    end
    return false, false
end

-- One Choice per current search result, in ranked order. The label is the
-- live landing speech (re-read on every announce, no cache); the row
-- carries its tech so dismiss can seat the cursor and Shift+Enter can queue
-- it. The Choice's own activate (Enter) seats the cursor and runs the
-- normal research commit, then drops the overlay -- acting exactly as if
-- the tree cursor had been parked on the tech and Enter pressed there.
local function buildSearchResultItems()
    local items = {}
    for _, origIndex in ipairs(_search:resultOriginalIndices()) do
        local entry = _corpus[origIndex]
        if entry ~= nil then
            local tech = entry.tech
            local it = BaseMenuItems.Choice({
                labelFn = function()
                    local p = currentPlayer()
                    if p == nil then
                        return Text.key(tech.Description)
                    end
                    return TechTreeLogic.buildLandingSpeech(tech.ID, p)
                end,
                pediaName = Text.key(tech.Description),
                activate = function()
                    seatCursorSilent(tech)
                    commit(false)
                    HandlerStack.removeByName(SEARCH_MENU_NAME, false)
                end,
            })
            it._techRow = tech
            items[#items + 1] = it
        end
    end
    return items
end

-- Esc / backspace-past-the-last-character. Seat the cursor on the focused
-- match (leaving the user where they were browsing), drop the overlay, and
-- speak the standard "search cleared". The overlay's onDeactivate clears
-- the search buffer.
local function dismissSearchMenu()
    if _searchMenu ~= nil then
        local it = _searchMenu.currentItem()
        if it ~= nil and it._techRow ~= nil then
            seatCursorSilent(it._techRow)
        end
    end
    HandlerStack.removeByName(SEARCH_MENU_NAME, false)
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
end

-- Keystroke handler installed on the overlay, replacing BaseMenu's built-in
-- type-ahead so refining feeds the tech search rather than searching within
-- the result rows. Backspace that would empty the buffer dismisses; other
-- search keys refilter and reland on the new top match. A no-match
-- keystroke leaves the prior rows standing (the search speaks "no match")
-- so the focused row stays valid for Enter / dismiss.
local function searchMenuHandleInput(_handler, vk, mods)
    if _search == nil or _corpus == nil then
        return false
    end
    local hasCtrl = math.floor(mods / 2) % 2 == 1
    local hasAlt = math.floor(mods / 4) % 2 == 1
    if hasCtrl or hasAlt then
        return false
    end
    if vk == Keys.VK_BACK and #_search:buffer() <= 1 then
        dismissSearchMenu()
        return true
    end
    local consumed, handled = feedSearchKey(vk)
    if not handled then
        return false
    end
    if _searchMenu ~= nil and _search:resultCount() > 0 then
        _searchMenu.setItems(buildSearchResultItems())
        _searchMenu.announceCurrent()
    end
    return consumed
end

-- Push the results overlay positioned on the top match. Called from the
-- tree-tab search hook on the first matching keystroke. capturesAllInput
-- defaults true, so arrows / Tab route to the overlay until it is dismissed.
--
-- Opening speaks only the focused result, like landing on it in the tree --
-- no overlay-name announcement, which no other type-ahead surface does.
-- silentDisplayName drops the title from the auto-open speech (F1 still
-- reads it); silentFirstOpen suppresses onActivate's own first-item speech
-- so the explicit announceCurrent below speaks the landing on interrupt
-- (matching the refine path) rather than onActivate's queued form.
local function openSearchMenu()
    HandlerStack.removeByName(SEARCH_MENU_NAME, false)
    local menu = BaseMenu.create({
        name = SEARCH_MENU_NAME,
        displayName = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_SEARCH_RESULTS"),
        items = buildSearchResultItems(),
        silentDisplayName = true,
        silentFirstOpen = true,
        helpExtras = {
            {
                keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_ENTER",
                description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER",
            },
            {
                keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_SHIFT_ENTER",
                description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER",
            },
        },
    })
    menu.handleSearchInput = searchMenuHandleInput
    menu.onDeactivate = function()
        _searchMenu = nil
        clearSearch()
    end
    menu.bindings[#menu.bindings + 1] = bind(Keys.VK_RETURN, MOD_SHIFT, function()
        local it = menu.currentItem()
        if it == nil or it._techRow == nil then
            return
        end
        seatCursorSilent(it._techRow)
        commit(true)
        HandlerStack.removeByName(SEARCH_MENU_NAME, false)
    end, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER")
    menu.bindings[#menu.bindings + 1] =
        bind(Keys.VK_ESCAPE, MOD_NONE, dismissSearchMenu, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE")
    menu.bindings[#menu.bindings + 1] = bind(Keys.VK_F6, MOD_NONE, closer, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6")
    _searchMenu = menu
    HandlerStack.push(menu)
    -- onActivate ran silent (silentFirstOpen); speak the focused result now,
    -- on interrupt, so opening sounds exactly like landing on it.
    menu.announceCurrent()
end

-- Tree-tab type-ahead hook. Feeds the keystroke to the shared search; the
-- first keystroke that yields a match opens the overlay, which then owns
-- refinement and commit. A non-matching prefix accumulates on the tree tab
-- (the search speaks "no match"); the arrow handlers clear it before nav.
local function treeHandleSearchInput(_handler, vk, mods)
    if _search == nil or _corpus == nil then
        return false
    end
    local hasCtrl = math.floor(mods / 2) % 2 == 1
    local hasAlt = math.floor(mods / 4) % 2 == 1
    if hasCtrl or hasAlt then
        return false
    end
    local consumed, handled = feedSearchKey(vk)
    if not handled then
        return false
    end
    if _search:resultCount() > 0 then
        openSearchMenu()
    end
    return consumed
end

-- ===== Tree tab =====

-- Static help entries shared by both modes (everything except the arrow
-- description). withModeNav prepends the mode-specific arrow entry to
-- this list.
local function buildBaseHelpEntries()
    return {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_ALT_UP_DOWN",
            description = "TXT_KEY_CIVVACCESS_HELP_DESC_REVIEW_SECTIONS",
        },
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
            bind(Keys.VK_DOWN, MOD_ALT, function()
                BaseMenuItems.SectionReview.next(_review)
            end, "TXT_KEY_CIVVACCESS_HELP_DESC_REVIEW_SECTIONS"),
            bind(Keys.VK_UP, MOD_ALT, function()
                BaseMenuItems.SectionReview.prev(_review)
            end, "TXT_KEY_CIVVACCESS_HELP_DESC_REVIEW_SECTIONS"),
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
                -- Seat the Alt+Up/Down review sections on first open and tab
                -- re-entry too, not only on arrow moves -- otherwise the chord
                -- is silent until the cursor first moves.
                BaseMenuItems.SectionReview.set(_review, TechTreeLogic.buildLandingSections(cur.ID, p))
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
        -- Drop the results overlay if the screen closes while it is open
        -- (F6 from within it, an engine-driven close, load-from-game). Its
        -- onDeactivate clears the search; reactivate=false so the shell
        -- underneath doesn't re-announce mid-teardown.
        HandlerStack.removeByName(SEARCH_MENU_NAME, false)
        _searchMenu = nil
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
        -- Title carries the rival's civ name in the spy view; reset otherwise
        -- (the field persists across opens).
        if _espionageView and _viewPlayerID >= 0 then
            handler.displayName = Text.format(
                "TXT_KEY_CIVVACCESS_TECHTREE_FOREIGN_TITLE",
                Text.key(Players[_viewPlayerID]:GetCivilizationShortDescription())
            )
        else
            handler.displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE")
        end
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
    -- VP espionage diplomat view: Data4>0 repoints the tree to the rival in
    -- Data5. Mutually exclusive with stealing (the diplomat launch sets
    -- Data2=-1). Reset on every open; Data4 is nil on vanilla.
    if popupInfo.Data4 ~= nil and popupInfo.Data4 > 0 then
        _espionageView = true
        _viewPlayerID = popupInfo.Data5
    else
        _espionageView = false
        _viewPlayerID = -1
    end
end, "TechTreeAccess")

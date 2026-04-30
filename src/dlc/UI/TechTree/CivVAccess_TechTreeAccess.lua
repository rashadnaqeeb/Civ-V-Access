-- Tech Tree screen accessibility. Wraps the in-game TechTree Context
-- (BUTTONPOPUP_TECH_TREE) as a TabbedShell with two tabs:
--
--   Tree    hand-rolled tab object; arrow-key DAG cursor (Up/Down for
--           parent/child, Left/Right for siblings), Enter / Shift+Enter
--           commits via Network.SendResearch, type-ahead search across
--           tech name + unlocks prose. NavigableGraph owns the pure DAG
--           cursor; tech-specific adjacency lambdas, label composition,
--           and commit eligibility live in CivVAccess_TechTreeLogic so
--           offline tests can exercise them without dofiling this wrapper.
--   Queue   TabbedShell.menuTab over a BaseMenu list. Items are rebuilt
--           on every onTabActivated so the queue reflects post-commit
--           state when the user Tabs over after queuing a tech.
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

local function speakLanding(techID)
    local p = currentPlayer()
    if p == nil then
        return
    end
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
            local p = currentPlayer()
            if p == nil then
                return
            end
            SpeechPipeline.speakInterrupt(TechTreeLogic.buildLandingSpeech(entry.tech.ID, p))
        end,
    }
end

-- ===== Tree nav =====

local function onUp()
    clearSearch()
    local n = _cursor.navigateUp()
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function onDown()
    clearSearch()
    local n = _cursor.navigateDown()
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function onLeft()
    clearSearch()
    local n = _cursor.cycleSibling(-1)
    if n == nil then
        return
    end
    speakLanding(n.ID)
end

local function onRight()
    clearSearch()
    local n = _cursor.cycleSibling(1)
    if n == nil then
        return
    end
    speakLanding(n.ID)
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

local function buildTreeTab()
    return {
        tabName = "TXT_KEY_CIVVACCESS_TECHTREE_TAB_TREE",
        bindings = {
            bind(Keys.VK_UP, MOD_NONE, onUp, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV"),
            bind(Keys.VK_DOWN, MOD_NONE, onDown, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV"),
            bind(Keys.VK_LEFT, MOD_NONE, onLeft, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV"),
            bind(Keys.VK_RIGHT, MOD_NONE, onRight, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV"),
            bind(Keys.VK_RETURN, MOD_NONE, function()
                commit(false)
            end, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_ENTER"),
            bind(Keys.VK_RETURN, MOD_SHIFT, function()
                commit(true)
            end, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_SHIFT_ENTER"),
            bind(Keys.VK_F6, MOD_NONE, closer, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"),
            bind(Keys.I, MOD_CTRL, openPediaForCurrent, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_PEDIA"),
        },
        helpEntries = {
            {
                keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_NAV",
                description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_NAV",
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
        },
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
                SpeechPipeline.speakQueued(TechTreeLogic.buildLandingSpeech(cur.ID, p))
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
        _cursor = nil
        _corpus = nil
        _search = nil
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
    onShow = function()
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
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TECH_TREE then
        return
    end
    _stealingTargetID = popupInfo.Data2 or -1
end)

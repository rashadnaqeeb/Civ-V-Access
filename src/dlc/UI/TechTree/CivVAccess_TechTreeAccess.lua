-- Tech Tree screen accessibility. Wraps the in-game TechTree Context
-- (BUTTONPOPUP_TECH_TREE) as a two-tab screen: tree (DAG cursor; Up/Down
-- parent/child, Left/Right siblings) and queue (flat read-only list).
-- Tree tab is a hand-rolled HandlerStack entry because its arrow-key
-- semantics collide with BaseMenu's; the queue tab is a fresh BaseMenu
-- handler pushed above the tree on Tab, popped on Tab again.
--
-- NavigableGraph owns the pure DAG cursor so the same module will back
-- a later social-policy screen. Tech-specific adjacency lambdas, label
-- composition, and commit eligibility live in CivVAccess_TechTreeLogic
-- so offline tests can exercise them without dofiling this wrapper.
--
-- Commit: Network.SendResearch(techID, numFreeTechs, stealingTargetID,
-- shift). Normal / free modes pass GetNumFreeTechs; stealing passes 0
-- with the target ID. Shift+Enter in normal mode queue-appends; the
-- confirmation speech just says "queued <name>" because SendResearch
-- is network-dispatched and GetQueuePosition on the next line reads
-- pre-commit state. The user can Tab to the queue tab to hear the
-- actual slot ordering. Free / stealing modes ignore Shift — they
-- commit once and the engine chains subsequent popups as needed.
--
-- Stealing target: stock TechTree.lua captures popupInfo.Data2 into a
-- chunk-local (unreachable from our appended include). We register our
-- own SerialEventGameMessagePopup listener that mirrors the capture into
-- a module upvalue. UIManager:QueuePopup defers ContextPtr show to the
-- next frame, so both listeners run in the same frame before ShowHide
-- fires and the upvalue is current by the time onActivate reads it.
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
-- and speaks "search cleared"; Esc with no buffer closes the screen.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
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
include("CivVAccess_Help")
include("CivVAccess_NavigableGraph")
include("CivVAccess_ChooseTechLogic")
include("CivVAccess_TechTreeLogic")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local TREE_HANDLER = "TechTreeScreen"
local QUEUE_HANDLER = "TechTreeQueue"

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

local function speakHeader()
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"))
    local p = currentPlayer()
    if p == nil then
        return
    end
    local preamble = ChooseTechLogic.buildPreamble(p, currentMode(), _stealingTargetID)
    if preamble ~= "" then
        SpeechPipeline.speakQueued(preamble)
    end
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
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_STOLEN", techName)
        )
        return
    end
    if mode == "free" then
        Network.SendResearch(techID, p:GetNumFreeTechs(), -1, false)
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT_FREE", techName)
        )
        return
    end
    -- Normal mode. The queued-commit announcement does not report slot
    -- number because SendResearch is dispatched through the engine's
    -- network layer; GetQueuePosition on the very next line returns pre-
    -- commit state (unreliably). The user can Tab to the queue tab to
    -- verify placement.
    Network.SendResearch(techID, p:GetNumFreeTechs(), -1, shift)
    if shift then
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_TECHTREE_QUEUED_COMMIT", techName)
        )
    else
        SpeechPipeline.speakInterrupt(
            Text.format("TXT_KEY_CIVVACCESS_CHOOSETECH_COMMIT", techName)
        )
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

-- ===== Queue tab (BaseMenu subhandler pushed on Tab) =====

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

local function openQueueTab()
    local queueHandler = BaseMenu.create({
        name = QUEUE_HANDLER,
        displayName = Text.key("TXT_KEY_CIVVACCESS_TECHTREE_TAB_QUEUE"),
        items = buildQueueItems(),
    })
    -- BaseMenu.create wires its own Tab / Shift+Tab that cycle spec.tabs;
    -- our handler has no tabs, so those bindings would be live no-ops and
    -- could shadow our Tab-to-tree binding if order changed. Strip and
    -- replace with explicit ones that pop this handler off the stack.
    for i = #queueHandler.bindings, 1, -1 do
        if queueHandler.bindings[i].key == Keys.VK_TAB then
            table.remove(queueHandler.bindings, i)
        end
    end
    local backToTree = function()
        HandlerStack.removeByName(QUEUE_HANDLER, true)
    end
    table.insert(queueHandler.bindings, {
        key = Keys.VK_TAB,
        mods = MOD_NONE,
        description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TAB",
        fn = backToTree,
    })
    table.insert(queueHandler.bindings, {
        key = Keys.VK_TAB,
        mods = MOD_SHIFT,
        description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TAB",
        fn = backToTree,
    })
    local closer = function()
        OnCloseButtonClicked()
    end
    table.insert(queueHandler.bindings, {
        key = Keys.VK_ESCAPE,
        mods = MOD_NONE,
        description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE",
        fn = closer,
    })
    table.insert(queueHandler.bindings, {
        key = Keys.VK_F6,
        mods = MOD_NONE,
        description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6",
        fn = closer,
    })
    HandlerStack.push(queueHandler)
end

-- ===== Tree handler =====

local bind = HandlerStack.bind

local function handleSearchInput(_handler, vk, mods)
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

local function createTreeHandler()
    local closer = function()
        OnCloseButtonClicked()
    end
    local onEscape = function()
        if _search ~= nil and (_search:isSearchActive() or _search:hasBuffer()) then
            _search:clear()
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
            return
        end
        closer()
    end
    local handler = {
        name = TREE_HANDLER,
        capturesAllInput = true,
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
            bind(Keys.VK_TAB, MOD_NONE, openQueueTab, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TAB"),
            bind(Keys.VK_TAB, MOD_SHIFT, openQueueTab, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TAB"),
            bind(Keys.VK_F1, MOD_NONE, speakHeader, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F1"),
            bind(Keys.VK_F6, MOD_NONE, closer, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F6"),
            bind(Keys.VK_ESCAPE, MOD_NONE, onEscape, "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_CLOSE"),
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
                keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_TAB",
                description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_TAB",
            },
            {
                keyLabel = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_KEY_F1",
                description = "TXT_KEY_CIVVACCESS_TECHTREE_HELP_DESC_F1",
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
        _initialized = false,
        handleSearchInput = handleSearchInput,
    }
    -- onActivate distinguishes first-open from re-exposure (queue tab pop)
    -- so the header + preamble are spoken exactly once per screen session
    -- while cursor re-announces are free to fire on every resurfacing.
    handler.onActivate = function(self)
        local p = currentPlayer()
        local cur = _cursor and _cursor.current()
        if not self._initialized then
            self._initialized = true
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_SCREEN_TECH_TREE"))
            if p ~= nil then
                local preamble = ChooseTechLogic.buildPreamble(p, currentMode(), _stealingTargetID)
                if preamble ~= "" then
                    SpeechPipeline.speakQueued(preamble)
                end
            end
            if cur ~= nil and p ~= nil then
                SpeechPipeline.speakQueued(TechTreeLogic.buildLandingSpeech(cur.ID, p))
            end
            return
        end
        if cur ~= nil and p ~= nil then
            SpeechPipeline.speakInterrupt(TechTreeLogic.buildLandingSpeech(cur.ID, p))
        end
    end
    return handler
end

-- ===== Lifecycle =====

local function onShow()
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
    HandlerStack.removeByName(TREE_HANDLER, false)
    HandlerStack.push(createTreeHandler())
end

local function onHide()
    -- QUEUE removal with reactivate=false because we're about to remove
    -- the tree handler on the next line: reactivating TREE for a single
    -- frame would speak a landing the user is leaving behind. TREE
    -- removal with reactivate=true so whichever handler sits underneath
    -- (Scanner in the usual case) re-announces itself and the user
    -- hears which mode they landed back in.
    HandlerStack.removeByName(QUEUE_HANDLER, false)
    HandlerStack.removeByName(TREE_HANDLER, true)
    _graph = nil
    _cursor = nil
    _corpus = nil
    _search = nil
end

ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit)
    if priorShowHide ~= nil then
        local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
        if not ok then
            Log.error("TechTreeAccess prior ShowHide: " .. tostring(err))
        end
    end
    if bIsHide then
        onHide()
    else
        onShow()
    end
end)

ContextPtr:SetInputHandler(function(msg, wp, lp)
    local mods = InputRouter.currentModifierMask()
    if InputRouter.dispatch(wp, mods, msg) then
        return true
    end
    if priorInput ~= nil then
        return priorInput(msg, wp, lp)
    end
    return false
end)

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

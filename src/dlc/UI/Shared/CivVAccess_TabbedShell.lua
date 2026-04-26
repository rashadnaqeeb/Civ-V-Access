-- TabbedShell hosts an array of tab objects under one HandlerStack handler.
-- Tab/Shift+Tab cycling is owned by the shell; only the shell pushes onto
-- HandlerStack. Each tab is a normal handler-shaped object plus implements
-- onTabActivated(announce) and onTabDeactivated() for lifecycle speech. Tabs
-- can be backed by anything: BaseMenu (via TabbedShell.menuTab), BaseTable,
-- or a hand-rolled handler with its own cursor (e.g., the tech-tree DAG, when
-- F6 is retrofitted).
--
-- Tab object contract:
--   tabName        TXT_KEY string spoken on Tab/Shift+Tab cycle (announce=true).
--   bindings       array of {key, mods, fn, description}, composed into the
--                  shell's bindings on activation. Tab/Shift+Tab/Esc are
--                  filtered out -- the shell owns those chords.
--   helpEntries    array of {keyLabel, description}, composed after the
--                  shell's own help entries.
--   onTabActivated(announce)
--                  announce=false on first-open: the shell already
--                  speakInterrupted displayName; the tab speakQueueds its
--                  opening content. announce=true on Tab cycle and on
--                  shell re-activation after a sub pop: the tab
--                  speakInterrupts its tabName then speakQueueds content.
--   onTabDeactivated()
--                  optional cleanup; called before each tab change and on
--                  shell hide.
--   handleSearchInput(self, vk, mods)
--                  optional; the shell's handleSearchInput delegates to the
--                  active tab so type-ahead routes to whatever is focused.
--
-- BaseMenu compatibility: TabbedShell.menuTab wraps BaseMenu.create with
-- silentDisplayName=true (shell speaks tabName instead) and toggles the
-- BaseMenu instance's _chainSpeech flag during onTabActivated so its
-- re-activation speech speakQueueds rather than speakInterrupts.
--
-- Spec for TabbedShell.create:
--   name              (string, required) HandlerStack identity.
--   displayName       (string, required) screen header spoken on first open.
--   tabs              (array, required) tab objects implementing the contract
--                     above. Must have at least one entry.
--   initialTabIndex   (number, optional, 1-based, default 1) first-open
--                     landing tab.
--   capturesAllInput  (bool, default true) modal barrier for InputRouter.
--   onEscape          (fn(self) -> bool, optional) consulted by install's Esc
--                     handler before priorInput. Return true to consume.
--
-- TabbedShell.install wraps a Context's existing ShowHide / Input handlers
-- the same way BaseMenu.install does: pushes the shell on show, pops on
-- hide, dispatches via InputRouter, falls through to priorInput on
-- unbound Esc.

TabbedShell = {}

local MOD_SHIFT = 1

local function check(cond, msg)
    if not cond then
        Log.error(msg)
        error(msg, 2)
    end
end

-- Strip Tab / Shift+Tab / Esc from a tab handler's bindings so the shell's
-- own bindings (which compose in front) win those chords. Keep every other
-- tab-bound chord intact.
local function filterTabBindings(bindings)
    if type(bindings) ~= "table" then
        return {}
    end
    local out = {}
    for _, b in ipairs(bindings) do
        local mods = b.mods or 0
        local strip = false
        if b.key == Keys.VK_TAB and (mods == 0 or mods == MOD_SHIFT) then
            strip = true
        elseif b.key == Keys.VK_ESCAPE and mods == 0 then
            strip = true
        end
        if not strip then
            out[#out + 1] = b
        end
    end
    return out
end

-- Validate a tab object passed in spec.tabs. Each tab is a free-form table
-- so we only require what the shell actually consumes; missing-but-optional
-- fields (helpEntries, onTabDeactivated, handleSearchInput) are tolerated.
local function checkTab(tab, i)
    check(type(tab) == "table", "tabs[" .. i .. "] must be a table")
    check(type(tab.tabName) == "string" and tab.tabName ~= "", "tabs[" .. i .. "].tabName required")
    check(type(tab.onTabActivated) == "function", "tabs[" .. i .. "].onTabActivated required")
    check(
        tab.bindings == nil or type(tab.bindings) == "table",
        "tabs[" .. i .. "].bindings must be a table if provided"
    )
    check(
        tab.helpEntries == nil or type(tab.helpEntries) == "table",
        "tabs[" .. i .. "].helpEntries must be a table if provided"
    )
    check(
        tab.onTabDeactivated == nil or type(tab.onTabDeactivated) == "function",
        "tabs[" .. i .. "].onTabDeactivated must be a function if provided"
    )
    check(
        tab.handleSearchInput == nil or type(tab.handleSearchInput) == "function",
        "tabs[" .. i .. "].handleSearchInput must be a function if provided"
    )
end

-- Compose shell-level bindings + active tab's bindings (with Tab/Esc
-- stripped). Shell entries come first so a chord defined at both levels
-- resolves to the shell's binding (relevant for Tab/Shift+Tab/F1, which
-- the shell always owns even if a tab erroneously declared them).
local function composeBindings(self)
    local out = {}
    for _, b in ipairs(self._shellBindings) do
        out[#out + 1] = b
    end
    local tab = self._tabs[self._activeIdx]
    for _, b in ipairs(filterTabBindings(tab.bindings or {})) do
        out[#out + 1] = b
    end
    return out
end

-- Shell-level help + active tab's help. ? help dedupes by keyLabel string,
-- so duplicate "Esc" entries from a tab's authored list won't double up.
local function composeHelpEntries(self)
    local out = {}
    for _, e in ipairs(self._shellHelpEntries) do
        out[#out + 1] = e
    end
    local tab = self._tabs[self._activeIdx]
    if type(tab.helpEntries) == "table" then
        for _, e in ipairs(tab.helpEntries) do
            out[#out + 1] = e
        end
    end
    return out
end

local function rebuildExposed(self)
    self.bindings = composeBindings(self)
    self.helpEntries = composeHelpEntries(self)
end

-- Resolve the spoken tab name. tabName is a TXT_KEY; the shell unconditionally
-- runs it through Text.key so call sites can treat it like any other authored
-- string. Returns the localized text.
local function resolveTabName(tab)
    return Text.key(tab.tabName)
end

local function deactivateTab(tab)
    if type(tab.onTabDeactivated) == "function" then
        local ok, err = pcall(tab.onTabDeactivated, tab)
        if not ok then
            Log.error("TabbedShell deactivate '" .. tostring(tab.tabName) .. "': " .. tostring(err))
        end
    end
end

local function activateTab(tab, announce)
    local ok, err = pcall(tab.onTabActivated, tab, announce)
    if not ok then
        Log.error("TabbedShell activate '" .. tostring(tab.tabName) .. "': " .. tostring(err))
    end
end

-- Switch to a new tab index (forward or backward through the array, with
-- wrap). Same-index calls are no-ops because cycling onto the active tab
-- is meaningless and would re-fire onActivate spuriously.
local function cycleTab(self, direction)
    local n = #self._tabs
    if n <= 1 then
        return
    end
    local newIdx = self._activeIdx + direction
    if newIdx < 1 then
        newIdx = n
    end
    if newIdx > n then
        newIdx = 1
    end
    if newIdx == self._activeIdx then
        return
    end
    deactivateTab(self._tabs[self._activeIdx])
    self._activeIdx = newIdx
    rebuildExposed(self)
    activateTab(self._tabs[self._activeIdx], true)
end

-- F1 re-reads displayName then the active tab's name. The tab itself
-- doesn't expose a re-read hook, so we don't dive deeper -- if the tab
-- has its own header (BaseMenu's preamble, BaseTable's column header),
-- F1 inside the tab could chain through onTabActivated(true), but we
-- start with the simpler "screen-name + tab-name" since that's the
-- minimum users need to re-orient.
local function readShellHeader(self)
    SpeechPipeline.speakInterrupt(self.displayName)
    local tab = self._tabs[self._activeIdx]
    if tab ~= nil then
        SpeechPipeline.speakQueued(resolveTabName(tab))
    end
end

local function buildShellBindings(self)
    return {
        {
            key = Keys.VK_TAB,
            mods = 0,
            description = "Next tab",
            fn = function()
                cycleTab(self, 1)
            end,
        },
        {
            key = Keys.VK_TAB,
            mods = MOD_SHIFT,
            description = "Previous tab",
            fn = function()
                cycleTab(self, -1)
            end,
        },
        {
            key = Keys.VK_F1,
            mods = 0,
            description = "Read shell header",
            fn = function()
                readShellHeader(self)
            end,
        },
    }
end

-- Reuses the BaseMenu help-entry templates so the ? overlay reads
-- consistently with every other tabbed screen in the mod.
local function buildShellHelpEntries()
    return {
        { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_TAB", description = "TXT_KEY_CIVVACCESS_HELP_DESC_NEXT_TAB" },
        { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_SHIFT_TAB", description = "TXT_KEY_CIVVACCESS_HELP_DESC_PREV_TAB" },
        { keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F1", description = "TXT_KEY_CIVVACCESS_HELP_DESC_READ_HEADER" },
    }
end

function TabbedShell.create(spec)
    check(type(spec) == "table", "TabbedShell.create requires a spec table")
    check(type(spec.name) == "string" and spec.name ~= "", "spec.name required")
    check(type(spec.displayName) == "string" and spec.displayName ~= "", "spec.displayName required")
    check(type(spec.tabs) == "table" and #spec.tabs >= 1, "spec.tabs must be a non-empty array")
    for i, tab in ipairs(spec.tabs) do
        checkTab(tab, i)
    end
    check(
        spec.initialTabIndex == nil
            or (
                type(spec.initialTabIndex) == "number"
                and spec.initialTabIndex >= 1
                and spec.initialTabIndex <= #spec.tabs
            ),
        "spec.initialTabIndex must be a positive number within tabs range if provided"
    )
    check(spec.onEscape == nil or type(spec.onEscape) == "function", "spec.onEscape must be a function if provided")

    local self = {
        name = spec.name,
        displayName = spec.displayName,
        capturesAllInput = spec.capturesAllInput ~= false,
        _tabs = spec.tabs,
        _activeIdx = spec.initialTabIndex or 1,
        _onEscape = spec.onEscape,
        _initialized = false,
    }

    self._shellBindings = buildShellBindings(self)
    self._shellHelpEntries = buildShellHelpEntries()
    rebuildExposed(self)

    function self.onActivate()
        if not self._initialized then
            self._initialized = true
            SpeechPipeline.speakInterrupt(self.displayName)
            -- Initial tab: shell already spoke screen name. Tab speakQueueds
            -- content so it chains. announce=false suppresses the tab's
            -- tabName speech (the user already heard the screen name; they
            -- don't need a second header line on first open).
            activateTab(self._tabs[self._activeIdx], false)
            return
        end
        -- Re-activation (sub pop). Re-announce active tab so user hears
        -- where they landed back on. announce=true so the tab speaks its
        -- tabName interrupt + content queued.
        activateTab(self._tabs[self._activeIdx], true)
    end

    function self.onDeactivate()
        deactivateTab(self._tabs[self._activeIdx])
    end

    -- Type-ahead pass-through. InputRouter calls top.handleSearchInput
    -- before the binding walk; the shell delegates to whichever tab is
    -- active so BaseMenu / BaseTable type-ahead routes correctly.
    function self.handleSearchInput(_me, vk, mods)
        local tab = self._tabs[self._activeIdx]
        if type(tab.handleSearchInput) ~= "function" then
            return false
        end
        local ok, consumed = pcall(tab.handleSearchInput, tab, vk, mods)
        if not ok then
            Log.error("TabbedShell handleSearchInput in '" .. tostring(tab.tabName) .. "': " .. tostring(consumed))
            return false
        end
        return consumed == true
    end

    -- Programmatic tab jump. Used by F2 wrapper to land on a non-default
    -- initial tab when popup data hints which tab to open. Same-index
    -- calls are coalesced (cycleTab no-ops on same idx).
    function self.switchToTab(idx)
        if type(idx) ~= "number" or idx < 1 or idx > #self._tabs then
            return
        end
        if idx == self._activeIdx then
            return
        end
        deactivateTab(self._tabs[self._activeIdx])
        self._activeIdx = idx
        rebuildExposed(self)
        activateTab(self._tabs[self._activeIdx], true)
    end

    function self.activeTabIndex()
        return self._activeIdx
    end

    function self.activeTab()
        return self._tabs[self._activeIdx]
    end

    return self
end

-- Build a tab object backed by a BaseMenu list. Sets silentDisplayName so
-- BaseMenu doesn't speak its own header (the shell speaks tabName instead),
-- and toggles the BaseMenu's _chainSpeech flag during onTabActivated so
-- re-activation content speakQueueds after the shell's tabName interrupt
-- rather than clobbering it.
--
-- Args:
--   tabName   (TXT_KEY) spoken on tab cycle.
--   menuSpec  same shape as BaseMenu.create's spec, minus name (we generate
--             one). silentDisplayName is forced to true. displayName must
--             still be present (BaseMenu requires it) but is unspoken.
function TabbedShell.menuTab(args)
    check(type(args) == "table", "TabbedShell.menuTab requires args")
    check(type(args.tabName) == "string" and args.tabName ~= "", "args.tabName required")
    check(type(args.menuSpec) == "table", "args.menuSpec required")

    local menuSpec = {}
    for k, v in pairs(args.menuSpec) do
        menuSpec[k] = v
    end
    menuSpec.silentDisplayName = true
    -- BaseMenu requires displayName for its own validation (and F1 readHeader);
    -- default to the tabName so a F1 inside the BaseMenu re-reads the tab name.
    if menuSpec.displayName == nil or menuSpec.displayName == "" then
        menuSpec.displayName = Text.key(args.tabName)
    end
    menuSpec.name = menuSpec.name or ("TabbedShell.menuTab." .. Text.key(args.tabName))

    local menu = BaseMenu.create(menuSpec)

    local tab = {
        tabName = args.tabName,
        bindings = menu.bindings,
        helpEntries = menu.helpEntries,
        _menu = menu,
    }

    function tab.onTabActivated(self, announce)
        if announce then
            SpeechPipeline.speakInterrupt(Text.key(self.tabName))
        end
        -- _chainSpeech makes BaseMenu's re-activation use speakQueued. First-
        -- open already uses speakQueued for content (silentDisplayName masks
        -- the only speakInterrupt in that branch), so the flag is harmless
        -- there.
        self._menu._chainSpeech = true
        local ok, err = pcall(self._menu.onActivate)
        self._menu._chainSpeech = nil
        if not ok then
            Log.error("TabbedShell.menuTab '" .. tostring(self.tabName) .. "' onActivate: " .. tostring(err))
        end
    end

    function tab.onTabDeactivated(self)
        if type(self._menu.onDeactivate) == "function" then
            local ok, err = pcall(self._menu.onDeactivate)
            if not ok then
                Log.error("TabbedShell.menuTab '" .. tostring(self.tabName) .. "' onDeactivate: " .. tostring(err))
            end
        end
    end

    -- BaseMenu's handleSearchInput hook is exposed as `handler.handleSearchInput`.
    -- Forward so type-ahead in the BaseMenu list works while it's the active
    -- tab. menu's expected signature is (self, vk, mods); we pass menu as self.
    function tab.handleSearchInput(_self, vk, mods)
        if type(menu.handleSearchInput) == "function" then
            return menu.handleSearchInput(menu, vk, mods)
        end
        return false
    end

    -- Reset the inner BaseMenu's first-open state. Called by the shell's
    -- install hide handler so the next open is a fresh first-open across
    -- all tabs. _initialized is the BaseMenu flag that gates first-open
    -- vs re-activation in BaseMenu.onActivate.
    function tab.resetForNextOpen(self)
        self._menu._initialized = false
    end

    -- Expose the inner menu for callers that need to push items, set the
    -- cursor, or refresh dynamic preambles between tab cycles.
    function tab.menu()
        return menu
    end

    return tab
end

-- Wrap a Context's existing ShowHide / Input handlers around a TabbedShell.
-- Mirrors BaseMenu.install: push on show, pop on hide, dispatch input via
-- InputRouter, fall through to priorInput on unbound Esc.
--
-- Spec fields specific to install (the rest are documented in TabbedShell.create):
--   priorShowHide,    chained beneath our wrapper so the engine's wiring
--   priorInput        keeps working underneath.
--   shouldActivate    fn() -> bool; if false on a non-hide ShowHide, skip
--                     the push without blocking the prior ShowHide.
--   onShow            fn(handler); runs after priorShowHide and before the
--                     push so callers can stage tab state.
--   deferActivate     when true, push fires next tick through TickPump so a
--                     same-frame hide can cancel before speech.
--   tickOwner         default true; install wires ContextPtr SetUpdate to
--                     TickPump for runOnce callbacks.
function TabbedShell.install(ContextPtr, spec)
    local handler = TabbedShell.create(spec)
    local priorShowHide = spec.priorShowHide
    local priorInput = spec.priorInput
    local deferActivate = spec.deferActivate == true
    local shouldActivate = spec.shouldActivate
    local onShow = spec.onShow
    local tickOwner = spec.tickOwner ~= false
    local onEscape = spec.onEscape
    local pendingPush = false

    if tickOwner then
        TickPump.install(ContextPtr)
    end

    local function runDeferredPush()
        if not pendingPush then
            return
        end
        pendingPush = false
        if ContextPtr:IsHidden() then
            return
        end
        HandlerStack.push(handler)
    end

    local function resetTabsForNextOpen()
        for _, tab in ipairs(handler._tabs) do
            if type(tab.resetForNextOpen) == "function" then
                local ok, err = pcall(tab.resetForNextOpen, tab)
                if not ok then
                    Log.error(
                        "TabbedShell '"
                            .. handler.name
                            .. "' resetForNextOpen on '"
                            .. tostring(tab.tabName)
                            .. "': "
                            .. tostring(err)
                    )
                end
            end
        end
        handler._initialized = false
        handler._activeIdx = spec.initialTabIndex or 1
        rebuildExposed(handler)
    end

    ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit)
        if priorShowHide then
            local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
            if not ok then
                Log.error("TabbedShell '" .. handler.name .. "' prior ShowHide: " .. tostring(err))
            end
        end
        if bIsInit then
            return
        end
        HandlerStack.removeByName(handler.name, bIsHide)
        if bIsHide then
            resetTabsForNextOpen()
            pendingPush = false
            return
        end
        if shouldActivate ~= nil then
            local ok, should = pcall(shouldActivate)
            if not ok then
                Log.error("TabbedShell '" .. handler.name .. "' shouldActivate: " .. tostring(should))
                return
            end
            if not should then
                return
            end
        end
        if onShow ~= nil then
            local ok, err = pcall(onShow, handler)
            if not ok then
                Log.error("TabbedShell '" .. handler.name .. "' onShow: " .. tostring(err))
            end
        end
        if deferActivate then
            pendingPush = true
            if not tickOwner then
                TickPump.install(ContextPtr)
            end
            TickPump.runOnce(runDeferredPush)
        else
            HandlerStack.push(handler)
        end
    end)

    ContextPtr:SetInputHandler(function(msg, wp, lp)
        local top = HandlerStack.active()
        if (msg == 256 or msg == 260) and wp == Keys.VK_ESCAPE then
            if top == handler then
                if onEscape ~= nil then
                    local ok, consumed = pcall(onEscape, handler)
                    if not ok then
                        Log.error("TabbedShell '" .. handler.name .. "' onEscape: " .. tostring(consumed))
                    elseif consumed then
                        return true
                    end
                end
                if priorInput then
                    return priorInput(msg, wp, lp)
                end
                return false
            end
            local mods = InputRouter.currentModifierMask()
            if InputRouter.dispatch(wp, mods, msg) then
                return true
            end
            if priorInput then
                return priorInput(msg, wp, lp)
            end
            return false
        end
        local mods = InputRouter.currentModifierMask()
        if InputRouter.dispatch(wp, mods, msg) then
            return true
        end
        if priorInput then
            return priorInput(msg, wp, lp)
        end
        return false
    end)

    return handler
end

return TabbedShell

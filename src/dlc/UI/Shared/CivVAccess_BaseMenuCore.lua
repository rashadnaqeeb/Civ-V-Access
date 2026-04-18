-- Polymorphic menu container. Navigates a nested list of items that implement
-- the BaseMenuItems interface (isNavigable / isActivatable / announce /
-- activate / adjust / children), with optional tabbed grouping.
--
-- Nested navigation:
--   Items can be Groups (see BaseMenuItems.Group) whose children are another
--   list of items. Navigation tracks a 1-based level (_level) and a cursor at
--   each level (_indices[level]). Right drills into a group; Left / Esc at
--   level > 1 goes back up a level. At level > 1 Up/Down wraps across sibling
--   groups (skipping leaves at the parent level), announcing the new group
--   before the first child on a boundary crossing. Ctrl+Up / Ctrl+Down jump
--   to the prev / next sibling group at the parent level, or across groups
--   at level 1.
--
-- Key bindings:
--   Up / Down             previous / next within current level (wraps at
--                         level 1; at level > 1 crosses to sibling groups)
--   Home / End            first / last navigable item within current level
--   Enter / Space         drill if current item is a group; else activate
--   Left                  on a slider adjust; else at level > 1 go back
--   Right                 on a slider adjust; on a group drill
--   Shift+Left / Right    slider big-step adjust
--   Ctrl+Up / Ctrl+Down   prev / next sibling group at the parent level
--   Tab / Shift+Tab       cycle tabs (when spec has tabs)
--   F1                    re-speak displayName + preamble (re-reads the
--                         live value of a function preamble)
--   A-Z / 0-9 / Space     type-ahead search (filters current level's items
--                         by tiered match; see TypeAheadSearch). Up/Down/
--                         Home/End navigate matches while active, Enter
--                         activates, Backspace rewinds, Esc clears.
--   Esc                   while a search is active: clear the search;
--                         otherwise at level > 1 go back a level; at
--                         level 1 bypass to screen's priorInput
--
-- Spec:
--   name              (string, required) stack identity.
--   displayName       (string, required) spoken on screen activation.
--   items   OR  tabs  array of item tables (see BaseMenuItems), or per-tab array
--                     of { name = "TXT_KEY", showPanel = fn, items = {...} }.
--   preamble          string | fn() -> string, spoken after displayName.
--                     A function preamble is re-readable via refresh() so
--                     dynamic status text (FrontEndPopup body, JoiningRoom
--                     status) can speak the latest on change.
--   shouldActivate    fn() -> bool; predicate consulted on every non-hide
--                     ShowHide. Return false to skip the push + announce
--                     without blocking the prior ShowHide (WaitingForPlayers
--                     splash during SP loads).
--   deferActivate    when true, push is deferred one tick through TickPump
--                    so a same-frame hide (EULA -> Mods transition) can
--                    cancel the pending push before speech fires.
--   priorShowHide,    screen's existing ShowHide / Input handlers; chained
--   priorInput        so the game's own wiring keeps working beneath ours.
--   focusParkControl  name of a non-EditBox control the menu can TakeFocus
--                     on to release any engine-held EditBox focus (auto-
--                     focused on tab switch or after edit-mode exit).
--   escapePops        when true, adds an Esc binding that pops this menu
--                     by name. Used by Pulldown's child menus so Esc cancels
--                     the sub without bypassing to the screen's priorInput.
--   tickOwner         default true; when true install wires ContextPtr's
--                     SetUpdate to TickPump so runOnce callbacks (edit-mode
--                     TakeFocus, deferred pushes) fire.
--   capturesAllInput  default true; the modal barrier for InputRouter.

BaseMenu = {}

local MOD_SHIFT = 1
local MOD_CTRL  = 2

-- Walk helpers ------------------------------------------------------------

local function nextValidIndex(items, start, step)
    return Nav.next(items, start, step, function(it)
        return it:isNavigable()
    end)
end

-- Non-wrapping walk in `step` direction. Returns nil at the list boundary.
-- Used at level > 1 where Up/Down cross into sibling groups on past-end
-- rather than wrapping within the current group's children.
local function stepValid(items, start, step)
    local n = #items
    local i = start
    while true do
        i = i + step
        if i < 1 or i > n then return nil end
        if items[i]:isNavigable() then return i end
    end
end

local function topLevelItems(self)
    if self.tabs then
        local t = self.tabs[self._tabIndex]
        return t and t._items or {}
    end
    return self._items or {}
end

-- Resolve items at a specific level by walking the parent path via
-- _indices[1..level-1]. Each intermediate parent must be a group (has a
-- children method). Returns empty list if the path breaks.
local function itemsAtLevel(self, level)
    local items = topLevelItems(self)
    for l = 1, level - 1 do
        local parent = items[self._indices[l]]
        if parent == nil or type(parent.children) ~= "function" then
            return {}
        end
        items = parent:children()
    end
    return items
end

local function currentItems(self)
    return itemsAtLevel(self, self._level)
end

local function currentIndex(self)
    return self._indices[self._level] or 1
end

-- Scan `items` starting from startIdx in `step` direction, wrapping around,
-- for the next navigable Group. Returns nil if none exist. The starting
-- index itself is not returned (only proper siblings and wrap-around).
local function findSiblingGroup(items, startIdx, step)
    local n = #items
    if n == 0 then return nil end
    local i = startIdx
    for _ = 1, n do
        i = i + step
        if i < 1 then i = n end
        if i > n then i = 1 end
        local sib = items[i]
        if sib ~= nil and sib.kind == "group" and sib:isNavigable() then
            return i
        end
    end
    return nil
end

-- Focus park --------------------------------------------------------------
--
-- TakeFocus is EditBox-only in Civ V; on non-EditBox widgets the pcall
-- fails. The park attempt is best-effort: log once per handler, then mark
-- _parkDisabled so repeated calls don't spam.

local function parkFocus(self)
    if self._parkDisabled then return end
    if self._focusParkControl == nil then return end
    local park = Controls[self._focusParkControl]
    if park == nil then
        Log.warn("BaseMenu '" .. self.name .. "' focus-park control '"
            .. tostring(self._focusParkControl)
            .. "' not found; disabling park for this handler")
        self._parkDisabled = true
        return
    end
    local ok, err = pcall(function() park:TakeFocus() end)
    if not ok then
        Log.warn("BaseMenu '" .. self.name
            .. "' focus-park TakeFocus failed, disabling park for this handler: "
            .. tostring(err))
        self._parkDisabled = true
    end
end

-- Preamble ----------------------------------------------------------------

local function resolvePreamble(self)
    local p = self.preamble
    if p == nil then return nil end
    if type(p) == "function" then
        local ok, result = pcall(p)
        if not ok then
            Log.error("BaseMenu '" .. self.name .. "' preamble fn failed: "
                .. tostring(result))
            return nil
        end
        return result
    end
    return p
end

-- Level-change boundary: the item list we were searching over just went
-- away (drill in/out, tab switch, explicit setItems replacement), so drop
-- the search state before any arrow-key or char event fires against stale
-- result indices.
local function resetSearch(self)
    if self._search ~= nil then self._search:clear() end
end

-- Tabs --------------------------------------------------------------------

local function switchTab(self, newTabIndex)
    if self.tabs == nil then return end
    local n = #self.tabs
    if n == 0 then return end
    if newTabIndex < 1 then newTabIndex = n end
    if newTabIndex > n then newTabIndex = 1 end
    if newTabIndex == self._tabIndex then return end
    self._tabIndex = newTabIndex
    local tab = self.tabs[newTabIndex]
    if type(tab.showPanel) == "function" then
        local ok, err = pcall(tab.showPanel)
        if not ok then
            Log.error("BaseMenu '" .. self.name .. "' showPanel for tab '"
                .. tostring(tab.name) .. "': " .. tostring(err))
        end
    end
    parkFocus(self)
    -- Reset nesting on tab switch: the new tab's items are a fresh list.
    self._level = 1
    local items = currentItems(self)
    local first = nextValidIndex(items, 0, 1)
    self._indices = { first or 1 }
    resetSearch(self)
    SpeechPipeline.speakInterrupt(Text.key(tab.name))
    if first ~= nil then
        SpeechPipeline.speakQueued(items[first]:announce(self))
    end
end

local function cycleTab(self, step)
    if self.tabs == nil then return end
    switchTab(self, self._tabIndex + step)
end

-- Navigation / activation -------------------------------------------------

local function moveToIndex(self, newIndex)
    if newIndex == nil or newIndex == currentIndex(self) then return end
    self._indices[self._level] = newIndex
    local item = currentItems(self)[newIndex]
    if item == nil then return end
    SpeechPipeline.speakInterrupt(item:announce(self))
end

-- Enter a group at the current cursor. If the group is empty or has no
-- navigable children the level is left unchanged and the group label is
-- re-announced (user gets feedback that nothing happened).
local function drillInto(self)
    local items = currentItems(self)
    local group = items[currentIndex(self)]
    if group == nil or group.kind ~= "group" then return end
    local children = group:children()
    local first = nextValidIndex(children, 0, 1)
    if first == nil then
        SpeechPipeline.speakInterrupt(group:announce(self))
        return
    end
    self._level = self._level + 1
    self._indices[self._level] = first
    resetSearch(self)
    SpeechPipeline.speakInterrupt(children[first]:announce(self))
end

local function goBackLevel(self)
    if self._level <= 1 then return end
    self._indices[self._level] = nil
    self._level = self._level - 1
    resetSearch(self)
    local item = currentItems(self)[currentIndex(self)]
    if item == nil then return end
    SpeechPipeline.speakInterrupt(item:announce(self))
end

-- Cross-parent jump at the parent level (self._level - 1). Lands on the
-- first / last valid child of the new group and announces "<group label>,
-- <child>" on a real boundary crossing; on same-group wrap (1 sibling group)
-- speaks just the child.
local function jumpSiblingGroup(self, step, landOnLast)
    if self._level <= 1 then return end
    local parentLevel = self._level - 1
    local parents = itemsAtLevel(self, parentLevel)
    local startParent = self._indices[parentLevel]
    local newParent = findSiblingGroup(parents, startParent, step)
    if newParent == nil then return end
    self._indices[parentLevel] = newParent
    local newItems = currentItems(self)
    local target
    if landOnLast then
        target = nextValidIndex(newItems, #newItems + 1, -1)
    else
        target = nextValidIndex(newItems, 0, 1)
    end
    if target == nil then
        self._indices[parentLevel] = startParent
        return
    end
    self._indices[self._level] = target
    local crossed = (newParent ~= startParent)
    if crossed then
        SpeechPipeline.speakInterrupt(parents[newParent]:announce(self))
        SpeechPipeline.speakQueued(newItems[target]:announce(self))
    else
        SpeechPipeline.speakInterrupt(newItems[target]:announce(self))
    end
end

local function onUp(self)
    if self._search ~= nil and self._search:isSearchActive() then
        self._search:navigateResults(-1); return
    end
    local items = currentItems(self)
    if self._level == 1 then
        moveToIndex(self, nextValidIndex(items, currentIndex(self), -1))
        return
    end
    local prev = stepValid(items, currentIndex(self), -1)
    if prev ~= nil then
        moveToIndex(self, prev)
    else
        jumpSiblingGroup(self, -1, true)
    end
end

local function onDown(self)
    if self._search ~= nil and self._search:isSearchActive() then
        self._search:navigateResults(1); return
    end
    local items = currentItems(self)
    if self._level == 1 then
        moveToIndex(self, nextValidIndex(items, currentIndex(self), 1))
        return
    end
    local next = stepValid(items, currentIndex(self), 1)
    if next ~= nil then
        moveToIndex(self, next)
    else
        jumpSiblingGroup(self, 1, false)
    end
end

local function onHome(self)
    if self._search ~= nil and self._search:isSearchActive() then
        self._search:jumpToFirstResult(); return
    end
    moveToIndex(self, nextValidIndex(currentItems(self), 0, 1))
end

local function onEnd(self)
    if self._search ~= nil and self._search:isSearchActive() then
        self._search:jumpToLastResult(); return
    end
    local items = currentItems(self)
    moveToIndex(self, nextValidIndex(items, #items + 1, -1))
end

local function onEnter(self)
    local items = currentItems(self)
    if #items == 0 then return end
    local item = items[currentIndex(self)]
    if item == nil or not item:isNavigable() then
        Log.warn("BaseMenu '" .. self.name .. "': Enter on invalid item")
        return
    end
    if item.kind == "group" then
        drillInto(self)
        return
    end
    if not item:isActivatable() then
        SpeechPipeline.speakInterrupt(item:announce(self))
        return
    end
    item:activate(self)
    -- Post-activate revalidation: if the just-activated item is now hidden
    -- (MultiplayerSelect's Standard/Pitboss toggle), advance and speak the
    -- next valid item so the user gets feedback on the state change.
    if not item:isNavigable() then
        local next = nextValidIndex(currentItems(self), currentIndex(self), 1)
        if next ~= nil then
            self._indices[self._level] = next
            SpeechPipeline.speakQueued(currentItems(self)[next]:announce(self))
        end
    end
end

-- Left/Right semantics:
--   Slider -> adjust (handler-bound, same as before)
--   Group  -> Right drills; Left falls through to level-back
--   Others -> level > 1 Left goes back a level; Right is a no-op
local function onLeft(self, big)
    local item = currentItems(self)[currentIndex(self)]
    if item == nil then return end
    if item.kind == "slider" then
        if item.adjust then item:adjust(self, -1, big) end
        return
    end
    if self._level > 1 then goBackLevel(self) end
end

local function onRight(self, big)
    local item = currentItems(self)[currentIndex(self)]
    if item == nil then return end
    if item.kind == "slider" then
        if item.adjust then item:adjust(self, 1, big) end
        return
    end
    if item.kind == "group" then
        drillInto(self)
    end
end

-- Ctrl+Up/Down at level 1 jumps among top-level groups (skipping leaves);
-- at level > 1 jumps to the prev/next sibling group at the parent level.
local function onCtrlUp(self)
    if self._level == 1 then
        local target = findSiblingGroup(currentItems(self),
            currentIndex(self), -1)
        if target ~= nil then moveToIndex(self, target) end
        return
    end
    jumpSiblingGroup(self, -1, false)
end

local function onCtrlDown(self)
    if self._level == 1 then
        local target = findSiblingGroup(currentItems(self),
            currentIndex(self), 1)
        if target ~= nil then moveToIndex(self, target) end
        return
    end
    jumpSiblingGroup(self, 1, false)
end

local function onTab(self)      cycleTab(self,  1) end
local function onShiftTab(self) cycleTab(self, -1) end

-- Search interface / input dispatch ---------------------------------------
--
-- Build a searchable view of the menu's current level for TypeAheadSearch.
-- getLabel returns nil for non-navigable items so results only land the
-- user on visible, active entries. moveTo is invoked by the search when it
-- picks / cycles a result: it rewrites the level cursor (_indices[level])
-- and announces the item via the existing composeSpeech path, exactly the
-- same announcement the user would hear from arrow-key nav.
local function buildSearchable(self)
    return {
        itemCount = function() return #currentItems(self) end,
        getLabel  = function(i)
            local item = currentItems(self)[i]
            if item == nil or not item:isNavigable() then return nil end
            local ok, text = pcall(function() return item:announce(self) end)
            if not ok or text == nil then return nil end
            return TextFilter.filter(text)
        end,
        moveTo = function(origIndex)
            self._indices[self._level] = origIndex
            local item = currentItems(self)[origIndex]
            if item == nil then return end
            SpeechPipeline.speakInterrupt(item:announce(self))
        end,
    }
end

-- Map a VK code / modifier mask to the character input layer. Returns true
-- if the search consumed the event. Letters (A-Z) are lower-cased; digits
-- (0-9) pass through as their char. Ctrl / Alt combinations do not feed
-- the search (those are hotkey territory). Shift is ignored — Shift+letter
-- is still "a letter" for search purposes.
function BaseMenu._handleSearchInput(handler, vk, mods)
    local hasCtrl = math.floor(mods / 2) % 2 == 1
    local hasAlt  = math.floor(mods / 4) % 2 == 1
    if hasCtrl or hasAlt then return false end

    local searchable = buildSearchable(handler)
    local search = handler._search

    if vk >= 0x41 and vk <= 0x5A then
        return search:handleChar(string.char(vk + 32), searchable)
    end
    if vk >= 0x30 and vk <= 0x39 then
        return search:handleChar(string.char(vk), searchable)
    end
    if vk == Keys.VK_SPACE and search:isSearchActive() then
        return search:handleKey(Keys.VK_SPACE, false, false, searchable)
    end
    if vk == Keys.VK_BACK then
        return search:handleKey(Keys.VK_BACK, false, false, searchable)
    end
    return false
end

-- Factory ------------------------------------------------------------------

function BaseMenu.create(spec)
    assert(type(spec) == "table", "BaseMenu.create requires a spec table")
    assert(type(spec.name) == "string" and spec.name ~= "",
        "spec.name required")
    assert(type(spec.displayName) == "string" and spec.displayName ~= "",
        "spec.displayName required")
    assert(spec.tabs == nil or spec.items == nil,
        "spec must have EITHER tabs OR items, not both")
    assert(spec.preamble == nil
        or (type(spec.preamble) == "string" and spec.preamble ~= "")
        or type(spec.preamble) == "function",
        "spec.preamble must be a non-empty string or a function if provided")

    local self = {
        name              = spec.name,
        displayName       = spec.displayName,
        preamble          = spec.preamble,
        capturesAllInput  = spec.capturesAllInput ~= false,
        _level            = 1,
        _indices          = { 1 },
        _tabIndex         = 1,
        -- Optional 1-based cursor at level 1 to land on at first onActivate.
        -- Used by Pulldown to open its child sub-menu pre-positioned on the
        -- current selection. Ignored if the target index is not navigable at
        -- open time; falls through to the first-valid default.
        _initialIndex     = spec.initialIndex,
        _focusParkControl = spec.focusParkControl,
        -- _initialized gates the first-open setup (reset cursor, speak
        -- displayName + preamble + tab + item). Re-activations from a sub
        -- pop preserve cursor and just re-announce the current item.
        _initialized      = false,
        _search           = TypeAheadSearch.new(),
    }

    if spec.tabs then
        assert(type(spec.tabs) == "table" and #spec.tabs > 0,
            "spec.tabs must be a non-empty array")
        local tabs = {}
        for i, tab in ipairs(spec.tabs) do
            assert(type(tab.name) == "string",
                "tab " .. i .. ".name (TXT_KEY) required")
            assert(type(tab.items) == "table",
                "tab " .. i .. ".items required")
            tabs[i] = {
                name      = tab.name,
                showPanel = tab.showPanel,
                _items    = tab.items,
            }
        end
        self.tabs = tabs
    else
        assert(type(spec.items) == "table", "spec.items or spec.tabs required")
        self._items = spec.items
    end

    self.bindings = {
        { key = Keys.VK_UP,     mods = 0,         description = "Previous item",
          fn = function() onUp(self) end },
        { key = Keys.VK_DOWN,   mods = 0,         description = "Next item",
          fn = function() onDown(self) end },
        { key = Keys.VK_UP,     mods = MOD_CTRL,  description = "Previous group",
          fn = function() onCtrlUp(self) end },
        { key = Keys.VK_DOWN,   mods = MOD_CTRL,  description = "Next group",
          fn = function() onCtrlDown(self) end },
        { key = Keys.VK_HOME,   mods = 0,         description = "First item",
          fn = function() onHome(self) end },
        { key = Keys.VK_END,    mods = 0,         description = "Last item",
          fn = function() onEnd(self) end },
        { key = Keys.VK_LEFT,   mods = 0,         description = "Adjust decrease / back",
          fn = function() onLeft(self, false) end },
        { key = Keys.VK_RIGHT,  mods = 0,         description = "Adjust increase / drill",
          fn = function() onRight(self, false) end },
        { key = Keys.VK_LEFT,   mods = MOD_SHIFT, description = "Adjust decrease (big)",
          fn = function() onLeft(self, true) end },
        { key = Keys.VK_RIGHT,  mods = MOD_SHIFT, description = "Adjust increase (big)",
          fn = function() onRight(self, true) end },
        { key = Keys.VK_RETURN, mods = 0,         description = "Activate / drill",
          fn = function() onEnter(self) end },
        { key = Keys.VK_SPACE,  mods = 0,         description = "Activate / drill",
          fn = function() onEnter(self) end },
        { key = Keys.VK_TAB,    mods = 0,         description = "Next tab",
          fn = function() onTab(self) end },
        { key = Keys.VK_TAB,    mods = MOD_SHIFT, description = "Previous tab",
          fn = function() onShiftTab(self) end },
        { key = Keys.VK_F1,     mods = 0,         description = "Read screen header",
          fn = function() self.readHeader() end },
    }
    if spec.escapePops then
        self.bindings[#self.bindings + 1] = {
            key = Keys.VK_ESCAPE, mods = 0, description = "Cancel",
            fn  = function() HandlerStack.removeByName(self.name, true) end,
        }
    end

    -- Upvalue: refresh() and onActivate both touch this; meaningless for
    -- string preambles (they never change).
    local lastPreambleText = nil

    function self.onActivate()
        -- Release any engine-held EditBox focus so arrow keys reach our
        -- bindings (base-screen ShowHide often focuses an EditBox; tab
        -- switch reveals a panel whose first EditBox auto-focuses).
        parkFocus(self)
        local items
        if not self._initialized then
            self._level = 1
            self._indices = { 1 }
            resetSearch(self)
            if self.tabs then
                self._tabIndex = 1
                local tab = self.tabs[1]
                if type(tab.showPanel) == "function" then
                    local ok, err = pcall(tab.showPanel)
                    if not ok then
                        Log.error("BaseMenu '" .. self.name
                            .. "' initial showPanel: " .. tostring(err))
                    end
                end
            end
            items = currentItems(self)
            local first = nextValidIndex(items, 0, 1)
            local startIndex = first or 1
            if self._initialIndex ~= nil then
                local target = items[self._initialIndex]
                if target ~= nil and target:isNavigable() then
                    startIndex = self._initialIndex
                end
            end
            self._indices[1] = startIndex
            self._initialized = true
            SpeechPipeline.speakInterrupt(self.displayName)
            local preambleText = resolvePreamble(self)
            if preambleText ~= nil and preambleText ~= "" then
                SpeechPipeline.speakQueued(preambleText)
            end
            lastPreambleText = preambleText
            if self.tabs then
                SpeechPipeline.speakQueued(Text.key(self.tabs[self._tabIndex].name))
            end
            if items[startIndex] ~= nil then
                SpeechPipeline.speakQueued(items[startIndex]:announce(self))
            end
            return
        end
        -- Re-activation (sub pop, EditMode pop). Validate cursor at current
        -- level first: a pulldown selection or post-activate hide can flip
        -- visibility.
        items = currentItems(self)
        local idx = currentIndex(self)
        local item = items[idx]
        if item == nil or not item:isNavigable() then
            local next = nextValidIndex(items, (idx or 1) - 1, 1)
            if next == nil then return end
            self._indices[self._level] = next
            item = items[next]
        end
        SpeechPipeline.speakInterrupt(item:announce(self))
    end

    function self.onDeactivate() end

    -- Replace the item list used for navigation. Dynamic-item feature:
    -- screens whose widgets are built by InstanceManager (e.g. dependent
    -- pulldowns, GameOption checkboxes) rebuild their lists at runtime and
    -- call setItems with freshly constructed BaseMenuItems entries.
    --
    -- Resets level to 1 and clamps the cursor to the first navigable item
    -- at or after the previous index. No announcement on swap; callers
    -- that want an announcement after a rebuild should call refresh()
    -- (for dynamic preambles) or drive their own speakInterrupt.
    function self.setItems(items, tabIndex)
        assert(type(items) == "table", "setItems: items must be a table")
        if self.tabs then
            tabIndex = tabIndex or self._tabIndex
            assert(self.tabs[tabIndex] ~= nil,
                "setItems: tab " .. tostring(tabIndex) .. " out of range")
            self.tabs[tabIndex]._items = items
        else
            self._items = items
        end
        if not self.tabs or tabIndex == self._tabIndex then
            self._level = 1
            local curr = (self._indices and self._indices[1]) or 1
            local newItems = currentItems(self)
            local item = newItems[curr]
            if item == nil or not item:isNavigable() then
                curr = nextValidIndex(newItems, (curr or 1) - 1, 1) or 1
            end
            self._indices = { curr }
            resetSearch(self)
        end
    end

    -- Update the level-1 cursor position that onActivate lands on the next
    -- time _initialized is false. `_initialized` resets on every hide
    -- through install's ShowHide wrapper, so a caller that recomputes the
    -- index in onShow or priorShowHide will have it honored on the next
    -- open. Clears back to `nil` when passed nil. Invalid / out-of-range
    -- values fall through the same isNavigable check spec.initialIndex
    -- uses.
    function self.setInitialIndex(idx)
        self._initialIndex = idx
    end

    -- Set the live level-1 cursor position. Does not announce (callers
    -- doing their own speech, e.g. folder drill-in, own the
    -- announcement). No-op on nil; silent when idx is out of range
    -- (setItems already clamps invalid slots on the next navigation key).
    function self.setIndex(idx)
        if idx == nil then return end
        self._level = 1
        self._indices = { idx }
    end

    -- Re-speak the displayName + current preamble. Resolves a function
    -- preamble fresh so F1 reads live state, and syncs lastPreambleText so
    -- a later refresh() against an unchanged value stays a no-op.
    function self.readHeader()
        SpeechPipeline.speakInterrupt(self.displayName)
        local preambleText = resolvePreamble(self)
        if preambleText ~= nil and preambleText ~= "" then
            SpeechPipeline.speakQueued(preambleText)
            lastPreambleText = preambleText
        end
    end

    -- Re-evaluate a function preamble; speakInterrupt if the result changed
    -- from what was last spoken. No-op for string preambles.
    function self.refresh()
        if type(self.preamble) ~= "function" then return end
        local text = resolvePreamble(self)
        if text == nil or text == "" then return end
        if text == lastPreambleText then return end
        lastPreambleText = text
        SpeechPipeline.speakInterrupt(text)
    end

    -- Exposed so install's InputHandler can route Esc at level > 1 without
    -- touching module locals.
    self._goBackLevel = function() goBackLevel(self) end

    return self
end

-- Install -----------------------------------------------------------------

function BaseMenu.install(ContextPtr, spec)
    local handler        = BaseMenu.create(spec)
    local priorShowHide  = spec.priorShowHide
    local priorInput     = spec.priorInput
    local deferActivate  = spec.deferActivate == true
    local shouldActivate = spec.shouldActivate
    local onShow         = spec.onShow
    local tickOwner      = spec.tickOwner ~= false
    local pendingPush    = false

    if tickOwner then
        TickPump.install(ContextPtr)
    end

    local function runDeferredPush()
        if not pendingPush then return end
        pendingPush = false
        if ContextPtr:IsHidden() then return end
        HandlerStack.push(handler)
    end

    ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit)
        if priorShowHide then
            local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
            if not ok then
                Log.error("BaseMenu '" .. handler.name
                    .. "' prior ShowHide: " .. tostring(err))
            end
        end
        -- reactivate=false: we're about to push this same handler back on;
        -- firing onActivate on whatever is underneath would spuriously
        -- announce a screen the user is about to be pulled off of.
        HandlerStack.removeByName(handler.name, false)
        if bIsHide then
            handler._initialized = false
            pendingPush = false
            return
        end
        if shouldActivate ~= nil then
            local ok, should = pcall(shouldActivate)
            if not ok then
                Log.error("BaseMenu '" .. handler.name
                    .. "' shouldActivate: " .. tostring(should))
                return
            end
            if not should then return end
        end
        -- onShow runs after priorShowHide (so the base screen's setters
        -- have finalized) and before the push (so setInitialIndex /
        -- setItems calls land before onActivate reads them). Receives the
        -- handler so callers don't need a forward-declared upvalue.
        if onShow ~= nil then
            local ok, err = pcall(onShow, handler)
            if not ok then
                Log.error("BaseMenu '" .. handler.name
                    .. "' onShow: " .. tostring(err))
            end
        end
        -- Park before push so arrow keys are not swallowed by a base-screen
        -- TakeFocus on an EditBox (e.g., ChangePassword's ShowHide focuses
        -- the Old/New password box).
        parkFocus(handler)
        if deferActivate then
            pendingPush = true
            if not tickOwner then TickPump.install(ContextPtr) end
            TickPump.runOnce(runDeferredPush)
        else
            HandlerStack.push(handler)
        end
    end)

    ContextPtr:SetInputHandler(function(msg, wp, lp)
        local top = HandlerStack.active()
        -- During edit mode, claim the Enter KEYUP so the engine's default
        -- Enter-release doesn't revoke focus from the EditBox we just took
        -- focus on. Without this, typed characters end up nowhere.
        if top ~= nil and top._editMode and msg == 257
                and wp == Keys.VK_RETURN then
            return true
        end
        if (msg == 256 or msg == 260) and wp == Keys.VK_ESCAPE then
            -- Esc on the menu itself: if a type-ahead search is live, clear
            -- it and stay at the current level. Otherwise at level > 1 go
            -- up a level; at level 1 bypass to the screen's own Back / OnNo.
            -- Esc on a sub (pulldown / edit mode) runs the sub's binding.
            if top == handler then
                if handler._search:isSearchActive() or handler._search:hasBuffer() then
                    handler._search:clear()
                    SpeechPipeline.speakInterrupt(
                        Text.key("TXT_KEY_CIVVACCESS_SEARCH_CLEARED"))
                    return true
                end
                if handler._level > 1 then
                    handler._goBackLevel()
                    return true
                end
                if priorInput then return priorInput(msg, wp, lp) end
                return false
            end
            local mods = InputRouter.currentModifierMask()
            if InputRouter.dispatch(wp, mods, msg) then return true end
            if priorInput then return priorInput(msg, wp, lp) end
            return false
        end
        -- Type-ahead search: intercept printable and Backspace before the
        -- binding dispatch so letters / digits / space / backspace don't
        -- need 40+ redundant bindings. Only fires when this handler is on
        -- top (a pulldown sub-menu or edit mode takes over ownership).
        if msg == 256 and top == handler then
            local mods = InputRouter.currentModifierMask()
            if BaseMenu._handleSearchInput(handler, wp, mods) then
                return true
            end
        end
        local mods = InputRouter.currentModifierMask()
        if InputRouter.dispatch(wp, mods, msg) then return true end
        if priorInput then return priorInput(msg, wp, lp) end
        return false
    end)

    return handler
end

-- Minimal InputHandler that routes Esc to backFn and consumes everything
-- else (returns true). Convenience for screens whose only non-menu input
-- contract is "Esc = go back".

function BaseMenu.escOnlyInput(backFn)
    return function(uiMsg, wParam)
        if (uiMsg == 256 or uiMsg == 260) and wParam == Keys.VK_ESCAPE then
            backFn()
        end
        return true
    end
end

-- EditMode sub-handler ----------------------------------------------------
--
-- Pushed above the menu when Textfield.activate fires. capturesAllInput is
-- false so every printable character / Backspace / caret arrow falls
-- through the mod's InputRouter to the engine-focused EditBox.
--
-- Enter commits: reads the current text, invokes priorCallback with
-- bIsEnter=true so non-CallOnChar EditBoxes (OptionsMenu's email, SMTP
-- host, MaxTurns / TurnTimer fields) still persist to OptionsManager /
-- PreGame, then parks focus + pops. Esc restores the snapshot.
--
-- The pop triggers BaseMenu.onActivate which re-announces the current item
-- (with its updated value). We then speakInterrupt the committed value or
-- "<label> restored" so the user hears explicit confirmation.

function BaseMenu._pushEdit(menu, textfieldItem)
    local editBox       = textfieldItem._control
    local priorCallback = textfieldItem.priorCallback
    local errCtx        = "BaseMenu '" .. menu.name .. "' textfield '"
        .. tostring(textfieldItem.controlName) .. "'"

    local function safe(op, fn)
        local ok, result = pcall(fn)
        if not ok then
            Log.error(errCtx .. " " .. op .. " failed: " .. tostring(result))
        end
        return ok, result
    end

    local okGet, text = safe("GetText", function() return editBox:GetText() end)
    local originalText = (okGet and text) or ""

    safe("clear SetText", function() editBox:SetText("") end)

    -- Wrapping callback chains every character to the screen's validator so
    -- typing keeps driving the screen's own state (e.g. SetMaxTurns). Does
    -- not own the Enter-pop: that is the edit-mode Esc/Enter bindings.
    local function wrappingCallback(t, control, bIsEnter)
        if priorCallback then
            safe("prior callback",
                function() priorCallback(t, control, bIsEnter) end)
        end
    end

    safe("RegisterCallback",
        function() editBox:RegisterCallback(wrappingCallback) end)

    local subName = menu.name .. "/" .. tostring(textfieldItem.controlName) .. "_Edit"
    local sub = {
        name             = subName,
        capturesAllInput = false,
        _editMode        = true,
    }

    local function exit(restore)
        if restore then
            safe("restore SetText",
                function() editBox:SetText(originalText) end)
        elseif priorCallback ~= nil then
            -- Non-CallOnChar EditBoxes only fire priorCallback on Enter, and
            -- our Enter binding just intercepted that Enter. Invoke prior
            -- manually with bIsEnter=true so the screen commits the value
            -- the same way a native Enter would. Safe for CallOnChar boxes
            -- too (the setter/validator is idempotent).
            local okG, typed = safe("commit GetText",
                function() return editBox:GetText() end)
            local committed = (okG and typed) or ""
            safe("commit callback",
                function() priorCallback(committed, editBox, true) end)
        end
        safe("restore RegisterCallback",
            function() editBox:RegisterCallback(priorCallback) end)
        parkFocus(menu)
        HandlerStack.removeByName(subName, true)
        if restore then
            SpeechPipeline.speakInterrupt(
                Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED",
                    BaseMenuItems.labelOf(textfieldItem)))
        else
            -- Speak committed value (blank sentinel if empty) so the user
            -- hears explicit confirmation of what was saved.
            SpeechPipeline.speakInterrupt(
                BaseMenuItems._textfieldCurrentValue(textfieldItem))
        end
    end

    sub.bindings = {
        { key = Keys.VK_ESCAPE, mods = 0, description = "Cancel edit",
          fn  = function() exit(true)  end },
        { key = Keys.VK_RETURN, mods = 0, description = "Commit edit",
          fn  = function() exit(false) end },
    }

    SpeechPipeline.speakInterrupt(
        Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_EDITING",
            BaseMenuItems.labelOf(textfieldItem)))

    HandlerStack.push(sub)

    -- Defer TakeFocus: calling it synchronously from inside a KEYDOWN
    -- handler leaves focus in a state the engine revokes when the matching
    -- KEYUP runs ~1 frame later, and subsequent WM_CHARs arrive with no
    -- focused widget. Letting the Enter pair complete before we steal focus
    -- sidesteps that.
    TickPump.runOnce(function()
        if HandlerStack.active() ~= sub then
            -- User exited edit mode before the tick fired (Esc before the
            -- first frame). Don't steal focus.
            return
        end
        safe("TakeFocus", function() editBox:TakeFocus() end)
    end)
end

return BaseMenu

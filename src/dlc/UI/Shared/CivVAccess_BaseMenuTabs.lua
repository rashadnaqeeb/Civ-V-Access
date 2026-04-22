-- Tab subsystem for BaseMenu. Owns tab-spec validation, the per-tab show /
-- onActivate / nameFn dispatch, and the switch / cycle orchestration that
-- resets the level cursor and announces the new tab's first item.
--
-- BaseMenuCore loads this file and calls into it; tab-aware reads of
-- self.tabs / self._tabIndex (e.g., topLevelItems) stay in Core because they
-- are one-line conditionals on the data layout, not behavior.
--
-- Navigation helpers Core owns (currentItems, currentIndex, nextValidIndex,
-- parkFocus, resetSearch) are passed in as a `nav` table on every entry
-- point that needs them. They cannot be required as locals because they are
-- module-scoped to Core.

BaseMenuTabs = {}

local function check(cond, msg)
    if not cond then
        Log.error(msg)
        error(msg, 2)
    end
end

-- Validate spec.tabs and return the array to assign to self.tabs. Caller
-- (BaseMenu.create) sets self._tabIndex = 1 separately so the rest of
-- create()'s state init reads in one place.
function BaseMenuTabs.normalize(specTabs)
    check(type(specTabs) == "table" and #specTabs > 0, "spec.tabs must be a non-empty array")
    local tabs = {}
    for i, tab in ipairs(specTabs) do
        check(type(tab.name) == "string", "tab " .. i .. ".name (TXT_KEY) required")
        check(type(tab.items) == "table", "tab " .. i .. ".items required")
        check(
            tab.onActivate == nil or type(tab.onActivate) == "function",
            "tab " .. i .. ".onActivate must be a function if provided"
        )
        check(
            tab.autoDrillToLevel == nil or (type(tab.autoDrillToLevel) == "number" and tab.autoDrillToLevel >= 1),
            "tab " .. i .. ".autoDrillToLevel must be a positive number"
        )
        check(
            tab.nameFn == nil or type(tab.nameFn) == "function",
            "tab " .. i .. ".nameFn must be a function if provided"
        )
        check(
            tab.onCtrlUp == nil or type(tab.onCtrlUp) == "function",
            "tab " .. i .. ".onCtrlUp must be a function if provided"
        )
        check(
            tab.onCtrlDown == nil or type(tab.onCtrlDown) == "function",
            "tab " .. i .. ".onCtrlDown must be a function if provided"
        )
        check(
            tab.onAltLeft == nil or type(tab.onAltLeft) == "function",
            "tab " .. i .. ".onAltLeft must be a function if provided"
        )
        check(
            tab.onAltRight == nil or type(tab.onAltRight) == "function",
            "tab " .. i .. ".onAltRight must be a function if provided"
        )
        check(
            tab.buildSearchable == nil or type(tab.buildSearchable) == "function",
            "tab " .. i .. ".buildSearchable must be a function if provided"
        )
        tabs[i] = {
            name = tab.name,
            showPanel = tab.showPanel,
            onActivate = tab.onActivate,
            autoDrillToLevel = tab.autoDrillToLevel,
            nameFn = tab.nameFn,
            onCtrlUp = tab.onCtrlUp,
            onCtrlDown = tab.onCtrlDown,
            onAltLeft = tab.onAltLeft,
            onAltRight = tab.onAltRight,
            buildSearchable = tab.buildSearchable,
            _items = tab.items,
        }
    end
    return tabs
end

-- Per-tab hook dispatch. PickerReader's reader tab overrides Ctrl+Up/Down to
-- mean "prev/next article" (vs. the default "prev/next sibling group"), and
-- Civilopedia's reader tab adds Alt+Left/Right for history back/forward (the
-- Alt chord has no BaseMenu default; unhooked tabs leave it a silent no-op).
-- Returns nil on tabless menus and on tabs without the named hook.
function BaseMenuTabs.hook(self, name)
    if self.tabs == nil then
        return nil
    end
    local tab = self.tabs[self._tabIndex]
    if tab == nil then
        return nil
    end
    local fn = tab[name]
    if type(fn) == "function" then
        return fn
    end
    return nil
end

-- Resolve the spoken name for a tab: nameFn override, or Text.key(tab.name).
-- nameFn returning empty / nil is meaningful: caller speaks nothing for the
-- tab name (no fallback to tab.name). pcall failure logs and returns nil.
local function resolveNameText(self, tab)
    if type(tab.nameFn) == "function" then
        local ok, result = pcall(tab.nameFn, self)
        if not ok then
            Log.error(
                "BaseMenu '" .. self.name .. "' nameFn for tab '" .. tostring(tab.name) .. "': " .. tostring(result)
            )
            return nil
        end
        return result
    end
    return Text.key(tab.name)
end

-- Walk the first navigable group at each level until reaching targetLevel,
-- or until the next item isn't a group / has no navigable children. Silent
-- on boundary: caller is responsible for the speech that follows. Used by
-- switch() to honor a tab spec's autoDrillToLevel, letting a PickerReader
-- reader-tab open already inside the first section rather than on the
-- section's header leaf.
local function autoDrillTo(self, targetLevel, nav)
    while self._level < targetLevel do
        local items = nav.currentItems(self)
        local cur = items[nav.currentIndex(self)]
        if cur == nil or cur.kind ~= "group" then
            return
        end
        local children = cur:children()
        local first = nav.nextValidIndex(children, 0, 1)
        if first == nil then
            return
        end
        self._level = self._level + 1
        self._indices[self._level] = first
    end
end

-- Core tab-activation path. `force` (used by switchToTab for programmatic
-- cross-tab jumps) bypasses the same-tab no-op so a PickerReader Entry
-- activation can re-enter the reader tab and re-announce even when it is
-- already the active tab. The Tab/Shift+Tab binding path sets force=false
-- so a wraparound onto the current tab is a no-op.
function BaseMenuTabs.switch(self, newTabIndex, force, nav)
    if self.tabs == nil then
        return
    end
    local n = #self.tabs
    if n == 0 then
        return
    end
    if newTabIndex < 1 then
        newTabIndex = n
    end
    if newTabIndex > n then
        newTabIndex = 1
    end
    if newTabIndex == self._tabIndex and not force then
        return
    end
    self._tabIndex = newTabIndex
    local tab = self.tabs[newTabIndex]
    if type(tab.showPanel) == "function" then
        local ok, err = pcall(tab.showPanel)
        if not ok then
            Log.error(
                "BaseMenu '" .. self.name .. "' showPanel for tab '" .. tostring(tab.name) .. "': " .. tostring(err)
            )
        end
    end
    nav.parkFocus(self)
    -- Reset nesting on tab switch: the new tab's items are a fresh list.
    self._level = 1
    local items = nav.currentItems(self)
    local first = nav.nextValidIndex(items, 0, 1)
    self._indices = { first or 1 }
    nav.resetSearch(self)
    -- onActivate fires between the reset and the announcement so callers
    -- (PickerReader's picker tab after a cross-tab return; reader tab on
    -- fresh selection) can swap items, restore a saved cursor, or set
    -- _level/_indices directly; the final announcement below speaks the
    -- item the callback landed on.
    if type(tab.onActivate) == "function" then
        local ok, err = pcall(tab.onActivate, self)
        if not ok then
            Log.error(
                "BaseMenu '" .. self.name .. "' onActivate for tab '" .. tostring(tab.name) .. "': " .. tostring(err)
            )
        end
    end
    if type(tab.autoDrillToLevel) == "number" then
        autoDrillTo(self, tab.autoDrillToLevel, nav)
    end
    local nameText = resolveNameText(self, tab)
    if nameText ~= nil and nameText ~= "" then
        SpeechPipeline.speakInterrupt(nameText)
    end
    local finalItems = nav.currentItems(self)
    local finalItem = finalItems[nav.currentIndex(self)]
    if finalItem ~= nil then
        if nameText ~= nil and nameText ~= "" then
            SpeechPipeline.speakQueued(finalItem:announce(self))
        else
            SpeechPipeline.speakInterrupt(finalItem:announce(self))
        end
    end
end

function BaseMenuTabs.cycle(self, step, nav)
    if self.tabs == nil then
        return
    end
    BaseMenuTabs.switch(self, self._tabIndex + step, false, nav)
end

-- First-open setup for tab 1. Mirrors switch's post-showPanel lifecycle
-- (cursor reset, tab.onActivate, autoDrillToLevel) so a tab whose
-- onActivate or autoDrillToLevel is meaningful sees the same behavior on
-- first open as on a subsequent Tab-key switch back. Returns the name
-- text the caller should speakQueued (or nil/"" to skip); caller handles
-- the displayName + preamble + first-item speech around it.
function BaseMenuTabs.openInitial(self, nav)
    self._tabIndex = 1
    local tab = self.tabs[1]
    if type(tab.showPanel) == "function" then
        local ok, err = pcall(tab.showPanel)
        if not ok then
            Log.error("BaseMenu '" .. self.name .. "' initial showPanel: " .. tostring(err))
        end
    end
    self._level = 1
    local items = nav.currentItems(self)
    local first = nav.nextValidIndex(items, 0, 1)
    self._indices = { first or 1 }
    if type(tab.onActivate) == "function" then
        local ok, err = pcall(tab.onActivate, self)
        if not ok then
            Log.error(
                "BaseMenu '" .. self.name .. "' onActivate for tab '" .. tostring(tab.name) .. "': " .. tostring(err)
            )
        end
    end
    if type(tab.autoDrillToLevel) == "number" then
        autoDrillTo(self, tab.autoDrillToLevel, nav)
    end
    return resolveNameText(self, tab)
end

return BaseMenuTabs

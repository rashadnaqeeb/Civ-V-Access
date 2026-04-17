-- Polymorphic menu container. Navigates a list of items that implement the
-- MenuItems interface (isNavigable / isActivatable / announce / activate /
-- adjust), with optional tabbed grouping. No kind-discriminated dispatch in
-- this file: new item kinds plug in via MenuItems without touching Menu.
--
-- Key bindings:
--   Up / Down           previous / next navigable item, wrapping
--   Home / End          first / last navigable item (every screen, always)
--   Enter / Space       item:activate(self)
--   Left / Right        item:adjust(self, -1/1, false)
--   Shift+Left / Right  item:adjust(self, -1/1, true)
--   Tab / Shift+Tab     cycle tabs (when spec has tabs)
--
-- Spec:
--   name              (string, required) stack identity.
--   displayName       (string, required) spoken on screen activation.
--   items   OR  tabs  array of item tables (see MenuItems), or per-tab array
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

Menu = {}

local MOD_SHIFT = 1

-- Walk helpers ------------------------------------------------------------

local function nextValidIndex(items, start, step)
    return Nav.next(items, start, step, function(it)
        return it:isNavigable()
    end)
end

local function currentItems(self)
    if self.tabs then
        local t = self.tabs[self._tabIndex]
        return t and t._items or {}
    end
    return self._items or {}
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
        Log.warn("Menu '" .. self.name .. "' focus-park control '"
            .. tostring(self._focusParkControl)
            .. "' not found; disabling park for this handler")
        self._parkDisabled = true
        return
    end
    local ok, err = pcall(function() park:TakeFocus() end)
    if not ok then
        Log.warn("Menu '" .. self.name
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
            Log.error("Menu '" .. self.name .. "' preamble fn failed: "
                .. tostring(result))
            return nil
        end
        return result
    end
    return p
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
            Log.error("Menu '" .. self.name .. "' showPanel for tab '"
                .. tostring(tab.name) .. "': " .. tostring(err))
        end
    end
    parkFocus(self)
    local items = currentItems(self)
    local first = nextValidIndex(items, 0, 1)
    self._index = first or 1
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

local function moveTo(self, newIndex)
    if newIndex == nil or newIndex == self._index then return end
    self._index = newIndex
    SpeechPipeline.speakInterrupt(currentItems(self)[newIndex]:announce(self))
end

local function onUp(self)
    moveTo(self, nextValidIndex(currentItems(self), self._index, -1))
end

local function onDown(self)
    moveTo(self, nextValidIndex(currentItems(self), self._index, 1))
end

local function onHome(self)
    moveTo(self, nextValidIndex(currentItems(self), 0, 1))
end

local function onEnd(self)
    local items = currentItems(self)
    moveTo(self, nextValidIndex(items, #items + 1, -1))
end

local function onEnter(self)
    local items = currentItems(self)
    if #items == 0 then return end
    local item = items[self._index]
    if item == nil or not item:isNavigable() then
        Log.warn("Menu '" .. self.name .. "': Enter on invalid item")
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
        local next = nextValidIndex(currentItems(self), self._index, 1)
        if next ~= nil then
            self._index = next
            SpeechPipeline.speakQueued(currentItems(self)[next]:announce(self))
        end
    end
end

local function onLeft(self, big)
    local item = currentItems(self)[self._index]
    if item == nil then return end
    if item.adjust then item:adjust(self, -1, big) end
end

local function onRight(self, big)
    local item = currentItems(self)[self._index]
    if item == nil then return end
    if item.adjust then item:adjust(self,  1, big) end
end

local function onTab(self)      cycleTab(self,  1) end
local function onShiftTab(self) cycleTab(self, -1) end

-- Factory ------------------------------------------------------------------

function Menu.create(spec)
    assert(type(spec) == "table", "Menu.create requires a spec table")
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
        _index            = 1,
        _tabIndex         = 1,
        _focusParkControl = spec.focusParkControl,
        -- _initialized gates the first-open setup (reset cursor, speak
        -- displayName + preamble + tab + item). Re-activations from a sub
        -- pop preserve cursor and just re-announce the current item.
        _initialized      = false,
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
        { key = Keys.VK_HOME,   mods = 0,         description = "First item",
          fn = function() onHome(self) end },
        { key = Keys.VK_END,    mods = 0,         description = "Last item",
          fn = function() onEnd(self) end },
        { key = Keys.VK_LEFT,   mods = 0,         description = "Adjust decrease",
          fn = function() onLeft(self, false) end },
        { key = Keys.VK_RIGHT,  mods = 0,         description = "Adjust increase",
          fn = function() onRight(self, false) end },
        { key = Keys.VK_LEFT,   mods = MOD_SHIFT, description = "Adjust decrease (big)",
          fn = function() onLeft(self, true) end },
        { key = Keys.VK_RIGHT,  mods = MOD_SHIFT, description = "Adjust increase (big)",
          fn = function() onRight(self, true) end },
        { key = Keys.VK_RETURN, mods = 0,         description = "Activate",
          fn = function() onEnter(self) end },
        { key = Keys.VK_SPACE,  mods = 0,         description = "Activate",
          fn = function() onEnter(self) end },
        { key = Keys.VK_TAB,    mods = 0,         description = "Next tab",
          fn = function() onTab(self) end },
        { key = Keys.VK_TAB,    mods = MOD_SHIFT, description = "Previous tab",
          fn = function() onShiftTab(self) end },
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
        local items = currentItems(self)
        if not self._initialized then
            if self.tabs then
                self._tabIndex = 1
                local tab = self.tabs[1]
                if type(tab.showPanel) == "function" then
                    local ok, err = pcall(tab.showPanel)
                    if not ok then
                        Log.error("Menu '" .. self.name
                            .. "' initial showPanel: " .. tostring(err))
                    end
                end
                items = currentItems(self)
            end
            local first = nextValidIndex(items, 0, 1)
            self._index = first or 1
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
            if first ~= nil then
                SpeechPipeline.speakQueued(items[first]:announce(self))
            end
            return
        end
        -- Re-activation (sub pop, EditMode pop). Validate cursor first: a
        -- pulldown selection or post-activate hide can flip visibility.
        local item = items[self._index]
        if item == nil or not item:isNavigable() then
            local next = nextValidIndex(items, (self._index or 1) - 1, 1)
            if next == nil then return end
            self._index = next
            item = items[next]
        end
        SpeechPipeline.speakInterrupt(item:announce(self))
    end

    function self.onDeactivate() end

    -- Replace the item list used for navigation. Dynamic-item feature:
    -- screens whose widgets are built by InstanceManager (e.g. dependent
    -- pulldowns, GameOption checkboxes) rebuild their lists at runtime and
    -- call setItems with freshly constructed MenuItems entries.
    -- No announcement on swap; if the cursor no longer points at a valid
    -- slot it clamps silently to the first valid.
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
            local curr = currentItems(self)
            local item = curr[self._index]
            if item == nil or not item:isNavigable() then
                local next = nextValidIndex(curr, (self._index or 1) - 1, 1)
                self._index = next or 1
            end
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

    return self
end

-- Install -----------------------------------------------------------------

function Menu.install(ContextPtr, spec)
    local handler        = Menu.create(spec)
    local priorShowHide  = spec.priorShowHide
    local priorInput     = spec.priorInput
    local deferActivate  = spec.deferActivate == true
    local shouldActivate = spec.shouldActivate
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
                Log.error("Menu '" .. handler.name
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
                Log.error("Menu '" .. handler.name
                    .. "' shouldActivate: " .. tostring(should))
                return
            end
            if not should then return end
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
            -- Esc on the menu itself bypasses to the screen's own Back /
            -- OnNo. Esc on a sub (pulldown / edit mode) runs the sub's
            -- Esc binding via dispatch.
            if top == handler then
                if priorInput then return priorInput(msg, wp, lp) end
                return false
            end
            local mods = InputRouter.currentModifierMask()
            if InputRouter.dispatch(wp, mods, msg) then return true end
            if priorInput then return priorInput(msg, wp, lp) end
            return false
        end
        local mods = InputRouter.currentModifierMask()
        if InputRouter.dispatch(wp, mods, msg) then return true end
        if priorInput then return priorInput(msg, wp, lp) end
        return false
    end)

    return handler
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
-- The pop triggers Menu.onActivate which re-announces the current item
-- (with its updated value). We then speakInterrupt the committed value or
-- "<label> restored" so the user hears explicit confirmation.

function Menu._pushEdit(menu, textfieldItem)
    local editBox       = textfieldItem._control
    local priorCallback = textfieldItem.priorCallback

    local okGet, text = pcall(function() return editBox:GetText() end)
    if not okGet then
        Log.error("Menu '" .. menu.name .. "' textfield '"
            .. tostring(textfieldItem.controlName)
            .. "' GetText failed: " .. tostring(text))
    end
    local originalText = (okGet and text) or ""

    local okClear, errClear = pcall(function() editBox:SetText("") end)
    if not okClear then
        Log.error("Menu '" .. menu.name .. "' textfield '"
            .. tostring(textfieldItem.controlName)
            .. "' clear SetText failed: " .. tostring(errClear))
    end

    -- Wrapping callback chains every character to the screen's validator so
    -- typing keeps driving the screen's own state (e.g. SetMaxTurns). Does
    -- not own the Enter-pop: that is the edit-mode Esc/Enter bindings.
    local function wrappingCallback(t, control, bIsEnter)
        if priorCallback then
            local ok, err = pcall(priorCallback, t, control, bIsEnter)
            if not ok then
                Log.error("Menu '" .. menu.name .. "' textfield '"
                    .. tostring(textfieldItem.controlName)
                    .. "' prior callback failed: " .. tostring(err))
            end
        end
    end

    local okReg, errReg = pcall(function() editBox:RegisterCallback(wrappingCallback) end)
    if not okReg then
        Log.error("Menu '" .. menu.name .. "' textfield '"
            .. tostring(textfieldItem.controlName)
            .. "' RegisterCallback failed: " .. tostring(errReg))
    end

    local subName = menu.name .. "/" .. tostring(textfieldItem.controlName) .. "_Edit"
    local sub = {
        name             = subName,
        capturesAllInput = false,
        _editMode        = true,
    }

    local function exit(restore)
        if restore then
            local ok, err = pcall(function() editBox:SetText(originalText) end)
            if not ok then
                Log.error("Menu '" .. menu.name .. "' textfield '"
                    .. tostring(textfieldItem.controlName)
                    .. "' restore SetText failed: " .. tostring(err))
            end
        elseif priorCallback ~= nil then
            -- Non-CallOnChar EditBoxes only fire priorCallback on Enter, and
            -- our Enter binding just intercepted that Enter. Invoke prior
            -- manually with bIsEnter=true so the screen commits the value
            -- the same way a native Enter would. Safe for CallOnChar boxes
            -- too (the setter/validator is idempotent).
            local okG, typed = pcall(function() return editBox:GetText() end)
            local okC, errC = pcall(priorCallback, (okG and typed) or "",
                editBox, true)
            if not okC then
                Log.error("Menu '" .. menu.name .. "' textfield '"
                    .. tostring(textfieldItem.controlName)
                    .. "' commit callback failed: " .. tostring(errC))
            end
        end
        local okReg2, errReg2 = pcall(function() editBox:RegisterCallback(priorCallback) end)
        if not okReg2 then
            Log.error("Menu '" .. menu.name .. "' textfield '"
                .. tostring(textfieldItem.controlName)
                .. "' restore RegisterCallback failed: " .. tostring(errReg2))
        end
        parkFocus(menu)
        HandlerStack.removeByName(subName, true)
        if restore then
            SpeechPipeline.speakInterrupt(
                Text.format("TXT_KEY_CIVVACCESS_TEXTFIELD_RESTORED",
                    MenuItems.labelOf(textfieldItem)))
        else
            -- Speak committed value (blank sentinel if empty) so the user
            -- hears explicit confirmation of what was saved.
            SpeechPipeline.speakInterrupt(
                MenuItems._textfieldCurrentValue(textfieldItem))
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
            MenuItems.labelOf(textfieldItem)))

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
        local okF, errF = pcall(function() editBox:TakeFocus() end)
        if not okF then
            Log.error("Menu '" .. menu.name .. "' textfield '"
                .. tostring(textfieldItem.controlName)
                .. "' TakeFocus failed: " .. tostring(errF))
        end
    end)
end

return Menu

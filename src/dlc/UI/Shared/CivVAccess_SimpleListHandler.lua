-- Reusable handler for the "flat vertical button list" family of screens:
-- Up/Down walk with wrap-around, Home/End jump to edges, Enter activates,
-- capturesAllInput so the barrier contains stray keys, no tick. A per-screen
-- access file declares the item list and calls install() to wire the
-- ContextPtr handlers.
--
-- Item shape:
--   controlName  (string, required) XML ID on Controls; resolved at create()
--   textKey      (string)           TXT_KEY_* for the spoken label; required
--                                   unless labelFn is given
--   labelFn      (fn(control))      alternative to textKey when the label is
--                                   live control text (pre-localized or set
--                                   by the screen after our items are built);
--                                   called with item._control at announce time
--   tooltipFn    (fn(control))      optional; read at announce time and
--                                   appended after the label. For buttons
--                                   whose tooltip is set dynamically via
--                                   SetToolTipString (Play Now settings
--                                   summary, disabled-reason hints) rather
--                                   than declared in XML.
--   activate     (fn, required)     fires on Enter; typically calls the
--                                   game's own click handler global
--
-- Spec may also carry an optional `preamble` (string OR function returning
-- string) spoken after displayName on entry, before the first item. A string
-- preamble is for static message text (ExitConfirm's "are you sure"); a
-- function preamble is for text that can change between enter and a later
-- refresh call (FrontEndPopup body, JoiningRoom status).
--
-- Items whose Controls.X is missing at create() are permanently invalid
-- (logged once). Navigation skips items that are :IsHidden() but walks items
-- that are :IsDisabled(); disabled items announce with a "disabled" suffix
-- and Enter on them is a no-op (no activate, no click sound). After activate
-- fires, if the just-activated item has flipped hidden (MultiplayerSelect's
-- Standard/Pitboss toggle case) we advance to the next valid entry and
-- speak it so the user gets feedback on the state change.
--
-- items may be an empty list: onActivate still speaks displayName + preamble
-- so status-splash screens (ContentSwitch, WaitingForPlayers, JoiningRoom)
-- can reuse this handler without a dedicated announce-only variant.
--
-- VK_ESCAPE is intentionally not bound here: each game screen's own
-- InputHandler owns Esc (BackButtonClick / OnNo) and install's wrapper
-- falls back to it when the router doesn't consume the key.

SimpleListHandler = {}

local function labelOf(item)
    if item.labelFn then
        local ok, result = pcall(item.labelFn, item._control)
        if not ok then
            Log.error("SimpleListHandler labelFn '"
                .. tostring(item.controlName) .. "' failed: " .. tostring(result))
            return ""
        end
        return result or ""
    end
    return Text.key(item.textKey)
end

local function isNavigable(item)
    return item._control ~= nil and not item._control:IsHidden()
end

local function isActivatable(item)
    return isNavigable(item) and not item._control:IsDisabled()
end

local function tooltipOf(item)
    if item.tooltipFn == nil then return nil end
    local ok, result = pcall(item.tooltipFn, item._control)
    if not ok then
        Log.error("SimpleListHandler tooltipFn '"
            .. tostring(item.controlName) .. "' failed: " .. tostring(result))
        return nil
    end
    if result == nil or result == "" then return nil end
    return tostring(result)
end

local function announceLabel(item)
    local parts = { labelOf(item) }
    if not isActivatable(item) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
    end
    local tip = tooltipOf(item)
    if tip ~= nil then parts[#parts + 1] = tip end
    return table.concat(parts, ", ")
end

local function nextValidIndex(items, start, step)
    return Nav.next(items, start, step, isNavigable)
end

local function speakIndex(self, index)
    local item = self.items[index]
    if item == nil then return end
    SpeechPipeline.speakInterrupt(announceLabel(item))
end

local function moveTo(self, newIndex)
    if newIndex == nil or newIndex == self._index then return end
    self._index = newIndex
    speakIndex(self, newIndex)
end

local function onUp(self)
    moveTo(self, nextValidIndex(self.items, self._index, -1))
end

local function onDown(self)
    moveTo(self, nextValidIndex(self.items, self._index, 1))
end

local function onHome(self)
    moveTo(self, nextValidIndex(self.items, 0, 1))
end

local function onEnd(self)
    moveTo(self, nextValidIndex(self.items, #self.items + 1, -1))
end

local function onEnter(self)
    if #self.items == 0 then return end
    local item = self.items[self._index]
    if item == nil or not isNavigable(item) then
        Log.warn("SimpleListHandler '" .. self.name .. "': Enter on invalid item")
        return
    end
    if not isActivatable(item) then
        SpeechPipeline.speakInterrupt(announceLabel(item))
        return
    end
    -- Engine plays this on mouse clicks; Enter-key activation bypasses that
    -- path, so we play it here to keep the click feel for keyboard users.
    Events.AudioPlay2DSound("AS2D_IF_SELECT")
    local ok, err = pcall(item.activate)
    if not ok then
        Log.error("SimpleListHandler '" .. self.name .. "' activate '"
            .. tostring(item.controlName) .. "' failed: " .. tostring(err))
        return
    end
    -- Post-activate revalidation: if the just-activated control is now hidden
    -- (MultiplayerSelect toggle), advance the cursor and speak the next valid.
    if not isNavigable(item) then
        local next = nextValidIndex(self.items, self._index, 1)
        if next ~= nil then
            self._index = next
            SpeechPipeline.speakQueued(announceLabel(self.items[next]))
        end
    end
end

local function resolvePreamble(self)
    local p = self.preamble
    if p == nil then return nil end
    if type(p) == "function" then
        local ok, result = pcall(p)
        if not ok then
            Log.error("SimpleListHandler '" .. self.name
                .. "' preamble fn failed: " .. tostring(result))
            return nil
        end
        return result
    end
    return p
end

function SimpleListHandler.create(spec)
    assert(type(spec) == "table", "SimpleListHandler.create requires a spec table")
    assert(type(spec.name) == "string" and spec.name ~= "", "spec.name required")
    assert(type(spec.displayName) == "string" and spec.displayName ~= "", "spec.displayName required")
    assert(type(spec.items) == "table", "spec.items required (may be empty)")
    assert(spec.preamble == nil
           or (type(spec.preamble) == "string" and spec.preamble ~= "")
           or type(spec.preamble) == "function",
        "spec.preamble must be a non-empty string or a function if provided")

    local self = {
        name = spec.name,
        displayName = spec.displayName,
        preamble = spec.preamble,
        items = {},
        capturesAllInput = true,
        _index = 1,
    }

    -- Upvalue rather than handler field: only onActivate / onDeactivate /
    -- refresh read it, and it is meaningless for string preambles.
    local lastPreambleText = nil

    for i, item in ipairs(spec.items) do
        assert(type(item.controlName) == "string", "item " .. i .. ".controlName required")
        assert(type(item.textKey) == "string" or type(item.labelFn) == "function",
            "item " .. i .. " needs textKey (string) or labelFn (function)")
        assert(type(item.activate) == "function", "item " .. i .. ".activate required")
        assert(item.tooltipFn == nil or type(item.tooltipFn) == "function",
            "item " .. i .. ".tooltipFn must be a function if provided")
        local resolved = {
            controlName = item.controlName,
            textKey     = item.textKey,
            labelFn     = item.labelFn,
            tooltipFn   = item.tooltipFn,
            activate    = item.activate,
            _control    = Controls[item.controlName],
        }
        if resolved._control == nil then
            Log.warn("SimpleListHandler '" .. self.name .. "': missing control '"
                .. item.controlName .. "' (item permanently invalid)")
        end
        self.items[#self.items + 1] = resolved
    end

    self.bindings = {
        { key = Keys.VK_UP,     mods = 0, description = "Previous item",
          fn = function() onUp(self)    end },
        { key = Keys.VK_DOWN,   mods = 0, description = "Next item",
          fn = function() onDown(self)  end },
        { key = Keys.VK_HOME,   mods = 0, description = "First item",
          fn = function() onHome(self)  end },
        { key = Keys.VK_END,    mods = 0, description = "Last item",
          fn = function() onEnd(self)   end },
        { key = Keys.VK_RETURN, mods = 0, description = "Activate item",
          fn = function() onEnter(self) end },
    }

    function self.onActivate()
        local first = nextValidIndex(self.items, 0, 1)
        self._index = first or 1
        SpeechPipeline.speakInterrupt(self.displayName)
        local preambleText = resolvePreamble(self)
        if preambleText ~= nil and preambleText ~= "" then
            SpeechPipeline.speakQueued(preambleText)
        end
        lastPreambleText = preambleText
        if first ~= nil then
            SpeechPipeline.speakQueued(announceLabel(self.items[first]))
        end
    end

    function self.onDeactivate()
        self._index = 1
        lastPreambleText = nil
    end

    -- Re-evaluate a function preamble and speakInterrupt the result if it
    -- differs from what was last spoken. No-op for string preambles (they
    -- never change) and no-op if the text hasn't changed.
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

-- Wire a screen's ContextPtr to the handler. The per-screen access file
-- captures the game's existing ShowHideHandler / InputHandler as locals
-- before calling in so we can chain them; either may be nil (MainMenu has
-- no game-defined InputHandler, ExitConfirm uses OnShowHide -> caller
-- passes it via spec.priorShowHide).
function SimpleListHandler.install(ContextPtr, spec)
    local handler = SimpleListHandler.create(spec)
    local priorShowHide = spec.priorShowHide
    local priorInput    = spec.priorInput
    -- spec.deferActivate: when a modal transition synchronously exposes a
    -- base screen only to cover it again in the same flow (MainMenu during
    -- EULA -> ModsBrowser accept), the engine fires ShowHide(false) then
    -- ShowHide(true) within one frame. A synchronous push speaks before the
    -- hide cancels it. Deferring the push to the next Update runs both
    -- ShowHide events first, so pendingPush clears before the speech fires.
    -- Routed through TickPump.runOnce so it composes with any other
    -- SetUpdate owner on the Context instead of clobbering it.
    local deferActivate = spec.deferActivate == true
    local pendingPush   = false

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
                Log.error("SimpleListHandler '" .. handler.name
                    .. "' prior ShowHide: " .. tostring(err))
            end
        end
        -- Idempotent clear before re-push. reactivate=false so the handler
        -- beneath doesn't spuriously re-announce during a SystemUpdateUI
        -- re-entry; we're about to push this same handler back on.
        HandlerStack.removeByName(handler.name, false)
        if bIsHide then
            pendingPush = false
            return
        end
        if deferActivate then
            pendingPush = true
            TickPump.install(ContextPtr)
            TickPump.runOnce(runDeferredPush)
        else
            HandlerStack.push(handler)
        end
    end)

    ContextPtr:SetInputHandler(function(msg, wp, lp)
        -- Esc always bypasses our capturesAllInput barrier and routes to the
        -- game's own InputHandler so per-screen Back / OnNo keeps working.
        -- On MainMenu priorInput is nil, so Esc silently returns false.
        if (msg == 256 or msg == 260) and wp == Keys.VK_ESCAPE then
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

-- Reusable handler for the "flat vertical button list" family of screens:
-- Up/Down walk with wrap-around, Home/End jump to edges, Enter activates,
-- capturesAllInput so the barrier contains stray keys, no tick. A per-screen
-- access file declares the item list and calls install() to wire the
-- ContextPtr handlers.
--
-- Item shape:
--   controlName  (string, required) XML ID on Controls; resolved at create()
--   textKey      (string, required) TXT_KEY_* for the spoken label
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
    return Text.key(item.textKey)
end

local function isNavigable(item)
    return item._control ~= nil and not item._control:IsHidden()
end

local function isActivatable(item)
    return isNavigable(item) and not item._control:IsDisabled()
end

local function announceLabel(item)
    if isActivatable(item) then
        return labelOf(item)
    end
    return labelOf(item) .. " " .. Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
end

local function firstValidIndex(items)
    for i = 1, #items do
        if isNavigable(items[i]) then return i end
    end
    return nil
end

-- Walk from `start` in direction `step` (+1 / -1), wrapping, looking for a
-- navigable item. Cap iterations at #items so an all-invalid list terminates
-- instead of spinning.
local function nextValidIndex(items, start, step)
    local n = #items
    if n == 0 then return nil end
    local i = start
    for _ = 1, n do
        i = i + step
        if i > n then i = 1 end
        if i < 1 then i = n end
        if isNavigable(items[i]) then return i end
    end
    return nil
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
    local i = firstValidIndex(self.items)
    if i == nil then return end
    moveTo(self, i)
end

local function onEnd(self)
    local n = #self.items
    for i = n, 1, -1 do
        if isNavigable(self.items[i]) then
            moveTo(self, i)
            return
        end
    end
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
        _lastPreambleText = nil,
    }

    for i, item in ipairs(spec.items) do
        assert(type(item.controlName) == "string", "item " .. i .. ".controlName required")
        assert(type(item.textKey) == "string", "item " .. i .. ".textKey required")
        assert(type(item.activate) == "function", "item " .. i .. ".activate required")
        local resolved = {
            controlName = item.controlName,
            textKey     = item.textKey,
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
        local first = firstValidIndex(self.items)
        self._index = first or 1
        SpeechPipeline.speakInterrupt(self.displayName)
        local preambleText = resolvePreamble(self)
        if preambleText ~= nil and preambleText ~= "" then
            SpeechPipeline.speakQueued(preambleText)
        end
        self._lastPreambleText = preambleText
        if first ~= nil then
            SpeechPipeline.speakQueued(announceLabel(self.items[first]))
        end
    end

    function self.onDeactivate()
        self._index = 1
        self._lastPreambleText = nil
    end

    -- Re-evaluate a function preamble and speakInterrupt the result if it
    -- differs from what was last spoken. No-op for string preambles (they
    -- never change) and no-op if the text hasn't changed.
    function self.refresh()
        if type(self.preamble) ~= "function" then return end
        local text = resolvePreamble(self)
        if text == nil or text == "" then return end
        if text == self._lastPreambleText then return end
        self._lastPreambleText = text
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

    ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit)
        if priorShowHide then
            local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
            if not ok then
                Log.error("SimpleListHandler '" .. handler.name
                    .. "' prior ShowHide: " .. tostring(err))
            end
        end
        -- Idempotent: clears any prior push from a double-show (e.g.
        -- SystemUpdateUI re-entry) before re-pushing.
        HandlerStack.removeByName(handler.name)
        if not bIsHide then
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

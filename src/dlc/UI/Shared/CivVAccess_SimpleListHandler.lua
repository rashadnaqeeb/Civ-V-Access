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
-- Items whose Controls.X is missing at create() are permanently invalid
-- (logged once). Items whose :IsHidden() flips at runtime are transparently
-- skipped. After activate fires, if the just-activated item has flipped
-- hidden (MultiplayerSelect's Standard/Pitboss toggle case) we advance to
-- the next valid entry and speak it so the user gets feedback on the state
-- change.
--
-- VK_ESCAPE is intentionally not bound here: each game screen's own
-- InputHandler owns Esc (BackButtonClick / OnNo) and install's wrapper
-- falls back to it when the router doesn't consume the key.

SimpleListHandler = {}

local function labelOf(item)
    return Text.key(item.textKey)
end

local function isValid(item)
    return item._control ~= nil and not item._control:IsHidden()
end

local function firstValidIndex(items)
    for i = 1, #items do
        if isValid(items[i]) then return i end
    end
    return nil
end

-- Walk from `start` in direction `step` (+1 / -1), wrapping, looking for a
-- valid item. Cap iterations at #items so an all-invalid list terminates
-- instead of spinning.
local function nextValidIndex(items, start, step)
    local n = #items
    if n == 0 then return nil end
    local i = start
    for _ = 1, n do
        i = i + step
        if i > n then i = 1 end
        if i < 1 then i = n end
        if isValid(items[i]) then return i end
    end
    return nil
end

local function speakIndex(self, index)
    local item = self.items[index]
    if item == nil then return end
    SpeechPipeline.speakInterrupt(labelOf(item))
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
        if isValid(self.items[i]) then
            moveTo(self, i)
            return
        end
    end
end

local function onEnter(self)
    local item = self.items[self._index]
    if item == nil or not isValid(item) then
        Log.warn("SimpleListHandler '" .. self.name .. "': Enter on invalid item")
        return
    end
    local ok, err = pcall(item.activate)
    if not ok then
        Log.error("SimpleListHandler '" .. self.name .. "' activate '"
            .. tostring(item.controlName) .. "' failed: " .. tostring(err))
        return
    end
    -- Post-activate revalidation: if the just-activated control is now hidden
    -- (MultiplayerSelect toggle), advance the cursor and speak the next valid.
    if not isValid(item) then
        local next = nextValidIndex(self.items, self._index, 1)
        if next ~= nil and next ~= self._index then
            self._index = next
            SpeechPipeline.speakQueued(labelOf(self.items[next]))
        end
    end
end

function SimpleListHandler.create(spec)
    assert(type(spec) == "table", "SimpleListHandler.create requires a spec table")
    assert(type(spec.name) == "string" and spec.name ~= "", "spec.name required")
    assert(type(spec.items) == "table", "spec.items required")

    local self = {
        name = spec.name,
        displayName = spec.displayName or spec.name,
        items = {},
        capturesAllInput = true,
        _index = 1,
    }

    for i, item in ipairs(spec.items) do
        assert(type(item.controlName) == "string", "item " .. i .. ".controlName required")
        assert(type(item.textKey) == "string", "item " .. i .. ".textKey required")
        assert(type(item.activate) == "function", "item " .. i .. ".activate required")
        local resolved = {
            controlName = item.controlName,
            textKey     = item.textKey,
            activate    = item.activate,
            _control    = Controls and Controls[item.controlName] or nil,
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
        if first ~= nil then
            SpeechPipeline.speakQueued(labelOf(self.items[first]))
        end
    end

    function self.onDeactivate()
        self._index = 1
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

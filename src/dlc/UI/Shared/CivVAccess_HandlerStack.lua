-- LIFO stack of active UI handlers. Top of stack is the currently focused
-- screen; InputRouter walks from the top. State lives on the proxy-owned
-- civvaccess_shared table so every Context sandbox references the same stack.
--
-- Handler shape (a plain Lua table pushed onto the stack):
--   name               (string, required) unique-ish; used by removeByName and logs.
--   capturesAllInput   (bool, default false) barrier for InputRouter's top-down
--                      walk. Stays false for almost all handlers. Set true only
--                      for modal-like contexts (popups, confirmations, overlays)
--                      that should swallow unbound keys.
--   bindings           (array, optional) {key, mods, fn, description} entries.
--                      The handler owns its bindings; there is no central registry.
--   helpEntries        (array, required when the handler has bindings) authored
--                      {keyLabel, description} entries for the ? help overlay.
--                      Handlers with no user-visible bindings (Baseline, transient
--                      subs) should set this to an empty {} to opt in explicitly.
--                      keyLabel is a TXT_KEY for a merged, human-readable chord
--                      label ("Up/Down", "Ctrl+Shift+Left/Right"); description
--                      is a TXT_KEY. See CivVAccess_Help.lua and
--                      BaseMenuHelp's MenuHelpEntries / ListNavHelpEntries
--                      templates.
--   onActivate         (fn(self), optional) fired on push / re-exposure
--                      (becomes top of stack).
--   onSuspend          (fn(self), optional) fired when this handler stops being
--                      the top because something is pushed above it. Distinct
--                      from onDeactivate: the handler is still on the stack and
--                      will receive onActivate again when re-exposed. Use for
--                      pausing background work that only makes sense while the
--                      handler is the input target (looping audio, periodic
--                      polling). onDeactivate is for cleanup that runs when
--                      the handler is being removed.
--   onDeactivate       (fn(self), optional) fired on removal from the stack.
--   tick               (fn(self), optional) called every frame by TickPump on
--                      the active handler only.
--   beaconsTransparent (bool, default false) handler is treated as pass-
--                      through by Beacons.refresh's top-down stack walk.
--                      For cursor-still-on-map flows like the Tab unit-
--                      action menu and the target / strike / gift pickers
--                      where the user is still on the world map and the
--                      audio bookmarks should keep playing despite a non-
--                      Baseline handler being on top.
--
-- Push when a screen opens; removeByName when it closes.

HandlerStack = {}

civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.stack = civvaccess_shared.stack or {}
local _shared = civvaccess_shared

-- Mutation listener for stack-driven side effects (currently Beacons.
-- refresh, which evaluates the audibility policy). Stored on the shared
-- table -- not on HandlerStack itself -- because every Context that
-- includes CivVAccess_HandlerStack gets its own HandlerStack global, so
-- a per-Context field would only fire for mutations from the Context
-- that registered the listener. civvaccess_shared is the proxy-injected
-- cross-Context bridge; storing here lets a push from CityView /
-- ChooseProductionPopup / etc. also reach the listener registered by
-- Beacons in WorldView. Single-listener slot rather than a registry; if
-- a second subscriber ever materializes, change to a table and append-
-- only.
function HandlerStack.setOnMutated(fn)
    _shared.onMutated = fn
end

local function notifyMutated()
    local fn = _shared.onMutated
    if type(fn) == "function" then
        Log.tryCall("HandlerStack.onMutated", fn)
    end
end

local function invoke(handler, methodName)
    local fn = handler[methodName]
    if type(fn) ~= "function" then
        return
    end
    local ok, err = pcall(fn, handler)
    if not ok then
        Log.error("HandlerStack " .. methodName .. " failed on '" .. tostring(handler.name) .. "': " .. tostring(err))
    end
    return ok
end

-- Constructor for a single binding entry. Handlers import this as
-- `local bind = HandlerStack.bind` so call sites read as bind(key, mods, fn, desc).
function HandlerStack.bind(key, mods, fn, description)
    return { key = key, mods = mods, fn = fn, description = description }
end

-- MOD_ALT bit-mask value mirrored from individual handlers (Civ V's modifier
-- mask: 1=Shift, 2=Ctrl, 4=Alt). Hardcoded here so the shared block helper
-- below doesn't have to take it as a parameter.
local MOD_ALT = 4
local function noop() end

-- Append Alt-blocked direct-move and quick-action no-op bindings to a
-- handler's `bindings` array. Used by interface modes that need to suppress
-- Baseline's Alt+QAZEDC direct-move and Alt+letter quick-action bindings
-- while a target / strike / gift picker is live -- e.g. UnitTargetMode,
-- GiftMode, CityRangeStrikeMode. Without these blocks, a stray Alt+key
-- during target mode commits a movement / fortify / pillage on the actor
-- and fights the picker.
--
-- opts:
--   directMove   bool. Block Q,E,A,D,Z,C (the 6 hex-direction keys).
--                Default true for all three callers.
--   quickActions bool. Block F,S,W,H,P,R,U,VK_SPACE (sleep / sentry / wake /
--                heal / pillage / ranged / upgrade / skip turn). Set by
--                UnitTargetMode and GiftMode; CityRangeStrikeMode leaves
--                these unblocked.
function HandlerStack.appendAltBlocks(bindings, opts)
    opts = opts or {}
    if opts.directMove ~= false then
        bindings[#bindings + 1] = HandlerStack.bind(Keys.Q, MOD_ALT, noop, "Block direct-move NW")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.E, MOD_ALT, noop, "Block direct-move NE")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.A, MOD_ALT, noop, "Block direct-move W")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.D, MOD_ALT, noop, "Block direct-move E")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.Z, MOD_ALT, noop, "Block direct-move SW")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.C, MOD_ALT, noop, "Block direct-move SE")
    end
    if opts.quickActions then
        bindings[#bindings + 1] = HandlerStack.bind(Keys.F, MOD_ALT, noop, "Block sleep/fortify")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.S, MOD_ALT, noop, "Block sentry")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.W, MOD_ALT, noop, "Block wake/cancel")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.H, MOD_ALT, noop, "Block heal")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.P, MOD_ALT, noop, "Block pillage")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.R, MOD_ALT, noop, "Block ranged attack")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.U, MOD_ALT, noop, "Block upgrade")
        bindings[#bindings + 1] = HandlerStack.bind(Keys.VK_SPACE, MOD_ALT, noop, "Block skip turn")
    end
end

function HandlerStack._reset()
    _shared.stack = {}
end

-- Detect whether a handler's owning Context env has been wiped. The probe
-- is a closure captured in the handler's home env at create time; if that
-- env's globals are nil (the case after a skin-set transition unloads the
-- Context, e.g. front-end-to-in-game on game start, or load-game-from-game
-- wiping in-game Contexts), the probe returns nil/false and we treat the
-- handler as dead. Handlers without a probe are assumed alive (subs that
-- aren't BaseMenu-built, like Help / per-screen pickers, opt out by
-- omission).
local function isDeadEnv(handler)
    if handler == nil then
        return false
    end
    local probe = handler._envProbe
    if type(probe) ~= "function" then
        return false
    end
    local ok, alive = pcall(probe)
    return not (ok and alive)
end

-- Walk the stack top-to-bottom and remove any entry whose env probe says
-- the owning Context's env has been wiped. Used at LoadScreenClose to
-- evict front-end handlers stranded by the skin transition (WaitingForPlayers,
-- LoadScreen, etc.) before in-game seating runs, and at the start of every
-- InputRouter dispatch as defense-in-depth in case the wipe lands after
-- LoadScreenClose. onDeactivate is intentionally NOT invoked: it is itself
-- a closure in the dead env and would throw on its first global access.
function HandlerStack.purgeDeadEnv()
    local removed = 0
    for i = #_shared.stack, 1, -1 do
        local h = _shared.stack[i]
        if isDeadEnv(h) then
            table.remove(_shared.stack, i)
            removed = removed + 1
            Log.warn(
                "HandlerStack.purgeDeadEnv: evicted dead-env handler '"
                    .. tostring(h.name)
                    .. "' (depth="
                    .. #_shared.stack
                    .. ")"
            )
        end
    end
    return removed
end

function HandlerStack.count()
    return #_shared.stack
end

function HandlerStack.active()
    return _shared.stack[#_shared.stack]
end

function HandlerStack.at(i)
    return _shared.stack[i]
end

-- Warn when a handler exposes bindings but forgot to declare helpEntries
-- (an empty table opts out cleanly; nil is treated as "the author forgot"
-- and the ? help overlay won't list the handler's keys).
local function warnIfMissingHelpEntries(handler, callerName)
    if handler.helpEntries == nil and type(handler.bindings) == "table" and #handler.bindings > 0 then
        Log.warn(
            "HandlerStack."
                .. callerName
                .. ": '"
                .. tostring(handler.name)
                .. "' has bindings but no helpEntries; ? help will not list it."
                .. " Set helpEntries (or an explicit {}) to opt in."
        )
    end
end

-- Fire onActivate when a handler becomes the new top. Returns false (and
-- logs) if the callback throws, so the caller can refuse the push and
-- avoid leaving a half-installed handler on the stack.
local function fireOnActivate(handler, callerName, abortVerb)
    local fn = handler.onActivate
    if type(fn) ~= "function" then
        return true
    end
    local ok, err = pcall(fn, handler)
    if not ok then
        Log.error(
            "HandlerStack."
                .. callerName
                .. " onActivate failed on '"
                .. tostring(handler.name)
                .. "': "
                .. tostring(err)
                .. " (handler not "
                .. abortVerb
                .. ")"
        )
        return false
    end
    return true
end

function HandlerStack.push(handler)
    if handler == nil then
        Log.warn("HandlerStack.push: nil handler")
        return false
    end
    warnIfMissingHelpEntries(handler, "push")
    if not fireOnActivate(handler, "push", "pushed") then
        return false
    end
    -- Suspend the previously-top handler before the new one shadows it.
    -- onSuspend fires after the new handler's onActivate has succeeded so
    -- a refused push (onActivate threw) doesn't strand the previous top
    -- in a half-suspended state.
    local prevTop = _shared.stack[#_shared.stack]
    if prevTop ~= nil then
        invoke(prevTop, "onSuspend")
    end
    _shared.stack[#_shared.stack + 1] = handler
    Log.debug("HandlerStack.push '" .. tostring(handler.name) .. "' (depth=" .. #_shared.stack .. ")")
    notifyMutated()
    return true
end

-- Insert a handler at a specific stack position. idx 1 is the bottom; idx
-- equal to count()+1 is the top and is equivalent to push. onActivate fires
-- only when the inserted handler becomes the new top -- inserting below the
-- current top leaves the active handler unchanged, so no announcement.
--
-- Used by Boot to seat Baseline / Scanner at the floor of the in-game stack
-- without burying any popup (PlayerChange in hotseat) that pushed itself
-- before LoadScreenClose fired.
function HandlerStack.insertAt(handler, idx)
    if handler == nil then
        Log.warn("HandlerStack.insertAt: nil handler")
        return false
    end
    warnIfMissingHelpEntries(handler, "insertAt")
    local n = #_shared.stack
    if type(idx) ~= "number" or idx < 1 or idx > n + 1 then
        Log.warn(
            "HandlerStack.insertAt: idx out of range ("
                .. tostring(idx)
                .. ", stack size "
                .. n
                .. ") for '"
                .. tostring(handler.name)
                .. "'"
        )
        return false
    end
    if idx == n + 1 and not fireOnActivate(handler, "insertAt", "inserted") then
        return false
    end
    -- Same suspend rule as push: when the inserted handler becomes the
    -- new top, the previous top gets onSuspend. Insertions below the top
    -- don't change who is responsible for input, so no suspend fires.
    if idx == n + 1 and n > 0 then
        invoke(_shared.stack[n], "onSuspend")
    end
    table.insert(_shared.stack, idx, handler)
    Log.debug(
        "HandlerStack.insertAt '" .. tostring(handler.name) .. "' (idx=" .. idx .. ", depth=" .. #_shared.stack .. ")"
    )
    notifyMutated()
    return true
end

function HandlerStack.pop()
    local n = #_shared.stack
    if n == 0 then
        Log.warn("HandlerStack.pop: empty stack")
        return nil
    end
    local top = _shared.stack[n]
    _shared.stack[n] = nil
    invoke(top, "onDeactivate")
    Log.debug("HandlerStack.pop '" .. tostring(top.name) .. "' (depth=" .. #_shared.stack .. ")")
    local newTop = _shared.stack[#_shared.stack]
    if newTop ~= nil then
        invoke(newTop, "onActivate")
    end
    notifyMutated()
    return top
end

function HandlerStack.replace(handler)
    local n = #_shared.stack
    if n > 0 then
        local top = _shared.stack[n]
        _shared.stack[n] = nil
        invoke(top, "onDeactivate")
        Log.debug("HandlerStack.replace '" .. tostring(top.name) .. "' (depth=" .. #_shared.stack .. ")")
    end
    return HandlerStack.push(handler)
end

function HandlerStack.popAbove(target)
    local found = false
    for i = 1, #_shared.stack do
        if _shared.stack[i] == target then
            found = true
            -- Pop everything above i without reactivating intermediates.
            for j = #_shared.stack, i + 1, -1 do
                local h = _shared.stack[j]
                _shared.stack[j] = nil
                invoke(h, "onDeactivate")
                Log.debug("HandlerStack.popAbove '" .. tostring(h.name) .. "' (depth=" .. #_shared.stack .. ")")
            end
            -- Target is now the top and is (re)exposed.
            invoke(_shared.stack[i], "onActivate")
            notifyMutated()
            break
        end
    end
    return found
end

-- reactivate defaults true. Pass false when the caller is about to push
-- something (BaseMenu.install's idempotent clear before repush):
-- firing onActivate on the handler underneath would spuriously announce a
-- screen the user is about to be pulled off of.
function HandlerStack.removeByName(name, reactivate)
    if reactivate == nil then
        reactivate = true
    end
    for i = #_shared.stack, 1, -1 do
        if _shared.stack[i].name == name then
            local h = _shared.stack[i]
            local wasTop = (i == #_shared.stack)
            table.remove(_shared.stack, i)
            invoke(h, "onDeactivate")
            Log.debug("HandlerStack.removeByName '" .. tostring(h.name) .. "' (depth=" .. #_shared.stack .. ")")
            if wasTop and reactivate then
                local newTop = _shared.stack[#_shared.stack]
                if newTop ~= nil then
                    invoke(newTop, "onActivate")
                end
            end
            notifyMutated()
            return true
        end
    end
    return false
end

-- Drain edit-mode subs above the named handler by invoking each sub's plain-
-- Esc binding (which runs the sub's commit-cancel exit path), then remove
-- the named handler. For BaseMenu hosts that can have BaseMenuEditMode subs
-- pushed above them, where closing the host without first running the sub's
-- exit would orphan EditMode state (RegisterCallback still wrapping the
-- EditBox, _editMode flag still set on the dead sub). Falls back to a hard
-- pop if a sub has no plain-Esc binding or if its binding throws -- without
-- the fallback the inner loop would never advance past the sub.
--
-- Returns true when the named handler was found and removed; false when
-- it isn't on the stack (caller treats false as "already closed", which is
-- how toggle-pattern callers detect they should open instead of close).
function HandlerStack.drainAndRemove(name, reactivate)
    if reactivate == nil then
        reactivate = true
    end
    for i = #_shared.stack, 1, -1 do
        if _shared.stack[i].name == name then
            while #_shared.stack > i do
                local top = _shared.stack[#_shared.stack]
                local escBinding
                if type(top.bindings) == "table" then
                    for _, b in ipairs(top.bindings) do
                        if b.key == Keys.VK_ESCAPE and (b.mods or 0) == 0 then
                            escBinding = b
                            break
                        end
                    end
                end
                if escBinding ~= nil then
                    if
                        not Log.tryCall(
                            "HandlerStack.drainAndRemove: sub '" .. tostring(top.name) .. "' Esc",
                            escBinding.fn
                        )
                    then
                        HandlerStack.pop()
                    end
                else
                    HandlerStack.pop()
                end
            end
            HandlerStack.removeByName(name, reactivate)
            return true
        end
    end
    return false
end

function HandlerStack.deactivateAll()
    for i = #_shared.stack, 1, -1 do
        local h = _shared.stack[i]
        _shared.stack[i] = nil
        invoke(h, "onDeactivate")
    end
    notifyMutated()
end

function HandlerStack.clear()
    _shared.stack = {}
    notifyMutated()
end

-- Always-on help entries appended at the bottom of every collected list.
-- For mod-wide hotkeys reachable at every depth of the stack. Authored as
-- {keyLabel, description} TXT_KEYs.
HandlerStack.commonHelpEntries = {
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_F12",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_OPEN_SETTINGS",
    },
    {
        keyLabel = "TXT_KEY_CIVVACCESS_HELP_KEY_CTRL_SHIFT_F12",
        description = "TXT_KEY_CIVVACCESS_HELP_DESC_TOGGLE_MUTE",
    },
}

-- Walk the stack top-to-bottom (mirroring InputRouter's dispatch walk),
-- collecting authored helpEntries from each reachable handler. Stops after
-- the first capturesAllInput handler (inclusive). Deduplicates by the
-- keyLabel string -- the topmost handler wins, so a lower handler's
-- different meaning for the same chord is dropped (it wouldn't fire anyway).
-- Convention: keyLabels must be canonically merged ("Up/Down" not "Up"),
-- otherwise dedupe can't collapse equivalent entries from stacked handlers.
function HandlerStack.collectHelpEntries()
    local seen = {}
    local out = {}
    for i = #_shared.stack, 1, -1 do
        local h = _shared.stack[i]
        if type(h.helpEntries) == "table" then
            for _, e in ipairs(h.helpEntries) do
                local k = tostring(e.keyLabel)
                if not seen[k] then
                    seen[k] = true
                    out[#out + 1] = e
                end
            end
        end
        if h.capturesAllInput then
            break
        end
    end
    for _, e in ipairs(HandlerStack.commonHelpEntries) do
        local k = tostring(e.keyLabel)
        if not seen[k] then
            seen[k] = true
            out[#out + 1] = e
        end
    end
    return out
end

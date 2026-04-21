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
--   onActivate         (fn(self), optional) fired on push / re-exposure.
--   onDeactivate       (fn(self), optional) fired on removal.
--   tick               (fn(self), optional) called every frame by TickPump on
--                      the active handler only.
--
-- Push when a screen opens; removeByName when it closes.

HandlerStack = {}

civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.stack = civvaccess_shared.stack or {}
local _shared = civvaccess_shared

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

function HandlerStack._reset()
    _shared.stack = {}
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

function HandlerStack.push(handler)
    if handler == nil then
        Log.warn("HandlerStack.push: nil handler")
        return false
    end
    if handler.helpEntries == nil and type(handler.bindings) == "table" and #handler.bindings > 0 then
        Log.warn(
            "HandlerStack.push: '"
                .. tostring(handler.name)
                .. "' has bindings but no helpEntries; ? help will not list it."
                .. " Set helpEntries (or an explicit {}) to opt in."
        )
    end
    local fn = handler.onActivate
    if type(fn) == "function" then
        local ok, err = pcall(fn, handler)
        if not ok then
            Log.error(
                "HandlerStack.push onActivate failed on '"
                    .. tostring(handler.name)
                    .. "': "
                    .. tostring(err)
                    .. " (handler not pushed)"
            )
            return false
        end
    end
    _shared.stack[#_shared.stack + 1] = handler
    Log.debug("HandlerStack.push '" .. tostring(handler.name) .. "' (depth=" .. #_shared.stack .. ")")
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
                Log.debug(
                    "HandlerStack.popAbove '" .. tostring(h.name) .. "' (depth=" .. #_shared.stack .. ")"
                )
            end
            -- Target is now the top and is (re)exposed.
            invoke(_shared.stack[i], "onActivate")
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
            Log.debug(
                "HandlerStack.removeByName '" .. tostring(h.name) .. "' (depth=" .. #_shared.stack .. ")"
            )
            if wasTop and reactivate then
                local newTop = _shared.stack[#_shared.stack]
                if newTop ~= nil then
                    invoke(newTop, "onActivate")
                end
            end
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
end

function HandlerStack.clear()
    _shared.stack = {}
end

-- Always-on help entries appended at the bottom of every collected list.
-- Empty for now; reserved for mod-wide hotkeys that exist at every depth of
-- the stack (cross-screen toggles, config, etc. — see ONI's F12/Ctrl+Shift+
-- F12 common entries). Authored as {keyLabel, description} TXT_KEYs.
HandlerStack.commonHelpEntries = {}

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

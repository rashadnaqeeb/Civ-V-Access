-- LIFO stack of active UI handlers. Top of stack is the currently focused
-- screen; InputRouter walks from the top. State lives on the proxy-owned
-- civvaccess_shared table so every Context sandbox references the same
-- stack within a given lua_State (one per phase: front-end / in-game).

HandlerStack = {}

civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.stack       = civvaccess_shared.stack       or {}
civvaccess_shared.pushFrames  = civvaccess_shared.pushFrames  or {}
civvaccess_shared.pushCounter = civvaccess_shared.pushCounter or 0
local _shared = civvaccess_shared

local function invoke(handler, methodName)
    local fn = handler[methodName]
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, handler)
    if not ok then
        Log.error("HandlerStack " .. methodName .. " failed on '"
            .. tostring(handler.name) .. "': " .. tostring(err))
    end
    return ok
end

function HandlerStack._reset()
    _shared.stack = {}
    _shared.pushFrames = {}
    _shared.pushCounter = 0
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
    local prevTop = _shared.stack[#_shared.stack]
    if prevTop ~= nil then
        -- The previous top loses focus when covered. No onDeactivate here;
        -- it only fires on removal. This mirrors ONI's model.
    end
    local fn = handler.onActivate
    if type(fn) == "function" then
        local ok, err = pcall(fn, handler)
        if not ok then
            Log.error("HandlerStack.push onActivate failed on '"
                .. tostring(handler.name) .. "': " .. tostring(err)
                .. " (handler not pushed)")
            return false
        end
    end
    _shared.pushCounter = _shared.pushCounter + 1
    _shared.stack[#_shared.stack + 1] = handler
    _shared.pushFrames[#_shared.pushFrames + 1] = _shared.pushCounter
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
    _shared.pushFrames[n] = nil
    invoke(top, "onDeactivate")
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
        _shared.pushFrames[n] = nil
        invoke(top, "onDeactivate")
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
                _shared.pushFrames[j] = nil
                invoke(h, "onDeactivate")
            end
            -- Target is now the top and is (re)exposed.
            invoke(_shared.stack[i], "onActivate")
            break
        end
    end
    return found
end

function HandlerStack.removeByName(name)
    for i = #_shared.stack, 1, -1 do
        if _shared.stack[i].name == name then
            local h = _shared.stack[i]
            local wasTop = (i == #_shared.stack)
            table.remove(_shared.stack, i)
            table.remove(_shared.pushFrames, i)
            invoke(h, "onDeactivate")
            if wasTop then
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
        _shared.pushFrames[i] = nil
        invoke(h, "onDeactivate")
    end
end

function HandlerStack.clear()
    _shared.stack = {}
    _shared.pushFrames = {}
end

function HandlerStack.collectHelpEntries()
    local seen = {}
    local out = {}
    local function keyOf(e)
        return tostring(e.key) .. ":" .. tostring(e.mods or 0)
    end
    for i = #_shared.stack, 1, -1 do
        local h = _shared.stack[i]
        local entries = h.helpEntries
        if entries == nil and type(h.bindings) == "table" then
            entries = h.bindings
        end
        if type(entries) == "table" then
            for _, e in ipairs(entries) do
                local k = keyOf(e)
                if not seen[k] then
                    seen[k] = true
                    out[#out + 1] = e
                end
            end
        end
        if h.capturesAllInput then break end
    end
    return out
end

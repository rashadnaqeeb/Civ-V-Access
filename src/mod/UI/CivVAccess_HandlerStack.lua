-- LIFO stack of active UI handlers. Top of stack is the currently focused
-- screen; InputRouter walks from the top. State is per-Context until the
-- proxy shared-state table lands (see followup plan).

HandlerStack = {}

local _stack = {}
local _pushFrames = {}
local _pushCounter = 0

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
    _stack = {}
    _pushFrames = {}
    _pushCounter = 0
end

function HandlerStack.count()
    return #_stack
end

function HandlerStack.active()
    return _stack[#_stack]
end

function HandlerStack.at(i)
    return _stack[i]
end

function HandlerStack.push(handler)
    if handler == nil then
        Log.warn("HandlerStack.push: nil handler")
        return false
    end
    local prevTop = _stack[#_stack]
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
    _pushCounter = _pushCounter + 1
    _stack[#_stack + 1] = handler
    _pushFrames[#_pushFrames + 1] = _pushCounter
    Log.debug("HandlerStack.push '" .. tostring(handler.name) .. "' (depth=" .. #_stack .. ")")
    return true
end

function HandlerStack.pop()
    local n = #_stack
    if n == 0 then
        Log.warn("HandlerStack.pop: empty stack")
        return nil
    end
    local top = _stack[n]
    _stack[n] = nil
    _pushFrames[n] = nil
    invoke(top, "onDeactivate")
    local newTop = _stack[#_stack]
    if newTop ~= nil then
        invoke(newTop, "onActivate")
    end
    return top
end

function HandlerStack.replace(handler)
    local n = #_stack
    if n > 0 then
        local top = _stack[n]
        _stack[n] = nil
        _pushFrames[n] = nil
        invoke(top, "onDeactivate")
    end
    return HandlerStack.push(handler)
end

function HandlerStack.popAbove(target)
    local found = false
    for i = 1, #_stack do
        if _stack[i] == target then
            found = true
            -- Pop everything above i without reactivating intermediates.
            for j = #_stack, i + 1, -1 do
                local h = _stack[j]
                _stack[j] = nil
                _pushFrames[j] = nil
                invoke(h, "onDeactivate")
            end
            -- Target is now the top and is (re)exposed.
            invoke(_stack[i], "onActivate")
            break
        end
    end
    return found
end

function HandlerStack.removeByName(name)
    for i = #_stack, 1, -1 do
        if _stack[i].name == name then
            local h = _stack[i]
            local wasTop = (i == #_stack)
            table.remove(_stack, i)
            table.remove(_pushFrames, i)
            invoke(h, "onDeactivate")
            if wasTop then
                local newTop = _stack[#_stack]
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
    for i = #_stack, 1, -1 do
        local h = _stack[i]
        _stack[i] = nil
        _pushFrames[i] = nil
        invoke(h, "onDeactivate")
    end
end

function HandlerStack.clear()
    _stack = {}
    _pushFrames = {}
end

function HandlerStack.collectHelpEntries()
    local seen = {}
    local out = {}
    local function keyOf(e)
        return tostring(e.key) .. ":" .. tostring(e.mods or 0)
    end
    for i = #_stack, 1, -1 do
        local h = _stack[i]
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

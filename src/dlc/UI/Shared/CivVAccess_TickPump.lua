-- Per-frame pump wired to ContextPtr:SetUpdate. Owns the monotonic frame
-- counter and forwards tick() to the active handler if it defines one.

TickPump = {}

local _frame = 0
local _installed = false

function TickPump._reset()
    _frame = 0
    _installed = false
end

function TickPump.frame()
    return _frame
end

function TickPump.tick()
    _frame = _frame + 1
    local h = HandlerStack.active()
    if h == nil then return end
    local fn = h.tick
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, h)
    if not ok then
        Log.error("TickPump tick failed on '" .. tostring(h.name)
            .. "': " .. tostring(err))
    end
end

function TickPump.install(ctx)
    if _installed then
        Log.warn("TickPump.install called twice; ignoring")
        return
    end
    _installed = true
    ctx:SetUpdate(TickPump.tick)
end

-- Per-frame pump wired to ContextPtr:SetUpdate. Owns the monotonic frame
-- counter, drains the one-shot queue, and forwards tick() to the active
-- handler if it defines one.
--
-- TickPump must be the sole owner of SetUpdate on any Context where per-
-- frame work happens (SetUpdate is replace-semantics; a second caller
-- silently unhooks the first). Callers that need a one-shot deferred run
-- schedule through TickPump.runOnce rather than calling SetUpdate directly.

TickPump = {}

local _frame = 0
local _oneShots = {}

function TickPump._reset()
    _frame = 0
    _oneShots = {}
end

function TickPump.frame()
    return _frame
end

-- Queue fn to run on the next tick, then be discarded. Idempotent wrt
-- installation -- caller must have called TickPump.install on at least one
-- currently-updating Context for the queue to drain.
function TickPump.runOnce(fn)
    _oneShots[#_oneShots + 1] = fn
end

function TickPump.tick()
    _frame = _frame + 1
    if #_oneShots > 0 then
        -- Snapshot then clear so a callback that itself calls runOnce
        -- queues for the next tick, not this one.
        local snapshot = _oneShots
        _oneShots = {}
        for _, fn in ipairs(snapshot) do
            local ok, err = pcall(fn)
            if not ok then
                Log.error("TickPump.runOnce callback failed: " .. tostring(err))
            end
        end
    end
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

-- Re-appliable: SetUpdate is replace-semantics (the engine exposes ClearUpdate
-- as a counterpart), so re-calling install on a new ContextPtr after a Context
-- rebuild rewires the pump cleanly. No idempotency guard.
function TickPump.install(ctx)
    ctx:SetUpdate(TickPump.tick)
end

-- Per-frame pump wired to ContextPtr:SetUpdate. Owns the monotonic frame
-- counter, drains the one-shot queue, and forwards tick() to the active
-- handler if it defines one.
--
-- State lives on civvaccess_shared because Civ V Contexts are fenv-sandboxed:
-- each Context that include()s this file gets its own _frame / _oneShots
-- locals otherwise, and a runOnce() queued from one Context would never
-- drain when another Context's SetUpdate fires tick(). Keeping the frame
-- counter and queue shared means any pumping Context drains callbacks
-- scheduled from any other Context.
--
-- TickPump must be the sole owner of SetUpdate on any Context where it is
-- installed (SetUpdate is replace-semantics; a second caller silently
-- unhooks the first). Installing on multiple Contexts is safe: each
-- Context's SetUpdate calls tick(), the shared queue drains on whichever
-- fires first, and the drain clears the queue so later ticks no-op.

TickPump = {}

civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.tickFrame = civvaccess_shared.tickFrame or 0
civvaccess_shared.tickOneShots = civvaccess_shared.tickOneShots or {}

function TickPump._reset()
    civvaccess_shared.tickFrame = 0
    civvaccess_shared.tickOneShots = {}
end

function TickPump.frame()
    return civvaccess_shared.tickFrame
end

-- Queue fn to run on the next tick, then be discarded. Idempotent wrt
-- installation -- caller must have called TickPump.install on at least one
-- currently-updating Context for the queue to drain.
function TickPump.runOnce(fn)
    local shots = civvaccess_shared.tickOneShots
    shots[#shots + 1] = fn
end

function TickPump.tick()
    civvaccess_shared.tickFrame = civvaccess_shared.tickFrame + 1
    local shots = civvaccess_shared.tickOneShots
    if #shots > 0 then
        -- Snapshot then clear so a callback that itself calls runOnce
        -- queues for the next tick, not this one.
        civvaccess_shared.tickOneShots = {}
        for _, fn in ipairs(shots) do
            local ok, err = pcall(fn)
            if not ok then
                Log.error("TickPump.runOnce callback failed: " .. tostring(err))
            end
        end
    end
    local h = HandlerStack.active()
    if h == nil then
        return
    end
    local fn = h.tick
    if type(fn) ~= "function" then
        return
    end
    local ok, err = pcall(fn, h)
    if not ok then
        Log.error("TickPump tick failed on '" .. tostring(h.name) .. "': " .. tostring(err))
    end
end

-- Re-appliable: SetUpdate is replace-semantics (the engine exposes ClearUpdate
-- as a counterpart), so re-calling install on a new ContextPtr after a Context
-- rebuild rewires the pump cleanly. No idempotency guard.
function TickPump.install(ctx)
    ctx:SetUpdate(TickPump.tick)
end

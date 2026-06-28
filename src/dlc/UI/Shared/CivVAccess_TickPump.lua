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
--
-- Subscribers are named, persistent per-tick callbacks that run on every
-- tick regardless of which HandlerStack handler is active. Unlike the
-- active-handler tick (which only fires for whatever is on top of the
-- stack), a subscriber keeps running while the user is off in a menu /
-- screen Context. Use it for background polling that must not stop when the
-- player navigates away (the MP end-turn reminder). The registry is keyed by
-- name on civvaccess_shared so it survives the load-from-game env wipe and a
-- fresh registration under the same name replaces the prior game's dead-env
-- closure. Because TickPump can be installed on more than one Context, a
-- subscriber may run more than once per frame -- keep them idempotent (gate
-- side effects on real wall-clock time, not on call count).

TickPump = {}

civvaccess_shared = civvaccess_shared or {}
civvaccess_shared.tickFrame = civvaccess_shared.tickFrame or 0
civvaccess_shared.tickOneShots = civvaccess_shared.tickOneShots or {}
civvaccess_shared.tickSubscribers = civvaccess_shared.tickSubscribers or {}

function TickPump._reset()
    civvaccess_shared.tickFrame = 0
    civvaccess_shared.tickOneShots = {}
    civvaccess_shared.tickSubscribers = {}
end

-- Register (or replace) a persistent per-tick callback under name. Replacing
-- by name is what lets a Context re-include after load-from-game swap in a
-- fresh closure without stacking a dead one.
function TickPump.subscribe(name, fn)
    civvaccess_shared.tickSubscribers[name] = fn
end

function TickPump.unsubscribe(name)
    civvaccess_shared.tickSubscribers[name] = nil
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
            Log.tryCall("TickPump.runOnce callback", fn)
        end
    end
    for name, fn in pairs(civvaccess_shared.tickSubscribers) do
        Log.tryCall("TickPump subscriber '" .. tostring(name) .. "'", fn)
    end
    local h = HandlerStack.active()
    if h == nil then
        return
    end
    local fn = h.tick
    if type(fn) ~= "function" then
        return
    end
    Log.tryCall("TickPump tick on '" .. tostring(h.name) .. "'", fn, h)
end

-- Re-appliable: SetUpdate is replace-semantics (the engine exposes ClearUpdate
-- as a counterpart), so re-calling install on a new ContextPtr after a Context
-- rebuild rewires the pump cleanly. No idempotency guard.
function TickPump.install(ctx)
    ctx:SetUpdate(TickPump.tick)
end

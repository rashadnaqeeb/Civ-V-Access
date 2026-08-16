-- Dispatcher for the engine hooks the fork defers instead of raising on the
-- game-core thread.
--
-- Why the indirection. Civ V runs the simulation on the game-core thread and
-- all UI Lua on the main thread, and the two locks involved (the game-core
-- mutex, the host's script lock) are taken in opposite orders by the two
-- directions of traffic. A Lua binding called from the UI thread takes the
-- script lock then the game-core mutex; a Lua callout made from inside the
-- simulation takes them the other way round. When both happen at once the
-- process deadlocks outright -- the UI thread stops pumping, Windows reports
-- "not responding", and in multiplayer every other player stalls behind the
-- wedged client until it is killed. Confirmed from paired process dumps of a
-- hung session; the full analysis is in docs/llm-docs/mp-deadlock.md.
--
-- The fork's two highest-frequency hooks (plot revealed, unit moved) fired
-- from the innermost loops of the simulation, thousands of times a turn, so
-- they were the dominant source of that collision. They now push onto a queue
-- in the DLL and this module drains it from a TickPump subscriber, on the
-- thread that is allowed to be in Lua. Handlers are called with exactly the
-- arguments the hook used to raise, so consumers did not change shape.
--
-- Register through EngineEvents.on rather than Log.installEvent(GameEvents,
-- ...) for any hook listed in DEFERRED below. For every other hook keep using
-- Log.installEvent: the rare ones still raise synchronously because their
-- handlers read engine objects that are destroyed moments later (a nuked city
-- is killed immediately after its hook fires), and deferring those would hand
-- Lua dead handles.
--
-- Degraded engines. An engine whose fork predates the queue -- a stock DLL, a
-- partner's sighted install, a Community-Patch fork not yet re-pinned --
-- reports no drain binding, and on() falls back to registering the handler
-- straight on GameEvents. Behaviour there is exactly what it was before.
--
-- Ordering. The queue is FIFO and the drain runs every tick, so a burst
-- arrives in simulation order, at most a frame late. Consumers of these two
-- hooks already buffer across a tick before speaking, so nothing downstream
-- notices the delay.

EngineEvents = {}

local SUBSCRIBER_NAME = "EngineEvents"

-- Hooks the fork queues. A name absent from this set has no queued path, so
-- on() must not be used for it; the assertion in on() catches that.
local DEFERRED = {
    CivVAccessPlotRevealed = true,
    CivVAccessUnitMoved = true,
}

-- name -> array of handlers. Module-local, so the load-from-game env wipe
-- clears it and every consumer's installListeners re-registers against the
-- live env -- the same reasoning as the no-install-once-guards rule in
-- CivVAccess_Boot.lua.
local _handlers = {}

-- True when this session is actually draining. Captured once per boot rather
-- than per event so a single log line explains which mode we are in.
local _deferring = false

-- Register a handler for a deferred hook. Mirrors Log.installEvent's shape so
-- call sites read the same either way; scope and missingMsg are only used on
-- the fallback path, where the registration really is a GameEvents install.
function EngineEvents.on(name, handler, scope, missingMsg)
    if not DEFERRED[name] then
        Log.error("EngineEvents.on: '" .. tostring(name) .. "' is not a deferred hook; use Log.installEvent")
        return
    end
    if not _deferring then
        Log.installEvent(GameEvents, name, handler, scope, missingMsg)
        return
    end
    local list = _handlers[name]
    if list == nil then
        list = {}
        _handlers[name] = list
    end
    list[#list + 1] = handler
end

-- Per-tick drain. Each queued entry is { hookName, arg... }; handlers take at
-- most six arguments (unit moved is the widest), and a handler for a narrower
-- hook simply ignores the trailing nils.
function EngineEvents._drain()
    local batch, overflowed = EngineData.drainEngineEvents()
    if overflowed then
        -- The membership maps fed by these hooks self-heal on a miss
        -- (MassNames rebuilds when it meets a plot it doesn't know), so this
        -- is a report rather than a failure, but it should never happen in
        -- ordinary play.
        Log.warn("EngineEvents: engine event queue overflowed; some reveals / moves were dropped")
    end
    for i = 1, #batch do
        local e = batch[i]
        local list = _handlers[e[1]]
        if list ~= nil then
            for j = 1, #list do
                Log.tryCall("EngineEvents '" .. tostring(e[1]) .. "'", list[j], e[2], e[3], e[4], e[5], e[6], e[7])
            end
        end
    end
end

-- Must run BEFORE the consumers' installListeners, since it clears the
-- handler table they are about to register into. CivVAccess_Boot.lua calls it
-- first for that reason.
function EngineEvents.installListeners()
    _handlers = {}
    _deferring = EngineData.deferredEventsAvailable()
    if _deferring then
        Log.info("EngineEvents: draining deferred engine events on the UI thread")
        TickPump.subscribe(SUBSCRIBER_NAME, EngineEvents._drain)
    else
        -- Not an error: the fallback is the pre-queue behaviour, which works,
        -- just with the deadlock exposure this module exists to remove.
        Log.warn(
            "EngineEvents: engine fork has no deferred-event queue; reveal and "
                .. "unit-move hooks will raise on the game-core thread as before"
        )
        TickPump.unsubscribe(SUBSCRIBER_NAME)
    end
end

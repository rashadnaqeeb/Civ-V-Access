-- Log wrapper. All mod logging goes through here so feature code never calls
-- bare print / Events.AppLog. Output reaches Lua.log only when the game's
-- config.ini sets LoggingEnabled=1; callers should log anyway.

Log = {}

local function emit(level, msg)
    print("[CivVAccess] [" .. level .. "] " .. tostring(msg))
end

function Log.debug(msg)
    emit("DEBUG", msg)
end
function Log.info(msg)
    emit("INFO", msg)
end
function Log.warn(msg)
    emit("WARN", msg)
end
function Log.error(msg)
    emit("ERROR", msg)
end

-- Validate a precondition. Logs the failure and re-raises so the caller
-- aborts rather than continuing in a known-bad state.
function Log.check(cond, msg)
    if not cond then
        emit("ERROR", msg)
        error(msg, 2)
    end
end

-- Install a fresh listener on a dispatcher (Events / GameEvents / LuaEvents)
-- by named slot. Logs a warn if the dispatcher itself or the named slot
-- is missing rather than throwing -- a feature that depends on a specific
-- engine event surface fails loudly in Lua.log without taking the rest
-- of the install path with it. The optional missingMsg is appended to
-- the warn line so per-feature consequence text ("goody-hut announce
-- disabled", "Shift+T will speak nothing") survives the conversion.
--
-- Why not gate on civvaccess_shared.flagInstalled to avoid duplicate
-- listeners across game transitions: the install-once pattern strands
-- listeners with dead envs after Civ V's per-Context env wipe on load-
-- from-game (see CLAUDE.md "No install-once guards on Events listeners").
-- This helper expects re-registration on every onInGameBoot; the engine
-- catches per-listener throws so the freshest live listener still fires.
-- Wrap a listener so a runtime throw inside it surfaces to Lua.log with a
-- breadcrumb instead of falling through the engine's per-listener catch
-- silently. Useful for listener bodies that have non-trivial logic
-- (closure capture across game transitions, payload-shape assumptions
-- that a future game patch could shift, MP races where a value the
-- listener depends on is briefly nil).
function Log.safeListener(scope, fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            Log.error(scope .. " listener failed: " .. tostring(err))
        end
    end
end

-- pcall wrapper that logs on failure with a breadcrumb. Returns
-- (ok, ...) so callers that capture the inner fn's return values can
-- still check ok and use them on the success path. On failure, returns
-- false alone (the inner values are unrecoverable from a thrown call).
--
-- Use this for hooks the mod calls into user-supplied callbacks where
-- a thrown closure shouldn't take the dispatch path with it: HandlerStack
-- lifecycle hooks, BaseMenuInstall priorShowHide / priorInput /
-- shouldActivate / suppressReactivateOnHide, TabbedShell per-tab
-- onActivate / onTabDeactivated / nameFn, TickPump runOnce. Inside
-- per-feature modules the explicit pcall form is preferred (the per-
-- site label string is closer to the call) -- this helper exists for
-- the inner-callback boundaries in shared scaffolding.
function Log.tryCall(label, fn, ...)
    local results = { pcall(fn, ...) }
    if not results[1] then
        Log.error(label .. " failed: " .. tostring(results[2]))
        return false
    end
    return unpack(results)
end

function Log.installEvent(dispatcher, eventName, handler, scope, missingMsg)
    if dispatcher == nil or dispatcher[eventName] == nil then
        local msg = scope .. ": " .. eventName .. " missing"
        if missingMsg ~= nil then
            msg = msg .. "; " .. missingMsg
        end
        Log.warn(msg)
        return false
    end
    dispatcher[eventName].Add(handler)
    return true
end

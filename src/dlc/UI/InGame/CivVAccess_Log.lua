-- Log wrapper. All mod logging goes through here so feature code never calls
-- bare print / Events.AppLog. Output reaches Lua.log only when the game's
-- config.ini sets LoggingEnabled=1; callers should log anyway.

Log = {}

local function emit(level, msg)
    print("[CivVAccess] [" .. level .. "] " .. tostring(msg))
end

function Log.debug(msg) emit("DEBUG", msg) end
function Log.info(msg)  emit("INFO",  msg) end
function Log.warn(msg)  emit("WARN",  msg) end
function Log.error(msg) emit("ERROR", msg) end

# `src/dlc/UI/Shared/CivVAccess_Log.lua`

23 lines · Logging wrapper that routes all mod output through a tagged `print` call rather than bare `print` or `Events.AppLog`.

## Header comment

```
-- Log wrapper. All mod logging goes through here so feature code never calls
-- bare print / Events.AppLog. Output reaches Lua.log only when the game's
-- config.ini sets LoggingEnabled=1; callers should log anyway.
```

## Outline

- L5: `Log = {}`
- L7: `local function emit(level, msg)`
- L11: `function Log.debug(msg)`
- L14: `function Log.info(msg)`
- L17: `function Log.warn(msg)`
- L20: `function Log.error(msg)`

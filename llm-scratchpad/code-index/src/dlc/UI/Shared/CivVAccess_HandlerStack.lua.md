# `src/dlc/UI/Shared/CivVAccess_HandlerStack.lua`

344 lines · LIFO stack of active UI handlers, routing keyboard input top-first and firing lifecycle callbacks on push/pop.

## Header comment

```
-- LIFO stack of active UI handlers. Top of stack is the currently focused
-- screen; InputRouter walks from the top. State lives on the proxy-owned
-- civvaccess_shared table so every Context sandbox references the same stack.
--
-- Handler shape (a plain Lua table pushed onto the stack):
--   name               (string, required) unique-ish; used by removeByName and logs.
--   capturesAllInput   (bool, default false) barrier for InputRouter's top-down
--                      walk. Stays false for almost all handlers. Set true only
--                      for modal-like contexts (popups, confirmations, overlays)
--                      that should swallow unbound keys.
--   bindings           (array, optional) {key, mods, fn, description} entries.
--                      The handler owns its bindings; there is no central registry.
--   helpEntries        (array, required when the handler has bindings) authored
--                      {keyLabel, description} entries for the ? help overlay.
--                      Handlers with no user-visible bindings (Baseline, transient
--                      subs) should set this to an empty {} to opt in explicitly.
--                      keyLabel is a TXT_KEY for a merged, human-readable chord
--                      label ("Up/Down", "Ctrl+Shift+Left/Right"); description
--                      is a TXT_KEY. See CivVAccess_Help.lua and
--                      BaseMenuHelp's MenuHelpEntries / ListNavHelpEntries
--                      templates.
--   onActivate         (fn(self), optional) fired on push / re-exposure.
--   onDeactivate       (fn(self), optional) fired on removal.
--   tick               (fn(self), optional) called every frame by TickPump on
--                      the active handler only.
--
-- Push when a screen opens; removeByName when it closes.
```

## Outline

- L29: `HandlerStack = {}`
- L31: `civvaccess_shared = civvaccess_shared or {}`
- L32: `civvaccess_shared.stack = civvaccess_shared.stack or {}`
- L33: `local _shared = civvaccess_shared`
- L35: `local function invoke(handler, methodName)`
- L49: `function HandlerStack.bind(key, mods, fn, description)`
- L53: `function HandlerStack._reset()`
- L57: `function HandlerStack.count()`
- L61: `function HandlerStack.active()`
- L65: `function HandlerStack.at(i)`
- L69: `function HandlerStack.push(handler)`
- L109: `function HandlerStack.insertAt(handler, idx)`
- L158: `function HandlerStack.pop()`
- L175: `function HandlerStack.replace(handler)`
- L186: `function HandlerStack.popAbove(target)`
- L210: `function HandlerStack.removeByName(name, reactivate)`
- L245: `function HandlerStack.drainAndRemove(name, reactivate)`
- L284: `function HandlerStack.deactivateAll()`
- L292: `function HandlerStack.clear()`
- L299: `HandlerStack.commonHelpEntries = { ... }`
- L317: `function HandlerStack.collectHelpEntries()`

## Notes

- L109 `HandlerStack.insertAt`: only fires `onActivate` when the inserted handler becomes the new top; inserting below the current top is silent.
- L245 `HandlerStack.drainAndRemove`: pops handlers above the named target by invoking each sub's plain-Esc binding before removing; falls back to a hard pop if the binding is absent or throws.
- L317 `HandlerStack.collectHelpEntries`: walks top-to-bottom, stops at the first `capturesAllInput` handler (inclusive), deduplicates by `keyLabel` string so the topmost handler wins.

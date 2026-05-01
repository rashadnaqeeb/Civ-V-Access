# `src/dlc/UI/InGame/CivVAccess_CivilopediaAccess.lua`

137 lines · Accessibility wiring for the CivilopediaScreen Context: installs a PickerReader session over the base pedia and handles external "open on article/category" requests from engine events.

## Header comment

```
-- CivilopediaScreen accessibility wiring. Appended to the pedia.lua override.
--
-- The pedia's own code has finished running by the time this include fires,
-- so CivilopediaCategory / SetSelectedCategory / ShowHideHandler /
-- InputHandler are live globals. We chain priorShowHide so the engine's
-- history restoration on reopen still runs, and priorInput so the pedia's
-- own Esc-to-close path fires when the user Escs out at picker level 1.
--
-- Per-Context include chain: the pedia is its own LuaContext under InGame,
-- with its own Lua globals. The shared modules must load into this sandbox
-- before anything touches Text / BaseMenu / etc. These same include stems
-- are already loaded into other InGame Contexts; the engine's VFS indexes
-- by bare stem and re-runs the file per Context.
```

## Outline

- L39: `local priorShowHide = ShowHideHandler`
- L40: `local priorInput = InputHandler`
- L44: `local session = PickerReader.create()`
- L45: `local pickerItems = Civilopedia.buildPickerItems(session.Entry)`
- L55: `local pendingTarget = nil`
- L57: `local handler = session.install(ContextPtr, {...})`
- L104: `Events.SearchForPediaEntry.Add(...)`
- L127: `Events.GoToPediaHomePage.Add(...)`

## Notes

- L55 `pendingTarget`: Staging variable for async show-then-navigate; consumed in `onShow` which runs after priorShowHide but before HandlerStack.push, so the article lands in the correct tab on popup open.

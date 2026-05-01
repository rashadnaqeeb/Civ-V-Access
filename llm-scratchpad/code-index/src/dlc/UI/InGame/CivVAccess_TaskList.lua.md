# `src/dlc/UI/InGame/CivVAccess_TaskList.lua`

102 lines · Maintains a read-only mirror of the engine's scenario task list via Events.TaskListUpdate and exposes a Shift+T binding that speaks any currently-active tasks.

## Header comment

```
-- Read-only mirror of the engine's task list. Shift+T speaks active
-- (status 0) tasks joined by ". ". With no active tasks (or no task list
-- at all -- the common case outside scenarios) the key is a silent no-op.
--
-- Why mirror at all (the "never cache game state" rule has an exception
-- here): tasks live in the engine's TaskList Context's sandboxed env
-- globals (g_aTaskString / g_aTaskStatus). There is no engine API to
-- query them, and Civ V's per-Context Lua sandbox blocks reads across
-- Contexts. Events.TaskListUpdate is the only signal the engine offers
-- for task content, so a synchronously-updated mirror is the only path
-- to a Shift+T readout. The mirror matches engine state for as long as
-- we don't drop an event; the engine's own TaskList.lua has the same
-- shape for the same reason.
--
-- Listener registers at file scope (matching the engine's TaskList.lua)
-- rather than the mod's usual installListeners() pattern, so it's live
-- before LoadScreenClose. Scenario task pushes from C++ can fire during
-- game setup, before the LoadScreenClose-driven boot path runs; later-
-- registered listeners would miss them. The file is re-evaluated on
-- every WorldView Context include (fresh-game and load-game-from-game),
-- so a fresh-env closure supplants any stranded prior-game listener
-- per the same rationale as Boot.lua's LoadScreenClose registration.
```

## Outline

- L24: `TaskList = {}`
- L26: `local MOD_SHIFT = 1`
- L28: `local STATUS_ACTIVE = 0`
- L30: `local function onTaskListUpdate(info)`
- L39: `Events.TaskListUpdate.Add(onTaskListUpdate)`
- L51: `function TaskList.resetForNewGame()`
- L55: `local function speakActiveTasks()`
- L84: `local bind = HandlerStack.bind`
- L86: `function TaskList.getBindings()`
- L101: `TaskList._speakActiveTasks = speakActiveTasks`

## Notes

- L39 `Events.TaskListUpdate.Add(...)`: registered at file scope (not in installListeners) so it fires before LoadScreenClose for scenario task pushes during game setup.
- L101 `TaskList._speakActiveTasks`: test seam exposing the private local function.

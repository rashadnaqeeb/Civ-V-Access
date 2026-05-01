# `src/dlc/UI/InGame/Popups/CivVAccess_ReplayViewerAccess.lua`

97 lines · Accessibility wrapper for the front-end replay viewer popup, exposing a panel pulldown and the Messages list with a Back button; skips install in the end-game Context variant.

## Header comment

```
-- ReplayViewer accessibility, front-end Load Replay path.
--
-- Same Lua file backs two Contexts: this one (a popup queued from
-- LoadReplayMenu after the user picks a replay file) and the EndGameReplay
-- LuaContext nested inside EndGameMenu. Vanilla's `if not g_bIsEndGame`
-- guards make this Context the popup root with its own InputHandler;
-- the end-game one stays input-less and the parent EndGameMenu owns
-- input. We mirror that split: install BaseMenu only at the front-end,
-- and let EndGameMenuAccess's Replay tab cover the end-game path
-- separately (different env, different items source -- it pulls from
-- Game.GetReplayMessages() rather than g_ReplayInfo).
--
-- Layout: a panel pulldown wrapping vanilla's ReplayInfoPulldown
-- (Messages / Graphs / Map), the messages list when the pulldown is on
-- Messages, then the Back button. Graphs and Map render blank for now;
-- the visual graph and animated culture map don't reduce to readable
-- text in any obvious way and are deferred. The pulldown itself stays
-- so the user sees the same panel-selection affordance sighted players
-- have, and so the structure is in place when Graphs gets a summarizer.
--
-- Items rebuild from g_ReplayInfo.Messages, populated by vanilla's
-- LuaEvents.ReplayViewer_LoadReplay listener. We register an additional
-- listener after that one (Civ V LuaEvents .Add chains, vanilla's runs
-- first in registration order) so by the time our rebuild fires, the
-- engine has loaded the file and refreshed g_ReplayInfo. setItems +
-- refresh announces the first message to confirm load completed.
--
-- Esc / Enter on unbound keys fall through priorInput to vanilla's
-- InputHandler -> OnBack(), which dequeues the popup. BaseMenu has no
-- escapePops binding so the chain works.
```

## Outline

- L36: `local priorInput = InputHandler`
- L37: `local priorShowHide = ShowHideHandler`
- L39: `local m_handler = nil`
- L43: `local function buildItems()`
- L80: `LuaEvents.ReplayViewer_LoadReplay.Add(...)`
- L90: `m_handler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L32: Early `return` when `g_bIsEndGame` is true prevents the entire file from executing in the end-game Context variant.
- L80 `LuaEvents.ReplayViewer_LoadReplay.Add`: Registered after vanilla's own listener so `g_ReplayInfo` is fully populated by the time our rebuild fires.

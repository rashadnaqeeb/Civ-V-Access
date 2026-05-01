# `src/dlc/UI/FrontEnd/CivVAccess_SinglePlayerAccess.lua`

110 lines · Accessibility wiring for the SinglePlayer screen, with a computed settings-summary tooltip for the Play Now button that replicates the engine-set string from live PreGame state.

## Header comment

```
-- SinglePlayer accessibility wiring. Tutorial and Scenarios buttons are
-- omitted: both crash the game with no explanation and the mod has no
-- plans to support them, so making them undiscoverable beats letting
-- players hit the crash.
--
-- StartGameButton carries a dynamic settings-summary tooltip set via
-- Controls.StartGameButton:SetToolTipString inside the screen's own
-- ShowHideHandler. There is no Lua API to read that string back, so we
-- recompute the same summary from PreGame at announce time: leader/civ,
-- map script, world size, handicap, game speed. PreGame persists a civ
-- pick made in Setup Game, so Play Now can launch as a specific leader.
```

## Outline

- L15: `local priorShowHide = ShowHideHandler`
- L16: `local priorInput = InputHandler`
- L18: `local function playNowSettingsSummary()`
- L73: `BaseMenu.install(ContextPtr, { ... })`

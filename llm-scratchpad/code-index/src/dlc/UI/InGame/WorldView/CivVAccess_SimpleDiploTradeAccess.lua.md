# `src/dlc/UI/InGame/WorldView/CivVAccess_SimpleDiploTradeAccess.lua`

52 lines · Thin Context wrapper that installs the PvP live-deal (SimpleDiploTrade) screen's accessibility handler via TradeLogicAccess with a player-name-based title and no preamble.

## Header comment

```
-- SimpleDiploTrade (PvP live-deal) accessibility. Included by
-- SimpleDiploTrade.lua's verbatim override. PvP-specific wiring in the
-- descriptor: title from ThemName, no preamble (no speech frame), full
-- speech on open (no voice clip to double-narrate).
```

## Outline

- L30: `local priorInput = InputHandler`
- L31: `local priorShowHide = OnShowHide`
- L36: `local function titleFn()`
- L44: `TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, { name = "SimpleDiploTrade", kind = "PvP", displayNameFn = titleFn, preambleFn = nil, silentFirstOpen = false, ... })`

## Notes

- L44 `TradeLogicAccess.install`: `silentFirstOpen = false` because there is no engine voice clip on PvP trade screens, so the full open-speech (title + items) should fire immediately.

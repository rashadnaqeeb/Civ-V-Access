# `src/dlc/UI/FrontEnd/CivVAccess_OtherMenuAccess.lua`

75 lines · Accessibility wiring for the OtherMenu screen (news, Civilopedia, Hall of Fame, replays, credits, leaderboard), with inlined anonymous button-body duplicates from the base file.

## Header comment

```
-- OtherMenu accessibility wiring. The game's LatestNews and Civilopedia
-- handlers are anonymous closures registered inline; we duplicate their
-- one-line bodies here rather than trying to reach into local scope.
-- If the base game changes those URLs / targets the duplicate needs a
-- matching update.
```

## Outline

- L8: `local priorShowHide = ShowHideHandler`
- L9: `local priorInput = InputHandler`
- L12: `BaseMenu.install(ContextPtr, { ... })`

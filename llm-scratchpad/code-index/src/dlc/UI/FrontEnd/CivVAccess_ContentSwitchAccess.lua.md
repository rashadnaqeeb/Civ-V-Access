# `src/dlc/UI/FrontEnd/CivVAccess_ContentSwitchAccess.lua`

15 lines · Accessibility wiring for the ContentSwitch status splash shown while the engine swaps DLC/expansion rules, announcing a static progress message with no navigable items.

## Header comment

```
-- ContentSwitch accessibility wiring. Status splash shown while the engine
-- swaps DLC / expansion rules — no buttons, just a progress message. Empty
-- items list keeps BaseMenu on the announce-only path.
```

## Outline

- L7: `local priorShowHide = OnShowHide`
- L9: `BaseMenu.install(ContextPtr, { ... })`

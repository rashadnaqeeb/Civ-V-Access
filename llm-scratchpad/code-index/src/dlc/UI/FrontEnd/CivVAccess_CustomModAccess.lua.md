# `src/dlc/UI/FrontEnd/CivVAccess_CustomModAccess.lua`

77 lines · Accessibility wiring for the Custom Mod game screen, providing a navigable list of mod entry points with a replicated launch callback since the base file's StartButton handler is anonymous.

## Header comment

```
-- CustomMod accessibility wiring. Base registers its InputHandler as an
-- anonymous callback (CustomMod.lua line 50) and has no ShowHideHandler
-- at all; the mod list is populated lazily via a ContextPtr:SetUpdate
-- (line 59) that BaseMenu's TickPump overwrites. priorInput is nil and
-- the list must be seeded from onShow. The StartButton callback is
-- anonymous too (line 27) so launch is replicated below.
```

## Outline

- L12: `local function startCustomMod()`
- L31: `local function buildItems()`
- L63: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L12 `startCustomMod`: Replicates the body of the base file's anonymous StartButton click closure; must be kept in sync if that base callback changes.

# `src/dlc/UI/FrontEnd/CivVAccess_LoadScreenAccess.lua`

212 lines · Accessibility wiring for the Dawn-of-Man load screen, surfacing leader/civ info, all unique units/buildings/improvements (without the base UI's 2-slot cap), and a Begin button that becomes focusable once `SequenceGameInitComplete` fires.

## Header comment

```
-- LoadScreen accessibility wiring. The Dawn-of-Man splash between map
-- launch and first turn. [...] F1 re-reads the quote as the preamble; the
-- Begin button sits first so the cursor can hop onto it the moment loading
-- completes.
--
-- Begin button timing: Controls.ActivateButton is hidden until
-- Events.SequenceGameInitComplete fires. [...]
--
-- Unique items: base PopulateUniqueBonuses caps the sighted UI at 2
-- slots [...]. We query Civilization_UnitClassOverrides /
-- Civilization_BuildingClassOverrides / Improvements.CivilizationType
-- directly and surface every unique as its own item.
--
-- Re-instantiation: the SequenceGameInitComplete listener closes over
-- civvaccess_shared.loadScreenHandler [...] The install guard
-- keeps the listener from double-registering on the session bus.
```

## Outline

- L36: `local priorShowHide = ShowHide`
- L37: `local priorInput = InputHandler`
- L39: `local function controlText(control)`
- L57: `local uniqueUnitsQuery = DB.CreateQuery([[...]])`
- L70: `local uniqueBuildingsQuery = DB.CreateQuery([[...]])`
- L85: `local uniqueImprovementsQuery = DB.CreateQuery([[...]])`
- L88: `local function activeCiv()`
- L93: `local function uniqueItem(labelKey, uniqueDesc, replacesDesc)`
- L101: `local function buildItems()`
- L166: `local function buildPreamble()`
- L174: `local handler = BaseMenu.install(ContextPtr, { ... })`
- L187: `civvaccess_shared.loadScreenHandler = handler`
- L189: `if not civvaccess_shared.loadScreenReadyListenerInstalled then`
- L191: `Events.SequenceGameInitComplete.Add(...)`

## Notes

- L36 `priorShowHide`: Captures `ShowHide` (not `ShowHideHandler`) because the base `LoadScreen.lua` registers its handler under that non-standard name; reading the wrong global would leave the base handler unchained.
- L57-86: Pre-compiled DB queries (not functions) created once at include time and re-executed per-show with a civilization type argument.

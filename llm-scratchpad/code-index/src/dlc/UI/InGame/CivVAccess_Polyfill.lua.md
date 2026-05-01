# `src/dlc/UI/InGame/CivVAccess_Polyfill.lua`

723 lines · Stubs engine globals for the offline test harness; self-disables in-game via a `ContextPtr` sentinel check.

## Header comment

```
-- Stubs engine globals for the offline test harness. In-game, ContextPtr is
-- always present, so this file no-ops and the real engine globals win.
-- Sentinel: ContextPtr (present in every Civ V UI Context, absent in tests).
```

## Outline

- L5: `if ContextPtr ~= nil then return end`
- L9: `civvaccess_shared = civvaccess_shared or {}`
- L17: `if include == nil then include = function() end end`
- L21: `StringsLoader = StringsLoader or { ... }`
- L26: `Locale = Locale or { ... }`
- L49: `UI = UI or { ... }`
- L88: `InterfaceModeTypes = InterfaceModeTypes or { ... }`
- L108: `Events = Events or { ... }`
- L119: `Map = Map or { ... }`
- L150: `Game = Game or { ... }`
- L174: `Players = Players or {}`
- L175: `Teams = Teams or {}`
- L176: `GameInfo = GameInfo or {}`
- L177: `GameInfoTypes = GameInfoTypes or {}`
- L183: `OptionsManager = OptionsManager or {}`
- L194: `Events.ActivePlayerTurnStart = Events.ActivePlayerTurnStart or { Add = function(_fn) end }`
- L197: `Events.ActivePlayerTurnEnd = Events.ActivePlayerTurnEnd or { Add = function(_fn) end }`
- L205: `EndTurnBlockingTypes = EndTurnBlockingTypes or { ... }`
- L233: `DirectionTypes = DirectionTypes or { ... }`
- L246: `PlotTypes = PlotTypes or { ... }`
- L255: `FeatureTypes = FeatureTypes or { NO_FEATURE = -1 }`
- L256: `TerrainTypes = TerrainTypes or { NO_TERRAIN = -1 }`
- L257: `ResourceTypes = ResourceTypes or { NO_RESOURCE = -1 }`
- L258: `ImprovementTypes = ImprovementTypes or { NO_IMPROVEMENT = -1 }`
- L259: `RouteTypes = RouteTypes or { NO_ROUTE = -1 }`
- L261: `YieldTypes = YieldTypes or { ... }`
- L279: `ResourceUsageTypes = ResourceUsageTypes or { ... }`
- L286: `DomainTypes = DomainTypes or { ... }`
- L297: `CombatPredictionTypes = CombatPredictionTypes or { ... }`
- L310: `GameDefines = GameDefines or { ... }`
- L337: `ActivityTypes = ActivityTypes or { ... }`
- L352: `Mouse = Mouse or { ... }`
- L365: `Keys = Keys or { ... }`
- L438: `Polyfill = Polyfill or {}`
- L440: `function Polyfill.makeLabel(initialText)`
- L463: `function Polyfill.makeButton()`
- L526: `function Polyfill.makeSlider(opts)`
- L570: `function Polyfill.makeCheckBox(opts)`
- L602: `function Polyfill.makeEditBox(opts)`
- L641: `function Polyfill.makePullDown()`
- L686: `function Polyfill.makePullDownWithMetatable(mt)`
- L703: `function Polyfill.makeButtonWithMetatable(mt)`

## Notes

- L5: The early return is the single sentinel that makes this file inert in-game; everything below line 5 only executes in the offline test harness.
- L526 `Polyfill.makeSlider` / L570 `Polyfill.makeCheckBox`: Intentionally do NOT fire the registered callback from `SetValue`/`SetCheck`; the real engine only fires those on mouse interaction, matching how `BaseMenuItems` wraps them.
- L686 `Polyfill.makePullDownWithMetatable`: Strips all instance methods from the polyfill table so `PullDownProbe` can patch the shared metatable exactly as it does in-game; tests use this to exercise the same dispatch path as production.

# `src/dlc/UI/InGame/CivVAccess_PlotComposers.lua`

254 lines · Assembles plot section tokens into the three spoken readouts: per-move glance, economy (W key), and combat (X key).

## Header comment

```
-- Composers for the per-move glance and the on-demand W (economy) and X
-- (combat) detail keys. Each composer reads sections in a fixed order,
-- joins non-empty tokens with ", ", and returns a single speech string.
--
-- Visibility gating happens here, not in the sections themselves: a fogged
-- plot reads stale GetRevealed* data fine, but live data (units, yields,
-- build progress, ZoC) only makes sense when IsVisible. The per-move
-- composer also handles the "never revealed" short-circuit so unexplored
-- tiles don't leak any information at all.
```

## Outline

- L11: `PlotComposers = {}`
- L13: `local function readSection(section, plot, ctx, out)`
- L35: `function PlotComposers.glance(plot, opts)`
- L70: `local YIELD_KEYS = { ... }`
- L79: `local function readYields(plot, out)`
- L88: `local function readBuildProgress(plot, out)`
- L111: `function PlotComposers.economy(plot, opts)`
- L150: `local NEIGHBOR_DIRS = { ... }`
- L159: `local function inEnemyZoC(plot, activeTeam, isDebug)`
- L180: `local function tileMoveCost(plot)`
- L215: `function PlotComposers.combat(plot)`

## Notes

- L35 `PlotComposers.glance`: `opts.cueOnly=true` suppresses tokens already conveyed by audio cues (base terrain, mountain, lake, non-wonder feature names, route) so audio and speech don't double-speak the same fact.
- L180 `tileMoveCost`: Returns tile-generic cost only; does not account for road bypass, river-edge bridges, embark, or unit-specific modifiers - those require a from-plot and unit that the keyboard cursor does not have.

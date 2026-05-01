# `src/dlc/UI/InGame/CivVAccess_RecommendationsCore.lua`

189 lines · Shared helpers for AI tile recommendations: gating, list accessors, membership checks, and reason-text builders used by both the scanner and the cursor-glance section.

## Header comment

```
-- Shared helpers for AI tile recommendations. Owns the gating, list
-- accessors, membership check, and the reason-text ladder that
-- GenericWorldAnchor.lua uses to build its map tooltip. Two consumers:
--   * ScannerBackendRecommendations -- uses gating + list iteration
--     to emit scanner entries.
--   * PlotSections.recommendation   -- uses membership + reason text
--     to append a "recommendation: ..." token to the cursor glance
--     when the user lands on a recommended plot.
--
-- Reason text reimplements the if/elseif ladder in
-- HandleSettlerRecommendation / HandleWorkerRecommendation verbatim,
-- using the same TXT_KEYs. Anything else drifts from what a sighted
-- player sees on the map marker tooltip.
```

## Outline

- L15: `Recommendations = {}`
- L19: `function Recommendations.allowed()`
- L25: `function Recommendations.settlerActive(player)`
- L29: `function Recommendations.workerActive()`
- L35: `function Recommendations.settlerPlots(player)`
- L43: `function Recommendations.workerPlots(player)`
- L53: `function Recommendations.settlerContains(player, x, y)`
- L62: `function Recommendations.workerContains(player, x, y, buildType)`
- L75: `function Recommendations.workerRecAt(player, x, y)`
- L95: `local SETTLER_RANGE = 2`
- L97: `function Recommendations.settlerReason(plot, player)`
- L154: `function Recommendations.workerReason(plot, buildType)`

## Notes

- L97 `Recommendations.settlerReason`: Reimplements `HandleSettlerRecommendation`'s 2-Chebyshev-range yield/resource accumulation and priority ladder verbatim, including the engine's thresholds (0.75 / 0.75 / 1.2 per-plot average), to match exactly what sighted players see on map-marker tooltips.
- L154 `Recommendations.workerReason`: Mirrors `HandleWorkerRecommendation`'s ladder: resource hookup takes priority over the build's own Recommendation key, which takes priority over first positive yield delta.

# `src/dlc/UI/InGame/CivVAccess_PlotSectionRiver.lua`

76 lines · Plot section that detects which of a hex's six edges border a river and returns a single spoken token describing them.

## Header comment

```
-- River edges section. Civ V's plot stores river presence for three of the
-- six hex edges as flags whose names look like edge labels but are actually
-- positional: IsNEOfRiver means "this plot is NE of a river," i.e. the
-- river runs along the plot's SW edge. By the same inversion IsWOfRiver
-- maps to the E edge and IsNWOfRiver to the SE edge. The other three edges
-- (NE, W, NW) live on the same flag of the neighbor in that direction --
-- e.g. the NE neighbor's IsNEOfRiver puts a river on its SW edge, which is
-- our NE edge. Authoritative source: CvPlot::updateRiverCrossing in the
-- SDK (CvGameCoreDLL_Expansion2/CvPlot.cpp).
--
-- We assemble all six edges and announce them in a fixed clockwise order
-- starting from NE so the same river always reads the same way regardless
-- of cursor approach. Six-of-six collapses to a single "river all sides"
-- token so the user doesn't sit through six direction tokens for what is
-- effectively "you are on a river island."
```

## Outline

- L17: `local SELF_EDGES = { ... }`
- L26: `local NEIGHBOR_EDGES = { ... }`
- L35: `local SPOKEN_ORDER = { ... }`
- L45: `PlotSectionRiver = { Read = function(plot) ... end }`

## Notes

- L17 `SELF_EDGES`: The flag names are inverted relative to the edge they describe (IsNEOfRiver = river on SW edge). The table maps from the spoken direction key to the correct method name so callers don't need to know this.
- L45 `PlotSectionRiver`: Exported as a module-table section (not `PlotSectionRiver.Read`), matching the `{ Read = fn }` shape all other sections use.

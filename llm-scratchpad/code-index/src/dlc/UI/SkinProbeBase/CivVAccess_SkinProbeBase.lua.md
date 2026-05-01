# `src/dlc/UI/SkinProbeBase/CivVAccess_SkinProbeBase.lua`

11 lines · Sentinel file for the BaseGame UISkin manifest (CivVAccess_0.Civ5Pkg); defines no globals and is never included by other modules.

## Header comment

```
-- Sentinel file for the BaseGame UISkin set. CivVAccess_0.Civ5Pkg needs a
-- non-empty <Skin>/<GameplaySkin> block to register its UISkin
-- declaration; this file is the directory's only content. Nothing
-- includes it, and it deliberately defines no globals. The mod's
-- functional payload all lives under our Expansion2 manifest's
-- directories. The presence of this BaseGame manifest (and its
-- Expansion1 sibling, CivVAccess_1.Civ5Pkg) is what avoids a tutorial /
-- vanilla-scenario CTD when only the Expansion2 manifest is present;
-- mechanism unverified, but the fix follows the EUI / VPUI three-
-- manifest pattern and is empirically reliable.
```

## Outline

(no symbols)

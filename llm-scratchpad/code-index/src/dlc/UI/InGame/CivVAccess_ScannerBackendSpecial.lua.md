# `src/dlc/UI/InGame/CivVAccess_ScannerBackendSpecial.lua`

92 lines · Scanner backend for special map objects: natural wonders (by NaturalWonder feature flag) and ancient ruins (goody-hut improvements).

## Header comment

```
-- Scanner backend: special map objects. Natural wonders (plots whose
-- feature has NaturalWonder=1) and ancient ruins (plots whose revealed
-- improvement is IMPROVEMENT_GOODY_HUT). World wonders do not live here
-- because they're building-in-city records, not map plots.
```

## Outline

- L6: `ScannerBackendSpecial = { name = "special" }`
- L10: `local function naturalWonderName(featureId)`
- L21: `function ScannerBackendSpecial.Scan(_activePlayer, activeTeam)`
- L62: `function ScannerBackendSpecial.ValidateEntry(entry, _cursorPlotIndex)`
- L87: `function ScannerBackendSpecial.FormatName(entry)`
- L91: `ScannerCore.registerBackend(ScannerBackendSpecial)`

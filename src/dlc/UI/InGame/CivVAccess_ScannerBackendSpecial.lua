-- Scanner backend: special map objects. Natural wonders (plots whose
-- feature has NaturalWonder=1) and ancient ruins (plots whose revealed
-- improvement is IMPROVEMENT_GOODY_HUT). World wonders do not live here
-- because they're building-in-city records, not map plots.
--
-- Step 2 stub: Scan returns empty. Step 7 fills it in.

ScannerBackendSpecial = {
    name = "special",
}

function ScannerBackendSpecial.Scan(_activePlayer, _activeTeam)
    return {}
end

function ScannerBackendSpecial.ValidateEntry(_entry, _cursorPlotIndex)
    return false
end

function ScannerBackendSpecial.FormatName(_entry)
    return ""
end

ScannerCore.registerBackend(ScannerBackendSpecial)

-- Scanner backend: cities (My / Neutral / Enemy) and barbarian camps.
-- Step 2 stub: Scan returns an empty list. Step 3 fills in the real
-- iteration over Players[p]:Cities() across every met team plus the
-- barb-camp plot sweep (see docs/scanner-design.md section 4).
--
-- ValidateEntry / FormatName are kept as placeholders that the mid-
-- snapshot validation path can call without crashing. They'll acquire
-- real behaviour alongside Scan in step 3.

ScannerBackendCities = {
    name = "cities",
}

function ScannerBackendCities.Scan(_activePlayer, _activeTeam)
    return {}
end

function ScannerBackendCities.ValidateEntry(_entry, _cursorPlotIndex)
    return false
end

function ScannerBackendCities.FormatName(_entry)
    return ""
end

ScannerCore.registerBackend(ScannerBackendCities)

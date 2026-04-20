-- Scanner backend: units (partitioned into My / Neutral / Enemy by the
-- scanning player's team stance, plus the Barbarians subcategory under
-- Enemy Units). Role subcategory is derived from Domain + UnitCombat per
-- the table in docs/scanner-design.md section 2.
--
-- Step 2 stub: Scan returns empty. Step 4 fills it in.

ScannerBackendUnits = {
    name = "units",
}

function ScannerBackendUnits.Scan(_activePlayer, _activeTeam)
    return {}
end

function ScannerBackendUnits.ValidateEntry(_entry, _cursorPlotIndex)
    return false
end

function ScannerBackendUnits.FormatName(_entry)
    return ""
end

ScannerCore.registerBackend(ScannerBackendUnits)

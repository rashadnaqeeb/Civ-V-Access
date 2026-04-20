-- Scanner backend: resources. Subcategory is GameInfo.Resources.ResourceUsage
-- (0 bonus / 1 strategic / 2 luxury). Plot reveal + tech-gating handled
-- by the two-arg plot:GetResourceType(activeTeam) overload.
--
-- Step 2 stub: Scan returns empty. Step 5 fills it in.

ScannerBackendResources = {
    name = "resources",
}

function ScannerBackendResources.Scan(_activePlayer, _activeTeam)
    return {}
end

function ScannerBackendResources.ValidateEntry(_entry, _cursorPlotIndex)
    return false
end

function ScannerBackendResources.FormatName(_entry)
    return ""
end

ScannerCore.registerBackend(ScannerBackendResources)

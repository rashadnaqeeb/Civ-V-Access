-- Scanner backend: improvements (My / Neutral / Enemy by owner team
-- stance). Reads plot:GetRevealedImprovementType / Owner(activeTeam) so
-- the scanner matches the engine's own rendering under fog. Skips
-- IMPROVEMENT_BARBARIAN_CAMP, IMPROVEMENT_GOODY_HUT (handled by the
-- Cities and Special backends respectively), and the road / railroad
-- pseudo-improvements (volume > signal).
--
-- Step 2 stub: Scan returns empty. Step 6 fills it in.

ScannerBackendImprovements = {
    name = "improvements",
}

function ScannerBackendImprovements.Scan(_activePlayer, _activeTeam)
    return {}
end

function ScannerBackendImprovements.ValidateEntry(_entry, _cursorPlotIndex)
    return false
end

function ScannerBackendImprovements.FormatName(_entry)
    return ""
end

ScannerCore.registerBackend(ScannerBackendImprovements)

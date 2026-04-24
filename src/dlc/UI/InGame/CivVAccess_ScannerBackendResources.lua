-- Scanner backend: resources. Subcategory keyed off GameInfo.Resources
-- .ResourceUsage (0 bonus / 1 strategic / 2 luxury).
--
-- Visibility gating is in two layers because the engine splits them:
--   * plot:IsRevealed(team, isDebug)      fog-of-war gate (explored yet?)
--   * plot:GetResourceType(team)          tech gate (returns -1 when a
--                                         strategic resource is present
--                                         but the team lacks the reveal
--                                         tech, e.g. Iron before BW)
-- Both must pass. The engine's own tooltip pipeline does the same pairing
-- (PlotHelpManager gates on IsRevealed before calling
-- GenerateResourceToolTip, which then calls GetResourceType with the
-- active team). Skipping the IsRevealed check surfaces resources on
-- unexplored plots, which is the whole-map leak we hit in testing.

ScannerBackendResources = {
    name = "resources",
}

local USAGE_SUBS = {
    [0] = "bonus",
    [1] = "strategic",
    [2] = "luxury",
}

function ScannerBackendResources.Scan(_activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and plot:IsRevealed(activeTeam, isDebug) then
            local resId = plot:GetResourceType(activeTeam)
            if resId ~= nil and resId >= 0 then
                local row = GameInfo.Resources[resId]
                if row ~= nil then
                    local sub = USAGE_SUBS[row.ResourceUsage]
                    if sub ~= nil then
                        out[#out + 1] = {
                            plotIndex = i,
                            backend = ScannerBackendResources,
                            data = { resourceId = resId },
                            category = "resources",
                            subcategory = sub,
                            itemName = Text.key(row.Description),
                            key = "resources:" .. i,
                            sortKey = 0,
                        }
                    end
                end
            end
        end
    end
    return out
end

function ScannerBackendResources.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    if not plot:IsRevealed(activeTeam, isDebug) then
        return false
    end
    return plot:GetResourceType(activeTeam) == entry.data.resourceId
end

function ScannerBackendResources.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendResources)

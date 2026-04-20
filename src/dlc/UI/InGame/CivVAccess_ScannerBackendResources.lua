-- Scanner backend: resources. Subcategory keyed off GameInfo.Resources
-- .ResourceUsage (0 bonus / 1 strategic / 2 luxury). The two-arg
-- plot:GetResourceType(activeTeam) overload handles both "unrevealed"
-- and "tech-gated" gates in one call (returns -1 for either).

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
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil then
            local resId = plot:GetResourceType(activeTeam)
            if resId ~= nil and resId >= 0 then
                local row = GameInfo.Resources[resId]
                if row ~= nil then
                    local sub = USAGE_SUBS[row.ResourceUsage]
                    if sub ~= nil then
                        out[#out + 1] = {
                            plotIndex   = i,
                            backend     = ScannerBackendResources,
                            data        = { resourceId = resId },
                            category    = "resources",
                            subcategory = sub,
                            itemName    = Text.key(row.Description),
                            sortKey     = 0,
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
    if plot == nil then return false end
    local activeTeam = Game.GetActiveTeam()
    return plot:GetResourceType(activeTeam) == entry.data.resourceId
end

function ScannerBackendResources.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendResources)

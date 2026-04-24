-- Scanner backend: special map objects. Natural wonders (plots whose
-- feature has NaturalWonder=1) and ancient ruins (plots whose revealed
-- improvement is IMPROVEMENT_GOODY_HUT). World wonders do not live here
-- because they're building-in-city records, not map plots.

ScannerBackendSpecial = {
    name = "special",
}

local function naturalWonderName(featureId)
    local row = GameInfo.Features[featureId]
    if row == nil or not row.NaturalWonder then
        return nil
    end
    if row.Description == nil then
        return nil
    end
    return Text.key(row.Description)
end

function ScannerBackendSpecial.Scan(_activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    local goodyHutId = GameInfoTypes and GameInfoTypes.IMPROVEMENT_GOODY_HUT
    local goodyHutLabel = Text.key("TXT_KEY_IMPROVEMENT_GOODY_HUT")
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and plot:IsRevealed(activeTeam, isDebug) then
            local featureId = plot:GetFeatureType()
            if featureId ~= nil and featureId >= 0 then
                local name = naturalWonderName(featureId)
                if name ~= nil then
                    out[#out + 1] = {
                        plotIndex = i,
                        backend = ScannerBackendSpecial,
                        data = { kind = "wonder", featureId = featureId },
                        category = "special",
                        subcategory = "natural_wonders",
                        itemName = name,
                        key = "special:wonder:" .. i,
                        sortKey = 0,
                    }
                end
            end
            if goodyHutId ~= nil and plot:GetRevealedImprovementType(activeTeam, isDebug) == goodyHutId then
                out[#out + 1] = {
                    plotIndex = i,
                    backend = ScannerBackendSpecial,
                    data = { kind = "ruins" },
                    category = "special",
                    subcategory = "ancient_ruins",
                    itemName = goodyHutLabel,
                    key = "special:ruins:" .. i,
                    sortKey = 0,
                }
            end
        end
    end
    return out
end

function ScannerBackendSpecial.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    if not plot:IsRevealed(activeTeam, isDebug) then
        return false
    end
    if entry.data.kind == "wonder" then
        return plot:GetFeatureType() == entry.data.featureId
    end
    -- Ancient ruin: popped when a unit steps on it, so revealed
    -- improvement flips back to NO_IMPROVEMENT.
    if GameInfoTypes == nil then
        return false
    end
    local goodyHutId = GameInfoTypes.IMPROVEMENT_GOODY_HUT
    if goodyHutId == nil then
        return false
    end
    return plot:GetRevealedImprovementType(activeTeam, isDebug) == goodyHutId
end

function ScannerBackendSpecial.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendSpecial)

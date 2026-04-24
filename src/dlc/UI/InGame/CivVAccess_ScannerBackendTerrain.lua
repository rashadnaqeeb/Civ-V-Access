-- Scanner backend: terrain. Emits up to three entries per revealed plot,
-- one per applicable subcategory:
--   base       the plot's terrain row description (grassland, plains,
--              desert, coast, ocean, mountain, ...).
--   features   the plot's feature row description (forest, jungle, oasis,
--              floodplains, natural wonders, ...) when one is present.
--   elevation  hills or mountain, when IsHills() / IsMountain() is true.
--
-- Double-listing is intentional per the scanner design: a forested hill
-- on grassland produces Grassland under base, Forest under features, and
-- Hills under elevation, and a natural-wonder tile also surfaces under
-- special.natural_wonders via ScannerBackendSpecial. Each sub answers a
-- different "where is ..." question (base material / overlay / relief)
-- and collapsing them would force the user to mentally re-query.
--
-- Visibility: plot:IsRevealed gate only. Terrain and features have no
-- GetRevealedTerrainType / GetRevealedFeatureType -- unlike improvements
-- and resources, the engine treats terrain and features as reveal-and-
-- remember data, so the live getters match what the player's fog map
-- shows (a forest chopped under fog stays a forest to the player until
-- they re-enter visibility, and the scanner honours the same ambiguity).

ScannerBackendTerrain = {
    name = "terrain",
}

local HILLS_KEY = "TXT_KEY_TERRAIN_HILLS_HEADING3_TITLE"
local MOUNTAIN_KEY = "TXT_KEY_TERRAIN_MOUNTAIN_HEADING3_TITLE"

function ScannerBackendTerrain.Scan(_activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and plot:IsRevealed(activeTeam, isDebug) then
            local terrainId = plot:GetTerrainType()
            if terrainId ~= nil and terrainId >= 0 then
                local row = GameInfo.Terrains[terrainId]
                if row ~= nil and row.Description ~= nil then
                    out[#out + 1] = {
                        plotIndex = i,
                        backend = ScannerBackendTerrain,
                        data = { kind = "base", terrainId = terrainId },
                        category = "terrain",
                        subcategory = "base",
                        itemName = Text.key(row.Description),
                        key = "terrain:base:" .. i,
                        sortKey = 0,
                    }
                end
            end

            local featureId = plot:GetFeatureType()
            if featureId ~= nil and featureId >= 0 then
                local frow = GameInfo.Features[featureId]
                if frow ~= nil and frow.Description ~= nil then
                    out[#out + 1] = {
                        plotIndex = i,
                        backend = ScannerBackendTerrain,
                        data = { kind = "feature", featureId = featureId },
                        category = "terrain",
                        subcategory = "features",
                        itemName = Text.key(frow.Description),
                        key = "terrain:feature:" .. i,
                        sortKey = 0,
                    }
                end
            end

            -- PLOT_MOUNTAIN and PLOT_HILLS are distinct plot types, so at
            -- most one branch fires per plot; the elseif is belt-and-braces
            -- in case a mod ever flips both flags.
            if plot:IsMountain() then
                out[#out + 1] = {
                    plotIndex = i,
                    backend = ScannerBackendTerrain,
                    data = { kind = "mountain" },
                    category = "terrain",
                    subcategory = "elevation",
                    itemName = Text.key(MOUNTAIN_KEY),
                    key = "terrain:elevation:" .. i,
                    sortKey = 0,
                }
            elseif plot:IsHills() then
                out[#out + 1] = {
                    plotIndex = i,
                    backend = ScannerBackendTerrain,
                    data = { kind = "hills" },
                    category = "terrain",
                    subcategory = "elevation",
                    itemName = Text.key(HILLS_KEY),
                    key = "terrain:elevation:" .. i,
                    sortKey = 0,
                }
            end
        end
    end
    return out
end

function ScannerBackendTerrain.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    if not plot:IsRevealed(activeTeam, isDebug) then
        return false
    end
    local kind = entry.data.kind
    if kind == "base" then
        return plot:GetTerrainType() == entry.data.terrainId
    elseif kind == "feature" then
        return plot:GetFeatureType() == entry.data.featureId
    elseif kind == "mountain" then
        return plot:IsMountain()
    elseif kind == "hills" then
        return plot:IsHills()
    end
    return false
end

function ScannerBackendTerrain.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendTerrain)

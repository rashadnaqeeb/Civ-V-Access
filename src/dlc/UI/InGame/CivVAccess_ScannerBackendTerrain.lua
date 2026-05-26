-- Scanner backend: terrain. Emits up to four entries per revealed plot,
-- one per applicable subcategory:
--   base        the plot's terrain row description (grassland, plains,
--               desert, coast, ocean, mountain, ...). Lakes use the
--               TERRAIN_COAST row but the engine flags them via
--               plot:IsLake(); those are emitted as "lake" so the user
--               isn't told an inland pond is coast. Contiguous unrevealed
--               plots are clustered into a single "unexplored" entry per
--               connected region; see the cluster block further down.
--   features    the plot's feature row description (forest, jungle, oasis,
--               floodplains, natural wonders, ...) when one is present.
--   elevation   hills or mountain, when IsHills() / IsMountain() is true.
--   freshwater  the engine's Plot:IsFreshWater() predicate -- the same
--               flag that gates farm yields, riverside city placement,
--               and Hanging Gardens. Includes tiles on a river, tiles
--               adjacent to a lake, and tiles adjacent to an oasis or
--               other AddsFreshWater feature.
--
-- Double-listing is intentional per the scanner design: a forested hill
-- on grassland next to a river produces Grassland under base, Forest
-- under features, Hills under elevation, and "fresh water" under
-- freshwater. A natural-wonder tile also surfaces under
-- special.natural_wonders via ScannerBackendSpecial. Each sub answers a
-- different "where is ..." question (base material / overlay / relief /
-- freshwater access) and collapsing them would force the user to
-- mentally re-query.
--
-- Visibility: plot:IsRevealed gate only. Terrain and features have no
-- GetRevealedTerrainType / GetRevealedFeatureType -- unlike improvements
-- and resources, the engine treats terrain and features as reveal-and-
-- remember data, so the live getters match what the player's fog map
-- shows (a forest chopped under fog stays a forest to the player until
-- they re-enter visibility, and the scanner honours the same ambiguity).
--
-- Unexplored clustering: plots that fail IsRevealed are union-find
-- clustered on 6-neighbor hex adjacency and emitted as one entry per
-- connected region under base. Without clustering, a turn-1 map produces
-- ~7500 singleton "unexplored" entries; the cluster collapses them to
-- one per connected fog region.

ScannerBackendTerrain = {
    name = "terrain",
}

local HILLS_KEY = "TXT_KEY_TERRAIN_HILLS_HEADING3_TITLE"
local MOUNTAIN_KEY = "TXT_KEY_TERRAIN_MOUNTAIN_HEADING3_TITLE"
local FRESH_WATER_KEY = "TXT_KEY_CIVVACCESS_FRESH_WATER"
local LAKE_KEY = "TXT_KEY_CIVVACCESS_LAKE"
local UNEXPLORED_KEY = "TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED"
local UNEXPLORED_CLUSTER_KEY = "TXT_KEY_CIVVACCESS_SCANNER_UNEXPLORED_CLUSTER"

local HEX_NEIGHBOR_DIRS = {
    DirectionTypes.DIRECTION_NORTHEAST,
    DirectionTypes.DIRECTION_EAST,
    DirectionTypes.DIRECTION_SOUTHEAST,
    DirectionTypes.DIRECTION_SOUTHWEST,
    DirectionTypes.DIRECTION_WEST,
    DirectionTypes.DIRECTION_NORTHWEST,
}

-- Union-find over plot indices for unexplored clustering. Path-compression
-- find plus union-by-rank, allocated fresh per Scan because the set of
-- unrevealed plots changes every rebuild. Sparse (hash table) rather than
-- a full plot-count array because revealed plots are out of the domain
-- and the overhead of allocating a 7500-slot table per scan would beat
-- the table lookup cost we save.
local function ufMake()
    return { parent = {}, rank = {} }
end

local function ufFind(uf, i)
    while uf.parent[i] ~= i do
        uf.parent[i] = uf.parent[uf.parent[i]]
        i = uf.parent[i]
    end
    return i
end

local function ufUnion(uf, a, b)
    local ra, rb = ufFind(uf, a), ufFind(uf, b)
    if ra == rb then
        return
    end
    if uf.rank[ra] < uf.rank[rb] then
        uf.parent[ra] = rb
    elseif uf.rank[ra] > uf.rank[rb] then
        uf.parent[rb] = ra
    else
        uf.parent[rb] = ra
        uf.rank[ra] = uf.rank[ra] + 1
    end
end

local function ufAdd(uf, i)
    if uf.parent[i] == nil then
        uf.parent[i] = i
        uf.rank[i] = 0
    end
end

-- Cursor module is published into civvaccess_shared by Boot before the
-- backends register, so Cursor.position() is normally available at Scan
-- time. The Cursor == nil branch covers the offline test harness, which
-- doesn't load the cursor module; the cx == nil branch covers very-early
-- boot where the cursor hasn't placed itself yet.
local function readCursor()
    if Cursor == nil then
        return 0, 0
    end
    local cx, cy = Cursor.position()
    if cx == nil then
        return 0, 0
    end
    return cx, cy
end

-- Walk a cluster's cell list, drop cells whose plot is now revealed
-- (compacting in place), and return the nearest survivor to (cx, cy).
-- Returns nil when no cells survive. Used at Scan time (where every cell
-- is already unrevealed, so the prune step is a no-op and the function
-- collapses to "nearest cell to cursor") and at ValidateEntry time (where
-- some cells may have been revealed since the snapshot was built).
local function pruneClusterCells(cells, cx, cy, activeTeam, isDebug)
    local nearestIdx, nearestDist
    local write = 0
    for read = 1, #cells do
        local plotIndex = cells[read]
        local p = Map.GetPlotByIndex(plotIndex)
        if not p:IsRevealed(activeTeam, isDebug) then
            write = write + 1
            cells[write] = plotIndex
            local d = Map.PlotDistance(cx, cy, p:GetX(), p:GetY())
            if nearestDist == nil or d < nearestDist then
                nearestDist = d
                nearestIdx = plotIndex
            end
        end
    end
    for i = #cells, write + 1, -1 do
        cells[i] = nil
    end
    return nearestIdx
end

function ScannerBackendTerrain.Scan(_activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    local unexploredUF = ufMake()
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and not plot:IsRevealed(activeTeam, isDebug) then
            -- Unrevealed branch: add to the cluster pool and union with
            -- the six hex neighbours that are also unrevealed. The
            -- neighbour walk doesn't try to limit itself to lower-index
            -- (already-seen) plots; ufUnion is idempotent and adding the
            -- forward-iteration neighbour now keeps the second pass over
            -- the parent map from picking up an isolated singleton when
            -- its only connections are below it in the scan order.
            ufAdd(unexploredUF, i)
            local px, py = plot:GetX(), plot:GetY()
            for _, dir in ipairs(HEX_NEIGHBOR_DIRS) do
                local n = Map.PlotDirection(px, py, dir)
                if n ~= nil and not n:IsRevealed(activeTeam, isDebug) then
                    local ni = n:GetPlotIndex()
                    ufAdd(unexploredUF, ni)
                    ufUnion(unexploredUF, i, ni)
                end
            end
        elseif plot ~= nil then
            local terrainId = plot:GetTerrainType()
            if terrainId ~= nil and terrainId >= 0 then
                local isLake = plot:IsLake()
                local row = GameInfo.Terrains[terrainId]
                if isLake then
                    out[#out + 1] = {
                        plotIndex = i,
                        backend = ScannerBackendTerrain,
                        data = { kind = "base", terrainId = terrainId, isLake = true },
                        category = "terrain",
                        subcategory = "base",
                        itemName = Text.key(LAKE_KEY),
                        key = "terrain:base:" .. i,
                        sortKey = 0,
                    }
                elseif row ~= nil and row.Description ~= nil then
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

            if plot:IsFreshWater() then
                out[#out + 1] = {
                    plotIndex = i,
                    backend = ScannerBackendTerrain,
                    data = { kind = "freshwater" },
                    category = "terrain",
                    subcategory = "freshwater",
                    itemName = Text.key(FRESH_WATER_KEY),
                    key = "terrain:freshwater:" .. i,
                    sortKey = 0,
                }
            end
        end
    end

    -- Second pass: gather union-find roots into cluster cell lists and
    -- emit one entry per cluster. The minimum plot index in each cluster
    -- is its stable key suffix; that cell stays in the same cluster
    -- across rebuilds until it itself gets revealed, so the user's
    -- "current instance" survives reveals at the cluster edge.
    local clusters = {}
    for plotIndex, _ in pairs(unexploredUF.parent) do
        local root = ufFind(unexploredUF, plotIndex)
        local cluster = clusters[root]
        if cluster == nil then
            cluster = { cells = {}, minIndex = plotIndex }
            clusters[root] = cluster
        end
        cluster.cells[#cluster.cells + 1] = plotIndex
        if plotIndex < cluster.minIndex then
            cluster.minIndex = plotIndex
        end
    end

    local cx, cy = readCursor()
    for _, cluster in pairs(clusters) do
        local repIndex = pruneClusterCells(cluster.cells, cx, cy, activeTeam, isDebug)
        out[#out + 1] = {
            plotIndex = repIndex,
            backend = ScannerBackendTerrain,
            data = { kind = "unexplored", cells = cluster.cells },
            category = "terrain",
            subcategory = "base",
            itemName = Text.key(UNEXPLORED_KEY),
            key = "terrain:unexplored:" .. cluster.minIndex,
            sortKey = 0,
        }
    end

    return out
end

function ScannerBackendTerrain.ValidateEntry(entry, cursorPlotIndex)
    local kind = entry.data.kind
    if kind == "unexplored" then
        local activeTeam = Game.GetActiveTeam()
        local isDebug = Game.IsDebugMode()
        local cx, cy = 0, 0
        if cursorPlotIndex ~= nil then
            local cursorPlot = Map.GetPlotByIndex(cursorPlotIndex)
            cx, cy = cursorPlot:GetX(), cursorPlot:GetY()
        end
        local nearestIdx = pruneClusterCells(entry.data.cells, cx, cy, activeTeam, isDebug)
        if nearestIdx == nil then
            return false
        end
        entry.plotIndex = nearestIdx
        return true
    end

    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    if not plot:IsRevealed(activeTeam, isDebug) then
        return false
    end
    if kind == "base" then
        if plot:GetTerrainType() ~= entry.data.terrainId then
            return false
        end
        return plot:IsLake() == (entry.data.isLake == true)
    elseif kind == "feature" then
        return plot:GetFeatureType() == entry.data.featureId
    elseif kind == "mountain" then
        return plot:IsMountain()
    elseif kind == "hills" then
        return plot:IsHills()
    elseif kind == "freshwater" then
        return plot:IsFreshWater()
    end
    return false
end

function ScannerBackendTerrain.FormatName(entry)
    if entry.data.kind == "unexplored" then
        local count = #entry.data.cells
        if count <= 1 then
            return Text.key(UNEXPLORED_KEY)
        end
        return Text.format(UNEXPLORED_CLUSTER_KEY, count)
    end
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendTerrain)

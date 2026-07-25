-- Scanner backend: geography. Enumerates the distinct landmasses and
-- bodies of open water the player has explored, as two numbered lists
-- under the Geography category (landmasses sub, oceans sub).
--
-- Clustering: revealed plots are union-find clustered on 6-neighbor hex
-- adjacency, split by domain -- land plots into landmass clusters,
-- non-lake water plots into ocean clusters. Lake plots are skipped
-- entirely; a lake reads as lake terrain on the land around it (the
-- terrain backend owns that) and never forms a body of water here.
--
-- The clustering deliberately follows what the player has revealed, NOT
-- the engine's true area connectivity. The engine knows (via plot:Area)
-- that two coastlines belong to one continent even when the land between
-- them is fogged; grouping on that would leak the link before the player
-- has seen it. So two disconnected revealed patches of the same continent
-- surface as two landmasses until the connecting tiles are revealed, at
-- which point the next rebuild merges them. Nothing about an unexplored
-- mass is ever announced: a mass with no revealed tiles produces no
-- cluster at all.
--
-- Numbering: clusters are ranked by hex distance from the player's
-- capital (nearest cell) and numbered from 1, so the home mass -- the one
-- holding the capital, distance 0 -- is always landmass 1. Before the
-- capital is founded the origin falls back to a city, then a unit, so the
-- starting settler's mass still numbers 1. The ordinal is a stable label,
-- not the list order: the snapshot still sorts items by proximity to the
-- cursor like every other scanner category.
--
-- Player-given names (CivVAccess_MassNames, Ctrl+N) replace the ordinal
-- in the item label and readout for masses the player has named; the
-- ordinal remains the label for unnamed masses and the stable fallback.
--
-- "Fully revealed": appended to a mass's readout when the player has
-- charted every tile of the underlying engine area (revealed == total for
-- the active team). This can only be true when nothing is hidden, so it
-- leaks nothing -- the engine's total tile count is never exposed, only
-- the equality is. A partially-explored continent (including the
-- two-patch case above) reports just its revealed hex count.

ScannerBackendGeography = {
    name = "geography",
}

local LANDMASS_KEY = "TXT_KEY_CIVVACCESS_SCANNER_LANDMASS"
local OCEAN_KEY = "TXT_KEY_CIVVACCESS_SCANNER_OCEAN"
local MASS_HEXES_KEY = "TXT_KEY_CIVVACCESS_SCANNER_MASS_HEXES"
local MASS_FULLY_REVEALED_KEY = "TXT_KEY_CIVVACCESS_SCANNER_MASS_FULLY_REVEALED"

-- kind -> (name key, subcategory). Iterated to emit both domains and read
-- by FormatName to rebuild the localized name from the stored ordinal.
local NAME_KEY = { landmass = LANDMASS_KEY, ocean = OCEAN_KEY }

-- Player-given name for the mass containing plot index `idx`, or nil for
-- an unnamed mass. MassNames maintains its own persistent clustering over
-- the same revealed set with the same domain split, so any cell of one of
-- this backend's clusters resolves to the same record. Nil-guarded for
-- the offline harness's bare polyfill (suites that don't load MassNames
-- keep the ordinal labels).
local function userName(idx)
    if MassNames == nil then
        return nil
    end
    local rec = MassNames.resolve(idx)
    if rec == nil then
        return nil
    end
    return rec.name
end

local HEX_NEIGHBOR_DIRS = {
    DirectionTypes.DIRECTION_NORTHEAST,
    DirectionTypes.DIRECTION_EAST,
    DirectionTypes.DIRECTION_SOUTHEAST,
    DirectionTypes.DIRECTION_SOUTHWEST,
    DirectionTypes.DIRECTION_WEST,
    DirectionTypes.DIRECTION_NORTHWEST,
}

-- Union-find over plot indices, allocated fresh per Scan (the revealed set
-- changes every rebuild). Sparse hash tables rather than full plot-count
-- arrays because revealed plots are a subset and most of a fresh map is
-- still fog. Mirrors the terrain backend's unexplored-cluster machinery;
-- kept file-local rather than shared because the two backends cluster
-- opposite plot sets and coupling them would buy little.
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

-- Which union-find a revealed plot belongs to: the land pool for land
-- plots, the water pool for non-lake water, nil for lakes (skipped). The
-- pools are passed in so the same predicate routes both the plot and its
-- neighbours during the adjacency walk.
local function poolFor(plot, landUF, waterUF)
    if plot:IsWater() then
        if plot:IsLake() then
            return nil
        end
        return waterUF
    end
    return landUF
end

-- Cursor module is published into civvaccess_shared by Boot before the
-- backends register, so Cursor.position() is normally available at Scan
-- time. The Cursor == nil branch covers the offline test harness; the
-- cx == nil branch covers very-early boot before the cursor has placed
-- itself.
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

-- Distance origin for the ordinal ranking: the player's capital, so the
-- home mass numbers 1. Falls back to the first city, then the first unit's
-- plot, so a pre-capital start still anchors on the settler's mass.
-- Re-resolved every Scan -- never cached (capital can be lost or moved).
local function numberingOrigin(activePlayer)
    local player = Players[activePlayer]
    if player == nil then
        return readCursor()
    end
    local capital = player:GetCapitalCity()
    if capital ~= nil then
        local plot = capital:Plot()
        return plot:GetX(), plot:GetY()
    end
    for city in player:Cities() do
        local plot = city:Plot()
        if plot ~= nil then
            return plot:GetX(), plot:GetY()
        end
    end
    for unit in player:Units() do
        local plot = unit:GetPlot()
        if plot ~= nil then
            return plot:GetX(), plot:GetY()
        end
    end
    return readCursor()
end

-- Gather a union-find's roots into cluster cell lists and emit one ScanEntry
-- per cluster. Each cluster carries its capital distance (min over cells)
-- for the ordinal sort and a representative cell (nearest to the cursor)
-- as the jump target. minIndex is the stable key suffix so the user's
-- "current mass" survives a rebuild even as the ordinal shifts.
local function emitClusters(out, uf, kind, subcategory, capX, capY, curX, curY)
    local clusters = {}
    for plotIndex, _ in pairs(uf.parent) do
        local root = ufFind(uf, plotIndex)
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

    local list = {}
    for _, cluster in pairs(clusters) do
        local capDist, repIndex, repDist
        for _, idx in ipairs(cluster.cells) do
            local plot = Map.GetPlotByIndex(idx)
            local px, py = plot:GetX(), plot:GetY()
            local dCap = Map.PlotDistance(capX, capY, px, py)
            if capDist == nil or dCap < capDist then
                capDist = dCap
            end
            local dCur = Map.PlotDistance(curX, curY, px, py)
            if repDist == nil or dCur < repDist then
                repDist = dCur
                repIndex = idx
            end
        end
        cluster.capDist = capDist
        cluster.repIndex = repIndex
        list[#list + 1] = cluster
    end

    -- Capital distance ascending; minIndex breaks ties so the ordinals are
    -- deterministic across rebuilds (Lua's pairs() order is not).
    table.sort(list, function(a, b)
        if a.capDist ~= b.capDist then
            return a.capDist < b.capDist
        end
        return a.minIndex < b.minIndex
    end)

    for ordinal, cluster in ipairs(list) do
        out[#out + 1] = {
            plotIndex = cluster.repIndex,
            backend = ScannerBackendGeography,
            data = { kind = kind, cells = cluster.cells, ordinal = ordinal },
            category = "geography",
            subcategory = subcategory,
            -- A player-named mass is listed under its name; the ordinal
            -- label covers the unnamed rest.
            itemName = userName(cluster.repIndex) or Text.format(NAME_KEY[kind], ordinal),
            key = "geography:" .. kind .. ":" .. cluster.minIndex,
            sortKey = 0,
        }
    end
end

function ScannerBackendGeography.Scan(activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    local landUF = ufMake()
    local waterUF = ufMake()
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and plot:IsRevealed(activeTeam, isDebug) then
            local uf = poolFor(plot, landUF, waterUF)
            if uf ~= nil then
                ufAdd(uf, i)
                local px, py = plot:GetX(), plot:GetY()
                for _, dir in ipairs(HEX_NEIGHBOR_DIRS) do
                    local n = Map.PlotDirection(px, py, dir)
                    if n ~= nil and n:IsRevealed(activeTeam, isDebug) and poolFor(n, landUF, waterUF) == uf then
                        local ni = n:GetPlotIndex()
                        ufAdd(uf, ni)
                        ufUnion(uf, i, ni)
                    end
                end
            end
        end
    end

    local capX, capY = numberingOrigin(activePlayer)
    local curX, curY = readCursor()
    emitClusters(out, landUF, "landmass", "landmasses", capX, capY, curX, curY)
    emitClusters(out, waterUF, "ocean", "oceans", capX, capY, curX, curY)
    return out
end

-- Re-center the jump target on the nearest cluster cell to the live cursor.
-- Cells never go stale between Scan and announce -- a revealed tile never
-- un-reveals and land/water never changes -- so there is nothing to prune;
-- the cluster is valid as long as it holds cells (always true post-Scan).
function ScannerBackendGeography.ValidateEntry(entry, cursorPlotIndex)
    local cells = entry.data.cells
    local cx, cy = 0, 0
    if cursorPlotIndex ~= nil then
        local cursorPlot = Map.GetPlotByIndex(cursorPlotIndex)
        if cursorPlot ~= nil then
            cx, cy = cursorPlot:GetX(), cursorPlot:GetY()
        end
    end
    local nearestIdx, nearestDist
    for _, idx in ipairs(cells) do
        local plot = Map.GetPlotByIndex(idx)
        if plot ~= nil then
            local d = Map.PlotDistance(cx, cy, plot:GetX(), plot:GetY())
            if nearestDist == nil or d < nearestDist then
                nearestDist = d
                nearestIdx = idx
            end
        end
    end
    if nearestIdx == nil then
        return false
    end
    entry.plotIndex = nearestIdx
    return true
end

-- True when the player has revealed every tile of the engine area the
-- cluster sits in. All of a land cluster's cells share one land area (and
-- a water cluster's one non-lake water area), so sampling the first cell
-- is enough. Reads the true total only to compare against revealed; the
-- total is never spoken, so the equality leaks nothing.
local function isFullyRevealed(cells)
    if #cells == 0 then
        return false
    end
    local area = Map.GetPlotByIndex(cells[1]):Area()
    return area:GetNumRevealedTiles(Game.GetActiveTeam()) >= area:GetNumTiles()
end

function ScannerBackendGeography.FormatName(entry)
    local data = entry.data
    local name = userName(data.cells[1]) or Text.format(NAME_KEY[data.kind], data.ordinal)
    local count = #data.cells
    local body = Text.formatPlural(MASS_HEXES_KEY, count, name, count)
    if isFullyRevealed(data.cells) then
        return Text.format(MASS_FULLY_REVEALED_KEY, body)
    end
    return body
end

ScannerCore.registerBackend(ScannerBackendGeography)

-- Shared hex-grid math. directionString turns a (from) to (to) delta
-- into the spoken cardinal form ("4e, 5ne") that the scanner's End key
-- and the surveyor rely on. coordinateString turns a plot's offset
-- coords into a capital-relative (x, y) pair for Shift+S, the optional
-- cursor-move prefix, and the optional scanner coord splice. Composition
-- in one place guarantees byte-identical output across callers; a future
-- format change lands here and applies to all of them.
--
-- directionString contract: identical endpoints return the empty
-- string. Each caller supplies its own "at origin" TXT_KEY
-- (SCANNER_HERE for the scanner) rather than overloading this module
-- with a zero-delta token that every caller would want to override.

HexGeom = {}

local function offsetToCube(col, row)
    -- Odd-row offset -> axial: q = col - (row - (row%2)) / 2; r = row.
    -- Lua 5.1 has no integer / or bit-and; (row - row%2) is always even so
    -- the / 2 yields an integer-valued float and arithmetic stays exact.
    local q = col - (row - (row % 2)) / 2
    local r = row
    -- Cube (x, y, z) = (q, -q - r, r).
    return q, -q - r, r
end

local function cubeToOffset(x, _y, z)
    local row = z
    local col = x + (row - (row % 2)) / 2
    return col, row
end

-- Cube delta D decomposes into a*u + b*v where (u, v) is one of the six
-- adjacent CW pairs from E. Each pair has a closed-form solution; pick
-- the first one whose (a, b) are both non-negative. The output is then
-- sorted into a fixed CW-from-E direction order regardless of which pair
-- produced it -- the user's mental model is "always read E before NE,"
-- not "read whichever pair the math chose first."
local function decomposeCube(dx, dy, dz)
    local counts = { E = 0, SE = 0, SW = 0, W = 0, NW = 0, NE = 0 }
    if dy <= 0 and dz <= 0 then
        counts.E, counts.SE = -dy, -dz
    elseif dx >= 0 and dy >= 0 then
        counts.SE, counts.SW = dx, dy
    elseif dz <= 0 and dx <= 0 then
        counts.SW, counts.W = -dz, -dx
    elseif dy >= 0 and dz >= 0 then
        counts.W, counts.NW = dy, dz
    elseif dx <= 0 and dy <= 0 then
        counts.NW, counts.NE = -dx, -dy
    else -- dz >= 0 and dx >= 0
        counts.NE, counts.E = dz, dx
    end
    return counts
end

local OUTPUT_ORDER = {
    { dir = "E", key = "TXT_KEY_CIVVACCESS_DIR_E" },
    { dir = "SE", key = "TXT_KEY_CIVVACCESS_DIR_SE" },
    { dir = "SW", key = "TXT_KEY_CIVVACCESS_DIR_SW" },
    { dir = "W", key = "TXT_KEY_CIVVACCESS_DIR_W" },
    { dir = "NW", key = "TXT_KEY_CIVVACCESS_DIR_NW" },
    { dir = "NE", key = "TXT_KEY_CIVVACCESS_DIR_NE" },
}

-- Map engine DirectionTypes constant to the spoken short-token TXT_KEY.
-- Used by stepListString; populated lazily because DirectionTypes isn't
-- defined when this file dofiles in some test setups.
local function dirKey(dir)
    if dir == DirectionTypes.DIRECTION_EAST then
        return "TXT_KEY_CIVVACCESS_DIR_E"
    elseif dir == DirectionTypes.DIRECTION_SOUTHEAST then
        return "TXT_KEY_CIVVACCESS_DIR_SE"
    elseif dir == DirectionTypes.DIRECTION_SOUTHWEST then
        return "TXT_KEY_CIVVACCESS_DIR_SW"
    elseif dir == DirectionTypes.DIRECTION_WEST then
        return "TXT_KEY_CIVVACCESS_DIR_W"
    elseif dir == DirectionTypes.DIRECTION_NORTHWEST then
        return "TXT_KEY_CIVVACCESS_DIR_NW"
    elseif dir == DirectionTypes.DIRECTION_NORTHEAST then
        return "TXT_KEY_CIVVACCESS_DIR_NE"
    end
    return nil
end

-- Returns the concatenated "<n><short-token>, ..." decomposition of the
-- (fromX, fromY) -> (toX, toY) delta. Empty string at zero delta.
function HexGeom.directionString(fromX, fromY, toX, toY)
    if fromX == toX and fromY == toY then
        return ""
    end
    local fx, fy, fz = offsetToCube(fromX, fromY)
    local tx, ty, tz = offsetToCube(toX, toY)
    local counts = decomposeCube(tx - fx, ty - fy, tz - fz)
    local parts = {}
    for _, d in ipairs(OUTPUT_ORDER) do
        local n = counts[d.dir]
        if n > 0 then
            parts[#parts + 1] = tostring(n) .. Text.key(d.key)
        end
    end
    return table.concat(parts, ", ")
end

-- Run-length encoded list of step directions: [E, E, SE, NW, NW, NW]
-- becomes "2e, 1se, 3nw". Distinct from directionString -- this caller
-- (move-path preview) follows the engine pathfinder's actual node chain,
-- which can change direction many times around obstacles, while
-- directionString only decomposes a single endpoint-to-endpoint delta.
-- Empty list returns "".
function HexGeom.stepListString(directions)
    if directions == nil or #directions == 0 then
        return ""
    end
    local parts = {}
    local runDir = directions[1]
    local runCount = 1
    local function flush(dir, n)
        local key = dirKey(dir)
        if key ~= nil then
            parts[#parts + 1] = tostring(n) .. Text.key(key)
        end
    end
    for i = 2, #directions do
        if directions[i] == runDir then
            runCount = runCount + 1
        else
            flush(runDir, runCount)
            runDir = directions[i]
            runCount = 1
        end
    end
    flush(runDir, runCount)
    return table.concat(parts, ", ")
end

local NEIGHBOR_DIRS = {
    DirectionTypes.DIRECTION_NORTHEAST,
    DirectionTypes.DIRECTION_EAST,
    DirectionTypes.DIRECTION_SOUTHEAST,
    DirectionTypes.DIRECTION_SOUTHWEST,
    DirectionTypes.DIRECTION_WEST,
    DirectionTypes.DIRECTION_NORTHWEST,
}

-- Walks the engine path-node array (from Unit:GetPath, ordered start to
-- destination) and returns the run-length-encoded direction string for
-- speech. Each consecutive pair yields one step; the direction is found
-- by scanning the six neighbors of the from-plot. Empty path or single
-- node returns "".
function HexGeom.stepListFromPath(path)
    if path == nil or #path < 2 then
        return ""
    end
    local directions = {}
    for i = 1, #path - 1 do
        local fx, fy = path[i].x, path[i].y
        local tx, ty = path[i + 1].x, path[i + 1].y
        for _, dir in ipairs(NEIGHBOR_DIRS) do
            local n = Map.PlotDirection(fx, fy, dir)
            if n ~= nil and n:GetX() == tx and n:GetY() == ty then
                directions[#directions + 1] = dir
                break
            end
        end
    end
    return HexGeom.stepListString(directions)
end

-- ===== Capital-relative coordinates =====

-- Locate the active player's original capital and return its (x, y) plot
-- coords. Iterates every player slot looking for a city flagged
-- IsOriginalCapital() with GetOriginalOwner() == active player; the city
-- can sit under any owner today (capital captures move the city object,
-- not the original-capital flag). Returns (nil, nil) before the active
-- player has founded their first city.
local MAX_PLAYER_INDEX_FOR_CAPITAL = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 64

local function activeOriginalCapital()
    local activePlayerId = Game.GetActivePlayer()
    for playerId = 0, MAX_PLAYER_INDEX_FOR_CAPITAL - 1 do
        local player = Players[playerId]
        if player ~= nil then
            for city in player:Cities() do
                if city:GetOriginalOwner() == activePlayerId and city:IsOriginalCapital() then
                    local plot = city:Plot()
                    if plot ~= nil then
                        return plot:GetX(), plot:GetY()
                    end
                end
            end
        end
    end
    return nil, nil
end

-- Coordinate of (x, y) relative to the active player's original capital,
-- in modified offset notation. Y is the plot row delta. X is the
-- geometric column delta with a 0.5 row-parity correction so a NE / NW
-- step always lands on a half-coordinate regardless of which row we
-- started from. On wrap-X maps the X delta is folded into [-W/2, W/2]
-- so a tile one west of the capital reads "-1, 0" and not "W-1, 0";
-- strict inequality at the antipode means dx = +/-W/2 keeps whichever
-- sign it had, picking a side without changing the magnitude. Returns
-- "" when the active player has no original capital yet.
function HexGeom.coordinateString(x, y)
    local capX, capY = activeOriginalCapital()
    if capX == nil then
        return ""
    end
    local dy = y - capY
    local dx = (x + 0.5 * (y % 2)) - (capX + 0.5 * (capY % 2))
    if Map.IsWrapX() then
        local w = Map.GetGridSize()
        local half = w / 2
        if dx > half then
            dx = dx - w
        elseif dx < -half then
            dx = dx + w
        end
    end
    return Text.format("TXT_KEY_CIVVACCESS_COORDINATE", dx, dy)
end

-- Cube distance between two offset coords. Exposed so callers that already
-- hold plots and need a sort key don't reconstruct the cube math.
function HexGeom.cubeDistance(x1, y1, x2, y2)
    local ax, ay, az = offsetToCube(x1, y1)
    local bx, by, bz = offsetToCube(x2, y2)
    return (math.abs(ax - bx) + math.abs(ay - by) + math.abs(az - bz)) / 2
end

-- Clockwise-from-E ordering key for two plots at equal cube distance from
-- a center: lower rank comes first. Used by surveyor scopes to break ties
-- among plots at the same radius ring. Ordering mirrors OUTPUT_ORDER so a
-- caller that already speaks directions via directionString hears tiebreaks
-- in the same sequence.
local DIRECTION_RANK = { E = 1, SE = 2, SW = 3, W = 4, NW = 5, NE = 6 }

function HexGeom.directionRank(cx, cy, tx, ty)
    if cx == tx and cy == ty then
        return 0
    end
    local fx, fy, fz = offsetToCube(cx, cy)
    local ttx, tty, ttz = offsetToCube(tx, ty)
    local counts = decomposeCube(ttx - fx, tty - fy, ttz - fz)
    for _, d in ipairs(OUTPUT_ORDER) do
        if counts[d.dir] > 0 then
            return DIRECTION_RANK[d.dir]
        end
    end
    return 0
end

-- Returns { plots = revealed-in-range, unexplored = count }. `plots` is a
-- list of Plot userdata the active team has revealed, within cube distance
-- r of (cx, cy) inclusive. `unexplored` counts real (non-nil) in-range
-- plots that aren't revealed. Off-map positions (GetPlot returns nil) are
-- silently dropped so non-wrapped map edges don't inflate the unexplored
-- tail.
function HexGeom.plotsInRange(cx, cy, r)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    local ccx, _, ccz = offsetToCube(cx, cy)
    local plots = {}
    local unexplored = 0
    for dx = -r, r do
        local dyMin = math.max(-r, -dx - r)
        local dyMax = math.min(r, -dx + r)
        for dy = dyMin, dyMax do
            local dz = -dx - dy
            local col, row = cubeToOffset(ccx + dx, nil, ccz + dz)
            local plot = Map.GetPlot(col, row)
            if plot ~= nil then
                if plot:IsRevealed(team, debug) then
                    plots[#plots + 1] = plot
                else
                    unexplored = unexplored + 1
                end
            end
        end
    end
    return { plots = plots, unexplored = unexplored }
end

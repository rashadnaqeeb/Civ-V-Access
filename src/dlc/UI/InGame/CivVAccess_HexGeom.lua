-- Shared hex-grid direction math. Turns a (fromX, fromY) to (toX, toY)
-- delta into the spoken form ("4e, 5ne") that every cursor-relative
-- caller (cursor's Shift+S orient, scanner's End, surveyor) relies on.
-- Keeping the composition in one place guarantees byte-identical output
-- across callers; a future format change (separator, long tokens,
-- total-distance prefix) lands here and applies to all of them.
--
-- Caller contract: identical endpoints return the empty string. Each
-- caller supplies its own "at origin" TXT_KEY (AT_CAPITAL for the S key,
-- SCANNER_HERE for the scanner) rather than overloading this module with
-- a zero-delta token that every caller would want to override anyway.

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

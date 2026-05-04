-- Discriminative pathfinder diagnostics. The vanilla engine pathfinder is
-- binary -- GeneratePath returns true / false with no failure reason -- so
-- this module re-runs the search with progressively relaxed flag combos
-- until a relaxation succeeds. The first relaxation that recovers the
-- path names the cause; if none do, the destination is genuinely
-- unreachable and we fall back to the closed-list closest tile (read
-- from m_pClosed via the engine-fork Game.GetClosestSearchedPlot).
--
-- Retry order is causally meaningful, not arbitrary: the first cause that
-- recovers the path is the one we report.
--
--   1. Strict
--   2. MOVE_DECLARE_WAR        -- closed borders / would-declare-war
--   3. MOVE_IGNORE_STACKING    -- your own same-type unit blocking
--   4. MOVE_UNITS_THROUGH_ENEMY -- at-war foreign units in path
--   5. None work -> closest-reached fallback via closed list
--
-- Once a relaxation recovers the path, we binary-search along the relaxed
-- path running the STRICT pathfinder against each intermediate tile. The
-- largest path index strict can reach is the closest reachable; the next
-- index along is the blocker tile. The team / unit on the blocker tile
-- names the cause concretely. This walks the actual pathfinder gates
-- rather than re-implementing them in Lua, so it stays correct as the
-- engine evolves and handles every PathValid corner the binary check
-- captures.

PathDiagnostic = {}

-- Pathfinder flag bits from CvDefines.h. Hardcoded here because the
-- engine doesn't expose them as Lua-side enums and we don't want to
-- shadow them through GameInfo. Keep these in sync with CvAStar.h's
-- PATHFINDER FLAGS section.
local MOVE_IGNORE_STACKING = 0x00000004
local MOVE_DECLARE_WAR = 0x00000020
local MOVE_UNITS_THROUGH_ENEMY = 0x00000010
-- Engine-fork-only flag (CvAStar.h). Forces PathDestValid to accept any
-- destination so the search runs regardless of whether the unit can
-- actually enter that tile. Used in the unreachable branch to populate
-- m_pClosed with the unit's reachable region for the closest-reachable
-- readout when the destination is fundamentally inaccessible (water for
-- non-embarking land unit, water tile with at-war unit a land unit can't
-- melee, deep ocean without Astronomy).
local MOVE_CIVVACCESS_FORCE_DEST_VALID = 0x20000000

-- Snapshot the current path's coords into a stable Lua array. Each
-- subsequent GeneratePath call wipes the unit's m_kLastPath, so the
-- binary search below needs a stable copy rather than re-fetching.
local function snapshotPath(unit)
    local path = unit:GetPath()
    local snap = {}
    for i, node in ipairs(path) do
        snap[i] = { x = node.x, y = node.y }
    end
    return snap
end

-- Binary-search the relaxed path for the largest index strict can reach.
-- Invariant: strict succeeds at path[lo], strict fails at path[hi].
-- relaxedPath[1] is the unit's start (trivially reachable, lo seeds at 1);
-- relaxedPath[#path] is the destination (strict already failed there at
-- the top of discriminativePath, hi seeds at #path).
--
-- Returns (closestNode, blockerNode) where closestNode is the last tile
-- strict reaches and blockerNode is the first tile strict can't. Either
-- can be nil for degenerate cases (path of length 1, etc.).
local function findReachabilityBoundary(unit, relaxedPath)
    local n = #relaxedPath
    if n < 2 then
        return nil, nil
    end
    local lo, hi = 1, n
    while lo + 1 < hi do
        local mid = math.floor((lo + hi) / 2)
        local node = relaxedPath[mid]
        local plot = Map.GetPlot(node.x, node.y)
        if unit:GeneratePath(plot) then
            lo = mid
        else
            hi = mid
        end
    end
    return relaxedPath[lo], relaxedPath[hi]
end

local function readClosedListClosest(targetX, targetY)
    local cx, cy, cdist = Game.GetClosestSearchedPlot(targetX, targetY)
    if cx == nil then
        return nil
    end
    return { x = cx, y = cy, distance = cdist }
end

-- Run the discriminative retry sequence. Returns one of:
--
--   { ok = "strict" }                                           -- strict succeeded
--   { ok = "declareWar", blockingTeam = T, closest = {...} }    -- only war-relax succeeded
--   { ok = "stacking", blockingUnit = U, closest = {...} }      -- only stacking-relax succeeded
--   { ok = "enemy", blockingUnit = U, closest = {...} }         -- only enemy-relax succeeded
--   { ok = "unreachable", closest = {...} or nil }              -- nothing worked
--
-- Caller decides policy: preview shows a diagnostic for any non-strict
-- ok value; commit allows "strict" and "declareWar" through (engine
-- handles war-confirm via popup) and aborts on the others.
function PathDiagnostic.discriminativePath(unit, target)
    local tx, ty = target:GetX(), target:GetY()

    if unit:GeneratePath(target) then
        return { ok = "strict" }
    end

    -- For each relaxation, if it recovers the path, snapshot the relaxed
    -- path and binary-search for the strict reachability boundary. The
    -- blocker tile (first tile strict can't reach) names the cause; the
    -- previous tile is the closest reachable.

    if unit:GeneratePath(target, MOVE_DECLARE_WAR) then
        local relaxed = snapshotPath(unit)
        local closest, blocker = findReachabilityBoundary(unit, relaxed)
        local blockingTeam = nil
        if blocker ~= nil then
            blockingTeam = Map.GetPlot(blocker.x, blocker.y):GetTeam()
        end
        return { ok = "declareWar", blockingTeam = blockingTeam, closest = closest }
    end

    if unit:GeneratePath(target, MOVE_IGNORE_STACKING) then
        local relaxed = snapshotPath(unit)
        local closest, blocker = findReachabilityBoundary(unit, relaxed)
        local blockingUnit = nil
        if blocker ~= nil then
            local plot = Map.GetPlot(blocker.x, blocker.y)
            -- Friendly stack uses Plot:GetNumFriendlyUnitsOfType against the
            -- actor; iterating units to pick one of the same general type
            -- as the actor matches the same gate PathValid uses (line 1294).
            local actorID = unit:GetID()
            for i = 0, plot:GetNumUnits() - 1 do
                local u = plot:GetUnit(i)
                if u ~= nil and u:GetID() ~= actorID and u:GetOwner() == unit:GetOwner() then
                    blockingUnit = u
                    break
                end
            end
        end
        return { ok = "stacking", blockingUnit = blockingUnit, closest = closest }
    end

    if unit:GeneratePath(target, MOVE_UNITS_THROUGH_ENEMY) then
        local relaxed = snapshotPath(unit)
        local closest, blocker = findReachabilityBoundary(unit, relaxed)
        local blockingUnit = nil
        if blocker ~= nil then
            local plot = Map.GetPlot(blocker.x, blocker.y)
            local activeTeam = Game.GetActiveTeam()
            for i = 0, plot:GetNumUnits() - 1 do
                local u = plot:GetUnit(i)
                if u ~= nil and u:GetTeam() ~= activeTeam and Teams[activeTeam]:IsAtWar(u:GetTeam()) then
                    blockingUnit = u
                    break
                end
            end
        end
        return { ok = "enemy", blockingUnit = blockingUnit, closest = closest }
    end

    -- No relaxation recovered the path. Run a force-valid exploration
    -- search to populate m_pClosed with the unit's reachable region,
    -- then read the closest tile to the original target.
    --
    -- The flag tells PathDestValid to return TRUE unconditionally, which
    -- matters because the destination might be one PathDestValid would
    -- otherwise reject before any search step runs (water target for a
    -- non-embarking land unit, water tile with an at-war unit a land
    -- unit can't melee, deep ocean without Astronomy). Without the flag
    -- the search never starts and m_pClosed is empty, so the closest-
    -- reachable readout falls back to the unit's start position --
    -- objectively wrong when there's a coastal tile next to the target.
    -- With the flag, intermediate PathValid still rejects steps the
    -- unit can't take, so the search exhausts naturally on unreachable
    -- destinations and m_pClosed has the reachable region.
    unit:GeneratePath(target, MOVE_CIVVACCESS_FORCE_DEST_VALID)
    return { ok = "unreachable", closest = readClosedListClosest(tx, ty) }
end

-- Render a unit as "[civ adjective] [unit name]" -- e.g. "Roman Warrior"
-- for the active player's units, "Mongol Worker" for foreign. The civ
-- adjective is the distinguisher; the user recognizes their own civ name
-- and infers ownership from that, so the same string format covers both
-- friendly stacking blockers and enemy blockers.
local function describeUnit(unit)
    local owner = Players[unit:GetOwner()]
    local adj = Text.key(owner:GetCivilizationAdjectiveKey())
    local name = Text.key(GameInfo.Units[unit:GetUnitType()].Description)
    return Text.format("TXT_KEY_CIVVACCESS_PATH_UNIT_DESCRIPTOR", adj, name)
end

-- Format a failure result as a TXT-formatted speech string. fromX, fromY
-- is the reference point the closest-reachable direction is measured
-- from -- in target mode this is the cursor (which equals the target
-- plot the user is pointing at), so "closest reachable northwest" reads
-- as direction from where the cursor sits. Same vocabulary the scanner /
-- bookmarks / surveyor use for spatial readouts.
function PathDiagnostic.formatFailure(diag, fromX, fromY)
    local closestDir = ""
    if diag.closest ~= nil then
        closestDir = HexGeom.directionString(fromX, fromY, diag.closest.x, diag.closest.y)
    end

    if diag.ok == "declareWar" then
        local civ = nil
        if diag.blockingTeam ~= nil and diag.blockingTeam ~= -1 then
            local team = Teams[diag.blockingTeam]
            if team ~= nil then
                local leader = Players[team:GetLeaderID()]
                if leader ~= nil then
                    civ = leader:GetCivilizationShortDescription()
                end
            end
        end
        if civ ~= nil and closestDir ~= "" then
            return Text.format("TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV", civ, closestDir)
        elseif civ ~= nil then
            return Text.format("TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_CIV_NO_DIR", civ)
        elseif closestDir ~= "" then
            return Text.format("TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS", closestDir)
        end
        return Text.key("TXT_KEY_CIVVACCESS_PATH_BLOCKED_BORDERS_NO_DIR")
    end

    -- Stacking and enemy share one shape: "blocked by [civ-adj] [unit]"
    -- with the civ adjective as the distinguisher between your-own and
    -- foreign. _FALLBACK fires only if the path walker couldn't locate
    -- a unit on the blocker tile, which can happen when the binary-
    -- search boundary lands on a tile whose blocker isn't a unit (e.g.
    -- the path's first turn-boundary tile triggered the stack gate but
    -- the unit on it has since moved).
    if diag.ok == "stacking" or diag.ok == "enemy" then
        if diag.blockingUnit ~= nil then
            local descriptor = describeUnit(diag.blockingUnit)
            if closestDir ~= "" then
                return Text.format("TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT", descriptor, closestDir)
            end
            return Text.format("TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_NO_DIR", descriptor)
        end
        if closestDir ~= "" then
            return Text.format("TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK", closestDir)
        end
        return Text.key("TXT_KEY_CIVVACCESS_PATH_BLOCKED_UNIT_FALLBACK_NO_DIR")
    end

    -- unreachable
    if closestDir ~= "" then
        return Text.format("TXT_KEY_CIVVACCESS_PATH_UNREACHABLE_CLOSEST", closestDir)
    end
    return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE")
end

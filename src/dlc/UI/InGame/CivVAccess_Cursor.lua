-- Free-roam tile cursor for blind players. Holds (x, y) -- never the live
-- plot userdata, since plot handles can outlive their freshness across
-- engine ticks; we re-resolve via Map.GetPlot at every operation. Owns the
-- owner-prefix diff (last spoken identity); composers handle everything
-- else. Keeps no other state cached -- the project rule says "the only
-- acceptable cache is a live engine handle read at speech time."

Cursor = {}

local _x, _y = nil, nil
-- Not a violation of the "never cache game state" rule: this holds "what the
-- user last heard from us," not a copy of any live game fact. The prefix diff
-- IS the feature, and a diff inherently needs a retained previous value --
-- there is no live source of "the announcement I already made." Re-querying
-- the previous tile's current ownership on each move would be strictly worse:
-- if an owner changed between two cursor steps, the player still needs to
-- hear the new name, which only happens by comparing against the retained
-- announced identity rather than against a freshly-read (and now-changed)
-- value that would match the new tile and silently suppress the prefix.
local _lastOwnerIdentity = nil

local function plotHere()
    if _x == nil then return nil end
    return Map.GetPlot(_x, _y)
end

local function setCursor(plot)
    _x, _y = plot:GetX(), plot:GetY()
    -- Flag 0 is the standard animated pan used by every base-game
    -- interactive camera move (unit select, city pan, diplomacy pan).
    -- Flag 2 appears in one spot (InGame.lua's city-screen exit) and
    -- empirically does not produce a pan from this Context.
    UI.LookAt(plot, 0)
end

-- Capital of the active player. Returns nil during the brief window before
-- the first city is settled; callers must handle nil. Re-resolved on every
-- call rather than cached -- the city ID can change (capture, destruction)
-- and a stale ID would silently stop matching the player's actual capital.
local function capitalPlot()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then return nil end
    local capital = player:GetCapitalCity()
    if capital == nil then return nil end
    return capital:Plot()
end

-- ===== Initialization =====
-- Pick the selected unit's plot if any, otherwise the capital. Boot.lua
-- calls this from the LoadScreenClose handler -- this is the "actually in
-- a game" signal; running earlier would land in pre-game-setup state.
function Cursor.init()
    local target = nil
    local unit = UI.GetHeadSelectedUnit()
    if unit ~= nil then
        target = unit:GetPlot()
    end
    if target == nil then
        target = capitalPlot()
    end
    if target == nil then
        Log.warn("Cursor.init: no selected unit and no capital; cursor unset until first move attempt")
        return
    end
    setCursor(target)
    _lastOwnerIdentity = nil
end

-- ===== Movement =====
-- Visibility is a separate axis from ownership: unexplored tiles speak the
-- "unexplored" token on every entry (a silent move loses the user across a
-- block of fog of war), fogged tiles get a leading "fog" marker over the
-- stale GetRevealed* data, and visible tiles read fully. The owner-identity
-- diff only tracks real ownership states (unclaimed / civ / city); it is
-- not touched while unexplored, so an Arabia → unexplored → Arabia walk
-- doesn't re-fire the prefix on re-entry.
local function announceForMove(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED") .. "."
    end
    local spoken, identity = PlotSections.ownerIdentity(plot)
    local glance = PlotComposers.glance(plot)
    local prefix = ""
    if identity ~= _lastOwnerIdentity then
        _lastOwnerIdentity = identity
        prefix = spoken .. ". "
    end
    if glance == "" then
        if prefix == "" then return "" end
        return spoken .. "."
    end
    return prefix .. glance .. "."
end

function Cursor.move(direction)
    if _x == nil then
        Log.warn("Cursor.move before init; ignoring")
        return ""
    end
    local next = Map.PlotDirection(_x, _y, direction)
    if next == nil then
        return Text.key("TXT_KEY_CIVVACCESS_EDGE_OF_MAP")
    end
    setCursor(next)
    return announceForMove(next)
end

-- ===== Orientation =====
local function offsetToCube(col, row)
    -- Odd-row offset → axial: q = col - (row - (row%2)) / 2; r = row.
    -- Lua 5.1 has no integer / or bit-and; (row - row%2) is always even so
    -- the / 2 yields an integer-valued float and arithmetic stays exact.
    local q = col - (row - (row % 2)) / 2
    local r = row
    -- Cube (x, y, z) = (q, -q - r, r).
    return q, -q - r, r
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
        counts.E,  counts.SE = -dy, -dz
    elseif dx >= 0 and dy >= 0 then
        counts.SE, counts.SW = dx, dy
    elseif dz <= 0 and dx <= 0 then
        counts.SW, counts.W  = -dz, -dx
    elseif dy >= 0 and dz >= 0 then
        counts.W,  counts.NW = dy, dz
    elseif dx <= 0 and dy <= 0 then
        counts.NW, counts.NE = -dx, -dy
    else  -- dz >= 0 and dx >= 0
        counts.NE, counts.E  = dz, dx
    end
    return counts
end

local ORIENT_OUTPUT_ORDER = {
    { dir = "E",  key = "TXT_KEY_CIVVACCESS_DIR_E"  },
    { dir = "SE", key = "TXT_KEY_CIVVACCESS_DIR_SE" },
    { dir = "SW", key = "TXT_KEY_CIVVACCESS_DIR_SW" },
    { dir = "W",  key = "TXT_KEY_CIVVACCESS_DIR_W"  },
    { dir = "NW", key = "TXT_KEY_CIVVACCESS_DIR_NW" },
    { dir = "NE", key = "TXT_KEY_CIVVACCESS_DIR_NE" },
}

function Cursor.orient()
    if _x == nil then
        Log.warn("Cursor.orient before init")
        return ""
    end
    local cap = capitalPlot()
    if cap == nil then
        -- The design notes a settled session is guaranteed to have a
        -- capital, so the only way here is during the pre-first-settle
        -- window or after losing all cities (the player has lost the
        -- game). Speak "unclaimed" as the closest-meaning token rather
        -- than silently dropping the request.
        return Text.key("TXT_KEY_CIVVACCESS_UNCLAIMED")
    end
    if _x == cap:GetX() and _y == cap:GetY() then
        return Text.key("TXT_KEY_CIVVACCESS_AT_CAPITAL")
    end
    local cx, cy, cz = offsetToCube(_x, _y)
    local kx, ky, kz = offsetToCube(cap:GetX(), cap:GetY())
    local counts = decomposeCube(cx - kx, cy - ky, cz - kz)
    local parts = {}
    for _, d in ipairs(ORIENT_OUTPUT_ORDER) do
        local n = counts[d.dir]
        if n > 0 then
            parts[#parts + 1] = tostring(n) .. Text.key(d.key)
        end
    end
    return table.concat(parts, ", ")
end

-- ===== Recenter on selected unit =====
function Cursor.recenter()
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then
        return Text.key("TXT_KEY_CIVVACCESS_NO_UNIT_SELECTED")
    end
    local plot = unit:GetPlot()
    setCursor(plot)
    return announceForMove(plot)
end

-- ===== Detail keys (W and X) =====
local function delegateDetail(composer)
    if _x == nil then
        Log.warn("Cursor detail key before init")
        return ""
    end
    return composer(plotHere())
end

function Cursor.economy() return delegateDetail(PlotComposers.economy) end
function Cursor.combat()  return delegateDetail(PlotComposers.combat)  end

-- Test seam: lets suites reset between cases without exposing the
-- locals. Production never calls this.
function Cursor._reset()
    _x, _y = nil, nil
    _lastOwnerIdentity = nil
end

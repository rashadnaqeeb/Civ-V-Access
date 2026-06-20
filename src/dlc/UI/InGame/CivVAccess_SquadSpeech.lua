-- Spoken readouts for the squad layer. Three shapes, all read live from the
-- engine and the roster (never cached): a per-unit row for the Left/Right
-- member cycler and the menu's unit list, the short movement status for the
-- Up/Down squad cycler, and the full status for Alt+Down.
--
-- The engine squad-movement queries (IsSquadMoving, GetSquadTurnsRemaining,
-- GetSquadMovementPreviewTurns) hang off a member unit -- the command
-- channel rides on a unit -- so the squad is addressed through any one of
-- its members. An empty squad has no member to query and reads as having no
-- units; that is also why a squad can exist (in the roster) while the engine
-- knows nothing about it.

SquadSpeech = {}

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

-- Live member handles for the squad. Re-queried every call through the seam;
-- the first member doubles as the squad's command handle for the movement
-- queries below.
local function members(num)
    return EngineData.squadMembers(activePlayer(), num)
end

-- Normalize an engine squad turn count for speech. The engine reports the
-- max path-turns across members; floor at 1 so a squad that arrives this
-- turn never speaks "0 turns left." This is the single seam for the turn
-- origin. VERIFY in-game: the VP pathfinder counts arrives-this-turn as 0,
-- so if a spoken count reads one LOW against the engine's own path numerals,
-- change this floor to `raw + 1`.
local function displayTurns(raw)
    if raw < 1 then
        return 1
    end
    return raw
end

-- Move-preview readout for Space in the move sub-mode: the turns for the
-- whole squad to finish the move to destPlot. The engine returns 0 when the
-- squad is empty or no member can reach the destination, so a 0 here is the
-- unreachable sentinel (a reachable move is >= 1), distinct from the
-- arrives-this-turn flooring above.
function SquadSpeech.movePreview(rep, destPlot)
    local raw = EngineData.squadMovePreviewTurns(rep, destPlot)
    if raw <= 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SQUAD_UNREACHABLE")
    end
    return Text.formatPlural("TXT_KEY_CIVVACCESS_SQUAD_PREVIEW_TURNS", raw, raw)
end

-- (isMoving, displayTurns) for the squad, or (false, 0) when empty / idle.
-- IsSquadMoving is the authoritative signal: the stored destination lingers
-- after arrival in the wake-each / sentry modes, so turns-remaining alone is
-- not a reliable "is moving."
local function movementState(num)
    local m = members(num)
    if #m == 0 then
        return false, 0
    end
    local rep = m[1]
    if not EngineData.squadIsMoving(rep) then
        return false, 0
    end
    return true, displayTurns(EngineData.squadTurnsRemaining(rep))
end

-- Compact unit row for the Left/Right member cycler and the menu unit list:
-- name, direction/distance from the hex cursor, HP if hurt, moves, status.
-- Delegates to UnitSpeech.unitBrief so the squad row and every other unit
-- readout share one assembly.
function SquadSpeech.unitRow(unit)
    local cx, cy = Cursor.position()
    return UnitSpeech.unitBrief(unit, cx, cy)
end

-- Cursor-relative bearing to the squad's destination ("destination 1ne, 1nw" /
-- "destination here"), or nil when the squad has no destination (or the engine
-- binding is absent). Uses HexGeom.directionString and the scanner "here" key --
-- the same bearing the cursor, bookmark, and surveyor readouts speak -- so the
-- destination reads like every other location in the mod (the scanner's compass
-- variant is scanner-scoped; everything else stays on the hex decomposition).
local function destinationPhrase(num)
    local m = members(num)
    if #m == 0 then
        return nil
    end
    local plot = EngineData.squadDestination(m[1])
    if plot == nil then
        return nil
    end
    local cx, cy = Cursor.position()
    local dx, dy = plot:GetX(), plot:GetY()
    local dir
    if cx == dx and cy == dy then
        dir = Text.key("TXT_KEY_CIVVACCESS_SCANNER_HERE")
    else
        dir = HexGeom.directionString(cx, cy, dx, dy)
        if dir == "" then
            return nil
        end
    end
    return Text.format("TXT_KEY_CIVVACCESS_SQUAD_DESTINATION", dir)
end

-- "moving, N turns left, destination <bearing>" for a moving squad, or nil when
-- idle / empty. Shared by the Up/Down scan and the Alt+Down full status so both
-- carry the destination.
local function movingPhrase(num)
    local moving, turns = movementState(num)
    if not moving then
        return nil
    end
    local parts = { Text.formatPlural("TXT_KEY_CIVVACCESS_SQUAD_MOVING", turns, turns) }
    local dest = destinationPhrase(num)
    if dest ~= nil then
        parts[#parts + 1] = dest
    end
    return table.concat(parts, ", ")
end

-- Short movement status for Up/Down: the moving phrase (with destination) when
-- the squad is mid-move, nil when idle or empty so the cycler stays silent
-- (Up/Down is an informational scan, not a navigation announcement -- the
-- action keys speak the name).
function SquadSpeech.movementStatus(num)
    return movingPhrase(num)
end

-- Full status for Alt+Down: name, unit count, movement state, wake mode, and
-- the escort flag when on. The deliberate report the silent Up/Down scan
-- omits.
function SquadSpeech.fullStatus(num)
    local parts = { SquadRoster.getName(num) }
    local m = members(num)
    local count = #m
    if count == 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS")
    else
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_SQUAD_UNIT_COUNT", count, count)
        local phrase = movingPhrase(num)
        if phrase ~= nil then
            parts[#parts + 1] = phrase
        else
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SQUAD_STATUS_IDLE")
        end
    end
    parts[#parts + 1] = SquadSpeech.wakeModeName(SquadRoster.getWakeMode(num))
    if SquadRoster.getEscort(num) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_SQUAD_ESCORT_ON")
    end
    return table.concat(parts, ", ")
end

-- Spoken name for an end-of-move wake mode (0/1/2). Shared by the menu's
-- cycler and the full-status readout so the three modes read identically
-- wherever they appear.
function SquadSpeech.wakeModeName(mode)
    if mode == SquadRoster.WAKE_EACH then
        return Text.key("TXT_KEY_CIVVACCESS_SQUAD_WAKE_EACH")
    elseif mode == SquadRoster.WAKE_ALL then
        return Text.key("TXT_KEY_CIVVACCESS_SQUAD_WAKE_ALL")
    end
    return Text.key("TXT_KEY_CIVVACCESS_SQUAD_WAKE_SENTRY")
end

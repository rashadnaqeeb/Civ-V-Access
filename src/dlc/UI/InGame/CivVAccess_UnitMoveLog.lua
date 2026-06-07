-- Per-move readout of foreign and other-human units moving in the active
-- player's view. The fork-added GameEvents.CivVAccessUnitMoved fires once per
-- hex from CvUnit::setXY (and once per teleport) with (owner, unit, fromX,
-- fromY, toX, toY); this buffers a unit's steps within a TickPump tick and,
-- on flush, run-length-encodes the direction sequence into one readout
-- ("Roman Warrior moves 2e, 1ne"). One unit's whole path lands in a single
-- ContinueMission burst, so the per-tick buffer captures the full ordered
-- step list; different units flush as the simulation processes each, pacing
-- the readouts across the turn the way combat readouts already pace.
--
-- Speech is gated per owner bucket: each move is classified (your queued
-- continuations, teammates, hostile civs, neutral civs, city-states,
-- barbarians) and speaks only when that bucket's toggle is on. The F7 Unit
-- Moves log (civvaccess_shared.unitMoveLog) is populated regardless,
-- decoupled from speech the same way RevealAnnounce's F7 surface is.
-- Visibility is filtered per step: only steps whose destination the active
-- team can see are buffered, so a unit crossing fog reads only the part you
-- could watch, and a move entirely in fog produces nothing.
--
-- Lifecycle mirrors CombatLog: the log clears at ActivePlayerTurnEnd and
-- accumulates through the AI turn and the player's next turn until the
-- following TurnEnd, so during your turn the group shows the moves you
-- waited through plus any other-human moves that landed live. Hotseat clears
-- on GameplaySetActivePlayer so one human's view doesn't bleed to the next.
--
-- Own-unit moves are included only as queued-move continuations: a unit you
-- sent on a multi-turn path advancing on turn 2+ (turn 1 is the interactive
-- commit, which UnitControlMovement already speaks). Those are filtered out
-- here via UnitControlMovement.hasPendingFor so the commit isn't double-
-- announced, and automated units are skipped. They read as "Your <unit>
-- moves <steps>", share the F7 group, and speak only when the Your-queued-
-- moves toggle is on.

UnitMoveLog = {}

-- Per-unit step buffer keyed "<ownerId>:<unitId>", with _order preserving
-- first-appearance order so a multi-unit flush speaks deterministically.
-- Entry: { ownerId, unitId, bucket, civAdjKey, unitDescKey, startX, startY,
-- lastX, lastY, dirs = { DirectionTypes... }, netOnly }. Module-local so a
-- Context re-entry drops any in-flight buffer; installListeners re-arms.
local _pending = {}
local _order = {}
local _flushScheduled = false

-- civvaccess_shared field gating speech for each owner bucket. Seeded by
-- Settings (defineBoolPref) in both the front-end and in-game Contexts, read
-- live here so a toggle takes effect on the next move. The F7 log populates
-- regardless of these; only speech is gated.
local BUCKET_FIELD = {
    own = "unitMoveOwn",
    teammate = "unitMoveTeammate",
    hostile = "unitMoveHostile",
    neutral = "unitMoveNeutral",
    cityState = "unitMoveCityState",
    barbarian = "unitMoveBarbarian",
}

local function shouldSpeak(bucket)
    local field = BUCKET_FIELD[bucket]
    return field ~= nil and civvaccess_shared[field] == true
end

function UnitMoveLog._flushBody()
    local pending, order = _pending, _order
    _pending, _order = {}, {}
    local list = civvaccess_shared.unitMoveLog
    for _, key in ipairs(order) do
        local entry = pending[key]
        -- A teleport, a fog-gap discontinuity, or a buffer that recorded no
        -- clean steps reads as net displacement -- "where it ended up" rather
        -- than a fabricated contiguous path.
        local steps
        if entry.netOnly or #entry.dirs == 0 then
            steps = HexGeom.directionString(entry.startX, entry.startY, entry.lastX, entry.lastY)
        else
            steps = HexGeom.stepListString(entry.dirs)
        end
        -- Net-zero displacement with no usable step tokens (walked out and
        -- back across a tick) speaks nothing.
        if steps ~= "" then
            -- Own continuations read "Your <unit> moves ..."; foreign reads
            -- "<civ> <unit> moves ..." so you can tell whose unit it is.
            local text
            if entry.bucket == "own" then
                text = Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVE_OWN", Text.key(entry.unitDescKey), steps)
            else
                local name = Text.unitWithCiv(entry.civAdjKey, entry.unitDescKey, nil)
                text = Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVE", name, steps)
            end
            if list == nil then
                list = {}
                civvaccess_shared.unitMoveLog = list
            end
            list[#list + 1] = {
                text = text,
                ownerId = entry.ownerId,
                unitId = entry.unitId,
                x = entry.lastX,
                y = entry.lastY,
            }
            if shouldSpeak(entry.bucket) then
                SpeechPipeline.speakQueued(text)
                MessageBuffer.append(text, "movement")
            end
        end
    end
end

function UnitMoveLog._flush()
    _flushScheduled = false
    local ok, err = pcall(UnitMoveLog._flushBody)
    if not ok then
        Log.error("UnitMoveLog: flush failed: " .. tostring(err))
    end
end

local function scheduleFlush()
    if _flushScheduled then
        return
    end
    _flushScheduled = true
    TickPump.runOnce(UnitMoveLog._flush)
end

-- Bucket a non-own owner by its relationship to the active team. City-states
-- and barbarians take their own bucket regardless of war status, checked
-- before the at-war split so a city-state you're at war with still reads as a
-- city-state, not a hostile civ. Teammates (allied into one team in MP) get
-- their own bucket rather than being dropped.
local function classifyOwnerBucket(owner, activeTeam)
    if owner:GetTeam() == activeTeam then
        return "teammate"
    end
    if owner:IsBarbarian() then
        return "barbarian"
    end
    if owner:IsMinorCiv() then
        return "cityState"
    end
    if Teams[activeTeam]:IsAtWar(owner:GetTeam()) then
        return "hostile"
    end
    return "neutral"
end

-- Classify a move into a (unit, bucket) pair, or nil to drop it. Own units log
-- only as queued continuations: skip the move while the interactive commit is
-- still resolving (UnitControlMovement speaks that) and skip automated units.
-- Non-own units must be alive, visible, and non-invisible, with a visible
-- destination so fogged movement stays silent.
local function classifyMove(ownerId, unitId, toX, toY)
    if ownerId == Game.GetActivePlayer() then
        if UnitControlMovement.hasPendingFor(unitId) then
            return nil
        end
        local unit = Players[ownerId]:GetUnitByID(unitId)
        if unit == nil or unit:IsAutomated() then
            return nil
        end
        return unit, "own"
    end
    local activeTeam = Game.GetActiveTeam()
    local owner = Players[ownerId]
    if owner == nil or not owner:IsAlive() then
        return nil
    end
    local unit = owner:GetUnitByID(unitId)
    if unit == nil or unit:IsInvisible(activeTeam, false) then
        return nil
    end
    local plot = Map.GetPlot(toX, toY)
    if plot == nil or not plot:IsVisible(activeTeam, false) then
        return nil
    end
    return unit, classifyOwnerBucket(owner, activeTeam)
end

local function onUnitMoved(ownerId, unitId, fromX, fromY, toX, toY)
    local unit, bucket = classifyMove(ownerId, unitId, toX, toY)
    if unit == nil then
        return
    end
    local key = ForeignUnitSnapshot.unitKey(ownerId, unitId)
    local entry = _pending[key]
    if entry == nil then
        -- Names resolved at first sighting (the unit may be gone by flush
        -- time) -- same reason combat snapshots its combatant names.
        local meta = ForeignUnitSnapshot.metadata(unit, ownerId, nil)
        if meta.civAdjKey == nil or meta.unitDescKey == nil then
            return
        end
        entry = {
            ownerId = ownerId,
            unitId = unitId,
            bucket = bucket,
            civAdjKey = meta.civAdjKey,
            unitDescKey = meta.unitDescKey,
            startX = fromX,
            startY = fromY,
            lastX = fromX,
            lastY = fromY,
            dirs = {},
            netOnly = false,
        }
        _pending[key] = entry
        _order[#_order + 1] = key
    end
    -- Append this hex's direction only when it's an adjacent step continuing
    -- from the last buffered hex. A non-adjacent jump (teleport) or a break in
    -- continuity -- the unit crossed a fogged tile we didn't buffer, so this
    -- step starts somewhere other than the last one ended -- can't be told as
    -- a clean step sequence, so flag the readout to fall back to net
    -- displacement rather than imply a shorter contiguous path.
    local dir = HexGeom.stepDirection(fromX, fromY, toX, toY)
    if dir ~= nil and fromX == entry.lastX and fromY == entry.lastY then
        entry.dirs[#entry.dirs + 1] = dir
    else
        entry.netOnly = true
    end
    entry.lastX, entry.lastY = toX, toY
    scheduleFlush()
end

-- Test-only seam. Production registers onUnitMoved on
-- GameEvents.CivVAccessUnitMoved in installListeners(); the offline harness
-- has no GameEvents pump, so suites call this entry directly.
UnitMoveLog._onUnitMoved = onUnitMoved

function UnitMoveLog._onTurnEnd()
    civvaccess_shared.unitMoveLog = nil
end

function UnitMoveLog._onActivePlayerChanged()
    civvaccess_shared.unitMoveLog = nil
end

-- Registers fresh listeners on every call. See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: prior-Context listener
-- closures die on load-game-from-game.
function UnitMoveLog.installListeners()
    civvaccess_shared.unitMoveLog = nil
    _pending = {}
    _order = {}
    _flushScheduled = false
    Log.installEvent(GameEvents, "CivVAccessUnitMoved", onUnitMoved, "UnitMoveLog")
    Log.installEvent(Events, "ActivePlayerTurnEnd", UnitMoveLog._onTurnEnd, "UnitMoveLog")
    if Game.IsHotSeat() then
        Log.installEvent(
            Events,
            "GameplaySetActivePlayer",
            UnitMoveLog._onActivePlayerChanged,
            "UnitMoveLog",
            "in hotseat session"
        )
    end
end

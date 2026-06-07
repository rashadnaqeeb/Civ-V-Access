-- UnitMoveLog: per-move readout of foreign / own units. Tests exercise the
-- per-unit step buffering and RLE, the visibility / ownership filters, the
-- per-owner-bucket speech gating with F7 decoupling, the bucket classification
-- (own / teammate / hostile / neutral / city-state / barbarian), the teleport
-- fallback, insertion ordering, and the clear lifecycle. HexGeom (real, loaded
-- by run.lua) does the RLE; Map.PlotDirection is stubbed to a simple
-- self-consistent neighbor convention so step directions resolve.

local T = require("support")
local M = {}

local spoken
local buffered
local fog
local warWith
local playerChangeListeners

-- dir -> (dcol, drow). Arbitrary but self-consistent: stepDirection finds the
-- dir whose PlotDirection lands on the fed destination, so the suite just has
-- to feed destinations matching this table.
local OFFSET

local function plotKey(x, y)
    return x .. "," .. y
end

local function plotAt(x, y)
    local p = {}
    function p:GetX()
        return x
    end
    function p:GetY()
        return y
    end
    function p:IsVisible(_team, _debug)
        return not fog[plotKey(x, y)]
    end
    return p
end

local function setup()
    spoken = {}
    buffered = {}
    fog = {}
    warWith = {}
    playerChangeListeners = {}
    civvaccess_shared = {}

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsNetworkMultiPlayer = function()
        return false
    end
    Game.IsOption = function(_o)
        return false
    end
    Game.IsHotSeat = function()
        return false
    end

    -- The active team (0) is at war with a team iff warWith[team] is set; tests
    -- that need a hostile owner flip the entry before stepping.
    Teams = {
        [0] = {
            IsAtWar = function(_self, otherTeam)
                return warWith[otherTeam] == true
            end,
        },
    }

    Players = {}
    GameInfo = { Units = { [100] = { Description = "Warrior" } } }

    OFFSET = {
        [DirectionTypes.DIRECTION_NORTHEAST] = { 1, 1 },
        [DirectionTypes.DIRECTION_EAST] = { 1, 0 },
        [DirectionTypes.DIRECTION_SOUTHEAST] = { 1, -1 },
        [DirectionTypes.DIRECTION_SOUTHWEST] = { -1, -1 },
        [DirectionTypes.DIRECTION_WEST] = { -1, 0 },
        [DirectionTypes.DIRECTION_NORTHWEST] = { -1, 1 },
    }
    Map = Map or {}
    Map.GetPlot = function(x, y)
        return plotAt(x, y)
    end
    Map.PlotDirection = function(x, y, dir)
        local off = OFFSET[dir]
        return plotAt(x + off[1], y + off[2])
    end
    Map.IsWrapX = function()
        return false
    end
    Map.IsWrapY = function()
        return false
    end

    local DIRTEXT = {
        TXT_KEY_CIVVACCESS_DIR_E = "e",
        TXT_KEY_CIVVACCESS_DIR_NE = "ne",
        TXT_KEY_CIVVACCESS_DIR_SE = "se",
        TXT_KEY_CIVVACCESS_DIR_SW = "sw",
        TXT_KEY_CIVVACCESS_DIR_W = "w",
        TXT_KEY_CIVVACCESS_DIR_NW = "nw",
    }
    Text = Text or {}
    Text.key = function(k)
        return DIRTEXT[k] or k
    end
    Text.format = function(k, a, b)
        if k == "TXT_KEY_CIVVACCESS_DIRECTION_STEP" then
            return tostring(a) .. b
        end
        if k == "TXT_KEY_CIVVACCESS_UNIT_MOVE" then
            return a .. " moves " .. b
        end
        if k == "TXT_KEY_CIVVACCESS_UNIT_MOVE_OWN" then
            return "Your " .. a .. " moves " .. b
        end
        return k
    end
    Text.unitWithCiv = function(adjKey, nameKey, _religion)
        return Text.key(adjKey) .. " " .. Text.key(nameKey)
    end

    SpeechPipeline = {
        speakQueued = function(t)
            spoken[#spoken + 1] = t
        end,
    }
    MessageBuffer = {
        append = function(text, category)
            buffered[#buffered + 1] = { text = text, category = category }
        end,
    }
    TickPump = { runOnce = function(_fn) end }

    -- Own-unit continuations consult this; default to "no interactive commit
    -- in flight" so a queued continuation logs. Individual tests override it.
    UnitControlMovement = {
        hasPendingFor = function(_)
            return false
        end,
    }

    GameEvents = { CivVAccessUnitMoved = { Add = function(_) end } }
    Events = {
        ActivePlayerTurnEnd = { Add = function(_) end },
        GameplaySetActivePlayer = {
            Add = function(fn)
                playerChangeListeners[#playerChangeListeners + 1] = fn
            end,
        },
    }

    ForeignUnitSnapshot = nil
    UnitMoveLog = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ForeignUnitSnapshot.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitMoveLog.lua")
end

-- Install a unit at player slot `slot`. By default team is the slot (so it
-- isn't on the active team 0) and the owner is a peaceful major civ; opts can
-- make it a teammate (team = 0), a city-state (isMinor), or a barbarian (barb).
-- Returns nothing; feed moves via step().
local function foreignUnit(slot, unitId, opts)
    opts = opts or {}
    local unit = {
        _id = unitId,
        _type = opts.type or 100,
        _invisible = opts.invisible or false,
        _automated = opts.automated or false,
    }
    function unit:GetID()
        return self._id
    end
    function unit:GetUnitType()
        return self._type
    end
    function unit:IsInvisible(_team, _debug)
        return self._invisible
    end
    function unit:IsAutomated()
        return self._automated
    end
    Players[slot] = T.fakePlayer({
        adj = opts.adj or "Roman",
        team = opts.team or slot,
        alive = opts.alive,
        isMinor = opts.isMinor,
        barb = opts.barb,
        units = { unit },
    })
end

local function step(slot, unitId, fx, fy, tx, ty)
    UnitMoveLog._onUnitMoved(slot, unitId, fx, fy, tx, ty)
end

-- ===== Tests =====

-- A unit's consecutive hexes within a tick buffer into one readout, with the
-- direction run-length-encoded, and speak when the matching bucket toggle is on
-- (a peaceful major civ buckets as neutral).
function M.test_adjacent_steps_rle_and_speech()
    setup()
    civvaccess_shared.unitMoveNeutral = true
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0) -- east
    step(1, 5, 1, 0, 2, 1) -- northeast
    UnitMoveLog._flush()
    local log = civvaccess_shared.unitMoveLog
    T.eq(#log, 1, "one buffered readout for the unit")
    T.eq(log[1].text, "Roman Warrior moves 1e, 1ne")
    T.eq(log[1].ownerId, 1)
    T.eq(log[1].unitId, 5)
    T.eq(log[1].x, 2, "jump coords are the last hex")
    T.eq(log[1].y, 1)
    T.eq(#spoken, 1, "neutral toggle speaks the readout")
    T.eq(spoken[1], "Roman Warrior moves 1e, 1ne")
end

-- All toggles off: the F7 log still populates (decoupled), but nothing is
-- spoken.
function M.test_speech_off_still_logs_f7()
    setup()
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(#civvaccess_shared.unitMoveLog, 1, "F7 logged with all toggles off")
    T.eq(#spoken, 0, "no speech when the bucket toggle is off")
end

-- The bracket-navigable message buffer mirrors what was spoken: a move enters
-- it only when its bucket toggle is on, under the movement category. F7 logs
-- either way (covered above).
function M.test_buffer_mirrors_speech_gating()
    setup()
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(#buffered, 0, "unspoken move stays out of the buffer")
    civvaccess_shared.unitMoveNeutral = true
    step(1, 5, 1, 0, 2, 0)
    UnitMoveLog._flush()
    T.eq(#buffered, 1, "spoken move enters the buffer")
    T.eq(buffered[1].text, "Roman Warrior moves 1e")
    T.eq(buffered[1].category, "movement")
end

-- A major civ at war buckets as hostile: the neutral toggle doesn't speak it,
-- the hostile toggle does. F7 logs either way.
function M.test_hostile_bucket_gated_separately_from_neutral()
    setup()
    warWith[1] = true
    civvaccess_shared.unitMoveNeutral = true
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(#civvaccess_shared.unitMoveLog, 1, "hostile move logged to F7 regardless")
    T.eq(#spoken, 0, "neutral toggle does not speak a hostile-bucket move")
    civvaccess_shared.unitMoveHostile = true
    step(1, 5, 1, 0, 2, 0)
    UnitMoveLog._flush()
    T.eq(#spoken, 1, "hostile toggle speaks the hostile move")
end

-- A city-state you're at war with still buckets as a city-state, not hostile:
-- the minor-civ check precedes the at-war split.
function M.test_city_state_routes_before_war()
    setup()
    warWith[1] = true
    civvaccess_shared.unitMoveHostile = true
    foreignUnit(1, 5, { isMinor = true })
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(#spoken, 0, "at-war city-state is not a hostile-bucket move")
    civvaccess_shared.unitMoveCityState = true
    step(1, 5, 1, 0, 2, 0)
    UnitMoveLog._flush()
    T.eq(#spoken, 1, "city-state toggle speaks it")
end

-- A barbarian buckets to its own toggle, not hostile, despite always being at
-- war.
function M.test_barbarian_routes_to_own_bucket()
    setup()
    civvaccess_shared.unitMoveHostile = true
    foreignUnit(1, 5, { barb = true })
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(#spoken, 0, "barbarian is not a hostile-bucket move")
    civvaccess_shared.unitMoveBarbarian = true
    step(1, 5, 1, 0, 2, 0)
    UnitMoveLog._flush()
    T.eq(#spoken, 1, "barbarian toggle speaks it")
end

-- A foreign player allied into the active team buckets as a teammate: logged to
-- F7 regardless, spoken only when the teammate toggle is on.
function M.test_teammate_bucket_logged_and_gated()
    setup()
    foreignUnit(1, 5, { team = 0 })
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(#civvaccess_shared.unitMoveLog, 1, "teammate move logged to F7")
    T.eq(#spoken, 0, "teammate silent without its toggle")
    civvaccess_shared.unitMoveTeammate = true
    step(1, 5, 1, 0, 2, 0)
    UnitMoveLog._flush()
    T.eq(#spoken, 1, "teammate toggle speaks it")
end

-- A step whose destination the active team can't see is not buffered, so a
-- move entirely in fog produces no readout and no log entry.
function M.test_fogged_destination_not_logged()
    setup()
    civvaccess_shared.unitMoveNeutral = true
    foreignUnit(1, 5)
    fog["1,0"] = true
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(civvaccess_shared.unitMoveLog, nil, "fogged-destination move not logged")
    T.eq(#spoken, 0)
end

-- A queued continuation of the active player's own unit (no interactive
-- commit in flight) logs and speaks as "Your <unit> ..." under the own toggle.
function M.test_own_continuation_logged()
    setup()
    civvaccess_shared.unitMoveOwn = true
    foreignUnit(0, 5, { team = 0 })
    step(0, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    local log = civvaccess_shared.unitMoveLog
    T.eq(#log, 1, "own queued continuation logged")
    T.eq(log[1].text, "Your Warrior moves 1e")
    T.eq(spoken[1], "Your Warrior moves 1e")
end

-- While the interactive commit is still resolving, the move is skipped here:
-- UnitControlMovement speaks it, so logging would double-announce.
function M.test_own_interactive_commit_skipped()
    setup()
    civvaccess_shared.unitMoveOwn = true
    UnitControlMovement.hasPendingFor = function(_)
        return true
    end
    foreignUnit(0, 5, { team = 0 })
    step(0, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(civvaccess_shared.unitMoveLog, nil, "pending commit not double-logged")
end

-- Automated own units (auto-explore / auto-worker) are dropped to avoid noise.
function M.test_own_automated_skipped()
    setup()
    civvaccess_shared.unitMoveOwn = true
    foreignUnit(0, 5, { team = 0, automated = true })
    step(0, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(civvaccess_shared.unitMoveLog, nil, "automated own unit not logged")
end

-- An invisible-to-team unit (e.g. submarine) on a visible plot is dropped.
function M.test_invisible_unit_not_logged()
    setup()
    civvaccess_shared.unitMoveNeutral = true
    foreignUnit(1, 5, { invisible = true })
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.eq(civvaccess_shared.unitMoveLog, nil, "invisible unit not logged")
end

-- A non-adjacent step (teleport / paradrop) can't be a step sequence, so the
-- readout falls back to the net displacement rather than fabricating steps.
function M.test_teleport_net_fallback()
    setup()
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 3, 0) -- three tiles east in one jump
    UnitMoveLog._flush()
    local log = civvaccess_shared.unitMoveLog
    T.eq(#log, 1)
    T.eq(log[1].text, "Roman Warrior moves 3e", "teleport reads as net displacement")
end

-- A unit crossing a fogged tile between two visible ones leaves a gap in the
-- buffered steps; rather than imply a shorter contiguous path, the readout
-- falls back to net displacement.
function M.test_fog_gap_uses_net_displacement()
    setup()
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0) -- visible east step
    -- (1,0)->(2,0) crossed fog and was dropped; the next visible step starts
    -- at (2,0), discontinuous with the last buffered hex (1,0).
    step(1, 5, 2, 0, 3, 0)
    UnitMoveLog._flush()
    local log = civvaccess_shared.unitMoveLog
    T.eq(#log, 1)
    T.eq(log[1].text, "Roman Warrior moves 3e", "fog gap reads as net displacement, not a contiguous step list")
end

-- Two units moving in the same tick produce two entries in first-moved order.
function M.test_multiple_units_insertion_order()
    setup()
    foreignUnit(1, 5)
    foreignUnit(2, 6, { team = 2 })
    step(1, 5, 0, 0, 1, 0)
    step(2, 6, 0, 0, 1, 0)
    UnitMoveLog._flush()
    local log = civvaccess_shared.unitMoveLog
    T.eq(#log, 2)
    T.eq(log[1].unitId, 5, "first-moved unit logged first")
    T.eq(log[2].unitId, 6)
end

-- The log clears at turn end, mirroring CombatLog's window.
function M.test_clear_on_turn_end()
    setup()
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.truthy(civvaccess_shared.unitMoveLog, "logged before turn end")
    UnitMoveLog._onTurnEnd()
    T.eq(civvaccess_shared.unitMoveLog, nil, "cleared at turn end")
end

-- Outside hotseat, no active-player-change listener is registered.
function M.test_no_active_player_listener_outside_hotseat()
    setup()
    UnitMoveLog.installListeners()
    T.eq(#playerChangeListeners, 0, "non-hotseat install registers no player-change listener")
end

-- In hotseat, an active-player change clears the log so one human's moves
-- don't bleed into the next player's view.
function M.test_hotseat_active_player_change_clears()
    setup()
    Game.IsHotSeat = function()
        return true
    end
    UnitMoveLog.installListeners()
    T.eq(#playerChangeListeners, 1, "hotseat install registers the player-change listener")
    foreignUnit(1, 5)
    step(1, 5, 0, 0, 1, 0)
    UnitMoveLog._flush()
    T.truthy(civvaccess_shared.unitMoveLog)
    playerChangeListeners[1](1, 0)
    T.eq(civvaccess_shared.unitMoveLog, nil, "active-player change clears the log")
end

return M

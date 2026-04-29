-- UnitControl pending-resolution tests. Drives onMissionDispatched
-- (the engine-fork hook listener) through every shape the engine can
-- present after a PUSH_MISSION net message resolves: unit reached its
-- target, unit stopped mid-path with 0 MP, unit accepted but no MP this
-- turn, unit refused outright, unit gone before dispatch landed, plus the
-- non-matching player / unit / no-pending early-return guards.
--
-- The hook is the authoritative MP resolver -- the prior frame-count
-- timeout false-fired "action failed" while the network round-trip was
-- still resolving -- so each branch's text is asserted exactly so a
-- regression that swallows a case shows up as a wrong assertion, not a
-- silent miss.

local T = require("support")
local M = {}

-- Mod-authored strings consumed by the listener and by UnitSpeech.moveResult.
-- The bare CivVAccess_Strings registry already covers most of these via the
-- run.lua dofile, but we mirror the values that show up in assertions here
-- so a single-suite run shows the literal phrases the user would hear.
local STRINGS = {
    TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN = "queued for next turn",
    TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED = "action failed",
    TXT_KEY_CIVVACCESS_UNIT_MOVED_TO = "moved, {1_Num} moves left",
    TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT = "stopped short",
    TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS = "stopped short, {1_Num} turns to arrival",
}

local spoken
local jumpedTo

-- mkUnit returns a UnitSpeech-compatible unit stub with just the fields
-- the resolution path reads (position, MP, mission queue, GeneratePath).
-- _id matches against _pending.unitID; _missionQueue length feeds the
-- "queued vs failed" branch.
local function mkUnit(opts)
    opts = opts or {}
    local u = {
        _id = opts.id or 1,
        _x = opts.x or 0,
        _y = opts.y or 0,
        _movesLeft = opts.movesLeft or 60,
        _missionQueue = opts.missionQueue or {},
        _generatePath = opts.generatePath,
    }
    function u:GetID()
        return self._id
    end
    function u:GetX()
        return self._x
    end
    function u:GetY()
        return self._y
    end
    function u:MovesLeft()
        return self._movesLeft
    end
    function u:GetMissionQueue()
        return self._missionQueue
    end
    function u:GeneratePath(targetPlot)
        if self._generatePath ~= nil then
            return self._generatePath(targetPlot)
        end
        return false, 0
    end
    return u
end

local function setup()
    -- Production strings table is populated by run.lua dofile, but the
    -- specific phrases we assert against need their templates pinned so
    -- {1_Num} substitution lands deterministically without depending on
    -- en_US's exact wording.
    for k, v in pairs(STRINGS) do
        CivVAccess_Strings = CivVAccess_Strings or {}
        CivVAccess_Strings[k] = v
    end

    Locale.ConvertTextKey = function(key, ...)
        local fmt = CivVAccess_Strings[key] or key
        local args = { ... }
        if #args == 0 then
            return fmt
        end
        return (
            fmt:gsub("{(%d+)_[^}]*}", function(n)
                local v = args[tonumber(n)]
                if v == nil then
                    return ""
                end
                return tostring(v)
            end)
        )
    end

    -- Pull in the production modules in dependency order. SpeechPipeline
    -- gets monkey-patched below to capture; Cursor.jumpTo is stubbed to
    -- record follow-jumps without pulling in the full cursor module. The
    -- cursorFollowsSelection toggle defaults off so the jump path stays
    -- inert unless a test enables it.
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitControl.lua")

    HandlerStack._reset()
    SpeechPipeline._reset()

    spoken = {}
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end

    jumpedTo = {}
    Cursor = Cursor or {}
    Cursor.jumpTo = function(x, y)
        jumpedTo[#jumpedTo + 1] = { x = x, y = y }
    end

    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.cursorFollowsSelection = false

    Game.GetActivePlayer = function()
        return 0
    end

    -- Map.GetPlot is consulted by the stopped-short branch (to call
    -- GeneratePath). Default returns a dummy plot so tests that don't
    -- override it still get a non-nil targetPlot.
    Map.GetPlot = function(_x, _y)
        return {}
    end

    -- Players[0]:GetUnitByID resolves _pending.unitID. Tests register the
    -- pending unit here; "unit gone" tests leave the slot nil.
    local activeUnits = {}
    Players[0] = {
        GetUnitByID = function(_self, id)
            return activeUnits[id]
        end,
    }
    -- Helper for tests to stage a unit visible to GetUnitByID.
    Players[0]._stage = function(unit)
        activeUnits[unit:GetID()] = unit
    end

    -- MissionTypes.MISSION_MOVE_TO is the missionType the engine fork
    -- passes through the hook; the listener doesn't switch on it but
    -- it must be present so test inputs match production shapes.
    GameInfoTypes.MISSION_MOVE_TO = 1

    -- ButtonPopupTypes is read by onPopupShown in production but not
    -- exercised here. Stub keeps the dofile happy.
    ButtonPopupTypes = ButtonPopupTypes or { BUTTONPOPUP_DECLAREWARMOVE = 999 }
end

-- Convenience: register a pending move and stage its unit on the active
-- player. Returns the unit so tests can mutate post-dispatch state
-- (move it, populate its mission queue, etc.) before firing the hook.
local function registerPendingFor(opts)
    local unit = mkUnit(opts)
    Players[0]._stage(unit)
    UnitControl.registerPending(unit, opts.targetX, opts.targetY)
    return unit
end

-- ===== Reached target =====
function M.test_dispatched_at_target_speaks_moved()
    setup()
    local unit = registerPendingFor({ id = 7, x = 0, y = 0, targetX = 1, targetY = 1 })
    unit._x, unit._y = 1, 1
    unit._movesLeft = 30
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1)
    T.eq(#spoken, 1, "exactly one speech line")
    T.eq(spoken[1].text, "moved, 0 moves left")
    T.eq(spoken[1].interrupt, false, "queued, not interrupt")
end

-- ===== Stopped mid-path with 0 MP =====
function M.test_dispatched_mid_path_zero_mp_speaks_stopped_short_with_turns()
    setup()
    local unit = registerPendingFor({
        id = 7,
        x = 0,
        y = 0,
        targetX = 5,
        targetY = 5,
        generatePath = function(_target)
            -- Engine returns iPathTurns >= 1; production drops one to
            -- get "turns to arrival" framed against the next turn.
            return true, 4
        end,
    })
    unit._x, unit._y = 2, 2
    unit._movesLeft = 0
    UnitControl._onMissionDispatched(0, 7, 1, 5, 5)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "stopped short, 3 turns to arrival")
end

function M.test_dispatched_mid_path_no_path_speaks_plain_stopped_short()
    -- GeneratePath returns false (target unreachable from the new plot --
    -- e.g. an enemy unit moved into the way). UnitSpeech.moveResult
    -- falls back to the plain "stopped short" key.
    setup()
    local unit = registerPendingFor({
        id = 7,
        x = 0,
        y = 0,
        targetX = 5,
        targetY = 5,
        generatePath = function(_target)
            return false, 0
        end,
    })
    unit._x, unit._y = 2, 2
    unit._movesLeft = 0
    UnitControl._onMissionDispatched(0, 7, 1, 5, 5)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "stopped short")
end

-- ===== Engine accepted but queued for next turn =====
function M.test_dispatched_on_start_with_queued_mission_speaks_queued()
    setup()
    local unit = registerPendingFor({
        id = 7,
        x = 3,
        y = 4,
        targetX = 5,
        targetY = 5,
        missionQueue = { { eMissionType = 1 } },
    })
    -- Unit didn't move -- 0 MP at commit, mission sits in queue under
    -- ACTIVITY_HOLD until next turn.
    UnitControl._onMissionDispatched(0, 7, 1, 5, 5)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "queued for next turn")
end

-- ===== Engine refused outright =====
function M.test_dispatched_on_start_with_empty_queue_speaks_action_failed()
    setup()
    registerPendingFor({
        id = 7,
        x = 3,
        y = 4,
        targetX = 5,
        targetY = 5,
        missionQueue = {},
    })
    UnitControl._onMissionDispatched(0, 7, 1, 5, 5)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "action failed")
end

-- ===== Unit gone before dispatch landed =====
function M.test_dispatched_unit_destroyed_silently_clears_pending()
    -- Combat killed the unit between commit and dispatch. The combat
    -- hook already announced; this listener clears _pending and stays
    -- silent so the user doesn't hear "action failed" on a unit that
    -- died.
    setup()
    UnitControl.registerPending(mkUnit({ id = 7, x = 0, y = 0 }), 1, 1)
    -- Don't stage the unit -- GetUnitByID returns nil.
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1)
    T.eq(#spoken, 0)
    -- A second dispatch must early-return on _pending == nil rather
    -- than crashing.
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1)
    T.eq(#spoken, 0)
end

-- ===== Match guards =====
function M.test_dispatched_with_no_pending_no_ops()
    setup()
    UnitControl._onMissionDispatched(0, 7, 1, 5, 5)
    T.eq(#spoken, 0)
end

function M.test_dispatched_for_other_player_no_ops()
    -- Engine fires the hook for every player's PUSH_MISSION (AI moves
    -- replay through the same dispatch on our client for sync). The
    -- player-id guard keeps us out of those.
    setup()
    local unit = registerPendingFor({ id = 7, x = 0, y = 0, targetX = 1, targetY = 1 })
    unit._x, unit._y = 1, 1
    UnitControl._onMissionDispatched(2, 7, 1, 1, 1)
    T.eq(#spoken, 0)
end

function M.test_dispatched_for_different_unit_no_ops()
    setup()
    local unit = registerPendingFor({ id = 7, x = 0, y = 0, targetX = 1, targetY = 1 })
    unit._x, unit._y = 1, 1
    -- Active player commits move on unit 7; engine processes a separate
    -- mission from the same player on unit 99 first (e.g. base UI's
    -- queued mid-flight commit). The listener must not consume our
    -- pending against that unrelated dispatch.
    UnitControl._onMissionDispatched(0, 99, 1, 1, 1)
    T.eq(#spoken, 0)
    -- The pending is still live, so the matching dispatch resolves it.
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "moved, 1 moves left")
end

-- ===== Race with SerialEventUnitMove =====
function M.test_dispatched_after_move_event_already_resolved_no_ops()
    -- In SP the per-hex SerialEventUnitMove fires inside PushMission and
    -- often resolves _pending before the post-PushMission hook fires.
    -- The dispatched listener must early-return on _pending == nil so it
    -- doesn't double-speak.
    setup()
    local unit = registerPendingFor({ id = 7, x = 0, y = 0, targetX = 1, targetY = 1 })
    unit._x, unit._y = 1, 1
    -- Simulate SerialEventUnitMove having resolved already.
    UnitControl.registerPending(unit, 1, 1)
    -- Manually clear _pending the way the move-event path would.
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1) -- arrives first
    T.eq(#spoken, 1, "first arrival speaks")
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1) -- second arrival
    T.eq(#spoken, 1, "second arrival no-ops on cleared pending")
end

-- ===== Cursor follow-jump =====
function M.test_dispatched_at_target_jumps_cursor_when_follow_enabled()
    setup()
    civvaccess_shared.cursorFollowsSelection = true
    local unit = registerPendingFor({ id = 7, x = 0, y = 0, targetX = 1, targetY = 1 })
    unit._x, unit._y = 1, 1
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1)
    T.eq(#jumpedTo, 1)
    T.eq(jumpedTo[1].x, 1)
    T.eq(jumpedTo[1].y, 1)
end

function M.test_dispatched_at_target_does_not_jump_when_follow_disabled()
    setup()
    civvaccess_shared.cursorFollowsSelection = false
    local unit = registerPendingFor({ id = 7, x = 0, y = 0, targetX = 1, targetY = 1 })
    unit._x, unit._y = 1, 1
    UnitControl._onMissionDispatched(0, 7, 1, 1, 1)
    T.eq(#jumpedTo, 0)
end

return M

-- SquadSpeech: the spoken readouts for the squad layer. Each test covers a
-- distinct shape: the Up/Down movement status is nil (silent) when the squad
-- is idle or empty and a "moving N turns" string when in transit; the move
-- preview maps the engine's 0 sentinel to a no-path message and a positive
-- count to a turns string; the full status composes name / count / movement /
-- wake-mode / escort; and the unit row delegates to UnitSpeech.unitBrief with
-- the live cursor cell.

local T = require("support")
local M = {}

local membersByNum
local moving
local turnsRemaining
local previewTurns
local destPlot

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_SquadStrings_en_US.lua")

    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.squadRoster = {}

    Modding = Modding or {}
    Modding.OpenUserData = function()
        return {
            GetValue = function()
                return nil
            end,
            SetValue = function() end,
        }
    end
    Network = Network or {}
    Network.GetMapRandSeed = function()
        return 1
    end
    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Players = { [0] = {} }

    membersByNum = {}
    moving = false
    turnsRemaining = 0
    previewTurns = 0
    destPlot = nil
    EngineData = {
        squadMembers = function(_p, num)
            return membersByNum[num] or {}
        end,
        squadIsMoving = function()
            return moving
        end,
        squadTurnsRemaining = function()
            return turnsRemaining
        end,
        squadMovePreviewTurns = function()
            return previewTurns
        end,
        squadDestination = function()
            return destPlot
        end,
    }

    -- The cursor cell the unit row reads its direction from.
    Cursor = {
        position = function()
            return 7, 8
        end,
    }
    -- unitBrief is exercised in suite_unit_speech against the real formatter;
    -- here we only verify SquadSpeech.unitRow forwards the live cursor cell.
    UnitSpeech = {
        unitBrief = function(unit, cx, cy)
            return "BRIEF:" .. tostring(unit._id) .. ":" .. tostring(cx) .. "," .. tostring(cy)
        end,
    }

    dofile("src/dlc/UI/InGame/CivVAccess_SquadRoster.lua")
    SquadRoster.hydrateForCurrentGame()
    dofile("src/dlc/UI/InGame/CivVAccess_SquadSpeech.lua")
end

local function squadWithMembers(count)
    SquadRoster.allocate() -- squad 1
    local m = {}
    for i = 1, count do
        m[i] = { _id = i }
    end
    membersByNum[1] = m
end

-- ===== movement status (Up/Down) =====

function M.test_movementStatus_nil_when_idle()
    setup()
    squadWithMembers(2)
    moving = false
    T.eq(SquadSpeech.movementStatus(1), nil, "an idle squad stays silent")
end

function M.test_movementStatus_nil_when_empty()
    setup()
    SquadRoster.allocate()
    membersByNum[1] = {}
    T.eq(SquadSpeech.movementStatus(1), nil, "an empty squad has no movement status")
end

function M.test_movementStatus_speaks_moving_with_turns()
    setup()
    squadWithMembers(2)
    moving = true
    turnsRemaining = 3
    local out = SquadSpeech.movementStatus(1)
    T.truthy(out ~= nil, "a moving squad must speak")
    T.truthy(out:find("moving", 1, true), "status must say moving: " .. tostring(out))
    T.truthy(out:find("3", 1, true), "status must carry the turn count: " .. tostring(out))
end

-- ===== move preview (Space in the move sub-mode) =====

function M.test_movePreview_no_path_on_zero_sentinel()
    setup()
    squadWithMembers(2)
    previewTurns = 0
    local out = SquadSpeech.movePreview(membersByNum[1][1], { _plot = true })
    T.eq(out, "no path", "the 0 sentinel reads as unreachable")
end

function M.test_movePreview_speaks_turns_when_reachable()
    setup()
    squadWithMembers(2)
    previewTurns = 4
    local out = SquadSpeech.movePreview(membersByNum[1][1], { _plot = true })
    T.truthy(out:find("4", 1, true), "preview must carry the turn count: " .. out)
    T.truthy(not out:find("no path", 1, true), "a reachable move is not unreachable: " .. out)
end

-- ===== full status (Alt+Down) =====

function M.test_fullStatus_composes_name_count_idle_wake()
    setup()
    squadWithMembers(2)
    SquadRoster.rename(1, "Alpha")
    moving = false
    local out = SquadSpeech.fullStatus(1)
    T.truthy(out:find("Alpha", 1, true), "leads with the name: " .. out)
    T.truthy(out:find("2 units", 1, true), "carries the member count: " .. out)
    T.truthy(out:find("idle", 1, true), "idle squad says idle: " .. out)
    T.truthy(out:find("sentry on arrival", 1, true), "carries the wake mode: " .. out)
end

function M.test_fullStatus_speaks_no_units_when_empty()
    setup()
    SquadRoster.allocate()
    membersByNum[1] = {}
    local out = SquadSpeech.fullStatus(1)
    T.truthy(out:find("no units", 1, true), "empty squad reports no units: " .. out)
end

function M.test_fullStatus_includes_escort_when_on()
    setup()
    squadWithMembers(1)
    SquadRoster.setEscort(1, true)
    local out = SquadSpeech.fullStatus(1)
    T.truthy(out:find("escorting", 1, true), "escort-on must surface in the status: " .. out)
end

function M.test_fullStatus_omits_escort_when_off()
    setup()
    squadWithMembers(1)
    SquadRoster.setEscort(1, false)
    local out = SquadSpeech.fullStatus(1)
    T.truthy(not out:find("escorting", 1, true), "escort-off must not surface: " .. out)
end

function M.test_fullStatus_speaks_moving_over_idle()
    setup()
    squadWithMembers(2)
    moving = true
    turnsRemaining = 1
    local out = SquadSpeech.fullStatus(1)
    T.truthy(out:find("moving", 1, true), "a moving squad reports moving, not idle: " .. out)
    T.truthy(not out:find("idle", 1, true), "moving squad must not also say idle: " .. out)
end

-- ===== wake-mode names =====

function M.test_wakeModeName_covers_three_modes()
    setup()
    T.eq(SquadSpeech.wakeModeName(SquadRoster.WAKE_SENTRY), "sentry on arrival")
    T.eq(SquadSpeech.wakeModeName(SquadRoster.WAKE_EACH), "wake on arrival")
    T.eq(SquadSpeech.wakeModeName(SquadRoster.WAKE_ALL), "wake when all arrive")
end

-- ===== unit row =====

function M.test_unitRow_forwards_live_cursor_cell()
    setup()
    local out = SquadSpeech.unitRow({ _id = 42 })
    T.eq(out, "BRIEF:42:7,8", "unit row must pass the unit and the live cursor cell to unitBrief")
end

-- ===== destination on the movement line =====

-- A moving squad's status appends the cursor-relative bearing to its
-- destination (HexGeom.directionString, stubbed here to isolate the composition
-- from HexGeom's internals).
function M.test_movementStatus_appends_destination_bearing()
    setup()
    squadWithMembers(1)
    moving = true
    turnsRemaining = 3
    destPlot = {
        GetX = function()
            return 10
        end,
        GetY = function()
            return 10
        end,
    }
    local origDir = HexGeom.directionString
    HexGeom.directionString = function()
        return "2ne"
    end
    local out = SquadSpeech.movementStatus(1)
    HexGeom.directionString = origDir
    T.truthy(out:find("moving", 1, true), "still says moving: " .. out)
    T.truthy(out:find("destination 2ne", 1, true), "appends the destination bearing: " .. out)
end

-- The cursor sitting on the destination tile reads "here" (the scanner key)
-- instead of a bearing.
function M.test_movementStatus_destination_here_at_cursor()
    setup()
    squadWithMembers(1)
    moving = true
    turnsRemaining = 1
    -- The cursor stub is at (7, 8); a destination on that tile is "here".
    destPlot = {
        GetX = function()
            return 7
        end,
        GetY = function()
            return 8
        end,
    }
    local out = SquadSpeech.movementStatus(1)
    T.truthy(out:find("destination", 1, true), "labels the destination: " .. out)
    T.truthy(
        out:find("TXT_KEY_CIVVACCESS_SCANNER_HERE", 1, true),
        "uses the scanner here key when the cursor is on the tile: " .. out
    )
end

-- No destination plot (binding absent or none set) appends nothing.
function M.test_movementStatus_omits_destination_when_none()
    setup()
    squadWithMembers(1)
    moving = true
    turnsRemaining = 3
    destPlot = nil
    local out = SquadSpeech.movementStatus(1)
    T.truthy(out:find("moving", 1, true), "still says moving: " .. out)
    T.truthy(not out:find("destination", 1, true), "no destination when the squad has none: " .. out)
end

-- The Alt+Down full status carries the destination too (shared moving phrase).
function M.test_fullStatus_includes_destination_when_moving()
    setup()
    squadWithMembers(2)
    moving = true
    turnsRemaining = 2
    destPlot = {
        GetX = function()
            return 10
        end,
        GetY = function()
            return 10
        end,
    }
    local origDir = HexGeom.directionString
    HexGeom.directionString = function()
        return "2ne"
    end
    local out = SquadSpeech.fullStatus(1)
    HexGeom.directionString = origDir
    T.truthy(out:find("destination 2ne", 1, true), "full status carries the destination: " .. out)
end

return M

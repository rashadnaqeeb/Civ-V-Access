-- SquadFocusCore: the map-mode focus cursor into the squad list (Up/Down)
-- and the focused squad's member list (Left/Right). The indices are clamped
-- against the live lists on every access, so each test drives a different
-- revalidation path: wrap at the ends, an empty roster / empty squad, the
-- focus surviving a list that shrank under it, and the two programmatic
-- focus setters (setSquad, focusOnUnit).

local T = require("support")
local M = {}

-- Live members per squad number, controlled per test.
local membersByNum

local function mkUnit(id, squad)
    return {
        _id = id,
        _squad = squad,
        GetID = function(self)
            return self._id
        end,
    }
end

local function setup()
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.squadRoster = {}

    -- Real roster for the squad-list source of truth; persistence is stubbed
    -- so allocate / delete don't touch disk.
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
    EngineData = {
        squadMembers = function(_player, num)
            return membersByNum[num] or {}
        end,
        squadNumber = function(unit)
            return unit._squad
        end,
    }

    dofile("src/dlc/UI/InGame/CivVAccess_SquadRoster.lua")
    SquadRoster.hydrateForCurrentGame()
    dofile("src/dlc/UI/InGame/CivVAccess_SquadFocusCore.lua")
    SquadFocusCore.reset()
end

-- Allocate `count` squads (numbers 1..count) in the roster.
local function allocate(count)
    for _ = 1, count do
        SquadRoster.allocate()
    end
end

-- ===== squad cycling =====

function M.test_currentSquad_nil_when_no_squads()
    setup()
    T.eq(SquadFocusCore.currentSquad(), nil)
end

function M.test_nextSquad_advances_then_wraps()
    setup()
    allocate(3)
    T.eq(SquadFocusCore.currentSquad(), 1, "focus starts on the first squad")
    T.eq(SquadFocusCore.nextSquad(), 2)
    T.eq(SquadFocusCore.nextSquad(), 3)
    T.eq(SquadFocusCore.nextSquad(), 1, "next past the end wraps to the first")
end

function M.test_prevSquad_wraps_backward()
    setup()
    allocate(3)
    T.eq(SquadFocusCore.prevSquad(), 3, "prev from the first wraps to the last")
    T.eq(SquadFocusCore.prevSquad(), 2)
end

function M.test_nextSquad_nil_when_no_squads()
    setup()
    T.eq(SquadFocusCore.nextSquad(), nil)
end

function M.test_focus_revalidates_when_list_shrinks()
    -- Focus is on the last squad; deleting it must clamp the cursor back into
    -- range on the next access rather than dangling past the end.
    setup()
    allocate(3)
    SquadFocusCore.nextSquad() -- 2
    SquadFocusCore.nextSquad() -- 3
    SquadRoster.delete(3)
    T.eq(SquadFocusCore.currentSquad(), 2, "deleting the focused squad clamps to the new last")
end

-- ===== unit cycling =====

function M.test_currentUnit_nil_when_squad_empty()
    setup()
    allocate(1)
    membersByNum[1] = {}
    T.eq(SquadFocusCore.currentUnit(), nil)
end

function M.test_currentUnit_nil_when_no_squad_focused()
    setup()
    T.eq(SquadFocusCore.currentUnit(), nil)
end

function M.test_nextUnit_cycles_within_focused_squad()
    setup()
    allocate(1)
    local a, b, c = mkUnit(10, 1), mkUnit(11, 1), mkUnit(12, 1)
    membersByNum[1] = { a, b, c }
    T.eq(SquadFocusCore.currentUnit(), a, "starts on the first member")
    T.eq(SquadFocusCore.nextUnit(), b)
    T.eq(SquadFocusCore.nextUnit(), c)
    T.eq(SquadFocusCore.nextUnit(), a, "wraps to the first member")
end

function M.test_prevUnit_wraps_backward()
    setup()
    allocate(1)
    local a, b = mkUnit(10, 1), mkUnit(11, 1)
    membersByNum[1] = { a, b }
    T.eq(SquadFocusCore.prevUnit(), b, "prev from the first member wraps to the last")
end

function M.test_unit_cursor_resets_when_squad_changes()
    setup()
    allocate(2)
    membersByNum[1] = { mkUnit(10, 1), mkUnit(11, 1) }
    membersByNum[2] = { mkUnit(20, 2), mkUnit(21, 2) }
    SquadFocusCore.nextUnit() -- move off the first member of squad 1
    SquadFocusCore.nextSquad() -- now on squad 2
    T.eq(SquadFocusCore.currentUnit():GetID(), 20, "switching squads lands on the new squad's first member")
end

-- ===== programmatic focus =====

function M.test_setSquad_points_focus_at_number()
    setup()
    allocate(3)
    SquadFocusCore.setSquad(3)
    T.eq(SquadFocusCore.currentSquad(), 3)
end

function M.test_setSquad_noop_for_unknown_number()
    setup()
    allocate(2)
    SquadFocusCore.nextSquad() -- focus squad 2
    SquadFocusCore.setSquad(99)
    T.eq(SquadFocusCore.currentSquad(), 2, "unknown number must leave focus unchanged")
end

function M.test_focusOnUnit_selects_squad_and_lands_on_unit()
    setup()
    allocate(2)
    local target = mkUnit(21, 2)
    membersByNum[2] = { mkUnit(20, 2), target }
    SquadFocusCore.focusOnUnit(target)
    T.eq(SquadFocusCore.currentSquad(), 2, "focus moves to the unit's squad")
    T.eq(SquadFocusCore.currentUnit():GetID(), 21, "focus lands on the unit itself")
end

function M.test_focusOnUnit_noop_for_squadless_unit()
    setup()
    allocate(1)
    membersByNum[1] = { mkUnit(10, 1) }
    SquadFocusCore.focusOnUnit(mkUnit(99, -1))
    T.eq(SquadFocusCore.currentSquad(), 1, "a unit in no squad must not move focus")
end

function M.test_focusOnUnit_noop_when_squad_not_in_roster()
    -- The unit's engine squad number isn't in the roster (an engine squad we
    -- never tracked). setSquad must report failure and focusOnUnit must leave
    -- BOTH cursors put -- not point the unit cursor into the untracked squad's
    -- member list while the squad cursor stays elsewhere.
    setup()
    allocate(2)
    membersByNum[1] = { mkUnit(10, 1) }
    membersByNum[2] = { mkUnit(20, 2), mkUnit(21, 2) }
    SquadFocusCore.nextSquad() -- focus squad 2, unit cursor on its first member
    -- Squad 5 exists in the engine but not the roster; target unit at index 2.
    membersByNum[5] = { mkUnit(49, 5), mkUnit(50, 5) }
    SquadFocusCore.focusOnUnit(mkUnit(50, 5))
    T.eq(SquadFocusCore.currentSquad(), 2, "focus stays on squad 2 (squad 5 untracked)")
    T.eq(SquadFocusCore.currentUnit():GetID(), 20, "unit cursor stays consistent with squad 2")
end

function M.test_reset_returns_focus_to_top()
    setup()
    allocate(3)
    SquadFocusCore.nextSquad()
    SquadFocusCore.nextSquad()
    SquadFocusCore.reset()
    T.eq(SquadFocusCore.currentSquad(), 1, "reset returns to the first squad")
end

return M

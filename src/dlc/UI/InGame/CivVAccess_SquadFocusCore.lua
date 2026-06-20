-- Map-mode focus state for the squad layer: which squad the Up/Down cycler
-- is on and which member the Left/Right cycler is on. The focus is mod-side
-- only -- it never changes the engine's unit selection or moves the cursor;
-- it is just the cursor into the squad list and the focused squad's member
-- list that the map bindings read and advance.
--
-- The indices are file-local session state, reset on every game load
-- (reset() from onInGameBoot). They are NOT on civvaccess_shared: focus is
-- per-seat transient state with no reason to outlive a game or cross a
-- Context, and resetting it on load is the correct behavior (a loaded game's
-- squads may differ from whatever was focused before).
--
-- Every accessor revalidates against the live squad / membership lists
-- before reading: squads get deleted and members die between presses, so a
-- stored index is clamped into range each time rather than trusted. Indices
-- are 1-based into SquadRoster.getList() (squads) and the live member list
-- (units).

SquadFocusCore = {}

local _squadIdx = 1
local _unitIdx = 1

-- Reset to the top of both lists. Called from onInGameBoot so a load-from-
-- game (or MP resync / hotseat handover that re-runs boot) starts focus
-- fresh rather than pointing at a squad from the prior game.
function SquadFocusCore.reset()
    _squadIdx = 1
    _unitIdx = 1
end

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

-- Clamp the squad cursor into the current list and return the list. An empty
-- list leaves the index at 1 (harmless; callers check the list length).
local function squadList()
    local list = SquadRoster.getList()
    if #list == 0 then
        _squadIdx = 1
    elseif _squadIdx > #list then
        _squadIdx = #list
    elseif _squadIdx < 1 then
        _squadIdx = 1
    end
    return list
end

-- The focused squad number, or nil when no squads exist.
function SquadFocusCore.currentSquad()
    local list = squadList()
    if #list == 0 then
        return nil
    end
    return list[_squadIdx]
end

-- Advance the squad cursor by dir (+1 next, -1 prev), wrapping. Resets the
-- unit cursor to the new squad's first member. Returns the new squad number,
-- or nil when no squads exist.
local function stepSquad(dir)
    local list = squadList()
    if #list == 0 then
        return nil
    end
    _squadIdx = ((_squadIdx - 1 + dir) % #list) + 1
    _unitIdx = 1
    return list[_squadIdx]
end

function SquadFocusCore.nextSquad()
    return stepSquad(1)
end

function SquadFocusCore.prevSquad()
    return stepSquad(-1)
end

-- Live members of the focused squad (empty when no squad is focused).
local function focusedMembers()
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        return {}, nil
    end
    return EngineData.squadMembers(activePlayer(), num), num
end

-- Clamp the unit cursor into the focused squad's member list and return it.
local function memberList()
    local m = focusedMembers()
    if #m == 0 then
        _unitIdx = 1
    elseif _unitIdx > #m then
        _unitIdx = #m
    elseif _unitIdx < 1 then
        _unitIdx = 1
    end
    return m
end

-- The focused member unit, or nil when the focused squad is empty / absent.
function SquadFocusCore.currentUnit()
    local m = memberList()
    if #m == 0 then
        return nil
    end
    return m[_unitIdx]
end

-- Advance the unit cursor by dir, wrapping. Returns the new member unit, or
-- nil when the focused squad is empty / absent.
local function stepUnit(dir)
    local m = memberList()
    if #m == 0 then
        return nil
    end
    _unitIdx = ((_unitIdx - 1 + dir) % #m) + 1
    return m[_unitIdx]
end

function SquadFocusCore.nextUnit()
    return stepUnit(1)
end

function SquadFocusCore.prevUnit()
    return stepUnit(-1)
end

-- Point focus at a specific squad number (e.g. after Alt+Right adds a unit
-- and the focus should move to that squad). No-op when the number isn't a
-- live squad. Resets the unit cursor to the squad's first member.
function SquadFocusCore.setSquad(num)
    local list = SquadRoster.getList()
    for i, n in ipairs(list) do
        if n == num then
            _squadIdx = i
            _unitIdx = 1
            return
        end
    end
end

-- Point focus at a specific unit: select its squad and land the unit cursor
-- on it. Used by Alt+Right so the just-added unit is the focused member and
-- an immediate Alt+Left would remove it. No-op when the unit is in no squad.
function SquadFocusCore.focusOnUnit(unit)
    local num = EngineData.squadNumber(unit)
    if num < 0 then
        return
    end
    SquadFocusCore.setSquad(num)
    local m = EngineData.squadMembers(activePlayer(), num)
    local id = unit:GetID()
    for i, u in ipairs(m) do
        if u:GetID() == id then
            _unitIdx = i
            return
        end
    end
end

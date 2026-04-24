-- Coordinator for unit-control bindings and event-driven announcements.
-- getBindings() is concat'd by BaselineHandler; installListeners() wires
-- the per-frame and per-engine-event hooks that speak result feedback.
--
-- Speech policy follows the design's "user-initiated INTERRUPT vs engine-
-- event QUEUE" split: Tab / / / Alt+QAZEDC / , / Ctrl+. / Ctrl+, go through
-- INTERRUPT; EndCombatSim and move-completion listeners speak QUEUED so
-- they race-and-lose against user speech in flight rather than clobbering
-- it. UnitSelectionChanged straddles both: the user's cycle keys drive it
-- (should interrupt) and engine flows (turn start, unit death, end of
-- move / combat reselection) also drive it (should queue). The cycle
-- sites stamp a short-lived "user-initiated" timestamp so the listener
-- can tell them apart.
--
-- Pending-move tracking bridges "commit" to "announce actual outcome".
-- On commit (Alt+QAZEDC or target-mode move-to) we stash target coords +
-- the active player's expected unit id; on the first SerialEventUnitMove
-- afterwards we compare the unit's live plot to the target and speak
-- "moved" / "stopped short". Two-tick fallback covers silently-rejected
-- commits. No cross-turn state -- pending is cleared on every resolution.
--
-- Combat moves skip pending entirely: combat animation runs for seconds
-- before the engine fires a post-advance SerialEventUnitMove (or never,
-- if the attacker loses / doesn't advance), so the two-tick timeout
-- would always trip and speak "action failed" while EndCombatSim is
-- already queuing the real outcome. EndCombatSim is the announcement
-- path for anything that hits enemyAt at commit time.

UnitControl = {}

local MOD_NONE = 0
local MOD_CTRL = 2
local MOD_ALT = 4

-- Windows VK codes for ',' '.' '/' — Civ V's Keys table exposes VK_OEM_3 /
-- VK_OEM_PLUS / VK_OEM_MINUS but not these three. InputRouter uses the same
-- numeric-literal workaround for its help hotkey.
local VK_OEM_COMMA = 188
local VK_OEM_PERIOD = 190
local VK_OEM_2 = 191

local COMBAT_CONFIRM_WINDOW_SECONDS = 1.0

-- ===== User-initiated selection flag =====
-- UnitSelectionChanged fires for both user actions (period / comma,
-- Ctrl+period / Ctrl+comma) and engine-initiated actions (turn start,
-- unit death, move / combat completion). We want interrupt for the
-- former (user asked to hear the next unit) and queued for the latter
-- (don't clobber the turn-start line or an in-flight move result).
-- Cycling sites stamp a timestamp here just before the select call;
-- the listener consumes it if fresh, falls back to queued otherwise.
-- Time-based staleness guards the case where the engine drops the
-- selection request (e.g., Game.CycleUnits with no eligible target)
-- so the flag doesn't leak into a later engine-driven selection.
local USER_SELECTION_WINDOW_SECONDS = 0.1
local _userSelectionAt = -math.huge

function UnitControl.markUserInitiatedSelection()
    _userSelectionAt = os.clock()
end

local function consumeUserInitiatedSelection()
    if (os.clock() - _userSelectionAt) < USER_SELECTION_WINDOW_SECONDS then
        _userSelectionAt = -math.huge
        return true
    end
    return false
end

-- ===== Combat-confirm state (Alt+QAZEDC two-tap) =====
local _combatConfirm = { dir = nil, clock = 0 }

local function clearCombatConfirm()
    _combatConfirm.dir = nil
    _combatConfirm.clock = 0
end

-- ===== Pending-move state =====
-- Kept module-local (not on civvaccess_shared) because a Context re-
-- entry should drop any in-flight pending move -- the listeners will
-- rehook on LoadScreenClose and a half-registered pending would never
-- resolve.
local PENDING_EXPIRY_FRAMES = 2

local _pending = nil

local function clearPending()
    _pending = nil
end

local schedulePendingExpiry

function UnitControl.registerPending(unit, targetX, targetY)
    if unit == nil then
        return
    end
    local snapshot = {
        unitID = unit:GetID(),
        startX = unit:GetX(),
        startY = unit:GetY(),
        targetX = targetX,
        targetY = targetY,
        commitFrame = TickPump.frame(),
    }
    _pending = snapshot
    schedulePendingExpiry(snapshot)
end

-- ===== Helpers =====
local function speakInterrupt(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakInterrupt(text)
end

local function speakQueued(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakQueued(text)
end

local function selectedUnit()
    return UI.GetHeadSelectedUnit()
end

local function plotAt(x, y)
    return Map.GetPlot(x, y)
end

function UnitControl.enemyAt(plot)
    if plot == nil then
        return nil
    end
    local activePlayer = Game.GetActivePlayer()
    local team = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    local teamObj = Teams[team]
    for i = 0, plot:GetNumUnits() - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and not u:IsInvisible(team, isDebug) and u:GetOwner() ~= activePlayer then
            local owner = Players[u:GetOwner()]
            if owner ~= nil and (owner:IsBarbarian() or teamObj:IsAtWar(owner:GetTeam())) then
                return u
            end
        end
    end
    return nil
end

-- ===== Cycle =====
-- Game.CycleUnits(bAllowOff, bForward, bWorker). Forward=true is the
-- base-game "CycleLeft" button -- the naming is inverted at the callers
-- (the button layout has left = "go to next", right = "go back"), so we
-- pass the direction through directly without renaming.
function UnitControl.cycleAll(forward)
    UnitControl.markUserInitiatedSelection()
    Game.CycleUnits(true, forward and true or false, false)
end

-- Reimplements CvUnitCycler's ordering (LoneGazebo/Community-Patch-DLL
-- CvGameCoreDLL_Expansion2/CvUnitCycler.cpp is the engine ground-truth
-- reference; we run stock Firaxis, so exact parity with Community Patch
-- is assumed, not guaranteed). The engine's Cycle() filters each
-- candidate by CvUnit::ReadyToSelect(), which is what makes plain . / ,
-- (via Game.CycleUnits) skip units that have moved, are fortified,
-- sleeping, or automated. For Ctrl+. / Ctrl+, we keep the spatial
-- ordering (nearest-neighbor seed plus up to five 2-opt passes) but
-- drop the filter so every active-player unit is a cycle target.
--
-- Tour is rebuilt every press. It's O(N^2) in unit count which is
-- trivially cheap at empire scale, and rebuild-every-press avoids any
-- cache-invalidation surface across turns, saves, or unit births/deaths.
local function buildUnitTour()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return nil
    end
    local units = {}
    for unit in player:Units() do
        units[#units + 1] = unit
    end
    local size = #units
    if size == 0 then
        return nil
    end
    local current = selectedUnit()
    local seedIdx = 1
    local seededFromSelection = false
    if current ~= nil and current:GetOwner() == Game.GetActivePlayer() then
        local cid = current:GetID()
        for i, u in ipairs(units) do
            if u:GetID() == cid then
                seedIdx = i
                seededFromSelection = true
                break
            end
        end
    end
    if not seededFromSelection then
        for i, u in ipairs(units) do
            if u:WorkRate(true) > 0 then
                seedIdx = i
                break
            end
        end
    end
    local tour, tourX, tourY = {}, {}, {}
    local visited = {}
    local function push(unit)
        local idx = #tour + 1
        tour[idx] = unit
        tourX[idx] = unit:GetX()
        tourY[idx] = unit:GetY()
        visited[unit:GetID()] = true
    end
    push(units[seedIdx])
    while #tour < size do
        local lastX, lastY = tourX[#tour], tourY[#tour]
        local bestDist, bestUnit = math.huge, nil
        for _, u in ipairs(units) do
            if not visited[u:GetID()] then
                local d = Map.PlotDistance(lastX, lastY, u:GetX(), u:GetY())
                if d < bestDist then
                    bestDist = d
                    bestUnit = u
                end
            end
        end
        if bestUnit == nil then
            break
        end
        push(bestUnit)
    end
    local n = #tour
    if n > 3 then
        local improved = true
        local passes = 5
        while improved and passes > 0 do
            improved = false
            passes = passes - 1
            for i = 1, n - 1 do
                for j = i + 2, n do
                    if not (i == 1 and j == n) then
                        local nextJ
                        if j == n then
                            nextJ = 1
                        else
                            nextJ = j + 1
                        end
                        local oldD = Map.PlotDistance(tourX[i], tourY[i], tourX[i + 1], tourY[i + 1])
                            + Map.PlotDistance(tourX[j], tourY[j], tourX[nextJ], tourY[nextJ])
                        local newD = Map.PlotDistance(tourX[i], tourY[i], tourX[j], tourY[j])
                            + Map.PlotDistance(tourX[i + 1], tourY[i + 1], tourX[nextJ], tourY[nextJ])
                        if newD < oldD then
                            local a, b = i + 1, j
                            while a < b do
                                tour[a], tour[b] = tour[b], tour[a]
                                tourX[a], tourX[b] = tourX[b], tourX[a]
                                tourY[a], tourY[b] = tourY[b], tourY[a]
                                a = a + 1
                                b = b - 1
                            end
                            improved = true
                        end
                    end
                end
            end
        end
    end
    return tour
end

function UnitControl.cycleAllUnits(forward)
    UnitControl.markUserInitiatedSelection()
    local tour = buildUnitTour()
    if tour == nil or #tour == 0 then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"))
        return
    end
    if #tour == 1 then
        UI.SelectUnit(tour[1])
        return
    end
    local current = selectedUnit()
    local currentIdx = 1
    if current ~= nil then
        local cid = current:GetID()
        for i, u in ipairs(tour) do
            if u:GetID() == cid then
                currentIdx = i
                break
            end
        end
    end
    local targetIdx
    if forward then
        targetIdx = currentIdx + 1
        if targetIdx > #tour then
            targetIdx = 1
        end
    else
        targetIdx = currentIdx - 1
        if targetIdx < 1 then
            targetIdx = #tour
        end
    end
    UI.SelectUnit(tour[targetIdx])
end

-- ===== Alt+QAZEDC direct move =====
local function commitDirectMove(unit, targetX, targetY, isCombat)
    if not isCombat then
        UnitControl.registerPending(unit, targetX, targetY)
    end
    Game.SelectionListGameNetMessage(
        GameMessageTypes.GAMEMESSAGE_PUSH_MISSION,
        GameInfoTypes.MISSION_MOVE_TO,
        targetX,
        targetY,
        0,
        false,
        false
    )
end

local function directMove(dir)
    local unit = selectedUnit()
    if unit == nil then
        clearCombatConfirm()
        return
    end
    local target = Map.PlotDirection(unit:GetX(), unit:GetY(), dir)
    if target == nil then
        clearCombatConfirm()
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_EDGE_OF_MAP"))
        return
    end
    local tx, ty = target:GetX(), target:GetY()
    local enemy = UnitControl.enemyAt(target)
    if enemy == nil then
        clearCombatConfirm()
        commitDirectMove(unit, tx, ty, false)
        return
    end
    -- Melee-attack confirm gate. Screen-reader users can't see the
    -- hover preview a mouse user does, so a second press within the
    -- window is the cheap "are you sure" check.
    local now = os.clock()
    if _combatConfirm.dir == dir and (now - _combatConfirm.clock) < COMBAT_CONFIRM_WINDOW_SECONDS then
        clearCombatConfirm()
        commitDirectMove(unit, tx, ty, true)
        return
    end
    _combatConfirm.dir = dir
    _combatConfirm.clock = now
    speakInterrupt(UnitSpeech.meleePreview(unit, enemy, target))
end

-- ===== Info key =====
local function speakInfo()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    speakInterrupt(UnitSpeech.info(unit))
end

-- ===== Tab action menu =====
local function openActionMenu()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    UnitActionMenu.open(unit)
end

-- ===== Bindings =====
local bind = HandlerStack.bind

function UnitControl.getBindings()
    local bindings = {
        bind(VK_OEM_PERIOD, MOD_NONE, function()
            UnitControl.cycleAll(true)
        end, "Next unit"),
        bind(VK_OEM_COMMA, MOD_NONE, function()
            UnitControl.cycleAll(false)
        end, "Previous unit"),
        bind(VK_OEM_PERIOD, MOD_CTRL, function()
            UnitControl.cycleAllUnits(true)
        end, "Next unit (including acted)"),
        bind(VK_OEM_COMMA, MOD_CTRL, function()
            UnitControl.cycleAllUnits(false)
        end, "Previous unit (including acted)"),
        bind(VK_OEM_2, MOD_NONE, speakInfo, "Unit info"),
        bind(Keys.VK_TAB, MOD_NONE, openActionMenu, "Unit action menu"),
        bind(Keys.Q, MOD_ALT, function()
            directMove(DirectionTypes.DIRECTION_NORTHWEST)
        end, "Move unit NW"),
        bind(Keys.E, MOD_ALT, function()
            directMove(DirectionTypes.DIRECTION_NORTHEAST)
        end, "Move unit NE"),
        bind(Keys.A, MOD_ALT, function()
            directMove(DirectionTypes.DIRECTION_WEST)
        end, "Move unit W"),
        bind(Keys.D, MOD_ALT, function()
            directMove(DirectionTypes.DIRECTION_EAST)
        end, "Move unit E"),
        bind(Keys.Z, MOD_ALT, function()
            directMove(DirectionTypes.DIRECTION_SOUTHWEST)
        end, "Move unit SW"),
        bind(Keys.C, MOD_ALT, function()
            directMove(DirectionTypes.DIRECTION_SOUTHEAST)
        end, "Move unit SE"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_ALL",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_ALL",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_INFO",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_INFO",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- ===== Listeners =====
local function onUnitSelectionChanged(playerID, unitID, _hexI, _hexJ, _hexK, isSelected)
    if not isSelected then
        return
    end
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    -- Skip when the city-strike picker is on top. The engine's
    -- CityScreenClosed re-selects the previously-selected unit on a
    -- delayed tick, and announcing it here would steal focus from the
    -- strike target the user just landed on. Gate on the handler-stack
    -- name rather than UI.GetInterfaceMode: the engine briefly bounces
    -- out of CITY_RANGE_ATTACK on entry (Bombardment.OnCityInfoDirty
    -- reverts when the unit-select clears the engine's city selection),
    -- and the late unit-select event tends to land during that gap, so
    -- a mode check would be racy.
    local top = HandlerStack.active()
    if top ~= nil and top.name == "CityRangeStrike" then
        return
    end
    -- If target mode is active for a different unit, unwind it. Covers
    -- unit cycling (. / ,), mouse reselect, and actor death flipping
    -- selection to another unit. Same-unit re-selects leave it in place.
    local targetActorID = UnitTargetMode.currentActorID()
    if targetActorID ~= nil and targetActorID ~= unitID then
        HandlerStack.removeByName("UnitTargetMode", false)
    end
    local player = Players[playerID]
    if player == nil then
        return
    end
    local unit = player:GetUnitByID(unitID)
    if unit == nil then
        return
    end
    local prevX, prevY = Cursor.position()
    local text = UnitSpeech.selection(unit, prevX, prevY)
    if consumeUserInitiatedSelection() then
        speakInterrupt(text)
    else
        speakQueued(text)
    end
    Cursor.jumpTo(unit:GetX(), unit:GetY())
end

-- Events.EndCombatSim args, per Community-Patch-DLL CvUnitCombat.cpp around
-- line 3306: the third arg per side is damage taken THIS combat (not the
-- unit's accumulated damage before combat); the fourth is cumulative damage
-- after combat. Naming the locals after the engine convention so the
-- subtractor doesn't get reintroduced.
local function onEndCombatSim(
    attackerPlayer,
    attackerUnit,
    attackerDamage,
    attackerFinalDamage,
    attackerMaxHP,
    defenderPlayer,
    defenderUnit,
    defenderDamage,
    defenderFinalDamage,
    defenderMaxHP
)
    local activePlayer = Game.GetActivePlayer()
    if attackerPlayer ~= activePlayer and defenderPlayer ~= activePlayer then
        return
    end
    local text = UnitSpeech.combatResult({
        attackerPlayer = attackerPlayer,
        attackerUnit = attackerUnit,
        attackerDamage = attackerDamage,
        attackerFinalDamage = attackerFinalDamage,
        attackerMaxHP = attackerMaxHP,
        defenderPlayer = defenderPlayer,
        defenderUnit = defenderUnit,
        defenderDamage = defenderDamage,
        defenderFinalDamage = defenderFinalDamage,
        defenderMaxHP = defenderMaxHP,
    })
    speakQueued(text)
end

local function resolvePendingUnit()
    if _pending == nil then
        return nil
    end
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return nil
    end
    return player:GetUnitByID(_pending.unitID)
end

-- Timeout check so a silently-rejected commit (engine dropped the
-- PUSH_MISSION, unit already out of moves, packet loss, etc.) doesn't
-- leak _pending forever and later misfire when some other SerialEvent
-- re-runs onUnitMoveCompleted. Snapshot guards against a newer commit
-- replacing the pending underneath us between reschedules.
schedulePendingExpiry = function(snapshot)
    TickPump.runOnce(function()
        if _pending ~= snapshot then
            return
        end
        if TickPump.frame() - snapshot.commitFrame < PENDING_EXPIRY_FRAMES then
            schedulePendingExpiry(snapshot)
            return
        end
        local unit = resolvePendingUnit()
        if unit ~= nil and unit:GetX() == snapshot.startX and unit:GetY() == snapshot.startY then
            speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
        end
        clearPending()
    end)
end

local function onUnitMoveCompleted()
    if _pending == nil then
        return
    end
    local unit = resolvePendingUnit()
    if unit == nil then
        -- Unit is gone (died in the attack, disbanded). The combat-end
        -- listener has already spoken the outcome; drop pending.
        clearPending()
        return
    end
    local cx, cy = unit:GetX(), unit:GetY()
    -- Stale event from a superseded pending: when a second move commits
    -- before the first's SerialEventUnitMove arrives, _pending is the
    -- new snapshot and the in-flight event belongs to the old one. The
    -- unit is sitting on the new pending's start hex (the old pending's
    -- target), so anchor the skip on that.
    if cx == _pending.startX and cy == _pending.startY then
        return
    end
    local tx, ty = _pending.targetX, _pending.targetY
    -- Only speak on a stop condition (at target OR out of moves). The
    -- engine fires SerialEventUnitMove per hex traversed, so mid-path
    -- events need to be ignored.
    local movesLeft = math.floor(unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR)
    local reachedTarget = (cx == tx and cy == ty)
    if reachedTarget or movesLeft <= 0 then
        local turnsToArrival
        if not reachedTarget then
            local targetPlot = plotAt(tx, ty)
            if targetPlot ~= nil then
                local result = Pathfinder.findPath(unit, targetPlot)
                if result ~= nil then
                    -- Pathfinder's first step treats mpRemaining==0 as
                    -- "wait for next turn," bumping its turn counter.
                    -- Here the unit has just stopped with 0 MP *this*
                    -- turn; the next move is what begins turn+1, so the
                    -- initial bump is already accounted for. Drop one.
                    turnsToArrival = result.turns - 1
                end
            end
        end
        speakQueued(UnitSpeech.moveResult(unit, tx, ty, turnsToArrival))
        Cursor.jumpTo(cx, cy)
        clearPending()
    end
end

-- Registers a fresh set of unit listeners on every call (onInGameBoot
-- invokes this once per game load). See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: load-game-from-game
-- kills the prior Context's env, stranding listeners that referenced its
-- globals. Dead listeners accumulate but throw silently on global access.
function UnitControl.installListeners()
    if Events == nil then
        Log.error("UnitControl.installListeners: Events table missing")
        return
    end
    if Events.UnitSelectionChanged ~= nil then
        Events.UnitSelectionChanged.Add(onUnitSelectionChanged)
    else
        Log.warn("UnitControl: Events.UnitSelectionChanged missing")
    end
    if Events.EndCombatSim ~= nil then
        Events.EndCombatSim.Add(onEndCombatSim)
    else
        Log.warn("UnitControl: Events.EndCombatSim missing")
    end
    if Events.SerialEventUnitMove ~= nil then
        Events.SerialEventUnitMove.Add(onUnitMoveCompleted)
    else
        Log.warn("UnitControl: Events.SerialEventUnitMove missing")
    end
    if Events.SerialEventUnitMoveToHexes ~= nil then
        Events.SerialEventUnitMoveToHexes.Add(onUnitMoveCompleted)
    else
        Log.warn("UnitControl: Events.SerialEventUnitMoveToHexes missing")
    end
end

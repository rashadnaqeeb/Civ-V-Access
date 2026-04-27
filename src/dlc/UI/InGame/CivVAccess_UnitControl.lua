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
-- Quick Movement support: with the option enabled the engine routes per-
-- hex moves through CvUnit::SetPosition (gDLL->GameplayUnitTeleported)
-- instead of QueueMoveForVisualization (gDLL->GameplayUnitMoved), so the
-- SerialEventUnitMove(ToHexes) events the pending resolver listens to
-- don't fire; SerialEventUnitTeleportedToHex does. We register the same
-- handler against that event so the resolution path runs identically.
--
-- Combat moves register a "combat pending" snapshot rather than a normal
-- pending. EndCombatSim is the primary announcement path (animations on).
-- The snapshot is the fallback for Quick Combat, where the engine skips
-- gDLL->GameplayUnitCombat (CvUnitCombat.cpp gates the call on
-- !quickCombat) and EndCombatSim never fires. The snapshot caches per-
-- side pre-damage and pre-resolved display names at commit (units may
-- be gone by fallback execution time), then a tick-based timer reads
-- post-state and feeds UnitSpeech.combatResult with a constructed
-- payload.
--
-- Snapshot registration is gated on GAMEOPTION_QUICK_COMBAT. Without the
-- gate, animations-on combats double-speak: the engine resolves damage
-- synchronously in the mission queue regardless of animation setting, so
-- the snapshot timer reads final post-state at commit+3 frames and
-- speaks; then EndCombatSim fires when the animation finishes (often
-- several seconds later) and speaks the same result again. The earlier
-- "EndCombatSim clears the snapshot" guard only worked in the
-- EndCombatSim-then-timer order, which is the reverse of what happens
-- with animations on.
--
-- War-confirm moves freeze pending into a deferred slot. Moving onto a
-- peaceful rival's tile (or attacking a peaceful rival's unit) does not
-- execute the move; the engine queues BUTTONPOPUP_DECLAREWARMOVE for
-- confirmation. enemyAt filters by IsAtWar so isCombat is false and
-- pending is registered, then the unit sits while the popup is up and
-- the two-tick timeout would falsely speak "action failed". The popup-
-- shown listener moves _pending to _deferred (cancels the timer);
-- DeclareWarPopupAccess re-arms via notifyDeferredCommit on Yes (the
-- engine re-issues the move via Game.SelectionListMove, which fires
-- SerialEventUnitMove and our listener resolves normally) or drops via
-- notifyCommitCanceled on No / Esc (the popup itself was the user's
-- answer, no further speech needed).

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

-- Combat resolution can take a frame longer than a plain move because
-- the mission queue runs Attack -> ResolveCombat synchronously and
-- damage / kill state needs to settle before we read post-state.
local COMBAT_PENDING_EXPIRY_FRAMES = 3

-- City combats settle on a delayed event chain: the engine applies city
-- HP via SerialEventCitySetDamage, which can fire many seconds after
-- commit (especially under standard combat with animation). The
-- city-pending snapshot lives until that event matches it; this cap
-- ignores stale snapshots so a damage event from a much later combat /
-- non-combat source (healing) doesn't reuse a snapshot from an earlier
-- attack the user has already moved on from.
local CITY_COMBAT_MAX_AGE_FRAMES = 600

local _pending = nil
local _deferred = nil
local _combatPending = nil

local function clearPending()
    _pending = nil
end

local function clearCombatPending()
    _combatPending = nil
end

local schedulePendingExpiry
local scheduleCombatExpiry

-- Look up a unit's current damage by id; returns the snapshot's pre-
-- recorded MaxHP if the unit has been removed (kill threshold trips so
-- the formatter speaks "killed"). Hoisted above the listener / timer
-- definitions so their lexical lookup resolves to this local rather than
-- a nil global -- a forward reference would silently misfire under
-- pcall when the listener fires.
local function liveDamage(playerId, unitId, snapshotMaxHP)
    local player = Players[playerId]
    if player == nil then
        return snapshotMaxHP
    end
    local unit = player:GetUnitByID(unitId)
    if unit == nil then
        return snapshotMaxHP
    end
    return unit:GetDamage()
end

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

-- Snapshot taken at combat commit (Alt+QAZEDC two-tap melee or target-
-- mode commit on a plot that willCauseCombat). Pre-damage + max HP +
-- pre-resolved display names are captured now because by fallback
-- execution time the killed unit may already be torn down. The fallback
-- timer runs UnitSpeech.combatResult with a payload reconstructed from
-- post-state damage minus snapshot pre-damage.
--
-- No-op when Quick Combat is off; EndCombatSim is authoritative in that
-- mode and registering the snapshot would double-speak.
function UnitControl.registerCombatPending(actor, defender)
    if actor == nil or defender == nil then
        return
    end
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_QUICK_COMBAT) then
        return
    end
    local atkPlayer = actor:GetOwner()
    local atkID = actor:GetID()
    local defPlayer = defender:GetOwner()
    local defID = defender:GetID()
    local snapshot = {
        defenderType = "unit",
        attackerPlayer = atkPlayer,
        attackerUnitID = atkID,
        attackerName = UnitSpeech.combatantName(atkPlayer, atkID),
        attackerPreDamage = actor:GetDamage(),
        attackerMaxHP = actor:GetMaxHitPoints(),
        defenderPlayer = defPlayer,
        defenderUnitID = defID,
        defenderName = UnitSpeech.combatantName(defPlayer, defID),
        defenderPreDamage = defender:GetDamage(),
        defenderMaxHP = defender:GetMaxHitPoints(),
        commitFrame = TickPump.frame(),
    }
    _combatPending = snapshot
    scheduleCombatExpiry(snapshot)
end

-- City-defender variant. Same shape as registerCombatPending but the
-- defender side reads from a city (GetDamage / GetMaxHitPoints / name)
-- rather than a unit. NO Quick-Combat gate: city damage settles
-- asynchronously on a different code path than unit-vs-unit, so polling
-- for the post-state never catches the value (city:GetDamage stays
-- pre-attack for many seconds after commit). Instead the snapshot
-- arms a SerialEventCitySetDamage listener that speaks the result the
-- moment the engine commits the damage. EndCombatSim is the redundant
-- fallback under standard combat (animations on); whichever fires first
-- speaks and clears the pending so the other no-ops.
function UnitControl.registerCityCombatPending(actor, city)
    if actor == nil or city == nil then
        return
    end
    local atkPlayer = actor:GetOwner()
    local atkID = actor:GetID()
    local cityOwner = city:GetOwner()
    local cityID = city:GetID()
    local snapshot = {
        defenderType = "city",
        attackerPlayer = atkPlayer,
        attackerUnitID = atkID,
        attackerName = UnitSpeech.combatantName(atkPlayer, atkID),
        attackerPreDamage = actor:GetDamage(),
        attackerMaxHP = actor:GetMaxHitPoints(),
        defenderPlayer = cityOwner,
        defenderCityID = cityID,
        defenderName = UnitSpeech.cityCombatantName(cityOwner, cityID),
        defenderPreDamage = city:GetDamage(),
        defenderMaxHP = city:GetMaxHitPoints(),
        commitFrame = TickPump.frame(),
    }
    _combatPending = snapshot
    scheduleCombatExpiry(snapshot)
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
-- Plain . / , go through Game.CycleUnits, which walks the engine's own
-- per-player list (CvUnitCycler) and applies its ReadyToSelect filter --
-- units that have moved, are fortified, sleeping, or automated are
-- skipped. Forward=true is the base-game "CycleLeft" button (the layout
-- has left = "go to next", right = "go back"); we pass through unchanged.
function UnitControl.cycleAll(forward)
    UnitControl.markUserInitiatedSelection()
    Game.CycleUnits(true, forward and true or false, false)
end

-- Ctrl+. / Ctrl+, walk our own list, which mirrors CvUnitCycler's data
-- structure: a stable array of unit IDs that's rebuilt on creation and
-- spliced on destruction, never on press. This is what makes forward-
-- then-backward round-trip -- the same list is walked both directions.
-- We drop the ReadyToSelect filter so every active-player unit is a
-- target (the whole point of the Ctrl variant is "show me everyone,
-- including units I've already moved").
--
-- Algorithm matches CvGameCoreDLL_Expansion2/CvUnitCycler.cpp Rebuild()
-- in LoneGazebo/Community-Patch-DLL: NN walk seeded from a chosen unit,
-- then up to 5 passes of 2-opt segment-reversal. Seed precedence is the
-- same as the engine's no-arg Rebuild: caller-provided > current
-- selection (if owned by active player) > first worker > first unit.
-- We run stock Firaxis, so exact parity with Community Patch is assumed,
-- not guaranteed.
local _cycleList = nil

local function rebuildCycleList(startUnit)
    local activePlayer = Game.GetActivePlayer()
    local player = Players[activePlayer]
    if player == nil then
        _cycleList = nil
        return
    end
    local units = {}
    for unit in player:Units() do
        units[#units + 1] = unit
    end
    local size = #units
    if size == 0 then
        _cycleList = {}
        return
    end
    if startUnit == nil then
        local sel = selectedUnit()
        if sel ~= nil and sel:GetOwner() == activePlayer then
            startUnit = sel
        end
    end
    if startUnit == nil then
        for _, u in ipairs(units) do
            if u:WorkRate(true) > 0 then
                startUnit = u
                break
            end
        end
    end
    if startUnit == nil then
        startUnit = units[1]
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
    push(startUnit)
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
    local list = {}
    for i, u in ipairs(tour) do
        list[i] = u:GetID()
    end
    _cycleList = list
end

local function spliceFromCycleList(unitID)
    if _cycleList == nil then
        return
    end
    for i, id in ipairs(_cycleList) do
        if id == unitID then
            table.remove(_cycleList, i)
            return
        end
    end
end

function UnitControl.cycleAllUnits(forward)
    UnitControl.markUserInitiatedSelection()
    if _cycleList == nil then
        rebuildCycleList(nil)
    end
    if _cycleList == nil or #_cycleList == 0 then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"))
        return
    end
    local activePlayer = Game.GetActivePlayer()
    local player = Players[activePlayer]
    if player == nil then
        return
    end
    local n = #_cycleList
    local current = selectedUnit()
    local startIdx
    if current ~= nil and current:GetOwner() == activePlayer then
        local cid = current:GetID()
        for i, id in ipairs(_cycleList) do
            if id == cid then
                startIdx = i
                break
            end
        end
    end
    -- Engine's Cycle: when current isn't in the list, step starts at the
    -- head (forward) or tail (backward).
    local idx
    if startIdx == nil then
        if forward then
            idx = 1
        else
            idx = n
        end
    elseif forward then
        idx = startIdx + 1
        if idx > n then
            idx = 1
        end
    else
        idx = startIdx - 1
        if idx < 1 then
            idx = n
        end
    end
    -- Walk until a live unit is found. Bounded by n so a list with stale
    -- IDs (missed destruction event) doesn't spin.
    for _ = 1, n do
        local unit = player:GetUnitByID(_cycleList[idx])
        if unit ~= nil then
            UI.SelectUnit(unit)
            return
        end
        if forward then
            idx = idx + 1
            if idx > n then
                idx = 1
            end
        else
            idx = idx - 1
            if idx < 1 then
                idx = n
            end
        end
    end
end

-- Enemy city at plot if any, with the same active-team / war gate enemyAt
-- uses for units. Used by directMove so an Alt+QAZEDC into an enemy city
-- gates on the same melee-attack confirm + combat-pending snapshot path
-- as one into an enemy unit.
local function enemyCityAt(plot)
    if plot == nil or not plot:IsCity() then
        return nil
    end
    local city = plot:GetPlotCity()
    if city == nil or city:GetOwner() == Game.GetActivePlayer() then
        return nil
    end
    local team = Teams[Game.GetActiveTeam()]
    if team == nil then
        return nil
    end
    local owner = Players[city:GetOwner()]
    if owner == nil then
        return nil
    end
    if not (owner:IsBarbarian() or team:IsAtWar(owner:GetTeam())) then
        return nil
    end
    return city
end

-- ===== Alt+QAZEDC direct move =====
-- defender non-nil means the caller already resolved the target as a melee
-- attack (against a unit OR a city) and registers the combat-pending
-- snapshot in lieu of a normal move pending. Combat commits go through
-- Game.SelectionListMove to match base UI's INTERFACEMODE_ATTACK click
-- handler (InGame.lua AttackIntoTile).
local function commitDirectMove(unit, target, targetX, targetY, defender, defenderIsCity)
    if defender == nil then
        UnitControl.registerPending(unit, targetX, targetY)
        Game.SelectionListGameNetMessage(
            GameMessageTypes.GAMEMESSAGE_PUSH_MISSION,
            GameInfoTypes.MISSION_MOVE_TO,
            targetX,
            targetY,
            0,
            false,
            false
        )
        return
    end
    if defenderIsCity then
        UnitControl.registerCityCombatPending(unit, defender)
    else
        UnitControl.registerCombatPending(unit, defender)
    end
    Game.SelectionListMove(target, false, false, false)
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
    local enemyCity
    if enemy == nil then
        enemyCity = enemyCityAt(target)
    end
    if enemy == nil and enemyCity == nil then
        clearCombatConfirm()
        commitDirectMove(unit, target, tx, ty, nil, false)
        return
    end
    -- Melee-attack confirm gate. Screen-reader users can't see the
    -- hover preview a mouse user does, so a second press within the
    -- window is the cheap "are you sure" check.
    local now = os.clock()
    if _combatConfirm.dir == dir and (now - _combatConfirm.clock) < COMBAT_CONFIRM_WINDOW_SECONDS then
        clearCombatConfirm()
        if enemy ~= nil then
            commitDirectMove(unit, target, tx, ty, enemy, false)
        else
            commitDirectMove(unit, target, tx, ty, enemyCity, true)
        end
        return
    end
    _combatConfirm.dir = dir
    _combatConfirm.clock = now
    if enemy ~= nil then
        speakInterrupt(UnitSpeech.meleePreview(unit, enemy, target))
    else
        speakInterrupt(UnitSpeech.cityMeleePreview(unit, enemyCity, target))
    end
end

-- ===== Info key =====
local function speakInfo()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    speakInterrupt(UnitSpeech.info(unit))
end

-- ===== Recenter cursor on selected unit =====
-- Counterpart to onUnitSelectionChanged's auto-jump: when the user has
-- wandered the cursor away from the unit they were last working with,
-- snap it back without forcing a re-cycle. Silent on no-unit, matching
-- every other selection-keyed binding in this file.
local function recenterOnUnit()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    speakInterrupt(Cursor.jumpTo(unit:GetX(), unit:GetY()))
end

-- ===== Tab action menu =====
local function openActionMenu()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    UnitActionMenu.open(unit)
end

-- ===== Alt-letter quick actions =====
-- Each Alt-letter binding routes to one or more action Types via
-- UnitActionMenu.commitByType. The menu's gates (Visible, CanHandleAction
-- twice, 0-moves filter) are reused so a hotkey commit and a Tab-menu
-- commit run the same engine path; the speech confirm goes through
-- UnitSpeech.selfPlotConfirm via the same SELF_PLOT_TOKENS_BY_TYPE map
-- the menu uses.
--
-- Type lists are ordered: commitByType walks them in caller order and
-- takes the first that's currently available. For Alt+F this means
-- MISSION_FORTIFY wins on military units and falls through to
-- MISSION_SLEEP on civilians (mirroring the engine's plain-F binding,
-- which picks by unit type the same way). For Alt+W, COMMAND_WAKE handles
-- a sleeping/fortified/alerted unit while COMMAND_CANCEL /
-- COMMAND_STOP_AUTOMATION cover queued moves and automated workers; only
-- one of these is ever available at a time so order doesn't shadow.
--
-- No-unit case is silent (matches Alt+QAZEDC directMove). When a unit is
-- selected but the action isn't available (out of moves, can't ranged-
-- attack here, etc.), we speak "{action} not available" using the
-- action's TextKey label so the user knows which action was rejected.

local ALT_ACTION_TYPES = {
    SLEEP = { "MISSION_FORTIFY", "MISSION_SLEEP" },
    SENTRY = { "MISSION_ALERT" },
    WAKE = { "COMMAND_WAKE", "MISSION_WAKE", "COMMAND_CANCEL", "COMMAND_STOP_AUTOMATION" },
    HEAL = { "MISSION_HEAL" },
    PILLAGE = { "MISSION_PILLAGE" },
    RANGED = { "INTERFACEMODE_RANGE_ATTACK", "INTERFACEMODE_AIRSTRIKE" },
    SKIP = { "MISSION_SKIP" },
    UPGRADE = { "COMMAND_UPGRADE" },
}

local function quickAction(types)
    return function()
        local unit = selectedUnit()
        if unit == nil then
            return
        end
        if UnitActionMenu.commitByType(unit, types) then
            return
        end
        local _, row = UnitActionMenu.findActionRow(types)
        local label = row and UnitActionMenu.actionLabel(row) or ""
        if label == "" then
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
        else
            speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_UNIT_ACTION_NOT_AVAILABLE", label))
        end
    end
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
        bind(VK_OEM_2, MOD_CTRL, recenterOnUnit, "Recenter cursor on selected unit"),
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
        bind(Keys.F, MOD_ALT, quickAction(ALT_ACTION_TYPES.SLEEP), "Sleep or fortify"),
        bind(Keys.S, MOD_ALT, quickAction(ALT_ACTION_TYPES.SENTRY), "Sentry"),
        bind(Keys.W, MOD_ALT, quickAction(ALT_ACTION_TYPES.WAKE), "Wake or cancel"),
        bind(Keys.VK_SPACE, MOD_ALT, quickAction(ALT_ACTION_TYPES.SKIP), "Skip turn"),
        bind(Keys.H, MOD_ALT, quickAction(ALT_ACTION_TYPES.HEAL), "Heal"),
        bind(Keys.R, MOD_ALT, quickAction(ALT_ACTION_TYPES.RANGED), "Ranged attack"),
        bind(Keys.P, MOD_ALT, quickAction(ALT_ACTION_TYPES.PILLAGE), "Pillage"),
        bind(Keys.U, MOD_ALT, quickAction(ALT_ACTION_TYPES.UPGRADE), "Upgrade unit"),
    }
    -- Unit section of the map-mode help. BaselineHandler concatenates this
    -- between the cursor cluster and the turn keys, so all unit-relevant
    -- bindings (cycling, info, the Tab menu, direct-move, and the Alt-letter
    -- quick actions) live in one stretch of the help readout.
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
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_RECENTER",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_RECENTER",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_TAB",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_TAB",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_MOVE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_MOVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SLEEP",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SLEEP",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SENTRY",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SENTRY",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_WAKE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_WAKE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_SKIP",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_SKIP",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_HEAL",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_HEAL",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RANGED",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RANGED",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_PILLAGE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_PILLAGE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_UPGRADE",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_UPGRADE",
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
    -- Settings toggle: when off, suppress the auto-jump so the cursor
    -- stays put. The direction string baked into the selection text above
    -- already tells the player where the new selection sits relative to
    -- the cursor's current position. Move-completed and the explicit
    -- "speak current unit" hotkey jump independently and stay live.
    if not civvaccess_shared.cursorFollowsSelection then
        return
    end
    Cursor.jumpTo(unit:GetX(), unit:GetY())
end

-- Events.EndCombatSim args, per Community-Patch-DLL CvUnitCombat.cpp around
-- line 3306: the third arg per side is damage taken THIS combat (not the
-- unit's accumulated damage before combat); the fourth is cumulative damage
-- after combat. Names use the engine convention so the subtractor doesn't
-- get reintroduced.
--
-- City defenders are routed to onCitySetDamage (defenderUnit=-1 / empty
-- name short-circuits below), since SerialEventCitySetDamage is the
-- canonical event for city HP changes and fires under both Quick Combat
-- ON and OFF -- whereas this event only fires under standard combat for
-- units (Quick Combat skips the gDLL->GameplayUnitCombat call).
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
    defenderMaxHP,
    attackerX,
    attackerY,
    defenderX,
    defenderY
)
    local activePlayer = Game.GetActivePlayer()
    if attackerPlayer ~= activePlayer and defenderPlayer ~= activePlayer then
        return
    end
    -- City defenders are owned by SerialEventCitySetDamage's listener;
    -- it speaks the result the moment the engine commits city HP, which
    -- is reliable under both Quick Combat ON and OFF. EndCombatSim's
    -- defenderUnit is -1 for city attacks, so duplicating the
    -- announcement here would both double-speak under standard combat
    -- and risk wrong numbers (damage args track the garrison or are zero).
    if defenderUnit == -1 then
        return
    end
    local defenderName = UnitSpeech.combatantName(defenderPlayer, defenderUnit)
    if defenderName == "" then
        Log.warn(
            "onEndCombatSim: defender name empty for player="
                .. tostring(defenderPlayer)
                .. " unit="
                .. tostring(defenderUnit)
        )
        return
    end
    local text = UnitSpeech.combatResult({
        attackerName = UnitSpeech.combatantName(attackerPlayer, attackerUnit),
        defenderName = defenderName,
        attackerDamage = attackerDamage,
        attackerFinalDamage = attackerFinalDamage,
        attackerMaxHP = attackerMaxHP,
        defenderDamage = defenderDamage,
        defenderFinalDamage = defenderFinalDamage,
        defenderMaxHP = defenderMaxHP,
    })
    speakQueued(text)
end

-- City HP-change announcement. Engine fires SerialEventCitySetDamage
-- whenever a city's damage value changes (combat hits, healing). Combat-
-- pending snapshot for a city target is the gate: if no snapshot or the
-- player/city don't match, this is a non-combat update and we stay
-- silent. The (damage, previousDamage) args give us the defender delta
-- directly; attacker delta is read live (unit:GetDamage). This is the
-- primary city-combat speech path under both Quick Combat and standard
-- combat -- it fires whenever the engine commits the damage, which is
-- reliable even when EndCombatSim doesn't (Quick Combat).
local function onCitySetDamage(cityPlayerID, cityID, damage, previousDamage)
    local pending = _combatPending
    if pending == nil or pending.defenderType ~= "city" then
        return
    end
    if pending.defenderPlayer ~= cityPlayerID or pending.defenderCityID ~= cityID then
        return
    end
    if TickPump.frame() - pending.commitFrame > CITY_COMBAT_MAX_AGE_FRAMES then
        clearCombatPending()
        return
    end
    local atkPost = liveDamage(pending.attackerPlayer, pending.attackerUnitID, pending.attackerMaxHP)
    local atkDelta = atkPost - pending.attackerPreDamage
    if atkDelta < 0 then
        atkDelta = 0
    end
    local defDelta = damage - previousDamage
    if defDelta < 0 then
        defDelta = 0
    end
    local text = UnitSpeech.combatResult({
        attackerName = pending.attackerName,
        defenderName = pending.defenderName,
        attackerDamage = atkDelta,
        attackerFinalDamage = atkPost,
        attackerMaxHP = pending.attackerMaxHP,
        defenderDamage = defDelta,
        defenderFinalDamage = damage,
        defenderMaxHP = pending.defenderMaxHP,
    })
    speakQueued(text)
    clearCombatPending()
end

-- Empty city captures don't fire EndCombatSim -- the unit just walks in.
-- SerialEventCityCaptured fires once per capture with (hexPos, oldOwner,
-- cityId, newOwner). Speak only when the active player is involved (we
-- captured one or one of ours fell). The engine's hex position is a
-- HexPos table; pulling x/y is enough to look up the city plot.
local function onCityCaptured(hexPos, oldOwner, cityId, newOwner)
    local activePlayer = Game.GetActivePlayer()
    if newOwner ~= activePlayer and oldOwner ~= activePlayer then
        return
    end
    local cityName
    local newPlayer = Players[newOwner]
    if newPlayer ~= nil then
        local city = newPlayer:GetCityByID(cityId)
        if city ~= nil then
            cityName = city:GetName()
        end
    end
    if cityName == nil then
        cityName = ""
    end
    if newOwner == activePlayer then
        speakQueued(Text.format("TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US", cityName))
    else
        speakQueued(Text.format("TXT_KEY_CIVVACCESS_CITY_LOST", cityName))
    end
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

-- Quick-Combat speech path. The snapshot is only ever registered when
-- GAMEOPTION_QUICK_COMBAT is on (see registerCombatPending), where
-- EndCombatSim never fires; this timer reads post-state damage and
-- reconstructs the same payload shape EndCombatSim would have delivered,
-- then routes through UnitSpeech.combatResult so both modes speak the
-- same sentence.
scheduleCombatExpiry = function(snapshot)
    -- City snapshots are driven by SerialEventCitySetDamage / capture
    -- listeners, not by polling. The listener checks snapshot age before
    -- speaking so a stale snapshot from a missed event doesn't get reused
    -- by a later unrelated city damage update.
    if snapshot.defenderType == "city" then
        return
    end
    TickPump.runOnce(function()
        if _combatPending ~= snapshot then
            return
        end
        if TickPump.frame() - snapshot.commitFrame < COMBAT_PENDING_EXPIRY_FRAMES then
            scheduleCombatExpiry(snapshot)
            return
        end
        local atkPost = liveDamage(snapshot.attackerPlayer, snapshot.attackerUnitID, snapshot.attackerMaxHP)
        local defPost = liveDamage(snapshot.defenderPlayer, snapshot.defenderUnitID, snapshot.defenderMaxHP)
        local atkDelta = atkPost - snapshot.attackerPreDamage
        if atkDelta < 0 then
            atkDelta = 0
        end
        local defDelta = defPost - snapshot.defenderPreDamage
        if defDelta < 0 then
            defDelta = 0
        end
        local text = UnitSpeech.combatResult({
            attackerName = snapshot.attackerName,
            defenderName = snapshot.defenderName,
            attackerDamage = atkDelta,
            attackerFinalDamage = atkPost,
            attackerMaxHP = snapshot.attackerMaxHP,
            defenderDamage = defDelta,
            defenderFinalDamage = defPost,
            defenderMaxHP = snapshot.defenderMaxHP,
        })
        speakQueued(text)
        clearCombatPending()
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

-- War-confirm popup intercept. The engine queues this in lieu of
-- executing a move that would trigger a war declaration; the unit hasn't
-- moved, so the pending-expiry timer would false-positive.
local function onPopupShown(popupInfo)
    if popupInfo == nil or popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_DECLAREWARMOVE then
        return
    end
    if _pending ~= nil then
        _deferred = _pending
        _pending = nil
    end
end

-- Called by DeclareWarPopupAccess on Yes. The engine's OnYesClicked then
-- runs Game.SelectionListMove synchronously, so re-arming pending here
-- captures a fresh start hex (the unit hasn't moved yet) before
-- SerialEventUnitMove fires.
function UnitControl.notifyDeferredCommit()
    if _deferred == nil then
        return
    end
    local snap = _deferred
    _deferred = nil
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return
    end
    local unit = player:GetUnitByID(snap.unitID)
    if unit == nil then
        return
    end
    UnitControl.registerPending(unit, snap.targetX, snap.targetY)
end

function UnitControl.notifyCommitCanceled()
    _deferred = nil
end

-- Cycle-list maintenance. Mirrors the engine's CvUnitCycler:
-- AddUnit triggers a full rebuild (no start unit, falls through to first
-- worker when nothing is selected); RemoveUnit just splices.
local function onUnitCreated(playerID, _unitID)
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    rebuildCycleList(nil)
end

local function onUnitDestroyed(playerID, unitID)
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    spliceFromCycleList(unitID)
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
    -- Quick Movement routes per-hex moves through CvUnit::SetPosition,
    -- which fires SerialEventUnitTeleportedToHex instead of
    -- SerialEventUnitMove(ToHexes). Same handler resolves pending the
    -- same way; the (i, j, playerID, unitID) args are ignored.
    if Events.SerialEventUnitTeleportedToHex ~= nil then
        Events.SerialEventUnitTeleportedToHex.Add(onUnitMoveCompleted)
    else
        Log.warn("UnitControl: Events.SerialEventUnitTeleportedToHex missing")
    end
    if Events.SerialEventGameMessagePopup ~= nil then
        Events.SerialEventGameMessagePopup.Add(onPopupShown)
    else
        Log.warn("UnitControl: Events.SerialEventGameMessagePopup missing")
    end
    if Events.SerialEventCityCaptured ~= nil then
        Events.SerialEventCityCaptured.Add(onCityCaptured)
    else
        Log.warn("UnitControl: Events.SerialEventCityCaptured missing")
    end
    if Events.SerialEventCitySetDamage ~= nil then
        Events.SerialEventCitySetDamage.Add(onCitySetDamage)
    else
        Log.warn("UnitControl: Events.SerialEventCitySetDamage missing")
    end
    if Events.SerialEventUnitCreated ~= nil then
        Events.SerialEventUnitCreated.Add(onUnitCreated)
    else
        Log.warn("UnitControl: Events.SerialEventUnitCreated missing")
    end
    if Events.SerialEventUnitDestroyed ~= nil then
        Events.SerialEventUnitDestroyed.Add(onUnitDestroyed)
    else
        Log.warn("UnitControl: Events.SerialEventUnitDestroyed missing")
    end
    -- Seed the cycle list now that we're past LoadScreenClose; initial
    -- units exist but their SerialEventUnitCreated events fired before
    -- our listener was registered. Match the engine's no-arg Rebuild
    -- (selected unit > first worker > first unit).
    rebuildCycleList(nil)
end

-- Coordinator for unit-control bindings and event-driven announcements.
-- getBindings() is concat'd by BaselineHandler; installListeners() wires
-- the per-frame and per-engine-event hooks that speak result feedback.
--
-- Speech policy follows the design's "user-initiated INTERRUPT vs engine-
-- event QUEUE" split: Tab / / / Alt+QAZEDC / , / Ctrl+. / Ctrl+, go through
-- INTERRUPT; UnitSelectionChanged, EndCombatSim, and move-completion
-- listeners speak QUEUED so they race-and-lose against user speech in
-- flight rather than clobbering it.
--
-- Pending-move tracking bridges "commit" to "announce actual outcome".
-- On commit (Alt+QAZEDC or target-mode move-to) we stash target coords +
-- the active player's expected unit id; on the first SerialEventUnitMove
-- afterwards we compare the unit's live plot to the target and speak
-- "moved" / "stopped short". Two-tick fallback covers silently-rejected
-- commits. No cross-turn state -- pending is cleared on every resolution.

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

local function enemyAt(plot)
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
    Game.CycleUnits(true, forward and true or false, false)
end

-- Walk the cursor's current plot's unit list, filter to active-player
-- units, and pick the next / previous relative to the currently-selected
-- unit (or the first entry if our selection isn't on this hex). Speaks
-- "no units" for empty. Single-unit case silently re-selects the unit
-- (no-op if already selected) so the user hears a selection-change
-- announcement through the listener.
function UnitControl.cycleOnHex(x, y, forward)
    local plot = plotAt(x, y)
    if plot == nil then
        Log.warn("UnitControl.cycleOnHex: no plot at (" .. tostring(x) .. ", " .. tostring(y) .. ")")
        return
    end
    local activePlayer = Game.GetActivePlayer()
    local ownUnits = {}
    for i = 0, plot:GetNumUnits() - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and u:GetOwner() == activePlayer then
            ownUnits[#ownUnits + 1] = u
        end
    end
    if #ownUnits == 0 then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"))
        return
    end
    if #ownUnits == 1 then
        UI.SelectUnit(ownUnits[1])
        return
    end
    local current = selectedUnit()
    local currentIdx
    if current ~= nil then
        local cid = current:GetID()
        for i, u in ipairs(ownUnits) do
            if u:GetID() == cid then
                currentIdx = i
                break
            end
        end
    end
    local targetIdx
    if currentIdx == nil then
        targetIdx = 1
    else
        if forward then
            targetIdx = currentIdx + 1
            if targetIdx > #ownUnits then
                targetIdx = 1
            end
        else
            targetIdx = currentIdx - 1
            if targetIdx < 1 then
                targetIdx = #ownUnits
            end
        end
    end
    UI.SelectUnit(ownUnits[targetIdx])
end

-- ===== Alt+QAZEDC direct move =====
local function commitDirectMove(unit, targetX, targetY)
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
    local enemy = enemyAt(target)
    if enemy == nil then
        clearCombatConfirm()
        commitDirectMove(unit, tx, ty)
        return
    end
    -- Melee-attack confirm gate. Screen-reader users can't see the
    -- hover preview a mouse user does, so a second press within the
    -- window is the cheap "are you sure" check.
    local now = os.clock()
    if _combatConfirm.dir == dir and (now - _combatConfirm.clock) < COMBAT_CONFIRM_WINDOW_SECONDS then
        clearCombatConfirm()
        commitDirectMove(unit, tx, ty)
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
            local cx, cy = Cursor.position()
            if cx == nil then
                return
            end
            UnitControl.cycleOnHex(cx, cy, true)
        end, "Next unit on hex"),
        bind(VK_OEM_COMMA, MOD_CTRL, function()
            local cx, cy = Cursor.position()
            if cx == nil then
                return
            end
            UnitControl.cycleOnHex(cx, cy, false)
        end, "Previous unit on hex"),
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
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_CYCLE_HEX",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_CYCLE_HEX",
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
    speakInterrupt(text)
    Cursor.jumpTo(unit:GetX(), unit:GetY())
end

local function onEndCombatSim(
    attackerPlayer,
    attackerUnit,
    attackerInitialDamage,
    attackerFinalDamage,
    _attackerMaxHP,
    defenderPlayer,
    defenderUnit,
    defenderInitialDamage,
    defenderFinalDamage,
    _defenderMaxHP
)
    local activePlayer = Game.GetActivePlayer()
    if attackerPlayer ~= activePlayer and defenderPlayer ~= activePlayer then
        return
    end
    local text = UnitSpeech.combatResult({
        attackerPlayer = attackerPlayer,
        attackerUnit = attackerUnit,
        attackerInitialDamage = attackerInitialDamage,
        attackerFinalDamage = attackerFinalDamage,
        defenderPlayer = defenderPlayer,
        defenderUnit = defenderUnit,
        defenderInitialDamage = defenderInitialDamage,
        defenderFinalDamage = defenderFinalDamage,
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
    local tx, ty = _pending.targetX, _pending.targetY
    -- Only speak on a stop condition (at target OR out of moves). The
    -- engine fires SerialEventUnitMove per hex traversed, so mid-path
    -- events need to be ignored.
    local cx, cy = unit:GetX(), unit:GetY()
    local movesLeft = math.floor(unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR)
    if cx == tx and cy == ty or movesLeft <= 0 then
        speakQueued(UnitSpeech.moveResult(unit, tx, ty))
        Cursor.jumpTo(cx, cy)
        clearPending()
    end
end

-- Idempotent per-session listener install. civvaccess_shared persists
-- across Context re-entries within one lua_State; the flag prevents a
-- second Context loading this file from registering duplicate listeners.
function UnitControl.installListeners()
    civvaccess_shared = civvaccess_shared or {}
    if civvaccess_shared.unitControlListenersInstalled then
        return
    end
    civvaccess_shared.unitControlListenersInstalled = true
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

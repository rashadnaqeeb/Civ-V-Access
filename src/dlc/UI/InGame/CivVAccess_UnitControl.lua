-- Coordinator for unit-control bindings and event-driven announcements.
-- getBindings() is concat'd by BaselineHandler; installListeners() wires
-- the per-frame and per-engine-event hooks that speak result feedback.
--
-- Speech policy follows the design's "user-initiated INTERRUPT vs engine-
-- event QUEUE" split: Tab / / / Alt+QAZEDC / , / Ctrl+. / Ctrl+, go through
-- INTERRUPT; combat-resolved and move-completion listeners speak QUEUED
-- so they race-and-lose against user speech in flight rather than
-- clobbering it. UnitSelectionChanged straddles both: the user's cycle keys drive it
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
-- Combat moves don't register a pending. The engine fork's
-- CivVAccessCombatResolved GameEvent fires synchronously from
-- CvUnitCombat::ResolveCombat for every unit-attacker melee / ranged
-- combat against units and cities, regardless of Quick Combat, with a
-- payload covering both sides' damage / final HP / max HP. The Lua
-- listener (onCombatResolved below) is the sole speech path for combat;
-- there is no fallback timer, no per-side snapshot, and no Events
-- listener race. The engine's own Events.EndCombatSim and
-- SerialEventCitySetDamage signals are not subscribed to -- they would
-- only double-speak the result the hook already announced.
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

local _pending = nil
local _deferred = nil

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

-- At-war defender at plot, used by directMove to gate Alt+QAZEDC into
-- the melee-attack commit (Game.SelectionListMove) vs. the plain-move
-- commit (registerPending + GAMEMESSAGE_PUSH_MISSION + MISSION_MOVE_TO).
-- bTestAtWar=true means at-war or barbarian (CvUnit::isEnemy at CvUnit
-- .cpp:18255 checks atWar; barbarians are always at war with all civs).
-- bTestPotentialEnemy=false so peaceful rivals don't trigger the attack
-- commit: entering a peaceful rival's tile queues BUTTONPOPUP_
-- DECLAREWARMOVE, not direct combat, and the popup path freezes pending
-- into a deferred slot. bNoncombatAllowed=false so a civilian-only plot
-- is treated as a move (capture), not an attack.
function UnitControl.enemyAt(plot)
    if plot == nil then
        return nil
    end
    return plot:GetBestDefender(-1, Game.GetActivePlayer(), nil, 1, 0, 0, 0)
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

-- Ctrl+. / Ctrl+, walk Game.GetCycleUnits(), the engine fork's exposure
-- of CvPlayer::GetUnitCycler(). Order is whatever the engine has built;
-- it persists across creation/destruction the same way as the engine's
-- own next-unit binding. We drop the ReadyToSelect filter so every
-- active-player unit is a target (the whole point of the Ctrl variant
-- is "show me everyone, including units I've already moved").
function UnitControl.cycleAllUnits(forward)
    UnitControl.markUserInitiatedSelection()
    local list = Game.GetCycleUnits()
    local n = #list
    if n == 0 then
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_NO_UNITS"))
        return
    end
    local activePlayer = Game.GetActivePlayer()
    local player = Players[activePlayer]
    if player == nil then
        return
    end
    local current = selectedUnit()
    local startIdx
    if current ~= nil and current:GetOwner() == activePlayer then
        local cid = current:GetID()
        for i, id in ipairs(list) do
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
        idx = forward and 1 or n
    elseif forward then
        idx = startIdx + 1
        if idx > n then idx = 1 end
    else
        idx = startIdx - 1
        if idx < 1 then idx = n end
    end
    -- Walk until a live unit is found. Bounded by n so a list with a
    -- stale ID (engine cycler hasn't pruned a just-killed unit) doesn't
    -- spin.
    for _ = 1, n do
        local unit = player:GetUnitByID(list[idx])
        if unit ~= nil then
            UI.SelectUnit(unit)
            return
        end
        if forward then
            idx = idx + 1
            if idx > n then idx = 1 end
        else
            idx = idx - 1
            if idx < 1 then idx = n end
        end
    end
end

-- Enemy city at plot if any, with the same active-team / war gate enemyAt
-- uses for units. Used by directMove so an Alt+QAZEDC into an enemy city
-- gates on the same melee-attack confirm path as one into an enemy unit.
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
-- attack (against a unit OR a city); commit goes through Game.Selection
-- ListMove to match base UI's INTERFACEMODE_ATTACK click handler (InGame
-- .lua AttackIntoTile). No move-pending registration on the combat path:
-- the engine fork's CivVAccessCombatResolved hook fires from inside
-- ResolveCombat and onCombatResolved speaks the result, and a pending
-- announcement on top of that would double-speak when the attacker
-- advances onto the defender's plot.
local function commitDirectMove(unit, target, targetX, targetY, defender)
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
    Game.SelectionListMove(target, false, false, false)
end

-- Precheck: would a melee attack from this unit be allowed at all? Order
-- of checks is most-actionable first so the user hears the suggestion
-- closest to their next keystroke. IsRanged / DOMAIN_AIR get their own
-- messages because the right action exists (Alt+R) -- the user just
-- picked the wrong key. IsCanAttack catches civilians and units the
-- engine has flagged as non-attackers. MovesLeft is last because it's
-- transient (next turn fixes it). Exported so UnitTargetMode's commit
-- path can reuse the same gate when the user lands a melee attack
-- through the menu rather than an Alt-direction key.
function UnitControl.preflightAttack(unit)
    if unit:IsRanged() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_RANGED")
    end
    if unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR")
    end
    if not unit:IsCanAttack() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK")
    end
    if unit:MovesLeft() <= 0 then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NO_MOVES")
    end
    return nil
end

-- Precheck: can this unit enter the target plot at all? bDeclareWar=1
-- so a step into a peaceful rival's tile passes the gate -- the engine
-- will queue BUTTONPOPUP_DECLAREWARMOVE downstream and DeclareWarPopup
-- Access speaks the confirmation prompt. bDestination=1 so destination
-- -only checks (e.g., transport offload at the final tile) apply. No MP
-- check: a 0-MP move is legitimately queued for next turn and the
-- expiry path announces "queued" rather than treating it as failure.
-- Flags are int, not bool: the binding uses luaL_optint and rejects
-- Lua true/false outright. Exported so UnitTargetMode can use this in
-- place of UI.CanDoInterfaceMode(MOVE_TO), which wrongly fails 0-MP
-- moves the engine is happy to queue.
function UnitControl.preflightMove(unit, target)
    if not unit:CanMoveOrAttackInto(target, 1, 1) then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_BLOCKED")
    end
    return nil
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
        local moveReason = UnitControl.preflightMove(unit, target)
        if moveReason ~= nil then
            speakInterrupt(moveReason)
            return
        end
        commitDirectMove(unit, target, tx, ty, nil)
        return
    end
    -- Combat case. Precheck runs on the first tap so a unit that can't
    -- melee (ranged, air, civilian, 0 MP) never gets a misleading combat
    -- preview. The mouse hover panel the engine shows for sighted users
    -- gates similarly (EnemyUnitPanel.lua ~1846); we do the same gate so
    -- the hotkey path matches what a sighted player sees.
    local attackReason = UnitControl.preflightAttack(unit)
    if attackReason ~= nil then
        clearCombatConfirm()
        speakInterrupt(attackReason)
        return
    end
    -- Melee-attack confirm gate. Screen-reader users can't see the
    -- hover preview a mouse user does, so a second press within the
    -- window is the cheap "are you sure" check.
    local now = os.clock()
    if _combatConfirm.dir == dir and (now - _combatConfirm.clock) < COMBAT_CONFIRM_WINDOW_SECONDS then
        clearCombatConfirm()
        commitDirectMove(unit, target, tx, ty, enemy or enemyCity)
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
    -- the cursor's current position. The explicit "speak current unit"
    -- hotkey jumps independently and stays live so the player can still
    -- recenter on demand.
    if not civvaccess_shared.cursorFollowsSelection then
        return
    end
    Cursor.jumpTo(unit:GetX(), unit:GetY())
end

-- GameEvents.CivVAccessCombatResolved listener. The engine fork fires
-- this from CvUnitCombat::ResolveCombat (post-resolve, before the
-- dispatcher returns) for every unit-attacker melee / ranged combat
-- against units and cities, regardless of Quick Combat. Sole speech path
-- for unit-initiated combat results: per-side damage-this-combat, final
-- damage, max HP. Defender is either a unit (defenderUnit > -1) or a
-- city (defenderCity > -1, defenderUnit = -1).
local function onCombatResolved(
    attackerPlayer,
    attackerUnit,
    attackerDamage,
    attackerFinalDamage,
    attackerMaxHP,
    defenderPlayer,
    defenderUnit,
    defenderCity,
    defenderDamage,
    defenderFinalDamage,
    defenderMaxHP
)
    local activePlayer = Game.GetActivePlayer()
    if attackerPlayer ~= activePlayer and defenderPlayer ~= activePlayer then
        return
    end
    local attackerName = UnitSpeech.combatantName(attackerPlayer, attackerUnit)
    local defenderName
    if defenderUnit ~= -1 then
        defenderName = UnitSpeech.combatantName(defenderPlayer, defenderUnit)
    else
        defenderName = UnitSpeech.cityCombatantName(defenderPlayer, defenderCity)
    end
    if defenderName == "" then
        Log.warn(
            "onCombatResolved: defender name empty for player="
                .. tostring(defenderPlayer)
                .. " unit="
                .. tostring(defenderUnit)
                .. " city="
                .. tostring(defenderCity)
        )
        return
    end
    local text = UnitSpeech.combatResult({
        attackerName = attackerName,
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

-- Empty city captures don't fire any combat resolution -- the unit just walks in.
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
            -- Engine accepted the mission but no MP this turn: it sits
            -- in the queue under ACTIVITY_HOLD until next turn. Speak
            -- "queued" rather than "action failed" so the user knows
            -- the move will resolve, just not now. Empty queue = genuine
            -- rejection (engine refused the PUSH_MISSION outright); fall
            -- back to the generic message there.
            if #unit:GetMissionQueue() > 0 then
                speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"))
            else
                speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
            end
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
        -- Unit is gone (died in the attack, disbanded). The combat-
        -- resolved hook has already spoken the outcome; drop pending.
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
    -- events need to be ignored. Compare MP in 60ths, not floored MP:
    -- a unit with 30/60 left can still enter the next tile (engine pays
    -- all remaining MP on over-cost entry, and roads cost only 30/60),
    -- so flooring would announce "stopped" one tile early in mixed-
    -- terrain or partial-MP cases.
    local movesLeft60ths = unit:MovesLeft()
    local reachedTarget = (cx == tx and cy == ty)
    if reachedTarget or movesLeft60ths <= 0 then
        local turnsToArrival
        if not reachedTarget then
            local targetPlot = plotAt(tx, ty)
            if targetPlot ~= nil then
                local ok, pathTurns = unit:GeneratePath(targetPlot)
                if ok then
                    -- Engine's iPathTurns starts at 1 (initial node) and
                    -- bumps on turn boundaries. The unit has just stopped
                    -- with 0 MP *this* turn; the next move begins turn+1,
                    -- which engine has already counted, so drop one.
                    turnsToArrival = pathTurns - 1
                end
            end
        end
        speakQueued(UnitSpeech.moveResult(unit, tx, ty, turnsToArrival))
        -- Same toggle that gates the selection auto-jump: when off, the
        -- cursor stays where the player parked it and they can recenter
        -- with the explicit hotkey if they want to inspect the
        -- destination.
        if civvaccess_shared.cursorFollowsSelection then
            Cursor.jumpTo(cx, cy)
        end
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
--
-- Adjacent + has-defender case skips re-arming: once the engine declares
-- war and re-runs SelectionListMove, the move resolves as combat against
-- a now-at-war defender, the CombatResolved hook speaks the result, and
-- a "moved to X" announcement on top of that would double-speak when the
-- attacker advances onto the cleared plot. The check uses
-- bTestPotentialEnemy=true because we run BEFORE the engine declares
-- war; bTestAtWar would still see the rival as peaceful and miss them.
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
    local targetPlot = plotAt(snap.targetX, snap.targetY)
    if targetPlot ~= nil then
        local activePlayer = Game.GetActivePlayer()
        local potentialDefender = targetPlot:GetBestDefender(-1, activePlayer, unit, 0, 1, 0, 0)
        local potentialCity
        if targetPlot:IsCity() then
            local city = targetPlot:GetPlotCity()
            if city ~= nil and city:GetOwner() ~= activePlayer then
                potentialCity = city
            end
        end
        local distance = Map.PlotDistance(unit:GetX(), unit:GetY(), snap.targetX, snap.targetY)
        if (potentialDefender ~= nil or potentialCity ~= nil) and distance == 1 then
            return
        end
    end
    UnitControl.registerPending(unit, snap.targetX, snap.targetY)
end

function UnitControl.notifyCommitCanceled()
    _deferred = nil
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
    -- Engine-fork hook fired from CvUnitCombat::ResolveCombat. Sole
    -- combat-speech path; the engine's Events.EndCombatSim and
    -- SerialEventCitySetDamage are not subscribed because the hook
    -- already covers every case they would have announced.
    if GameEvents ~= nil and GameEvents.CivVAccessCombatResolved ~= nil then
        GameEvents.CivVAccessCombatResolved.Add(onCombatResolved)
    else
        Log.warn("UnitControl: GameEvents.CivVAccessCombatResolved missing")
    end
end

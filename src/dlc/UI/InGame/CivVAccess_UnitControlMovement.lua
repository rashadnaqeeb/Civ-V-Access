-- Movement / actions / pending-tracking half of the unit-control split.
-- Owns the Alt+QAZEDC direct-move bindings, the Tab action menu, the
-- Alt-letter quick-action bindings (Alt+F/S/W/X/H/R/P/U/N), the pending-
-- move tracker, the SerialEventUnitMove / MissionDispatched / war-confirm
-- listeners, and the DeclareWarPopupAccess hand-off methods.
--
-- Pending-move tracking bridges "commit" to "announce actual outcome".
-- On commit (Alt+QAZEDC or target-mode move-to) we stash target coords +
-- the active player's expected unit id. Two listeners drive resolution:
-- SerialEventUnitMove fires per-hex while the unit traverses (announce
-- on stop conditions: at target OR 0 MP), and the engine fork's
-- CivVAccessMissionDispatched hook fires once after the engine processes
-- the net message (announce moved / stopped-short / queued / failed
-- depending on the unit's post-dispatch state). The hook is the
-- authoritative resolver for MP, where the lockstep round-trip can stretch
-- the move's resolution out by seconds; SerialEventUnitMove still races
-- ahead in SP, and both paths early-return on _pending == nil so whichever
-- arrives first wins and the other no-ops. No cross-turn state -- pending
-- is cleared on every resolution.
--
-- Quick Movement support: with the option enabled the engine routes per-
-- hex moves through CvUnit::SetPosition (gDLL->GameplayUnitTeleported)
-- instead of QueueMoveForVisualization (gDLL->GameplayUnitMoved), so the
-- SerialEventUnitMove(ToHexes) events the pending resolver listens to
-- don't fire; SerialEventUnitTeleportedToHex does. We register the same
-- handler against that event so the resolution path runs identically.
--
-- War-confirm moves freeze pending into a deferred slot. Moving onto a
-- peaceful rival's tile (or attacking a peaceful rival's unit) does not
-- execute the move; the engine queues BUTTONPOPUP_DECLAREWARMOVE for
-- confirmation locally before any net message goes out, so neither
-- SerialEventUnitMove nor MissionDispatched will fire for the original
-- commit. The popup-shown listener moves _pending to _deferred to keep it
-- out of the resolver paths; DeclareWarPopupAccess re-arms via
-- notifyDeferredCommit on Yes (the engine re-issues the move via
-- Game.SelectionListMove, which sends a fresh PUSH_MISSION and resolves
-- through the normal path) or drops via notifyCommitCanceled on No / Esc
-- (the popup itself was the user's answer, no further speech needed).

include("CivVAccess_UnitControlCombat")

UnitControlMovement = {}

local MOD_NONE = 0
local MOD_ALT = 4

-- ===== Pending-move state =====
-- Kept module-local (not on civvaccess_shared) because a Context re-
-- entry should drop any in-flight pending move -- the listeners will
-- rehook on LoadScreenClose and a half-registered pending would never
-- resolve.
local _pending = nil
local _deferred = nil

local function clearPending()
    _pending = nil
end

-- opts.kind / opts.destLabel: discriminator + payload for the announcement
-- path. Default (nil opts) speaks the MOVE_TO-style "moved, N moves left" /
-- "stopped short" lines through UnitSpeech.moveResult. kind = "rebase" with
-- destLabel = "{Name}" routes through UnitSpeech.rebaseConfirm so the
-- announcement is "rebased to {Name}" rather than the misleading
-- "moved, 0 moves left" (rebase always finishMoves, so the MP suffix in
-- moveResult would imply a partial / failed move).
function UnitControlMovement.registerPending(unit, targetX, targetY, opts)
    if unit == nil then
        return
    end
    local snapshot = {
        unitID = unit:GetID(),
        startX = unit:GetX(),
        startY = unit:GetY(),
        targetX = targetX,
        targetY = targetY,
    }
    if opts ~= nil then
        snapshot.kind = opts.kind
        snapshot.destLabel = opts.destLabel
    end
    _pending = snapshot
end

-- ===== Helpers =====
local speakInterrupt = SpeechPipeline.speakInterrupt
local speakQueued = SpeechPipeline.speakQueued

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
function UnitControlMovement.enemyAt(plot)
    if plot == nil then
        return nil
    end
    return plot:GetBestDefender(-1, Game.GetActivePlayer(), nil, 1, 0, 0, 0)
end

-- Enemy city at plot if any, with the same active-team / war gate enemyAt
-- uses for units. Used by directMove so an Alt+QAZEDC into an enemy city
-- gates on the same melee-attack confirm path as one into an enemy unit;
-- exposed for UnitTargetMode which has the same active-team / war predicate
-- in its target legality checks.
function UnitControlMovement.enemyCityAt(plot)
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
local enemyCityAt = UnitControlMovement.enemyCityAt

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
        UnitControlMovement.registerPending(unit, targetX, targetY)
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

local function directMove(dir)
    local unit = selectedUnit()
    if unit == nil then
        UnitControlCombat.clearCombatConfirm()
        return
    end
    local target = Map.PlotDirection(unit:GetX(), unit:GetY(), dir)
    if target == nil then
        UnitControlCombat.clearCombatConfirm()
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_EDGE_OF_MAP"))
        return
    end
    local tx, ty = target:GetX(), target:GetY()
    local enemy = UnitControlMovement.enemyAt(target)
    local enemyCity
    if enemy == nil then
        enemyCity = enemyCityAt(target)
    end
    if enemy == nil and enemyCity == nil then
        UnitControlCombat.clearCombatConfirm()
        -- Air units don't direct-move; they rebase. The path diagnostic
        -- would just say "blocked," which reads as a per-tile failure
        -- and obscures that no direction will ever work.
        if unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_AIR_NO_DIRECT_MOVE"))
            return
        end
        -- 0-MP gate. Without this, the engine accepts the PUSH_MISSION
        -- and queues the move for next turn, which then resolves through
        -- onMissionDispatched as "queued for next turn." Alt+QAZEDC is
        -- the keyboard equivalent of mouse-click-to-step; queueing a
        -- single step has no UI affordance on the sighted side and
        -- collides with target mode, which is the explicit-queue surface
        -- (Shift+Enter, plus implicit 0-MP queueing on plain Enter).
        if unit:MovesLeft() <= 0 then
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_MOVES"))
            return
        end
        -- discriminativePath: if strict succeeds, we move. declareWar
        -- success also moves -- the engine queues BUTTONPOPUP_DECLAREWAR
        -- MOVE downstream and DeclareWarPopupAccess speaks the prompt.
        -- Any other outcome (stacking / enemy / unreachable with
        -- sub-cause) means the engine will refuse the step; speak the
        -- specific reason. closest-reachable direction is suppressed for
        -- the directMove case: for a 1-tile attempt the closest tile is
        -- usually the actor's own plot, which reads as the opposite of
        -- the direction the user just pressed.
        local diag = PathDiagnostic.discriminativePath(unit, target)
        if diag.ok ~= "strict" and diag.ok ~= "declareWar" then
            diag.closest = nil
            speakInterrupt(PathDiagnostic.formatFailure(diag, tx, ty))
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
    local attackReason = UnitControlCombat.preflightAttack(unit)
    if attackReason ~= nil then
        UnitControlCombat.clearCombatConfirm()
        speakInterrupt(attackReason)
        return
    end
    -- Target-specific gate covers refusals preflightAttack can't see
    -- (naval-vs-land, city-attack-only, etc.). Without it the user hears
    -- combat odds for an attack the engine will silently refuse.
    local targetReason = UnitControlCombat.preflightAttackTarget(unit, target)
    if targetReason ~= nil then
        UnitControlCombat.clearCombatConfirm()
        speakInterrupt(targetReason)
        return
    end
    -- Melee-attack confirm gate. Screen-reader users can't see the
    -- hover preview a mouse user does, so a second press into the same
    -- target plot is the cheap "are you sure" check.
    if UnitControlCombat.consumeCombatConfirm(target) then
        commitDirectMove(unit, target, tx, ty, enemy or enemyCity)
        return
    end
    UnitControlCombat.armCombatConfirm(target)
    if enemy ~= nil then
        speakInterrupt(UnitSpeech.meleePreview(unit, enemy, target))
    else
        speakInterrupt(UnitSpeech.cityMeleePreview(unit, enemyCity, target))
    end
end

-- ===== Rename unit =====
-- Fires the engine's BUTTONPOPUP_RENAME_UNIT for the selected unit. The
-- engine exposes this as a pencil button on UnitPanel that's only shown
-- for promotable units (military), but the popup itself accepts any
-- selected unit -- we open it for whatever's selected, matching the
-- BUTTONPOPUP wiring used by base UnitPanel.lua's OnEditNameClick.
-- Our SetUnitNameAccess wrapper makes the textfield + Accept / Cancel
-- accessible.
local function renameUnit()
    local unit = selectedUnit()
    if unit == nil then
        return
    end
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_RENAME_UNIT,
        Data1 = unit:GetID(),
        Data2 = -1,
        Data3 = -1,
        Option1 = false,
        Option2 = false,
    })
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

function UnitControlMovement.getBindings()
    local bindings = {
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
        bind(Keys.X, MOD_ALT, quickAction(ALT_ACTION_TYPES.SKIP), "Skip turn"),
        bind(Keys.H, MOD_ALT, quickAction(ALT_ACTION_TYPES.HEAL), "Heal"),
        bind(Keys.R, MOD_ALT, quickAction(ALT_ACTION_TYPES.RANGED), "Ranged attack"),
        bind(Keys.P, MOD_ALT, quickAction(ALT_ACTION_TYPES.PILLAGE), "Pillage"),
        bind(Keys.U, MOD_ALT, quickAction(ALT_ACTION_TYPES.UPGRADE), "Upgrade unit"),
        bind(Keys.N, MOD_ALT, renameUnit, "Rename unit"),
    }
    local helpEntries = {
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
        {
            keyLabel = "TXT_KEY_CIVVACCESS_UNIT_HELP_KEY_ALT_RENAME",
            description = "TXT_KEY_CIVVACCESS_UNIT_HELP_DESC_ALT_RENAME",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- ===== Move-resolution chain =====
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

-- Speak the moved / stopped-short result and clear pending. Shared by
-- onUnitMoveCompleted (per-hex SerialEventUnitMove fires while the unit
-- traverses the path) and onMissionDispatched (engine-fork hook fires
-- once after the net message is processed). Cursor follow-jump and the
-- pending clear happen here so both call sites stay symmetric.
local function speakMoveResult(unit, cx, cy)
    local tx, ty = _pending.targetX, _pending.targetY
    if _pending.kind == "rebase" then
        speakQueued(UnitSpeech.rebaseConfirm(_pending.destLabel))
    else
        local reachedTarget = (cx == tx and cy == ty)
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
    end
    -- Same toggle that gates the selection auto-jump: when off, the
    -- cursor stays where the player parked it and they can recenter
    -- with the explicit hotkey if they want to inspect the
    -- destination.
    if civvaccess_shared.cursorFollowsSelection then
        Cursor.jumpTo(cx, cy)
    end
    clearPending()
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
    -- Only speak on a stop condition (at target OR out of moves). The
    -- engine fires SerialEventUnitMove per hex traversed, so mid-path
    -- events need to be ignored. Compare MP in 60ths, not floored MP:
    -- a unit with 30/60 left can still enter the next tile (engine pays
    -- all remaining MP on over-cost entry, and roads cost only 30/60),
    -- so flooring would announce "stopped" one tile early in mixed-
    -- terrain or partial-MP cases.
    local movesLeft60ths = unit:MovesLeft()
    local reachedTarget = (cx == _pending.targetX and cy == _pending.targetY)
    if reachedTarget or movesLeft60ths <= 0 then
        speakMoveResult(unit, cx, cy)
    end
end

-- Engine-fork hook fired from CvDllNetMessageHandler::ResponsePushMission
-- and ResponseSwapUnits after the mission has been processed by the
-- simulation. In SP this lands almost immediately after the user's commit;
-- in MP it lands after the network lockstep slice processes the message
-- (typically a couple of seconds, sometimes more). Either way the engine
-- has either moved the unit, queued the mission for next turn, or refused
-- the message by the time this fires -- so the listener can decide moved /
-- stopped-short / queued / failed without a wall-clock timeout.
--
-- A frame-count expiry timer would assume SP-style synchronous resolution
-- and false-fire "action failed" while the network was still processing
-- the move in MP. Dispatch-event filtering (this listener) waits for the
-- engine's actual mission resolution instead.
--
-- Player + unit ID match is required: the hook fires for every PUSH_MISSION
-- the engine processes (including AI moves and other-player moves replayed
-- on our client for sync), but we only resolve when the dispatch is for
-- our active player's currently-pending unit. SerialEventUnitMove may
-- have already resolved _pending by the time this fires (the engine fires
-- the move event from inside PushMission); the _pending == nil early-
-- return covers that race.
local function onMissionDispatched(playerID, unitID, _missionType, _iData1, _iData2)
    if _pending == nil then
        return
    end
    if playerID ~= Game.GetActivePlayer() then
        return
    end
    if unitID ~= _pending.unitID then
        return
    end
    local unit = resolvePendingUnit()
    if unit == nil then
        clearPending()
        return
    end
    local cx, cy = unit:GetX(), unit:GetY()
    if cx == _pending.startX and cy == _pending.startY then
        -- Engine processed the message but the unit didn't move. Either
        -- it queued for next turn (mission queue non-empty -- 0-MP move,
        -- ACTIVITY_HOLD until MP refresh) or it was refused outright
        -- (engine dropped the PUSH_MISSION, unit ineligible at dispatch
        -- time, etc.).
        if #unit:GetMissionQueue() > 0 then
            speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_QUEUED_NEXT_TURN"))
        else
            speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
        end
        clearPending()
        return
    end
    speakMoveResult(unit, cx, cy)
end

-- Test-only seam. Production registers onMissionDispatched on
-- GameEvents.CivVAccessMissionDispatched in installListeners(); the
-- offline harness has no GameEvents pump, so suites call this entry
-- directly to drive the listener.
UnitControlMovement._onMissionDispatched = onMissionDispatched

-- ===== War-confirm popup intercept =====
-- The engine queues BUTTONPOPUP_DECLAREWARMOVE in lieu of executing a
-- move that would trigger a war declaration; the unit hasn't moved, so
-- the pending-expiry timer would false-positive.
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
function UnitControlMovement.notifyDeferredCommit()
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
    UnitControlMovement.registerPending(unit, snap.targetX, snap.targetY)
end

function UnitControlMovement.notifyCommitCanceled()
    _deferred = nil
end

-- Registers fresh listeners on every call (per CLAUDE.md's no-install-
-- once-guards rule for load-game-from-game survival).
function UnitControlMovement.installListeners()
    Log.installEvent(Events, "SerialEventUnitMove", onUnitMoveCompleted, "UnitControlMovement")
    Log.installEvent(Events, "SerialEventUnitMoveToHexes", onUnitMoveCompleted, "UnitControlMovement")
    -- Quick Movement routes per-hex moves through CvUnit::SetPosition,
    -- which fires SerialEventUnitTeleportedToHex instead of
    -- SerialEventUnitMove(ToHexes). Same handler resolves pending the
    -- same way; the (i, j, playerID, unitID) args are ignored.
    Log.installEvent(Events, "SerialEventUnitTeleportedToHex", onUnitMoveCompleted, "UnitControlMovement")
    Log.installEvent(Events, "SerialEventGameMessagePopup", onPopupShown, "UnitControlMovement")
    -- Engine-fork hook fired from CvDllNetMessageHandler::ResponsePushMission
    -- and ResponseSwapUnits after the engine processes a unit-mission net
    -- message. Drives the deterministic post-dispatch resolution of
    -- _pending. SerialEventUnitMove still races ahead in SP (per-hex
    -- engine event fires inside PushMission), and the _pending == nil
    -- early-return on the second arrival keeps both paths idempotent.
    Log.installEvent(GameEvents, "CivVAccessMissionDispatched", onMissionDispatched, "UnitControlMovement")
end

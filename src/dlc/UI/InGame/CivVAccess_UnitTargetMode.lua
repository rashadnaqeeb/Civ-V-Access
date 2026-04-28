-- Target-mode handler. Pushed above the baseline stack when the action
-- menu commits a targeted action (attack, range strike, move-to, etc.).
-- The actor is the selected unit; the cursor is the target. Space speaks
-- a per-mode trial preview; Enter commits; Esc cancels; Tab reopens the
-- action menu to switch verb.
--
-- capturesAllInput = false: cursor movement (QAZEDC), cursor info queries
-- (S/W/X/1/2/3 and the Shift-letter surveyor cluster), and scanner cycling
-- fall through to Baseline / Scanner unchanged. Only keys whose target-
-- mode behavior must differ from Baseline are bound here. Alt+QAZEDC and
-- the Alt-letter quick actions (F/S/W/H/P/R/U, Alt+Space) are bound as
-- no-ops: Baseline's direct-move and quick-action handlers would commit
-- against the actor while the engine is in an attack / move interface
-- mode, so we swallow them.
--
-- Unit cycling (. / ,) is not bound here either -- `,` falls through to
-- Baseline's UnitControl.cycleAll and `.` falls through to the engine's
-- native next-unit binding. Either path fires UnitSelectionChanged on
-- the new unit; UnitControl's listener pops this handler when the
-- selection moves to a different unit, which also covers mouse reselect
-- and actor death.
--
-- Preview math clones base-game EnemyUnitPanel.lua:655-707 (bidirectional
-- GetCombatDamage for melee, GetRangeCombatDamage for ranged). The move-
-- to preview runs Unit:GeneratePath / Unit:GetPath (engine fork bindings)
-- and speaks MP cost + turn count.

UnitTargetMode = {}

local MOD_NONE = 0
local MOD_SHIFT = 1
local MOD_ALT = 4

-- CvAStar.h MOVE_DECLARE_WAR. Lets the unit pathfinder route through
-- tiles whose entry would declare war (peaceful rival territory),
-- matching the engine's interface pathfinder for hover-path display.
local MOVE_DECLARE_WAR = 0x00000020

-- Tracks the actor's unit ID while this handler is on the stack.
-- Exposed via UnitTargetMode.currentActorID so UnitControl's selection-
-- changed listener can tell whether a selection event reflects a cycle
-- away from the actor (pop target mode) vs. a re-select of the same unit.
local _currentActorID = nil

function UnitTargetMode.currentActorID()
    return _currentActorID
end

local function restoreSelection()
    UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
end

local function speakInterrupt(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakInterrupt(text)
end

local function cursorPlot()
    local cx, cy = Cursor.position()
    if cx == nil then
        return nil
    end
    return Map.GetPlot(cx, cy), cx, cy
end

-- Format a 60ths MP value as the engine does: integer when whole,
-- one decimal when fractional. Road/railroad costs (e.g. 20/60 MP)
-- need the decimal; plain terrain (60/60, 120/60) reads cleaner as
-- "1" / "2" than "1.0" / "2.0".
local function formatMP(mp60ths)
    local whole = mp60ths / 60
    local rounded = math.floor(whole * 10 + 0.5) / 10
    if rounded == math.floor(rounded) then
        return tostring(math.floor(rounded))
    end
    return string.format("%.1f", rounded)
end

local function movePathPreview(actor, targetPlot)
    local fromPlot = actor:GetPlot()
    if fromPlot:GetPlotIndex() == targetPlot:GetPlotIndex() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    -- Match the engine's interface pathfinder (CvDllContext.cpp:1269):
    -- it pathfinds through fog (no MOVE_TERRITORY_NO_UNEXPLORED) and uses
    -- MOVE_DECLARE_WAR so peaceful rival tiles still route. Try the plain
    -- search first; if it fails, retry with MOVE_DECLARE_WAR so we can
    -- distinguish "would declare war" from "physically unreachable".
    local ok = actor:GeneratePath(targetPlot)
    local declaresWar = false
    if not ok then
        ok = actor:GeneratePath(targetPlot, MOVE_DECLARE_WAR)
        declaresWar = ok
    end
    if not ok then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE")
    end
    local path = actor:GetPath()
    -- Engine path nodes carry m_iData1=moves remaining and m_iData2=turn
    -- count after arriving at that node. Front of GetPath() is the start
    -- (we reverse in the binding); end is the destination. iData2 starts
    -- at 1 and increments only when the parent node had 0 moves left
    -- (turn boundary crossed). Engine's CvUnit::GeneratePath exposes the
    -- destination's iData2 as iPathTurns; so "turns=1" means the unit
    -- arrives this turn.
    local lastNode = path[#path]
    local turns = lastNode.turn
    -- The engine's interface pathfinder routes optimistically through
    -- fog: PathValid (CvAStar.cpp:1361-1370) skips the land-vs-water
    -- check on unrevealed destinations, and CvUnitMovement::MovementCost
    -- (CvUnitMovement.cpp:184-189) applies ConsumesAllMoves to every
    -- unrevealed tile for human units, so each fogged hex costs a full
    -- turn regardless of underlying terrain. Turn count is therefore a
    -- pure path-length-through-fog signal, not a terrain leak; sighted
    -- gets the same number from PathHelpManager turn numerals at Z=15
    -- above the fog overlay (PathHelpManager.lua:30-48). What sighted
    -- can NOT see is the per-tile route shape inside the fog.
    --
    -- Match that: speak per-tile geometry up to the last revealed hex
    -- (sighted players visually trace this through the map), then "then
    -- unexplored" plus the turn count. Stops at the first fogged hex; if
    -- the path re-emerges into revealed terrain after that, we don't try
    -- to stitch the segments -- those re-emergence cases are uncommon
    -- and the saved info isn't worth the parse complexity.
    local team = actor:GetTeam()
    local isDebug = Game.IsDebugMode()
    local crossesFog = false
    local revealedPrefix
    if not isDebug then
        revealedPrefix = {}
        for _, node in ipairs(path) do
            local p = Map.GetPlot(node.x, node.y)
            if p ~= nil and not p:IsRevealed(team, isDebug) then
                crossesFog = true
                break
            end
            revealedPrefix[#revealedPrefix + 1] = node
        end
    end
    local summary
    if crossesFog then
        local prefixSteps = HexGeom.stepListFromPath(revealedPrefix)
        if prefixSteps ~= "" then
            if turns <= 1 then
                summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN", prefixSteps)
            else
                summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN", turns, prefixSteps)
            end
        elseif turns <= 1 then
            summary = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN")
        else
            summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN", turns)
        end
    else
        local maxMoves = actor:MaxMoves()
        local startMP = actor:MovesLeft()
        if startMP < 0 then startMP = maxMoves end
        local mpRemaining = lastNode.moves
        -- Total MP spent from start to destination, in 60ths.
        local mpCost = (math.max(0, turns - 1)) * maxMoves + (startMP - mpRemaining)
        local mpText = formatMP(mpCost)
        local leftText = formatMP(mpRemaining)
        if turns <= 1 then
            summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN", mpText, leftText)
        else
            summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN", mpText, turns, leftText)
        end
        local steps = HexGeom.stepListFromPath(path)
        if steps ~= "" then
            summary = summary .. ", " .. steps
        end
    end
    if declaresWar then
        summary = summary .. ", " .. Text.key("TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR")
    end
    return summary
end

local function rangedPreview(actor, defender, targetPlot, targetX, targetY)
    if not actor:CanRangeStrikeAt(targetX, targetY, true, true) then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE")
    end
    return UnitSpeech.rangedPreview(actor, defender, targetPlot)
end

local function firstEnemyUnit(plot)
    if plot == nil then
        return nil
    end
    local team = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    for i = 0, plot:GetNumUnits() - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and not u:IsInvisible(team, isDebug) and u:GetOwner() ~= Game.GetActivePlayer() then
            return u
        end
    end
    return nil
end

-- Enemy city at plot if any. The active team must be at war with the city's
-- owner -- a peaceful rival's city isn't a combat target (the move that
-- enters it would route through the war-confirm popup, not a strike).
local function enemyCityAt(plot)
    if plot == nil or not plot:IsCity() then
        return nil
    end
    local city = plot:GetPlotCity()
    if city == nil or city:GetOwner() == Game.GetActivePlayer() then
        return nil
    end
    local activeTeam = Teams[Game.GetActiveTeam()]
    if activeTeam == nil then
        return nil
    end
    local owner = Players[city:GetOwner()]
    if owner == nil then
        return nil
    end
    if not (owner:IsBarbarian() or activeTeam:IsAtWar(owner:GetTeam())) then
        return nil
    end
    return city
end

local function isRangeAttackMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK or mode == InterfaceModeTypes.INTERFACEMODE_AIRSTRIKE
end

local function isMeleeAttackMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_ATTACK
end

local function isMoveMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_MOVE_TO
        or mode == InterfaceModeTypes.INTERFACEMODE_MOVE_TO_TYPE
        or mode == InterfaceModeTypes.INTERFACEMODE_MOVE_TO_ALL
end

local function isRouteMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_ROUTE_TO
end

-- Per-target previews for the modes whose only sighted feedback is a
-- highlight tint (legal target = colored, otherwise dimmed). The engine
-- doesn't expose per-target failure reasons, so illegal collapses to a
-- single "cannot X here" string. Legal speaks the destination plot's
-- glance summary so the player can sanity-check terrain / units / city
-- before committing.
local function legalityPreview(canTarget, illegalKey, plot)
    if not canTarget then
        return Text.key(illegalKey)
    end
    local glance = PlotComposers.glance(plot)
    if glance == nil or glance == "" then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    return glance
end

-- Air sweep has no Can*At; the engine accepts any plot in air range and
-- picks an interceptor at random at commit time. Best signal we can give
-- is "how many interceptors are visible covering this tile" -- 0 means
-- the sweep will whiff (no one to clear), N>0 names the threat density.
local function airSweepPreview(actor, plot)
    local interceptors = actor:GetInterceptorCount(plot, nil, true, true)
    local parts = {}
    if interceptors > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS", interceptors)
    else
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NO_INTERCEPTORS")
    end
    local glance = PlotComposers.glance(plot)
    if glance ~= nil and glance ~= "" then
        parts[#parts + 1] = glance
    end
    return table.concat(parts, ", ")
end

-- Route-to preview. The engine routes a worker on MISSION_ROUTE_TO via
-- GC.GetBuildRouteFinder() (exposed as Game.GetBuildRoutePath); we speak
-- the path length (tiles excluding the worker's start) and the total
-- build turns across plots that still need a route built.

-- Pick the build the engine will queue per tile. Mirrors the engine's
-- GetBestBuildRouteForRoadTo: highest-Routes.Value build the player has
-- tech for. Resolved once per preview; tech doesn't change mid-preview.
local function pickBestRouteBuild(team)
    local bestValue = -1
    local bestBuild, bestRoute = nil, nil
    if GameInfo == nil or GameInfo.Builds == nil then
        return nil, nil, -1
    end
    for buildRow in GameInfo.Builds() do
        local routeName = buildRow.RouteType
        if routeName ~= nil and routeName ~= "NONE" then
            local routeId = GameInfoTypes and GameInfoTypes[routeName]
            if routeId ~= nil then
                local routeRow = GameInfo.Routes[routeId]
                if routeRow ~= nil then
                    local prereq = buildRow.PrereqTech
                    local hasTech = true
                    if prereq ~= nil and prereq ~= "NONE" then
                        local techId = GameInfoTypes and GameInfoTypes[prereq]
                        if techId == nil or team == nil or not team:IsHasTech(techId) then
                            hasTech = false
                        end
                    end
                    if hasTech then
                        local value = routeRow.Value or 0
                        if value > bestValue then
                            bestValue = value
                            bestBuild = buildRow.ID
                            bestRoute = routeId
                        end
                    end
                end
            end
        end
    end
    return bestBuild, bestRoute, bestValue
end

-- Per-plot build turns under the worker's contribution rate. Cities and
-- plots already at-or-above the target route tier are zero-cost. The
-- start plot zeroes the extra-rate when the worker is mid-build of this
-- same route there, matching the base-game tooltip's no-double-count.
local function plotBuildTurns(plot, buildId, routeValue, extraRate, isStartPlot)
    if buildId == nil or plot:IsCity() then
        return 0
    end
    local existing = plot:GetRouteType()
    if existing >= 0 then
        local existingRow = GameInfo.Routes[existing]
        if existingRow ~= nil and (existingRow.Value or 0) >= routeValue then
            return 0
        end
    end
    local extra = extraRate
    if isStartPlot and plot:GetBuildType() == buildId then
        extra = 0
    end
    return plot:GetBuildTurnsLeft(buildId, plot:GetOwner(), extra, extra)
end

local function routePathPreview(actor, targetPlot)
    local fromPlot = actor:GetPlot()
    if fromPlot:GetPlotIndex() == targetPlot:GetPlotIndex() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    local team = actor:GetTeam()
    local pTeam = Teams[team]
    local isDebug = Game.IsDebugMode()
    if not isDebug and not targetPlot:IsRevealed(team, isDebug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    local buildId, routeId, routeValue = pickBestRouteBuild(pTeam)
    if buildId == nil then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD")
    end
    local owner = actor:GetOwner()
    local path = Game.GetBuildRoutePath(fromPlot:GetX(), fromPlot:GetY(), targetPlot:GetX(), targetPlot:GetY(), owner)
    if #path == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE")
    end
    local extraRate = actor:WorkRate(true, buildId)
    local buildTurns = 0
    for i, node in ipairs(path) do
        local plot = Map.GetPlot(node.x, node.y)
        if plot ~= nil then
            buildTurns = buildTurns + plotBuildTurns(plot, buildId, routeValue, extraRate, i == 1)
        end
    end
    local tileCount = #path - 1
    if buildTurns == 0 then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE", tileCount)
    end
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE", tileCount, buildTurns)
end

-- Range / melee preview that prefers a unit garrison over the city
-- itself. EnemyUnitPanel does the same: a defended city's combat goes
-- through the garrison's stats, undefended cities use city stats. Returns
-- nil if the plot has no enemy combat target (caller speaks EMPTY).
local function combatPreviewAt(actor, plot, tx, ty, ranged)
    local defenderUnit = firstEnemyUnit(plot)
    if defenderUnit ~= nil then
        if ranged then
            return rangedPreview(actor, defenderUnit, plot, tx, ty)
        end
        return UnitSpeech.meleePreview(actor, defenderUnit, plot)
    end
    local defenderCity = enemyCityAt(plot)
    if defenderCity ~= nil then
        if ranged then
            return UnitSpeech.cityRangedPreview(actor, defenderCity, plot)
        end
        return UnitSpeech.cityMeleePreview(actor, defenderCity, plot)
    end
    return nil
end

local function buildPreview(self)
    local plot, tx, ty = cursorPlot()
    if plot == nil then
        return ""
    end
    local mode = self._mode
    local actor = self._actor
    local parts = {}
    if isRangeAttackMode(mode) then
        local text = combatPreviewAt(actor, plot, tx, ty, true)
        if text == nil or text == "" then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        else
            parts[#parts + 1] = text
        end
        local rivalTeam = actor:GetDeclareWarRangeStrike(plot)
        if rivalTeam ~= -1 then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR")
        end
    elseif isMeleeAttackMode(mode) then
        local text = combatPreviewAt(actor, plot, tx, ty, false)
        if text == nil or text == "" then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        else
            parts[#parts + 1] = text
        end
    elseif isMoveMode(mode) then
        -- Move-into-enemy resolves as an attack at commit time (engine
        -- MoveOrAttack). Speak the matching combat preview when adjacent
        -- so the user gets damage prediction; further away the engine
        -- queues a multi-turn move that won't attack this turn -- speak
        -- the path as a regular move. War-declaration on move is
        -- surfaced by the engine's popup at commit time (routed through
        -- GenericPopupAccess), so no pre-commit detection here.
        local hasEnemy = firstEnemyUnit(plot) ~= nil or enemyCityAt(plot) ~= nil
        local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), tx, ty)
        if hasEnemy and dist == 1 then
            local text = combatPreviewAt(actor, plot, tx, ty, false)
            if text == nil or text == "" then
                parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
            else
                parts[#parts + 1] = text
            end
        else
            parts[#parts + 1] = movePathPreview(actor, plot)
        end
    elseif isRouteMode(mode) then
        parts[#parts + 1] = routePathPreview(actor, plot)
    elseif mode == InterfaceModeTypes.INTERFACEMODE_PARADROP then
        parts[#parts + 1] = legalityPreview(
            actor:CanParadropAt(actor:GetPlot(), tx, ty),
            "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL",
            plot
        )
    elseif mode == InterfaceModeTypes.INTERFACEMODE_AIRLIFT then
        parts[#parts + 1] = legalityPreview(
            actor:CanAirliftAt(actor:GetPlot(), tx, ty),
            "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL",
            plot
        )
    elseif mode == InterfaceModeTypes.INTERFACEMODE_REBASE then
        parts[#parts + 1] = legalityPreview(
            actor:CanRebaseAt(actor:GetPlot(), tx, ty),
            "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL",
            plot
        )
    elseif mode == InterfaceModeTypes.INTERFACEMODE_EMBARK then
        parts[#parts + 1] = legalityPreview(
            actor:CanEmbarkOnto(actor:GetPlot(), plot),
            "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL",
            plot
        )
    elseif mode == InterfaceModeTypes.INTERFACEMODE_DISEMBARK then
        parts[#parts + 1] =
            legalityPreview(actor:CanDisembarkOnto(plot), "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL", plot)
    elseif mode == InterfaceModeTypes.INTERFACEMODE_NUKE then
        parts[#parts + 1] =
            legalityPreview(actor:CanNukeAt(tx, ty), "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL", plot)
    elseif mode == InterfaceModeTypes.INTERFACEMODE_AIR_SWEEP then
        parts[#parts + 1] = airSweepPreview(actor, plot)
    else
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    return table.concat(parts, ", ")
end

-- Generic "commit current interface mode at cursor plot" path. Mirrors
-- base WorldView.lua:364-382 (missionTypeLButtonUpHandler): look up the
-- mode's backing mission id, check CanDoInterfaceMode, fire the network
-- message, and drop back to selection mode. Range-attack war-declare
-- popups come through the engine's own ButtonPopupTypes.BUTTONPOPUP_*
-- dispatch and are handled by GenericPopupAccess, not here.
--
-- INTERFACEMODE_ATTACK is special-cased to Game.SelectionListMove rather
-- than GAMEMESSAGE_PUSH_MISSION + MISSION_MOVE_TO. The base UI's mouse
-- click handler (InGame.lua AttackIntoTile) uses SelectionListMove for
-- ATTACK mode; mirroring that keeps the mod on the same code path the
-- engine has been exercised against for melee attacks against units AND
-- cities. The mission-push variant is technically another route through
-- CvUnitMission but base never uses it for melee attacks, and we hit
-- "actions don't resolve" reports against cities through it.
--
-- Combat commits register a combat-pending snapshot in lieu of a normal
-- move pending. EndCombatSim is the primary announcement path with
-- animations on; the snapshot is the Quick-Combat fallback (engine
-- skips gDLL->GameplayUnitCombat in CvUnitCombat.cpp ~3624 and
-- EndCombatSim never fires). Defender resolution prefers a unit
-- garrison over the city itself, so a defended city snapshots the
-- defender unit (matching what EndCombatSim sends) and an undefended
-- city snapshots the city.
local function willCauseCombat(actor, plot, mode)
    if isMeleeAttackMode(mode) or isRangeAttackMode(mode) then
        return true
    end
    if isMoveMode(mode) then
        if UnitControl.enemyAt(plot) ~= nil or enemyCityAt(plot) ~= nil then
            -- Move-into-enemy resolves as an attack only when the unit is
            -- adjacent on commit; further away the engine queues a multi-
            -- turn move and combat happens on a later turn (when no
            -- snapshot can be tied to this commit). Restrict combat
            -- pending to the adjacent case.
            local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), plot:GetX(), plot:GetY())
            return dist == 1
        end
    end
    return false
end

-- LoS probe range used by the ranged-attack drill-down. Mirrors
-- CursorCore.targetabilityPrefix: a large explicit range so the engine's
-- internal range gate inside CanSeePlot doesn't conflate "blocked by
-- terrain" with "too far away" -- the latter we report separately as
-- "out of range" via Map.PlotDistance.
local LOS_PROBE_RANGE = 100

-- Per-mode commit-time precheck. Returns:
--   nil  -- mode recognized + gate passed -> push the mission
--   key  -- mode recognized + gate failed -> speak the key, abort
--   false -- mode unrecognized -> caller falls back to UI.CanDoInterface
--          Mode as the engine's safety net
--
-- Replaces a blanket UI.CanDoInterfaceMode gate that returned a single
-- generic "action failed" for every reason. CanDoInterfaceMode also
-- returns false for 0-MP MOVE_TO commits the engine would happily queue
-- for next turn -- preflightMove doesn't gate on MP, so 0-MP moves get
-- pushed and the schedulePendingExpiry path then announces "queued for
-- next turn" instead of falsely reporting failure.
local function commitFailureReason(actor, mode, plot, tx, ty)
    if isMoveMode(mode) then
        return UnitControl.preflightMove(actor, plot)
    end
    if isRouteMode(mode) then
        local path = Game.GetBuildRoutePath(actor:GetX(), actor:GetY(), tx, ty, actor:GetOwner())
        if #path == 0 then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE")
        end
        return nil
    end
    if isMeleeAttackMode(mode) then
        local r = UnitControl.preflightAttack(actor)
        if r ~= nil then
            return r
        end
        local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), tx, ty)
        if dist ~= 1 then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT")
        end
        if firstEnemyUnit(plot) == nil and enemyCityAt(plot) == nil then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        end
        return nil
    end
    if isRangeAttackMode(mode) then
        if not actor:CanRangeStrike() then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK")
        end
        if actor:MovesLeft() <= 0 then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NO_MOVES")
        end
        -- bNeedWar=false: a strike on a peaceful rival's tile passes
        -- the gate; the engine queues BUTTONPOPUP_DECLAREWARRANGESTRIKE
        -- and GenericPopupAccess speaks the confirmation. bNoncombat
        -- Allowed=true so an undefended city / civilian-occupied tile
        -- is a valid target.
        if not actor:CanRangeStrikeAt(tx, ty, false, true) then
            -- Drill into why. Order matches user-helpful priority:
            -- semantic (no target), geometric (too far), terrain
            -- (blocked LoS). Cursor's targetabilityPrefix already speaks
            -- range / LoS while the user navigates, but commit-time also
            -- emits them so a user who pressed enter without hearing the
            -- prefix still gets a clear reason.
            if firstEnemyUnit(plot) == nil and enemyCityAt(plot) == nil then
                return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
            end
            local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), tx, ty)
            if dist > actor:Range() then
                return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE")
            end
            local ignoresLoS = actor:GetDomainType() == DomainTypes.DOMAIN_AIR
                or actor:IsRangeAttackIgnoreLOS()
            if
                not ignoresLoS
                and not actor:GetPlot():CanSeePlot(plot, actor:GetTeam(), LOS_PROBE_RANGE, DirectionTypes.NO_DIRECTION)
            then
                return Text.key("TXT_KEY_CIVVACCESS_TARGET_UNSEEN")
            end
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED")
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_PARADROP then
        if not actor:CanParadropAt(actor:GetPlot(), tx, ty) then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL")
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_AIRLIFT then
        if not actor:CanAirliftAt(actor:GetPlot(), tx, ty) then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL")
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_REBASE then
        if not actor:CanRebaseAt(actor:GetPlot(), tx, ty) then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL")
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_EMBARK then
        if not actor:CanEmbarkOnto(actor:GetPlot(), plot) then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL")
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_DISEMBARK then
        if not actor:CanDisembarkOnto(plot) then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL")
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_NUKE then
        if not actor:CanNukeAt(tx, ty) then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL")
        end
        return nil
    end
    return false
end

-- queued=true is shift+enter: append the mission to the unit's queue
-- via bShift on the engine's PUSH_MISSION net message (matches base
-- WorldView.lua's mouse-shift-click path), skip pending registration
-- (the move won't necessarily resolve this turn, so the SerialEventUnit*
-- "moved / stopped short" announcement isn't ours to make), and stay in
-- target mode so the user can chain more shift+enters to add legs. Plain
-- enter (queued=false) keeps the existing replace-and-resolve flow.
--
-- queued mode skips melee attack and combat-pending paths entirely:
-- combat doesn't queue meaningfully (the engine still resolves on the
-- following turn but we have no pre-snapshot for the eventual combat),
-- and bShift on a non-MOVE mission is a base-engine pass-through with
-- no on-screen path line for sighted players either.
local function commitAtCursor(self, queued)
    local plot, tx, ty = cursorPlot()
    if plot == nil then
        SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
        return
    end
    local mode = UI.GetInterfaceMode()
    local modeRow = GameInfo.InterfaceModes[mode]
    if modeRow == nil then
        Log.error("UnitTargetMode.commit: no InterfaceModes row for mode " .. tostring(mode))
        return
    end
    local mission = GameInfoTypes[modeRow.Mission]
    if mission == nil or mission == MissionTypes.NO_MISSION then
        Log.warn("UnitTargetMode.commit: interface mode has no backing mission; popping without commit")
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end
    -- Queued branch runs before the CanDoInterfaceMode gate: a 0-MP unit
    -- has CanDoInterfaceMode(MOVE_TO) returning false, but the engine
    -- accepts a queued PUSH_MISSION regardless (StartMission sets
    -- ACTIVITY_HOLD until the next turn brings MP). Plain enter still
    -- hits the gate below and speaks "action failed."
    if queued then
        if isMeleeAttackMode(mode) then
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"))
            return
        end
        -- Send bShift=true only if the queue is non-empty. Engine quirk:
        -- CvUnitMission::InsertAtEndMissionQueue only calls
        -- ActivateHeadMission when bStart (= !bAppend) is true. bShift=true
        -- maps to bAppend=true, so a shift-push onto an empty queue lands
        -- in the queue with no active head and the unit sits there.
        -- Vanilla mouse shift+click hits the same wall; the difference is
        -- that base UI's mouse path expects a prior plain click to have
        -- already activated a head. We treat the first shift+enter as
        -- equivalent to plain enter (queue starts immediately), and only
        -- second-and-later shift+enters as true appends.
        local bShift = #self._actor:GetMissionQueue() > 0
        Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, mission, tx, ty, 0, false, bShift)
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"))
        return
    end
    -- Per-mode reason check. Returns nil to allow commit, a TXT key to
    -- speak and abort, or false for "unrecognized mode -- defer to the
    -- engine gate." The engine gate is only consulted on fall-through;
    -- for recognized modes we are the source of truth so MOVE_TO can
    -- bypass CanDoInterfaceMode's wrong-for-0-MP false negative.
    local reason = commitFailureReason(self._actor, mode, plot, tx, ty)
    if reason == false then
        if not UI.CanDoInterfaceMode(mode) then
            reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED")
        else
            reason = nil
        end
    end
    if reason ~= nil then
        SpeechPipeline.speakQueued(reason)
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end
    if willCauseCombat(self._actor, plot, mode) then
        -- Defender preference depends on attack type. Ranged attacks
        -- (ranged-strike / airstrike) target the city directly when one
        -- exists; the engine damages CityHP, not the garrison's. So a
        -- ranged-vs-defended-city snapshot must read city HP or no
        -- damage delta surfaces. Melee attacks go through the garrison
        -- first (engine's MoveOrAttack picks the unit defender as the
        -- combat target), so unit-first is correct there.
        local defenderCity = enemyCityAt(plot)
        local defenderUnit = firstEnemyUnit(plot)
        if isRangeAttackMode(mode) and defenderCity ~= nil then
            UnitControl.registerCityCombatPending(self._actor, defenderCity)
        elseif defenderUnit ~= nil then
            UnitControl.registerCombatPending(self._actor, defenderUnit)
        elseif defenderCity ~= nil then
            UnitControl.registerCityCombatPending(self._actor, defenderCity)
        end
    else
        UnitControl.registerPending(self._actor, tx, ty)
    end
    if isMeleeAttackMode(mode) then
        -- Match base UI's AttackIntoTile (InGame.lua); SelectionListMove
        -- is the engine-blessed melee-attack commit path against units
        -- AND cities.
        Game.SelectionListMove(plot, false, false, false)
    else
        Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, mission, tx, ty, 0, false, false)
    end
    HandlerStack.removeByName("UnitTargetMode", false)
    restoreSelection()
end

local bind = HandlerStack.bind

-- Push target-mode handler. `actor` is the unit the action is being
-- committed against; `iAction` is the hash that entered this mode (kept
-- for logging / future verb-display use); `mode` is the engine interface
-- mode the menu commit just set (so we don't re-read UI.GetInterfaceMode
-- and race the engine's own transitions).
function UnitTargetMode.enter(actor, iAction, mode)
    if actor == nil then
        Log.warn("UnitTargetMode.enter: nil actor; aborting")
        return
    end
    local self = {
        name = "UnitTargetMode",
        capturesAllInput = false,
        _actor = actor,
        _iAction = iAction,
        _mode = mode,
    }
    local noop = function() end
    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            speakInterrupt(buildPreview(self))
        end, "Target preview"),
        bind(Keys.VK_RETURN, MOD_NONE, function()
            commitAtCursor(self)
        end, "Commit target"),
        bind(Keys.VK_RETURN, MOD_SHIFT, function()
            commitAtCursor(self, true)
        end, "Queue target"),
        bind(Keys.VK_ESCAPE, MOD_NONE, function()
            HandlerStack.removeByName("UnitTargetMode", false)
            restoreSelection()
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
        end, "Cancel target mode"),
        bind(Keys.VK_TAB, MOD_NONE, function()
            HandlerStack.removeByName("UnitTargetMode", false)
            restoreSelection()
            UnitActionMenu.open(actor)
        end, "Switch verb"),
        -- Alt+QAZEDC no-ops: Baseline binds these to direct-move, which
        -- would move the actor while an attack / move interface mode is
        -- live. Bind here so InputRouter matches and returns before the
        -- key falls through.
        bind(Keys.Q, MOD_ALT, noop, "Block direct-move NW"),
        bind(Keys.E, MOD_ALT, noop, "Block direct-move NE"),
        bind(Keys.A, MOD_ALT, noop, "Block direct-move W"),
        bind(Keys.D, MOD_ALT, noop, "Block direct-move E"),
        bind(Keys.Z, MOD_ALT, noop, "Block direct-move SW"),
        bind(Keys.C, MOD_ALT, noop, "Block direct-move SE"),
        -- Alt-letter quick-action no-ops, same rationale as the direct-move
        -- block: a fortify / heal / pillage / wake / etc. commit while the
        -- engine is mid-target-mode would fire against the actor and fight
        -- the picker the user is in.
        bind(Keys.F, MOD_ALT, noop, "Block sleep/fortify"),
        bind(Keys.S, MOD_ALT, noop, "Block sentry"),
        bind(Keys.W, MOD_ALT, noop, "Block wake/cancel"),
        bind(Keys.H, MOD_ALT, noop, "Block heal"),
        bind(Keys.P, MOD_ALT, noop, "Block pillage"),
        bind(Keys.R, MOD_ALT, noop, "Block ranged attack"),
        bind(Keys.U, MOD_ALT, noop, "Block upgrade"),
        bind(Keys.VK_SPACE, MOD_ALT, noop, "Block skip turn"),
    }
    self.helpEntries = {}
    -- onDeactivate always restores the selection mode. Belt-and-
    -- suspenders: every binding that pops also calls restoreSelection,
    -- but an external popAbove / popByName could still unwind us.
    self.onDeactivate = function()
        _currentActorID = nil
        restoreSelection()
    end
    self.onActivate = function()
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"))
    end
    if HandlerStack.push(self) then
        _currentActorID = actor:GetID()
    end
end

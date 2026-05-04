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

local speakInterrupt = SpeechPipeline.speakInterrupt

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
-- "1" / "2" than "1.0" / "2.0". Built from integer parts so the
-- decimal separator stays "." regardless of LC_NUMERIC -- a comma-
-- decimal locale would otherwise feed "1,5" to Tolk, spoken as "one
-- comma five."
local function formatMP(mp60ths)
    local tenths = math.floor(mp60ths * 10 / 60 + 0.5)
    local whole = math.floor(tenths / 10)
    local frac = tenths - whole * 10
    if frac == 0 then
        return tostring(whole)
    end
    return tostring(whole) .. "." .. tostring(frac)
end

local function movePathPreview(actor, targetPlot)
    local fromPlot = actor:GetPlot()
    if fromPlot:GetPlotIndex() == targetPlot:GetPlotIndex() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    -- Discriminative retry: strict first, then DECLARE_WAR / IGNORE_STACKING /
    -- UNITS_THROUGH_ENEMY in turn. The first relaxation that recovers the
    -- path names the cause. None work -> closest-reached fallback. Closest-
    -- reached coords come from the strict-failure closed list (saved in
    -- diag.closest before any retry overwrites it).
    local diag = PathDiagnostic.discriminativePath(actor, targetPlot)
    if diag.ok ~= "strict" then
        return PathDiagnostic.formatFailure(diag, targetPlot:GetX(), targetPlot:GetY())
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
    -- Each path node carries `revealed` (set by the engine binding from the
    -- same isRevealed answer the pathfinder used to compute costs). In
    -- debug mode every node reports revealed=true, so crossesFog stays
    -- false and the else branch handles the path uniformly.
    local crossesFog = false
    local revealedPrefix = {}
    for _, node in ipairs(path) do
        if not node.revealed then
            crossesFog = true
            break
        end
        revealedPrefix[#revealedPrefix + 1] = node
    end
    local summary
    if crossesFog then
        local prefixSteps = HexGeom.stepListFromPath(revealedPrefix)
        if prefixSteps ~= "" then
            if turns <= 1 then
                summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_THIS_TURN", prefixSteps)
            else
                summary = Text.formatPlural(
                    "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_PREFIX_MULTI_TURN",
                    turns,
                    turns,
                    prefixSteps
                )
            end
        elseif turns <= 1 then
            summary = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_THIS_TURN")
        else
            summary = Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_FOG_MULTI_TURN", turns, turns)
        end
    else
        local maxMoves = actor:MaxMoves()
        local startMP = actor:MovesLeft()
        if startMP < 0 then
            startMP = maxMoves
        end
        local mpRemaining = lastNode.moves
        -- Total MP spent from start to destination, in 60ths.
        local mpCost = (math.max(0, turns - 1)) * maxMoves + (startMP - mpRemaining)
        local mpText = formatMP(mpCost)
        local leftText = formatMP(mpRemaining)
        if turns <= 1 then
            summary = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN", mpText, leftText)
        else
            summary = Text.formatPlural(
                "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN",
                turns,
                mpText,
                turns,
                leftText
            )
        end
        local steps = HexGeom.stepListFromPath(path)
        if steps ~= "" then
            summary = summary .. ", " .. steps
        end
    end
    -- Embark/disembark hint for the non-obvious cases only: same-domain
    -- start and end with the OPPOSITE domain in the middle. Land->land
    -- across water means the unit must embark mid-trip; water->water
    -- across a land hop means it must disembark. Cross-domain endpoints
    -- (land->water, water->land) make the transition self-evident from
    -- the destination, no announcement needed. DOMAIN_LAND gate filters
    -- naval / air, where the announcement doesn't apply (naval routes
    -- through cities don't count as disembarking). CanMoveAllTerrain
    -- filters Helicopter Gunship and similar units that bypass the
    -- embark mechanic via the canMoveAllTerrain branch of PathValid
    -- (CvAStar.cpp:1365) -- they cross water without embarking, so
    -- "requires embark" would be wrong for them. Land units without
    -- embark tech can't produce a water-crossing path in the first
    -- place, so no extra gate needed for that.
    if
        actor:GetDomainType() == DomainTypes.DOMAIN_LAND
        and not actor:CanMoveAllTerrain()
        and #path >= 3
    then
        local startWater = Map.GetPlot(path[1].x, path[1].y):IsWater()
        local endWater = Map.GetPlot(path[#path].x, path[#path].y):IsWater()
        if startWater == endWater then
            for i = 2, #path - 1 do
                local plot = Map.GetPlot(path[i].x, path[i].y)
                if plot:IsWater() ~= startWater then
                    if startWater then
                        summary = summary .. ", " .. Text.key("TXT_KEY_CIVVACCESS_PATH_REQUIRES_DISEMBARK")
                    else
                        summary = summary .. ", " .. Text.key("TXT_KEY_CIVVACCESS_PATH_REQUIRES_EMBARK")
                    end
                    break
                end
            end
        end
    end
    return summary
end

local function rangedPreview(actor, defender, targetPlot, targetX, targetY)
    -- bNeedWar=false so a strike on a peaceful rival's tile passes the
    -- gate and gets the full damage preview; the engine will queue
    -- BUTTONPOPUP_DECLAREWARRANGESTRIKE on commit and GenericPopupAccess
    -- speaks the confirmation. With bNeedWar=true the preview wrongly
    -- collapsed to "out of range" for any peaceful target the commit
    -- path would actually allow.
    if not actor:CanRangeStrikeAt(targetX, targetY, false, true) then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE")
    end
    return UnitSpeech.rangedPreview(actor, defender, targetPlot)
end

-- Plot defender for combat preview / commit. Wraps the engine's
-- getBestDefender (CvPlot.cpp:2627) -- the same pick the engine uses to
-- resolve combat -- with the filters the target-mode UI needs.
--
-- bTestAtWar=true mirrors the engine's airStrikeTarget at
-- CvUnit.cpp:20242. The other engine getBestDefender flag,
-- bTestPotentialEnemy, looks like the right way to also include peaceful
-- rivals but is dead code: it bottoms out in a Firaxis stub at
-- CvGameCoreUtils.cpp:157 (`bool isPotentialEnemy(TeamTypes, TeamTypes)`)
-- that always returns false, so passing 1 makes getBestDefender drop every
-- defender. Community Patch confirmed this is unsalvageable -- they
-- removed every reference to isPotentialEnemy from their engine. We
-- handle the peaceful-rival ranged case below with a manual scan.
--
-- bNoncombatAllowed: for range previews, civilians are valid strike
-- targets; for melee previews, melee-into-civilian is a capture, not
-- combat, so the civilian isn't a defender.
--
-- Passing the actor as pAttacker improves the air-strike damage-cap pick
-- when the attacker is an air unit. NO_PLAYER (-1) leaves the unit-owner
-- filter off so any non-allied unit on the plot is considered.
local function defenderAt(plot, ranged, actor)
    if plot == nil then
        return nil
    end
    local activePlayer = Game.GetActivePlayer()
    local defender = plot:GetBestDefender(-1, activePlayer, actor, 1, 0, 0, ranged and 1 or 0)
    if defender ~= nil then
        return defender
    end
    -- Peaceful-rival fallback for ranged: a strike on a not-yet-at-war
    -- rival is legal when GetDeclareWarRangeStrike returns a team; the
    -- engine queues BUTTONPOPUP_DECLAREWARRANGESTRIKE at commit and
    -- GenericPopupAccess speaks the confirmation. Find a defender on that
    -- team manually since the at-war filter rejects them. Melee / move
    -- modes skip this: move-into-peaceful-rival routes through
    -- DECLAREWARMOVE and the post-war move resolves separately, not as
    -- preview-time combat.
    if ranged then
        local rivalTeam = actor:GetDeclareWarRangeStrike(plot)
        if rivalTeam ~= -1 then
            for i = 0, plot:GetNumUnits() - 1 do
                local u = plot:GetUnit(i)
                if u ~= nil and u ~= actor and u:GetTeam() == rivalTeam and u:IsCanDefend() then
                    return u
                end
            end
        end
    end
    return nil
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

local legalityPreview = PlotComposers.legalityPreview

-- Air sweep has no Can*At; the engine accepts any plot in air range and
-- picks an interceptor at random at commit time. Best signal we can give
-- is "how many interceptors are visible covering this tile" -- 0 means
-- the sweep will whiff (no one to clear), N>0 names the threat density.
local function airSweepPreview(actor, plot)
    local interceptors = actor:GetInterceptorCount(plot, nil, true, true)
    local parts = {}
    if interceptors > 0 then
        parts[#parts + 1] =
            Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS", interceptors, interceptors)
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
    local isDebug = Game.IsDebugMode()
    if not isDebug and not targetPlot:IsRevealed(team, isDebug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    -- Engine's CvUnit::GetBestBuildRoute (CvUnit.cpp:18793) picks the
    -- highest-Routes.Value build the worker can build on the given plot
    -- given the player's tech. Asking against the worker's current plot
    -- gives the route the engine will queue along the path's land tiles.
    local routeId, buildId = actor:GetBestBuildRoute(fromPlot)
    if buildId < 0 or routeId < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_NO_BUILD")
    end
    local routeRow = GameInfo.Routes[routeId]
    local routeValue = (routeRow ~= nil and routeRow.Value) or 0
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
        return Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_ALREADY_DONE", tileCount, tileCount)
    end
    local tilesClause = Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TILES_CLAUSE", tileCount, tileCount)
    local turnsClause = Text.formatPlural("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE_TURNS_CLAUSE", buildTurns, buildTurns)
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ROUTE", tilesClause, turnsClause)
end

-- Range / melee preview that prefers a unit garrison over the city
-- itself. EnemyUnitPanel does the same: a defended city's combat goes
-- through the garrison's stats, undefended cities use city stats. Returns
-- nil if the plot has no enemy combat target (caller speaks EMPTY).
local function combatPreviewAt(actor, plot, tx, ty, ranged)
    local defenderUnit = defenderAt(plot, ranged, actor)
    if defenderUnit ~= nil then
        if ranged then
            return rangedPreview(actor, defenderUnit, plot, tx, ty)
        end
        return UnitSpeech.meleePreview(actor, defenderUnit, plot)
    end
    local defenderCity = UnitControl.enemyCityAt(plot)
    if defenderCity ~= nil then
        if ranged then
            return UnitSpeech.cityRangedPreview(actor, defenderCity, plot)
        end
        return UnitSpeech.cityMeleePreview(actor, defenderCity, plot)
    end
    return nil
end

-- Path-after-move suffix for the combat preview when a melee target is
-- reachable but not adjacent. The path's last node is the enemy tile;
-- the second-to-last is the tile the unit attacks from. Truncate the
-- path to (start through attack-from) and run it through the existing
-- direction-step formatter, then format with the new attack-after-move
-- key. Path length 2 (adjacent attack) yields a single-node truncated
-- path, stepListFromPath returns "", and the caller skips appending,
-- preserving the unchanged adjacent combat readout. MP cost is omitted
-- on purpose: the engine consumes all remaining MP on attack and
-- promotion bonuses can grant extra attacks, so any predicted MP-after-
-- attack number would mislead.
local function formatAttackAfterMove(path)
    if path == nil or #path < 3 then
        return ""
    end
    local truncated = {}
    for i = 1, #path - 1 do
        truncated[i] = path[i]
    end
    local steps = HexGeom.stepListFromPath(truncated)
    if steps == "" then
        return ""
    end
    local turns = path[#path].turn
    if turns <= 1 then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_THIS_TURN", steps)
    end
    return Text.formatPlural(
        "TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_AFTER_MOVE_MULTI_TURN",
        turns,
        turns,
        steps
    )
end

-- Combined move-mode preview + latch driver. Returns (text, commitPlot).
-- text: speech to read aloud.
-- commitPlot: when non-nil, signals that this commit needs a follow-up
--   confirmation; the caller arms self._pendingFallback with this plot
--   so the next Enter on the same cursor commits MOVE_TO commitPlot.
--
-- Two latch-arming cases collapsed into one return:
--   - Path failure (stacking / enemy / unreachable): commitPlot is the
--     closest reachable tile from the diagnostic, when it differs from
--     the unit's own plot.
--   - Combat-causing strict success (move-into at-war defender or city):
--     commitPlot is the cursor plot itself; second-Enter commits MOVE_TO
--     target which the engine resolves as MoveOrAttack.
--
-- declareWar success returns commitPlot=nil. The engine pops a war-
-- confirm popup at commit time and that popup is the safety net, so a
-- second-press confirmation on top would be redundant.
--
-- preflightAttackTarget short-circuits the adjacent-but-can't-attack
-- cases (naval vs land, city-attack-only) before discriminativePath
-- runs, so the user hears a unit-attribute reason rather than a generic
-- pathfinding failure.
local function moveModePreview(actor, plot)
    local fromPlot = actor:GetPlot()
    if fromPlot:GetPlotIndex() == plot:GetPlotIndex() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY"), nil
    end
    local hasEnemy = defenderAt(plot, false, actor) ~= nil or UnitControl.enemyCityAt(plot) ~= nil
    local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), plot:GetX(), plot:GetY())
    if hasEnemy and dist == 1 then
        local targetReason = UnitControl.preflightAttackTarget(actor, plot)
        if targetReason ~= nil then
            return targetReason, nil
        end
    end

    local diag = PathDiagnostic.discriminativePath(actor, plot)

    if diag.ok ~= "strict" and diag.ok ~= "declareWar" then
        local text = PathDiagnostic.formatFailure(diag, plot:GetX(), plot:GetY())
        local commitPlot = nil
        if diag.closest ~= nil then
            local cp = Map.GetPlot(diag.closest.x, diag.closest.y)
            if cp ~= nil and cp:GetPlotIndex() ~= fromPlot:GetPlotIndex() then
                commitPlot = cp
            end
        end
        return text, commitPlot
    end

    if diag.ok == "declareWar" then
        return PathDiagnostic.formatFailure(diag, plot:GetX(), plot:GetY()), nil
    end

    if hasEnemy then
        local text = combatPreviewAt(actor, plot, plot:GetX(), plot:GetY(), false)
        if text == nil or text == "" then
            text = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        end
        local path = actor:GetPath()
        local suffix = formatAttackAfterMove(path)
        if suffix ~= "" then
            text = text .. ", " .. suffix
        end
        return text, plot
    end

    -- Reachable, no enemy. Delegate to movePathPreview for full path
    -- formatting (MP, fog, embark hints). It re-runs discriminativePath
    -- internally; one redundant GeneratePath call, no correctness issue.
    return movePathPreview(actor, plot), nil
end

local function buildPreview(self)
    local plot, tx, ty = cursorPlot()
    if plot == nil then
        return "", nil
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
        -- Match the gate order of directMove and commitFailureReason:
        -- preflightAttack first (unit-level reasons hand the user a more
        -- actionable message, e.g. "ranged unit, use ranged attack" wins
        -- over the target-level fallback), preflightAttackTarget after.
        local attackReason = UnitControl.preflightAttack(actor)
        if attackReason ~= nil then
            parts[#parts + 1] = attackReason
        else
            local targetReason = UnitControl.preflightAttackTarget(actor, plot)
            if targetReason ~= nil then
                parts[#parts + 1] = targetReason
            else
                local text = combatPreviewAt(actor, plot, tx, ty, false)
                if text == nil or text == "" then
                    parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
                else
                    parts[#parts + 1] = text
                end
            end
        end
    elseif isMoveMode(mode) then
        -- Move-mode preview is bundled with the latch decision (combat
        -- vs path-failure both arm the latch differently). moveModePreview
        -- handles the combined logic and returns (text, commitPlot); the
        -- early return propagates commitPlot up to the caller.
        return moveModePreview(actor, plot)
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
    return table.concat(parts, ", "), nil
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
-- Combat commits skip move-pending registration. The engine fork's
-- CivVAccessCombatResolved hook fires from CvUnitCombat::ResolveCombat
-- and UnitControl.onCombatResolved speaks the result; layering a move-
-- pending announcement on top would double-speak when the attacker
-- advances onto the defender's plot after a melee kill. Move-into-enemy
-- counts as combat only when the unit is adjacent on commit; further
-- away the engine queues a multi-turn move and combat happens on a
-- later turn (the hook will fire then for whichever turn it resolves).
local function willCauseCombat(actor, plot, mode)
    if isMeleeAttackMode(mode) or isRangeAttackMode(mode) then
        return true
    end
    if isMoveMode(mode) then
        if UnitControl.enemyAt(plot) ~= nil or UnitControl.enemyCityAt(plot) ~= nil then
            local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), plot:GetX(), plot:GetY())
            return dist == 1
        end
    end
    return false
end

-- Per-mode commit-time precheck. Returns:
--   nil   -- mode recognized + gate passed -> push the mission
--   table -- mode recognized + gate failed -> { reason = TXT, closestPlot? }
--           closestPlot, when set, is the fallback target the latch in
--           commitAtCursor uses on a follow-up Enter (move mode only).
--   false -- mode unrecognized -> caller falls back to UI.CanDoInterface
--           Mode as the engine's safety net
--
-- A bare UI.CanDoInterfaceMode gate would return a single generic "action
-- failed" for every reason; this returns the specific TXT_KEY for the
-- particular gate that tripped. CanDoInterfaceMode also returns false
-- for 0-MP MOVE_TO commits the engine would happily queue for next turn,
-- so move mode skips this function entirely and runs through
-- moveModePreview / discriminativePath instead, which doesn't gate on MP.
local function commitFailureReason(actor, mode, plot, tx, ty)
    -- Move-mode commits do not flow through this function; commitAtCursor
    -- calls moveModePreview directly because the latch state machine is
    -- specific to move mode (combat-causing and path-failure cases both
    -- arm the latch differently).
    if isRouteMode(mode) then
        local path = Game.GetBuildRoutePath(actor:GetX(), actor:GetY(), tx, ty, actor:GetOwner())
        if #path == 0 then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE") }
        end
        return nil
    end
    if isMeleeAttackMode(mode) then
        local r = UnitControl.preflightAttack(actor)
        if r ~= nil then
            return { reason = r }
        end
        local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), tx, ty)
        if dist ~= 1 then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NOT_ADJACENT") }
        end
        if defenderAt(plot, false, actor) == nil and UnitControl.enemyCityAt(plot) == nil then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY") }
        end
        local targetReason = UnitControl.preflightAttackTarget(actor, plot)
        if targetReason ~= nil then
            return { reason = targetReason }
        end
        return nil
    end
    if isRangeAttackMode(mode) then
        if not actor:CanRangeStrike() then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK") }
        end
        if actor:MovesLeft() <= 0 then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NO_MOVES") }
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
            if defenderAt(plot, true, actor) == nil and UnitControl.enemyCityAt(plot) == nil then
                return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY") }
            end
            local dist = Map.PlotDistance(actor:GetX(), actor:GetY(), tx, ty)
            if dist > actor:Range() then
                return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE") }
            end
            local ignoresLoS = actor:GetDomainType() == DomainTypes.DOMAIN_AIR or actor:IsRangeAttackIgnoreLOS()
            if not ignoresLoS and not actor:GetPlot():HasLineOfSight(plot, actor:GetTeam()) then
                return { reason = Text.key("TXT_KEY_CIVVACCESS_TARGET_UNSEEN") }
            end
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED") }
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_PARADROP then
        if not actor:CanParadropAt(actor:GetPlot(), tx, ty) then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_PARADROP_ILLEGAL") }
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_AIRLIFT then
        if not actor:CanAirliftAt(actor:GetPlot(), tx, ty) then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_AIRLIFT_ILLEGAL") }
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_REBASE then
        if not actor:CanRebaseAt(actor:GetPlot(), tx, ty) then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_REBASE_ILLEGAL") }
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_EMBARK then
        if not actor:CanEmbarkOnto(actor:GetPlot(), plot) then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMBARK_ILLEGAL") }
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_DISEMBARK then
        if not actor:CanDisembarkOnto(plot) then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_DISEMBARK_ILLEGAL") }
        end
        return nil
    end
    if mode == InterfaceModeTypes.INTERFACEMODE_NUKE then
        if not actor:CanNukeAt(tx, ty) then
            return { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_NUKE_ILLEGAL") }
        end
        return nil
    end
    return false
end

-- Push the configured mission against `plot`. queued=true sends a bShift
-- append (with the empty-queue quirk noted below) and skips pending
-- registration; queued=false fires immediately and registers a move-
-- resolution snapshot, except on combat-causing commits where the engine
-- fork's CivVAccessCombatResolved hook owns the announcement. Used for
-- every non-melee commit (including the latch fallback to closest-
-- reachable) so all of them share the same pending-snapshot rules.
local function pushMission(self, mission, plot, mode, queued)
    local tx, ty = plot:GetX(), plot:GetY()
    local bShift = false
    if queued then
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
        bShift = #self._actor:GetMissionQueue() > 0
    else
        if not willCauseCombat(self._actor, plot, mode) then
            UnitControl.registerPending(self._actor, tx, ty)
        end
    end
    Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, mission, tx, ty, 0, false, bShift)
end

-- queued=true is shift+enter: append the mission to the unit's queue
-- via bShift on the engine's PUSH_MISSION net message (matches base
-- WorldView.lua's mouse-shift-click path), skip pending registration
-- (the move won't necessarily resolve this turn, so the SerialEventUnit*
-- "moved / stopped short" announcement isn't ours to make), and stay in
-- target mode so the user can chain more shift+enters to add legs. Plain
-- enter (queued=false) keeps the existing replace-and-resolve flow.
--
-- queued mode rejects melee attacks: combat doesn't queue meaningfully
-- (the engine still resolves on the following turn but the user has no
-- way to inspect it before then), and bShift on a non-MOVE mission is
-- a base-engine pass-through with no on-screen path line for sighted
-- players either.
--
-- Move-mode latch: when moveModePreview returns a non-nil commitPlot,
-- the commit is "non-trivial" -- either a path failure with a usable
-- closest-reachable fallback, or a strict success that would resolve as
-- combat at the destination. The first Space or Enter on such a plot
-- speaks the diagnostic / preview and arms self._pendingFallback. A
-- second Enter (or Shift+Enter) on the same plot fires the latch and
-- commits MOVE_TO commitPlot, which is the closest plot for failures
-- and the cursor plot itself for combat (the engine resolves MOVE_TO an
-- enemy hex as MoveOrAttack). Cursor moves invalidate the latch
-- implicitly via the targetPlotIndex check.
local function commitAtCursor(self, queued)
    local plot, tx, ty = cursorPlot()
    if plot == nil then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
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
    local plotIndex = plot:GetPlotIndex()

    -- Latch fast-path. Armed by a prior Space or Enter on this same plot
    -- whose moveModePreview returned a non-nil commitPlot. Second press
    -- commits MOVE_TO commitPlot. The commit plot is reachable by
    -- construction (strict succeeded against it during binary search,
    -- came from m_pClosed, or is the cursor target itself for combat),
    -- so we skip re-running diagnostics and CanDoInterfaceMode.
    if self._pendingFallback ~= nil and self._pendingFallback.targetPlotIndex == plotIndex then
        local cp = self._pendingFallback.commitPlot
        self._pendingFallback = nil
        pushMission(self, mission, cp, mode, queued)
        if queued then
            -- Stay in target mode after a queued latch fire so the user
            -- can chain more Shift+Enter legs, matching the non-latch
            -- queued path below.
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"))
            return
        end
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end

    -- Queued melee rejection: combat doesn't queue meaningfully.
    if queued and isMeleeAttackMode(mode) then
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_NOT_QUEUEABLE"))
        return
    end

    -- Move mode runs through the combined preview-and-latch driver. A
    -- non-nil commitPlot means we speak the diagnostic / preview and
    -- stay in target mode with the latch armed; a nil commitPlot means
    -- the commit is benign (regular reachable move, or declareWar where
    -- the engine's war-confirm popup is the safety net) and proceeds to
    -- mission dispatch.
    if isMoveMode(mode) then
        local text, commitPlot = moveModePreview(self._actor, plot)
        if commitPlot ~= nil then
            SpeechPipeline.speakInterrupt(text)
            self._pendingFallback = {
                targetPlotIndex = plotIndex,
                commitPlot = commitPlot,
            }
            return
        end
        -- A latch armed for this plot from a prior Space or Enter is now
        -- stale (the diagnostic returned no commitPlot this time). Clear
        -- it so a subsequent Enter doesn't fire an outdated fallback.
        if self._pendingFallback ~= nil and self._pendingFallback.targetPlotIndex == plotIndex then
            self._pendingFallback = nil
        end
        if queued then
            pushMission(self, mission, plot, mode, true)
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"))
            return
        end
        pushMission(self, mission, plot, mode, false)
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end

    -- Non-move modes. Per-mode reason check returns nil to allow commit,
    -- a {reason} table to speak and abort, or false for "unrecognized
    -- mode -- defer to the engine gate." Queued non-move commits skip
    -- the reason check so they bypass CanDoInterfaceMode (the engine
    -- accepts queued missions regardless of MP state).
    local result
    if not queued then
        result = commitFailureReason(self._actor, mode, plot, tx, ty)
        if result == false then
            if not UI.CanDoInterfaceMode(mode) then
                result = { reason = Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED") }
            else
                result = nil
            end
        end
    end

    if result ~= nil then
        SpeechPipeline.speakInterrupt(result.reason)
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end

    self._pendingFallback = nil
    if queued then
        pushMission(self, mission, plot, mode, true)
        SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_QUEUED"))
        return
    end
    if isMeleeAttackMode(mode) then
        -- Match base UI's AttackIntoTile (InGame.lua); SelectionListMove
        -- is the engine-blessed melee-attack commit path against units
        -- AND cities.
        Game.SelectionListMove(plot, false, false, false)
    else
        pushMission(self, mission, plot, mode, false)
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
        -- { targetPlotIndex, commitPlot } when a Space or Enter on
        -- `targetPlotIndex` armed the two-press confirm latch. commitPlot
        -- is what the next Enter / Shift+Enter on the same plot commits
        -- MOVE_TO: the closest reachable plot for path failures, or the
        -- cursor target itself for combat-causing strict success.
        -- Cleared by successful commits, by handler pop, and by a fresh
        -- Space / Enter that returns no commitPlot for the same plot.
        -- See the block comment on commitAtCursor for the state machine.
        _pendingFallback = nil,
    }
    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            local plot = cursorPlot()
            local plotIndex = plot ~= nil and plot:GetPlotIndex() or nil
            local text, commitPlot = buildPreview(self)
            speakInterrupt(text)
            if commitPlot ~= nil and plotIndex ~= nil then
                self._pendingFallback = {
                    targetPlotIndex = plotIndex,
                    commitPlot = commitPlot,
                }
            elseif plotIndex ~= nil
                and self._pendingFallback ~= nil
                and self._pendingFallback.targetPlotIndex == plotIndex
            then
                -- Latch was armed for this plot from a prior arm but
                -- the current preview produces no commitPlot. State
                -- changed; drop the stale latch.
                self._pendingFallback = nil
            end
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
    }
    -- Block Baseline's Alt+QAZEDC direct-move and Alt+letter quick-actions
    -- (fortify / heal / pillage / wake / etc.) while the engine is mid-target
    -- mode; without the blocks a stray Alt+key commits against the actor and
    -- fights the picker the user is in.
    HandlerStack.appendAltBlocks(self.bindings, { directMove = true, quickActions = true })
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

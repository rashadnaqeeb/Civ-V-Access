-- Combat-resolution half of the unit-control split. Owns the two-tap
-- melee-attack confirm state (consumed by Movement's directMove), the
-- preflight-attack gates that compose combat-preview text, and every
-- engine-event listener for combat / nuke / city-capture announcements.
-- No bindings of its own.
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
-- Nuclear strikes are accumulated between NukeStart and NukeEnd so a
-- single composed speech line covers the whole strike rather than per-
-- entity speech (verbose) or just the header (loses info). Names are
-- resolved at hook-fire time because destroyed cities lose their handle
-- when the engine's pkCity->kill() runs after NukeCityAffected.

UnitControlCombat = {}

-- ===== Combat-confirm state (consumed by Movement's directMove) =====
-- Module-local rather than civvaccess_shared because a Context re-entry
-- should drop any in-flight confirm window.
--
-- Keyed on the target plot's index, mirroring UnitTargetMode's
-- _pendingFallback. State changes that should invalidate the latch
-- (selection cycle, the actor moving, a different direction pressed)
-- naturally compute a different target plot index, so the consume check
-- silently misses without explicit clear hooks.
local _combatConfirm = { targetPlotIndex = nil }

function UnitControlCombat.clearCombatConfirm()
    _combatConfirm.targetPlotIndex = nil
end

-- Consume the confirm latch when `target` (a plot) matches the armed
-- target plot. Returns true and clears on match; returns false (without
-- arming) on miss. Pair with armCombatConfirm to arm on the first tap.
function UnitControlCombat.consumeCombatConfirm(target)
    if target == nil then
        return false
    end
    if _combatConfirm.targetPlotIndex == target:GetPlotIndex() then
        UnitControlCombat.clearCombatConfirm()
        return true
    end
    return false
end

function UnitControlCombat.armCombatConfirm(target)
    _combatConfirm.targetPlotIndex = target:GetPlotIndex()
end

local speakQueued = SpeechPipeline.speakQueued

-- ===== Preflight =====
-- Precheck: would a melee attack from this unit be allowed at all? Order
-- of checks is most-actionable first so the user hears the suggestion
-- closest to their next keystroke. IsRanged / DOMAIN_AIR get their own
-- messages because the right action exists (Alt+R) -- the user just
-- picked the wrong key. IsCanAttack catches civilians and units the
-- engine has flagged as non-attackers. MovesLeft is last because it's
-- transient (next turn fixes it). Exported so UnitTargetMode's commit
-- path can reuse the same gate when the user lands a melee attack
-- through the menu rather than an Alt-direction key.
function UnitControlCombat.preflightAttack(unit)
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
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_OUT_OF_ATTACKS")
    end
    return nil
end

-- Target-specific attack gate. preflightAttack only covers unit-level
-- attributes (ranged / air / can-attack / has-moves); this catches the
-- engine refusals that depend on the actor / target / terrain triple --
-- the cases where preflight passes but a melee preview would predict
-- combat the engine then silently refuses. Currently observed:
--
--   - Naval melee against a land tile with a land defender. Engine
--     rejects in canMoveInto via canEnterTerrain (CvUnit.cpp:2750);
--     naval melee can still capture coastal cities, so we exclude IsCity
--     from the naval-vs-land message.
--   - City-attack-only units (Battering Ram, future siege variants with
--     PROMOTION_ONLY_ATTACKS_CITIES) against any non-city defender.
--     CvUnit.cpp:2542 short-circuits with
--     `IsCityAttackOnly && !plot.isEnemyCity && plot.getBestDefender`.
--   - Defender already past the actor's combat limit (CvUnit.cpp:2654).
--   - ONLY_DEFENSIVE units advancing into an enemy city (CvUnit.cpp:2559).
--
-- CanMoveOrAttackInto(target, 1, 1) tests both move-without-attack and
-- attack (engine code at CvUnit.cpp:2760). Callers reach this gate after
-- they have already established a defender on the plot, so the move
-- branch is gated by the visibleEnemyUnit check (CvUnit.cpp:2717) and a
-- true result here can only come from the attack branch. The fork's
-- CvLuaUnit.cpp lCanMoveOrAttackInto (line 791) returns the actual
-- result; vanilla discards it and would always read false.
--
-- Drill order is most-specific first so the user hears the
-- distinguishing fact (this unit only attacks cities; this is a naval
-- domain mismatch) before the generic fallback.
function UnitControlCombat.preflightAttackTarget(unit, target)
    if unit:CanMoveOrAttackInto(target, 1, 1) then
        return nil
    end
    if unit:IsCityAttackOnly() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CITY_ATTACK_ONLY")
    end
    if unit:GetDomainType() == DomainTypes.DOMAIN_SEA and not target:IsWater() and not target:IsCity() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_NAVAL_VS_LAND")
    end
    return Text.key("TXT_KEY_CIVVACCESS_UNIT_PRECHECK_CANT_ATTACK_TARGET")
end

-- ===== Combat-resolved listener =====
-- Engine fork fires GameEvents.CivVAccessCombatResolved from
-- CvUnitCombat::ResolveCombat (post-resolve, before the dispatcher
-- returns) for every unit-attacker melee / ranged / air-sweep combat
-- against units and cities, regardless of Quick Combat. Sole speech
-- path for unit-initiated combat results: per-side damage-this-combat,
-- final damage, max HP. Defender is either a unit (defenderUnit > -1)
-- or a city (defenderCity > -1, defenderUnit = -1).
--
-- Interceptor fields populate only on landed air-strike intercepts
-- (engine-side gate; see CvUnitCombat.cpp CIVVACCESS hook). Failed /
-- evaded intercepts arrive as -1 / -1 / 0 sentinels and the speech
-- formatter omits the intercept clause -- matching base game's UI,
-- which announces interceptors only on landed hits.
--
-- combatKind distinguishes air-sweep paths from normal combat:
--   0 = normal melee / ranged / air strike (no prefix)
--   1 = air sweep against ground AA (one-sided): "interception" prefix
--   2 = air sweep against an air interceptor (dogfight): "dogfight" prefix
--
-- plotVisibleToActiveTeam / attackerKnown / defenderKnown drive the
-- AI-vs-AI parity gate. Active-player-involved combats ignore the
-- known flags -- attacking reveals identity (base game names attackers
-- in defender-side messages, even submarines that ambush). For
-- AI-vs-AI on a plot the active player can see, an invisible side
-- substitutes "unknown" in the readout, matching the sighted view of
-- "an unseen hit landing on a visible target". Both sides invisible
-- on a visible plot stays silent (no actor to name).
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
    defenderMaxHP,
    interceptorPlayer,
    interceptorUnit,
    interceptorDamage,
    combatKind,
    plotVisibleToActiveTeam,
    attackerKnown,
    defenderKnown,
    attackerCity,
    defenderCityCaptured,
    plotX,
    plotY
)
    local activePlayer = Game.GetActivePlayer()
    local activeInvolved = (attackerPlayer == activePlayer or defenderPlayer == activePlayer)
    if not activeInvolved then
        if plotVisibleToActiveTeam ~= 1 then
            return
        end
        if attackerKnown ~= 1 and defenderKnown ~= 1 then
            return
        end
    end
    local resolvedAttackerName
    if not activeInvolved and attackerKnown ~= 1 then
        resolvedAttackerName = Text.key("TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT")
    elseif attackerCity ~= -1 then
        resolvedAttackerName = UnitSpeech.cityCombatantName(attackerPlayer, attackerCity)
    else
        resolvedAttackerName = UnitSpeech.combatantName(attackerPlayer, attackerUnit)
    end
    if resolvedAttackerName == "" then
        Log.warn(
            "onCombatResolved: attacker name empty for player="
                .. tostring(attackerPlayer)
                .. " unit="
                .. tostring(attackerUnit)
                .. " city="
                .. tostring(attackerCity)
        )
        return
    end
    local attackerName = resolvedAttackerName
    local defenderName
    if not activeInvolved and defenderKnown ~= 1 then
        defenderName = Text.key("TXT_KEY_CIVVACCESS_COMBAT_UNKNOWN_COMBATANT")
    elseif defenderUnit ~= -1 then
        defenderName = UnitSpeech.combatantName(defenderPlayer, defenderUnit)
    elseif defenderCityCaptured == 1 then
        -- City was captured this combat -- the original CvCity object was
        -- freed by acquireCity inside ResolveCityMeleeCombat, so the pre-
        -- capture (owner, ID) lookup against Players[...]:GetCityByID is
        -- guaranteed to miss. The post-capture city on the same plot
        -- reads back the same name (cities retain their name on capture),
        -- so resolve the name via Map.GetPlot.
        local plot = Map.GetPlot(plotX, plotY)
        local capturedCity = plot and plot:GetPlotCity()
        defenderName = capturedCity and capturedCity:GetName() or ""
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
    local interceptorName
    if interceptorUnit ~= -1 and interceptorDamage > 0 then
        interceptorName = UnitSpeech.combatantName(interceptorPlayer, interceptorUnit)
        if interceptorName == "" then
            interceptorName = nil
        end
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
        interceptorName = interceptorName,
        combatKind = combatKind,
        defenderCaptured = defenderCityCaptured == 1,
    })
    -- Player-initiated combat always speaks: it's direct feedback for the
    -- key the user just pressed. Combat the active player didn't initiate
    -- (AI attacking the player, or AI vs AI on a visible plot) is gated
    -- behind the aiCombatAnnounce setting; when off it still records to
    -- the F7 Combat Log so the user can review what happened during the
    -- AI turn.
    if attackerPlayer == activePlayer or civvaccess_shared.aiCombatAnnounce then
        speakQueued(text)
    end
    CombatLog.recordCombat(text)
    MessageBuffer.append(text, "combat")
end

-- GameEvents.CivVAccessAirSweepNoTarget listener. Engine fork fires this
-- from CvUnitCombat::AttackAirSweep when GetBestInterceptor returns NULL
-- (no interceptor in range / with charges left at the target plot). No
-- combat resolves and CombatResolved doesn't fire, so without this hook
-- the user's sweep would be a silent no-op. Engine-side AddMessage that
-- lands the same info in the on-screen message strip for sighted players
-- has no Lua subscription hook.
local function onAirSweepNoTarget(attackerPlayer, _attackerUnit)
    if attackerPlayer ~= Game.GetActivePlayer() then
        return
    end
    local text = Text.key("TXT_KEY_CIVVACCESS_AIR_SWEEP_NO_TARGET")
    speakQueued(text)
    MessageBuffer.append(text, "combat")
end

-- ===== Nuclear strike accumulator =====
-- The engine fork fires four hooks for each nuclear strike, in order:
-- NukeStart, then a stream of NukeUnitAffected / NukeCityAffected per
-- damaged entity, then NukeEnd. We accumulate between Start and End so a
-- single composed speech line covers the whole strike rather than
-- per-entity speech (verbose) or just the header (loses info). Names
-- are resolved at hook-fire time because destroyed cities lose their
-- handle when the engine's pkCity->kill() runs after NukeCityAffected.
-- Module-local rather than civvaccess_shared so a Context re-entry
-- drops any in-flight buffer (a half-flushed buffer wouldn't replay
-- cleanly on the next NukeEnd).
local _nukeBuffer = nil

-- City names stand alone in nuke speech without a civ-adjective prefix:
-- a city's name uniquely identifies its civ for the user, so "Babylon"
-- already communicates "Babylonian Babylon" without doubling the
-- identity word. Same reasoning we landed on earlier for the regular
-- combat readout's city-defender path -- units need the adjective
-- because "Warrior" collides across civs, cities don't.
local function nukeCityDisplayName(playerId, cityId)
    local owner = Players[playerId]
    if owner == nil then
        return ""
    end
    local city = owner:GetCityByID(cityId)
    if city == nil then
        return ""
    end
    return city:GetName()
end

local function onNukeStart(
    attackerPlayer,
    _attackerUnit,
    _targetX,
    _targetY,
    _nuclearLevel,
    targetCityPlayer,
    targetCityId
)
    local launcher = Players[attackerPlayer]
    -- GetCivilizationAdjective() returns the resolved adjective ("Roman");
    -- GetCivilizationAdjectiveKey() returns a TXT_KEY string that
    -- CivVAccess_Text.substitute would speak verbatim because mod-authored
    -- format keys (CIVVACCESS-prefixed) don't recursively resolve nested
    -- TXT_KEY args -- only base-game keys routed through Locale.Convert
    -- TextKey do, which is why TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV in
    -- unitName() can take *Key args while our TXT_KEY_CIVVACCESS_NUKE_HEADER
    -- here cannot.
    local launcherAdj = launcher and launcher:GetCivilizationAdjective() or ""
    local targetName
    if targetCityId ~= -1 then
        targetName = nukeCityDisplayName(targetCityPlayer, targetCityId)
        if targetName == "" then
            targetName = nil
        end
    end
    _nukeBuffer = {
        attackerPlayer = attackerPlayer,
        launcherCivAdj = launcherAdj,
        targetName = targetName,
        cities = {},
        units = {},
    }
end

local function onNukeUnitAffected(defenderPlayer, defenderUnit, damageDelta, finalDamage, maxHP)
    if _nukeBuffer == nil then
        return
    end
    local displayName = UnitSpeech.combatantName(defenderPlayer, defenderUnit)
    if displayName == "" then
        return
    end
    table.insert(_nukeBuffer.units, {
        defenderPlayer = defenderPlayer,
        displayName = displayName,
        hpDelta = damageDelta,
        killed = finalDamage >= maxHP,
    })
end

local function onNukeCityAffected(
    defenderPlayer,
    defenderCity,
    damageDelta,
    _finalDamage,
    _maxHP,
    popDelta,
    wasDestroyed
)
    if _nukeBuffer == nil then
        return
    end
    local displayName = nukeCityDisplayName(defenderPlayer, defenderCity)
    if displayName == "" then
        return
    end
    table.insert(_nukeBuffer.cities, {
        defenderPlayer = defenderPlayer,
        displayName = displayName,
        hpDelta = damageDelta,
        popDelta = popDelta,
        wasDestroyed = wasDestroyed == 1,
    })
end

local function nukeBufferInvolvesActivePlayer(buf, activePlayer)
    if buf.attackerPlayer == activePlayer then
        return true
    end
    for _, e in ipairs(buf.units) do
        if e.defenderPlayer == activePlayer then
            return true
        end
    end
    for _, e in ipairs(buf.cities) do
        if e.defenderPlayer == activePlayer then
            return true
        end
    end
    return false
end

local function onNukeEnd(_attackerPlayer)
    if _nukeBuffer == nil then
        return
    end
    local buf = _nukeBuffer
    _nukeBuffer = nil
    if not nukeBufferInvolvesActivePlayer(buf, Game.GetActivePlayer()) then
        return
    end
    local text = UnitSpeech.nuclearStrikeResult(buf)
    speakQueued(text)
    MessageBuffer.append(text, "combat")
end

-- Empty city captures don't fire any combat resolution -- the unit just walks in.
-- SerialEventCityCaptured fires once per capture with (hexPos, oldOwner,
-- cityId, newOwner). Speak only when the active player is involved (we
-- captured one or one of ours fell). The engine's hex position is a
-- HexPos table; pulling x/y is enough to look up the city plot.
local function onCityCaptured(_hexPos, oldOwner, cityId, newOwner)
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
    local text
    if newOwner == activePlayer then
        text = Text.format("TXT_KEY_CIVVACCESS_CITY_CAPTURED_BY_US", cityName)
    else
        text = Text.format("TXT_KEY_CIVVACCESS_CITY_LOST", cityName)
    end
    speakQueued(text)
    MessageBuffer.append(text, "combat")
end

-- Registers fresh listeners on every call (per CLAUDE.md's no-install-
-- once-guards rule for load-game-from-game survival).
function UnitControlCombat.installListeners()
    Log.installEvent(Events, "SerialEventCityCaptured", onCityCaptured, "UnitControlCombat")
    -- Engine-fork hook fired from CvUnitCombat::ResolveCombat. Sole
    -- combat-speech path; the engine's Events.EndCombatSim and
    -- SerialEventCitySetDamage are not subscribed because the hook
    -- already covers every case they would have announced.
    Log.installEvent(GameEvents, "CivVAccessCombatResolved", onCombatResolved, "UnitControlCombat")
    -- Engine-fork hook fired from CvUnitCombat::AttackAirSweep when no
    -- interceptor is in range. CombatResolved never fires for this case;
    -- without a dedicated signal a sweep into nothing reads as silence.
    Log.installEvent(GameEvents, "CivVAccessAirSweepNoTarget", onAirSweepNoTarget, "UnitControlCombat")
    -- Nuclear strike hook stream: Start, per-entity affected, End. The
    -- accumulator-flush model handles the variable-shape payload (a nuke
    -- can hit zero or many entities) that a single fixed-arg hook can't
    -- carry cleanly.
    Log.installEvent(GameEvents, "CivVAccessNukeStart", onNukeStart, "UnitControlCombat")
    Log.installEvent(GameEvents, "CivVAccessNukeUnitAffected", onNukeUnitAffected, "UnitControlCombat")
    Log.installEvent(GameEvents, "CivVAccessNukeCityAffected", onNukeCityAffected, "UnitControlCombat")
    Log.installEvent(GameEvents, "CivVAccessNukeEnd", onNukeEnd, "UnitControlCombat")
end

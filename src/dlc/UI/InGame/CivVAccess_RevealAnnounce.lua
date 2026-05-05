-- Speaks reveal and hide lines after a unit move (or any visibility-
-- change source) so blind players know what just appeared on or
-- disappeared from the map. The base game has no equivalent feedback:
-- sighted players see new terrain / units / cities slide into view
-- (and old ones slide back into fog) while a screen-reader user has
-- nothing to react to.
--
-- Three readouts in one flush. Reveal lists tiles that came into view
-- with their foreign-unit / foreign-city / resource payload. Hide
-- lists foreign units that left view because the active player's
-- actions retracted LOS (a unit moved away, a unit died, a city was
-- lost). Gone lists barbarian camps and ancient ruins that were on a
-- plot the active team had previously revealed but are no longer
-- there -- cleared by someone the team couldn't see at the moment
-- of clearing; the diff fires only on revisit because first-reveal
-- plots have no prior state to compare. Cities and resources are
-- excluded from the hide direction: once discovered they stay
-- revealed -- only unit positions actually become unknown again. A
-- single move can emit any subset of these three lines; reveal
-- speaks first, then hide, then gone.
--
-- Hide is computed by snapshot-diff. Once a tile turns to fog the
-- foreign units on it are unreachable through the plot, so a snapshot
-- of currently-visible foreign units is the only way to know what the
-- player just lost sight of. The snapshot is primed in installListeners
-- and rebuilt at the end of every flush. Destroyed and captured units
-- (Players[i]:GetUnitByID returns nil under the original owner) are
-- dropped: the combat readout already speaks kills, and listing a
-- killed unit as "hidden" would be misleading. Hide buckets foreign
-- owners as enemy / other to mirror the reveal payload's split.
--
-- Dual signal for reveals. The fork-added GameEvents.CivVAccessPlot-
-- Revealed (CvPlot.cpp inside the existing isRevealed != bNewValue
-- guard) fires only on first reveal of a plot for a team. Events.Hex-
-- FOWStateChanged fires on every visibility transition. We listen to
-- both: first-reveal plots get the full payload (units + cities +
-- resources); revisit plots (came back into sight on a known tile)
-- only contribute units that aren't already in _visibleUnits. The
-- resource / terrain / city weren't new on a revisit, so re-
-- announcing them every time the player's vision flickers across the
-- plot is noise; and re-announcing a known-visible unit overlaps
-- with ForeignUnitWatch's TurnStart "entered" line. Mixed ticks
-- combine: total count plus the union of payloads, with the
-- per-piece gates above applied.
--
-- Coalescing. A single move emits a burst of events from two sources
-- that don't share timing: CivVAccessPlotRevealed fires synchronously
-- from C++ during the move (via LuaSupport::CallHook inside CvPlot::
-- setRevealed), while HexFOWStateChanged is queued into the engine's
-- m_vDeferredFogPlots and dispatched on a later tick by
-- CvMap::updateDeferredFog. A flush on the next TickPump tick would
-- catch only the synchronous half and produce a separate "N tiles
-- revealed" line for each. The flush waits FLUSH_DELAY_FRAMES after
-- the first event of a burst so both halves land in the same buffer
-- and the user hears one combined announcement per move. Subsequent
-- bursts (separate moves) re-arm a fresh flush.
--
-- Visibility filter. We don't trust the fowType integer that ships in
-- HexFOWStateChanged: the shipped UI Lua (CityBannerManager, UnitFlag-
-- Manager) calls value 0 "BlackFog/invisible" but the engine's
-- FogOfWarModeTypes enum maps 0 to FOGOFWARMODE_OFF (currently visible).
-- Whichever convention is correct, plot:IsVisible(activeTeam) is the
-- ground truth at handler time, so we filter on that and ignore fowType.
--
-- Skip rules apply only to the reveal payload. Natural-wonder features,
-- goody-hut improvements, and barbarian-camp improvements are excluded
-- there -- the engine fires its own popups/notifications for those,
-- and announcing them again is double-speech. Own units, own cities,
-- and teammate units are excluded across both directions (the player
-- already knows where they are).

RevealAnnounce = {}

-- Tick budget for the burst window. Empirically a unit move's
-- synchronous CivVAccessPlotRevealed and the engine's deferred
-- HexFOWStateChanged batch land within a few frames of each other; six
-- frames matches NotificationAnnounce's burst window for the same
-- "engine tail vs. user-perceived single event" reason.
local FLUSH_DELAY_FRAMES = 6

local _firstReveals = {}
local _nowVisible = {}
local _flushTargetFrame = -1

-- Per-plot tracking for the gone-on-revisit announcement. Maps
-- plotIndex -> "camp" / "ruin" for plots whose last-known state showed
-- one; absent for everything else. Source of truth is Lua: bootstrapped
-- at installListeners by walking the revealed map (engine's
-- GetRevealedImprovementType is accurate at that moment because no
-- changeVisibilityCount has fired since the load), then maintained on
-- every flush by reading GetImprovementType for each plot in nowVisible.
-- We can't read the engine's revealed type at flush time -- CvPlot::
-- setRevealed's "if(!bTerrainOnly)" block is OUTSIDE the revealed-bit
-- transition guard, so on every revisit it synchronously runs
-- setRevealedImprovementType(eTeam, getImprovementType()) (CvPlot.cpp
-- line 8349). By the time HexFOWStateChanged dispatches to Lua, the
-- engine's revealed-type already equals the current type, so the diff
-- would always be zero.
local _campOrRuinKind = {}

local function classifyImprovementAsCampOrRuin(improvementType)
    if improvementType == nil or improvementType < 0 then
        return nil
    end
    local row = GameInfo.Improvements[improvementType]
    if row == nil then
        return nil
    end
    if row.Type == "IMPROVEMENT_BARBARIAN_CAMP" then
        return "camp"
    end
    if row.Goody then
        return "ruin"
    end
    return nil
end

-- One-time install-time walk to bootstrap the snapshot from the engine's
-- per-team revealed-improvement-type. Runs before any move has triggered
-- changeVisibilityCount in this session, so the engine's value is the
-- saved last-sighted state for each plot. Map.GetNumPlots may be missing
-- in degraded environments (test harness, pre-game contexts); guard
-- defensively so installListeners never crashes the boot path.
local function bootstrapCampOrRuinSnapshot()
    if Map == nil or Map.GetNumPlots == nil or Map.GetPlotByIndex == nil then
        return
    end
    local team = Game.GetActiveTeam()
    local n = Map.GetNumPlots()
    for i = 0, n - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil then
            local kind = classifyImprovementAsCampOrRuin(plot:GetRevealedImprovementType(team, false))
            if kind ~= nil then
                _campOrRuinKind[i] = kind
            end
        end
    end
end

-- Snapshot of foreign units the active team can see, keyed by
-- "<ownerId>:<unitId>". Primed in installListeners and rebuilt at the
-- end of every flush so the next burst's diff is against the
-- last-known-visible state. Per-entry shape:
-- { ownerId, unitId, civAdjKey, unitDescKey, bucket = "hostile" | "other" }.
local _visibleUnits = {}

local function isEnabled()
    return civvaccess_shared.revealAnnounce == true
end

local function scheduleFlush()
    if _flushTargetFrame >= 0 then
        return
    end
    _flushTargetFrame = TickPump.frame() + FLUSH_DELAY_FRAMES
    TickPump.runOnce(RevealAnnounce._maybeFlush)
end

function RevealAnnounce._maybeFlush()
    if TickPump.frame() < _flushTargetFrame then
        TickPump.runOnce(RevealAnnounce._maybeFlush)
        return
    end
    -- Clear the deadline before _flush runs so any event that lands
    -- back in the buffer during the flush gets a fresh schedule rather
    -- than being silently absorbed into a buffer with no drain queued.
    _flushTargetFrame = -1
    RevealAnnounce._flush()
end

local function recordFirstReveal(eTeam, iX, iY)
    if not isEnabled() then
        return
    end
    if eTeam ~= Game.GetActiveTeam() then
        return
    end
    local plot = Map.GetPlot(iX, iY)
    if plot == nil then
        return
    end
    _firstReveals[plot:GetPlotIndex()] = true
    scheduleFlush()
end

local function recordNowVisible(hexPos, _fowType, bWholeMap)
    if bWholeMap then
        return
    end
    if not isEnabled() then
        return
    end
    local gridX, gridY = ToGridFromHex(hexPos.x, hexPos.y)
    local plot = Map.GetPlot(gridX, gridY)
    if plot == nil then
        return
    end
    if not plot:IsVisible(Game.GetActiveTeam(), false) then
        return
    end
    _nowVisible[plot:GetPlotIndex()] = true
    scheduleFlush()
end

-- Engine fires its own popup/notification for natural wonders, goody
-- huts, and barbarian camps; suppress those here so the user doesn't
-- hear the discovery twice.
local function shouldSkipPlot(plot)
    local feat = plot:GetFeatureType()
    if feat ~= nil and feat >= 0 then
        local row = GameInfo.Features[feat]
        if row and row.NaturalWonder then
            return true
        end
    end
    local imp = plot:GetImprovementType()
    if imp ~= nil and imp >= 0 then
        local row = GameInfo.Improvements[imp]
        if row then
            if row.Goody then
                return true
            end
            if row.Type == "IMPROVEMENT_BARBARIAN_CAMP" then
                return true
            end
        end
    end
    return false
end

-- Returns "enemy" / "other" for foreign units the player should hear
-- about, nil for own / teammate units we suppress. Mirrors the bucket
-- logic in ScannerBackendUnits.ownerCategory but collapses "my" and
-- "teammate" to a single ignored bucket since this announcement is
-- about things the player just saw, not about own forces.
-- ForeignUnitSnapshot.collect already gates on the owner being alive,
-- so this only classifies live foreign players.
local function unitOwnerBucket(ownerId, activePlayerId, activeTeam)
    if ownerId == activePlayerId then
        return nil
    end
    local owner = Players[ownerId]
    if owner:IsBarbarian() then
        return "enemy"
    end
    local ownerTeam = owner:GetTeam()
    if ownerTeam == activeTeam then
        return nil
    end
    if Teams[activeTeam]:IsAtWar(ownerTeam) then
        return "enemy"
    end
    return "other"
end

local function resourceName(resourceId)
    local row = GameInfo.Resources[resourceId]
    if row == nil or row.Description == nil then
        return nil
    end
    return Text.key(row.Description)
end

local function buildVisibleForeignUnits()
    return ForeignUnitSnapshot.collect(unitOwnerBucket)
end

local formatUnitList = ForeignUnitSnapshot.formatList

function RevealAnnounce._flush()
    local ok, err = pcall(RevealAnnounce._flushBody)
    if not ok then
        Log.error("RevealAnnounce: flush failed: " .. tostring(err))
    end
end

function RevealAnnounce._flushBody()
    local firstReveals = _firstReveals
    local nowVisible = _nowVisible
    _firstReveals = {}
    _nowVisible = {}

    local activePlayerId = Game.GetActivePlayer()
    local activeTeam = Game.GetActiveTeam()

    -- "Revealed" is reserved for unexplored-to-revealed transitions
    -- (BlackFog -> ever-seen): revisits (already-revealed plots coming
    -- back into sight) contribute payload but not to the reveal count,
    -- since those tiles were revealed in prior turns. Natural-wonder /
    -- goody-hut / barb-camp plots still COUNT as revealed -- the user
    -- is being told how many tiles came into view, and skipping those
    -- from the headline would underreport. The skip rule only applies
    -- to payload generation: the engine fires its own popup for those,
    -- so listing them again as "Resources" / "Cities" is the redundant
    -- bit, not the count.
    local announcePlots = {}
    local revealedCount = 0
    for idx in pairs(firstReveals) do
        local plot = Map.GetPlotByIndex(idx)
        if plot ~= nil then
            revealedCount = revealedCount + 1
            if not shouldSkipPlot(plot) then
                announcePlots[idx] = plot
            end
        end
    end
    for idx in pairs(nowVisible) do
        if not firstReveals[idx] then
            local plot = Map.GetPlotByIndex(idx)
            if plot ~= nil and not shouldSkipPlot(plot) then
                announcePlots[idx] = plot
            end
        end
    end

    local enemyUnits, otherUnits, cities, resources = {}, {}, {}, {}
    local goneCamps, goneRuins = 0, 0

    for idx, plot in pairs(announcePlots) do
        -- Cities and resources only on first-reveal plots. Neither
        -- changes on revisit, so re-announcing London every time the
        -- player walks back into the city plot's vision (or iron every
        -- time the unit passes the resource) would be noise. The
        -- engine fires its own city-founded notification for cities
        -- discovered after that plot was already revealed.
        -- Plot:GetResourceType(team) returns NO_RESOURCE when the
        -- team lacks the prereq tech, so tech-gating is automatic.
        if firstReveals[idx] then
            local city = plot:GetPlotCity()
            if city ~= nil then
                local cityOwner = Players[city:GetOwner()]
                if cityOwner ~= nil and cityOwner:GetTeam() ~= activeTeam then
                    cities[#cities + 1] = city:GetName()
                end
            end
            local rType = plot:GetResourceType(activeTeam)
            if rType ~= nil and rType >= 0 then
                local name = resourceName(rType)
                if name ~= nil then
                    resources[#resources + 1] = name
                end
            end
        end
        -- Units only on currently-visible plots, and only units that
        -- aren't already in _visibleUnits (the snapshot from the
        -- previous flush, also rebuilt at TurnStart). A known-visible
        -- foreign unit shouldn't re-announce every time the player
        -- walks in / out of fog on its plot, and the TurnStart reset
        -- means a unit that entered view during the AI turn is in
        -- the snapshot before the player's first move flushes here --
        -- ForeignUnitWatch already announced it as "entered" so
        -- repeating "revealed" would double-speak. Map-share-only
        -- reveals put the plot in firstReveals without nowVisible:
        -- the terrain is known but unit positions are not. Collect
        -- metadata (civ adjective + unit description key) rather than
        -- a flat name so formatUnitList can aggregate identical units
        -- and prefix the civ adjective the same way the hide direction
        -- does -- otherwise the player hears "Enemy: Warrior, Warrior"
        -- with no clue whose Warriors those are.
        if nowVisible[idx] then
            local n = plot:GetNumLayerUnits(-1)
            for i = 0, n - 1 do
                local unit = plot:GetLayerUnit(i, -1)
                if unit ~= nil and not unit:IsInvisible(activeTeam, false) then
                    local ownerId = unit:GetOwner()
                    local bucket = unitOwnerBucket(ownerId, activePlayerId, activeTeam)
                    if bucket ~= nil and Players[ownerId] ~= nil then
                        local key = ForeignUnitSnapshot.unitKey(ownerId, unit:GetID())
                        if _visibleUnits[key] == nil then
                            local meta = ForeignUnitSnapshot.metadata(unit, ownerId, bucket)
                            if meta.civAdjKey ~= nil and meta.unitDescKey ~= nil then
                                if bucket == "enemy" then
                                    enemyUnits[#enemyUnits + 1] = meta
                                else
                                    otherUnits[#otherUnits + 1] = meta
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Gone-on-revisit walk. Iterates nowVisible directly rather than
    -- announcePlots: shouldSkipPlot filters out plots whose CURRENT
    -- improvement is a camp / ruin (because the engine speaks new
    -- camps / ruins via popup), but the gone diff needs to know the
    -- LAST-KNOWN camp / ruin state, which can only come from the Lua
    -- snapshot. Reading GetImprovementType here, comparing to the
    -- snapshot's stored kind, and writing the snapshot afterwards. The
    -- diff is gated to revisits (`not firstReveals[idx]`) since
    -- first-reveals have nothing prior to compare; the snapshot still
    -- updates for first-reveals so a subsequent walk-away-and-back
    -- cycle has a baseline.
    for idx in pairs(nowVisible) do
        local plot = Map.GetPlotByIndex(idx)
        if plot ~= nil then
            local nowKind = classifyImprovementAsCampOrRuin(plot:GetImprovementType())
            if not firstReveals[idx] then
                local prevKind = _campOrRuinKind[idx]
                if prevKind ~= nil and prevKind ~= nowKind then
                    if prevKind == "camp" then
                        goneCamps = goneCamps + 1
                    else
                        goneRuins = goneRuins + 1
                    end
                end
            end
            _campOrRuinKind[idx] = nowKind
        end
    end

    local payload = {}
    if #enemyUnits > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_ENEMY", formatUnitList(enemyUnits))
    end
    if #otherUnits > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_UNITS", formatUnitList(otherUnits))
    end
    if #cities > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_CITIES", table.concat(cities, ", "))
    end
    if #resources > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_RESOURCES", table.concat(resources, ", "))
    end

    -- Reveal headline form: "<N> tiles revealed" when something
    -- unexplored just got revealed; "Revealed" alone otherwise.
    -- Revisit-only events with no payload to mention produce no reveal
    -- line (no point speaking "Revealed" with nothing after it). Hide
    -- always runs after this regardless -- a flush with no reveal but
    -- a unit slipping into fog still needs to fire the "Hidden" line.
    local revealLine
    if revealedCount > 0 then
        local headline = Text.formatPlural("TXT_KEY_CIVVACCESS_REVEAL_COUNT", revealedCount, revealedCount)
        if #payload > 0 then
            revealLine = headline .. ": " .. table.concat(payload, ". ")
        else
            revealLine = headline
        end
    elseif #payload > 0 then
        revealLine = Text.key("TXT_KEY_CIVVACCESS_REVEAL_HEADER") .. ": " .. table.concat(payload, ". ")
    end

    -- Hide diff: foreign units that were in the last-flush snapshot but
    -- aren't visible now. Drop entries whose owner no longer has the
    -- unit (destroyed or captured) -- combat readouts speak kills, and
    -- listing a killed unit as "hidden" would be misleading. Snapshot
    -- updates after the diff so the next burst diffs against the
    -- post-flush state.
    local currentUnits = buildVisibleForeignUnits()
    local enemyHidden, otherHidden = {}, {}
    for key, prev in pairs(_visibleUnits) do
        if currentUnits[key] == nil then
            local owner = Players[prev.ownerId]
            if owner ~= nil and owner:GetUnitByID(prev.unitId) ~= nil then
                if prev.bucket == "enemy" then
                    enemyHidden[#enemyHidden + 1] = prev
                else
                    otherHidden[#otherHidden + 1] = prev
                end
            end
        end
    end
    _visibleUnits = currentUnits

    local hidePayload = {}
    if #enemyHidden > 0 then
        hidePayload[#hidePayload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_ENEMY", formatUnitList(enemyHidden))
    end
    if #otherHidden > 0 then
        hidePayload[#hidePayload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_UNITS", formatUnitList(otherHidden))
    end
    local hideLine
    if #hidePayload > 0 then
        hideLine = Text.key("TXT_KEY_CIVVACCESS_HIDDEN_HEADER") .. ": " .. table.concat(hidePayload, ". ")
    end

    -- Gone line: per-category plural counts joined with the same AND
    -- key ForeignClearWatch uses, prefixed with the GONE_HEADER + ": "
    -- to mirror the Revealed: / Hidden: shape.
    local goneLine
    if goneCamps > 0 or goneRuins > 0 then
        local goneParts = {}
        if goneCamps > 0 then
            goneParts[#goneParts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_GONE_CAMP_PART", goneCamps, goneCamps)
        end
        if goneRuins > 0 then
            goneParts[#goneParts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_GONE_RUIN_PART", goneRuins, goneRuins)
        end
        goneLine = Text.key("TXT_KEY_CIVVACCESS_GONE_HEADER")
            .. ": "
            .. table.concat(goneParts, Text.key("TXT_KEY_CIVVACCESS_FOREIGN_CLEAR_AND"))
    end

    if revealLine ~= nil then
        SpeechPipeline.speakQueued(revealLine)
        MessageBuffer.append(revealLine, "reveal")
    end
    if hideLine ~= nil then
        SpeechPipeline.speakQueued(hideLine)
        MessageBuffer.append(hideLine, "reveal")
    end
    if goneLine ~= nil then
        SpeechPipeline.speakQueued(goneLine)
        MessageBuffer.append(goneLine, "reveal")
    end
end

-- Silent snapshot rebuild at the start of every player turn so the next
-- flush's hide diff is against post-AI-turn state, not the stale
-- end-of-last-player-turn state. Without this, a foreign unit that
-- walked into fog during the AI turn (which ForeignUnitWatch already
-- speaks as "left" at turn start) is still in _visibleUnits, so the
-- first flush after the player's first move re-announces it as hidden
-- and the user hears the same unit twice from two sources.
function RevealAnnounce._onTurnStart()
    local ok, err = pcall(function()
        _visibleUnits = buildVisibleForeignUnits()
    end)
    if not ok then
        Log.error("RevealAnnounce: TurnStart snapshot reset failed: " .. tostring(err))
    end
end

-- Registers fresh listeners on every call. See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: load-game-from-game
-- kills the prior Context's env, stranding listeners that captured its
-- closures.
function RevealAnnounce.installListeners()
    -- Prime the foreign-unit snapshot so the first flush has a real
    -- baseline. With an empty snapshot the diff iterates nothing, so
    -- the first move after install would silently miss any unit it
    -- pushes into fog. Subsequent flushes self-maintain via the
    -- snapshot rebuild at the end of _flush, and _onTurnStart resyncs
    -- the snapshot across AI turns. Re-priming on every installListeners
    -- call is intentional: load-from-game resets the module-local
    -- _visibleUnits to the file-scope default, so the baseline has to
    -- be re-established against the new game's state.
    _visibleUnits = buildVisibleForeignUnits()
    -- Reset the gone-on-revisit snapshot and bootstrap from the engine's
    -- per-team revealed-improvement-type. Bootstrap must run BEFORE the
    -- player's first move triggers changeVisibilityCount, since that
    -- call's setRevealed body synchronously rewrites the engine's
    -- revealed-type to the current improvement; the snapshot then drives
    -- detection on its own.
    _campOrRuinKind = {}
    bootstrapCampOrRuinSnapshot()
    Log.installEvent(
        GameEvents,
        "CivVAccessPlotRevealed",
        recordFirstReveal,
        "RevealAnnounce",
        "first-reveal announces disabled (engine fork not deployed?)"
    )
    Log.installEvent(Events, "HexFOWStateChanged", recordNowVisible, "RevealAnnounce")
    Log.installEvent(Events, "ActivePlayerTurnStart", RevealAnnounce._onTurnStart, "RevealAnnounce")
end

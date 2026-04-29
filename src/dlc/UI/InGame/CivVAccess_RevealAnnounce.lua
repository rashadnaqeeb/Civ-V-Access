-- Speaks reveal and hide lines after a unit move (or any visibility-
-- change source) so blind players know what just appeared on or
-- disappeared from the map. The base game has no equivalent feedback:
-- sighted players see new terrain / units / cities slide into view
-- (and old ones slide back into fog) while a screen-reader user has
-- nothing to react to.
--
-- Two readouts in one flush. Reveal lists tiles that came into view
-- with their foreign-unit / foreign-city / resource payload. Hide
-- lists foreign units that left view because the active player's
-- actions retracted LOS (a unit moved away, a unit died, a city was
-- lost). Cities and resources are excluded from the hide direction:
-- once discovered they stay revealed -- only unit positions actually
-- become unknown again. A single move can emit either or both lines;
-- when both fire, reveal speaks first and hide queues after.
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
-- resources), revisit plots (came back into sight on a known tile)
-- get just units + cities, since the resource and terrain weren't new
-- there. Mixed ticks combine: total count plus the union, with
-- resources still scoped to the first-reveal subset.
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
local function unitOwnerBucket(ownerId, activePlayerId, activeTeam)
    if ownerId == activePlayerId then
        return nil
    end
    local owner = Players[ownerId]
    if owner == nil then
        return nil
    end
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

local function visibilityKey(ownerId, unitId)
    return tostring(ownerId) .. ":" .. tostring(unitId)
end

-- Metadata shape used by both directions: { ownerId, unitId, civAdjKey,
-- unitDescKey, bucket }. The reveal direction populates from plot-walk
-- (announcePlots) and hands the list to formatUnitList for the same
-- "{count} {civ adj} {unit name}" rendering the hide direction uses.
-- Snapshot keys foreign units by "<ownerId>:<unitId>" so the hide diff
-- can drop captures (the captured unit appears under a different
-- ownerId in the new snapshot, so the original key fails to match and
-- the still-alive guard catches the rest).
local function unitVisibilityMetadata(unit, ownerId, bucket)
    local civAdjKey = Players[ownerId]:GetCivilizationAdjectiveKey()
    local row = GameInfo.Units[unit:GetUnitType()]
    local unitDescKey = row and row.Description or nil
    return {
        ownerId = ownerId,
        unitId = unit:GetID(),
        civAdjKey = civAdjKey,
        unitDescKey = unitDescKey,
        bucket = bucket,
    }
end

-- Walks every foreign player slot and collects visible-to-active-team
-- units into a keyed table. Mirrors ForeignUnitWatch.buildVisibleSet's
-- visibility filter (IsVisible AND not IsInvisible) so stealth and
-- recon-blocking behave the same way for both directions.
local function buildVisibleForeignUnits()
    local set = {}
    local activePlayerId = Game.GetActivePlayer()
    local activeTeam = Game.GetActiveTeam()
    local maxIndex = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 63
    for i = 0, maxIndex do
        if i ~= activePlayerId then
            local player = Players[i]
            if player ~= nil and player:IsAlive() then
                local bucket = unitOwnerBucket(i, activePlayerId, activeTeam)
                if bucket ~= nil then
                    for unit in player:Units() do
                        if not unit:IsInvisible(activeTeam, false) then
                            local plot = unit:GetPlot()
                            if plot ~= nil and plot:IsVisible(activeTeam, false) then
                                local meta = unitVisibilityMetadata(unit, i, bucket)
                                if meta.civAdjKey ~= nil and meta.unitDescKey ~= nil then
                                    set[visibilityKey(i, unit:GetID())] = meta
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return set
end

-- "3 Arabian Warrior" form, comma-joined, sorted alphabetically by
-- (civAdjKey, unitDescKey). Used by both directions: reveal and hide
-- render their unit lists the same way so the player hears a
-- consistent "<count> <civ adj> <unit name>" shape regardless of
-- direction. Sorting matters: pairs() on the counts table is non-
-- deterministic, and an unsorted output reorders the list across
-- flushes even when the content is identical, which sounds "wrong" to
-- a user tracking a familiar list.
local function formatUnitList(entries)
    local counts = {}
    local order = {}
    for _, e in ipairs(entries) do
        local key = e.civAdjKey .. "|" .. e.unitDescKey
        local bucket = counts[key]
        if bucket == nil then
            counts[key] = {
                count = 1,
                civ = Text.key(e.civAdjKey),
                unit = Text.key(e.unitDescKey),
            }
            order[#order + 1] = key
        else
            bucket.count = bucket.count + 1
        end
    end
    table.sort(order)
    local pieces = {}
    for _, k in ipairs(order) do
        local b = counts[k]
        if b.count > 1 then
            pieces[#pieces + 1] = tostring(b.count) .. " " .. b.civ .. " " .. b.unit
        else
            pieces[#pieces + 1] = b.civ .. " " .. b.unit
        end
    end
    return table.concat(pieces, ", ")
end

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

    for idx, plot in pairs(announcePlots) do
        local city = plot:GetPlotCity()
        if city ~= nil then
            local cityOwner = Players[city:GetOwner()]
            if cityOwner ~= nil and cityOwner:GetTeam() ~= activeTeam then
                cities[#cities + 1] = city:GetName()
            end
        end
        -- Units only on currently-visible plots. A map-share-only
        -- reveal puts the plot in firstReveals without nowVisible:
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
                        local meta = unitVisibilityMetadata(unit, ownerId, bucket)
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
        -- Resources only on first-reveal plots: they don't change on a
        -- revisit, so re-announcing iron every time the player walks
        -- past it would be noise. Plot:GetResourceType(team) returns
        -- NO_RESOURCE when the team lacks the prereq tech, so
        -- tech-gating is automatic.
        if firstReveals[idx] then
            local rType = plot:GetResourceType(activeTeam)
            if rType ~= nil and rType >= 0 then
                local name = resourceName(rType)
                if name ~= nil then
                    resources[#resources + 1] = name
                end
            end
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
        local headline = Text.format("TXT_KEY_CIVVACCESS_REVEAL_COUNT", revealedCount)
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

    if revealLine ~= nil then
        SpeechPipeline.speakQueued(revealLine)
        MessageBuffer.append(revealLine, "reveal")
    end
    if hideLine ~= nil then
        SpeechPipeline.speakQueued(hideLine)
        MessageBuffer.append(hideLine, "reveal")
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
    if GameEvents ~= nil and GameEvents.CivVAccessPlotRevealed ~= nil then
        GameEvents.CivVAccessPlotRevealed.Add(recordFirstReveal)
    else
        Log.warn(
            "RevealAnnounce: GameEvents.CivVAccessPlotRevealed missing; first-reveal announces disabled (engine fork not deployed?)"
        )
    end
    if Events ~= nil and Events.HexFOWStateChanged ~= nil then
        Events.HexFOWStateChanged.Add(recordNowVisible)
    else
        Log.warn("RevealAnnounce: Events.HexFOWStateChanged missing")
    end
    if Events ~= nil and Events.ActivePlayerTurnStart ~= nil then
        Events.ActivePlayerTurnStart.Add(RevealAnnounce._onTurnStart)
    else
        Log.warn("RevealAnnounce: Events.ActivePlayerTurnStart missing")
    end
end

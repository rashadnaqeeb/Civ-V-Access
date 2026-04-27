-- Speaks a "tiles revealed" line after a unit move (or any reveal source)
-- so blind players know what just appeared on the map. The base game has
-- no equivalent feedback: sighted players see the new terrain, units, and
-- cities slide into view, but a screen-reader user has nothing to react
-- to.
--
-- Dual signal. The fork-added GameEvents.CivVAccessPlotRevealed (CvPlot.cpp
-- inside the existing isRevealed != bNewValue guard) fires only on first
-- reveal of a plot for a team. Events.HexFOWStateChanged fires on every
-- visibility transition. We listen to both: first-reveal plots get the
-- full payload (units + cities + resources), revisit plots (came back
-- into sight on a known tile) get just units + cities, since the resource
-- and terrain weren't new there. Mixed ticks combine: total count plus
-- the union, with resources still scoped to the first-reveal subset.
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
-- Skip rules. Natural-wonder features, goody-hut improvements, and
-- barbarian-camp improvements are excluded -- the engine fires its own
-- popups/notifications for those, and announcing them again is double-
-- speech. Own units, own cities, and teammate units are excluded
-- (the player already knows where they are).

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

local function unitName(unit)
    local row = GameInfo.Units[unit:GetUnitType()]
    if row == nil or row.Description == nil then
        return nil
    end
    return Text.key(row.Description)
end

local function resourceName(resourceId)
    local row = GameInfo.Resources[resourceId]
    if row == nil or row.Description == nil then
        return nil
    end
    return Text.key(row.Description)
end

function RevealAnnounce._flush()
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
        -- the terrain is known but unit positions are not.
        if nowVisible[idx] then
            local n = plot:GetNumUnits()
            for i = 0, n - 1 do
                local unit = plot:GetUnit(i)
                if unit ~= nil and not unit:IsInvisible(activeTeam, false) then
                    local bucket = unitOwnerBucket(unit:GetOwner(), activePlayerId, activeTeam)
                    if bucket ~= nil then
                        local name = unitName(unit)
                        if name ~= nil then
                            if bucket == "enemy" then
                                enemyUnits[#enemyUnits + 1] = name
                            else
                                otherUnits[#otherUnits + 1] = name
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
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_ENEMY", table.concat(enemyUnits, ", "))
    end
    if #otherUnits > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_UNITS", table.concat(otherUnits, ", "))
    end
    if #cities > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_CITIES", table.concat(cities, ", "))
    end
    if #resources > 0 then
        payload[#payload + 1] = Text.format("TXT_KEY_CIVVACCESS_REVEAL_RESOURCES", table.concat(resources, ", "))
    end

    -- Headline form: "<N> tiles revealed" when something unexplored
    -- just got revealed; "Revealed" alone otherwise. Revisit-only
    -- events with no payload to mention are silent (no point speaking
    -- "Revealed" with nothing after it).
    local headline
    if revealedCount > 0 then
        headline = Text.format("TXT_KEY_CIVVACCESS_REVEAL_COUNT", revealedCount)
    elseif #payload > 0 then
        headline = Text.key("TXT_KEY_CIVVACCESS_REVEAL_HEADER")
    else
        return
    end

    if #payload > 0 then
        SpeechPipeline.speakQueued(headline .. ": " .. table.concat(payload, ". "))
    else
        SpeechPipeline.speakQueued(headline)
    end
end

-- Registers fresh listeners on every call. See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: load-game-from-game
-- kills the prior Context's env, stranding listeners that captured its
-- closures.
function RevealAnnounce.installListeners()
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
end


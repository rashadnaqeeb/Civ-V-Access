-- Plot-handle-in, cue-out mapping for the per-hex audio layer. Output shape:
-- { bed = "<name>", fog = bool, crossing = "river"|"bridge"|nil,
--   stingers = { "<name>", ... } } or nil for an unrevealed plot.
--
-- PlotAudio.loadAll() preloads every sound in the palette into the proxy's
-- audio bank and stashes the name-to-handle map on civvaccess_shared so
-- re-entered Contexts reuse the existing handles (the proxy also dedups by
-- name; both guards keep the bank from filling up with duplicates).
--
-- PlotAudio.emit(plot, prevPlot) is the one-call dispatcher used by the
-- cursor layer: cancel in-flight audio, then play crossing (if any) at t=0,
-- bed + optional fog at the post-crossing slot, and stingers one slot
-- later. prevPlot is optional; supply it when the cursor moved across an
-- edge so the river/bridge layer can resolve. A nil prevPlot (programmatic
-- jump) suppresses the edge layer.
--
-- Natural wonders do NOT promote to a feature bed here. The bed for a
-- wonder plot comes from the plot's mountain/terrain core, and wonder
-- identity is spoken by the cursor pipeline separately (no dedicated wonder
-- sound in the palette).
--
-- See .planning/audio-cues-plan.md for the sound-palette rationale.

PlotAudio = PlotAudio or {}

-- Inter-layer spacing. Stingers fire one slot after the bed so they read
-- as discrete events on top rather than fusing into the bed's onset.
-- The river/bridge crossing layer reuses the same slot length, plays one
-- step earlier than the bed, and pushes the rest of the stack back by one
-- slot. Upper end of the plan's 50-100 ms range; revisit by ear.
local STINGER_OFFSET_MS = 100

-- Fog wash plays at half per-sound volume so it reads as a tint on the bed
-- rather than a discrete event. Applied once at load via audio.set_volume
-- and inherited on every subsequent play of the fog slot.
local FOG_VOLUME = 0.5

-- Route stinger plays louder than the rest so a route on the tile reads
-- distinctly through the bed instead of getting buried in it. Applies to
-- both road and railroad slots; same one-shot audio.set_volume pattern as
-- fog, just on the other side of unity.
local ROUTE_VOLUME = 1.25

-- Features whose bed replaces the terrain bed. Each has exactly one allowed
-- base terrain per Feature_TerrainBooleans, so the underlying terrain is
-- recoverable from the feature bed alone.
local PROMOTABLE_FEATURES = {
    FEATURE_JUNGLE = "jungle",
    FEATURE_MARSH = "marsh",
    FEATURE_FLOOD_PLAINS = "floodplain",
    FEATURE_OASIS = "oasis",
    FEATURE_ICE = "ice",
    FEATURE_ATOLL = "atoll",
}

-- Features that layer a stinger over the bed. Forest spawns on multiple
-- base terrains; fallout on anything. Neither can serve as a bed.
local STINGER_FEATURES = {
    FEATURE_FOREST = "forest",
    FEATURE_FALLOUT = "fallout",
}

-- Base terrain beds. Coast and ocean collapse into one water bed; lake is
-- routed here via plot:IsLake() since lake is not its own terrain type.
local TERRAIN_BEDS = {
    TERRAIN_GRASS = "grassland",
    TERRAIN_PLAINS = "plains",
    TERRAIN_DESERT = "desert",
    TERRAIN_TUNDRA = "tundra",
    TERRAIN_SNOW = "snow",
    TERRAIN_COAST = "water",
    TERRAIN_OCEAN = "water",
}

local function allSoundNames()
    local set = {
        mountain = true,
        fog = true,
        road = true,
        railroad = true,
        river = true,
        bridge = true,
    }
    for _, v in pairs(PROMOTABLE_FEATURES) do
        set[v] = true
    end
    for _, v in pairs(STINGER_FEATURES) do
        set[v] = true
    end
    for _, v in pairs(TERRAIN_BEDS) do
        set[v] = true
    end
    local list = {}
    for n in pairs(set) do
        list[#list + 1] = n
    end
    return list
end

local function featureRow(plot)
    local fid = plot:GetFeatureType()
    if fid == nil or fid < 0 then
        return nil
    end
    return GameInfo.Features[fid]
end

-- Edge-crossing layer. Engine model from CvUnitMovement.cpp:74:
--   bridge in effect = both endpoint plots have a (non-pillaged) route
--                      AND the team has bridge-building tech.
-- "Revealed route" here matches the road stinger's fog-respecting check
-- so the cue stays consistent with what speech says about the tile.
local function crossingFor(plot, prevPlot, team, debug)
    if prevPlot == nil then
        return nil
    end
    if not prevPlot:IsRiverCrossingToPlot(plot) then
        return nil
    end
    local fromRoute = prevPlot:GetRevealedRouteType(team, debug) or -1
    local toRoute = plot:GetRevealedRouteType(team, debug) or -1
    if fromRoute >= 0 and toRoute >= 0 then
        local activeTeam = Teams[team]
        if activeTeam ~= nil and activeTeam:IsBridgeBuilding() then
            return "bridge"
        end
    end
    return "river"
end

function PlotAudio.cueForPlot(plot, prevPlot)
    if plot == nil then
        return nil
    end
    local team = Game.GetActiveTeam()
    local debug = Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        return nil
    end

    local fRow = featureRow(plot)
    local bed

    if plot:IsMountain() then
        bed = "mountain"
    elseif fRow and not fRow.NaturalWonder then
        bed = PROMOTABLE_FEATURES[fRow.Type]
    end

    if bed == nil then
        local tid = plot:GetTerrainType()
        local tRow = tid ~= nil and tid >= 0 and GameInfo.Terrains[tid] or nil
        bed = tRow and TERRAIN_BEDS[tRow.Type] or nil
        if bed == nil and (plot:IsLake() or plot:IsWater()) then
            bed = "water"
        end
    end

    if bed == nil then
        Log.warn("PlotAudio.cueForPlot: unresolved bed, defaulting to grassland")
        bed = "grassland"
    end

    local fog = not plot:IsVisible(team, debug)
    local crossing = crossingFor(plot, prevPlot, team, debug)

    local stingers = {}
    if fRow then
        local stinger = STINGER_FEATURES[fRow.Type]
        if stinger ~= nil then
            stingers[#stingers + 1] = stinger
        end
    end
    -- Fog-respecting: on a revealed-but-not-visible plot where a route was
    -- built or pillaged while the player wasn't looking, we must match what
    -- speech says about the tile. The route section uses the Revealed*
    -- variant; so do we, with the same team/debug values.
    --
    -- The bridge crossing already implies a route on the destination plot
    -- (that's a precondition of the bridge resolution), so a separate route
    -- stinger would be redundant after the bridge sound. The river crossing
    -- carries no such implication and the stinger still fires there.
    --
    -- Railroad and road share dispatch shape but distinct sounds; the
    -- type-switch picks which slot fires. Unknown route types fall back
    -- to the road slot rather than going silent.
    local rid = plot:GetRevealedRouteType(team, debug)
    if rid ~= nil and rid >= 0 and crossing ~= "bridge" then
        local rRow = GameInfo.Routes[rid]
        if rRow and rRow.Type == "ROUTE_RAILROAD" then
            stingers[#stingers + 1] = "railroad"
        else
            stingers[#stingers + 1] = "road"
        end
    end

    return {
        bed = bed,
        fog = fog,
        crossing = crossing,
        stingers = stingers,
    }
end

function PlotAudio.loadAll()
    if civvaccess_shared.plotAudioHandles ~= nil then
        return
    end
    if audio == nil then
        Log.warn("PlotAudio.loadAll: audio binding missing")
        return
    end
    local handles = {}
    local loaded, missed = 0, 0
    for _, name in ipairs(allSoundNames()) do
        local h = audio.load(name)
        if h == nil then
            Log.error("PlotAudio.loadAll: failed to load " .. name)
            missed = missed + 1
        else
            handles[name] = h
            loaded = loaded + 1
        end
    end
    civvaccess_shared.plotAudioHandles = handles
    if handles.fog ~= nil then
        audio.set_volume(handles.fog, FOG_VOLUME)
    end
    if handles.road ~= nil then
        audio.set_volume(handles.road, ROUTE_VOLUME)
    end
    if handles.railroad ~= nil then
        audio.set_volume(handles.railroad, ROUTE_VOLUME)
    end
    Log.info("PlotAudio.loadAll: loaded " .. tostring(loaded) .. ", missed " .. tostring(missed))
end

local function handleFor(name)
    local h = civvaccess_shared.plotAudioHandles
    return h and h[name] or nil
end

local function playAt(name, delayMs)
    local h = handleFor(name)
    if h == nil then
        return
    end
    if delayMs == 0 then
        audio.play(h)
    else
        audio.play_delayed(h, delayMs)
    end
end

function PlotAudio.emit(plot, prevPlot)
    if audio == nil then
        return
    end
    local cue = PlotAudio.cueForPlot(plot, prevPlot)
    audio.cancel_all()
    if cue == nil then
        return
    end

    -- Layered onset. With a crossing, river/bridge plays at t=0 and the
    -- bed/stinger stack shifts down by one slot so the crossing has the
    -- foreground for the same gap the bed and stingers always have between
    -- themselves. Without a crossing, timing is unchanged from before.
    local bedDelay = 0
    if cue.crossing ~= nil then
        playAt(cue.crossing, 0)
        bedDelay = STINGER_OFFSET_MS
    end

    playAt(cue.bed, bedDelay)
    if cue.fog then
        playAt("fog", bedDelay)
    end
    for _, name in ipairs(cue.stingers) do
        playAt(name, bedDelay + STINGER_OFFSET_MS)
    end
end
